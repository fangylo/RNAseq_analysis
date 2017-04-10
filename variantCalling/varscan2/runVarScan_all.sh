#!/usr/bin/bash

## Set template script:
# templateScript=/home/lof/code/RNAseq_analysis/htseq-count/runHTSeq_count_template.sh
templateScript=/home/lof/code/RNAseq_analysis/variantCalling/varscan2/runVarScan_template.sh

usage ()
{
  echo 'Usage : '
  echo '1. Go to the project directory.'
  echo '2. Run script as follows: '
  echo '   runVarScan_all.sh --refFastaFile <location for reference fasta file>'
  echo '                                    (e.g. /dev/shm/genomes/hg19/fasta/genome.fa)'
  echo '                     --pid_fuid <PID,FUID> (e.g.Project_15903_FUID1025093-3)'
  echo '                     --regex_pattern_for_samplenames <pattern> (e.g.\./[US/-]{3}[0-9]{7})'
  echo '                     --subdir <Default is "". Supply subdir name if there is any between samples and PID dir>'
  echo '                              e.g. if sample is under: */Project_16038_FUID1026031/tophat/ instead of'
  echo '                                   */Project_16038_FUID1026031/, then tophat should be supplied here.'
  echo '                     --altalignedbamformat <default is "">. Supply if the aligned bam file format is not'
  echo '                                           [US barcode].bam. e.g. tophat output is accepted_hits.bam'
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
    -f|--refFastaFile)
      refFastaFile="$2"
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
    -d|--subdir)
      subdir="$2"
      shift # past argument
    ;;
    --default)
    DEFAULT=""
    ;;

    -f|--alignedbamformat)
      alignedbamformat="$2"
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

echo "refFastaFile  = ${refFastaFile}"
echo "PID,FUID = ${pid_fuid}"
echo "regex_pattern_for_samplenames = ${regex_pattern_for_samplenames}"
echo "Is this RNA-seq data stranded ? ${ifstranded}"
echo "Sub directory name if exists = ${subdir}"
echo "Alternative aligned bam file format? ${alignedbamformat}"


##############################################################################
proj_dir=`pwd`
cd $proj_dir

## Create htseq-count directory and copy template htseq-count
## scripts to this directory
mkdir -p htseq-count/counts htseq-count/log htseq-count/scripts

cp $templateScript $proj_dir"/htseq-count/"
templateScript=$proj_dir"/htseq-count/runHTSeq_count_template.sh"
thisProj_templateScript=$proj_dir"/htseq-count/runHTSeq_count_template_thisProj.sh"

## Create script:
cat $templateScript | sed -e "s|TOBEREPLACEDTO_REFFASTAFILE|$refFastaFile|" \
| sed -e "s|TOBEREPLACEDTO_PID_FUID|$pid_fuid|" \
| sed -e "s|TOBEREPLACEDTO_REFGTF|$refGtf|" \
| sed -e "s|TOBEREPLACEDTO_IFSTRANDED|$ifstranded|" \
| sed -e "s|TOBEREPLACEDTO_ALTALIGNEDBAMFORMAT|$alignedbamformat|" \
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
    cat $thisProj_templateScript | sed -e "s/XXXXX/$sample/" > \
        $proj_dir/htseq-count/scripts/runHTSeq_count_$sample.sh
    dos2unix $proj_dir/htseq-count/scripts/runHTSeq_count_$sample.sh
    qsub $proj_dir/htseq-count/scripts/runHTSeq_count_$sample.sh
    sleep 25
    cd ..
done