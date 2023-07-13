// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin libraries for access control and token management
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArtPlatform is Ownable, ERC721 {
    struct Artwork {
        string CID;
        uint256 price;
        uint256 quantity;
        bool isLimitedEdition;
        bool isAuctioned;
        uint256 auctionEndTime;
    }
    struct Certificates{
        string provider;
        address providerAddress;
    }
    Artwork[] public artworks;
    mapping (string => Certificates) public CertificatesOfArtwork;
    mapping(uint256 => address) public artworkOwners;
    mapping(uint256 => uint256) public artworkSupply;
    mapping(uint256 => uint256) public artworkBids;
    address[] public verifiers;
    // uint256 public nativeTokenRate;
    // IERC20 public nativeToken;

    event ArtworkAdded(uint256 indexed artworkId);
    event ArtworkUpdated(uint256 indexed artworkId);
    event ArtworkDeliveryStatusUpdated(uint256 indexed artworkId);
    event ArtworkAuctionStarted(uint256 indexed artworkId, uint256 auctionEndTime);
    event ArtworkBidPlaced(uint256 indexed artworkId, address indexed bidder, uint256 amount);
    event ArtworkCertificateIssued(uint256 indexed artworkId, address indexed verifier);
    event NativeTokenRateUpdated(uint256 newRate);

    constructor() ERC721("ArtPlatform", "ART") {
        // nativeToken = IERC20(_nativeTokenAddress);
        // nativeTokenRate = 1; // Default rate, can be updated by the owner
        
    }

    modifier onlyArtworkOwner(uint256 _artworkId) {
        require(msg.sender == artworkOwners[_artworkId], "Only artwork owner can perform this action");
        _;
    }

    modifier onlyVerifier() {
        require(isVerifier(msg.sender), "Only verifiers can perform this action");
        _;
    }

    function isVerifier(address _address) public view returns (bool) {
        // Add your verification logic here
        // e.g., check if the address belongs to a registered verifier
        for(uint i = 0; i<verifiers.length;i++){
            if(verifiers[i]== _address){
                return true;
            }
        }
        return false;
    }

    function registerVerifier() external {
        // Registration logic for verifiers
        // Add your implementation here
        require(!isVerifier(msg.sender), "Already a verifier");
        verifiers.push(msg.sender);
    }

    function addArtwork(
        string memory _CID,
        uint256 _price,
        uint256 _quantity,
        bool _isLimitedEdition,
        bool _isAuctioned,
        uint256 _auctionEndTime
    ) external onlyOwner {
        uint256 artworkId = artworks.length;
        artworks.push(Artwork({
            CID: _CID,
            price: _price,
            quantity: _quantity,
            isLimitedEdition: _isLimitedEdition,
            isAuctioned: _isAuctioned,
            auctionEndTime: _auctionEndTime
        }));
        artworkOwners[artworkId] = msg.sender;
        artworkSupply[artworkId] = _quantity;

        emit ArtworkAdded(artworkId);
    }

    

    function startArtworkAuction(uint256 _artworkId, uint256 _auctionEndTime) external onlyArtworkOwner(_artworkId) {
        Artwork storage artwork = artworks[_artworkId];
        require(!artwork.isAuctioned, "Artwork is already auctioned");

        artwork.isAuctioned = true;
        artwork.auctionEndTime = _auctionEndTime;

        emit ArtworkAuctionStarted(_artworkId, _auctionEndTime);
    }

    function placeBid(uint256 _artworkId, uint256 _amount) external {
        Artwork storage artwork = artworks[_artworkId];

        require(artwork.isAuctioned, "Artwork is not available for auction");
        require(block.timestamp < artwork.auctionEndTime, "Auction has ended");
        require(_amount > artworkBids[_artworkId], "A higher bid already exists");
        
        artworkBids[_artworkId] = _amount;

        emit ArtworkBidPlaced(_artworkId, msg.sender, _amount);
    }

    function issueCertificate(uint256 _artworkId) external onlyVerifier {
        
        

        // artworkCertified[_artworkId] = true;

        // emit ArtworkCertificateIssued(_artworkId, msg.sender);
    }

    // function setNativeTokenRate(uint256 _rate) external onlyOwner {
    //     nativeTokenRate = _rate;

    //     emit NativeTokenRateUpdated(_rate);
    // }

}
