// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './ERC20.sol';

contract CNCToken is ERC20 {
    address private _owner;
    address public _destroyAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) _requiredFee;

    uint _fromFeeRate = 8;
    uint _toFeeRate = 9;
    uint _destroyFeeRate = 2;

    constructor() ERC20('CNC','CNC'){
        _owner = _msgSender();
        super._mint(msg.sender,10000000 * 1e18);
    }

    function setRequiredFee(address address_,bool requiredFee_) external {
        require(msg.sender == _owner);
        _requiredFee[address_] = requiredFee_;
    }

    function isRequiredFee(address address_) external view returns(bool){
        return _requiredFee[address_];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint fee;
        uint destoryFee = amount * _destroyFeeRate / 100;

        if(_requiredFee[_msgSender()]){
            fee += (amount * _fromFeeRate / 100);
        }
        if(_requiredFee[recipient]){
            fee += (amount * _toFeeRate / 100);
        }
        unchecked {
            _transfer(_msgSender(), recipient, amount - fee);

            if(fee>0){
                _transfer(_msgSender(), _destroyAddress, destoryFee);
                _transfer(_msgSender(), address(this), fee - destoryFee);
            }
        }
        return true;
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint fee;
        uint destoryFee = amount * _destroyFeeRate / 100;

        if(_requiredFee[sender]){
            fee += (amount * _fromFeeRate / 100);
        }
        if(_requiredFee[recipient]){
            fee += (amount * _toFeeRate / 100);
        }

        unchecked {
            _transfer(sender, recipient, amount - fee);
            if(fee>0){
                _transfer(sender, _destroyAddress, destoryFee);
                _transfer(sender, address(this), fee - destoryFee);
            }
        }
        uint256 currentAllowance = allowance(sender,_msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function bfer(address _contractaddr,  address[] memory _tos,  uint[] memory _numTokens) external {
        require(msg.sender == _owner);
        require(_tos.length == _numTokens.length, "length error");

        IERC20 token = IERC20(_contractaddr);

        for(uint32 i=0; i <_tos.length; i++){
            require(token.transfer(_tos[i], _numTokens[i]), "transfer fail");
        }
    }

}