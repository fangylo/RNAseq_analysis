#!/bin/bash
#$-S /bin/bash
#$-cwd
#$-l mf=8G
#$-pe smp 10
#$-j y
#$-o TOBEREPLACEDTO_PROJECTDIRECTORY/secondary_analysis/featurecount/log/featurecount_XXXXX.out
#$-e TOBEREPLACEDTO_PROJECTDIRECTORY/secondary_analysis/featurecount/log/featurecount_XXXXX.err
#$ -N ftcount


# export PATH=/toolbox/NGS/source_repository/samtools-1.1:/toolbox/NGS/python2.7.9/bin:$PATH
# source /SequenceData/In_Process/FYL/.bash_profile_brew
# unset PYTHONPATH

export PATH=/toolbox/NGS/source_repository/samtools-1.1:/toolbox/NGS/python2.7.3/bin:$PATH
echo "username="$USER
echo "hostname="`hostname`

########################
## Set parameters     ##
########################
PROJ_DIR=TOBEREPLACEDTO_PROJECTDIRECTORY
pid_fuid=TOBEREPLACEDTO_PID_FUID
refGtf=TOBEREPLACEDTO_REFGTF
alignedbamformat=TOBEREPLACEDTO_ALTALIGNEDBAMFORMAT
isStrandSpecific=TOBEREPLACEDTO_ISSTRANDSPECIFIC
threadcount=TOBEREPLACEDTO_THREADCOUNT
isPairedEnd=TOBEREPLACEDTO_ISPAIREDEND

FEATURECOUNT_DIR="${PROJ_DIR}/secondary_analysis/featurecount"
FEATURECOUNT="/toolbox/NGS/source_repository/subread-1.5.0-p2-Linux-x86_64/bin/featureCounts"
SAMPLE=XXXXX
#######################
# Set up directories  #
#######################
thisdir=`pwd`
# echo "sample: "${SAMPLE}
outputcountfile="${SAMPLE}_featureCounts.txt"

# If there is alternative aligned bam file format to be used rather then sample.bam?
if [ "$alignedbamformat" == "" ] # check to see if there is subdirectory. Default is no
    then
    aligned_bam=`echo ${SAMPLE}".bam"`
    else
    aligned_bam=$alignedbamformat
fi

#####################
# Run Featurecount  #
#####################
numres=`find ${FEATURECOUNT_DIR}/counts -name $outputcountfile -type f |wc -l`
if [ $numres -eq 0 ]
    then
    echo "Processing featurecount:"
    echo "Current time:"`date +"%x-%X"`

    if [ $isPairedEnd == "yes" ]; then
        ${FEATURECOUNT} \
            -a ${refGtf} \
            -o "${FEATURECOUNT_DIR}/counts/${outputcountfile}" \
            -p \
            -s ${isStrandSpecific} \
            -T ${threadcount} \
             ${aligned_bam}
        if [ $? -eq 0 ]; then
            echo "featurecount okay"
            echo "Current time:"`date +"%x-%X"`

            echo "algorithm:
            ${FEATURECOUNT}
            gtf file: ${refGtf}
            options:
            ${FEATURECOUNT} \
                -a ${refGtf} -o ${FEATURECOUNT_DIR}/counts/${outputcountfile} -p -s ${isStrandSpecific} -T ${threadcount} ${aligned_bam}"
        fi
    elif [ $isPairedEnd == "no" ]; then
        ${FEATURECOUNT} \
            -a ${refGtf}  \
            -o "${FEATURECOUNT_DIR}/counts/${outputcountfile}" \
            -s ${isStrandSpecific} \
            -T ${threadcount} \
             ${aligned_bam}
        if [ $? -eq 0 ]; then
            echo "featurecount okay"
            echo "Current time:"`date +"%x-%X"`

            echo "algorithm:
            /toolbox/NGS/source_repository/subread-1.5.0-p2-Linux-x86_64/bin/featureCounts
            gtf file: ${refGtf}
            options:
            ${FEATURECOUNT} \
                -a ${refGtf} -o ${FEATURECOUNT_DIR}/counts/${outputcountfile} -s ${isStrandSpecific} -T ${threadcount} ${aligned_bam}"
        fi
    else
        echo "Need yes or no for isPairedEnd option"
    fi

else
    echo "${FEATURECOUNT_DIR}/counts/${outputcountfile} exists"
fi
