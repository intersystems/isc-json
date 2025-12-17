/// For testing %JSONNew code generation
Class UnitTest.isc.json.sample.jsonNew Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Property Foo As %String(%JSONREQUIRED = 0, MAXLEN = 128) [ Required ];

Property Bar As %String(%JSONREQUIRED = 0, MAXLEN = 128) [ Required ];

Property Baz As %String(MAXLEN = 128);

Property Another As %String(MAXLEN = 128);

Property Combined1 As %String(MAXLEN = 128);

Property Combined2 As %String(MAXLEN = 128);

ClassMethod %JSONNew(dynamicObject As %DynamicObject, containerOref As %RegisteredObject = "") As %RegisteredObject
{
    Set obj = ..%JSONNewDefault(dynamicObject,containerOref)
	If dynamicObject.%Get("_includeDefaults") {
        Set obj.Foo = "DefaultFoo"
        Set obj.Bar = "DefaultBar"
    }
    Return obj
}

}

