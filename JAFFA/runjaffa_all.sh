#!/bin/bash

## Set template script:
templateScript=/home/lof/code/RNAseq_analysis/JAFFA/runjaffa_template.sh

usage ()
{
  echo 'Usage : '
  echo '1. Go to the project directory.'
  echo '2. Run script as follows: '
  echo '   runjaffa_all.sh --regex_pattern_for_samplenames <pattern> (e.g.\./[US/-]{3}[0-9]{7})'
  echo '                   --projectdirroot <e.g./SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672>'
  echo '                   --fastqdirroot <e.g./SequenceData/Data_Analysis/Project_15425_FUID1022672>'
  echo '   Note: all samples to be processed should be found using the above pattern by:'
  echo '         find -regextype posix-egrep -maxdepth 1 -mindepth 1 -type d -regex $regex_pattern_for_samplenames'
  exit
}

while [[ $# > 0 ]]
do
  key="$1"
case $key in
    -h|--help)
      usage
      shift # past argument
    ;;
    -p|--regex_pattern_for_samplenames)
      regex_pattern_for_samplenames="$2"
      shift # past argument
    ;;
    -d|--projectdirroot)
      projectdirroot="$2"
      shift # past argument
    ;;
    -f|--fastqdirroot)
      fastqdirroot="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo "regex_pattern_for_samplenames=${regex_pattern_for_samplenames}"
echo "projectdirroot=${projectdirroot}"
echo "fastqdirroot=${fastqdirroot}"

###############################################################################
## Set up parameters
# regex_pattern_for_samplenames=\./[US/-]{3}[0-9]{7}
# fastqdirroot=/SequenceData/Data_Analysis/Project_15425_FUID1022672
# projectdirroot=/SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672

## Set up directories
cd $projectdirroot
mkdir -p JAFFA/log JAFFA/scripts

## Set up this project template script:
cp $templateScript $projectdirroot"/JAFFA/scripts/"
templateScript=$projectdirroot"/JAFFA/scripts/runjaffa_template.sh"


## Get sample barcodes:
dirArray=( $( find -regextype posix-egrep -maxdepth 1 -mindepth 1 \
             -type d -regex $regex_pattern_for_samplenames) )

for d in ${dirArray[@]}
do
    echo $d
    samplebarcode=`echo $d | sed -e "s/\.\///"`

    ## Create script:
    thisSample_templateScript=$projectdirroot"/JAFFA/scripts/runjaffa_template_"$samplebarcode".sh"
    cat $templateScript | sed -e "s|TOBEREPLACEDTO_SAMPLEBARCODE|$samplebarcode|" \
    | sed -e "s|TOBEREPLACEDTO_FASTQDIRROOT|$fastqdirroot|" \
    | sed -e "s|TOBEREPLACEDTO_ANALYSIS_PROJDITROOT|$projectdirroot|" \
    > $thisSample_templateScript

    echo $samplebarcode
    dos2unix $thisSample_templateScript
    qsub $thisSample_templateScript
    sleep 25
done