// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../src/XenBoxHelper.sol";

interface Ix {
    function x() external view returns (address);
}

contract x {
    address public x;
}

contract XenBoxHelperTest is Test {
    address _x;

    function setUp() public {
        _x = address(new x());
    }

    function test1() public view {
        Ix x= Ix(_x);
        for (uint256 i = 0; i < 2; i++) {
            x.x();
        }
    }

    function test2() public view {
        for (uint256 i = 0; i < 2; i++) {
            Ix(_x).x();
        }
    }
}
