#!/bin/bash
#$-S /bin/bash
#$-cwd
#$-l mf=2G
#$-pe smp 2
#$-e /SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672/JAFFA/log/TOBEREPLACEDTO_SAMPLEBARCODE.err
#$-o /SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672/JAFFA/log/TOBEREPLACEDTO_SAMPLEBARCODE.out
#$ -N TOBEREPLACEDTO_SAMPLEBARCODE_jaffa

####################
#  Set parameters  #
####################
samplebarcode=TOBEREPLACEDTO_SAMPLEBARCODE
fastqdirroot=TOBEREPLACEDTO_FASTQDIRROOT
fastqfilepaths=$fastqdirroot/Sample_$samplebarcode/*fastq.gz
analysisdirroot=TOBEREPLACEDTO_ANALYSIS_PROJDITROOT

# fastqdirroot=/SequenceData/Data_Analysis/Project_15425_FUID1022672
# analysisdirroot=/SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Project_15425_FUID1022672/JAFFA
cd $analysisdirroot/JAFFA

##################################################
# Does the directory exist? Skip this sample     #
# if the sample directory exists.                #
# If not, run JAFFA                              #
##################################################
# if [ `find -maxdepth 1 -mindepth 1 -type d -name $samplebarcode| wc -l` == 1 ]; then
#     echo "Directory exists. Skipped."
# else
mkdir -p $samplebarcode
cd $samplebarcode
/toolbox/NGS/source_repository/JAFFA-version-1.06/tools/bin/bpipe run \
/toolbox/NGS/source_repository/JAFFA-version-1.06/JAFFA_assembly.groovy \
$fastqfilepaths

# # This is when the pipeline stopped because of reformat error.
# # Modify and rerun.
# grep reformat commandlog.txt| tr "\\;" "\n" | tail -n +2| \
# sed 's|/toolbox/NGS/source_repository/JAFFA-version-1.06/tools/bin/reformat|/toolbox/NGS/source_repository/bbmap/reformat.sh|' \
# >tmp_reformat_fix.sh

# ./tmp_reformat_fix.sh

# # Then restart the pipeline again. It will pick up from where it was left off:
# /toolbox/NGS/source_repository/JAFFA-version-1.06/tools/bin/bpipe run \
# /toolbox/NGS/source_repository/JAFFA-version-1.06/JAFFA_assembly.groovy \
# $fastqfilepaths

cd ..
# fi



