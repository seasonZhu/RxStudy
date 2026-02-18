fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios pg

```sh
[bundle exec] fastlane ios pg
```

集成到蒲公英,预生产环境与生产环境,打包命令:fastlane pg version:1.0.0 mode:Debug/Release env:test/pre/pro changelog:引号加上内容

### ios beta

```sh
[bundle exec] fastlane ios beta
```

集成到testflight测试,用于上架前的冒烟,生产环境,注意version需要在Xcode里面手动写好,build号会自动在当前的build上面+1,比如你想要打build为1,那么Xcode中就填写0,打包命令:fastlane beta showSDKInfo:true changelog:引号加上内容

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
