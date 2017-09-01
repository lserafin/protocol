pragma solidity ^0.4.11;

import './safeMath.sol';
import '../dependencies/ERC20.sol';
import '../datafeeds/DataFeedInterface.sol';

library calculate {
    using safeMath for uint;

    // CONSTANT METHODS - ACCOUNTING

    /// Pre: Non-zero share supply; value denominated in [base unit of melonAsset]
    /// Post: Share price denominated in [base unit of melonAsset * base unit of share / base unit of share] == [base unit of melonAsset]
    function valuePerShare(uint value, uint mlnBaseUnits, uint totalSupply)
        constant
        returns (uint)
    {
        require(totalSupply > 0);
        return value.mul(mlnBaseUnits).div(totalSupply);
    }

    /// Pre: baseUnitsPerShare not zero
    /// Post: priceInRef denominated in [base unit of melonAsset]
    function priceForNumBaseShares(
        uint numBaseShares,
        uint baseUnitsPerShare,
        uint value,
        uint totalSupply
    )
        constant
        returns (uint sharePrice)
    {
        if (totalSupply > 0)
            sharePrice = value.mul(baseUnitsPerShare).div(totalSupply);
        else
            sharePrice = baseUnitsPerShare;
        return numBaseShares.mul(sharePrice).div(baseUnitsPerShare);
    }

    /// Pre: Gross asset value and sum of all applicable and unclaimed fees has been calculated
    /// Post: Net asset value denominated in [base unit of melonAsset]
    function netAssetValue(
        uint gav,
        uint rewardsUnclaimed
    )
        constant
        returns (uint)
    {
        return gav.sub(rewardsUnclaimed);
    }

    //  when timeDifference == 0, return 0
    /// Post: Reward denominated in referenceAsset
    function managementReward(
        uint managementRewardRate,
        uint timeDifference,
        uint gav,
        uint divisorFee
    )
        constant
        returns (uint)
    {
        uint absoluteChange = timeDifference * gav;
        return absoluteChange * managementRewardRate / divisorFee;
    }

    //  when timeDifference == 0, return 0
    /// Post: Reward denominated in referenceAsset
    function performanceReward(
        uint performanceRewardRate,
        int deltaPrice, // Price Difference measured agains referenceAsset
        uint totalSupply,
        uint divisorFee
    )
        constant
        returns (uint)
    {
        if (deltaPrice <= 0) return 0;
        uint absoluteChange = uint(deltaPrice) * totalSupply;
        return absoluteChange * performanceRewardRate / divisorFee;
    }

    /// Pre: Gross asset value has been calculated
    /// Post: The sum and its individual parts of all applicable fees denominated in [base unit of melonAsset]
    function unclaimedRewards(
      uint lastPayoutTime, uint lastPayoutPrice, uint managementRewardRate,
      uint performanceRewardRate, uint feeDivisor, uint totalSupply, uint gav,
      uint melonBaseUnits
    )
        constant
        returns (
            uint management,
            uint performance,
            uint unclaimed
        )
    {
        uint timeDifference = now.sub(lastPayoutTime);
        management = managementReward(
            managementRewardRate,
            timeDifference,
            gav,
            feeDivisor
        );
        performance = 0;
        if (totalSupply != 0) {
            uint currSharePrice = valuePerShare(gav, melonBaseUnits, totalSupply); //TODO: Multiply w getInvertedPrice(ofReferenceAsset)
            if (currSharePrice > lastPayoutPrice) {
                performance = performanceReward(
                    performanceRewardRate,
                    int(currSharePrice - lastPayoutPrice),
                    totalSupply,
                    feeDivisor
                );
            }
        }
        unclaimed = management.add(performance);
    }
}
