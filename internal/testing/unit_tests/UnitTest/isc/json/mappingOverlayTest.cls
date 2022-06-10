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

}

