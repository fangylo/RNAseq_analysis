from __future__ import print_function
import pandas as pd
import numpy as np
import logging
import time
from collections import defaultdict
import itertools
import glob
import os
import re

# python /home/lof/code/RNAseq_analysis/pipeline_based/utils.py


class Samplefpkm:

    """
    Samplefpkm with sample id and fpkm
    """

    def __init__(self,
                 sampleid,
                 fpkm):
        """
        sampleid: <str>
        fpkm: <dict> of fpkm. e.g. {'gene1':15,'gene2':2,...}
        """
        self.sampleid = sampleid
        self.fpkm = fpkm


def getfpkmfromfile(sampleid,
                    filepath='genes.fpkm_tracking',
                    colaskey='gene_short_name',
                    colasvalue='FPKM',
                    filterStatus=True,
                    removeKeyEqTo='-',
                    mergeDupBy='mean'):
    """
    Read the fpkm file and output Samplefpkm class that specifies:
    (1) sample id (2) fpkm: a dict such as: {'gene1':15,'gene2':2,...}

    Args:
        sampleid:<str>
        filepath: <str> fpkm file path
        colaskey: <str> column name used as key for the output dict
        colasvalue: <str> column name used as value for the output dict
        filterStatus: <Bool>: if True, only keep the rows with FPKM_Status=OK
        removeKeyEqTo: None or <str>: if not None, remove keys equal to
                       this value
        mergeDupBy : "mean" "max" or "median"

    Return:
        <Samplefpkm>
    """
    # Read (fpkm) file:
    df = pd.read_csv(filepath,
                     sep="\t",
                     header=0,
                     skip_blank_lines=True)
    df = df.dropna(axis='columns', how='all')

    # Only consider rows with 'OK' FPKM_status
    if filterStatus is True:
        df = df[df['FPKM_status'] == 'OK']

    # Remove rows where there is no value/gene name, etc.
    if removeKeyEqTo is not None:
        df = df[df[colaskey] != removeKeyEqTo]

    keylist = list(df[colaskey])  # keys used for the output dict
    valuelist = list(df[colasvalue])  # values used for the output dict

    # Check if there is any duplicate of keys, and merge values
    # by specified method if there is any duplicate:

    res_keylist, res_valuelist = mergeDupKeys(keylist,
                                              valuelist,
                                              mergeDupBy=mergeDupBy)

    fpkmdict = dict(itertools.izip(res_keylist, res_valuelist))
    result = Samplefpkm(sampleid=sampleid, fpkm=fpkmdict)
    # logging.debug(result.fpkm)

    return result


def get_filepaths(filepattern="genes.fpkm_tracking",
                  firstLevelFolderPattern="US-*",
                  rootfolderPaths=["."]):
    """
    Go through the specified folder(s), e.g. PID_FUID
    Get all the sample ID folders, then return list of file paths.

    Input args:
        filepattern: <str>
        firstLevelFolderPattern: <list>
        rootfolderPaths: <str>
    Return: <list> of file paths
    """
    logging.debug("get_filepath_func_filepattern="+filepattern)
    logging.debug("get_filepath_func_rootfolder="+",".join(rootfolderPaths))
    res_filepaths = []
    for rootfolderPath in rootfolderPaths:
        firstlevelfolders = [p for p in os.walk(rootfolderPath).next(
        )[1] if re.search(firstLevelFolderPattern, p)]
        for firstlevelfolder in firstlevelfolders:
            pattern = rootfolderPath + "/" + \
                firstlevelfolder + "/" + filepattern
            res_filepaths = res_filepaths + glob.glob(pattern)
    return res_filepaths


def getMergedFpkmDfFromMultipleSamples(filepaths,
                                       colaskey='gene_short_name',
                                       colasvalue='FPKM',
                                       filterStatus=True,
                                       removeKeyEqTo='-',
                                       mergeDupBy='mean',
                                       outfilePath=None,
                                       outputdelim=","):
    """
    Go through the specified files (e.g.genes.fpkm_tracking from multiple
    samples):
    (1) Use the specified column (e.g. gene_short_name) as key
    (2) Merge the result to a dataframe and optionally output the table
        to csv file
    Args:
        filepaths: <list>
        colaskey: <str> column name used as key for the output dict
        colasvalue: <str> column name used as value for the output dict
        filterStatus: <Bool>: if True, only keep the rows with FPKM_Status=OK
        removeKeyEqTo: None or <str>: if not None, remove keys equal to
                       this value
        mergeDupBy : "mean" "max" or "median"

    Output:<pd.DataFrame>: a df with column names as samples if/ filepath
                           and rows as (gene name).
    """
    list_sampleFpkm = []

    for filepath in filepaths:
        sampleFpkm = getfpkmfromfile(sampleid=filepath,
                                     filepath=filepath,
                                     colaskey=colaskey,
                                     colasvalue=colasvalue,
                                     filterStatus=filterStatus,
                                     removeKeyEqTo=removeKeyEqTo,
                                     mergeDupBy=mergeDupBy)
        list_sampleFpkm.append(sampleFpkm)
    df = mergeSamplefpkmToDf(list_sampleFpkm,
                             outfilePath=outfilePath,
                             outputdelim=outputdelim)

    return df


