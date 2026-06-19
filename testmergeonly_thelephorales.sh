#!/bin/bash

# ==============================================================================
# Script para análisis TESTMERGEONLY en IQ-TREE3
# ==============================================================================

# Ruta principal de los alineamientos
DIR="/home/CarlaSilva/Documentos/tesis_maestria_carla/secuencias_limpias/alineamientos_postmesquite/alineamientos_postmesquite_17_06_26"
DIR_OUT="$DIR/resultados_testmergeonly"

THREADS=10

# Crear directorio de salida si no existe
mkdir -p "$DIR_OUT"

# Ruta del archivo de particiones unificado
PARTITION_FILE="$DIR_OUT/particiones_globales.txt"

echo "Generando archivo de particiones globales..."

# Crear el encabezado en formato NEXUS
echo "#nexus" > "$PARTITION_FILE"
echo "begin sets;" >> "$PARTITION_FILE"

# 1. Agregar los loci en formato PHYLIP (excluyendo rpb2)
cd "$DIR" || exit
for aln in *_thelephorales.phy; do
    if [ "$aln" != "rpb2_thelephorales.phy" ] && [ -f "$aln" ]; then
        base=$(basename "$aln" .phy)
        # Nota: Se remueve la palabra 'DNA,' para compatibilidad estricta con IQ-TREE 3
        echo "    charset $base = $DIR/$aln: 1-. ;" >> "$PARTITION_FILE"
    fi
done

# 2. Agregar las posiciones de codón exactas para rpb2 sin la palabra 'DNA,'
echo "    charset codonPos1 = $DIR/rpb2_thelephorales.phy: 1-595\\3 ;" >> "$PARTITION_FILE"
echo "    charset codonPos2 = $DIR/rpb2_thelephorales.phy: 2-593\\3 ;" >> "$PARTITION_FILE"
echo "    charset codonPos3 = $DIR/rpb2_thelephorales.phy: 3-594\\3 ;" >> "$PARTITION_FILE"

echo "end;" >> "$PARTITION_FILE"

echo "========================================================="
echo "Iniciando análisis TESTMERGEONLY en IQ-TREE3..."
echo "========================================================="

# Ejecutar IQ-TREE3
iqtree3 \
    -p "$PARTITION_FILE" \
    -m TESTMERGEONLY \
    -nt $THREADS \
    -pre "$DIR_OUT/analisis_merge_thelephorales"

echo "========================================================="
echo "Análisis finalizado"
echo "========================================================="
