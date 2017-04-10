#!/bin/bash

## Set template script:
templateScript=/home/lof/code/RNAseq_analysis/JAFFA/runjaffa_template2.sh

usage ()
{
  echo 'Usage : '
  echo '1. Go to the project directory.'
  echo '2. Run script as follows: '
  echo '   runjaffa_singlesample.sh --samplebarcode <pattern> (e.g.US-1493187)'
  echo '                            --projectdirroot <e.g./SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672>'
  echo '                            --fastqdirroot <e.g./SequenceData/Data_Analysis/Project_15425_FUID1022672>'
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
    -s|--samplebarcode)
      samplebarcode="$2"
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

echo "samplebarcode=${samplebarcode}"
echo "projectdirroot=${projectdirroot}"
echo "fastqdirroot=${fastqdirroot}"
###############################################################################
## Set up directories
cd $projectdirroot
mkdir -p JAFFA/log JAFFA/scripts

## Set up this project template script:
cp $templateScript $projectdirroot"/JAFFA/scripts/"
templateScript=$projectdirroot"/JAFFA/scripts/runjaffa_template2.sh"

## Create script:
thisSample_templateScript=$projectdirroot"/JAFFA/scripts/runjaffa_template_"$samplebarcode".sh"
cat $templateScript | sed -e "s|TOBEREPLACEDTO_SAMPLEBARCODE|$samplebarcode|" \
| sed -e "s|TOBEREPLACEDTO_FASTQDIRROOT|$fastqdirroot|" \
| sed -e "s|TOBEREPLACEDTO_ANALYSIS_PROJDITROOT|$projectdirroot|" \
> $thisSample_templateScript

# echo $thisSample_templateScript
echo "samplecode="$samplebarcode
dos2unix $thisSample_templateScript
qsub $thisSample_templateScript
