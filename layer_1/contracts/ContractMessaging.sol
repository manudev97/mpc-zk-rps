// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./starknet/IStarknetMessaging.sol";

/// @title ContractMessaging
/// @dev This contract facilitates communication between Ethereum and StarkNet by sending messages to StarkNet contracts.
contract ContractMessaging {
    IStarknetMessaging public _snMessaging;

    /// @param starknetCore The address of the StarkNet core contract.
    constructor(address starknetCore) {
        _snMessaging = IStarknetMessaging(starknetCore);
    }

    /// @notice Sends a message to a StarkNet contract.
    /// @dev This function constructs a payload and sends it to a specified Layer 2 contract.
    /// @param contractAddress The address of the StarkNet contract to which the message will be sent.
    /// @param selector The function selector that identifies the function to be called on the Layer 2 contract.
    function sendMessageValue(
        uint256 contractAddress,
        uint256 selector
    ) external payable {
        uint256[] memory payload = new uint256[](1);
        payload[0] = 1;
        // Sending the message to the specified StarkNet contract.
        _snMessaging.sendMessageToL2{value: msg.value}(
            contractAddress,
            selector,
            payload
        );
    }
}