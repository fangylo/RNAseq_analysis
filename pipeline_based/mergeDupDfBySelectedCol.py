import utils
import pandas as pd
import time
import logging
import argparse
from argparse import RawTextHelpFormatter
from collections import defaultdict


def readDf(filepath,
           sep="\t",
           header=0,
           skip_blank_lines=True):
    """

    """
    df = pd.read_csv(filepath,
                     sep=sep,
                     header=header,
                     skip_blank_lines=skip_blank_lines)
    df = df.dropna(axis='columns', how='all')

    return df


def mergeDfDupRows(df,
                   colAsKey="GeneSymbol",
                   colsToBeOmitted=["GeneSymbol", "ID", "Description"]):
    """
    """
    keylist = df[colAsKey]

    # Get duplicated items {dup_value:[indexes]}:
    dupDict = defaultdict(list)
    for i, item in enumerate(keylist):
        dupDict[item].append(i)
    dupDict = {k: v for k, v in dupDict.items() if len(v) > 1}

    # Extract uniq items:
    dupkey_listidx = [item for sublist in dupDict.values() for item in sublist]
    uniqkey_listidx = list(set(range(0, len(keylist))) - set(dupkey_listidx))

    uniq_keylist = [keylist[i] for i in uniqkey_listidx]
    res_uniq_df = df[df[colAsKey].isin(uniq_keylist)]
    res_uniq_df = res_uniq_df.set_index(res_uniq_df[colAsKey])
    res_uniq_df = res_uniq_df.drop(colsToBeOmitted, axis=1)

    # Merge duplicated items:
    merged_dfdict = {}

    for dupKeyItem in dupDict:  # Go through all the duplicated
                                # keys (e.g. gene names)
        thiskey_df = df.loc[dupDict[dupKeyItem]]
        thisMergedSeries = pd.Series(thiskey_df.mean(axis=0))
        merged_dfdict[dupKeyItem] = thisMergedSeries
    res_mergeddup_df = pd.DataFrame.from_dict(merged_dfdict, orient='index')

    if list(res_mergeddup_df.columns) != list(res_uniq_df.columns):
        raise Exception("columns in the merged group not identical to uniq group.\n" +
                        "Check colsToBeOmitted? Some non numeric columns are included?")
    else:
        res_df = res_uniq_df.append(res_mergeddup_df)

    return res_df


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s %(levelname)s %(message)s')

    parser = argparse.ArgumentParser(
        description='Process a gene expression csv file: merge duplicated \n' +
                    'genes. Optionally output merged results to a csv table.'
                    'Example:\n' +
                    '   python mergeDupDfBySelectedCol.py \n' +
                    '          "expression.csv"\n' +
                    '          -o expression_merged.csv\n' +
                    '          -d ","\n' +
                    '          -k GeneSymbol\n' +
                    '          -m GeneSymbol ID Description',
        formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument('filepath',
                        action='store',
                        help='Input file path. \n' +
                             'E.g. "/home/lof/Agilent_201602/data/expression1.csv"')
    # Optional arguments:
    parser.add_argument('-o', '--outfilePath',
                        action='store',
                        default=None,
                        help='Output file path. \n' +
                             'E.g. "/home/lof/Agilent_201602/data/expression_merged.csv"')
    parser.add_argument('-d', '--delimiter',
                        action='store',
                        default=",",
                        help='Delimiter.')
    parser.add_argument('-k', '--colAsKey',
                        action='store',
                        default="GeneSymbol",
                        help='Delimiter.')
    parser.add_argument('-m', '--colsToBeOmitted',
                        action='store',
                        nargs="*",
                        default=["GeneSymbol", "ID", "Description"],
                        help='Names of columns to be omitted.')

    args = parser.parse_args()
    logging.info(args)
    filepath = args.filepath
    outfilePath = args.outfilePath
    sep = args.delimiter
    colAsKey = args.colAsKey
    colsToBeOmitted = args.colsToBeOmitted

    starttime = time.time()
    df = readDf(filepath, sep=sep, header=0, skip_blank_lines=True)
    merged_df = mergeDfDupRows(df,
                               colAsKey=colAsKey,
                               colsToBeOmitted=colsToBeOmitted)
    logging.debug(merged_df)
    if outfilePath is not None:
        merged_df.to_csv(outfilePath, sep=sep, na_rep="-", index=True)

    duration = time.time() - starttime
    logging.debug("Run duration=" + str(duration) + " seconds.")
