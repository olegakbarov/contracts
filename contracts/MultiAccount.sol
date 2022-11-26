
// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract MultiAccount {

    mapping(address => uint) private _remainingWithdrawAmount;
    mapping(address => uint) private _addressShare;

    error AddressStakeMismatch();
    error InsufficientFundsForAddress();

    // ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",  "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"], [50, 30, 20]
    constructor(address[] memory owners, uint[] memory shares)  {
        uint len = owners.length;
        uint i = 0;

        if (owners.length != shares.length)  {
            revert AddressStakeMismatch();
        }

        for (i = 0; i < len; i++) {
            _remainingWithdrawAmount[owners[i]] = 0;
            _addressShare[owners[i]] = shares[i] / 100;
        }
    }

    function showBalance(address x) public view returns (uint) {
        return _remainingWithdrawAmount[x];
    }

    function withdraw(uint amount) public payable {
        if (amount > address(this).balance) {
            revert InsufficientFundsForAddress();
        }

        if (amount > (address(this).balance * _addressShare[msg.sender] - _remainingWithdrawAmount[msg.sender])) {
            revert InsufficientFundsForAddress();
        }

        _remainingWithdrawAmount[msg.sender] = _remainingWithdrawAmount[msg.sender] - amount;
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}