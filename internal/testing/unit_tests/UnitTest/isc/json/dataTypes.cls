Class UnitTest.isc.json.dataTypes Extends (%pkg.isc.json.adaptor, %UnitTest.TestCase)
{

Property Integer As %Integer [ InitialExpression = 1 ];

Property Boolean As %Boolean [ InitialExpression = 0 ];

Property String As %String [ InitialExpression = "hello world" ];

Property StringWithLists As %String(DISPLAYLIST = ",a,b,c", JSONLISTPARAMETER = "DISPLAYLIST", VALUELIST = ",1,2,3") [ InitialExpression = 1 ];

Property Date As %Date [ InitialExpression = {+$h} ];

Property Time As %Time [ InitialExpression = {+$p($h,",",2)} ];

Property TimeStamp As %TimeStamp [ InitialExpression = {$zdt($h,3)} ];

Property ArrayList As %pkg.isc.json.dataType.list [ InitialExpression = {$ListBuild(1,,2,3)} ];

Property ReferenceObject As %DynamicObject(%JSONINCLUDE = "NONE");

Property JObject As %DynamicObject;

Property JArray As %DynamicArray;

Property JAnyAsObject As %DynamicAbstractObject;

Property JAnyAsArray As %DynamicAbstractObject;

Property IntOrString As UnitTest.isc.json.sample.intOrString;

XData IntOrStringOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping">
<Property Name="IntOrString" />
</Mapping>
}

Method %OnNew(initvalue) As %Status
{
	set sc = ##super(initvalue)
	set ..JObject = { "a":1 }
	set ..JArray = [ 1,2,3 ]
	set ..JAnyAsObject = { "a":2 }
	set ..JAnyAsArray = [ 10,20,30]
	Quit sc
}

Method TestAAAALogJSON()
{
	// Named so that it runs first
	Do $$$AssertStatusOK(..%JSONExportToString(.tJSON))
	Do $$$LogMessage(tJSON)
	Set ..ReferenceObject = {}.%FromJSON(tJSON)
}

Method TestInteger()
{
	Do $$$AssertEquals(..ReferenceObject.%GetTypeOf("Integer"),"number")
	Do $$$AssertEquals(..ReferenceObject.Integer,..Integer)
}

Method TestBoolean()
{
	Do $$$AssertEquals(..ReferenceObject.%GetTypeOf("Boolean"),"boolean")
	Do $$$AssertEquals(..ReferenceObject.Boolean,..Boolean)
}

Method TestString()
{
	Do $$$AssertEquals(..ReferenceObject.String,..String)
}

Method TestStringValuelist()
{
	Do $$$AssertEquals(..ReferenceObject.StringWithLists,..StringWithListsLogicalToDisplay(..StringWithLists))
}

Method TestDate()
{
	Do $$$AssertEquals(..ReferenceObject.Date,$zd(..Date,3))
}

Method TestTime()
{
	Do $$$AssertEquals(..ReferenceObject.Time,$zt(..Time)_"Z")
}

Method TestTimeStamp()
{
	Do $$$AssertEquals(..ReferenceObject.TimeStamp,$Replace(..TimeStamp," ","T")_"Z")
}

Method TestListArray()
{
	Do $$$AssertEquals(..ReferenceObject.ArrayList.%Get(0),$ListGet(..ArrayList,1))
	Do $$$AssertEquals(..ReferenceObject.ArrayList.%GetTypeOf(1),"null")
	Do $$$AssertEquals(..ReferenceObject.ArrayList.%Get(2),$ListGet(..ArrayList,3))
	Do $$$AssertEquals(..ReferenceObject.ArrayList.%Get(3),$ListGet(..ArrayList,4))
}

Method TestEndtoEnd()
{
	// Convert from dynamic object -> JSON string -> this object
	Set tJSON = ..ReferenceObject.%ToJSON()
	Set tComparison = ..%New($$$NULLOREF)
	Do $$$AssertStatusOK(tComparison.%JSONImport(tJSON))
	
	For tProp = "Integer","Boolean","String","StringWithLists","Date","Time","TimeStamp" {
		Do $$$AssertEquals($Property(tComparison,tProp),$Property($This,tProp),"tComparison."_tProp_"==.."_tProp)
	}
	
	Do $$$AssertEquals($ListGet(tComparison.ArrayList,1),1)
	Do $$$AssertEquals($ListData(tComparison.ArrayList,2),0)
	Do $$$AssertEquals($ListGet(tComparison.ArrayList,3),2)
	Do $$$AssertEquals($ListGet(tComparison.ArrayList,4),3)
}

