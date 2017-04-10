#! /usr/bin/env python

import sys
import os
import glob
import re

if len(sys.argv) < 3:
    print >> sys.stderr, 'ERROR: make_featureCounts.py: Wrong number of arguments'
    print >> sys.stderr, 'USAGE: make_featureCounts.py in.projdir in.sampletag in.genome'
    print >> sys.stderr, 'E.G.: make_featureCounts.py /SequenceData/In_Process/HiSeq/rnaseq_processing/INTERNAL_DEV/Janssen_MM/Project_16017_FUID1026371 US hg19'
    sys.exit()

projdir = sys.argv[1]
samtag = sys.argv[2]
genome = sys.argv[3]
genbase = '/toolbox/NGS/genomes/'

scriptdir = projdir + '/scripts/'
if not os.path.exists(scriptdir):
    os.makedirs(scriptdir)
logdir = projdir + '/log/'
if not os.path.exists(logdir):
    os.makedirs(logdir)

featureCounts = '/toolbox/NGS/source_repository/subread-1.5.0-p2-Linux-x86_64/bin/featureCounts'

sampleGlob = sorted(glob.glob(projdir + '/' + samtag + '*'))
for s in sampleGlob:
    infiles = ''
    BamGlob = sorted(glob.glob(s + '/*.bam'))
    for bg in BamGlob:
        infiles = infiles + ' I=' + bg
    sample = s.split('/')[-1]
    outprefix = s + '/' + sample
    ofile = outprefix + '_featureCounts.txt'

    fullFC = featureCounts + ' -a ' + genbase + genome + '/annotations/refGene.gtf' + \
        ' -o ' + ofile + ' -p -s 2 -T 10 ' + s + '/' + sample + '.bam\n\n'

    scriptfile = scriptdir + 'featureCounts_' + sample + '.sh_test'

    try:
        with open(scriptfile, 'w') as output:
            output.write('#!/bin/bash\n')
            output.write('#$-S /bin/bash\n')
            output.write('#$-cwd\n')
            output.write('#$-pe smp 10\n')
            output.write('#$-l mf=8G\n')
            output.write('#$-e ' + logdir +
                         'featureCounts_' + sample + '.err\n')
            output.write('#$-o ' + logdir + 'featureCounts_' +
                         sample + '.out\n\n')
            output.write('. ~/.bash_profile\n\n')
            output.write(fullFC)
        output.close()
        os.system('chmod 755 ' + scriptfile)
    except OSError:
        print 'fail'

launchscript = scriptdir + 'runFeatureCountsJobs.sh'
try:
    shGlob = sorted(glob.glob(scriptdir + 'featureCounts*.sh'))
    with open(launchscript, 'w') as output2:
        for sh in shGlob:
            output2.write('qsub ' + sh + '\n')
            output2.write('sleep 3\n')
    output2.close()
    os.system('chmod 755 ' + launchscript)
except OSError:
    print 'fail'
