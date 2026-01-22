
from setuptools import setup

from git import Repo

repo = Repo()

# Get version before adding version file
rawVer = repo.git.describe('--tags')

fields = rawVer.split('-')

if len(fields) == 1:
    pyVer = fields[0]
else:
    pyVer = fields[0] + '.dev' + fields[1]

# append version constant to package init
with open('python/RceG3/__init__.py','a') as vf:
    vf.write(f'\n__version__="{pyVer}"\n')

setup (
   name='rce_gen3_fw_lib',
   version=pyVer,
   packages=['RceG3', ],
   package_dir={'':'python'},
)

