"""在临时仓库替换外部工具，验证开关状态、失败恢复与重复执行。"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'switch-flutter.sh'


class FlutterSwitchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='Flutter 开关测试 ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'scripts').mkdir()
        shutil.copy2(SCRIPT, self.root / 'scripts/switch-flutter.sh')
        (self.root / 'RxStudy.xcodeproj').mkdir()
        (self.root / 'flutter_module').mkdir()
        (self.root / 'flutter_module/pubspec.yaml').write_text('name: fixture\n')
        (self.root / 'Podfile').write_text('# 测试配置\n')
        self.project = self.root / 'RxStudy.xcodeproj/project.pbxproj'
        self.project.write_text('// 测试工程\n')
        (self.root / 'Pods').mkdir()
        for name in ('Podfile.lock', 'Pods/Manifest.lock'):
            (self.root / name).write_text('PODS:\n')
        subprocess.run(['git', 'init', '-q', str(self.root)], check=True)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        # PATH 只提供用到的工具，保证缺少 Flutter 的测试不被本机 SDK 干扰。
        for name in ('bash', 'git', 'ruby', 'dirname', 'pwd', 'grep', 'cmp',
                     'uname', 'mkdir', 'rmdir', 'mktemp', 'touch', 'rm', 'tee', 'cat', 'cp'):
            (self.bin / name).symlink_to('/usr/bin/ruby' if name == 'ruby' else shutil.which(name))
        self.tool('xcodebuild', '''
if [ "$1" = clean ]; then
    [ -z "${MOCK_CLEAN_FAIL:-}" ] || exit 18
    printf '%s\\n' "$@" > clean-arguments.txt
fi
''')
        self.tool('flutter', '''
if [ "$1" = precache ]; then
    [ -z "${MOCK_PRECACHE_FAIL:-}" ] || exit 16
    exit 0
fi
[ -z "${MOCK_PUB_FAIL:-}" ] || exit 17
mkdir -p .ios/Flutter
for file in podhelper.rb Generated.xcconfig flutter_export_environment.sh; do
    touch ".ios/Flutter/$file"
done
''')
        self.tool('pod', '''
[ -z "${MOCK_POD_FAIL:-}" ] || exit 19
if [ -f .flutter-enabled ]; then
    printf 'PODS:\\n  - Flutter (1.0.0)\\n  - FlutterPluginRegistrant (0.0.1)\\n' > Podfile.lock
    printf 'Run Flutter Build\\nEmbed Flutter Build\\n' > RxStudy.xcodeproj/project.pbxproj
else
    printf 'PODS:\\n' > Podfile.lock
    printf '// 测试工程\\n' > RxStudy.xcodeproj/project.pbxproj
fi
cp Podfile.lock Pods/Manifest.lock
''')
        self.env = dict(os.environ, PATH=str(self.bin), TMPDIR=str(self.root))

    def tool(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/bash\nset -e\n' + body + '\n')
        path.chmod(0o755)

    def run_switch(self, *args, code=0, env=None, input=None):
        result = subprocess.run(
            ['/bin/bash', str(self.root / 'scripts/switch-flutter.sh'), *args],
            cwd='/private/tmp', env=dict(self.env, **(env or {})),
            input=input, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        )
        self.assertEqual(result.returncode, code, result.stdout)
        return result.stdout

    def test_cycle_and_repeated_commands(self):
        self.run_switch('status')
        for _ in range(2):
            self.run_switch('enable')
            self.assertTrue((self.root / '.flutter-enabled').exists())
            self.assertEqual(self.project.read_text().count('Run Flutter Build'), 1)
        (self.bin / 'flutter').unlink()
        for _ in range(2):
            self.run_switch('disable')
            self.assertFalse((self.root / '.flutter-enabled').exists())
        self.assertTrue((self.root / 'flutter_module/.ios/Flutter/podhelper.rb').exists())

    def test_install_failure_restores_disabled_flag(self):
        self.run_switch('enable', code=19, env={'MOCK_POD_FAIL': '1'})
        self.assertFalse((self.root / '.flutter-enabled').exists())
        self.assertFalse((self.root / '.git/dependency-switch.lock').exists())
        self.assertTrue(list(self.root.glob('rxstudy-flutter-enable.*')))

    def test_install_failure_restores_enabled_flag(self):
        self.run_switch('enable')
        self.run_switch('disable', code=19, env={'MOCK_POD_FAIL': '1'})
        self.assertTrue((self.root / '.flutter-enabled').exists())

    def test_pub_failure_does_not_change_flag(self):
        self.run_switch('enable', code=17, env={'MOCK_PUB_FAIL': '1'})
        self.assertFalse((self.root / '.flutter-enabled').exists())

    def test_precache_failure_does_not_change_flag(self):
        self.run_switch('enable', code=16, env={'MOCK_PRECACHE_FAIL': '1'})
        self.assertFalse((self.root / '.flutter-enabled').exists())

    def test_incomplete_installation_restores_flag(self):
        self.tool('pod', 'exit 0')
        self.assertIn('不一致', self.run_switch('enable', code=1))
        self.assertFalse((self.root / '.flutter-enabled').exists())

    def test_clean_failure_restores_enabled_flag(self):
        self.run_switch('enable')
        self.assertIn('清理 Xcode', self.run_switch(
            'disable', code=18, env={'MOCK_CLEAN_FAIL': '1'}))
        self.assertTrue((self.root / '.flutter-enabled').exists())

    def test_custom_build_directory_is_passed_to_xcode(self):
        custom = str(self.root / '构建 缓存')
        self.run_switch('disable', env={'RXSTUDY_DERIVED_DATA_PATH': custom})
        self.assertIn('-derivedDataPath\n' + custom + '\n',
                      (self.root / 'clean-arguments.txt').read_text())

    def test_missing_tool_and_invalid_arguments(self):
        (self.bin / 'flutter').unlink()
        self.assertIn('缺少工具：flutter', self.run_switch('enable', code=1))
        self.run_switch('invalid', code=2)
        self.run_switch('enable', 'extra', code=2)
        self.run_switch('--help')

    def test_status_is_read_only_and_detects_partial_installation(self):
        self.tool('flutter', 'exit 99')  # status 不得执行 Flutter 命令。
        self.run_switch('status')
        before = self.project.read_bytes()
        self.project.write_text('Run Flutter Build\n')
        self.assertIn('不一致', self.run_switch('status', code=1))
        self.assertEqual(self.project.read_text(), 'Run Flutter Build\n')
        self.project.write_bytes(before)
        (self.root / 'Podfile.lock').write_text('PODS:\n  - Flutter (1.0.0)\n')
        self.run_switch('status', code=1)

    def test_shared_lock_and_missing_project(self):
        (self.root / '.git/dependency-switch.lock').mkdir()
        self.assertIn('已有依赖切换任务', self.run_switch('enable', code=1))
        self.project.unlink()
        self.assertIn('缺少 CocoaPods', self.run_switch('enable', code=1))

    def test_menu(self):
        self.assertIn('配置与安装结果一致', self.run_switch(input='3\n'))


if __name__ == '__main__':
    unittest.main()
