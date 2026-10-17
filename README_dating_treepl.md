# Guía de fechado con treePL — Thelephorales (servidor beagle)

Esta guía fecha el árbol de máxima verosimilitud de 539 especies (`results/especies_compuestas/`) con treePL, siguiendo el protocolo de Maurin (2020) y el flujo de Thelephoraceae de América (Andrea Mackie Greene), con cinco calibraciones fósiles y una calibración secundaria en la raíz (271.2 Ma).

## Qué árbol usar: el .treefile

Se fecha el `.treefile` (`ml/thelephorales_especies_ml.treefile`), no el `.contree`: treePL convierte longitudes de rama en tiempo, y solo el `.treefile` tiene la topología y las longitudes de rama de máxima verosimilitud.

|  | `.treefile` | `.contree` |
| --- | --- | --- |
| Qué es | El mejor árbol que encontró IQ-TREE | El consenso de las 1000 réplicas UFBoot |
| Topología | Totalmente resuelta (540 nodos internos, verificado) | Puede tener politomías donde el soporte fue < 50% |
| Longitudes de rama | Optimizadas por ML sobre los datos | Calculadas sobre el consenso, no las del mejor árbol |
| Valores en los nodos | UFBoot | UFBoot |
| Uso en esta guía | **Árbol que se fecha** y restricción de las réplicas | Solo para comparar o ilustrar soporte |

Por qué no afecta el análisis usar el `.treefile`:

- Es lo que piden Maurin (2020) y la guía de Thelephoraceae de América: el mejor árbol ML, sin valores de soporte.
- Las réplicas bootstrap se generan con la **misma topología** (restricción `-g`), así que los intervalos de confianza son de los nodos de ese mismo árbol.
- Los valores de UFBoot se quitan antes de fechar (treePL no tolera anotaciones) y se pueden volver a poner en la figura final.

Condición que hay que mantener: los nombres del árbol deben coincidir con los de `concatenado_especies.nex`. Si se corrigió el nombre de *Thelephora* AM671 en uno, debe estar igual en el otro (el Paso 0 lo comprueba).

## Mapa del flujo

| Paso | Qué se hace | Dónde |
| --- | --- | --- |
| 0 | Verificar taxones y nombres (`taxa_ml.txt`, 539 terminales) | Servidor |
| 1 | Obtener `numsites` (5516) | Servidor |
| 2 | 1000 réplicas bootstrap con topología fija (IQ-TREE `-g`) → `boot.boottrees` | Servidor |
| 3 | Enraizar en *Corticium minnsiae*, quitar *Hydnellum joeides* y multiplicar ×10 000 (R) | Laptop |
| 4 | Archivo de configuración con calibraciones (`config_prime.txt`) | Servidor |
| 5 | `prime` ×3 (treePL) → `opt`, `optad`, `optcvad` | Servidor |
| 6 | Validación cruzada ×3 (treePL) → `smooth` | Servidor |
| 7 | Fechar 50 bloques de 20 réplicas (treePL) → `boot_fechados.tre` | Servidor |
| 8 | Resumir con TreeAnnotator → `thelephorales_fechado.tre` | Laptop |

El único regreso es del Paso 5 al 3: si `prime` marca más de un mensaje *tiny branch*, se vuelve a multiplicar con un factor mayor.

## Calibraciones

Se usan cinco calibraciones fósiles como edades mínimas y una calibración secundaria en la raíz; el árbol se enraíza en *Corticium minnsiae*, igual que el análisis de ML con todas las secuencias (`-o Corticium_minnsiae`).

