import glob
from os import walk
from os.path import join, isdir
from os import listdir

from termcolor import colored

import subprocess
import re


_warns = []

_errs = []

root = './cores/'
assertF = './cores/helpers/tb.v'

cores = [join(root, f) for f in listdir(root) if isdir(join(root, f))]

regex = re.compile(r"/")

MOD_NAME = re.compile('(\\w+)$')
TB_NAME = re.compile('(\\w+)_tb.v$')

for core in cores:
  if not isdir(join(core, 'tb')):
    continue
  fils = []
  for g in glob.glob(join(core, 'rtl', '*.v')):
    fils.append(g)

  for g in glob.glob(join(core, 'tb', '*_tb.v')):
    # run test
    core_name = MOD_NAME.search(core).group()
    tb_name = TB_NAME.search(g).group(1)

    print colored('Testing:', attrs=['bold']), '%s | %s ' % (core_name, tb_name)

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

    ers = err.splitlines()
    for er in ers:
      if 'warning' in er:
        _warns.append(er)
      else:
	_errs.append(er)


print ''
print ''
if len(_errs) > 0:
  print colored('FINISHED WITH ERRORS', 'red', attrs=['bold'])
else:
  print colored('Done!', 'green')

print colored('Warnings:', 'yellow')
for w in _warns:
  print colored('Warn:', 'yellow'), ' %s' % w

print colored('Errors:', 'red')
for e in _errs:
  print colored('Error:', 'red'), ' %s' % e
