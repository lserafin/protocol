pragma solidity ^0.4.11;

import './ParticipationInterface.sol';
import '../dependencies/Permissioned.sol';

/// @title Participation Contract
/// @author Melonport AG <team@melonport.com>
/// @notice Simple and static Participation Module.
contract Participation is ParticipationInterface, Permissioned {

    // CONSTANT METHODS

    /// Pre: Request ID
    /// Post: Boolean dependent on market data and on personel data; Compliance
    function isSubscribeRequestPermitted(
        address owner,
        uint256 numShares,
        uint256 offeredValue
    )
        constant
        returns (bool)
    {
        return isPermitted(owner);
    }

    /// Pre: Request ID
    /// Post: Boolean whether permitted or not
    function isRedeemRequestPermitted(
        address owner,
        uint256 numShares,
        uint256 requestedValue
    )
        constant
        returns (bool)
    {
        return isPermitted(owner);
    }
}
