// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract ManualToken {
    error ManualToken__TransferInsufficientBalance();
    error ManualToken__TransferFromInsufficientAllowance();
    error ManualToken__WrongBurnAddress();
    error ManualToken__BurnInsufficientBalance();

    uint256 public s_totalSupply;
    mapping(address => uint256) public s_balances;
    mapping(address => mapping(address => uint256)) public s_allowaneces;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // You can use this to replace your name() function
    string public _name = "Manual Token";
    // They r the same, but there's some gas tradeoffs

    constructor() {
        s_totalSupply = 1000 ether;
        s_balances[msg.sender] = s_totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return "MT";
    }

    function totalSupply() public view returns (uint256) {
        return s_totalSupply;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    // eips.ethereum.org version
    // function transfer(address _to, uint256 _value) public returns (bool success) {}

    // Patrick version
    function transfer(address _to, uint256 _amount) public {
        if (balanceOf(msg.sender) < _amount) {
            revert ManualToken__TransferInsufficientBalance();
        }
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= _amount; // Subtract amount from sender
        s_balances[_to] += _amount; // Add amount to recipient
        require(balanceOf(msg.sender) + balanceOf(_to) == previousBalances, "Transfer failed");
        emit Transfer(msg.sender, _to, _amount);
    }

    // We could just keep adding one by one function according to the ERC20 token standard
    // But a much easier way is to use oppenzeppelin's ERC20.sol contract which has been audited, tested and ready to go

    function transferFrom(address _from, address _to, uint256 _value) public {
        if (_value > allowance(_from, msg.sender)) {
            revert ManualToken__TransferFromInsufficientAllowance();
        }
        uint256 previousBalances = balanceOf(_from) + balanceOf(_to);
        s_balances[_from] -= _value;
        s_balances[_to] += _value;
        require(balanceOf(_from) + balanceOf(_to) == previousBalances, "Transfer failed");
        updateAllowances(_from, msg.sender, _value);
        emit Transfer(_from, _to, _value);
    }

    function updateAllowances(address _owner, address _spender, uint256 _value) internal {
        s_allowaneces[_owner][_spender] -= _value;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        s_allowaneces[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return s_allowaneces[_owner][_spender];
    }

    function burn(address to, uint256 _value) public {
        if (to != address(0)) {
            revert ManualToken__WrongBurnAddress();
        }
        if (balanceOf(msg.sender) < _value) {
            revert ManualToken__BurnInsufficientBalance();
        }
        s_balances[msg.sender] -= _value;
        s_totalSupply -= _value;
    }

    function mint(address account, uint256 amount) public {
        s_totalSupply += amount;
        s_balances[account] += amount;
    }
}
