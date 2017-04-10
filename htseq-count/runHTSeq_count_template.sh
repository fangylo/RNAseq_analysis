#!/bin/bash
#$-S /bin/bash
#$-cwd
#$-l mf=2G
#$-pe smp 2
#$-j y
#$-o TOBEREPLACEDTO_PROJECTDIRECTORY/secondary_analysis/htseq-count/log/htseqCount_XXXXX.out
#$-e TOBEREPLACEDTO_PROJECTDIRECTORY/secondary_analysis/htseq-count/log/htseqCount_XXXXX.err
#$ -N htsc

export PATH=/toolbox/NGS/source_repository/samtools-1.1:/toolbox/NGS/python2.7.3/bin:$PATH
# export PATH=/toolbox/NGS/source_repository/samtools-1.1:/toolbox/NGS/python2.7.9/bin:$PATH
# source /SequenceData/In_Process/FYL/.bash_profile_brew
# unset PYTHONPATH

echo "username="$USER
echo "hostname="`hostname`

########################
## Set parameters     ##
########################
pid_fuid=TOBEREPLACEDTO_PID_FUID
proj_dir=TOBEREPLACEDTO_PROJECTDIRECTORY
ifstranded=TOBEREPLACEDTO_IFSTRANDED
alignedbamformat=TOBEREPLACEDTO_ALTALIGNEDBAMFORMAT
refGtf=TOBEREPLACEDTO_REFGTF
htseqcount_dir=${proj_dir}/secondary_analysis/htseq-count
samoutFile=${htseqcount_dir}/log/samout_XXXXX.samout
sample=XXXXX
#######################
# Set up directories  #
#######################
thisdir=`pwd`

echo "sample: "$sample

# If there is alternative aligned bam file format to be used rather then sample.bam?
if [ "$alignedbamformat" == "" ] # check to see if there is subdirectory. Default is no
    then
    aligned_bam=`echo $sample".bam"`
    else
    aligned_bam=$alignedbamformat
fi

#### File names:
htseqCountOutput=`echo "htseq.count.out_"$sample"_refGeneGTF.txt"`


############################################
#### Convert sam file to bam file first:
############################################
if [ `find ./ -maxdepth 1 -mindepth 1 -name $aligned_bam |wc -l` -eq 0 ] # check to see if the file already exists
    then
    echo "No "$aligned_bam" found."
    # samtools view -bS  $aligned_sam > $aligned_bam
fi

######################################################################
#### Check to see if the aligned bam file is cooredinate sorted:
######################################################################
# samtools view -H accepted_hits.bam|grep "SO:coordinate"| wc -l
if [ `samtools view -H $aligned_bam|grep "SO:coordinate"| wc -l` -eq 0 ]
    then
    echo "$aligned_bam is not coordinate sorted."
fi
# ##########################################################
# #### Convert the coordinate sorted bam file to sam:
# ##########################################################
# if [ `find ./ -maxdepth 1 -mindepth 1 -name $aligned_sam |wc -l` -eq 0 ] # check to see if the file already exists
#     then
#     echo "Processing samtools view. Input:"$aligned_bam", output:"$aligned_sam
#     echo "Current time:"`date +"%x-%X"`
#     samtools view $aligned_bam > $aligned_sam
#     if [ $? -eq 0 ]
#         then
#         echo "samtools view okay"
#     fi
#     echo "Current time:"`date +"%x-%X"`
# fi

#######################
#### Htseq-count:
#######################
numres=`find  ${htseqcount_dir}/counts -name $htseqCountOutput -type f |wc -l`
if [ $numres -eq 0 ]
    then
    echo "Processing htseq-count"
    echo "Current time:"`date +"%x-%X"`
    python -m HTSeq.scripts.count -m union \
        -s $ifstranded \
        -f bam \
        -r pos \
        $aligned_bam \
        $refGtf\
        > "${htseqcount_dir}/counts/${htseqCountOutput}"
    if [ $? -eq 0 ]
    then
    echo "htseq-count okay"
    echo "Current time:"`date +"%x-%X"`

    echo "algorithm:
    HTSeq-0.6.0
    python version: `which python`
    gtf file: $refGtf
    options:
    python -m HTSeq.scripts.count -m union -s $ifstranded -r pos -f bam
    -o $samoutFile $aligned_bam $refGtf>
    ${htseqcount_dir}/counts/${htseqCountOutput}"

fi
else
    echo "${htseqcount_dir}/counts/${htseqCountOutput}" exists
fi
