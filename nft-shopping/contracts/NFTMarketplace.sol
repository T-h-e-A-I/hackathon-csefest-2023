// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin libraries for access control and token management
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArtPlatform is Ownable, ERC721 {
    struct Artwork {
        string CID; //cid from ipfs
        uint256 price; //price of the artwork
        uint256 quantity; // quantity as stock in the marketplace
        bool isLimitedEdition;
        bool isAuctioned;
        uint256 auctionEndTime;
    }

    Artwork[] public artworks;
    mapping(uint256 => address[]) public certificatesOfArtwork;
    mapping(uint256 => address) public artworkOwners;
    mapping(uint256 => uint256) public artworkSupply;
    mapping(uint256 => uint256) public artworkBids;
    uint256 public artworkCounter;
    address[] public verifiers;

    event ArtworkAdded(uint256 indexed artworkId);
    event ArtworkUpdated(uint256 indexed artworkId);
    event ArtworkDeliveryStatusUpdated(uint256 indexed artworkId);
    event ArtworkAuctionStarted(
        uint256 indexed artworkId,
        uint256 auctionEndTime
    );
    event ArtworkBidPlaced(
        uint256 indexed artworkId,
        address indexed bidder,
        uint256 amount
    );
    event ArtworkCertificateIssued(
        uint256 indexed artworkId,
        address indexed verifier
    );
    event NativeTokenRateUpdated(uint256 newRate);


    constructor() ERC721("ArtPlatform", "ART") {
        artworkCounter = 0;
    }

    
    // getters:

    function getArtwork(uint256 index) public view returns (Artwork memory) {
        require(index < artworks.length, "Invalid artwork index");
        return artworks[index];
    }

    function getCertificateOfArtwork(
        uint256 tokenId
    ) public view returns (address[] memory) {
        return certificatesOfArtwork[tokenId];
    }

    function getArtworkOwner(uint256 tokenId) public view returns (address) {
        return artworkOwners[tokenId];
    }

    function getArtworkSupply(uint256 tokenId) public view returns (uint256) {
        return artworkSupply[tokenId];
    }

    function getArtworkBids(uint256 tokenId) public view returns (uint256) {
        return artworkBids[tokenId];
    }

    function getArtworkCounter() public view returns (uint256) {
        return artworkCounter;
    }

    function getVerifiers() public view returns (address[] memory) {
        return verifiers;
    }


    function isVerifier(address _address) public view returns (bool) {
        // check if the address belongs to a registered verifier
        for (uint i = 0; i < verifiers.length; i++) {
            if (verifiers[i] == _address) {
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
    ) external onlyOwner returns (uint256) { //returns the artworkID

        uint256 artworkId = artworkCounter;
        artworkCounter++;

        artworks.push(
            Artwork({
                CID: _CID,
                price: _price,
                quantity: _quantity,
                isLimitedEdition: _isLimitedEdition,
                isAuctioned: _isAuctioned,
                auctionEndTime: _auctionEndTime
            })
        );
        artworkOwners[artworkId] = msg.sender;
        artworkSupply[artworkId] = _quantity;

        emit ArtworkAdded(artworkId);

        return artworkId;
    }

    function startArtworkAuction(
        uint256 _artworkId,
        uint256 _auctionEndTime
    ) external onlyArtworkOwner(_artworkId) {
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
        require(
            _amount > artworkBids[_artworkId],
            "A higher bid already exists"
        );

        artworkBids[_artworkId] = _amount;

        emit ArtworkBidPlaced(_artworkId, msg.sender, _amount);
    }

    function issueCertificate(uint256 _artworkId) external onlyVerifier {
        certificatesOfArtwork[_artworkId].push(msg.sender);

        emit ArtworkCertificateIssued(_artworkId, msg.sender);
    }
// modifiers
    
    modifier onlyArtworkOwner(uint256 _artworkId) {
        require(
            msg.sender == artworkOwners[_artworkId],
            "Only artwork owner can perform this action"
        );
        _;
    }

    modifier onlyVerifier() {
        require(
            isVerifier(msg.sender),
            "Only verifiers can perform this action"
        );
        _;
    }
}