| Nodo en el config | Orden | Calibración | Edad (Ma) | Terminales del `mrca` | Referencia |
| --- | --- | --- | --- | --- | --- |
| `RAIZ` | Ancestro común de los seis órdenes | Secundaria | min = max = 271.2 | `Corticium_minnsiae` + `Hymenochaete_rubiginosa` | Sánchez-García et al., 2020 (confirmar figura y valor) |
| `HYMENOCHAETALES` | Hymenochaetales | *Quatsinoporites cranhamii* | min 125, max 129 | `Inonotus_cuticularis` + `Resinicium_friabile` | Smith et al., 2004 |
| `RUSSULALES` | Russulales | *Edaphagaricites conicus* | min 113 | `Russula_xerampelina` + `Artomyces_pyxidatus` | Gobo et al., 2025 |
| `BOLETALES` | Boletales | Fósil ectomicorrízico *Suillus*/*Rhizopogon* | min 50 | `Suillellus_luridus` + `Leccinum_versipelle` | Lepage et al., 1997 |
| `POLYPORALES_TRAMETITES` | Polyporales | *Trametites eocenicus* | min 35 | `Ganoderma_carnosum` + `Fomes_fomentarius` | Knobloch y Kotlaba, 1994 |
| `GANODERMA` | Polyporales | *Ganodermites lybicus* | min 18 | `Ganoderma_carnosum` + `Ganoderma_applanatum` | Fleischmann et al., 2007 |

- **Raíz en 271.2 Ma.** Tu árbol tiene seis órdenes (Thelephorales, Boletales, Polyporales, Russulales, Hymenochaetales y Corticiales), y en la filogenia de referencia su ancestro común es el nodo de 271.2 Ma. Se fija como valor puntual, así que su incertidumbre no pasa a los intervalos de confianza; se reporta como limitación. Si treePL rechaza `min` y `max` idénticos, se usa una ventana angosta (por ejemplo 271.1–271.3) o el intervalo HPD del artículo.
- **El `mrca` de la raíz usa *Corticium minnsiae* y cualquier terminal del otro lado de la raíz.** Como el árbol se enraíza en esa terminal, su ancestro común con cualquier otra especie es la raíz; en R se comprueba que `getMRCA()` devuelva el nodo raíz (Paso 3).
- **No se calibran los nodos intermedios de la referencia** (198.4 Ma para Hymenochaetales + Corticiales y 243.9 Ma para el otro bloque): en tu árbol Corticiales no sale monofilético (*Vuilleminia* y *Punctularia* quedan junto a Hymenochaetales y Russulales), así que esos nodos no existen en tu topología. Se usan solo para comparar al final: las coronas de Polyporales (\~193 Ma), Thelephorales (\~176 Ma) y Boletales (\~152 Ma) deberían quedar cerca de esos valores.
- **Los fósiles son edades mínimas**, salvo *Quatsinoporites*, con mínimo y máximo (125–129 Ma). Para *Edaphagaricites* (113–121 Ma) se usa solo el mínimo.
- **Varios fósiles se colocan en un nodo más amplio que el grupo al que se asignan**: *Quatsinoporites* (Hymenochaetaceae) en Hymenochaetales, *Edaphagaricites* en Russulales (*Russula* + *Artomyces*), el fósil de *Suillus*/*Rhizopogon* (Suillineae) en la corona de Boletales y *Trametites* (*Trametes*) en el nodo de *Ganoderma* + *Fomes*. Como son edades mínimas, es una decisión conservadora; se reporta en métodos.
- **Cada `mrca` usa una terminal de cada uno de los dos linajes que salen del nodo calibrado.** En Hymenochaetales, confirma que *Resinicium* queda dentro del orden y en el lado opuesto a *Inonotus*: en el árbol completo, *Resinicium* y *Rickenella* salían fuera del bloque de *Hymenochaete*, *Coltricia* y *Xylodon*.

## Pasos 0–2: verificar, numsites y réplicas bootstrap

### Paso 0. Verificar taxones de calibración y grupo externo

Antes de lanzar nada, confirma que las terminales de las calibraciones existen en el árbol y que los nombres del árbol coinciden con la matriz.

```bash
mkdir -p ~/mi_proyecto/results/especies_compuestas/fechado
cd ~/mi_proyecto/results/especies_compuestas
tr ',()' '\n\n\n' < ml/thelephorales_especies_ml.treefile | sed 's/:.*//' | grep -v '^[0-9.\/]*$' | grep -v '^;*$' | sort -u > fechado/taxa_ml.txt
awk '/matrix/{m=1; next} m && /;/{exit} m && NF==2 {print $1}' concatenado_especies.nex | sort > fechado/taxa_matriz.txt
echo "Árbol: $(wc -l < fechado/taxa_ml.txt)  Matriz: $(wc -l < fechado/taxa_matriz.txt)"
comm -3 fechado/taxa_ml.txt fechado/taxa_matriz.txt

for t in Corticium_minnsiae Hymenochaete_rubiginosa Inonotus_cuticularis Resinicium_friabile Russula_xerampelina Artomyces_pyxidatus \
         Suillellus_luridus Leccinum_versipelle Ganoderma_carnosum Fomes_fomentarius Ganoderma_applanatum; do
  grep -qx "$t" fechado/taxa_ml.txt && echo "OK         $t" || echo "NO EXISTE  $t"
done

cut -d_ -f1 fechado/taxa_ml.txt | sort | uniq -c
```

