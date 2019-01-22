# loco plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-loco)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-loco`, add it to your project by adding the following line to your pluginfile :

`gem 'fastlane-plugin-loco', git: 'https://github.com/JohnPaulConcierge/fastlane-plugin-loco.git'`



<!-- ```bash
fastlane add_plugin loco
``` -->

## About loco

Eases up retrieving translations from loco (localise.biz)

This plugin contains a single action `loco`.

This action uses a configuration file to update several string tables based on multiple localise.biz projects.

### 1 Table from 1 project

In its simplest form, a conf file just specifies:
- the locales
- the directory where the resources will be located
- the project from where to pull the strings.
- the plaform

```
---
- locales:
    - en
    - fr
  directory: app/res
  platform: android
  projects:
    - key: dummy1
```

<!-- ## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary) -->

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
