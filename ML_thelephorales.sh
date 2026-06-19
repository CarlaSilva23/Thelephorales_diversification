#!/bin/bash

# ==============================================================================
# Script para análisis de máxima verosimilitud 
# ==============================================================================

# Definición de rutas principales
DIR_DATA="/home/CarlaSilva/Documentos/tesis_maestria_carla/secuencias_limpias/alineamientos_postmesquite/alineamientos_postmesquite_17_06_26"
DIR_MERGE="$DIR_DATA/resultados_testmergeonly"
DIR_OUT="$DIR_DATA/resultados_arbol_final"

THREADS=10

# Crear la nueva carpeta para el árbol final si no existe
mkdir -p "$DIR_OUT"

# Nos posicionamos en la carpeta de los alineamientos porque el archivo .best_scheme.nex
# busca los archivos .phy usando rutas relativas desde ahí.
cd "$DIR_DATA" || exit

echo "========================================================="
echo "Iniciando análisis"
echo "========================================================="

# Ejecución de IQ-TREE 3
# -p: Lee el esquema optimizado por el TestMergeOnly
# -B 1000: Corre 1000 réplicas de Ultrafast Bootstrap para soporte de ramas
iqtree3 \
    -p "$DIR_MERGE/analisis_merge_thelephorales.best_scheme.nex" \
    -B 1000 \
    -nt $THREADS \
    -pre "$DIR_OUT/arbol_final_thelephorales"

echo "========================================================="
echo "Análisis de máxima verosimilitud completo"
echo "Los resultados están en: $DIR_OUT"
echo "========================================================="
