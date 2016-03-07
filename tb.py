import glob
from os import walk
from os.path import join, isdir
from os import listdir

from termcolor import colored

import subprocess
import re


_warns = []

_errs = []

_total = 0

_failed = 0
_success = 0

root = './cores/'
assertF = './cores/helpers/tb.v'

cores = [join(root, f) for f in listdir(root) if isdir(join(root, f))]

regex = re.compile(r"/")

MOD_NAME = re.compile('(\\w+)$')
TB_NAME = re.compile('(\\w+)_tb.v$')
ASSER = re.compile('ASSERT h\'(\\w+) h\'(\\w+) ([\\w\s]+)')

print colored('Starting testing', attrs=['bold'])

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

    args = ' '.join([assertF, ' '.join(fils), g, '-o', o_file])

    comm = 'iverilog %s && vvp %s' % (args, o_file)


    p = subprocess.Popen(comm, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = p.communicate()

    if len(out) > 0:
      asdf = out.splitlines()
      for ass in asdf:
        _total = _total + 1

        dsd = ASSER.search(ass)
	r1 = dsd.group(1)
	r2 = dsd.group(2)
	comm = dsd.group(3)

	if r1 == r2:
	  _success = _success + 1
	  print colored('ok', 'green'), " %s" % comm
	else:
          _failed = _failed + 1
	  print colored('fail', 'red'), "%s != %s, %s" % (r1, r2, comm)

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

print 'Testcases: %s, ' % _total, colored('successful: %s, ' % _success, 'green'), colored('Failed: %s ' % _failed, 'red')

print colored('Warnings:', 'yellow')
for w in _warns:
  print colored('Warn:', 'yellow'), ' %s' % w

if len(_errs) > 0:
  print colored('Errors:', 'red')
  for e in _errs:
    print colored('Error:', 'red'), ' %s' % e
