#[starknet::interface]
pub trait IMatchProof<TContractState> {
    fn submit_proof(ref self: TContractState, proof: Proof);
    fn verify_proofs(self: @TContractState) -> bool;
    fn reset_proofs(ref self: TContractState);
    fn get_winner(self: @TContractState) -> felt252;
}

#[derive(Drop, Serde, Copy, PartialEq, starknet::Store)]
    pub struct Proof {
        pi_a_1: u256,
        pi_a_2: u256,
        pi_b_11: u256,
        pi_b_12: u256,
        pi_b_21: u256,
        pi_b_22: u256,
        pi_c_1: u256,
        pi_c_2: u256
    }

#[starknet::contract]
mod ProofManager {
    use starknet::{EthAddress, SyscallResultTrait};
    use super::Proof;
    use super::IMatchProof;

    

    #[storage]
    struct Storage {
        player1_proof: Proof,      // proof of player 1
        player2_proof: Proof,      // proof of  player 2
        proofs_match: bool,          // if the proof match
        verifier: felt252,   // address of the authorized verifier
        winner: felt252
    }

    pub const DEFAULT_PROOF: Proof = Proof {
        pi_a_1: 0,
        pi_a_2: 0,
        pi_b_11: 0,
        pi_b_12: 0,
        pi_b_21: 0,
        pi_b_22: 0,
        pi_c_1: 0,
        pi_c_2: 0,
    };

    #[constructor]
    fn constructor(ref self: ContractState, verifier: felt252) {
        self.player1_proof.write(DEFAULT_PROOF);
        self.player2_proof.write(DEFAULT_PROOF);
        self.verifier.write(verifier); // we keep the address of the authorized verifier
    }

    // defines the event to send the test to L1
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ProofSubmitted: ProofSubmitted,
    }

    #[derive(Drop, Serde, starknet::Event)]
    struct ProofSubmitted {
        #[key]
        to_address: EthAddress,
        proof: Proof,
    }

    #[abi(embed_v0)]
    impl ProofManager of IMatchProof<ContractState> {

        fn submit_proof(ref self: ContractState, proof: Proof) {
            if self.player1_proof.read() == DEFAULT_PROOF {
                self.player1_proof.write(proof);
            } else if self.player2_proof.read() == DEFAULT_PROOF {
                self.player2_proof.write(proof);
            } else {
                panic!("Both proofs already submitted");
            }
        }
    
        fn verify_proofs(self: @ContractState) -> bool {
            let proof1 = self.player1_proof.read();
            let proof2 = self.player2_proof.read();
    
            // Implement your logic here to compare the proofs for equality
            // This could involve bit-wise comparison, cryptographic operations, etc.
            // For example (replace with your actual comparison logic):
            if proof1 == proof2 && proof1 != DEFAULT_PROOF
                // ... compare all other fields of the Proof struct ...
            {
                true
            } else {
                false
            }
        }
    
        fn reset_proofs(ref self: ContractState) {
            self.player1_proof.write(DEFAULT_PROOF);
            self.player2_proof.write(DEFAULT_PROOF);
        }

        fn get_winner(self: @ContractState) -> felt252 {
            self.winner.read()
        }
    }

    // l1 handler function to send the test from L1
    #[l1_handler]
    fn receive_message_value_l1(ref self: ContractState, from_address: felt252, value: felt252) {
        let verifier = self.verifier.read();
        assert(from_address == verifier, 'Unauthorized caller');
        // Fixed value to be valid == 1 or 2 or 3
        assert(value == 0 || value == 1 || value == 2, 'Invalid value');
    }

    #[external(v0)]
    fn send_proof_l1_handler(
        ref self: ContractState,
        to_address: EthAddress,
        proof: Proof
    ) {
        let mut buf: Array<felt252> = array![];
        proof.serialize(ref buf);
        starknet::syscalls::send_message_to_l1_syscall(to_address.into(), buf.span()).unwrap_syscall();

        // emit an event to send the proof data to L1
        self.emit(
            ProofSubmitted {
                to_address,
                proof,  // You need to populate the proof fields here with actual data
            }
        );
    }  

}
