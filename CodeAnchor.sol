// SPDX-License-Identifier: MIT
// PATCHED v0.1.44 CodeAnchor.sol — Simple anchoring contract

pragma solidity ^0.8.0;

/// @title CodeAnchor
/// @notice Stores anchored commit hashes on-chain
contract CodeAnchor {
    /// @notice Contract owner address
    address public owner;

    /// @notice Mapping of keys to anchored hashes
    mapping(string => bytes32) public anchoredHashes;

    /// @notice Emitted when a hash is anchored
    /// @param key The reference key
    /// @param hashValue The bytes32 hash associated with the key
    event AnchorSet(string indexed key, bytes32 hashValue);

    /// @notice Initializes owner to deployer
    constructor() {
        owner = msg.sender;
    }

    /// @dev Restricts function access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Anchor a hash value for a given key
    /// @param key Identifier for the anchored hash
    /// @param hashValue The bytes32 hash to store
    function anchor(string memory key, bytes32 hashValue) external onlyOwner {
        anchoredHashes[key] = hashValue;
        emit AnchorSet(key, hashValue);
    }

    /// @notice Retrieve anchored hash for a key
    /// @param key Identifier for the anchored hash
    /// @return bytes32 The stored hash value
    function getHash(string memory key) external view returns (bytes32) {
        return anchoredHashes[key];
    }
}
