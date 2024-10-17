//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ManualToken {

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "ManualToken";
    }

    function symbol() public pure returns (string memory) {
        return "MTK";
    }

    function decimals() public pure returns (uint256) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        // Prevent transfers to the zero address
        require(_to != address(0), "Transfer to the zero address");
    
        uint256 balanceFrom = s_balances[msg.sender];
        // Use require instead of if for better error handling
        require(balanceFrom >= _value, "Insufficient balance");
        
        // Use unchecked for gas optimization (Solidity 0.8.0 and above)
        unchecked {
            s_balances[msg.sender] = balanceFrom - _value;
            s_balances[_to] += _value;
        }
        
        // Emit a Transfer event (not shown in original code)
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

    
}
