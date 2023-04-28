// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../src/XenBoxHelper.sol";

contract XenBoxHelperTest is Test {
    bytes32 immutable codehash1 =
        keccak256(
            abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                address(this),
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            )
        );

    bytes32 public codehash2 =
        keccak256(
            abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                address(this),
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            )
        );

    function setUp() public {}

    function test1() public view {
        bytes32 _codehash = keccak256(
            abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                address(this),
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            )
        );
        for (uint256 i = 0; i < 100; i++) {
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), i, _codehash)))));
        }
    }

    function test2() public view {
        for (uint256 i = 0; i < 100; i++) {
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), i, codehash1)))));
        }
    }

    function test3() public view {
        for (uint256 i = 0; i < 100; i++) {
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), i, codehash2)))));
        }
    }
}
