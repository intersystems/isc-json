Include %pkg.isc.json.map

/// Tests for %JSONImport
/// zpm "isc.json test -only -DUnitTest.Case=UnitTest.isc.json.import"
Class UnitTest.isc.json.import Extends UnitTest.isc.json.testBase
{

/// Same-name mapping: parent and SubItem both use "Simple"
Method TestImportWithSameNameMappingOnChild()
{
    #dim inst As UnitTest.isc.json.sample.generalPersistent
    Set inst = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set dobj = {"name":"P1","SubItem":{"code":"C1","value":11}}
    Set sc = inst.%JSONImport(dobj,"Simple")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(inst.Name,"P1")
    Do $$$AssertTrue($IsObject(inst.SubItem))
    Do $$$AssertEquals(inst.SubItem.Code,"C1")
    Do $$$AssertEquals(inst.SubItem.Value,11)
}

/// Different-name mapping: parent chooses child's "CodeOnly"
Method TestImportWithDifferentChildMapping()
{
    #dim inst As UnitTest.isc.json.sample.generalPersistent
    Set inst = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    // Provide both code and value; child mapping CodeOnly should only apply Code
    Set dobj = {"Name":"P2","SubItem":{"code":"C2","value":999}}
    Set sc = inst.%JSONImport(dobj,"ParentChildAlt")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(inst.Name,"P2")
    Do $$$AssertEquals(inst.SubItem.Code,"C2")
    // Value should be left unset by CodeOnly mapping
    Do $$$AssertEquals(inst.SubItem.Value,"")
}

/// Invalid child mapping referenced for SubItem should be rejected
Method TestImportInvalidChildMappingForSubItem()
{
    #dim inst As UnitTest.isc.json.sample.generalPersistent
    Set inst = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set dobj = {"Name":"Bad","SubItem":{"code":"C3","value":3}}
    Set sc = inst.%JSONImport(dobj,"InvalidChildMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

/// Invalid child mapping referenced for SubItemPersistent should be rejected
Method TestImportInvalidChildMappingForSubItemPersistent()
{
    #dim inst As UnitTest.isc.json.sample.generalPersistent
    Set inst = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set dobj = {"Name":"Bad2","SubItemPersistent":{"code":"PC","value":4}}
    Set sc = inst.%JSONImport(dobj,"InvalidChildMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

}