Method TestCompilingMe()
{
	// Gets Generator test coverage credit!
	Do $$$AssertStatusOK($System.OBJ.Compile($classname(),"ck/display=none/nomulticompile"))
}

Method TestLogicalToJSONDirect()
{
	// Gets direct test coverage credit on %pkg.isc.json.dataType.list
	Do $$$AssertEquals(##class(%pkg.isc.json.dataType.list).LogicalToJSON($lb(1,,2,3,)).%ToJSON(),"[1,null,2,3,null]")
	Do $$$AssertEquals(##class(%pkg.isc.json.dataType.list).JSONToLogical([1,null,2,3,null]),$lb(1,,2,3,))
}

Method TestDynamicObject()
{
	Do $$$AssertEquals(..ReferenceObject.%GetTypeOf("JObject"),"object")
	Do $$$AssertEquals(..ReferenceObject.JObject.%ToJSON(),..JObject.%ToJSON())
}

Method TestDynamicArray()
{
	Do $$$AssertEquals(..ReferenceObject.%GetTypeOf("JArray"),"array")
	Do $$$AssertEquals(..ReferenceObject.JArray.%ToJSON(),..JArray.%ToJSON())
}

Method TestAnyAsObject()
{
	Do $$$AssertEquals(..ReferenceObject.%GetTypeOf("JAnyAsObject"),"object")
	Do $$$AssertEquals(..ReferenceObject.JAnyAsObject.%ToJSON(),..JAnyAsObject.%ToJSON())
}

Method TestAnyAsArray()
{
	Do $$$AssertEquals(..ReferenceObject.%GetTypeOf("JAnyAsArray"),"array")
	Do $$$AssertEquals(..ReferenceObject.JAnyAsArray.%ToJSON(),..JAnyAsArray.%ToJSON())
}

Method TestDynamicArrayAsObject()
{
	// Set an object into an array property
	set newobj = ..%New($$$NULLOREF)
	Set newobj.JArray = { "a":10 }
	Do newobj.%JSONExportToString(.json)
	set sc = newobj.%JSONImport( json )
	if $$$ISOK(sc) {
		Do $$$AssertFailure("Expected Error when importing %DynamicObject into %DynamicArray property")
	} else {
		Do $$$AssertSuccess("Got Error when importing %DynamicObject into %DynamicArray property")
	}
}

Method TestDynamicObjectAsArray()
{
	// Set an array into an object property
	Set newobj = ..%New($$$NULLOREF)
	Set newobj.JObject = [ "a","b"]
	Do newobj.%JSONExportToString(.json)
	set sc = newobj.%JSONImport( json )
	if $$$ISOK(sc) {
		Do $$$AssertFailure("Expected Error when importing %DynamicArray into %DynamicObject property")
	} else {
		Do $$$AssertSuccess("Got Error when importing %DynamicArray into %DynamicObject property")
	}
}

Method TestRuntimeIntOrString()
{
	// String
	Set json = { "IntOrString": "string" }
	Set o = ..%New($$$NULLOREF)
	Set sc = o.%JSONImport(json)
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(o.IntOrString,"string")
	Kill str
	Set sc = o.%JSONExportToString(.str,"IntOrStringOnly")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(str,json.%ToJSON())
	
	// Integer
	Set json = { "IntOrString": 1234 }
	Set o = ..%New($$$NULLOREF)
	Set sc = o.%JSONImport(json)
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(o.IntOrString,1234)
	Kill str
	Set sc = o.%JSONExportToString(.str,"IntOrStringOnly")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(str,json.%ToJSON())

	// Boolean - should fail
	Set json = { "IntOrString": true }
	Set o = ..%New($$$NULLOREF)
	Set sc = o.%JSONImport(json)
	Do $$$AssertStatusNotOK(sc)
}

}
