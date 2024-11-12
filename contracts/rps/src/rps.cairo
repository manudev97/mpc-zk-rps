use starknet::ContractAddress;

#[starknet::interface]
pub trait IMatchProof<TContractState> {
    fn submit_proof(ref self: TContractState, player: ContractAddress, proof: felt252);
    fn verify_proofs(self: @TContractState) -> bool;
}

#[starknet::contract]
mod ProofManager {
    use starknet::{ContractAddress, get_caller_address};
    use super::IMatchProof;

    #[storage]
    struct Storage {
        player1_proof: felt252,      // proof of player 1
        player2_proof: felt252,      // proof of  player 2
        proofs_match: bool,          // if the proof match
        verifier: felt252,   // address of the authorized verifier
    }

    #[constructor]
    fn constructor(ref self: ContractState, verifier: felt252) {
        self.proofs_match.write(false);
        self.player1_proof.write(0);
        self.player2_proof.write(0);
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
        from_address: felt252,
        proof1: felt252,
    }

    #[abi(embed_v0)]
    impl ProofManager of IMatchProof<ContractState> {

        fn submit_proof(ref self: ContractState, player: ContractAddress, proof: felt252) {
            let caller = get_caller_address();
            assert(caller == player, 'Unauthorized');

            if self.player1_proof.read() == 0 {
                self.player1_proof.write(proof);
            } else if self.player2_proof.read() == 0 {
                self.player2_proof.write(proof);
            } else {
                panic!("Both proofs already submitted");
            }
        }

        fn verify_proofs(self: @ContractState) -> bool {
            let proof1 = self.player1_proof.read();
            let proof2 = self.player2_proof.read();

            if proof1 != 0 && proof2 != 0 {
                proof1 == proof2
            } else {
                false
            }
        }
    }

    // l1 handler function to send the test from L1
    #[l1_handler]
    fn submit_proof_l1_handler(
        ref self: ContractState,
        from_address: felt252,
        proof1: felt252,
    ) {
        let verifier = self.verifier.read();
        assert(from_address == verifier, 'Unauthorized caller');

        // Save the proof parts to storage or process them as you wish
        self.player1_proof.write(proof1);  // just as an example of storage

        // emit an event to send the prrof data to L1
        self.emit(
            ProofSubmitted {
                from_address,
                proof1,
            }
        );
    }        
}