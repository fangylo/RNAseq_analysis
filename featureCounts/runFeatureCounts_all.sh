#!/bin/bash

## Set template script:
templateScript=/home/lof/code/RNAseq_analysis/featureCounts/runFeatureCounts_template.sh
# templateScript=/toolbox/NGS/scripts/htseq-count/runFeatureCounts_template.sh
# templateScript=/SequenceData/In_Process/FYL/featureCounts/runFeatureCounts_template.sh

usage ()
{
  echo '''Usage :
       1. Go to the project directory.
       2. Run script as follows:
          runFeatureCounts_all.sh --refGtf <location for reference the GTF file> (e.g. /genome/refGtf)
                                  --pid_fuid <PID,FUID> (e.g.Project_15903_FUID1025093-3)
                                  --regex_pattern_for_samplenames <pattern> (e.g.\./[US/-]{3}[0-9]{7})
                                  --subdir <Default is "". Supply subdir name if there is any between samples and PID dir>
                                            e.g. if sample is under: */Project_16038_FUID1026031/tophat/ instead of
                                                 */Project_16038_FUID1026031/, then tophat should be supplied here.
                                  --altalignedbamformat <default is "">. Supply if the aligned bam file format is not
                                                      [US barcode].bam. e.g. tophat output is accepted_hits.bam
                                  --isStrandSpecific:Indicate if strand-specific read counting should be performed.
                                                     It has three possible values: 0 (unstranded), 1 (stranded) and
                                                     2 (reversely stranded). 0 by default.
                                  --threadcount: Number of the threads. The value should be between 1 and 32. Default 1
                                  --isPairedEnd: yes or no. Default is yes.
          Note:
            All samples to be processed should be found using the above pattern by:
            find -regextype posix-egrep -maxdepth 1 -mindepth 1 -type d -regex $regex_pattern_for_samplenames

          Run example:
          cd /SequenceData/In_Process/HiSeq/rnaseq_processing/1112_Lilly/Project_16411_FUID1029081/tophat
          runFeatureCounts_all.sh \
            --refGtf /toolbox/NGS/genomes/rn5/annotations/refGene.gtf \
            --pid_fuid Project_16411_FUID1029081 \
            --regex_pattern_for_samplenames \./[US/-]{3}[0-9]{7} \
            --isStrandSpecific 2 \
            --threadcount 10 \
            --isPairedEnd yes \
            --subdir tophat \
            --altalignedbamformat accepted_hits.bam
           '''
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
    -r|--regex_pattern_for_samplenames)
      regex_pattern_for_samplenames="$2"
      shift # past argument
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

    -s|--isStrandSpecific)
      isStrandSpecific="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=0
    ;;

    -t|--threadcount)
      threadcount="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=1
    ;;

    -p|--isPairedEnd)
      isPairedEnd="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=yes
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
echo "Sub directory name if exists = ${subdir}"
echo "Alternative aligned bam file format? ${altalignedbamformat}"
echo "Strand specific= ${isStrandSpecific}"
echo "Thread count= ${threadcount}"
echo "Is it paired end? ${isPairedEnd}"
##############################################################################
PROJ_DIR=`pwd`
cd $PROJ_DIR
echo $PROJ_DIR

## Create htseq-count directory and copy template featurecount
## scripts to this directory
FEATURECOUNT_DIR=${PROJ_DIR}/secondary_analysis/featurecount
mkdir -p "${FEATURECOUNT_DIR}/counts" "${FEATURECOUNT_DIR}/scripts" "${FEATURECOUNT_DIR}/log"

cp $templateScript "${FEATURECOUNT_DIR}/scripts"
templateScript="${FEATURECOUNT_DIR}/scripts/runFeatureCounts_template.sh"
thisProj_templateScript="${FEATURECOUNT_DIR}/scripts/runFeatureCounts_template_thisProj.sh"

## Create script:
cat $templateScript | sed -e "s|TOBEREPLACEDTO_PROJECTDIRECTORY|$PROJ_DIR|" \
| sed -e "s|TOBEREPLACEDTO_PID_FUID|$pid_fuid|" \
| sed -e "s|TOBEREPLACEDTO_REFGTF|$refGtf|" \
| sed -e "s|TOBEREPLACEDTO_IFSTRANDED|$ifstranded|" \
| sed -e "s|TOBEREPLACEDTO_ALTALIGNEDBAMFORMAT|$altalignedbamformat|" \
| sed -e "s|TOBEREPLACEDTO_ISSTRANDSPECIFIC|$isStrandSpecific|" \
| sed -e "s|TOBEREPLACEDTO_THREADCOUNT|$threadcount|" \
| sed -e "s|TOBEREPLACEDTO_ISPAIREDEND|$isPairedEnd|" \
> ${thisProj_templateScript}


dirArray=( $( find -regextype posix-egrep -maxdepth 1 -mindepth 1 -type d -regex $regex_pattern_for_samplenames) )
for d in ${dirArray[@]}
do
    echo $d
    cd $d
    thisdir=`pwd`
    echo $thisdir

    if [ "$subdir" == "" ] # check to see if there is subdirectory. Default is no
      then
        sample=`echo $thisdir | sed -e "s/.*$pid_fuid\///"`
      else
        sample=`echo $thisdir | sed -e "s/.*$pid_fuid\///" | sed -e "s/$subdir\///"`
    fi
    echo $sample
    cat ${thisProj_templateScript} | sed -e "s/XXXXX/${sample}/" > \
        "${FEATURECOUNT_DIR}/scripts/runFeatureCounts_${sample}.sh"
    dos2unix "${FEATURECOUNT_DIR}/scripts/runFeatureCounts_${sample}.sh"
    qsub "${FEATURECOUNT_DIR}/scripts/runFeatureCounts_${sample}.sh"
    sleep 8
    cd ..
done
