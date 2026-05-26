#!/bin/bash

# =====================================================
# Script para selección de modelo en IQ-TREE3
# Para alineamientos en formato PHYLIP (.phy)
# =====================================================

# Ruta a tus alineamientos
DIR="/home/CarlaSilva/Documentos/tesis_maestria_carla/secuencias_limpias/alineamientos_postmesquite"

# Número de hilos a usar
THREADS=4

# Ir al directorio
cd "$DIR" || exit

# Crear carpeta para resultados
mkdir -p resultados_modeltest

# Loop para todos los archivos .phy
for aln in *.phy; do
    
    # Obtener nombre base
    base=$(basename "$aln" .phy)

    echo "====================================="
    echo "Analizando: $aln"
    echo "====================================="

    # Correr ModelFinder
    iqtree3 \
        -s "$aln" \
        -m MFP \
        -nt $THREADS \
        -pre "resultados_modeltest/${base}"

done

echo "====================================="
echo "Selección de modelos terminada"
echo "====================================="