- Árbol y matriz deben dar **539** y `comm` no debe imprimir nada.
- Una terminal que salga **NO EXISTE** se cambia por otra especie que defina el mismo nodo (Calibraciones).
- La lista de géneros sirve para revisar los pares de terminales de cada calibración.

### Paso 1. numsites

```bash
grep -m1 dimensions ~/mi_proyecto/results/especies_compuestas/concatenado_especies.nex
```

Debe decir `nchar=5516`: ese es `numsites`. IQ-TREE no descarta sitios con bases ambiguas, así que 5516 corresponde a lo que usó el análisis.

### Paso 2. 1000 réplicas bootstrap con la topología fija

IQ-TREE recibe el árbol ML como restricción (`-g`); como está totalmente resuelto, todas las réplicas tienen esa topología y solo cambian sus longitudes de rama. Los modelos ya elegidos se reutilizan (`-p best_scheme`).

```bash
cd ~/mi_proyecto/results/especies_compuestas
sed -E 's/\)[0-9.\/]+:/):/g; s/\)[0-9.\/]+;/);/' ml/thelephorales_especies_ml.treefile > fechado/ml_sin_soporte.tre
ls ml/thelephorales_especies_ml.best_scheme.nex

cat > ~/mi_proyecto/scripts/18_bootstrap_fechado.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=boot_fecha
#SBATCH --partition=ib
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=5-00:00:00
#SBATCH --output=/home/ib/csilva/mi_proyecto/logs/boot_fecha_%j.out

cd ~/mi_proyecto
D=/results/especies_compuestas
apptainer exec --containall --cleanenv --bind $PWD/results:/results contenedores/filogenia_portable.sif \
  iqtree3 -s $D/concatenado_especies.nex \
          -p $D/ml/thelephorales_especies_ml.best_scheme.nex \
          -g $D/fechado/ml_sin_soporte.tre \
          -b 1000 -T $SLURM_CPUS_PER_TASK \
          --prefix $D/fechado/boot
EOF
cd ~/mi_proyecto/scripts && sbatch 18_bootstrap_fechado.sh
```

- Salida: `fechado/boot.boottrees` (1000 árboles con longitudes de rama).
- Si llega al límite de 5 días, se vuelve a enviar el mismo script: IQ-TREE continúa desde su checkpoint.
- Al terminar: `grep -c ";" fechado/boot.boottrees` debe dar 1000.

## Paso 3: enraizar y multiplicar longitudes de rama (R, en la laptop)

treePL necesita árboles enraizados, y el árbol ML y las 1000 réplicas deben llevar **el mismo enraizamiento y el mismo factor**; si no, se fecharían árboles distintos al usado en prime y en la validación cruzada.

Descargar al laptop. En **Linux Mint** (Terminal):

```bash
scp "csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/ml_sin_soporte.tre" \
    "csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/boot.boottrees" ~/Descargas/
```

En **Windows** (PowerShell, todo en una línea):

```powershell
scp "csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/ml_sin_soporte.tre" "csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/boot.boottrees" C:\Users\carla\Downloads\
```

En R:

