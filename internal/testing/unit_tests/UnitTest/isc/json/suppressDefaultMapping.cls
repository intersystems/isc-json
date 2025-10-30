Class UnitTest.isc.json.suppressDefaultMapping Extends (%pkg.isc.json.adaptor, %UnitTest.TestCase)
{

/// %JSONDEFAULTMAPPING may be set to 0 (default is 1) to suppress creation of the default JSON mapping for the object.
Parameter %JSONDEFAULTMAPPING As BOOLEAN = 0;

/// This will break compilation if the default mapping isn't suppressed.
Property Foo As UnitTest.isc.json.notJSONAdapted;

Property Bar As %String;

XData CustomMapping [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping">
<Property Name="Bar" FieldName="bar" />
</Mapping>
}

/// Make sure custom mapping works bidirectionally
Method TestCustomMapping()
{
	Set instance = ..%New($$$NULLOREF)
	Set instance.Bar = "baz"
	Do $$$AssertStatusOK(instance.%JSONExportToStream(.stream,"CustomMapping"))
	Set json = {}.%FromJSON(stream)
	Do $$$AssertEquals(json.bar,"baz")
	
	Set imported = ..%New($$$NULLOREF)
	Do $$$AssertStatusOK(imported.%JSONImport(stream,"CustomMapping"))
	Do $$$AssertEquals(imported.Bar,"baz")
}

}

