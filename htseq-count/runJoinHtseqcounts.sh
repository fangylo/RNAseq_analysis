#!/bin/bash
#$-S /bin/bash
#$-cwd
#$-l mf=8G
#$-q new.q
#$-o /SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count/log/joinhtseqcount.out
#$-e /SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count/log/joinhtseqcount.err
#$ -N joinhtseqcounts

#### qsub /home/lof/code/htseq-count/runJoinHtseqcounts.sh
which python
echo $HOME
echo $USER

cd /SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count/counts/
python /home/lof/code/htseq-count/joinCounts.py "htseqcount_all.txt" htseq.count.out_*