```r
library(ape)
setwd("~/Descargas")                    # Linux Mint
# setwd("C:/Users/carla/Downloads")     # Windows: quita el # aquí y ponlo en la línea de arriba

# Grupo externo: Corticium minnsiae (igual que -o en el ML con todas las secuencias)
externo <- "Corticium_minnsiae"

ml   <- read.tree("ml_sin_soporte.tre")
reps <- read.tree("boot.boottrees")

ml   <- root(ml, outgroup = externo, resolve.root = TRUE)
reps <- lapply(reps, root, outgroup = externo, resolve.root = TRUE); class(reps) <- "multiPhylo"
# Quitar Hydnellum_joeides: es la misma especie que Hydnellum_ioeides (hermanas, UFBoot 100)
ml   <- drop.tip(ml, "Hydnellum_joeides")
reps <- lapply(reps, drop.tip, tip = "Hydnellum_joeides"); class(reps) <- "multiPhylo"
is.rooted(ml); is.binary(ml); Ntip(ml); length(reps)     # TRUE, TRUE, 538, 1000

# La raíz: el mrca debe ser el nodo raíz (Ntip + 1)
getMRCA(ml, c("Corticium_minnsiae", "Hymenochaete_rubiginosa")) == Ntip(ml) + 1   # TRUE

# Verificar qué géneros quedan dentro de cada nodo calibrado
calibraciones <- list(
  HYMENOCHAETALES        = c("Inonotus_cuticularis", "Resinicium_friabile"),
  RUSSULALES             = c("Russula_xerampelina", "Artomyces_pyxidatus"),
  BOLETALES              = c("Suillellus_luridus", "Leccinum_versipelle"),
  POLYPORALES_TRAMETITES = c("Ganoderma_carnosum", "Fomes_fomentarius"),
  GANODERMA              = c("Ganoderma_carnosum", "Ganoderma_applanatum"))
for (k in names(calibraciones)) {
  d <- extract.clade(ml, getMRCA(ml, calibraciones[[k]]))$tip.label
  cat("\n==", k, "(", length(d), "terminales):", paste(sort(unique(sub("_.*", "", d))), collapse = ", "), "\n")
}

min(ml$edge.length[ml$edge.length > 0])                  # rama más corta
factor <- 10000
ml$edge.length <- ml$edge.length * factor
reps <- lapply(reps, function(t){ t$edge.length <- t$edge.length * factor; t }); class(reps) <- "multiPhylo"

write.tree(ml,   "ml_enraizado_x10000.tre")
write.tree(reps, "boot_enraizado_x10000.tre")
```

**Poda de *Hydnellum joeides*.** Las muestras `Hydnellum_joeides_126` y `_127` son *H. ioeides* con un error ortográfico, así que en la matriz formaron una terminal aparte. En el árbol ML ambas terminales son hermanas (UFBoot = 100, distancia 0.0029), de modo que se quita `Hydnellum_joeides` del árbol ML **y de las 1000 réplicas** antes de fechar; se conserva `Hydnellum_ioeides` (ITS + LSU). A partir de aquí el árbol tiene **538 especies**, y el árbol fechado ya sale con una terminal por especie para MuHiSSE.

Subir al servidor. En **Linux Mint**:

```bash
scp ~/Descargas/ml_enraizado_x10000.tre ~/Descargas/boot_enraizado_x10000.tre \
    csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/
```

En **Windows** (PowerShell, todo en una línea):

```powershell
scp C:\Users\carla\Downloads\ml_enraizado_x10000.tre C:\Users\carla\Downloads\boot_enraizado_x10000.tre csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/
```

- `root()` da error si los externos no forman un clado; en ese caso revisa la lista `externos`.
- Multiplicar por 10 000 **no cambia las edades** (las calibraciones fijan la escala); evita que treePL reemplace las ramas muy cortas por un valor estándar (Maurin, Step 4.5).
- Si al correr `prime` aparece más de un mensaje `tiny branch`, se repite este paso con un factor mayor. Un solo mensaje, atribuible a la rama de la raíz, se puede ignorar.

## Pasos 4–6: configuración, prime y validación cruzada

### Paso 4. Archivo de configuración y script de treePL

Un solo archivo se va modificando paso a paso; las calibraciones quedan activas todo el tiempo y las líneas con `#` están desactivadas.

