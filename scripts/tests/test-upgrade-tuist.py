#!/usr/bin/env python3
"""在隔离 Git 仓库中验证升级失败保护和清理边界，不操作本机安装。"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]
REAL_GIT = shutil.which('git')
FAKE = r'''#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
name=Path(sys.argv[0]).name;args=sys.argv[1:];root=Path(os.environ['FIXTURE'])
with (root/'commands').open('a') as f:f.write(name+' '+' '.join(args)+'\n')
failure=os.environ.get('FAIL_STAGE','')
if name=='git':
 if args[:1]==['ls-remote']:
  if failure=='query':sys.exit(1)
  print('abc\trefs/tags/4.212.0\nabc\trefs/tags/4.200.4\nabc\trefs/tags/5.0.0-rc.1\nabc\trefs/tags/app@9.0.0\nabc\trefs/tags/xcresult-processor-image@99.0.0')
  sys.exit(0)
 os.execv(os.environ['REAL_GIT'],[os.environ['REAL_GIT'],*args])
if name in ('open','swiftgen'):sys.exit(0)
state=root/'installed.json';items=json.loads(state.read_text())
if args[0]=='ls':
 if '--prunable' in args:items=[x for x in items if x['version']!='4.33.0']
 print(json.dumps(items));sys.exit(0)
value=next((x.split('@',1)[1] for x in args if x.startswith('tuist@')),'')
if args[0]=='install':
 if failure=='download':sys.exit(1)
 if not any(x['version']==value for x in items):
  path=root/'installs/tuist'/value;path.mkdir(parents=True,exist_ok=True)
  items.append(dict(version=value,installed=True,active=False,install_path=str(path)))
 state.write_text(json.dumps(items));sys.exit(0)
if args[0]=='exec':
 command=args[args.index('--')+2]
 if command=='version':print('4.0.0' if failure=='version' else value)
 if command=='install':
  assert '--force-resolved-versions' in args and '--skip-update' in args
  if failure=='dependencies':sys.exit(1)
  if failure=='lock':Path('Tuist/Package.resolved').write_text('changed')
 if command=='generate' and failure=='generate':sys.exit(1)
 sys.exit(0)
if args[0]=='uninstall':
 if failure=='cleanup':sys.exit(1)
 state.write_text(json.dumps([x for x in items if x['version']!=value]));sys.exit(0)
sys.exit(3)
'''


class UpgradeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='tuist upgrade tests ')
        self.base = Path(self.temp.name)
        self.repo = self.base/'repo with spaces'
        (self.repo/'scripts').mkdir(parents=True)
        shutil.copy2(SOURCE/'upgrade-tuist.py', self.repo/'scripts/upgrade-tuist.py')
        (self.repo/'scripts/swiftgen.sh').write_text('exit 0\n')
        (self.repo/'mise.toml').write_text('[tools]\ntuist = "4.200.4" # 保留注释\n')
        (self.repo/'Tuist').mkdir()
        (self.repo/'Tuist/Package.resolved').write_text('locked')
        self.bin = self.base/'bin'
        self.bin.mkdir()
        for name in ('git','mise','open','swiftgen'):
            path=self.bin/name;path.write_text(FAKE);path.chmod(0o755)
        self.env={**os.environ,'PATH':str(self.bin)+os.pathsep+os.environ['PATH'],
                  'FIXTURE':str(self.base),'REAL_GIT':REAL_GIT}
        items=[]
        for value in ('4.33.0','4.100.0','4.200.4','1.0.0'):
            path=self.base/'installs/tuist'/value
            path.mkdir(parents=True)
            items.append(dict(version=value,installed=True,active=False,install_path=str(path)))
        # 模拟 Homebrew / 外部关联安装，必须保留。
        external=self.base/'external';external.mkdir()
        path=self.base/'installs/tuist/1.0.0';path.rmdir();path.symlink_to(external)
        (self.base/'installed.json').write_text(json.dumps(items))
        self.git('init','-b','develop-tuist');self.git('config','user.name','测试')
        self.git('config','user.email','test@example.com');self.git('add','.')
        self.git('commit','-m','测试初始状态')

    def tearDown(self):
        self.temp.cleanup()

    def git(self,*args):
        return subprocess.check_output([REAL_GIT,*args],cwd=self.repo,stderr=subprocess.DEVNULL,text=True)

    def invoke(self,*args,failure='',code=0):
        result=subprocess.run([sys.executable,'scripts/upgrade-tuist.py',*args],cwd=self.repo,
                              env={**self.env,'FAIL_STAGE':failure},text=True,capture_output=True)
        self.assertEqual(result.returncode,code,result.stdout+result.stderr)
        return result

    def test_check_is_read_only_even_when_dirty(self):
        (self.repo/'dirty').write_text('保留')
        self.invoke('--check')
        commands=(self.base/'commands').read_text()
        self.assertNotIn('mise install ',commands)
        self.assertFalse((self.repo/'.git/dependency-switch.lock').exists())
        self.assertFalse((self.repo/'.git/tuist-upgrade-state.json').exists())
        self.assertIn('4.200.4',(self.repo/'mise.toml').read_text())

    def test_query_download_dependency_generation_and_version_failures(self):
        for failure in ('query','download','dependencies','generate','version'):
            with self.subTest(failure=failure):
                self.invoke(failure=failure,code=1)
                self.assertIn('4.200.4',(self.repo/'mise.toml').read_text())
                self.assertFalse((self.repo/'.git/tuist-upgrade-state.json').exists())
                self.assertNotIn('mise uninstall ',(self.base/'commands').read_text())
                self.assertFalse((self.repo/'.git/dependency-switch.lock').exists())

    def test_success_keeps_previous_referenced_and_external(self):
        self.invoke()
        self.assertIn('4.212.0',(self.repo/'mise.toml').read_text())
        self.assertIn('# 保留注释',(self.repo/'mise.toml').read_text())
        commands=(self.base/'commands').read_text()
        self.assertIn('mise uninstall tuist@4.100.0',commands)
        for value in ('4.33.0','4.200.4','1.0.0'):
            self.assertNotIn('mise uninstall tuist@'+value,commands)
        record=json.loads((self.repo/'.git/tuist-upgrade-state.json').read_text())
        self.assertEqual(record,dict(current='4.212.0',previous='4.200.4'))
        self.git('add','mise.toml');self.git('commit','-m','保存升级版本')
        self.invoke()
        self.assertEqual(record,json.loads((self.repo/'.git/tuist-upgrade-state.json').read_text()))
        self.assertEqual(self.git('status','--porcelain'),'')

    def test_already_latest_without_state_preserves_best_older(self):
        config=self.repo/'mise.toml'
        config.write_text(config.read_text().replace('4.200.4','4.212.0'))
        self.git('add','mise.toml');self.git('commit','-m','预先使用最新版')
        self.invoke()
        record=json.loads((self.repo/'.git/tuist-upgrade-state.json').read_text())
        self.assertEqual(record['previous'],'4.200.4')
        self.assertEqual(self.git('status','--porcelain'),'')

    def test_lock_change_stops_without_resetting(self):
        self.invoke(failure='lock',code=1)
        self.assertEqual((self.repo/'Tuist/Package.resolved').read_text(),'changed')
        self.assertIn('4.200.4',(self.repo/'mise.toml').read_text())
        self.assertNotIn('mise uninstall ',(self.base/'commands').read_text())

    def test_cleanup_failure_preserves_upgrade(self):
        self.invoke(failure='cleanup',code=2)
        self.assertIn('4.212.0',(self.repo/'mise.toml').read_text())
        self.assertIn('open RxStudy.xcworkspace',(self.base/'commands').read_text())

    def test_dirty_lock_and_git_operation(self):
        (self.repo/'dirty').write_text('保留')
        self.invoke(code=1);(self.repo/'dirty').unlink()
        lock=self.repo/'.git/dependency-switch.lock';lock.mkdir()
        self.invoke(code=1);lock.rmdir()
        (self.repo/'.git/MERGE_HEAD').write_text(self.git('rev-parse','HEAD'))
        self.invoke(code=1)

    def test_other_branch_explains_switch_command(self):
        self.git('switch','-c','develop-pods')
        result=self.invoke(code=1)
        self.assertIn('switch-dependencies.sh tuist',result.stderr)
        self.invoke('--check')


if __name__ == '__main__':
    unittest.main()
