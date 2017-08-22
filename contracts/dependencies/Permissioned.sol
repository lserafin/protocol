pragma solidity ^0.4.11;

import './DBC.sol';
import './Owned.sol';

// only Owner is able to give and revoke permissions
contract Permissioned is DBC, Owned {

    // FIELDS

    mapping (address => bool) public permitted;

    // CONSTANT METHODS

    function isPermitted(address query) constant returns (bool) {
        return permitted[query];
    }

    function senderPermitted() constant returns (bool) {
        return isPermitted(msg.sender);
    }

    // NON-CONSTANT METHODS

    function addPermission(address entry) pre_cond(isOwner()) {
        permitted[entry] = true;
    }

    function addManyPermissions(address[] entries) pre_cond(isOwner()) {
        for (uint i = 0; i < entries.length; ++i) {
            permitted[entries[i]] = true;
        }
    }

    function removePermission(address entry) pre_cond(isOwner()) {
        permitted[entry] = false;
    }

    function removeManyPermissions(address[] entries) pre_cond(isOwner()) {
        for (uint i = 0; i < entries.length; ++i) {
            permitted[entries[i]] = false;
        }
    }
}
