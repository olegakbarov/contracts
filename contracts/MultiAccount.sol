// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";

contract MultiAccount {
    mapping(address => uint) private _remainingWithdrawAmount;
    mapping(address => uint) private _addressShare;

    // ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",  "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"], [50, 30, 20]
    // 10000000 = 10'000'000 gwei
    constructor(address[] memory owners, uint[] memory shares)  {
        require(owners.length == shares.length, "Input length mismatch");

        uint len = owners.length;
        uint i = 0;

        for (i = 0; i < len; i++) {
            _remainingWithdrawAmount[owners[i]] = 0;
            _addressShare[owners[i]] = shares[i];
        }
    }

    function showWithdrawnAmount(address x) public view returns (uint) {
        return _remainingWithdrawAmount[x];
    }

    function showMyWithdrawLimit() public view returns (uint) {
        return (address(this).balance * _addressShare[msg.sender] / 100) - _remainingWithdrawAmount[msg.sender];
    }

    function withdraw(uint amount) public payable {
        require (amount <= address(this).balance, "Requested amount is more than treasury size");
        require(amount <= ((address(this).balance * _addressShare[msg.sender] / 100) - _remainingWithdrawAmount[msg.sender]), "Requested amount exceeds withdraw limit");
            
        _remainingWithdrawAmount[msg.sender] = (address(this).balance * _addressShare[msg.sender] / 100) - amount;
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}