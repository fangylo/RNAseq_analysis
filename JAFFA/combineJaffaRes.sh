jaffaDir=/SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672/JAFFA
cd $jaffaDir

# Set result file:
resultfile=$jaffaDir/combined_jaffares.csv
result_numfile=$jaffaDir/num_fusion.txt

# Combine all jaffa results:
head -1 US-1494958/jaffa_results.csv > $resultfile


dirarray=( $(find -maxdepth 1 -mindepth 1 -type d -name "US*") )


for d in ${dirarray[@]}
do
    cd $d
    if [ `find -name "jaffa_results.csv"| wc -l` == 1 ]; then
        # Jaffa results found.
        # echo $d
        tail -n +2 jaffa_results.csv >> $resultfile
        num=`wc -l jaffa_results.csv`
        echo $d$'\t'$num >> $result_numfile
    else
        echo "No jaffa_results.csv found for "$d
    fi
    cd ..
done