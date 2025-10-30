/// Tests for %JSONImportArray
/// zpm "isc.json test -only -v -DUnitTest.Case=UnitTest.isc.json.exportArray"
Class UnitTest.isc.json.importArray Extends UnitTest.isc.json.testBase
{

/// Build %DynamicArray for generalPersistent with simple fields only
Method BuildGeneralJSONArray(count As %Integer = 3) As %DynamicArray
{
    Set arr = []
    For i=1:1:count {
        Set o = {
            "Name": ("User"_i),
            "Age": (20+i),
            "Tags": [("t"_i), "x"],
            "SubList": [
                {
                    "Code": ("Code"_i),
                    "Value": (i)
                },
                {
                    "Code": ("Code"_(i*10)),
                    "Value": (i*10)
                }
            ],
            "Attr": {
                "key1": ("val"_i),
                "key2": "extra"
            },
            "Items": {
                "first": { "Code": ("C"_i), "Value": (i*10) },
                "second": { "Code": ("D"_i), "Value": (i*10+5) }
            },
            "Children": [
                { "Name": ("ChildA"_i) },
                { "Name": ("ChildB"_i) }
            ],
            "Relateds": [
                { "Label": ("RelA"_i) },
                { "Label": ("RelB"_i) }
            ]
        }
        Do o.%Set("Active", (i#2), "boolean")
        // Add attr, child and related programmatically to exercise structures
        #dim attr As %DynamicObject
        #dim children As %DynamicArray
        #dim relateds As %DynamicArray
        Set attr = o.%Get("Attr")
        If $IsObject(attr) {
            Do attr.%Set("key3", ("valExtra"_i))
        }
        Set children = o.%Get("Children")
        If $IsObject(children) {
            Do children.%Push({ "Name": ("ChildC"_i) })
        }
        Set relateds = o.%Get("Relateds")
        If $IsObject(relateds) {
            Do relateds.%Push({ "Label": ("RelC"_i) })
        }
        Do arr.%Push(o)
    }
    Quit arr
}

/// Build %DynamicArray for NonPersistentSample
Method BuildNonPersistentJSONArray() As %DynamicArray
{
    Return [
        {
            "Name": "Alpha",
            "Tags": ["a","b"]
        },
        {
            "Name": "Beta",
            "Tags": ["b"]
        }
    ]
}

/// Creates list when not provided and populates it
Method TestNoProvidedListCreatesAndPopulates()
{
    Set arr = ..BuildGeneralJSONArray(2)
    Kill list
    // mappingName:"", default behavior (accumulateErrors:true, save:false)
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "", {}, .list, .errorLog)
    Do $$$AssertStatusOK(sc, "Import should succeed")
    Do $$$AssertTrue($IsObject(list),"List-of-objects output must be created")
    Do $$$AssertEquals(list.Count(),2,"List should contain all imported records")

    Set o1 = list.GetAt(1)
    Do $$$AssertEquals(o1.Name,"User1")
    Do $$$AssertEquals(o1.Age,21)
    Do $$$AssertEquals(o1.Active,1)
    Do $$$AssertEquals(o1.Tags.Count(),2)

    // save=0 -> not persisted
    Do $$$AssertTrue(o1.%Id()="", "Objects shouldn't be saved when save=0")
}

/// Appends to provided list
Method TestAppendsToProvidedList()
{
    Set seed = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set seed.Name = "Seed"
    Set list = ##class(%ListOfObjects).%New()
    Do list.Insert(seed)

    Set arr = ..BuildGeneralJSONArray(3)
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "", {}, .list, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(list.Count(),4,"Should append 3 to existing 1")
    Do $$$AssertEquals(list.GetAt(2).Name,"User1")
    Do $$$AssertEquals(list.GetAt(4).Name,"User3")
}

/// save=1 persists for persistent classes
Method TestSaveTruePersists()
{
    Set before = ##class(UnitTest.isc.json.sample.generalPersistent).Count()
    Set arr = ..BuildGeneralJSONArray(2)
    Kill list
    // behavior.save=true
    Set behavior = {"save":1}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "", behavior, .list, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(list.Count(),2)

    Set after = ##class(UnitTest.isc.json.sample.generalPersistent).Count()
    Do $$$AssertEquals(after, before+2, "Extent should increase by number imported with save=1")

    Set o = list.GetAt(1)
    Do $$$AssertTrue(+o.%Id()>0,"Saved object should have an ID")
}

/// save flag ignored for non-persistent classes (no error)
Method TestSaveIgnoredForNonPersistent()
{
    Set arr = ..BuildNonPersistentJSONArray()
    Kill list
    // behavior.save=true but ignored for non-persistent
    Set sc = ##class(UnitTest.isc.json.sample.generalNonPersistent).%JSONImportArray(arr, "", {"save":1}, .list, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(list.Count(),2)
    Set np = list.GetAt(1)
    Do $$$AssertEquals(np.Name,"Alpha")
    Do $$$AssertEquals(np.Tags.Count(),2)
}

/// Empty array yields success and creates empty list
Method TestEmptyArray()
{
    Set empty = []
    Kill list
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(empty, "", {}, .list, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertTrue($IsObject(list),"List should be created even for empty input")
    Do $$$AssertEquals(list.Count(),0,"No records should be added for empty input")
}

/// Invalid mapping name is rejected
Method TestInvalidMappingNameRejected()
{
    Set arr = ..BuildGeneralJSONArray(1)
    Kill list
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "AltMap", {}, .list, .errorLog)
    Do $$$AssertStatusNotOK(sc,"Invalid mapping name should be rejected")
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping,"Correct error status for invalid mapping")
}

/// NameAge mapping imports only Name and Age fields
Method TestImportWithNameAgeMapping()
{
    // Build array with extra fields that should be ignored by mapping
    Set arr = []
    Do arr.%Push({"name":"U1","age":31,"Active":1,"IgnoreMe":"x"})
    Do arr.%Push({"name":"U2","age":32,"jsonObj":{},"Tags":["t"]})
    Kill list
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "NameAge", {}, .list, .errorLog)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(list.Count(),2)
    Set o1 = list.GetAt(1)
    Do $$$AssertEquals(o1.Name,"U1")
    Do $$$AssertEquals(o1.Age,31)
    Do $$$AssertEquals(o1.Active,"")
    Do $$$AssertEquals(o1.Tags.Count(),0)
}

