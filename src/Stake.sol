//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./BAYU.sol";
import "solmate/tokens/ERC20.sol";

contract Stake{

    event Staked(address indexed user, uint216 amount);
    event Withdrawn(address indexed user, uint216 amount);
    event InterestCompounded(address indexed user, uint216 amount);


    address Maxi;
    uint256 factor = 1e11;
    uint256 delta = 3854;
    address BAYC = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;


    struct Stakedata{
        uint216 amountToStake;
        uint40 timeStaked;
        bool staked;
    }

    mapping(address => Stakedata) _stakeData;

    constructor(address _maxi) {
        Maxi = _maxi;
    }

    /// @dev function to stake token, only boreApe owners can stake
    function stake(uint216 amount) external{
        require(ERC20(Maxi).transferFrom(msg.sender, address(this), amount));
        Stakedata storage sd  = _stakeData[msg.sender];
        require(BAYU(BAYC).balanceOf(msg.sender) > 0, "balance not sufficient");
        if( sd.amountToStake > 0 ){
            uint216 currentReward = getInterest(msg.sender);
            sd.amountToStake += currentReward;
            emit InterestCompounded(msg.sender, uint216(currentReward));
        }
             sd.amountToStake += amount;
             sd.timeStaked = uint40(block.timestamp);
             //emit an event
             sd.staked = true;
            emit Staked(msg.sender, uint216(amount));
    }

    /// @dev function to calaculate interate rate after a specific amount of days
    function getInterest(address user) internal view returns(uint216 interest){
        Stakedata memory sd = _stakeData[user];
        //require(sd.amountToStake > 0, "You have no token");
        if(sd.amountToStake > 0){
            uint216 currentAmount = uint216(sd.amountToStake);
            uint40 duration = uint40(block.timestamp) - sd.timeStaked;
            interest = uint216(delta * duration * currentAmount);
            interest/= uint216(factor);
        }
    }

        /// @dev function to withdraw staked amount in batches

        function withdraw (uint256 amount) external {
            Stakedata storage sd = _stakeData[msg.sender];
            require(sd.staked == true);
            require( sd.amountToStake >= amount, "No sufficient token");
            uint216 amountToSend = uint216(amount);
            amountToSend += getInterest(msg.sender);
            sd.amountToStake -= uint216(amount);
            sd.timeStaked = uint40(block.timestamp);
            ERC20(Maxi).transfer(msg.sender, amountToSend);
            emit Withdrawn(msg.sender, amountToSend);
        }

        // @dev function to get a particular user staking information.
        function getUserData(address user) public view returns(Stakedata memory sd){
            sd = _stakeData[user];
        }
}

