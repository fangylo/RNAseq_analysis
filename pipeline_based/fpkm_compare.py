#!/usr/bin/env python
from __future__ import print_function
import pandas as pd
import logging
import argparse
from argparse import RawTextHelpFormatter

# python /home/lof/code/RNAseq_analysis/pipeline_based/fpkm_compare.py


class Samplefpkm:

    """
    Samplefpkm with sample id and fpkm
    """

    def __init__(self,
                 sampleid,
                 fpkm):
        """
        sampleid: <str>
        fpkmdict: <dict> of fpkm. e.g. {'gene1':15,'gene2':2,...}
        """
        self.sampleid = sampleid
        self.fpkm = fpkm


def getfpkmfromfile(sampleid,
                    filepath='genes.fpkm_tracking',
                    colaskey='gene_short_name',
                    colasvalue='FPKM'):
    """
    read fpkm file and output dict such as: {'gene1':15,'gene2':2,...}
    Arg:
        sampleid:<str>
        filepath: <str> fpkm file path
        colaskey: <str> column name used as key for the output dict
        colasvalue: <str> column name used as value for the output dict
    Return:
        <Samplefpkm>
    """
    df = pd.read_csv(filepath,
                     sep="\t",
                     header=0,
                     skip_blank_lines=True)
    df = df.dropna(axis='columns', how='all')
    # Only consider rows with 'OK' FPKM_status
    df = df[df['FPKM_status'] == 'OK']
    # Remove rows where there is no value/gene name, etc.
    df = df[df[colaskey] != '-']
    fpkmdict = df.set_index(colaskey)[colasvalue].to_dict()
    result = Samplefpkm(sampleid=sampleid, fpkm=fpkmdict)
    # logging.debug(result.fpkm)

    return result


def getCorrBetweenSamplefpkm(samplefpkm1, samplefpkm2, method='pearson'):
    """
    Get correlation between two samples
    Input args:
        samplefpkm1:<Samplefpkm>
        samplefpkm2:<Samplefpkm>
        method: 'pearson' or 'spearman'
    """
    overlap_keys = list(
        samplefpkm1.fpkm.viewkeys() & samplefpkm2.fpkm.viewkeys())
    v1 = [samplefpkm1.fpkm.get(x) for x in overlap_keys]
    v2 = [samplefpkm2.fpkm.get(x) for x in overlap_keys]
    # logging.debug(overlap_keys)
    # logging.debug(v1)
    # logging.debug(v2)
    corr = pd.Series(v1).corr(pd.Series(v2), method=method)
    return corr


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s %(levelname)s %(message)s')

    parser = argparse.ArgumentParser(
        description='Get correlation coefficients between two gene expression results (fpkm).' +
        'Note: use \n' +
        'Example:\n' +
        'python fpkm_compare.py -p <projectfolderdir>\n' +
        '                       -s <sampleid1> <sampleid2>\n' +
        '                       -f <gene.fpkm> <gene.fpkm>\n' +
        '                       -m <correlation method>',
        formatter_class=RawTextHelpFormatter)

    parser.add_argument('-p', '--projectdir',
                        action='store',
                        default='.',
                        help='Project root dirpath.'
                        )
    parser.add_argument('-s', '--sampleIds',
                        action='store',
                        default=None,
                        nargs=2,
                        help='The two sample ids of which correlation to be calculated.\n' +
                        'This should be the same name as the sample folders.\n'
                        'Eg. RS-758933 RS-758934'
                        )
    parser.add_argument('-f', '--fpkmfilename',
                        action='store',
                        default='genes.fpkm_tracking',
                        help='Name of files under each sample dir.'
                        )
    parser.add_argument('-m', '--corrMethod',
                        action='store',
                        default='pearson',
                        help='Method used for correlation.'
                        )

    args = parser.parse_args()
    logging.info(args)

    projectdir = args.projectdir
    sampleIds = args.sampleIds
    fpkmfilename = args.fpkmfilename
    corrMethod = args.corrMethod

    filepathsForComparisons = [
        str(projectdir) + "/" + x + "/" + fpkmfilename for x in sampleIds]
    # logging.debug(filepathsForComparisons)

    s1 = getfpkmfromfile(sampleIds[0], filepath=filepathsForComparisons[0])
    s2 = getfpkmfromfile(sampleIds[1], filepath=filepathsForComparisons[1])
    corr = getCorrBetweenSamplefpkm(s1, s2, method=corrMethod)
    print(corrMethod + " correlation between " +
          sampleIds[0] + " and " + sampleIds[1] + ":\n" + str(corr))
