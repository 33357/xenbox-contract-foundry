//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IProxy {
    function rank(uint256 term) external;

    function rankAndReward(uint256 term) external;
}

interface IXen {
    function claimRank(uint256 term) external;

    function claimMintRewardAndShare(address other, uint256 pct) external;

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract XenBoxUpgradeable is ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    struct Token {
        uint48 start;
        uint48 end;
        address refer;
    }

    bytes32 public immutable codehash =
        keccak256(
            abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                address(this),
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            )
        );

    address immutable _thisAddress = address(this);

    address constant _xen = 0x06450dEe7FD2Fb8E39061434BAbCFC05599a6Fb8;

    uint256 public totalProxy;

    uint256 public totalToken;

    uint256 public totalFee;

    uint256 public fee = 500;

    uint256 public referFee = 100;

    string public baseURI = "https://xenbox.store/api/token/";

    mapping(uint256 => Token) public tokenMap;

    mapping(address => uint256) public rewardMap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() external initializer {
        __UUPSUpgradeable_init();
        __Ownable_init();
        __ERC721_init_unchained("xenbox.store", "XenBox2");
    }

    /* ================ UTIL FUNCTIONS ================ */

    function _authorizeUpgrade(address) internal view override onlyOwner {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _batchCreate(uint256 start, uint256 end, uint256 term) internal {
        bytes memory code = abi.encodePacked(
            bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
            address(this),
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
        for (uint256 i = start; i < end; i++) {
            IProxy proxy;
            assembly {
                proxy := create2(0, add(code, 32), mload(code), i)
            }
            proxy.rank(term);
        }
    }

    function _batchRankAndReward(uint256 start, uint256 end, uint256 term) internal {
        for (uint256 i = start; i < end; i++) {
            IProxy(address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), i, codehash))))))
                .rankAndReward(term);
        }
    }

    function rankAndReward(uint256 term) external {
        require(msg.sender == _thisAddress);
        IXen(_xen).claimMintRewardAndShare(_thisAddress, 100);
        IXen(_xen).claimRank(term);
    }

    function rank(uint256 term) external {
        require(msg.sender == _thisAddress);
        IXen(_xen).claimRank(term);
    }

    /* ================ VIEW FUNCTIONS ================ */

    function version() public pure returns (string memory) {
        return "1.0.0";
    }

    /* ================ TRAN FUNCTIONS ================ */

    function mint(uint256 amount, uint256 term, address refer) external {
        require(amount == 100 || amount == 50 || amount == 20 || amount == 10, "error amount");
        uint256 end = totalProxy + amount;
        _batchCreate(totalProxy, end, term);
        _mint(msg.sender, totalToken);
        tokenMap[totalToken] = Token({start: uint48(totalProxy), end: uint48(end), refer: refer});
        totalProxy += amount;
        totalToken++;
    }

    function claim(uint256 tokenId, uint256 term) external {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        IXen xen = IXen(_xen);
        uint256 beforeBalance = xen.balanceOf(address(this));
        _batchRankAndReward(tokenMap[tokenId].start, tokenMap[tokenId].end, term);
        uint256 getBalance = xen.balanceOf(address(this)) - beforeBalance;
        uint256 getAmount = (getBalance * (10000 - fee)) / 10000;
        address refer = tokenMap[tokenId].refer;
        uint256 rewardAmount;
        if (refer != address(0) && balanceOf(refer) != 0 && refer != msg.sender) {
            rewardAmount = (getBalance * referFee) / 10000;
            rewardMap[refer] += rewardAmount;
        }
        totalFee += getBalance - getAmount - rewardAmount;
        xen.transfer(msg.sender, getAmount);
    }

    function getReward() external {
        uint256 rewardAmount = rewardMap[msg.sender];
        rewardMap[msg.sender] = 0;
        IXen(_xen).transfer(msg.sender, rewardAmount);
    }

    /* ================ ADMIN FUNCTIONS ================ */

    function getFee(address to) external onlyOwner {
        IXen(_xen).transfer(to, totalFee);
        totalFee = 0;
    }

    function setFee(uint256 _fee, uint256 _referFee) external onlyOwner {
        fee = _fee;
        referFee = _referFee;
    }

    function setBaseURI(string memory __baseURI) external onlyOwner {
        baseURI = __baseURI;
    }
}
