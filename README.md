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

### 1 Table from multiple projects

The following configuration will pull the strings from 2 projects, merge the resources and output a single table. The way keys are overriden is based on the projects ordering, in the following example, strings in `dummy2` will override ones in `dummy1`.

```
---
- locales:
    - en
    - fr
  directory: app/res
  platform: android
  projects:
    - key: dummy1
    - key: dummy2
```

### Using multiple tables

Below is the configuration to create mutliple tables, each based on a single project.

It will create 2 tables, one with the default name and a second named `Other`. This will output `Other.strings/stringdict` on iOS and `other.xml` on Android.

```
---
- platform: android
- projects:
    - key: dummy1
  directory: app/res
  locales:
    - en
    - fr
- table: Other
  projects:
    - key: dummy2
  directory: app/res
  locales:
    - en
    - fr
```

The first item in the array is required and used to specify the defaults. This is then equivalent to

```
- platform: android
  directory: app/res
  locales:
    - en
    - fr
- projects:
    - key: dummy1
- table: Other
  projects:
    - key: dummy2
```

### Including and excluding keys

It is possible to add a list of regex to include and exclude at the project level. The following configuration will create 2 tables based on the same project, one containing only keys starting with `city_` and one containing the rest.

```
- platform: android
  directory: app/res
  locales:
    - en
    - fr
- projects:
    - key: dummy1
    - include: city_.*
- table: Other
  projects:
    - key: dummy1
    - exclude: city_.*
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
