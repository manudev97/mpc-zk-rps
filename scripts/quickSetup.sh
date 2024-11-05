# Usar la configuracion de potencias perpetuas de tau como la fase 1
PHASE1=build/phase1_final.ptau
PHASE2=build/phase2_final.ptau
CIRCUIT_ZKEY=build/circuit_final.zkey

# Fase 1
if [ -f "$PHASE1" ]; then
    echo "Phase 1 file exists, no action"
else
    echo "Phase 1 file does not exist, downloading ..."
    curl -o $PHASE1 https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_14.ptau
fi

# Fase 2 sin contribuciones
npx snarkjs powersoftau prepare phase2 $PHASE1 $PHASE2 -v

npx snarkjs zkey new build/rps.r1cs $PHASE2 $CIRCUIT_ZKEY

npx snarkjs zkey export verificationkey $CIRCUIT_ZKEY build/verification_key.json


npx snarkjs zkey export solidityverifier $CIRCUIT_ZKEY build/Verifier.sol
# Fix versión de solidity (para que el comando funcione tanto en Linux como en Mac)
cd build/ && sed 's/0\.6\.11/0\.7\.3/g' Verifier_1in_pr.sol > tmp.txt && mv tmp.txt Verifier.sol
