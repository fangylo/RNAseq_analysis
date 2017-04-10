#!/bin/bash
#$-S /bin/bash
#$-cwd
#$-l mf=2G
#$-pe smp 2
#$-j y
#$-o TOBEREPLACEDTO_PROJECTDIRECTORY/htseq-count/log/htseqCount_XXXXX.out
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
refGtf=TOBEREPLACEDTO_REFGTF
samoutFile=TOBEREPLACEDTO_PROJECTDIRECTORY/htseq-count/log/samout_XXXXX.samout
ifstranded=TOBEREPLACEDTO_IFSTRANDED
alignedbamformat=TOBEREPLACEDTO_ALTALIGNEDBAMFORMAT
#######################
# Set up directories  #
#######################
thisdir=`pwd`
# sample=`echo $thisdir | sed -e "s/.*$pid_fuid\///"`
sample=XXXXX
echo "sample: "$sample

# If there is alternative aligned bam file format to be used rather then sample.bam?
if [ "$alignedbamformat" == "" ] # check to see if there is subdirectory. Default is no
      then
        aligned_bam=`echo $sample".bam"`
      else
        aligned_bam=$alignedbamformat
    fi

#### File names:
nsorted_aligned_bam_prefix=`echo $sample"_nsorted"`
nsorted_aligned_bam=`echo $sample"_nsorted.bam"`
nsorted_aligned_sam=`echo $sample"_nsorted.sam"`
htseqCountOutput=`echo "htseq.count.out_"$sample"_refGeneGTF.txt"`


############################################
#### Convert sam file to bam file first:
############################################
if [ `find ./ -maxdepth 1 -mindepth 1 -name $aligned_bam |wc -l` -eq 0 ] # check to see if the file already exists
    then
    echo "No "$aligned_bam" found."
    # samtools view -bS  $aligned_sam > $aligned_bam
fi

###################################
#### Sort the bam file by name:
###################################
if [ `find ./ -maxdepth 1 -mindepth 1 -name $nsorted_aligned_bam |wc -l` -eq 0 ] # check to see if the file already exists
    then
    echo "Processing samtools sort. Input:"$aligned_bam", output:"$nsorted_aligned_bam
    samtools sort -n $aligned_bam $nsorted_aligned_bam_prefix
    if [ $? -eq 0 ]
        then
        echo "samtools n sort okay"
    fi
fi
##############################################
#### Convert the name sorted bam file to sam:
##############################################
if [ `find ./ -maxdepth 1 -mindepth 1 -name $nsorted_aligned_sam |wc -l` -eq 0 ] # check to see if the file already exists
    then
    echo "Processing samtools view. Input:"$nsorted_aligned_bam", output:"$nsorted_aligned_sam
    echo "Current time:"`date +"%x-%X"`
    samtools view $nsorted_aligned_bam > $nsorted_aligned_sam
    if [ $? -eq 0 ]
        then
        echo "samtools view okay"
    fi
    echo "Current time:"`date +"%x-%X"`
fi

#######################
#### Htseq-count:
#######################
numres=`find TOBEREPLACEDTO_PROJECTDIRECTORY/htseq-count/counts -name $htseqCountOutput -type f |wc -l`
if [ $numres -eq 0 ]
    then
    echo "Processing htseq-count"
    echo "Current time:"`date +"%x-%X"`
    python -m HTSeq.scripts.count -m union \
                              -s $ifstranded \
                              -r name \
                              $nsorted_aligned_sam \
                              $refGtf\
                              > TOBEREPLACEDTO_PROJECTDIRECTORY/htseq-count/counts/$htseqCountOutput
    if [ $? -eq 0 ]
    then
    echo "htseq-count okay"
    echo "Current time:"`date +"%x-%X"`

    echo "algorithm:
    HTSeq-0.6.0
    python version: `which python`
    gtf file: $refGtf
    options:
    python -m HTSeq.scripts.count -m union -s $ifstranded -r name
    -o $samoutFile $nsorted_aligned_sam $refGtf>
    TOBEREPLACEDTO_PROJECTDIRECTORY/htseq-count/counts/$htseqCountOutput"

fi
else
    echo TOBEREPLACEDTO_PROJECTDIRECTORY/htseq-count/counts/$htseqCountOutput exists
fi
