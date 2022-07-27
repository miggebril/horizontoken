pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Horizon.sol";

contract HorizonStake {
    
    struct TokenStake
    {
        uint256 creationTime;

        uint256 stakingBalance;

        uint256 apyRate;

        bool isStaking;

        address depositContract;

        uint256 horizonBalance;
    }

    mapping(address => TokenStake) public stakingBalance;

    string public name = "Horizon Pool";

    IERC20 public exDao;
    HorizonToken public horizon;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed from, uint256 amount);

    constructor(IERC20 _exDao, HorizonToken _horizon)
    {
        exDao = _exDao;
        horizon = _horizon;
    }

    function isStaking(address user) public view returns(bool) {
        return stakingBalance[user].isStaking;
    }

    function stakingAmount(address user) public view returns(uint256) {
        return stakingBalance[user].stakingBalance;
    }

    function horizonAmount(address user) public view returns(uint256) {
        return stakingBalance[user].horizonBalance;
    }

    function apyRate(address user) public view returns(uint256) {
        return stakingBalance[user].apyRate;
    }

    function creationTime(address user) public view returns(uint256) {
        if (!stakingBalance[user].isStaking) {
            return 0;
        }

        return stakingBalance[user].creationTime;
    }

    function stake(uint256 amount) public {
        require(amount > 0 && exDao.balanceOf(msg.sender) >= amount, "You must stake a valid number of tokens which you already hold");

        if (stakingBalance[msg.sender].isStaking)
        {
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            stakingBalance[msg.sender].horizonBalance += toTransfer;
        }

        exDao.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender].stakingBalance += amount;
        stakingBalance[msg.sender].creationTime = block.timestamp;
        stakingBalance[msg.sender].isStaking = true;

        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(stakingBalance[msg.sender].isStaking && stakingBalance[msg.sender].stakingBalance >= amount, "Not staking a valid amount");

        uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        stakingBalance[msg.sender].creationTime = block.timestamp;
        uint256 balanceTransfer = amount;
        amount = 0;
        
        stakingBalance[msg.sender].stakingBalance -= balanceTransfer;
        exDao.transfer(msg.sender, balanceTransfer);
        stakingBalance[msg.sender].horizonBalance += yieldTransfer;
        
        if (stakingBalance[msg.sender].stakingBalance == 0) {
            stakingBalance[msg.sender].isStaking = false;
        }

        emit Unstake(msg.sender, amount);
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(toTransfer > 0 || stakingBalance[msg.sender].horizonBalance > 0, "Not withdrawing a valid amount");

        if (stakingBalance[msg.sender].horizonBalance != 0) {
            uint256 oldBalance = stakingBalance[msg.sender].horizonBalance;
            stakingBalance[msg.sender].horizonBalance = 0;
            toTransfer += oldBalance;
        }

        stakingBalance[msg.sender].creationTime = block.timestamp;
        horizon.mint(msg.sender, toTransfer);

        emit YieldWithdraw(msg.sender, toTransfer);
    }
    
    function calculateYieldTime(address user) public view returns(uint256) {
        uint256 end = block.timestamp;
        uint256 totalTime = end - stakingBalance[user].creationTime;
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user) * 10**18;
        uint256 rate = (86400 * 365) / stakingBalance[user].apyRate;
        uint256 timeRate = time / rate;
        uint256 rawYield = (stakingBalance[user].stakingBalance * timeRate) / 10**18;
        return rawYield;
    }
}