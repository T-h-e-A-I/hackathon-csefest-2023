// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArtworkMarketplace {
    struct Artwork {
        uint256 tokenId; // Unique identifier for the artwork
        string description; // Description of the artwork
        string image; // Image URL or IPFS hash of the artwork
        uint256 price; // Price of the artwork
        string artistCredentials; // Credentials or information about the artist
        address seller; // Address of the seller
        bool isVerified; // Flag indicating if the artwork is verified
    }
    
    mapping(uint256 => Artwork) public artworks; // Mapping to store the artworks
    uint256 public totalArtworks; // Counter for the total number of artworks
    
    event ArtworkListed(uint256 indexed tokenId, address indexed seller, uint256 price); // Event emitted when an artwork is listed
    event ArtworkSold(uint256 indexed tokenId, address indexed buyer, uint256 price); // Event emitted when an artwork is sold
    event ArtworkVerified(uint256 indexed tokenId, bool isVerified); // Event emitted when an artwork is verified
    
    modifier onlySeller(uint256 tokenId) {
        require(msg.sender == artworks[tokenId].seller, "Only the seller can perform this action");
        _;
    }
    
    modifier onlyBuyer(uint256 tokenId) {
        require(msg.sender != artworks[tokenId].seller, "Only the buyer can perform this action");
        _;
    }
    
    /**
     * @dev Function to list an artwork for sale
     * @param _description Description of the artwork
     * @param _image Image URL or IPFS hash of the artwork
     * @param _price Price of the artwork
     * @param _artistCredentials Credentials or information about the artist
     */
    function listArtwork(
        string memory _description,
        string memory _image,
        uint256 _price,
        string memory _artistCredentials
    ) public {
        totalArtworks++;
        
        Artwork memory newArtwork = Artwork(
            totalArtworks,
            _description,
            _image,
            _price,
            _artistCredentials,
            msg.sender,
            false
        );
        
        artworks[totalArtworks] = newArtwork;
        
        emit ArtworkListed(totalArtworks, msg.sender, _price);
    }
    
    /**
     * @dev Function to buy an artwork
     * @param tokenId Unique identifier of the artwork
     */
    function buyArtwork(uint256 tokenId) public payable onlyBuyer(tokenId) {
        Artwork storage artwork = artworks[tokenId];
        
        require(artwork.price == msg.value, "Incorrect payment amount");
        require(!artwork.isVerified, "Artwork is already verified");
        
        address payable seller = payable(artwork.seller);
        seller.transfer(msg.value);
        
        artwork.isVerified = true;
        
        emit ArtworkSold(tokenId, msg.sender, msg.value);
        emit ArtworkVerified(tokenId, true);
    }
    
    /**
     * @dev Function to verify an artwork
     * @param tokenId Unique identifier of the artwork
     */
    function verifyArtwork(uint256 tokenId) public onlySeller(tokenId) {
        Artwork storage artwork = artworks[tokenId];
        
        require(!artwork.isVerified, "Artwork is already verified");
        
        artwork.isVerified = true;
        
        emit ArtworkVerified(tokenId, true);
    }
}
