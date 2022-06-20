# isc.json

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased - 2.0.0+snapshot]

### Added 
- APPS-13390: New error macros in class `%pkg.isc.json.localization`

### Changed
- APPS-13390: Updated to use approriate error macros instead of `$$$GeneralError`
- APPS-13385: Remove orphaned code in include file `%pkg.isc.json.map`

### Fixed
- APPS-13384: Mapping cannot override a property from `<Call>` to remove it entirely

### Security
-

### Removed
- APPS-13390: Include file `%pkg.isc.json.cos`
- APPS-13390: All `%pkg.isc.json.dataType.*` classes 
- APPS-13390: Overridden error macros for working on Cache (now only supported on IRIS so not needed)

### Deprecated
-

## [1.0.0] - 2022-04-21
- Last released version before CHANGELOG existed.

