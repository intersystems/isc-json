/// zpm "isc.json test -only -DUnitTest.Case=UnitTest.isc.json.mappingOverlayTest"
Class UnitTest.isc.json.mappingOverlayTest Extends %UnitTest.TestCase
{

Method TestImportNameOnly()
{
	Set inst = ..GetImportedObject("NameOnly")
	Do $$$AssertEquals(inst.Name,"Tester, Fred G.")
	Do $$$AssertEquals(inst.SSN,"")
	Do $$$AssertEquals(inst.DOB,"")
}

Method TestExportNameOnly()
{
	Set exportedString = ..GetExportedString("NameOnly")
	Do $$$AssertEquals(exportedString,"{""name"":""Tester, Fred G.""}")
}

Method TestImportEverything()
{
	Set inst = ..GetImportedObject("Everything")
	Do $$$AssertEquals(inst.Name,"Tester, Fred G.")
	Do $$$AssertEquals(inst.SSN,"123-45-6789")
	Do $$$AssertEquals(inst.DOB,66267)
}

Method TestExportEverything()
{
	Set exportedString = ..GetExportedString("Everything")
	Do $$$AssertEquals(exportedString,"{""name"":""Tester, Fred G."",""dob"":""2022-06-07"",""ssn"":""123-45-6789""}")
}

Method TestImportSSNInputOnly()
{
	Set inst = ..GetImportedObject("SSNInputOnly",{"Name":"Tester, Fred G.","SSN":"123-45-6789","DOB":"2022-06-07"})
	Do $$$AssertEquals(inst.Name,"Tester, Fred G.")
	Do $$$AssertEquals(inst.SSN,"123-45-6789")
	Do $$$AssertEquals(inst.DOB,66267)
}

Method TestExportSSNInputOnly()
{
	Set exportedString = ..GetExportedString("SSNInputOnly")
	Do $$$AssertEquals(exportedString,"{""Name"":""Tester, Fred G."",""DOB"":""2022-06-07""}")
}

Method TestImportNoSSN()
{
	Set inst = ..GetImportedObject("NoSSN",{"Name":"Tester, Fred G.","SSN":"123-45-6789","DOB":"2022-06-07"})
	Do $$$AssertEquals(inst.Name,"Tester, Fred G.")
	Do $$$AssertEquals(inst.SSN,"")
	Do $$$AssertEquals(inst.DOB,66267)
}

Method TestExportNoSSN()
{
	Set exportedString = ..GetExportedString("NoSSN")
	Do $$$AssertEquals(exportedString,"{""Name"":""Tester, Fred G."",""DOB"":""2022-06-07""}")
}

Method GetExportedString(mapping As %String) As %String
{
	Set inst = ##class(UnitTest.isc.json.mappingOverlay).%New()
	Set inst.Name = "Tester, Fred G."
	Set inst.SSN = "123-45-6789"
	Set inst.DOB = 66267 //2022-06-07
	Do $$$AssertStatusOK(inst.%JSONExportToString(.string,mapping))
	Quit string
}

Method GetImportedObject(mapping As %String, object As %DynamicAbstractObject = {{"name":"Tester, Fred G.","ssn":"123-45-6789","dob":"2022-06-07"}}) As UnitTest.isc.json.mappingOverlay
{
	Set inst = ##class(UnitTest.isc.json.mappingOverlay).%New()
	Do $$$AssertStatusOK(inst.%JSONImport(object,mapping))
	Quit inst
}

Method TestMappingInfoDefault()
{
	#dim mappingInfo As %pkg.isc.json.mappingInfo
	Set sc = ##class(UnitTest.isc.json.mappingOverlay).%JSONMappingInfo(.mappingInfo)
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(mappingInfo.Classname,"UnitTest.isc.json.mappingOverlay")
	Do $$$AssertEquals(mappingInfo.IgnoreInvalidField,0)
	Do $$$AssertEquals(mappingInfo.Properties.Count(),3)
	Set name = mappingInfo.Properties.GetAt(1)
	Do $$$AssertEquals(name.Name,"Name")
	Do $$$AssertEquals(name.FieldName,"Name")
	Set dob = mappingInfo.Properties.GetAt(2)
	Do $$$AssertEquals(dob.Name,"DOB")
	Do $$$AssertEquals(dob.FieldName,"DOB")
	Set ssn = mappingInfo.Properties.GetAt(3)
	Do $$$AssertEquals(ssn.Name,"SSN")
	Do $$$AssertEquals(ssn.FieldName,"SSN")
}

Method TestMappingInfoNameOnly()
{
	#dim mappingInfo As %pkg.isc.json.mappingInfo
	Set sc = ##class(UnitTest.isc.json.mappingOverlay).%JSONMappingInfo(.mappingInfo,"NameOnly")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(mappingInfo.Classname,"UnitTest.isc.json.mappingOverlay")
	Do $$$AssertEquals(mappingInfo.IgnoreInvalidField,1)
	Do $$$AssertEquals(mappingInfo.Properties.Count(),1)
	Set name = mappingInfo.Properties.GetAt(1)
	Do $$$AssertEquals(name.Name,"Name")
	Do $$$AssertEquals(name.FieldName,"name")
}

Method TestMappingInfoEverything()
{
	#dim mappingInfo As %pkg.isc.json.mappingInfo
	Set sc = ##class(UnitTest.isc.json.mappingOverlay).%JSONMappingInfo(.mappingInfo,"Everything")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(mappingInfo.Classname,"UnitTest.isc.json.mappingOverlay")
	Do $$$AssertEquals(mappingInfo.IgnoreInvalidField,1)
	Do $$$AssertEquals(mappingInfo.Properties.Count(),3)
	Set name = mappingInfo.Properties.GetAt(1)
	Do $$$AssertEquals(name.Name,"Name")
	Do $$$AssertEquals(name.FieldName,"name")
	Set dob = mappingInfo.Properties.GetAt(2)
	Do $$$AssertEquals(dob.Name,"DOB")
	Do $$$AssertEquals(dob.FieldName,"dob")
	Set ssn = mappingInfo.Properties.GetAt(3)
	Do $$$AssertEquals(ssn.Name,"SSN")
	Do $$$AssertEquals(ssn.FieldName,"ssn")
}

Method TestMappingInfoSSNInputOnly()
{
	#dim mappingInfo As %pkg.isc.json.mappingInfo
	Set sc = ##class(UnitTest.isc.json.mappingOverlay).%JSONMappingInfo(.mappingInfo,"SSNInputOnly")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(mappingInfo.Classname,"UnitTest.isc.json.mappingOverlay")
	Do $$$AssertEquals(mappingInfo.IgnoreInvalidField,1)
	Do $$$AssertEquals(mappingInfo.Properties.Count(),3)
	Set name = mappingInfo.Properties.GetAt(1)
	Do $$$AssertEquals(name.Name,"Name")
	Do $$$AssertEquals(name.FieldName,"Name")
	Set dob = mappingInfo.Properties.GetAt(2)
	Do $$$AssertEquals(dob.Name,"DOB")
	Do $$$AssertEquals(dob.FieldName,"DOB")
	Set ssn = mappingInfo.Properties.GetAt(3)
	Do $$$AssertEquals(ssn.Name,"SSN")
	Do $$$AssertEquals(ssn.FieldName,"SSN")
	Do $$$AssertEquals(ssn.Include,"inputonly")
}

Method TestMappingInfoNoSSN()
{
	#dim mappingInfo As %pkg.isc.json.mappingInfo
	Set sc = ##class(UnitTest.isc.json.mappingOverlay).%JSONMappingInfo(.mappingInfo,"NoSSN")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(mappingInfo.Classname,"UnitTest.isc.json.mappingOverlay")
	Do $$$AssertEquals(mappingInfo.IgnoreInvalidField,1)
	Do $$$AssertEquals(mappingInfo.Properties.Count(),2)
	Set name = mappingInfo.Properties.GetAt(1)
	Do $$$AssertEquals(name.Name,"Name")
	Do $$$AssertEquals(name.FieldName,"Name")
	Set dob = mappingInfo.Properties.GetAt(2)
	Do $$$AssertEquals(dob.Name,"DOB")
	Do $$$AssertEquals(dob.FieldName,"DOB")
}

Method TestMappingInfoInvalidMapping()
{
	#dim mappingInfo As %pkg.isc.json.mappingInfo
	Set sc = ##class(UnitTest.isc.json.mappingOverlay).%JSONMappingInfo(.mappingInfo,"MyInvalidMapping")
	Do $$$AssertStatusOK(sc)
	Do $$$AssertEquals(mappingInfo,"")
}

}

