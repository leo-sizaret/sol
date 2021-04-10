pragma solidity ^0.8.0;

contract TransferToken {
    string private _name;
    string private _symbol;

    mapping(address => uint256) balances;
    address public _owner;
    uint256 public _totalSupply = 1000000 * 10**18;
    uint256 public _decimals = 18;
    uint256 public _transferFee;

    event Transfer(address _from, address _to, uint256 _amount);
    event TransferWithFee(address _from, uint256 _amount, uint256 _fee);
    event ChangedFee(address _from, uint256 _previousFee, uint256 _newFee);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 _fee
    ) {
        // Set name and symbol.
        _name = name_;
        _symbol = symbol_;

        // Set owner as creator of the contract.
        _owner = msg.sender;

        // Allocate totalSupply to owner.
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        // Set transfer fee.
        changeTransferFee(_fee);
    }

    // ERC20 functionalities (will be overwritten by OpenZeppelin ERC20 contract in next version).
    // Return name of the token.
    function name() public view returns (string memory) {
        return _name;
    }

    // Return symbol of the token.
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // Return totalSupply.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Return the number of decimals. The OpenZeppelin default is 18 but we use 0 here.
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    // Return the balance of an address.
    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        _transferWithFee(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        _transferWithFee(_from, _to, _amount);
        return true;
    }

    // Transfer tokens from one address to another. Includes a 1% fee mechanism.
    function _transferWithFee(
        address _from,
        address _to,
        uint256 _amount
    ) public {
        require(
            _to != address(0),
            "ERROR transferWithFee: Cannot transfer to zero address."
        );
        require(_amount > 0, "ERROR transferWithFee: Invalid amount.");

        // Calculate fee and add it to obtain the total amount of the tx.
        uint256 transferFee = (_amount * _transferFee) / 100;
        uint256 totalAmount = _amount + transferFee;
        require(
            balances[_from] >= totalAmount,
            "ERROR transferWithFee: Balance insuficcient for transfer."
        );

        // Transfer _amount and send the fee to the contract.
        balances[_from] -= totalAmount;
        balances[_to] += _amount;
        balances[address(this)] += transferFee;

        // Add event incl. transfer and sending of fee to the contract.
        emit Transfer(_from, _to, _amount);
        // emit TransferWithFee(_from, _amount, transferFee);
    }

    // Set the transfer fee. Should be formatted as a percentage, e.g. 1 (i.e. 1%).
    function changeTransferFee(uint256 _fee) public {
        // Only the contract owner can set the fee. Can be changed later to a voting mechanism.
        require(
            _owner == msg.sender,
            "ERROR setTransferFee: Function must be called by contract owner."
        );
        uint256 previousFee = _transferFee;
        _transferFee = _fee;

        // Add event.
        emit ChangedFee(msg.sender, previousFee, _transferFee);
    }
}
