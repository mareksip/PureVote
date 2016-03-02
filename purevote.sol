contract PurePoll{

    //define Poll attributes and state variables
    struct Poll{
        //address of creator
        address creator;
        //name of the poll
        bytes32 text;
        //not required contract expiration
        //expires when eth runs out
        uint deadline;
        //number of casted votes
        uint totalVotes;
        //checking if Poll ended
        bool status;
    }
    //Elegible addresses that can vote
    struct Voter{
        address addr;
        bool voted;
        uint weight;
    }
    //options to be voted
    struct Option{
        //name of option
        bytes32 text;
        //number of casted votes
        uint votes;
    }
    Option[] public options;
    Voter[] public voters;

    Poll public p;

      // event tracking of all votes
  event NewVote(bytes32 votechoice);

     //initiator function that stores the necessary poll information
  function NewPoll(bytes32 _text, bytes32[] _options, address[] _voters, uint _deadline) {
    p.creator = msg.sender;
    p.text = _text;
    p.deadline = _deadline;
    p.status = true;
    p.totalVotes = 0;

    // Add each option to contract options
    for (uint i = 0; i < _options.length; i++){
        // Option({}) creates a temporary Option object
        // options.push(...) appends _option to contract options
            options.push(Option({
            text: _options[i],
            votes: 0
            }));
    }
    for (uint x = 0; x < _voters.length; x++){
        // Option({}) creates a temporary Option object
        // options.push(...) appends _option to contract options
            voters.push(Voter({
            addr: _voters[x],
            voted: false,
            weight: 1
            }));
            //TODO: assign correct votes
    }
  }
    //function for user vote. input is a string choice
  function vote(bytes32 _choice) returns (bool) {
      //TODO: check for passed deadline
    if (msg.sender != p.creator || p.status != true) {
      return false;
    }

    uint voteWeight = 1; //default weight is 1

    if(voters.length != 0){
        //Poll requires authentication
        bool verified = false;
        for(uint i = 0; i < voters.length; i++){
            //loopin through elegible voters
            if(msg.sender == voters[i].addr){
                //address corresponds verify if havent voted
                if(voters[i].voted == false){
                    verified = true;
                    //assign voting power
                    voteWeight = voters[i].weight;
                }

            }
        }
        if(!verified){
            //only specific addresses are allowed to vote
            //senders address was not found  or
            //address already casted a vote
            return false;
        }

    }

    for(uint x = 0; x < options.length; x++){
            //loopin through options
            if(_choice == options[x].text){
                //vote casted
                options[x].votes += voteWeight;
                p.totalVotes += 1;
            }
            else{
                //choice was not found
                return false;
            }
    }
    NewVote(_choice);

    return true;
  }
    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() constant
            returns (uint winningProposal)
    {
        uint winningVoteCount = 0;
        for (uint o = 0; o < options.length; o++)
        {
            if (options[o].votes > winningVoteCount)
            {
                winningVoteCount = options[o].votes;
                winningProposal = o;
            }
        }
    }

  //when time or vote limit is reached, set the poll status to false
  function endPoll() returns (bool) {
    if (msg.sender != p.creator) {
      return false;
    }
    p.status = false;
    return true;
  }
}
