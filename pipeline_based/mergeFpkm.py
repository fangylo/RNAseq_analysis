import utils
import time
import logging
import argparse
from argparse import RawTextHelpFormatter


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s %(levelname)s %(message)s')

    parser = argparse.ArgumentParser(
        description='''
        Merge selected files in the PID_FUID directory. Optionally output csv
        file. After rna-seq pipeline, fpkm files are ususally stored under each
        sample ID directory (US-*) under the PID_FUID project directory. Also
        there are often duplicated gene names. This script look through all the
        sample directories in the project directory, find the file that matches
        the supplied pattern (filepattern, default set to genes_fpkm.tracking,
        which is the gene fpkm), then first read the fpkm files to
        pd.dataframes. The data is the filtered by status (default only select
        rows where FPKM_status=OK), then merge duplicated row values by mean,
        median or max (default set to mean).The resulting dataframe has
        different samples as columns and different genes (unique) as rows.
        Note that no log transformation is performed here.

        Example:
        cd <Project directory>
        python mergeFpkm.py
               -f "gene.fpkm_tracking"
               -r .
               -p "US-*"
               -k "gene_short_name"
               -m mean
               -o out_test.csv
               -u ","
        ''',
        formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument('-f', '--filepattern',
                        action='store',
                        default='genes.fpkm_tracking',
                        help='Input file pattern. \n' +
                             'E.g. "genes.fpkm_tracking"')
    # Optional arguments:
    parser.add_argument('-p', '--firstLevelFolderPattern',
                        action='store',
                        default="US-*",
                        help='First level folder pattern, i.e. the sample\n' +
                             'id folders.')
    parser.add_argument('-r', '--rootfolderPaths',
                        action='store',
                        default=["."],
                        nargs="*",
                        help='One or more root folder paths that first level\n' +
                             'folder pattern will be searched in.'
                        )
    parser.add_argument('-k', '--colaskey',
                        action='store',
                        default="gene_short_name",
                        help='column in the file used as key (rownames)')
    parser.add_argument('-v', '--colasvalue',
                        action='store',
                        default="FPKM",
                        help='column in the file used as values')
    parser.add_argument('--withoutstatusfilter',
                        dest='withoutstatusfilter',
                        action='store_true',
                        help='Supply this argument if do not filter FPKM \n' +
                             'to only rows where the status column is OK.')
    parser.set_defaults(withoutstatusfilter=False)
    parser.add_argument('-d', '--removeKeyEqTo',
                        action='store',
                        default="-",
                        help='Remove keys (gene names) shown as -.')
    parser.add_argument('-m', '--mergeDupBy',
                        action='store',
                        default="mean",
                        help='Merge duplicated (genes) by mean, median or max.')
    parser.add_argument('-o', '--outfilePath',
                        action='store',
                        default=None,
                        help='Output the result df to a (csv) file.\n' +
                             'Default is None. No file is output.')
    parser.add_argument('-u', '--outputdelim',
                        action='store',
                        default=",",
                        help='Delimiter used for output file. Default is ","')

    args = parser.parse_args()
    logging.info(args)
    filepattern = args.filepattern
    firstLevelFolderPattern = args.firstLevelFolderPattern
    rootfolderPaths = args.rootfolderPaths
    colaskey = args.colaskey
    colasvalue = args.colasvalue
    filterStatus = not args.withoutstatusfilter
    removeKeyEqTo = args.removeKeyEqTo
    mergeDupBy = args.mergeDupBy
    outfilePath = args.outfilePath
    outputdelim = args.outputdelim

    starttime = time.time()
    filepaths = utils.get_filepaths(filepattern=filepattern,
                                    firstLevelFolderPattern=firstLevelFolderPattern,
                                    rootfolderPaths=rootfolderPaths)
    outputdelim = outputdelim.decode('string_escape')
    logging.debug(filepaths)
    logging.debug(outputdelim)

    mergedsamplefpkm_df = utils.getMergedFpkmDfFromMultipleSamples(filepaths,
                                                                   colaskey=colaskey,
                                                                   colasvalue=colasvalue,
                                                                   filterStatus=filterStatus,
                                                                   removeKeyEqTo=removeKeyEqTo,
                                                                   mergeDupBy=mergeDupBy,
                                                                   outfilePath=outfilePath,
                                                                   outputdelim=outputdelim)
    logging.debug(mergedsamplefpkm_df)
    duration = time.time() - starttime

    logging.debug("Running time=" + str(duration))
