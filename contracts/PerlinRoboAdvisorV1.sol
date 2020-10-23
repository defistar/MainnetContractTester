//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.10 <0.6.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IRToken {
    function mintWithNewHat(uint256 mintAmount, address[] calldata recipients, uint32[] calldata proportions) 
                                                                    external returns (bool);
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

   
}

contract PerlinRoboAdvisorV1 {
    using SafeMath for uint256;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    
    address public DEPLOYER;
    address public treasury;
    address public rDai;
    address public dai;
    IERC20  public daiToken;
    IERC20  public rDaiToken;

      // Events
    event DaiApproved(
        address indexed sender,
        address indexed rdaiContractAddress,
        uint256 amount
    );

    event DaiAllowanceFound(
        address indexed sender,
        address indexed rdaiContractAddress,
        uint256 allowanceAmount
    );

    event DaiAllowanceValidation(
        address indexed sender,
        address indexed rdaiContractAddress,
        uint256 allowanceAmount,
        uint256 investment
    );

    event DaiAllowance( address indexed owner,
        address indexed spender,
        uint256 amount);

    // Only Admin can execute
    modifier onlyAdmin() {
        require(msg.sender == DEPLOYER, "Must be Admin");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

      // Only Deployer can execute
    modifier onlyDeployer() {
        require(msg.sender == DEPLOYER, "DeployerErr");
        _;
    }

    constructor(address _treasury, address _dai, address _rDai) public {
        DEPLOYER = msg.sender;
        treasury = _treasury; 
        dai = _dai;
        daiToken = IERC20(dai);
        rDai = _rDai;
        rDaiToken = IERC20(rDai);
        _status = _NOT_ENTERED;

    }

    function purgeDeployer() public onlyDeployer {
        DEPLOYER = address(0);
    }

  
    //non-custodial investment of DAI

    /**
     * @dev IRToken.mintWithNewHat implementation
     */
    function investDai(uint mintAmount) public returns (bool) {
        uint allowanceFromUser  = daiToken.allowance(msg.sender, address(this));
        emit DaiAllowanceFound(msg.sender, rDai, allowanceFromUser);
        emit DaiAllowanceValidation(msg.sender, rDai, allowanceFromUser, mintAmount);
        require(allowanceFromUser >= mintAmount , "Insufficient DAI - Please increase DAI allowance for roboAdvisor");
        require(daiToken.transferFrom(msg.sender, address(this), mintAmount), "Failed to transfer DAI to RoboAdvisor");
        require(daiToken.approve(rDai, mintAmount), "Failed to allocate DAI funds to rDAI");
        address[] memory recipients = new address[](2);
        recipients[0] = treasury;
        recipients[1] = msg.sender;
        uint32[] memory proportions = new uint32[](2);
        proportions[0] = 90;
        proportions[1] = 10;
        require(IRToken(rDai).mintWithNewHat(mintAmount, recipients, proportions));
        require(rDaiToken.transferFrom(address(this), msg.sender, mintAmount), "failed to transfer rDai token to Investor");
        return true;
    }

    function getAllowanceOfRoboAdvisorWithDai(address investor) public view returns (uint) {
        return daiToken.allowance(msg.sender, address(this));
    }

    function getAllocatedDAIByRoboAdvisorTorDai() public view onlyAdmin returns (uint){
        return daiToken.allowance(address(this), rDai);
    }

    function getDaiBalanceOfSender() public view returns (uint) {
        return daiToken.balanceOf(msg.sender);
    }

    function getrDaiBalanceOfSender() public view returns (uint) {
        return rDaiToken.balanceOf(msg.sender);
    }
}