#!/usr/bin/env python
from __future__ import print_function
import pandas as pd
import logging
import argparse
from argparse import RawTextHelpFormatter


def readCountFile(countfile,
                  selectedColIdx=[5]):
    """
    Read in feature count txt result and output the column with counts info
    Skip the first row because it starts with #
        countfile: filepath
        selectedColIdx: <list> of column index. Default selecting
                               the 6th column.
    output: pd.dataframe
    """
    df = pd.read_csv(countfile,
                     header='infer',
                     index_col=0,
                     sep="\t",
                     skiprows=1)
    result_df = df.iloc[:, selectedColIdx]
    result_df.columns = [countfile]
    # logging.debug(result_df.columns)
    return(result_df)


def joinCountFiles(listOfCountFiles):
    """
    <list Of count files>
    !!! Important: only use this when the row Ids are unique. or it will
        multiply the results and never finish running...
    """
    i = 0

    totalFileN = len(listOfCountFiles)
    for countfile in listOfCountFiles:
        logging.info("joining file:" + str(i + 1) + "/" +
                     str(totalFileN) + ",filename=" + countfile)

        count_df = readCountFile(countfile)
        if i == 0:
            result_df = count_df
        else:
            result_df = result_df.join(count_df, how='inner')
        i = i + 1
    return(result_df)

if __name__ == '__main__':
    """
    cd /SequenceData/In_Process/HiSeq/rnaseq_processing/1120_Daiichi/Project_15022/secondary_analysis/htseq-count/counts
    python /home/lof/code/RNAseq_analysis/featureCounts/joinCounts.py "featurecount_all.txt" *_featureCounts.txt
    """

    logging.basicConfig(
        level=logging.DEBUG, format='%(asctime)s %(levelname)s %(message)s')

    parser = argparse.ArgumentParser(
        description='Join featurecounts results.\n' +
                    'Example:\n' +
                    '   python joinCounts.py \n' +
                    '          "featurecount_all.txt" *_featureCounts.txt\n',
        formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument('out_filename',
                        action='store',
                        help='Output file name. \n' +
                             'E.g. "featurecount_all.txt"')
    parser.add_argument('listOfCountFiles',
                        action='store',
                        nargs="*",
                        help='File pattern for input count files. \n' +
                             'E.g. *_featureCounts.txt')
    args = parser.parse_args()
    logging.info(args)
    listOfCountFiles = args.listOfCountFiles
    out_filename = args.out_filename

    logging.warning("!Only use this when the row Ids are unique.")
    logging.info("listOfCountFiles:")
    logging.info(listOfCountFiles)
    result_df = joinCountFiles(listOfCountFiles)

    result_df.to_csv(out_filename, sep="\t")
