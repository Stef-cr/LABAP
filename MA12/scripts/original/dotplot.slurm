#!/bin/bash
#SBATCH --job-name=mummer
#SBATCH --output=mum.txt
#SBATCH --ntasks=1
#SBATCH --time=744:00:00
#SBATCH --partition=dribe-long
#SBATCH --mem=500G
#SBATCH --cpus-per-task=20

. /opt/Modules/3.2.10/init/sh

module load mummer/4.0.0beta2

# 1. Alinear genomas (genoma de referencia, genoma a comparar)
nucmer --prefix=were_ma12 p_werel.fasta Results_MA12/MA12_medusa.fasta

# 2. Filtrar alineamientos 1-to-1
delta-filter -1 were_ma12.delta > were_ma12.filter
show-coords -rcl were_ma12.filter > were_ma12.coords

# 3. Generar coordenadas legibles
show-aligns were_ma12.filter p_werel.fasta Results_MA12/MA12_medusa.fasta > were_ma12.aligns

#4. Mummerplot para generar el dotplot
echo "4. Generando dotplot..."
if command -v gnuplot &> /dev/null; then
    mummerplot were_ma12.filter -R p_werel.fasta -Q Results_MA12/MA12_medusa.fasta --filter --layout -b
    echo "✓ Dotplot generado: were_ma12*.png"
else
    echo "⚠ Gnuplot no encontrado. Generando archivos para visualización manual..."
    mummerplot were_ma12.filter -R p_werel.fasta -Q Results_MA12/MA12_medusa.fasta --filter --layout
    echo "Usa: gnuplot were_ma12.gp"
fi