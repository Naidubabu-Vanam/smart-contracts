pragma solidity ^0.6.4;

contract ExampleContract01 {
    uint256 counter = 5;

    function add() public {
        counter++;
    }

    function subtract() public {
        counter--;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }
}