def mergeSamplefpkmToDf(listOfSampleFpkm,
                        outfilePath=None,
                        outputdelim=","):
    """
    Merge multiple listOfSampleFpkm to a dataframe. Optionally
    output the table to a csv file
    """
    fpkmdict_multiplesamples = {}
    for i in range(0, len(listOfSampleFpkm)):
        sampleid = listOfSampleFpkm[i].sampleid
        fpkmdict = listOfSampleFpkm[i].fpkm
        fpkmdict_multiplesamples[sampleid] = fpkmdict
    df = pd.DataFrame.from_dict(fpkmdict_multiplesamples, orient='columns')

    if outfilePath is not None:
        df.to_csv(outfilePath, sep=outputdelim, na_rep="-", index=True)

    return df


def mergeDupKeys(keylist, valuelist, mergeDupBy='mean'):
    """
    The two input lists are eventually used for building dict
    They should have the same length.
    Here is to merge key duplicates, and the corresponding values are merged
    by mean or median or max.

    Args:
        keylist: <list>
        valuelist: <list>
        mergeDupBy: <str>: 'mean' or 'max' or 'median'
    Return:
        res_keylist
        res_valuelist
    """

    if len(keylist) != len(valuelist):
        raise Exception("keylist and valuelist need to have equal length.")

    if len(set(keylist)) != len(keylist):  # Duplicates exists

        # Get duplicated items:
        dupDict = defaultdict(list)
        for i, item in enumerate(keylist):
            dupDict[item].append(i)
        dupDict = {k: v for k, v in dupDict.items() if len(v) > 1}

        # Extract uniq items:
        dupkey_idx = [item for sublist in dupDict.values() for item in sublist]
        uniqkey_idx = list(set(range(0, len(keylist))) - set(dupkey_idx))

        uniq_keylist = [keylist[i] for i in uniqkey_idx]
        uniq_valuelist = [valuelist[i] for i in uniqkey_idx]

        # Merge duplicated items:
        merged_dupkeylist = []
        merged_dupvaluelist = []

        for dupKeyItem in dupDict:  # Go through all the duplicated
                                   # keys (e.g. gene names)

            thiskey_valueIdxs = dupDict[dupKeyItem]
            thiskey_values = [valuelist[i] for i in thiskey_valueIdxs]

            merged_dupkeylist.append(dupKeyItem)
            if mergeDupBy == 'mean':
                merged_dupvaluelist.append(np.mean(thiskey_values))
            elif mergeDupBy == 'median':
                merged_dupvaluelist.append(np.median(thiskey_values))
            elif mergeDupBy == 'max':
                merged_dupvaluelist.append(np.max(thiskey_values))
            else:
                raise Exception("mergeDupBy valid values:mean,mdian or max.")

        res_keylist = uniq_keylist + merged_dupkeylist
        res_valuelist = uniq_valuelist + merged_dupvaluelist
    else:  # no duplicates
        res_keylist = keylist
        res_valuelist = valuelist
    return res_keylist, res_valuelist


# if __name__ == '__main__':
#     logging.basicConfig(
#         level=logging.DEBUG,
#         format='%(asctime)s %(levelname)s %(message)s')

#     filepattern = "test"
#     firstLevelFolderPattern = "US-*"
#     rootfolderPaths = ["."]
#     colaskey = 'gene_short_name'
#     colasvalue = 'FPKM'
#     filterStatus = True
#     removeKeyEqTo = None
#     mergeDupBy = 'mean'

#     starttime = time.time()
#     filepaths = get_filepaths(filepattern=filepattern,
#                               firstLevelFolderPattern=firstLevelFolderPattern,
#                               rootfolderPaths=rootfolderPaths)
#     logging.debug(filepaths)

#     mergedsamplefpkm_df = getMergedFpkmDfFromMultipleSamples(filepaths,
#                                                              colaskey=colaskey,
#                                                              colasvalue=colasvalue,
#                                                              filterStatus=filterStatus,
#                                                              removeKeyEqTo=removeKeyEqTo,
#                                                              mergeDupBy=mergeDupBy)
#     logging.debug(mergedsamplefpkm_df)
#     duration = time.time() - starttime

#     logging.debug("Running time=" + str(duration))