/// NoStreams mapping ignores stream inputs
Method TestImportWithNoStreamsMapping()
{
    Set arr = []
    Do arr.%Push({"Name":"SLESS","Age":20,"CharStream":"X","BinaryStream":"Y","BinaryStreamHex":"Z"})
    Kill list
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "NoStreams", {}, .list, .errorLog)
    Do $$$AssertStatusOK(sc)
    #dim o as UnitTest.isc.json.sample.generalPersistent
    Set o = list.GetAt(1)
    Do $$$AssertEquals(o.Name,"SLESS")
    Do $$$AssertEquals(o.CharStream.Size,0)
    Do $$$AssertEquals(o.BinaryStream.Size,0)
    Do $$$AssertEquals(o.BinaryStreamHex.Size,0)
}

/// accumulateErrors=true (default) collects per-element errors and returns aggregated %Status
Method TestImportArrayErrorAccumulation()
{
    // First element valid, second element invalid (missing required Name)
    Set arr = []
    Do arr.%Push({"Name":"OK","Age":30})
    Do arr.%Push({"Age":31})
    Kill list,errorLog
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "", {}, .list, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // List is still created and both elements inserted
    Do $$$AssertTrue($IsObject(list))
    Do $$$AssertEquals(list.Count(),2)
    // Error is logged for index 1 (second element, 0-based)
    Do $$$AssertTrue($Data(errorLog(1))>0)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc), $System.Status.GetErrorCodes(errorLog(1)))
}

/// accumulateErrors=false stops at first error; errorLog contains only that index
Method TestImportArrayStopOnFirstError()
{
    Set arr = []
    Do arr.%Push({"Name":"OK1","Age":25})
    Do arr.%Push({"Age":26}) // invalid: missing Name
    Do arr.%Push({"Name":"OK2","Age":27})
    Kill list,errorLog
    Set behavior = {"accumulateErrors":0}
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "", behavior, .list, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    // Should stop after second element; list has at least two entries
    Do $$$AssertTrue(list.Count()>=2)
    // Count error entries and ensure it is index 1 (second element)
    Set cnt=0,k="" For  Set k=$Order(errorLog(k)) Quit:(k="")  Set cnt=cnt+1
    Do $$$AssertEquals(cnt,1,"Only one error should be logged")
    Do $$$AssertTrue($Data(errorLog(1))>0)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc), $System.Status.GetErrorCodes(errorLog(1)))
}

/// Mixed malformed/valid inputs produce errorLog entries at exact indices
Method TestImportArrayMixedValidityErrorIndices()
{
    // 0: valid, 1: invalid (missing Name), 2: valid, 3: invalid type, 4: valid
    Set arr = []
    Do arr.%Push({"Name":"OK0","Age":20})
    Do arr.%Push({"Age":21}) // missing Name
    Do arr.%Push({"Name":"OK2","Age":22})
    Do arr.%Push("notAnObject")
    Do arr.%Push({"Name":"OK4","Age":24})
    Kill list,errorLog
    // Default accumulateErrors=true; expect both errors captured
    Set sc = ##class(UnitTest.isc.json.sample.generalPersistent).%JSONImportArray(arr, "", {}, .list, .errorLog)
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals(list.Count(),5)
    // Errors should be at indices 1 and 3 (0-based)
    Do $$$AssertTrue($Data(errorLog(1))>0)
    Do $$$AssertTrue($Data(errorLog(3))>0)
}

}
