#!/bin/bash

## Set template script:
templateScript=/home/lof/code/RNAseq_analysis/htseq-count/runHTSeq_count_template.sh
# templateScript=/toolbox/NGS/scripts/htseq-count/runHTSeq_count_template.sh

usage ()
{
  echo 'Usage : '
  echo '1. Go to the project directory.'
  echo '2. Run script as follows: '
  echo '   runHTSeq_count_all.sh --refGtf <location for reference the GTF file> (e.g. /genome/refGtf)'
  echo '                         --pid_fuid <PID,FUID> (e.g.Project_15903_FUID1025093-3)'
  echo '                         --regex_pattern_for_samplenames <pattern> (e.g.\./[US/-]{3}[0-9]{7})'
  echo '                         --stranded <yes or no: is this RNA-seq data strand specific?>'
  echo '                         --subdir <Default is "". Supply subdir name if there is any between samples and PID dir>'
  echo '                                   e.g. if sample is under: */Project_16038_FUID1026031/tophat/ instead of'
  echo '                                        */Project_16038_FUID1026031/, then tophat should be supplied here.'
  echo '                         --altalignedbamformat <default is "">. Supply if the aligned bam file format is not'
  echo '                                               [US barcode].bam. e.g. tophat output is accepted_hits.bam'
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
    -g|--refGtf)
      refGtf="$2"
      shift # past argument
    ;;
    -i|--pid_fuid)
      pid_fuid="$2"
      shift # past argument
    ;;
    -p|--regex_pattern_for_samplenames)
      regex_pattern_for_samplenames="$2"
      shift # past argument
    ;;
    -s|--stranded)
      ifstranded="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=yes
    ;;

    -d|--subdir)
      subdir="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=""
    ;;

    -f|--altalignedbamformat)
      altalignedbamformat="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=""
    ;;

    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

echo "refGtf  = ${refGtf}"
echo "PID,FUID = ${pid_fuid}"
echo "regex_pattern_for_samplenames = ${regex_pattern_for_samplenames}"
echo "Is this RNA-seq data stranded ? ${ifstranded}"
echo "Sub directory name if exists = ${subdir}"
echo "Alternative aligned bam file format? ${altalignedbamformat}"


##############################################################################
PROJ_DIR=`pwd`
cd $PROJ_DIR

## Create htseq-count directory and copy template htseq-count
## scripts to this directory
HTSEQCOUNT_DIR=${PROJ_DIR}/secondary_analysis/htseq-count
mkdir -p "${HTSEQCOUNT_DIR}/counts" "${HTSEQCOUNT_DIR}/scripts" "${HTSEQCOUNT_DIR}/log"

cp $templateScript "${HTSEQCOUNT_DIR}/scripts"
templateScript="${HTSEQCOUNT_DIR}/scripts/runHTSeq_count_template.sh"
thisProj_templateScript="${HTSEQCOUNT_DIR}/scripts/runHTSeq_count_template_thisProj.sh"

## Create script:
cat $templateScript | sed -e "s|TOBEREPLACEDTO_PROJECTDIRECTORY|$PROJ_DIR|" \
| sed -e "s|TOBEREPLACEDTO_PID_FUID|$pid_fuid|" \
| sed -e "s|TOBEREPLACEDTO_REFGTF|$refGtf|" \
| sed -e "s|TOBEREPLACEDTO_IFSTRANDED|$ifstranded|" \
| sed -e "s|TOBEREPLACEDTO_ALTALIGNEDBAMFORMAT|$altalignedbamformat|" \
> $thisProj_templateScript


dirArray=( $( find -regextype posix-egrep -maxdepth 1 -mindepth 1 -type d -regex $regex_pattern_for_samplenames) )
for d in ${dirArray[@]}
do
    echo $d
    cd $d
    thisdir=`pwd`

    if [ "$subdir" == "" ] # check to see if there is subdirectory. Default is no
      then
        sample=`echo $thisdir | sed -e "s/.*$pid_fuid\///"`
      else
        sample=`echo $thisdir | sed -e "s/.*$pid_fuid\///" | sed -e "s/$subdir\///"`
    fi
    echo $sample
    cat $thisProj_templateScript | sed -e "s/XXXXX/${sample}/" > \
        "${HTSEQCOUNT_DIR}/scripts/runHTSeq_count_${sample}.sh"
    dos2unix "${HTSEQCOUNT_DIR}/scripts/runHTSeq_count_${sample}.sh"
    qsub "${HTSEQCOUNT_DIR}/scripts/runHTSeq_count_${sample}.sh"
    sleep 8
    cd ..
done
