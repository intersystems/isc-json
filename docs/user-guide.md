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
To project a %List datatype to/from a JSON array, use the %pkg.isc.json.dataType.list datatype instead of %List.

Example:
```
Class isc.sample.json.list Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Property listProperty As %pkg.isc.json.dataType.list;

ClassMethod Demo()
{
	set inst = ..%New()
	
	do inst.%JSONExport()
	// Output: {"listProperty":[]}
	write !
	set inst.listProperty = $ListBuild(1,2,3,"a","b","c")
	
	do inst.%JSONExport()
	// Output: {"listProperty":[1,2,3,"a","b","c"]}
	write !
	
	do inst.%JSONImport({"listProperty":[7,8,9,"x","y","z"]})
	zwrite inst.listProperty
	// Output: $lb(7,8,9,"x","y","z")
}

}
```

### Including row IDs in JSON projection of persistent classes
To include row IDs in a JSON projection of a persistent class, override the `%JSONINCLUDEID` class parameter and set it to 1. The name of the ID property defaults to `"_id"` but can be customized by overriding the `%JSONIDFIELD` class parameter and providing a different value.

In an XData mapping block, projection of the ID is controlled equivalently through the IncludeID and IDField attributes of the top-level <Mapping> element.

Example:
```
Class isc.sample.json.persistent Extends (%Persistent, %pkg.isc.json.adaptor)
{

Parameter %JSONINCLUDEID = 1;

Property name As %String;

XData AltMapping [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IncludeID="true" IDField="rowID">
<Property Name="name" />
</Mapping>
}

ClassMethod Demo()
{
	do ..%KillExtent()
	
	set inst = ..%New()
	set inst.name = "Klingman,Paul I." //##class(%PopulateUtils).Name()
	do inst.%Save()
	
	do inst.%JSONExport()
	// Outputs: {"_id":1,"name":"Klingman,Paul I."}
	
	write !
	do inst.%JSONExport("AltMapping")
	// Outputs: {"rowID":1,"name":"Klingman,Paul I."}
	
	// BUT this will not set inst to be ID 1 - it creates a clone
	set inst = ..%New()
	do inst.%JSONImport({"_id":1,"name":"Klingman,Paul I."})
	do inst.%Save()
	write !,inst.%Id()
	// Outputs: 2
}

Storage Default
{
<Data name="persistentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
</Data>
<DataLocation>^isc.sample.json.persistentD</DataLocation>
<DefaultData>persistentDefaultData</DefaultData>
<IdLocation>^isc.sample.json.persistentD</IdLocation>
<IndexLocation>^isc.sample.json.persistentI</IndexLocation>
<StreamLocation>^isc.sample.json.persistentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
```

### Layering/extending mappings within a given class
XData Mapping blocks can now include a `<Call />` element with an optional Mapping attribute set to the name of a different XData block defined in the class. (If not specified, the class's default mapping is used.) This allows JSON projection data in these XData blocks to be reused within the class rather than duplicating the same list of properties repeatedly. The same property can be projected differently in multiple JSON fields (say, as both an ID and an embedded dynamic object), or can be overridden to have different behavior (e.g., setting Include to INPUTONLY/OUTPUTONLY/NONE).

Example:

```
Class isc.sample.json.callMapping Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Property Name As %String;

Property DOB As %Date;

Property SSN As %String;

XData NameOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<Property Name="Name" FieldName="name" />
</Mapping>
}

XData Everything [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<!-- Reuse the NameOnly mapping, adding dob and ssn properties. -->
<Call Mapping="NameOnly" />
<Property Name="DOB" FieldName="dob" />
<Property Name="SSN" FieldName="ssn" />
</Mapping>
}

XData SSNInputOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<!-- Call the default mapping, but make SSN input only. -->
<Call />
<Property Name="SSN" FieldName="SSN" Include="INPUTONLY" />
</Mapping>
}

XData NoSSN [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<Call />
<Property Name="SSN" FieldName="SSN" Include="NONE" />
</Mapping>
}

ClassMethod Demo()
{
	Set inst = ..%New()
	Set inst.Name = "Tester, Fred G."
	Set inst.SSN = "123-45-6789"
	Set inst.DOB = 66267 //2022-06-07
	
	Write !,"NameOnly: "
	Do inst.%JSONExport("NameOnly")
	// Output: {"name":"Tester, Fred G."}
	
	Write !,"Everything: "
	Do inst.%JSONExport("Everything")
	// Output: {"name":"Tester, Fred G.","dob":"2022-06-07","ssn":"123-45-6789"}
	
	Write !,"SSNInputOnly: "
	Do inst.%JSONExport("SSNInputOnly")
	// Output: {"Name":"Tester, Fred G.","DOB":"2022-06-07"}
	
	Write !,"NoSSN: "
	Do inst.%JSONExport("NoSSN")
	// Output: {"Name":"Tester, Fred G.","DOB":"2022-06-07"}
	
	Do inst.%JSONImport({"SSN":"234-56-7890"},"NoSSN")
	Write !,"SSN: ", inst.SSN
	// Output: 123-45-6789 (unchanged)
	
	Do inst.%JSONImport({"SSN":"234-56-7890"},"SSNInputOnly")
	Write !,"SSN: ", inst.SSN
	// Output: 234-56-7890 (changed)
}

}
```

### PascalCase->camelCase property name conversion
A common pattern we see is preference for PascalCase property names in ObjectScript classes and camelCase in JSON representations. Rather than requiring an XData Mapping to be defined in this case, a developer can override the `%JSONFIELDNAMEASCAMELCASE` parameter and set it to 1.
	
Example:
```
Class isc.sample.json.pascalCase Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Parameter %JSONFIELDNAMEASCAMELCASE As BOOLEAN = 1;

Property FirstName As %String;

Property LastName As %String;

ClassMethod Demo()
{
	Set inst = ..%New()
	Set inst.FirstName = "Tim"
	Set inst.LastName = "Leavitt"
	
	Do inst.%JSONExport()
	// Output: {"firstName":"Tim","lastName":"Leavitt"}
}

}
```

## Related Topics in InterSystems Documentation
* [Using the JSON Adaptor](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GJSON_adaptor)
