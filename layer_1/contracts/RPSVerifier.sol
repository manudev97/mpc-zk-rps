// SPDX-License-Identifier: MIT
import "./starknet/IStarknetMessaging.sol";


error InvalidPayload();
/// @title TicketVerifier
/// @dev This contract is responsible for verifying the validity of a ticket using a zero-knowledge proof system.
/// It interacts with the StarkNet messaging system to send messages to Layer 2.
interface IVerifier {
    /// @notice Verifies a zero-knowledge proof.
    /// @param _pA The first part of the proof.
    /// @param _pB The second part of the proof (pairing).
    /// @param _pC The third part of the proof.
    /// @param _pubSignals The public signals that are used for verification.
    /// @return bool True if the proof is valid, otherwise false.
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals
    ) external view returns (bool);
}
pragma solidity >=0.7.0 <0.9.0;

contract RockPaperScissorsVerifier {
    IStarknetMessaging public _snMessaging;
    IVerifier public _verifierContract;
    
    uint256 public publicSignal;
    bool public success;
    /// @param starknetCore The address of the StarkNet core contract.
    constructor(address starknetCore, address _verifierAddress) {
        _snMessaging = IStarknetMessaging(starknetCore);
        _verifierContract = IVerifier(_verifierAddress);
    }

    /// @notice Check the result of the Rock, Paper, Scissors game based on three possible public signals.
    /// @param _pA First part of the test.
    /// @param _pB Second part of the test.
    /// @param _pC Third part of the test.
    /// @param contractAddress The address of the Layer 2 contract to which the message will be sent.
    /// @param selector The function selector to call on the Layer 2 contract.
    function verifyGameResult(
        uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        uint256 contractAddress,
        uint256 selector
    ) external payable {
        // Try to verify the test with publicSignal = 0, 1 and 2
        for (publicSignal = 0; publicSignal <= 2; publicSignal++) {
            success = _verifierContract.verifyProof(
                _pA,
                _pB,
                _pC,
                [uint256(bytes32(publicSignal))]
            );

            // If the proof is valid, return the value of publicSignal
            if (success) {
                break;
            }
        }

        // If no proof is valid, roll back the transaction
        require(success, "Invalid Proof");
        uint256[] memory payload = new uint256[](1);
        payload[0] = publicSignal;

        _snMessaging.sendMessageToL2{value: msg.value}(
            contractAddress,
            selector,
            payload
        );
    }

    function consumeMessageStarknet(
        uint256 fromAddress,
        uint256[] calldata payload
    )
        external
    {
        _snMessaging.consumeMessageFromL2(fromAddress, payload);

        if (payload.length != 8) {
            revert InvalidPayload();
        }

        uint256 pi_a_1 = payload[0];
        uint256 pi_a_2 = payload[1];
        uint256 pi_b_11 = payload[2];
        uint256 pi_b_12 = payload[3];
        uint256 pi_b_21 = payload[4];
        uint256 pi_b_22 = payload[5];
        uint256 pi_c_1 = payload[6];
        uint256 pi_c_2 = payload[7];
        require(pi_a_1 > 0 && pi_a_2 > 0 && pi_b_11 > 0 && pi_b_12 > 0 && pi_b_21 > 0 &&
         pi_b_22 > 0 && pi_c_1 > 0 && pi_c_2 > 0, "Invalid Value");
    }
}