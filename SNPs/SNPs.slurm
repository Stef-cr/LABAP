#!/bin/bash
#SBATCH --job-name=SNPs_cafe
#SBATCH --output=CaraHiFi_SNPs.txt
#SBATCH --ntasks=1
#SBATCH --time=164:00:00
#SBATCH --partition=kura-long

. /opt/Modules/3.2.10/init/sh

### Pipeline analysis for single-sample paired-end Reads ### 
### Determination of genetic diversity in plants using Illumina sequencing data ###

module load bowtie2/2.5.0 
module load TrimGalore/0.4.3
module load cutadapt/Python3.5-1.9.1 
module load samtools/1.9
module load jdk/1.8.0_151 # Required to run GATK, otherwise throws an error
module load picard/2.18.9
module load bwa/0.7.17
module load miniconda/gatk
module load snpEff/5.0e

# ==========================================
# DEFINITION OF VARIABLES & SAMPLE INPUTS
# ==========================================
SAMPLE_ID="file"
R1="file_1.fq.gz"
R2="file_2.fq.gz"
REF="Cara_HiFi/ET39_HiFi_processed.fasta"
GATK_JAR="/opt/bioinf/gatk-4.2.0.0/gatk-package-4.2.0.0-local.jar"
PICARD_JAR="/opt/bioinf/picard-2.11.0/picard.jar"

# Ensure working directories exist
mkdir -p QC/ Esamples/

#%%%%%%%%%%%%% 1. CREATE INDEX 
bwa index $REF
samtools faidx $REF
java -jar $PICARD_JAR CreateSequenceDictionary R=$REF O=${REF%.*}.dict

#%%%%%%%%%%%%% 2. PERFORM TRIMMING
echo "========================== trimming $R1 and $R2 ============================"
trim_galore --paired --clip_R1 10 $R1 --clip_R2 10 $R2 --three_prime_clip_R1 5 $R1 --three_prime_clip_R2 5 $R2 --fastqc -o QC/

# Processed read filenames produced by TrimGalore for file_1 and file_2
R1_TRIM="QC/file_1_val_1.fq.gz"
R2_TRIM="QC/file_2_val_2.fq.gz"

#%%%%%%%%%%%%% 3. ALIGN TO REFERENCE
SAM_OUT="Esamples/${SAMPLE_ID}.sam"
echo "========================== aligning to index ============================"
bwa mem -K 100000000 -Y -t 4 -R "@RG\tID:${SAMPLE_ID}\tLB:${SAMPLE_ID}\tPL:ILLUMINA\tPM:HISEQ\tSM:${SAMPLE_ID}" $REF $R1_TRIM $R2_TRIM > $SAM_OUT

#%%%%%%%%%%%%% 4. MARK DUPLICATES AND SORT
BAM_DEDUP="Esamples/${SAMPLE_ID}_sortdedup_reads.bam"
METRICS_DEDUP="Esamples/${SAMPLE_ID}_dedup_metrics.txt"

java -jar $GATK_JAR MarkDuplicatesSpark \
    -I $SAM_OUT \
    -M $METRICS_DEDUP \
    -O $BAM_DEDUP

#%%%%%%%%%%%%% 5. ALIGNMENTS AND METRICS
java -jar $PICARD_JAR AlignmentSummaryMetrics \
    R=$REF \
    I=$BAM_DEDUP \
    O=Esamples/${SAMPLE_ID}_alignment_metrics.txt

java -jar $PICARD_JAR CollectInsertSizeMetrics \
    INPUT=$BAM_DEDUP \
    OUTPUT=Esamples/${SAMPLE_ID}_insert_metrics.txt \
    HISTOGRAM_FILE=Esamples/${SAMPLE_ID}_insert_size_histogram.pdf

samtools depth -a $BAM_DEDUP > Esamples/${SAMPLE_ID}_depth_out.txt

#%%%%%%%%%%%%% 6. CALL VARIANTS (RAW)
RAW_VCF="Esamples/${SAMPLE_ID}_raw_variants.vcf"

java -jar $GATK_JAR HaplotypeCaller \
    -R $REF \
    -I $BAM_DEDUP \
    -O $RAW_VCF

#%%%%%%%%%%%%% 7. SEPARATE SNPS AND INDELS
RAW_SNPS="Esamples/${SAMPLE_ID}_raw_snps.vcf"
RAW_INDELS="Esamples/${SAMPLE_ID}_raw_indels.vcf"

java -jar $GATK_JAR SelectVariants \
    -R $REF \
    -V $RAW_VCF \
    -select-type SNP \
    -O $RAW_SNPS

java -jar $GATK_JAR SelectVariants \
    -R $REF \
    -V $RAW_VCF \
    -select-type INDEL \
    -O $RAW_INDELS

#%%%%%%%%%%%%% 8. FILTER SNPS AND INDELS
FILTERED_SNPS="Esamples/${SAMPLE_ID}_filtered_snps.vcf"
FILTERED_INDELS="Esamples/${SAMPLE_ID}_filtered_indels.vcf"

