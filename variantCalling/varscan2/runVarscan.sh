#!/bin/bash
#$-S /bin/bash
#$-cwd
#$ -j y
#$-l mf=8G
#$-pe smp 2
#$-o /SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672/varscan2/log/US-1493154.log
#$ -N varscan2

printf "username="$USER
printf "hostname="`hostname`
referenceFasta=/dev/shm/genomes/hg19/fasta/genome.fa
project_dir=/SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672


sample=US-1493154
cd $project_dir/$sample

printf "sample="$sample"\n"
###################
##  Run mpileup:
###################
if [ `find ./ -maxdepth 1 -mindepth 1 -name $sample.mpileup |wc -l` -eq 0 ] # check to see if the file already exists
    then
    printf "\nRun samtools mpileup:\n"
    /toolbox/NGS/source_repository/samtools-1.2/samtools mpileup \
    -B -q 1 \
    -f $referenceFasta \
    $sample.bam > $sample.mpileup
fi

# sed -n '/\t0\t/!p' $sample.mpileup > $sample.mpileup2
# mv $sample.mpileup2 $sample.mpileup

###################
##  Run VarScan:
###################
if [ `find ./ -maxdepth 1 -mindepth 1 -name $sample.varScan.snp |wc -l` -eq 0 ] # check to see if the file already exists
    then
    printf "\nRun mpileup2snp:\n"
    java -jar /toolbox/NGS/varscan_v2.3.9/VarScan.v2.3.9.jar mpileup2snp $sample.mpileup \
    --mincoverage 8 \
    --min-var-freq 0.20 \
    --p-value 0.1 \
    >$sample.varScan.snp
fi

if [ `find ./ -maxdepth 1 -mindepth 1 -name $sample.varScan.snp |wc -l` -eq 0 ] # check to see if the file already exists
    then
    printf "\nRun mpileup2snp:\n"
    java -jar /toolbox/NGS/varscan_v2.3.9/VarScan.v2.3.9.jar mpileup2snp $sample.mpileup \
    --mincoverage 8 \
    --min-var-freq 0.20 \
    --p-value 0.1 \
    >$sample.varScan.snp
fi

if [ `find ./ -maxdepth 1 -mindepth 1 -name $sample.varScan.indel |wc -l` -eq 0 ] # check to see if the file already exists
    then
    printf "\nRun mpileup2indel\n"
    java -jar /toolbox/NGS/varscan_v2.3.9/VarScan.v2.3.9.jar mpileup2indel $sample.mpileup \
    --mincoverage 8 \
    --min-var-freq 0.10 \
    --p-value 0.1 \
    >$sample.varScan.indel
fi

printf "\nRun varscan filter\n"
java -jar /toolbox/NGS/varscan_v2.3.9/VarScan.v2.3.9.jar \
filter $sample.varScan.snp \
--indel-file $sample.varScan.indel \
--output-file $sample.varScan.snp.filter

###################
##  Filtering:
###################
printf "\nRun bam-readcount\n"
/toolbox/NGS/source_repository/bam-readcount/bin/bam-readcount \
-q 1 -b 20 \
-f $referenceFasta \
-l $sample.varScan.snp $sample.bam \
> $sample.varScan.snp.readcounts

printf "\nRun fpfilter.pl\n"
perl /toolbox/NGS/varscan_v2.3.9/fpfilter.pl \
$sample.varScan.snp $sample.varScan.snp.readcounts \
-output-basename $sample.varScan.snp.filter