```bash
cd ~/mi_proyecto/results/especies_compuestas/fechado
cat > config_prime.txt << 'EOF'
[Input files containing the ML trees]
treefile = ml_enraizado_x10000.tre
#treefile = boot_enraizado_x10000.tre

[General commands]
numsites = 5516
nthreads = 8
thorough
log_pen

[Calibrations]
mrca = RAIZ Corticium_minnsiae Hymenochaete_rubiginosa
min = RAIZ 271.2
max = RAIZ 271.2
mrca = HYMENOCHAETALES Inonotus_cuticularis Resinicium_friabile
min = HYMENOCHAETALES 125
max = HYMENOCHAETALES 129
mrca = RUSSULALES Russula_xerampelina Artomyces_pyxidatus
min = RUSSULALES 113
mrca = BOLETALES Suillellus_luridus Leccinum_versipelle
min = BOLETALES 50
mrca = POLYPORALES_TRAMETITES Ganoderma_carnosum Fomes_fomentarius
min = POLYPORALES_TRAMETITES 35
mrca = GANODERMA Ganoderma_carnosum Ganoderma_applanatum
min = GANODERMA 18

[Priming command]
prime

[Best optimisation parameters]
#opt =
#optad =
#optcvad =

[Cross-validation analysis]
#randomcv
#cviter = 5
#cvsimaniter = 1000000000
#cvstart = 10
#cvstop = 0.00000001
#cvmultstep = 0.1
#seed = 12345
#cvoutfile = randomcv_1.txt

[Best smoothing value]
#smooth =

[Output file of dating step]
#outfile = boot_fechados.tre
EOF

cat > ~/mi_proyecto/scripts/19_treepl.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=treepl
#SBATCH --partition=ib
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=5-00:00:00
#SBATCH --output=/home/ib/csilva/mi_proyecto/logs/treepl_%j.out
# Uso: sbatch 19_treepl.sh config_xxx.txt
cd ~/mi_proyecto
apptainer run --cleanenv --bind $PWD/results:/results \
  --pwd /results/especies_compuestas/fechado contenedores/treepl.sif "$1"
EOF
```

Si en el Paso 0 alguna terminal salió **NO EXISTE**, cámbiala en el bloque `[Calibrations]` antes de seguir.

### Paso 5. prime (3 corridas)

```bash
cd ~/mi_proyecto/scripts
for i in 1 2 3; do sbatch 19_treepl.sh config_prime.txt; done
```

Al terminar, en cada log se leen los parámetros sugeridos y los mensajes de ramas cortas:

```bash
for f in $(ls -t ~/mi_proyecto/logs/treepl_*.out | head -n 3); do
  echo "== $f"; grep -A4 "PLACE THE LINES" $f; echo "tiny branch: $(grep -c 'tiny branch' $f)"
done
```

- Se elige la corrida con los valores **más bajos** de `opt`, `optad` y `optcvad`.
- Más de un mensaje `tiny branch` → volver al Paso 3 con un factor mayor.
- `Linear search failed`, `Unable to progress` o `Maximum number of function evaluations reached` son normales.

### Paso 6. Validación cruzada (3 corridas)

Se desactiva `prime`, se escriben los parámetros del Paso 5 y se activa la validación cruzada aleatoria con un rango de smoothing de 10 a 10⁻⁸.

```bash
cd ~/mi_proyecto/results/especies_compuestas/fechado
sed -e 's/^prime/#prime/' -e 's/^#opt =.*/opt = X/' -e 's/^#optad =.*/optad = Y/' -e 's/^#optcvad =.*/optcvad = Z/' \
    -e 's/^#\(randomcv\|cviter\|cvsimaniter\|cvstart\|cvstop\|cvmultstep\|seed\)/\1/' \
    -e 's/^#cvoutfile = .*/cvoutfile = randomcv_RUN.txt/' config_prime.txt > config_cv.txt
nano config_cv.txt          # cambiar X, Y y Z por los valores del Paso 5

for i in 1 2 3; do sed "s/RUN/$i/" config_cv.txt > config_cv_$i.txt; sbatch ~/mi_proyecto/scripts/19_treepl.sh config_cv_$i.txt; done
```

Cuando terminen las tres:

```bash
paste randomcv_1.txt randomcv_2.txt randomcv_3.txt
```

Cómo elegir `smooth`:

1. El mejor valor de cada corrida es el de **chi² más bajo**.
2. Si el mínimo cae justo en `cvstop` (10⁻⁸), repetir con `cvstart = 0.0001` y `cvstop = 0.000000000001`.
3. Si las corridas no coinciden, elegir el valor **más bajo** dentro del rango de los mejores: con seis órdenes de Agaricomycetes se espera mucha heterogeneidad de tasas.
4. Si aparece `might want to try a different opt=VALUE` u `optad=VALUE`, subir ese valor de uno en uno hasta que desaparezca.
5. Una corrida con chi² casi plano en todo el rango probablemente no convergió; no se usa para decidir.