echo "========================== filtering raw SNPs ============================"
java -jar $GATK_JAR VariantFiltration \
    -R $REF \
    -V $RAW_SNPS \
    -O $FILTERED_SNPS \
    -filter-name "QD_filter" -filter "QD < 2.0" \
    -filter-name "FS_filter" -filter "FS > 60.0" \
    -filter-name "MQ_filter" -filter "MQ < 40.0" \
    -filter-name "SOR_filter" -filter "SOR > 4.0" \
    -filter-name "MQRankSum_filter" -filter "MQRankSum < -12.5" \
    -filter-name "ReadPosRankSum_filter" -filter "ReadPosRankSum < -8.0"

echo "========================== filtering raw INDELs ============================"
java -jar $GATK_JAR VariantFiltration \
    -R $REF \
    -V $RAW_INDELS \
    -O $FILTERED_INDELS \
    -filter-name "QD_filter" -filter "QD < 2.0" \
    -filter-name "FS_filter" -filter "FS > 200.0" \
    -filter-name "SOR_filter" -filter "SOR > 10.0"

#%%%%%%%%%%%%% 9 & 10. EXCLUDE FILTERED VARIANTS
BQSR_SNPS="Esamples/${SAMPLE_ID}_bqsr_snps.vcf"
BQSR_INDELS="Esamples/${SAMPLE_ID}_bqsr_indels.vcf"

java -jar $GATK_JAR SelectVariants \
    --exclude-filtered \
    -V $FILTERED_SNPS \
    -O $BQSR_SNPS

java -jar $GATK_JAR SelectVariants \
    --exclude-filtered \
    -V $FILTERED_INDELS \
    -O $BQSR_INDELS

#%%%%%%%%%%%%% 11. BASE QUALITY SCORE RECALIBRATION (BQSR)
RECAL_TABLE="Esamples/${SAMPLE_ID}_recal_data.table"

echo "========================== recalibrating BQSR ============================"
java -jar $GATK_JAR BaseRecalibrator \
    -R $REF \
    -I $BAM_DEDUP \
    --known-sites $BQSR_SNPS \
    --known-sites $BQSR_INDELS \
    -O $RECAL_TABLE

#%%%%%%%%%%%%% 12. APPLY BQSR
RECAL_BAM="Esamples/${SAMPLE_ID}_recal_reads.bam"

echo "========================== applying recal bqsr ============================"
java -jar $GATK_JAR ApplyBQSR \
    -R $REF \
    -I $BAM_DEDUP \
    -bqsr $RECAL_TABLE \
    -O $RECAL_BAM

#%%%%%%%%%%%%% 13. CALL FILTERED AND RECALIBRATED VARIANTS
RAW_RECAL_VCF="Esamples/${SAMPLE_ID}_raw_variants_recal.vcf"

echo "========================== calling recalibrated variants ============================"
java -jar $GATK_JAR HaplotypeCaller \
    -R $REF \
    -I $RECAL_BAM \
    -O $RAW_RECAL_VCF

#%%%%%%%%%%%%% 14. SEPARATE RECALIBRATED SNPS AND INDELS
RAW_SNPS_RECAL="Esamples/${SAMPLE_ID}_raw_snps_recal.vcf"
RAW_INDELS_RECAL="Esamples/${SAMPLE_ID}_raw_indels_recal.vcf"

java -jar $GATK_JAR SelectVariants \
    -R $REF \
    -V $RAW_RECAL_VCF \
    -select-type SNP \
    -O $RAW_SNPS_RECAL

java -jar $GATK_JAR SelectVariants \
    -R $REF \
    -V $RAW_RECAL_VCF \
    -select-type INDEL \
    -O $RAW_INDELS_RECAL

#%%%%%%%%%%%%% 15. FILTER RECALIBRATED SNPS AND INDELS
FINAL_SNPS="Esamples/${SAMPLE_ID}_recal_filtered_snps.vcf"
FINAL_INDELS="Esamples/${SAMPLE_ID}_recal_filtered_indels.vcf"

java -jar $GATK_JAR VariantFiltration \
    -R $REF \
    -V $RAW_SNPS_RECAL \
    -O $FINAL_SNPS \
    -filter-name "QD_filter" -filter "QD < 2.0" \
    -filter-name "FS_filter" -filter "FS > 60.0" \
    -filter-name "MQ_filter" -filter "MQ < 40.0" \
    -filter-name "SOR_filter" -filter "SOR > 4.0" \
    -filter-name "MQRankSum_filter" -filter "MQRankSum < -12.5" \
    -filter-name "ReadPosRankSum_filter" -filter "ReadPosRankSum < -8.0"

java -jar $GATK_JAR VariantFiltration \
    -R $REF \
    -V $RAW_INDELS_RECAL \
    -O $FINAL_INDELS \
    -filter-name "QD_filter" -filter "QD < 2.0" \
    -filter-name "FS_filter" -filter "FS > 200.0" \
    -filter-name "SOR_filter" -filter "SOR > 10.0"

#%%%%%%%%%%%%% 16. RUN SNPEFF
# 17.1 Generate database: make sure fasta headers match GTF and reference fasta
# 17.2 Create folder with genome name and add sequence.fa and gtf.fa (GTF format)
# 17.3 Edit config file right after line 40 to add the custom genome entry
# 17.4 Build database:
# java -jar snpEff.jar -build gtf22 Coffee 

# 16.5 Run annotation analysis
java -jar snpEff.jar Coffee -v -htmlStats Esamples/${SAMPLE_ID}_summary.html $FINAL_SNPS > Esamples/${SAMPLE_ID}_ann.vcf
