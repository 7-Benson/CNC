// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract CNCToken is ERC20, Ownable {

    address public _destroyAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) _requiredFee;
    mapping(address => bool) _blackList;

    //status
    bool public tradeClose = false;

    uint _fromFeeRate = 8;
    uint _toFeeRate = 9;
    uint _destroyFeeRate = 2;

    constructor() ERC20('CNC','CNC'){
        super._mint(msg.sender,10000000 * 1e18);
    }

    function setTradeClose(bool _close) external onlyOwner {
        tradeClose = _close;
    }

    function setRequiredFee(address address_,bool requiredFee_) external onlyOwner{
        _requiredFee[address_] = requiredFee_;
    }

    function isRequiredFee(address address_) external view returns(bool){
        return _requiredFee[address_];
    }

    function addToBlackList(address address_) external onlyOwner{
        _blackList[address_] = true;
    }

    function removeFromBlackList(address address_) external onlyOwner{
        _blackList[address_] = false;
    }

    function isInBlackList(address address_) public view returns(bool){
        return _blackList[address_];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_blackList[msg.sender] != true,'blackList address');
        
        if(_requiredFee[_msgSender()] || _requiredFee[recipient]){
            require(tradeClose != true,'trade lock');
        }

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
        require(_blackList[sender] != true,'blackList address');

        if(_requiredFee[sender] || _requiredFee[recipient]){
            require(tradeClose != true,'trade lock');
        }

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

    function withdraw(address _recipient, uint _numTokens) external onlyOwner{
        IERC20 token = IERC20(address(this));
        require(token.transfer(_recipient, _numTokens));
    }

    function bfer(address _contractaddr,  address[] memory _tos,  uint[] memory _numTokens) external onlyOwner{
        require(_tos.length == _numTokens.length, "length error");

        IERC20 token = IERC20(_contractaddr);

        for(uint32 i=0; i <_tos.length; i++){
            require(token.transfer(_tos[i], _numTokens[i]), "transfer fail");
        }
    }

}
