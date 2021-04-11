pragma solidity ^0.8.3;

contract Voter {
    int256 public capitalInvestedInVote;
    mapping(address => int256) capitalContributed;

    struct VoteRecorded {
        bool vote;
        bool hasVoted;
    }
    mapping(address => VoteRecorded) public votesRecorded;

    int256 public voteBalance;
    bool public votingOpen = true;
    bool public voteOutcome;

    // _capitalInvested: capital (ETH) which the user uses to give weight to their vote.
    // _vote: bool which represents the user's vote for (true) or against (false) the proposal.
    // TODO: make payable?
    // TODO: add events.
    function receiveVote(int256 _capitalInvested, bool _vote)
        public
        returns (bool)
    {
        require(votingOpen = true, "ERROR vote: Vote has ended.");
        require(
            _capitalInvested > 0,
            "ERROR vote: Capital invested must be greater than 0."
        );

        if (votesRecorded[msg.sender].hasVoted == false) {
            // Register the vote.
            votesRecorded[msg.sender].vote = _vote;
            votesRecorded[msg.sender].hasVoted = true;

            // Increment the total capital invested.
            capitalInvestedInVote += _capitalInvested;

            // Increment the voter's total contribution.
            capitalContributed[msg.sender] += _capitalInvested;

            // Update the vote balance.
            updateVoteBalance(_capitalInvested, _vote);
        } else {
            // The voter has already voted.
            // Let them add to their position but not change their vote.
            bool existingVote = votesRecorded[msg.sender].vote;
            updateVoteBalance(_capitalInvested, existingVote);
        }

        return true;
    }

    // TODO: make private or internal?
    // TODO: add a time component, e.g. number of blocks.
    function decideVoteOutcome() public returns (bool) {
        // Close the vote;
        votingOpen = false;

        // Return the outcome.
        voteOutcome = voteBalance > 0;
        return voteOutcome;
    }

    // Update the vote balance based on the vote (for/against).
    function updateVoteBalance(int256 _amount, bool _vote) public {
        if (_vote == true) {
            voteBalance += _amount;
        } else {
            voteBalance -= _amount;
        }
    }
}
