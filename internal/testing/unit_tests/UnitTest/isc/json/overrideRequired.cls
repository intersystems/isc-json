Class UnitTest.isc.json.overrideRequired Extends (%pkg.isc.json.adaptor, %UnitTest.TestCase)
{

/// This will break compilation if the default mapping isn't suppressed.
Property RequiredProp As %String [ Required ];

Property NonRequiredProp As %String;

XData InvertedMapping [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping">
<Property Name="RequiredProp" Required="false"/>
<Property Name="NonRequiredProp" Required="true"/>
</Mapping>
}

Method TestCompilingMe()
{
	// Gets Generator test coverage credit!
	Do $$$AssertStatusOK($System.OBJ.Compile($classname(),"ck/nomulticompile"))
}

/// Make sure custom mapping works bidirectionally
Method TestCustomMapping()
{
	Set json = {"RequiredProp": "foo"}
	Set sc = ..%JSONImport(json)
	do $$$AssertStatusOK(sc, "Object with only required properties imports using default mapping.")
	
	Set json = {"NonRequiredProp": "bar"}
	Set sc = ..%JSONImport(json)
	do $$$AssertStatusNotOK(sc, "Object with only non-required properties fails to import using default mapping.")
	
	Set json = {"RequiredProp": "foo"}
	Set sc = ..%JSONImport(json, "InvertedMapping")
	do $$$AssertStatusNotOK(sc, "Object with only required properties fails to import using inverted mapping")

	Set json = {"NonRequiredProp": "bar"}
	Set sc = ..%JSONImport(json, "InvertedMapping")
	do $$$AssertStatusOK(sc, "Object with only non-required properties imports using inverted mapping.")
}

}