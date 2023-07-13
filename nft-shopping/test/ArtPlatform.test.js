const { expect, BigNumber } = require("chai");

// Import the necessary ArtPlatform contract artifacts
const { ethers } = require("hardhat");

describe("ArtPlatform", function () {
  let artPlatform;
  let owner;
  let verifier;
  let addr1;
  let addr2;
  let addr3;

  beforeEach(async function () {
    // Deploy the ArtPlatform contract
    const ArtPlatform = await ethers.getContractFactory("ArtPlatform");
    artPlatform = await ArtPlatform.deploy();
    await artPlatform.deployed();

    // Get the accounts
    [owner, verifier, addr1, addr2, addr3] = await ethers.getSigners();
  });

  it("should register a verifier", async function () {
    // Register a verifier
    await artPlatform.connect(verifier).registerVerifier();

    // Check if the verifier is registered
    const isVerifier = await artPlatform.isVerifier(verifier.address);
    expect(isVerifier).to.be.true;
  });

  it("should add an artwork and start an auction", async function () {
    // Add an artwork
    await artPlatform.addArtwork("CID1", 100, 10, false, false, 0);

    // Start an auction for the artwork
    const artworkId = 0;
    const auctionEndTime = Math.floor(Date.now() / 1000) + 3600; // Auction ends in 1 hour
    await artPlatform.connect(owner).startArtworkAuction(artworkId, auctionEndTime);

    // Get the artwork
    const artwork = await artPlatform.getArtwork(artworkId);
    expect(artwork.isAuctioned).to.be.true;
    expect(artwork.auctionEndTime).to.equal(BigNumber.from(auctionEndTime));
  });

  it("should place a bid on an artwork", async function () {
    // Add an artwork
    await artPlatform.addArtwork("CID1", 100, 10, false, true, Math.floor(Date.now() / 1000) + 3600);

    // Place a bid on the artwork
    const artworkId = 0;
    const bidAmount = 200;
    await artPlatform.connect(addr1).placeBid(artworkId, bidAmount);

    // Get the artwork bid
    const artworkBid = await artPlatform.getArtworkBids(artworkId);
    expect(artworkBid).to.equal(BigNumber.from(bidAmount));
  });

  it("should issue a certificate for an artwork", async function () {
    // Add an artwork
    await artPlatform.addArtwork("CID1", 100, 10, false, false, 0);

    // Register a verifier
    await artPlatform.connect(verifier).registerVerifier();

    // Issue a certificate for the artwork
    const artworkId = 0;
    await artPlatform.connect(verifier).issueCertificate(artworkId);

    // Get the certificate of the artwork
    const certificates = await artPlatform.getCertificateOfArtwork(artworkId);
    expect(certificates).to.have.lengthOf(1);
    expect(certificates[0]).to.equal(verifier.address);
  });
});
