// SPDX-License-Identifier: MIT
import "./starknet/IStarknetMessaging.sol";

// starknetCore --> 0xE2Bb56ee936fd6433DC0F6e7e3b8365C906AA057
// _verifierAddress --> 0x46565B512A3E167b9196AD0B8eb3A14a7f593547

error InvalidPayload();
/// @title TicketVerifier
/// @dev This contract is responsible for verifying the validity of a RPS game using a zero-knowledge proof system.
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
    uint256[2] public pA;
    uint256[2][2] public pB;
    uint256[2] public pC;
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

        if (payload.length != 16) {
            revert InvalidPayload();
        }

        pA[0] = uint256(bytes32((payload[1] << 128) | payload[0]));
        pA[1] = uint256(bytes32((payload[3] << 128) | payload[2]));

        pB[0][0] = uint256(bytes32((payload[5] << 128) | payload[4]));
        pB[0][1] = uint256(bytes32((payload[7] << 128) | payload[6]));
        pB[1][0] = uint256(bytes32((payload[9] << 128) | payload[8]));
        pB[1][1] = uint256(bytes32((payload[11] << 128) | payload[10]));

        pC[0] = uint256(bytes32((payload[13] << 128) | payload[12]));
        pC[1] = uint256(bytes32((payload[15] << 128) | payload[14]));
    }

}