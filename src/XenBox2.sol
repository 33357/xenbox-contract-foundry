//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

contract XenBox2 is ERC721, Ownable {
    event Minted(address indexed sender, uint256 indexed tokenId, address indexed refer);

    event Claimed(address indexed sender, uint256 indexed tokenId, uint256 getAmount);

    event Reward(uint256 indexed tokenId, address indexed refer, uint256 rewardAmount);

    struct Token {
        uint48 start;
        uint48 end;
        address refer;
    }

    uint256 public totalProxy;

    uint256 public totalToken;

    uint256 public totalFee;

    uint256 public fee100 = 500;

    uint256 public fee50 = 600;

    uint256 public fee20 = 700;

    uint256 public fee10 = 800;

    uint256 public referFeePercent = 20;

    string public baseURI = "https://xenbox.store/api/token/";

    mapping(uint256 => Token) public tokenMap;

    mapping(address => bool) public isRefer;

    mapping(address => uint256) public rewardMap;

    address public constant xenAddress = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;

    address immutable _thisAddress = address(this);

    bytes32 public immutable codehash =
        keccak256(
            abi.encodePacked(
                bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                address(this),
                bytes15(0x5af43d82803e903d91602b57fd5bf3)
            )
        );

    constructor() ERC721("xenbox.store", "XenBox2") {}

    /* ================ UTIL FUNCTIONS ================ */

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
        IXen xen = IXen(xenAddress);
        xen.claimMintRewardAndShare(_thisAddress, 100);
        xen.claimRank(term);
    }

    function rank(uint256 term) external {
        require(msg.sender == _thisAddress);
        IXen(xenAddress).claimRank(term);
    }

    /* ================ VIEW FUNCTIONS ================ */

    /* ================ TRAN FUNCTIONS ================ */

    function mint(uint256 amount, uint256 term, address refer) external {
        require(amount == 100 || amount == 50 || amount == 20 || amount == 10, "error amount");
        uint256 end = totalProxy + amount;
        _batchCreate(totalProxy, end, term);
        _mint(msg.sender, totalToken);
        tokenMap[totalToken] = Token({start: uint48(totalProxy), end: uint48(end), refer: refer});
        totalProxy += amount;
        emit Minted(msg.sender, totalToken, refer);
        totalToken++;
        if (!isRefer[msg.sender] && amount == 100) {
            isRefer[msg.sender] = true;
        }
    }

    function claim(uint256 tokenId, uint256 term) external {
        require(ownerOf(tokenId) == msg.sender, "not owner");
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
            emit Reward(tokenId, refer, rewardAmount);
        }
        uint256 getAmount = getBalance - fee;
        totalFee += fee - rewardAmount;
        xen.transfer(msg.sender, getAmount);
        emit Claimed(msg.sender, tokenId, getAmount);
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

    function transfer(address token, address to, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            payable(to).transfer(amount);
        } else {
            IXen(token).transfer(to, amount);
        }
    }
}
