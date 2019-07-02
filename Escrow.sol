pragma solidity 0.5.9;
library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Escrow {
    using SafeMath for uint256;
    
    event Deposited(address indexed payee, uint256 weiAmount);
    event Release(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;
    mapping(address => address) private _sender;
    mapping(address => bool) private _verify;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    function verifyOf(address payee) public view returns (bool) {
        return _verify[payee];
    }

    function deposit(address payee) public payable {
        uint256 amount = msg.value;
        _deposits[payee] = _deposits[payee].add(amount);
        _sender[payee] = msg.sender;
        _verify[payee] = false;
        emit Deposited(payee, amount);
    }
    
    function verify(address payee) public payable {
        address sender = _sender[payee];
        require(msg.sender == sender, "Warning! Address sender deposit is not address msg.sender");
        _verify[payee] = true;
    }

    function release(address payable payee) public {
        bool status = _verify[payee];
        require(status == true, "Warning! Status Verify is false");
        require(msg.sender == payee, "Warning! Address payee is not address msg.sender");
        uint256 amount = _deposits[payee];
        _deposits[payee] = 0;
        payee.transfer(amount);
        emit Release(payee, amount);
    }
}