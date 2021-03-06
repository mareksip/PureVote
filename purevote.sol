contract PurePoll{
    //define Poll attributes and state variables
    struct Poll{
        //address of creator
        address creator;
        //name of the poll
        string text;
        //not required contract expiration UNIX timestamp
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
        uint value;
        //number of casted votes
        uint votes;
    }

    Option[] public options;
    Voter[] public voters;

    Poll public p;

    // event tracking of all votes
    event NewVote(uint votechoice);

    //initiator function that stores the necessary poll information
  function NewPoll(string _text, uint[] _options, address[] _voters, uint _deadline) {
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
            value: _options[i],
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
    }
  }
    //function for user vote. input is a string choice
  function vote(uint _choice) returns (bool) {
    //now = alias for block.timestamp
    if(now > p.deadline){
        p.status = false;
        return false;
    }

    if (msg.sender != p.creator || p.status != true) {
      return false;
    }

    uint voteWeight = 1; //default weight is 1

    if(voters.length > 0){
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
            //looping through options
            if(_choice == options[x].value){
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

  //only creator can end the poll
  function terminate() returns (bool) {
    if (msg.sender == p.creator) {
        p.status = false;
        return true;
    }
    return false;
  }

  //only creator can delete the contract
  function remove() returns (bool) {
    if (msg.sender == p.creator) {
      suicide(p.creator);
      return true;
    }
    return false;
  }
}