## Pasos 7–8: fechar las réplicas y resumir

### Paso 7. Fechar las 1000 réplicas en bloques

Con los parámetros y el `smooth` elegidos, treePL fecha cada réplica; sus edades dan los intervalos de confianza. Se divide en 50 bloques de 20 réplicas, con 5 bloques corriendo a la vez.

**Config de fechado** (réplicas activas, validación cruzada desactivada, `smooth` y `outfile` activos, 4 hilos por bloque):

```bash
cd ~/mi_proyecto/results/especies_compuestas/fechado
sed -e 's/^\(randomcv\|cviter\|cvsimaniter\|cvstart\|cvstop\|cvmultstep\|cvoutfile\)/#\1/' \
    -e 's/^#smooth =.*/smooth = S/' -e 's/^#outfile = .*/outfile = SALIDA/' \
    -e 's/^treefile = /#treefile = /' -e 's/^#treefile = boot_/treefile = boot_/' \
    -e 's/^nthreads = 8/nthreads = 4/' config_cv_1.txt > config_fechado.txt
nano config_fechado.txt     # cambiar S por el smooth elegido; revisar que el treefile activo sea boot_enraizado_x10000.tre
```

**Prueba con una sola réplica**, para medir el tiempo por árbol y confirmar que lee las calibraciones:

```bash
head -n 1 boot_enraizado_x10000.tre > boot_prueba.tre
sed -e 's/^treefile = .*/treefile = boot_prueba.tre/' -e 's/^outfile = .*/outfile = fechado_prueba.tre/' config_fechado.txt > config_prueba.txt
sbatch ~/mi_proyecto/scripts/19_treepl.sh config_prueba.txt
```

`fechado_prueba.tre` debe existir y su raíz debe medir 271.2. El tiempo que tardó, multiplicado por 20, es lo que tardará cada bloque.

**Todos los bloques**, como arreglo de SLURM:

```bash
cd ~/mi_proyecto/results/especies_compuestas/fechado
split -l 20 -d -a 2 boot_enraizado_x10000.tre boot_bloque_

cat > ~/mi_proyecto/scripts/20_treepl_bloques.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=fechar
#SBATCH --partition=ib
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=5-00:00:00
#SBATCH --array=0-49%5
#SBATCH --output=/home/ib/csilva/mi_proyecto/logs/fechar_%A_%a.out
cd ~/mi_proyecto/results/especies_compuestas/fechado
B=$(printf "%02d" $SLURM_ARRAY_TASK_ID)
sed -e "s/^treefile = .*/treefile = boot_bloque_$B/" -e "s/^outfile = .*/outfile = fechados_$B.tre/" config_fechado.txt > config_bloque_$B.txt
cd ~/mi_proyecto
apptainer run --cleanenv --bind $PWD/results:/results \
  --pwd /results/especies_compuestas/fechado contenedores/treepl.sif config_bloque_$B.txt
EOF
sbatch ~/mi_proyecto/scripts/20_treepl_bloques.sh
```

Al terminar todos:

```bash
cd ~/mi_proyecto/results/especies_compuestas/fechado
ls fechados_*.tre | wc -l               # 50 bloques
cat fechados_*.tre > boot_fechados.tre
grep -c ";" boot_fechados.tre          # 1000
```

### Paso 8. Resumir con TreeAnnotator

Descargar `boot_fechados.tre` al laptop. En **Linux Mint**:

```bash
scp "csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/boot_fechados.tre" ~/Descargas/
```

En **Windows** (PowerShell):

```powershell
scp "csilva@atocatl-hpc.lamod.unam.mx:~/mi_proyecto/results/especies_compuestas/fechado/boot_fechados.tre" C:\Users\carla\Downloads\
```

Convertirlo a NEXUS en R:

```r
library(ape)
setwd("~/Descargas")                    # Linux Mint
# setwd("C:/Users/carla/Downloads")     # Windows: quita el # aquí y ponlo en la línea de arriba
f <- read.tree("boot_fechados.tre"); length(f)      # 1000
write.nexus(f, file = "boot_fechados.nex")
```

Resumir con TreeAnnotator (viene con BEAST 2): 0% de burn-in y alturas medias de nodo. En **Linux Mint** (si `treeannotator` no se encuentra, usa la ruta completa, por ejemplo `~/beast/bin/treeannotator`):

