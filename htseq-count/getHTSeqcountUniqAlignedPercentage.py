from __future__ import print_function
from __future__ import division
import sys
import argparse
# import warnings
from argparse import RawTextHelpFormatter
import logging
import os
import fnmatch
import re
import argparse
from argparse import RawTextHelpFormatter
pathsToAdd = ['/home/lof/code/Tools/python/logwatcher']
sys.path = sys.path + pathsToAdd
import logwatcher


def getTotalNumSAMAlignmentPairs(htseq_err_filepath):
    """
    Get total number of processed SAM alignment pairs
    from standard htseq-count err file

    Arg: <str>: filepath to htseq-count-<samplebarcode>.err
    Return: <int>: total number of processed aligned SAM pairs.
    """
    lastline = logwatcher.LogWatcher.tail(htseq_err_filepath, 1)
    logging.debug(lastline)
    totalprocessedN = int(lastline[0].split()[0]) * 2
    return totalprocessedN


def getNotUniqAlignedNumber(htseq_count_result_filepath):
    """
    The 5 lines of the htseq-count result are the numbers of features that
    did not uniquely aligned to features.
    These 5 lines look like this:
        __no_feature    4899656
        __ambiguous     878343
        __too_low_aQual 0
        __not_aligned   1997853
        __alignment_not_unique  2012171

    Here the sum of tehse numbers is returned as <int> in order to calculate
    the percentage of processed reads that are uniquely aligned.

    Arg: <htseq_count_result_filepath> filepath to a htseq-count result file
    Return: <int>
    """
    mappingstats = logwatcher.LogWatcher.tail(htseq_count_result_filepath, 5)
    totalNotAlignedN = [int(mappingstats[i].split('\t')[1])
                        for i in range(0, len(mappingstats))]
    return sum(totalNotAlignedN)


def getfilepathsFromEachSample(htseqAnalysisDir, samplebarcode):
    """
    Based on standard htseq-count run, get appropriate filepath for each sample
    Arg:
        <str> htseqAnalysisDir. Do not add the trailing "/"
              E.g.  /SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count
        <str> samplebarcode. E,g, US-1469755
    Return: <tuple>: (htseq_err_filepath,htseq_count_result_filepath)
    """
    if htseqAnalysisDir.endswith("/"):
        logging.warn("Analysis directory should not end with '/'.")
    htseq_err_filepath = htseqAnalysisDir + \
        "/log/htseqCount_" + samplebarcode + ".err"
    htseq_count_result_filepath = htseqAnalysisDir + \
        "/counts/htseq.count.out_" + samplebarcode + "_refGeneGTF.txt"
    return (htseq_err_filepath, htseq_count_result_filepath)


def getUniqAlignedPercentage(htseqAnalysisDir, samplebarcode):
    """
    """
    (htseq_err_filepath, htseq_count_result_filepath) = getfilepathsFromEachSample(
        htseqAnalysisDir, samplebarcode)
    htseq_err_file_size = os.stat(htseq_err_filepath).st_size
    htseq_count_file_size = os.stat(htseq_count_result_filepath).st_size
    if htseq_err_file_size > 0 and htseq_count_file_size > 0:
        totalNotAlignedN = getNotUniqAlignedNumber(htseq_count_result_filepath)
        totalprocessedN = getTotalNumSAMAlignmentPairs(htseq_err_filepath)
        perc = 100 * ((totalprocessedN - totalNotAlignedN) / totalprocessedN)
    else:
        perc = "N/A"
    return perc


def getAllSampleBarcodes(htseqAnalysisDir):
    """
    Get all the sample barcodes processed (has results in the counts/directory)
    Arg: <str> htse-count analysis directory
    Return: <list> of sample barcodes
    """
    htseqresultfiles = []
    for file in os.listdir(htseqAnalysisDir + "/counts"):
        if fnmatch.fnmatch(file, '*.txt'):
            if fnmatch.fnmatch(file, 'htseq.count.out_*'):
                htseqresultfiles.append(file)
    allbarcodes = [
        re.sub("htseq.count.out_|_refGeneGTF.txt", "", file) for file in htseqresultfiles]
    return allbarcodes


def getUniqAlignedPercentageAllSamples(htseqAnalysisDir, printToScreen=True):
    if printToScreen:
        print("sample_barcode\tpercentage of reads uniq aligned to feature")

    allbarcodes = getAllSampleBarcodes(htseqAnalysisDir)
    result = dict.fromkeys(allbarcodes)
    for samplebarcode in allbarcodes:
        logging.debug(samplebarcode)
        perc = getUniqAlignedPercentage(
            htseqAnalysisDir, samplebarcode)
        result[samplebarcode] = perc

        if printToScreen:
            print("\t".join([samplebarcode, str(perc)]))

    return result


if __name__ == '__main__':
    """
    """
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s %(levelname)s %(message)s')
    parser = argparse.ArgumentParser(
        description='Get the percentage of uniquely aligned reads by HTSeq-count:\n' +
        'Example:\n' +
        '  python getHTSeqcountUniqAlignedPercentage.py \n' +
        '         /SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count\n',
        formatter_class=RawTextHelpFormatter)

    parser.add_argument('analysisdir',
                        action='store',
                        help='htseq-count analysis directory path (without trailing "/").')
    args = parser.parse_args()
    logging.info(args)
    htseqAnalysisDir = args.analysisdir

    # htseqAnalysisDir = "/SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count"

    result = getUniqAlignedPercentageAllSamples(htseqAnalysisDir)
