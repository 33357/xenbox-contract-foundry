// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.17;

// import "forge-std/Test.sol";

// import "../src/XenBoxHelper.sol";

// contract XenBoxHelperTest is Test {
//     XenBoxHelper t;

//     function setUp() public {
//         t = new XenBoxHelper();
//     }

//     // function testGetOwnedTokenIdList() public {
//     //     uint256[] memory tokenIdList = t.getOwnedTokenIdList(
//     //         0x23b4F4B4Fd084847ff824573c0BAC145062608C0,
//     //         0x28C5a66E3682c5c52BC2D11FEF3034b7CB73DA8B,
//     //         0,
//     //         20
//     //     );
//     //     console.log(tokenIdList.length);
//     // }

//     function testPenalty() public view {
//         console.log(t._penalty(1*60*60*24));
//         console.log(t._penalty(2*60*60*24));
//         console.log(t._penalty(3*60*60*24));
//         console.log(t._penalty(4*60*60*24));
//         console.log(t._penalty(5*60*60*24));
//         console.log(t._penalty(6*60*60*24));
//         console.log(t._penalty(7*60*60*24));
//     }
// }
