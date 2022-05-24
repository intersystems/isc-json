# isc.json User Guide

## Prerequisites

isc.json requires InterSystems IRIS Data Platform 2018.1 or later.

Installation is done via the [Community Package Manager](https://github.com/intersystems-community/zpm):

    zpm "install isc.json"

## The Basics: isc.json is like %JSON

isc.json is a superset of the functionality of the %JSON package. If you are currently extending `%JSON.Adaptor`, you should be able to extend `%pkg.isc.json.adaptor` instead, change the XML namespace of any XData mapping blocks in your classes to `http://www.intersystems.com/_pkg/isc/json/jsonmapping` instead of `http://www.intersystems.com/jsonmapping`, and everything else should "just work."

Similarly, our intent is that in some future version of IRIS, you'll be able to change *back* to %JSON.Adaptor and the old XML namespace, and that will "just work" - but it'll take some time to get there, and we'd like to iterate on JSON features with community involvement. We reserve the right to reverse course on decisions made here, but will do so following semantic versioning on this package.

The first place to start on understanding isc.json is to read up on the %JSON package: [Using the JSON Adaptor](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GJSON_adaptor)

## Overview: What's new in isc.json

Features:
* Support for %List datatype projection to/from arrays
* Ability to easily include row IDs in JSON projection of persistent classes
* "Studio Assist" schema for XData blocks
* Ability to layer/extend mappings within a given class
* Ability to replace collections rather than append on %JSONImport
* Support for simple PascalCase->camelCase conversion by convention

Bug fixes:
* Non-JSON-related XData blocks don't make class compilation fail
* You can define %JSONMAPPING for a single property via property parameter
* %JSONNew gets the proper dynamic object level
* %JSONImport doesn't fail on calculated fields

## Feature Documentation

### Projecting %List datatypes to/from arrays
TODO

### Including row IDs in JSON projection of persistent classes
TODO

### Layering/extending mappings within a given class
TODO

### PascalCase->camelCase property name conversion
TODO

## Related Topics in InterSystems Documentation
TODO

* [Using the JSON Adaptor](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GJSON_adaptor)
