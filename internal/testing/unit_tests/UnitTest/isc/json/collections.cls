Class UnitTest.isc.json.collections Extends %UnitTest.TestCase
{

Method TestListWithoutProperty()
{
	Set obj = ..GetTestObject()
	Do obj.%JSONImport({})
	Do $$$AssertEquals(obj.Strings.Count(),1)
	Do $$$AssertEquals(obj.Strings.GetAt(1),"violin")
}

Method TestEmptyList()
{
	Set obj = ..GetTestObject()
	Do obj.%JSONImport({"Strings":[]})
	Do $$$AssertEquals(obj.Strings.Count(),0)
}

Method TestListWithTwoValues()
{
	Set obj = ..GetTestObject()
	Do obj.%JSONImport({"Strings":["viola","cello"]})
	Do $$$AssertEquals(obj.Strings.Count(),2)
	Do $$$AssertEquals(obj.Strings.GetAt(1),"viola")
	Do $$$AssertEquals(obj.Strings.GetAt(2),"cello")
}

Method TestArrayWithoutProperty()
{
	Set obj = ..GetTestObject()
	Do obj.%JSONImport({})
	Do $$$AssertEquals(obj.Map.Count(),1)
	Do $$$AssertEquals(obj.Map.GetAt("MA"),"Boston")
}

Method TestEmptyArray()
{
	Set obj = ..GetTestObject()
	Do obj.%JSONImport({"Map":{}})
	Do $$$AssertEquals(obj.Map.Count(),0)
}

Method TestArrayWithTwoValues()
{
	Set obj = ..GetTestObject()
	Do obj.%JSONImport({"Map":{
		"NH":"Concord",
		"RI":"Providence"
	}})
	Do $$$AssertEquals(obj.Map.Count(),2)
	Do $$$AssertEquals(obj.Map.GetAt("NH"),"Concord")
	Do $$$AssertEquals(obj.Map.GetAt("RI"),"Providence")
}

Method TestArrayWithEscapedProperty()
{
	Set exportObj = ..GetTestObject()
	Set importObj = ##class(UnitTest.isc.json.collectionExample).%New()
	Do exportObj.Map.SetAt("Desert Mouse","Muad""Dib")
	Do $$$AssertStatusOK(exportObj.%JSONExportToString(.tJSON))
	Do $$$AssertStatusOK(importObj.%JSONImport(tJSON))
	Do $$$AssertEquals(importObj.Map.GetAt("Muad""Dib"),"Desert Mouse")
}

Method GetTestObject() As UnitTest.isc.json.collectionExample
{
	Set obj = ##class(UnitTest.isc.json.collectionExample).%New()
	Do obj.Strings.Insert("violin")
	Do obj.Map.SetAt("Boston","MA")
	Quit obj
}

Method TestCompiling()
{
	// Ensure we get test coverage credit for the generator methods being covered here!
	Do $$$AssertStatusOK($System.OBJ.Compile("UnitTest.isc.json.collectionExample","ck-d/nomulticompile"))
}

}

