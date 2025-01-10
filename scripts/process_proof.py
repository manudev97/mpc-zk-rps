import json
import sys

def hexify(value):
    """Convierte un entero decimal a un par de enteros de 128 bits en formato hexadecimal."""
    high = value >> 128
    low = value & ((1 << 128) - 1)
    return f"{high} {low}"

def main(proof_file):
    # Cargar datos desde el archivo proof.json
    with open(proof_file, 'r') as f:
        proof_data = json.load(f)

    # Procesar pi_a
    pi_a = [int(x) for x in proof_data["pi_a"][:2]]
    pi_a = [hexify(x) for x in pi_a]

    # Procesar pi_b (matriz de 2x2)
    pi_b = [[int(x) for x in row] for row in proof_data["pi_b"][:2]]
    pi_b = [hexify(row[0]) + " " + hexify(row[1]) for row in pi_b]

    # Procesar pi_c
    pi_c = [int(x) for x in proof_data["pi_c"][:2]]
    pi_c = [hexify(x) for x in pi_c]

    # Generar el comando final
    starkli_args = " ".join(pi_a + pi_b + pi_c)
    print(f"starkli invoke 0x046141f63d44c8ee3a770f6188c98136bd28cc5c4f87f691f5587363e943ac63 submit_proof <player_address> {starkli_args}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python process_proof.py <proof.json>")
        sys.exit(1)
    main(sys.argv[1])
