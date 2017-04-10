jaffaDir=/SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672/JAFFA
cd $jaffaDir
## Get sample barcodes:
dirarray=( $(find -maxdepth 1 -mindepth 1 -type d -name "US*") )

for d in ${dirArray[@]}
do
    cd $d
    if [ `find -name "jaffa_results.csv"| wc -l` == 0 ]; then
        echo "Directory="$d", no jaffa_results found"
    fi
    cd ..
done
# Directory=./US-1493179, no jaffa_results found
# Directory=./US-1493200, no jaffa_results found
# Directory=./US-1492043, no jaffa_results found
# Directory=./US-1492026, no jaffa_results found
# Directory=./US-1493187, no jaffa_results found


## Rerun:
projdir=/SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672
fastqdir=/SequenceData/Data_Analysis/Project_15425_FUID1022672

samplebarcode=US-1493187

sh /home/lof/code/RNAseq_analysis/JAFFA/runjaffa_singlesample.sh \
-s $samplebarcode \
-d $projdir \
-f $fastqdir


