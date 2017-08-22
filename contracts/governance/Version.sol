pragma solidity ^0.4.11;

import '../Vault.sol';
import '../VaultInterface.sol';
import '../dependencies/DBC.sol';
import '../dependencies/Owned.sol';
import '../dependencies/Logger.sol';

/// @title Version Contract
/// @author Melonport AG <team@melonport.com>
/// @notice Simple and static Management Fee.
contract Version is DBC, Owned {

    // TYPES

    enum Status {
        setup,
        funding,
        trading,
        payout
    }

    // FIELDS

    // Fields that are only changed in constructor
    address public MELON_ASSET; // Adresss of Melon asset contract
    address public ASSET_REGISTRAR; // Address of Asset Registrar contract
    address public GOVERNANCE; // Address of Melon protocol governance contract
    address public LOGGER;
    Logger logger;
    // Fields that can be changed by functions
    mapping (uint => address) public vaults; // Links identifier to vault addresses
    uint public lastVaultId;

    // EVENTS

    event VaultUpdated(uint id);

    // PRE, POST, INVARIANT CONDITIONS

    function isVaultOwner(uint256 id) internal returns (bool) {
        return msg.sender == Vault(vaults[id]).owner(); // TODO using VaultInterface
    }

    // CONSTANT METHODS

    function getMelonAsset() constant returns (address) { return MELON_ASSET; }
    function getLastVaultId() constant returns (uint) { return lastVaultId; }
    function getVault(uint id) constant returns (address) { return vaults[id]; }

    // NON-CONSTANT INTERNAL METHODS

    function next_id() internal returns (uint) {
        lastVaultId++; return lastVaultId;
    }

    // NON-CONSTANT METHODS

    function Version(
        address ofMelonAsset,
        address ofAssetRegistrar,
        address ofLogger
    ) {
        GOVERNANCE = msg.sender; //TODO fix (not set as msg.sender by default!)
        MELON_ASSET = ofMelonAsset;
        ASSET_REGISTRAR = ofAssetRegistrar;
        LOGGER = ofLogger;
        logger = Logger(LOGGER);
    }

    function setupVault(
        string withName,
        string withSymbol,
        uint withDecimals,
        address ofUniverse,
        address ofParticipation,
        address ofRiskMgmt,
        address ofRewards
    )
        returns (uint id)
    {
        address vault = address(new Vault( // TODO using VaultInterface
            msg.sender,
            withName,
            withSymbol,
            withDecimals,
            ASSET_REGISTRAR,
            MELON_ASSET,
            ofUniverse,
            ofParticipation,
            ofRiskMgmt,
            ofRewards,
            LOGGER
        ));
        id = next_id();
        vaults[id] = vault;
        logger.addPermission(vault);
    }

    // Dereference Vault and trigger selfdestruct
    function decommissionVault(uint id)
        pre_cond(isVaultOwner(id) || isOwner())
    {
        // TODO also refund and selfdestruct vault contract
        delete vaults[id];
        VaultUpdated(id);
    }
}
