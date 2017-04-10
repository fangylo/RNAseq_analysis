#!/usr/bin/env python
from __future__ import print_function
import pandas as pd
import logging
import argparse
from argparse import RawTextHelpFormatter


def readCountFile(countfile):
    df = pd.read_csv(countfile,
                     names=[countfile],
                     header=None,
                     index_col=0,
                     delim_whitespace=True)
    return(df)


def joinCountFiles(listOfCountFiles):
    """
    <list Of count files>
    !!! Important: only use this when the row Ids are unique. or it will
        multiply the results and never finish running...
    """
    i = 0

    totalFileN = len(listOfCountFiles)
    for countfile in listOfCountFiles:
        logging.info("joining file:" + str(i + 1) + "/" + str(totalFileN))

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
    python /home/lof/code/RNAseq_analysis/htseq-count/joinCounts.py "htseqcount_all.txt" htseq.count.out_*
    """

    logging.basicConfig(
        level=logging.DEBUG, format='%(asctime)s %(levelname)s %(message)s')

    parser = argparse.ArgumentParser(
        description='Join HTseq count results.\n' +
                    'Example:\n' +
                    '   python joinCounts.py.py \n' +
                    '          "htseqcount_all.txt" htseq.count.out_*\n',
        formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument('out_filename',
                        action='store',
                        help='Output file name. \n' +
                             'E.g. "htseqcount_all.txt"')
    parser.add_argument('listOfCountFiles',
                        action='store',
                        nargs="*",
                        help='File pattern for input count files. \n' +
                             'E.g. htseq.count.out_*')
    args = parser.parse_args()
    logging.info(args)
    listOfCountFiles = args.listOfCountFiles
    out_filename = args.out_filename

    logging.warning("!ONY USE THIS SCRIPT WHEN ROW IDS ARE UNIQUE!")
    logging.info("listOfCountFiles:")
    logging.info(listOfCountFiles)
    result_df = joinCountFiles(listOfCountFiles)

    result_df.to_csv(out_filename, sep="\t")
