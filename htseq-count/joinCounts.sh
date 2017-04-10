htseqcount_countdir=/SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count/counts
cd $htseqcount_countdir
python /home/lof/code/RNAseq_analysis/htseq-count/joinCounts.py "htseqcount_all.txt" htseq.count.out_*

head -1 htseqcount_all.txt| sed 's/htseq.count.out_//g' | sed 's/_refGeneGTF.txt//g' > htseqcount_all_tmp.txt
awk '!/^__/' htseqcount_all.txt | tail -n+2 >> htseqcount_all_tmp.txt
mv htseqcount_all_tmp.txt htseqcount_all.txt

