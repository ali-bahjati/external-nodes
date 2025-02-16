// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "./interfaces/external/IExternalNode.sol";
import "./interfaces/external/IAtomicOrderModule.sol";

contract SpotMarketOracle is IExternalNode {
    using DecimalMath for int256;
    using DecimalMath for uint256;

    using SafeCastI256 for int256;
    using SafeCastU256 for uint256;

    int256 public constant PRECISION = 18;

    address public immutable spotMarketAddress;

    constructor(address _spotMarketAddress) {
        spotMarketAddress = _spotMarketAddress;
    }

    function process(
        bytes memory parameters,
        bytes32[] memory runtimeKeys,
        bytes32[] memory runtimeValues
    ) internal view returns (NodeOutput.Data memory nodeOutput) {
        IAtomicOrderModule market = IAtomicOrderModule(spotMarketAddress);
        uint128 marketId = uint128(runtimeValues[0]);
        uint256 synthAmount = uint256(runtimeValues[1]);

        uint256 memory synthValue = market.quoteSellExactIn(
            marketId,
            synthAmount
        );

        return
            NodeOutput.Data(
                synthValue.divDecimal(synthAmount),
                block.timestamp,
                0,
                0
            );
    }

    function isValid(
        NodeDefinition.Data memory nodeDefinition
    ) internal view returns (bool valid) {
        // Must have no parents
        if (nodeDefinition.parents.length > 0) {
            return false;
        }

        return true;
    }
}
