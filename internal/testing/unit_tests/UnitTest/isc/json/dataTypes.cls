Class UnitTest.isc.json.dataTypes Extends (%pkg.isc.json.adaptor, %UnitTest.TestCase)
{

Property Integer As %pkg.isc.json.dataType.integer [ InitialExpression = 1 ];

Property Boolean As %pkg.isc.json.dataType.boolean [ InitialExpression = 0 ];

Property String As %pkg.isc.json.dataType.string [ InitialExpression = "hello world" ];

Property StringWithLists As %pkg.isc.json.dataType.string(DISPLAYLIST = ",a,b,c", JSONLISTPARAMETER = "DISPLAYLIST", VALUELIST = ",1,2,3") [ InitialExpression = 1 ];

Property Date As %pkg.isc.json.dataType.date [ InitialExpression = {+$h} ];

Property Time As %pkg.isc.json.dataType.time [ InitialExpression = {+$p($h,",",2)} ];

Property TimeStamp As %pkg.isc.json.dataType.timeStamp [ InitialExpression = {$zdt($h,3)} ];

Property ArrayList As %pkg.isc.json.dataType.list [ InitialExpression = {$ListBuild(1,,2,3)} ];

Property ReferenceObject As %DynamicObject(%JSONINCLUDE = "NONE");

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
	Do $$$AssertStatusOK($System.OBJ.Compile($classname(),"ck/nomulticompile"))
}

Method TestLogicalToJSONDirect()
{
	// Gets direct test coverage credit on %pkg.isc.json.dataType.list
	Do $$$AssertEquals(##class(%pkg.isc.json.dataType.list).LogicalToJSON($lb(1,,2,3,)),"[1,null,2,3,null]")
	Do $$$AssertEquals(##class(%pkg.isc.json.dataType.list).JSONToLogical([1,null,2,3,null]),$lb(1,,2,3,))
}

}

