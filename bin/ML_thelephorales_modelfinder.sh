#!/bin/bash

# =====================================================
# ANALISIS FILOGENETICO ML EN IQ-TREE3
# =====================================================

# Ir al directorio de trabajo
cd /home/CarlaSilva/Documentos/tesis_maestria_carla/secuencias_limpias/alineamientos_postmesquite/matrices_concatenadas

# =====================================================
# Ejecutar IQ-TREE3
# =====================================================

iqtree3 \
    -s matriz_concatenada_26_05_26.phy \
    -p particiones.txt \
    -m MFP+MERGE \
    -B 1000 \
    --alrt 1000 \
    -bnni \
    -T AUTO \
    --prefix ML_Thelephorales
