dos2unix /home/lof/code/RNAseq_analysis/htseq-count/runHTSeq_count_all.sh

cd /SequenceData/In_Process/HiSeq/rnaseq_processing/1112_Lilly/Project_16038_FUID1026031/tophat

# /home/lof/code/RNAseq_analysis/htseq-count/runHTSeq_count_all.sh \

/toolbox/NGS/scripts/htseq-count/runHTSeq_count_all.sh \
--refGtf /toolbox/NGS/genomes/hg19/annotations/refGene.gtf \
--pid_fuid Project_16038_FUID1026031 \
--regex_pattern_for_samplenames \./[US/-]{3}[0-9]{7} \
--stranded yes \
--subdir tophat \
--alignedbamformat accepted_hits.bam

# --regex_pattern_for_samplenames \./[US/-]{3}[0-9]{7} \
\./US-1600080
cd /SequenceData/In_Process/HiSeq/rnaseq_processing/1112_Lilly/Project_16038_FUID1026031/hisat2
/home/lof/code/RNAseq_analysis/htseq-count/runHTSeq_count_all.sh \
--refGtf /toolbox/NGS/genomes/hg19/annotations/refGene.gtf \
--pid_fuid Project_16038_FUID1026031 \
--regex_pattern_for_samplenames \./[US/-]{3}[0-9]{7} \
--stranded yes \
--subdir hisat2