```bash
cd ~/Descargas
treeannotator -burnin 0 -heights mean boot_fechados.nex thelephorales_fechado.tre
```

En **Windows**, con la ventana de TreeAnnotator (menú Inicio → BEAST 2 → TreeAnnotator):

1. **Burnin percentage**: `0`.
2. **Node heights**: `Mean heights`.
3. **Input Tree File**: `C:\Users\carla\Downloads\boot_fechados.nex`.
4. **Output File**: `C:\Users\carla\Downloads\thelephorales_fechado.tre`.
5. **Run**.

O desde PowerShell (ajusta la ruta si instalaste BEAST 2 en otra carpeta):

```powershell
cd C:\Users\carla\Downloads
& "C:\Program Files\BEAST\bat\treeannotator.bat" -burnin 0 -heights mean boot_fechados.nex thelephorales_fechado.tre
```

Resultado: el cronograma con la edad media y el intervalo de 95% de cada nodo (`height_95%_HPD`), visible en FigTree. Los soportes UFBoot del `.treefile` original se pueden mostrar aparte o copiar a la figura.

## Lista de verificación y problemas frecuentes

- [ ] Árbol y matriz con 539 terminales y los mismos nombres (Paso 0)
- [ ] Todas las terminales de las calibraciones existen (Paso 0)
- [ ] `numsites = 5516` (Paso 1)
- [ ] `boot.boottrees` con 1000 árboles (Paso 2)
- [ ] Árbol ML y réplicas con el mismo enraizamiento y el mismo factor (Paso 3)
- [ ] Como mucho un mensaje `tiny branch` en prime (Paso 5)
- [ ] `opt`, `optad` y `optcvad` de la corrida con valores más bajos (Paso 5)
- [ ] `smooth` elegido con tres corridas de validación cruzada (Paso 6)
- [ ] Prueba con una réplica: raíz en 271.2 (Paso 7)
- [ ] `boot_fechados.tre` con 1000 árboles (Paso 7)

| Problema | Causa probable | Solución |
| --- | --- | --- |
| `root()` da error en R | El nombre del grupo externo no coincide con el árbol | Revisar que `externo` diga exactamente `Corticium_minnsiae` (comparar con `taxa_ml.txt`) |
| treePL no encuentra un `mrca` | Nombre de terminal mal escrito o ausente | Comparar con `taxa_ml.txt`; usar otra especie del mismo nodo |
| Muchos mensajes `tiny branch` | Factor insuficiente | Repetir el Paso 3 con un factor mayor (por ejemplo ×100 000) |
| El mejor `smooth` cae en `cvstop` | El óptimo está por debajo del rango probado | Repetir la validación cruzada con un rango más bajo |
| Una corrida de CV con chi² plano | El optimizador no convergió | No usarla; correr otra |
| El bootstrap pasa de 5 días | Límite de la partición `ib` | Reenviar `18_bootstrap_fechado.sh`; IQ-TREE continúa desde su checkpoint |
| Un bloque del arreglo falla | Error puntual o límite de tiempo | Revisar `logs/fechar_*_NN.out` y reenviar solo ese bloque con `sbatch --array=NN 20_treepl_bloques.sh` |

## Fuentes

- Maurin, K. J. L. (2020). [An empirical guide for producing a dated phylogeny with treePL in a maximum likelihood framework](https://doi.org/10.48550/arXiv.2008.07054). *arXiv* 2008.07054.
- [Flujo de trabajo: filogenia datada con treePL (thelephoraceae\_de\_america)](https://github.com/andreamackieg/thelephoraceae_de_america/blob/main/flujo_treepl_filogenia_fechada/README.md): fósiles de referencia y estructura de los pasos.
- Sánchez-García, M., et al. (2020). [Fruiting body form, not nutritional mode, is the major driver of diversification in mushroom-forming fungi](https://doi.org/10.1073/pnas.1922539117). *PNAS* 117(51): 32528–32534. Filogenia de referencia para la edad de la raíz (271.2 Ma) y las edades de validación; confirmar el valor en la figura.
- Smith et al. (2004), Gobo et al. (2025), Lepage et al. (1997), Knobloch y Kotlaba (1994) y Fleischmann et al. (2007): fósiles citados en el flujo de Thelephoraceae de América.
