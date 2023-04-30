//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

interface IXen {
    struct MintInfo {
        address user;
        uint256 term;
        uint256 maturityTs;
        uint256 rank;
        uint256 amplifier;
        uint256 eaaRate;
    }

    function claimRank(uint256 term) external;

    function claimMintRewardAndShare(address other, uint256 pct) external;

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function userMints(address user) external view returns (MintInfo memory);
}

interface IXenBoxImpl {
    function rank(uint256 term) external;

    function rankAndReward(uint256 term) external;

    function delegatecall(address impl, bytes memory data) external payable;

    function call(address _contract, bytes memory data) external payable;
}

contract XenBoxImpl is IXenBoxImpl {
    address public constant xenAddress = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;

    address immutable _proxyAddress = msg.sender;

    function rankAndReward(uint256 term) external {
        require(msg.sender == _proxyAddress);
        IXen xen = IXen(xenAddress);
        xen.claimMintRewardAndShare(_proxyAddress, 100);
        xen.claimRank(term);
    }

    function rank(uint256 term) external {
        require(msg.sender == _proxyAddress);
        IXen(xenAddress).claimRank(term);
    }

    function delegatecall(address impl, bytes memory data) external payable {
        require(msg.sender == _proxyAddress);
        impl.delegatecall(data);
    }

    function call(address _contract, bytes memory data) external payable {
        require(msg.sender == _proxyAddress);
        _contract.call{value: msg.value}(data);
    }

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRAN FUNCTIONS ================ */

    /* ================ ADMIN FUNCTIONS ================ */
}
