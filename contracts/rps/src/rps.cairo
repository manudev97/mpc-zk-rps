use starknet::ContractAddress;

#[starknet::interface]
pub trait IMatchProof<TContractState> {
    fn submit_proof(ref self: TContractState, player: ContractAddress, proof: u256);
    fn verify_proofs(self: @TContractState) -> bool;
}

#[starknet::contract]
mod ProofManager {
    use starknet::storage::Map;

    #[storage]
    struct Storage {
        player1_proof: Option<u256>,
        player2_proof: Option<u256>,
        proofs_match: bool,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.proofs_match.write(false);
    }

    #[abi(embed_v0)]
    impl ProofManager of IMatchProof<ContractState> {
        /// Envía la prueba del jugador al contrato
        /// @param player Dirección del jugador que envía la prueba.
        /// @param proof Prueba en formato `u256`.
        fn submit_proof(ref self: ContractState, player: ContractAddress, proof: u256) {
            let caller = get_caller_address();
            assert(caller == player, "Unauthorized");

            if self.player1_proof.is_none() {
                self.player1_proof.write(Some(proof));
            } else if self.player2_proof.is_none() {
                self.player2_proof.write(Some(proof));
            } else {
                panic!("Both proofs already submitted");
            }
        }

        /// Verifica que ambas pruebas coincidan.
        /// @return `true` si las pruebas coinciden, de lo contrario `false`.
        fn verify_proofs(self: @ContractState) -> bool {
            match (self.player1_proof.read(), self.player2_proof.read()) {
                (Some(proof1), Some(proof2)) => {
                    let match_result = proof1 == proof2;
                    self.proofs_match.write(match_result);
                    match_result
                }
                _ => false,
            }
        }
    }
}
