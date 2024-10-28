import json, sys

# Cargar el archivo JSON (asegúrate de que el archivo "archivo.json" exista)
with open('rps_constraints.json', 'r') as json_file:
    data = json.load(json_file)

# Obtener el número de columnas
num_columnas = int(sys.argv[1])

# Crear matrices A, B y C con ceros
A = [[0] * num_columnas for _ in range(len(data['constraints']))]
B = [[0] * num_columnas for _ in range(len(data['constraints']))]
C = [[0] * num_columnas for _ in range(len(data['constraints']))]

# Llenar las matrices con los valores de los diccionarios
for i, row in enumerate(data['constraints']):
    for j, dic in enumerate(row):
        for key, val in dic.items():
            col = int(key)  # Convertir la clave a índice de columna
            try:
                if j == 0:
                    A[i][col] = int(val)
                elif j == 1:
                    B[i][col] = int(val)
                elif j == 2:
                    C[i][col] = int(val)
            except IndexError:
                print(f"Error: Índice fuera de rango en fila {i}, columna {col}")

# Imprimir las matrices
print("A = Matrix(Fp,\n["+",\n".join(str(fila) for fila in A)+"]\n)")
print("B = Matrix(Fp,\n["+",\n".join(str(fila) for fila in B)+"]\n)")
print("C = Matrix(Fp,\n["+",\n".join(str(fila) for fila in C)+"]\n)")

