import glob
from os import walk
from os.path import join, isdir
from os import listdir

import subprocess
import re


root = './cores/'
assertF = './cores/helpers/tb.v'

cores = [join(root, f) for f in listdir(root) if isdir(join(root, f))]

print cores

regex = re.compile(r"/")

for core in cores:
  if not isdir(join(core, 'tb')):
    continue
  print '--- search in %s' % core
  fils = []
  for g in glob.glob(join(core, 'rtl', '*.v')):
    fils.append(g)

  print fils
  for g in glob.glob(join(core, 'tb', '*.v')):
    # run test
    print 'tb %s' % g

    o_file = join('./tmp/', g[2:].replace('/','_') +'.o')
    print "o_file %s" % o_file

    args = ' '.join([assertF, ' '.join(fils), g, '-o', o_file])
    print args

    comm = 'iverilog %s && vvp %s' % (args, o_file)

    print comm

    p = subprocess.Popen(comm, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = p.communicate()

    print '__ OUT'
    print out
    print '__ err'
    print err

