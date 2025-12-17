# isc.json

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.5.0] - 2025-09-18

### Added 
- HSIEO-13278: Add %JSONImportArray, %JSONExportToDynamicObject and %JSONExportArray.

### Changed
- HSIEO-13278: Refactor %JSONExport* methods to export to %DynamicObject and have other %JSONExport* methods call out to it. Update datatypes with JSONTYPE of runtime since that is now updated to not need extra escaping for LogicalToJSON().

### Fixed
- HSIEO-13278: Fix bug where invalid mapping would use base mapping. Throw error instead
- HSIEO-13655: Fix ILLEGAL VALUE in export generation due to invalid third arg to %Set() - caused by HSIEO-13278.

## [3.4.1] - 2025-09-03

### Fixed
- HSIEO-13346: Fix %JSONNewDefault handling to avoid METHOD DOES NOT EXIST errors

## [3.4.0] - 2025-08-22

### Added 
- HSIEO-13279: Add new code generated method %JSONNewDefault. This will do default handling for %JSONNew 
which is to return %New() of the corresponding class if not persistent. 
If persistent, try to match against ID or unique indices based on what is available 
(ID will override unique index if both are present).
Update user guide and readme.

## [3.3.0] - 2025-08-06

### Added 
- HSIEO-12322: New JSONTYPE of runtime to dynamically determine JSON type
- HSIEO-10522: Add IDField and IncludeID in jsonMappingInfo

### Changed
- HSIEO-13080: Add Author info to module from "Ownership of AppModules" confluence page

## [3.2.1] - 2024-07-01

### Fixed
- APPS-23837: Array property keys are not properly escaped by generated %JSONExport() code
- APPS-23826: Fix bug in camelCase conversion when second char is a number.
- HSIEO-10881: Fix bug in json generator dynamic object import.

## [3.2.0] - 2024-04-10

### Added 
- APPS-21020: New method %JSONMappingInfo which returns the parsed mapping info for a given JSON mapping given the mapping name. 
Useful for creating utilities that rely on the JSON mapping metadata

## [3.1.0] - 2023-10-18

### Changed
- HSIEO-5398: Ensure `IncludeID` default matches `%JSONINCLUDEID` default of 1.

## [3.0.0] - 2023-09-27

### Changed
- HSIEO-8297: IPM Adoption
- HSIEO-9269, HSIEO-9402: Deprecate % in perforce path

## [2.2.2] - 2023-09-15 

## [2.2.1] - 2023-06-03

## [2.2.0] - 2023-08-16

### Fixed 
- APPS-20986: Ensure `<property name>IsValid()` errors are returned if import fails 
rather than generic JSON import error which obscures away error details.

## [2.1.0] - 2023-03-08

### Added 
- APPS-12974: Add support for %DynamicObject/Array properties, then remove usage of %Extends against
the class being compiled.

## [2.0.1] - 2024-12-04

### Fixed
- #7: Make the library compatible with %IPM v0.9+

## [2.0.0] - 2022-06-21

### Added 
- APPS-13390: New error macros in class `%pkg.isc.json.localization`

### Changed
- APPS-13390: Updated to use approriate error macros instead of `$$$GeneralError`
- APPS-13385: Remove orphaned code in include file `%pkg.isc.json.map`

### Fixed
- APPS-13384: Mapping cannot override a property from `<Call>` to remove it entirely

### Removed
- APPS-13390: Include file `%pkg.isc.json.cos`
- APPS-13390: All `%pkg.isc.json.dataType.*` classes 
- APPS-13390: Overridden error macros for working on Cache (now only supported on IRIS so not needed)

## [1.0.0] - 2022-04-21
- Last released version before CHANGELOG existed.
