//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./XenBoxImpl.sol";

contract XenBoxUpgradeable is ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    event Minted(address indexed sender, address indexed refer, uint256 indexed tokenId);

    event Claimed(address indexed sender, uint256 indexed tokenId, uint256 getAmount);

    event Forced(address indexed from, address indexed to, uint256 indexed tokenId);

    event Reward(address indexed refer, uint256 indexed tokenId, uint256 rewardAmount);

    struct Token {
        uint48 start;
        uint48 end;
        address refer;
    }

    uint256 public totalProxy;

    uint256 public totalToken;

    uint256 public totalFee;

    uint256 public fee100;

    uint256 public fee50;

    uint256 public fee20;

    uint256 public fee10;

    uint256 public referFeePercent;

    uint256 public forceDay;

    uint256 public forceFee;

    string public baseURI;

    address public implAddress;

    bytes32 public codehash;

    mapping(uint256 => Token) public tokenMap;

    mapping(address => bool) public isRefer;

    mapping(address => uint256) public rewardMap;

    address public constant xenAddress = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() external initializer {
        __UUPSUpgradeable_init();
        __Ownable_init();
        __ERC721_init_unchained("xenbox.store", "XenBox2");
        fee100 = 500;
        fee50 = 600;
        fee20 = 700;
        fee10 = 800;
        referFeePercent = 20;
        forceDay = 30;
        baseURI = "https://xenbox.store/api/token2/";
        implAddress = address(new XenBoxImpl{salt: 0}());
        codehash = keccak256(
            abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                implAddress,
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            )
        );
    }

    /* ================ UTIL FUNCTIONS ================ */

    function _authorizeUpgrade(address) internal view override onlyOwner {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _batchCreate(uint256 start, uint256 end, uint256 term) internal {
        bytes memory code = abi.encodePacked(
            bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
            implAddress,
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
        unchecked {
            for (uint256 i = start; i < end; ++i) {
                IXenBoxImpl implProxy;
                assembly {
                    implProxy := create2(0, add(code, 32), mload(code), i)
                }
                implProxy.rank(term);
            }
        }
    }

    function _batchRankAndReward(uint256 start, uint256 end, uint256 term) internal {
        address _implAddress = implAddress;
        bytes32 _codehash = codehash;
        unchecked {
            for (uint256 i = start; i < end; ++i) {
                IXenBoxImpl(proxyAddress(_implAddress, i, _codehash)).rankAndReward(term);
            }
        }
    }

    function _claim(uint256 tokenId, uint256 term) internal {
        IXen xen = IXen(xenAddress);
        uint256 beforeBalance = xen.balanceOf(address(this));
        _batchRankAndReward(tokenMap[tokenId].start, tokenMap[tokenId].end, term);
        uint256 getBalance = xen.balanceOf(address(this)) - beforeBalance;
        uint256 amount = tokenMap[tokenId].end - tokenMap[tokenId].start;
        uint256 fee;
        if (amount == 100) {
            fee = (getBalance * fee100) / 10000;
        } else if (amount == 50) {
            fee = (getBalance * fee50) / 10000;
        } else if (amount == 20) {
            fee = (getBalance * fee20) / 10000;
        } else if (amount == 10) {
            fee = (getBalance * fee10) / 10000;
        }
        address refer = tokenMap[tokenId].refer;
        uint256 rewardAmount;
        if (isRefer[refer] && refer != msg.sender) {
            rewardAmount = (fee * referFeePercent) / 100;
            rewardMap[refer] += rewardAmount;
            emit Reward(refer, tokenId, rewardAmount);
        }
        uint256 getAmount = getBalance - fee;
        totalFee += fee - rewardAmount;
        xen.transfer(msg.sender, getAmount);
        emit Claimed(msg.sender, tokenId, getAmount);
    }

    /* ================ VIEW FUNCTIONS ================ */

    function version() public pure returns (string memory) {
        return "1.0.0";
    }

    function proxyAddress(address impl, uint256 index, bytes32 _codehash) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), impl, index, _codehash)))));
    }

    function userMints(uint256 tokenId) public view returns (IXen.MintInfo memory) {
        return IXen(xenAddress).userMints(proxyAddress(implAddress, tokenMap[tokenId].start, codehash));
    }

    /* ================ TRAN FUNCTIONS ================ */

    function mint(uint256 amount, uint256 term, address refer) external {
        require(amount == 100 || amount == 50 || amount == 20 || amount == 10, "error amount");
        uint256 end = totalProxy + amount;
        _batchCreate(totalProxy, end, term);
        _mint(msg.sender, totalToken);
        tokenMap[totalToken] = Token({start: uint48(totalProxy), end: uint48(end), refer: refer});
        totalProxy += amount;
        emit Minted(msg.sender, refer, totalToken);
        totalToken++;
        if (!isRefer[msg.sender] && amount == 100) {
            isRefer[msg.sender] = true;
        }
    }

    function claim(uint256 tokenId, uint256 term) public {
        require(ownerOf(tokenId) == msg.sender, "not owner");
        _claim(tokenId, term);
    }

    function force(uint256 tokenId, uint256 term) external payable {
        require(block.timestamp > userMints(tokenId).maturityTs + 60 * 60 * 24 * forceDay, "not time");
        require(msg.value == forceFee * (tokenMap[tokenId].end - tokenMap[tokenId].start), "error fee");
        _claim(tokenId, term);
        address oldOwner = ownerOf(tokenId);
        _transfer(oldOwner, msg.sender, tokenId);
        emit Forced(oldOwner, msg.sender, tokenId);
    }

    function batchClaim(uint256[] memory tokenIdList, uint256 term) external {
        for (uint256 i = 0; i < tokenIdList.length; i++) {
            claim(tokenIdList[i], term);
        }
    }

    function getReward() external {
        uint256 rewardAmount = rewardMap[msg.sender];
        rewardMap[msg.sender] = 0;
        IXen(xenAddress).transfer(msg.sender, rewardAmount);
    }

    /* ================ ADMIN FUNCTIONS ================ */

    function getFee(address to) external onlyOwner {
        IXen(xenAddress).transfer(to, totalFee);
        totalFee = 0;
    }

    function getForceFee(address to) external onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function setFee(uint256 _fee100, uint256 _fee50, uint256 _fee20, uint256 _fee10) external onlyOwner {
        fee100 = _fee100;
        fee50 = _fee50;
        fee20 = _fee20;
        fee10 = _fee10;
    }

    function setReferFeePercent(uint256 _referFeePercent) external onlyOwner {
        referFeePercent = _referFeePercent;
    }

    function setBaseURI(string memory __baseURI) external onlyOwner {
        baseURI = __baseURI;
    }

    function setForceDay(uint256 _forceDay) external onlyOwner {
        forceDay = _forceDay;
    }

    function setForceFee(uint256 _forceFee) external onlyOwner {
        forceFee = _forceFee;
    }
}
