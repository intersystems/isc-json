/// Tests for %JSONExportArray
/// zpm "isc.json test -only -v -DUnitTest.Case=UnitTest.isc.json.exportArray"
Class UnitTest.isc.json.exportArray Extends UnitTest.isc.json.testBase
{

Method BuildListOfObjectsPersistent(count As %Integer = 2) As %ListOfObjects
{
    Set list = ##class(%ListOfObjects).%New()
    Set list.ElementType = "UnitTest.isc.json.sample.generalPersistent"
    For i=1:1:count {
        Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
        Set o.Name = ("P"_i)
        Set o.Age = (20+i)
        Do list.Insert(o)
    }
    Quit list
}

/// Accepts %ListOfObjects for persistent classes and projects elements
Method TestPersistentListOfObjects()
{
    Set list = ..BuildListOfObjectsPersistent(2)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(list, "", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertTrue($IsObject(arr))
    Do $$$AssertEquals(arr.%Size(), 2)
    Do $$$AssertEquals($Data(errorLog),0)
    Set o0 = arr.%Get(0)
    Set o1 = arr.%Get(1)
    Do $$$AssertEquals(o0.%Get("Name"), "P1")
    Do $$$AssertEquals(o1.%Get("Age"), 22)
}

/// Accepts raw $LIST of IDs for persistent classes
Method TestPersistentListOfIDsRawList()
{
    Set id1 = ..CreateSavedPersistent("L1", 31)
    Set id2 = ..CreateSavedPersistent("L2", 32)
    Set idlist = $Listbuild(id1, id2)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(idlist, "", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(arr.%Size(), 2)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "L1")
    Do $$$AssertEquals(arr.%Get(1).%Get("Name"), "L2")
    Do $$$AssertEquals($Data(errorLog),0)
}

/// Accepts %ListOfDataTypes of IDs for persistent classes
Method TestPersistentListOfDataTypesIDs()
{
    Set id1 = ..CreateSavedPersistent("D1", 41)
    Set id2 = ..CreateSavedPersistent("D2", 42)
    Set lod = ##class(%ListOfDataTypes).%New()
    Set lod.ElementType = "%Integer"
    Do lod.Insert(id1)
    Do lod.Insert(id2)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(lod, "", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(arr.%Size(), 2)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "D1")
    Do $$$AssertEquals(arr.%Get(1).%Get("Age"), 42)
    Do $$$AssertEquals($Data(errorLog),0)
}

/// Raw $LIST of IDs with an invalid ID accumulates errors (accumulateErrors=true)
Method TestPersistentRawListErrorAccumulation()
{
    Set id1 = ..CreateSavedPersistent("RL1", 71)
    Set badId = 987654321
    Set idlist = $Listbuild(id1, badId)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(idlist, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // One good entry exported, one error logged at index 1 (second element)
    Do $$$AssertEquals(arr.%Size(),1)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "RL1")
    Do $$$AssertTrue($Data(errorLog(1))>0)
}

/// Raw $LIST of IDs stops at first error when accumulateErrors=false
Method TestPersistentRawListStopOnFirstError()
{
    Set id1 = ..CreateSavedPersistent("RL2", 72)
    Set badId = 987654320
    Set id3 = ..CreateSavedPersistent("RL3", 73)
    Set idlist = $Listbuild(id1, badId, id3)
    Kill arr,errorLog
    Set behavior = {"accumulateErrors":0}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(idlist, "", behavior, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // Should stop on badId; only first item exported
    Do $$$AssertEquals(arr.%Size(),1)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"),"RL2")
    // Only one error captured at index 1 (badId)
    Set cnt=0,k="" For  Set k=$Order(errorLog(k)) Quit:(k="")  Set cnt=cnt+1
    Do $$$AssertEquals(cnt,1)
    Do $$$AssertTrue($Data(errorLog(1))>0)
}

/// %ListOfDataTypes with an invalid ID accumulates errors
Method TestPersistentListOfDataTypesErrorAccumulation()
{
    Set id1 = ..CreateSavedPersistent("LD1", 81)
    Set badId = 876543210
    Set lod = ##class(%ListOfDataTypes).%New()
    Set lod.ElementType = "%Integer"
    Do lod.Insert(id1)
    Do lod.Insert(badId)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(lod, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals(arr.%Size(),1)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "LD1")
    Do $$$AssertTrue($Data(errorLog(1))>0)
}

/// %ListOfDataTypes stops at first error when accumulateErrors=false
Method TestPersistentListOfDataTypesStopOnFirstError()
{
    Set id1 = ..CreateSavedPersistent("LD2", 82)
    Set badId = 876543211
    Set id3 = ..CreateSavedPersistent("LD3", 83)
    Set lod = ##class(%ListOfDataTypes).%New()
    Set lod.ElementType = "%Integer"
    Do lod.Insert(id1)
    Do lod.Insert(badId)
    Do lod.Insert(id3)
    Kill arr,errorLog
    Set behavior = {"accumulateErrors":0}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(lod, "", behavior, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals(arr.%Size(),1)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "LD2")
    Set cnt=0,k="" For  Set k=$Order(errorLog(k)) Quit:(k="")  Set cnt=cnt+1
    Do $$$AssertEquals(cnt,1)
    Do $$$AssertTrue($Data(errorLog(1))>0)
}

/// %ListOfObjects per-element export errors when mapping is invalid (accumulateErrors=true)
Method TestPersistentListOfObjectsErrorAccumulationInvalidMapping()
{
    Set list = ..BuildListOfObjectsPersistent(2)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(list, "AltMap", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // No entries exported as mapping is invalid for all
    Do $$$AssertEquals(arr.%Size(),0)
    // Should log errors for indices 0 and 1 (0-based)
    Do $$$AssertTrue($Data(errorLog(0))>0)
    Do $$$AssertTrue($Data(errorLog(1))>0)
}

/// %ListOfObjects stops at first error when accumulateErrors=false and mapping invalid
Method TestPersistentListOfObjectsStopOnFirstErrorInvalidMapping()
{
    Set list = ..BuildListOfObjectsPersistent(3)
    Kill arr,errorLog
    Set behavior = {"accumulateErrors":0}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(list, "AltMap", behavior, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals(arr.%Size(),0)
    Do $$$AssertTrue($Data(errorLog(0))>0)
}

/// %SQL.StatementResult per-row export errors when mapping invalid (accumulateErrors=true)
Method TestPersistentSQLResultErrorAccumulationInvalidMapping()
{
    Set id1 = ..CreateSavedPersistent("QS1", 91)
    Set id2 = ..CreateSavedPersistent("QS2", 92)
    Set rs = ##class(%SQL.Statement).%ExecDirect(, "SELECT ID FROM UnitTest_isc_json_sample.generalPersistent WHERE ID IN ("_id1_","_id2_") ORDER BY ID")
    $$$ThrowSQLIfError(rs.%SQLCODE, rs.%Message)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(rs, "AltMap", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals(arr.%Size(),0)
    // Expect errors for both returned rows: indices 0 and 1
    Do $$$AssertTrue($Data(errorLog(0))>0)
    Do $$$AssertTrue($Data(errorLog(1))>0)
}

/// %SQL.StatementResult stops at first error when accumulateErrors=false and mapping invalid
Method TestPersistentSQLResultStopOnFirstErrorInvalidMapping()
{
    Set id1 = ..CreateSavedPersistent("QS3", 93)
    Set id2 = ..CreateSavedPersistent("QS4", 94)
    Set rs = ##class(%SQL.Statement).%ExecDirect(, "SELECT ID FROM UnitTest_isc_json_sample.generalPersistent WHERE ID IN ("_id1_","_id2_") ORDER BY ID")
    $$$ThrowSQLIfError(rs.%SQLCODE, rs.%Message)
    Kill arr,errorLog
    Set behavior = {"accumulateErrors":0}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(rs, "AltMap", behavior, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals(arr.%Size(),0)
    Set cnt=0,k="" For  Set k=$Order(errorLog(k)) Quit:(k="")  Set cnt=cnt+1
    Do $$$AssertEquals(cnt,1)
    Do $$$AssertTrue($Data(errorLog(0))>0)
}

/// Accepts %DynamicArray of IDs for persistent classes
Method TestPersistentDynamicArrayIDs()
{
    Set id1 = ..CreateSavedPersistent("A1", 51)
    Set id2 = ..CreateSavedPersistent("A2", 52)
    Set ids = []
    Do ids.%Push(id1)
    Do ids.%Push(id2)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(ids, "", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(arr.%Size(), 2)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "A1")
    Do $$$AssertEquals(arr.%Get(1).%Get("Name"), "A2")
    Do $$$AssertEquals($Data(errorLog),0)
}

/// Accepts %SQL.StatementResult of IDs for persistent classes
Method TestPersistentSQLStatementResultIDs()
{
    // Create specific records for query
    Set id1 = ..CreateSavedPersistent("S1", 61)
    Set id2 = ..CreateSavedPersistent("S2", 62)
    // Select only the two we created above
    Set rs = ##class(%SQL.Statement).%ExecDirect(, "SELECT ID FROM UnitTest_isc_json_sample.generalPersistent WHERE Name %STARTSWITH 'S' ORDER BY ID")
    $$$ThrowSQLIfError(rs.%SQLCODE, rs.%Message)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(rs, "", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    // At least the two just created should be present at the end;size may include prior S* rows if any
    Do $$$AssertTrue(arr.%Size() >= 2)
    // Find last two elements
    Set last = (arr.%Size()-1)
    Set prev = (arr.%Size()-2)
    Do $$$AssertEquals(arr.%Get(prev).%Get("Name"), "S1")
    Do $$$AssertEquals(arr.%Get(last).%Get("Name"), "S2")
    Do $$$AssertEquals($Data(errorLog),0)
}

/// Mapping NameOnly applied when exporting array of IDs
Method TestWithNameOnlyMapping()
{
    Set id1 = ..CreateSavedPersistent("M1", 21)
    Set id2 = ..CreateSavedPersistent("M2", 22)
    Set idlist = $Listbuild(id1, id2)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(idlist, "NameOnly", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(arr.%Size(), 2)
    Do $$$AssertEquals(arr.%Get(0).%Get("name"), "M1")
    Do $$$AssertEquals(arr.%Get(1).%Get("name"), "M2")
    Do $$$AssertEquals(arr.%Get(0).%IsDefined("Age"), 0)
    Do $$$AssertEquals($Data(errorLog),0)
}

/// Non-persistent classes accept only %ListOfObjects of instances
Method TestNonPersistentListOfObjectsOnly()
{
    // Build list of objects for non-persistent class
    Set list = ##class(%ListOfObjects).%New()
    Set list.ElementType = "UnitTest.isc.json.sample.generalNonPersistent"
    For i=1:1:2 {
        Set o = ##class(UnitTest.isc.json.sample.generalNonPersistent).%New()
        Set o.Name = ("NP"_i)
        Do o.Tags.Insert("t")
        Do list.Insert(o)
    }
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalNonPersistent).%JSONExportArray(list, "", {}, .arr, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(arr.%Size(), 2)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"), "NP1")
    Do $$$AssertEquals($Data(errorLog),0)
}

/// Non-persistent classes reject ID-based inputs
Method TestNonPersistentRejectsIDs()
{
    Set idlist = $Listbuild(1,2,3)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalNonPersistent).%JSONExportArray(idlist, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidListForExportArray)
}

/// Non-persistent rejects %ListOfDataTypes
Method TestNonPersistentRejectsListOfDataTypes()
{
    Set lod = ##class(%ListOfDataTypes).%New()
    Set lod.ElementType = "%Integer" Do lod.Insert(1)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalNonPersistent).%JSONExportArray(lod, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidListForExportArray)
}

/// Non-persistent rejects %DynamicArray of IDs
Method TestNonPersistentRejectsDynamicArrayIDs()
{
    Set ids = [] Do ids.%Push(1)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalNonPersistent).%JSONExportArray(ids, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidListForExportArray)
}

/// Non-persistent rejects %SQL.StatementResult
Method TestNonPersistentRejectsSQLStatementResult()
{
    Set rs = ##class(%SQL.Statement).%ExecDirect(, "SELECT ID FROM UnitTest_isc_json_sample.generalPersistent WHERE 1=0")
    $$$ThrowSQLIfError(rs.%SQLCODE, rs.%Message)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalNonPersistent).%JSONExportArray(rs, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidListForExportArray)
}

/// Invalid input object type is rejected (neither supported list nor IDs)
Method TestInvalidInputTypeRejectedPersistent()
{
    Set bad = ##class(UnitTest.isc.json.notJSONAdapted).%New()
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(bad, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidListForExportArray)
}

/// Invalid mapping name is rejected
Method TestMappingNameAccepted()
{
    Set list = ..BuildListOfObjectsPersistent(1)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(list, "AltMap", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc,"Invalid mapping name should be rejected")
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping,"Correct error status for invalid mapping")
}

/// accumulateErrors=true (default) collects per-element export errors and returns aggregated %Status
Method TestErrorAccumulation()
{
    // Create one valid, one invalid ID using %DynamicArray to ensure index tracking
    Set validId = ..CreateSavedPersistent("EA_OK", 33)
    Set invalidId = 99999999 // assume no such row
    Set ids = [] Do ids.%Push(validId) Do ids.%Push(invalidId)
    Kill arr,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(ids, "", {}, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // Array should include first exported object only
    Do $$$AssertEquals(arr.%Size(),1)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"),"EA_OK")
    // Error logged for index 1 (second element)
    Do $$$AssertTrue($Data(errorLog(1))>0)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc), $System.Status.GetErrorCodes(errorLog(1)))
}

/// accumulateErrors=false stops at first error; errorLog contains only that index
Method TestStopOnFirstError()
{
    Set id1 = ..CreateSavedPersistent("EA1", 41)
    Set badId = 99999998
    Set id3 = ..CreateSavedPersistent("EA3", 43)
    Set ids = [] Do ids.%Push(id1) Do ids.%Push(badId) Do ids.%Push(id3)
    Kill arr,errorLog
    Set behavior = {"accumulateErrors":0}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONExportArray(ids, "", behavior, .arr, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // Should stop after badId; only first record exported
    Do $$$AssertEquals(arr.%Size(),1)
    Do $$$AssertEquals(arr.%Get(0).%Get("Name"),"EA1")
    Do $$$AssertTrue($Data(errorLog(1))>0)
    Do $$$AssertEquals($Order(errorLog(1)),"")
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc), $System.Status.GetErrorCodes(errorLog(1)))
}

}
