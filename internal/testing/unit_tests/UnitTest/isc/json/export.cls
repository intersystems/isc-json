Include %pkg.isc.json.map

/// Tests for %JSONExport/ToString/ToStream/ToDynamicObject methods
/// zpm "isc.json test -DUnitTest.Case=UnitTest.isc.json.export"
Class UnitTest.isc.json.export Extends UnitTest.isc.json.testBase
{

/// Spec: Export persistent object to DynamicObject
Method TestExportToDynamicObjectPersistent()
{
    Set id = ..CreateSavedPersistent("E1", 31)
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%OpenId(id)
    Set sc = o.%JSONExportToDynamicObject(.json, "")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertTrue($IsObject(json))
    // Scalars
    Do $$$AssertEquals(json.%Get("Name"), o.Name)
    Do $$$AssertEquals(json.%Get("Age"), o.Age)
    Do $$$AssertEquals(json.%Get("DoubleVal"), o.DoubleVal)
    Do $$$AssertEquals(json.%Get("Active"), o.Active)
    Do $$$AssertEquals(json.%Get("NameIgnoreNull"), o.NameIgnoreNull)
    Do $$$AssertEquals(json.%Get("Snake_Case"), o."Snake_Case")
    Do $$$AssertEquals(json.%Get("Timestamp"), ##class(%TimeStamp).LogicalToXSD(o.Timestamp))
    Do $$$AssertEquals(json.%Get("IntOrString"), o.IntOrString)

    // JSON types
    Do $$$AssertTrue($IsObject(json.%Get("jsonObj")))
    Do $$$AssertEquals(json.%Get("jsonObj").%Get("k"), o.jsonObj.%Get("k"))
    Do $$$AssertTrue($IsObject(json.%Get("jsonArr")))
    Do $$$AssertEquals(json.%Get("jsonArr").%Size(), o.jsonArr.%Size())
    Do $$$AssertEquals(json.%Get("jsonArr").%Get(0), o.jsonArr.%Get(0))
    Do $$$AssertEquals(json.%Get("jsonArr").%Get(1), o.jsonArr.%Get(1))

    // Streams
    Do $$$AssertEquals(json.%Get("CharStream"), "chars-"_o.Name)
    Do $$$AssertEquals(json.%Get("BinaryStream"), "AQIDBA==")
    Do $$$AssertEquals(json.%Get("BinaryStreamHex"), "ABCDEF")

    // Nested serial object
    Set si = json.%Get("SubItem")
    Do $$$AssertTrue($IsObject(si))
    Do $$$AssertEquals(si.%Get("Code"), "E1_C")
    Do $$$AssertEquals(si.%Get("Value"), 31)

    // Referenced persistent object (OBJECT)
    Set spi = json.%Get("SubItemPersistent")
    Do $$$AssertTrue($IsObject(spi))
    Do $$$AssertEquals(spi.%Get("Code"), "E1_PC")
    Do $$$AssertEquals(spi.%Get("Value"), 32)

    // Reference projections
    Do $$$AssertEquals(json.%Get("SubItemPersistentID"), o.SubItemPersistent.%Id())
    Set expectedOID = $listget(o.SubItemPersistent.%Oid(),2)_","_$listget(o.SubItemPersistent.%Oid())
    Do $$$AssertEquals(json.%Get("SubItemPersistentOID"), expectedOID)
    Set expectedGUID = o.SubItemPersistent.%GUID(o.SubItemPersistent.%Oid())
    Do $$$AssertEquals(json.%Get("SubItemPersistentGUID"), expectedGUID)

    // Collections
    Set tags = json.%Get("Tags")
    Do $$$AssertTrue($IsObject(tags))
    Do $$$AssertEquals(tags.%Size(), 2)
    Do $$$AssertEquals(tags.%Get(0), "E1_t1")
    Do $$$AssertEquals(tags.%Get(1), "E1_t2")

    Set subl = json.%Get("SubList")
    Do $$$AssertTrue($IsObject(subl))
    Do $$$AssertEquals(subl.%Size(), 1)
    Do $$$AssertEquals(subl.%Get(0).%Get("Code"), "E1_SL")
    Do $$$AssertEquals(subl.%Get(0).%Get("Value"), 33)

    Set attr = json.%Get("Attr")
    Do $$$AssertTrue($IsObject(attr))
    Do $$$AssertEquals(attr.%Get("key1"), "E1_val1")
    Do $$$AssertEquals(attr.%Get("key2"), "E1_val2")

    Set items = json.%Get("Items")
    Do $$$AssertTrue($IsObject(items))
    Do $$$AssertTrue($IsObject(items.%Get("first")))
    Do $$$AssertEquals(items.%Get("first").%Get("Code"), "E1_IT")
    Do $$$AssertEquals(items.%Get("first").%Get("Value"), 34)

    // Relationships not set should be empty string, not arrays
    Do $$$AssertEquals(json.%Get("Children"), "")
    Do $$$AssertEquals(json.%Get("Relateds"), "")
}

/// Spec: Unset collections export as "" and not [] / {}
Method TestExportToDynamicObjectCollectionsUnsetNotExported()
{
    Set o = ..BuildUnsavedPersistent("C0", 20)
    Do o.Tags.Clear()
    Do o.Children.Clear()
    Set sc = o.%JSONExportToDynamicObject(.json, "")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertTrue($IsObject(json))

    // Lists
    Do $$$AssertTrue('json.%IsDefined("Tags"))
    Do $$$AssertTrue('json.%IsDefined("SubList"))

    // Relationships
    Do $$$AssertTrue('json.%IsDefined("Children"))
    Do $$$AssertTrue('json.%IsDefined("Relateds"))
}

/// Spec: Uses NameOnly mapping to include only Name with field rename
Method TestExportToDynamicObjectWithNameOnlyMapping()
{
    Set id = ..CreateSavedPersistent("Map1", 40)
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%OpenId(id)
    Set sc = o.%JSONExportToDynamicObject(.json, "NameOnly")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertTrue($IsObject(json))
    Do $$$AssertEquals(json.%Get("name"), "Map1")
    Do $$$AssertTrue('json.%IsDefined("Age"))
}

/// Spec: Export non-persistent object to DynamicObject
Method TestExportToDynamicObjectNonPersistent()
{
    Set o = ..BuildUnsavedNonPersistent("N1")
    Set sc = o.%JSONExportToDynamicObject(.json, "")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(json.%Get("Name"), "N1")
}

/// Spec: Export persistent object to string JSON
Method TestExportToStringPersistent()
{
    Set o = ..BuildUnsavedPersistent("S1", 28)
    Set sc = o.%JSONExportToString(.str)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertTrue($Length(str)>0)
    Set dobj = {}.%FromJSON(str)
    Do $$$AssertEquals(dobj.%Get("Name"), "S1")
}

/// Spec: NameAge mapping exports only Name and Age with lowercase field names
Method TestExportToStringWithNameAgeMapping()
{
    Set o = ..BuildUnsavedPersistent("S2", 33)
    Set sc = o.%JSONExportToString(.s, "NameAge")
    Do $$$AssertStatusOK(sc)
    Set dobj = {}.%FromJSON(s)
    Do $$$AssertEquals(dobj.%Get("name"), "S2")
    Do $$$AssertEquals(dobj.%Get("age"), 33)
    Do $$$AssertTrue('dobj.%IsDefined("Active"))
}

/// Spec: Export persistent object to provided stream
Method TestExportToStreamPersistent()
{
    Set o = ..BuildUnsavedPersistent("T1", 29)
    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Set sc = o.%JSONExportToStream(.stream)
    Do $$$AssertStatusOK(sc)
    Do stream.Rewind()
    Set dobj = {}.%FromJSON(stream)
    Do $$$AssertEquals(dobj.%Get("Name"), "T1")
}

/// Spec: NoStreams mapping excludes stream properties from export
Method TestExportToStreamWithNoStreamsMapping()
{
    Set o = ..BuildUnsavedPersistent("TS", 35)
    Set stream = ##class(%Stream.GlobalCharacter).%New()
    Set sc = o.%JSONExportToStream(.stream, "NoStreams")
    Do $$$AssertStatusOK(sc)
    Do stream.Rewind()
    Set dobj = {}.%FromJSON(stream)
    Do $$$AssertEquals(dobj.%Get("CharStream"), "")
    Do $$$AssertEquals(dobj.%Get("BinaryStream"), "")
    Do $$$AssertEquals(dobj.%Get("BinaryStreamHex"), "")
}

/// Spec: Export to current device returns success
Method TestExportToCurrentDevice()
{
    Set o = ..BuildUnsavedPersistent("D1", 27)
    // We do not capture output; ensure it succeeds
    Set sc = o.%JSONExport()
    Do $$$AssertStatusOK(sc)
}

/// Spec: Invalid mapping name is rejected in DynamicObject export
Method TestExportToDynamicObjectInvalidMapping()
{
    Set o = ..BuildUnsavedPersistent("MX", 26)
    Set sc = o.%JSONExportToDynamicObject(.json, "AltMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

/// Spec: Invalid mapping name is rejected in string export
Method TestExportToStringInvalidMapping()
{
    Set o = ..BuildUnsavedPersistent("MS", 26)
    Set sc = o.%JSONExportToString(.str, "AltMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

/// Spec: Invalid mapping name is rejected in stream export
Method TestExportToStreamInvalidMapping()
{
    Set o = ..BuildUnsavedPersistent("MT", 26)
    Set s = ##class(%Stream.GlobalCharacter).%New()
    Set sc = o.%JSONExportToStream(.s, "AltMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

/// Spec: Invalid mapping name is rejected in device export
Method TestExportInvalidMapping()
{
    Set o = ..BuildUnsavedPersistent("MD", 26)
    Set sc = o.%JSONExport("AltMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

/// Spec: Simple mapping applies same-named child mapping to SubItem
Method TestExportToDynamicObjectWithSimpleMapping()
{
    Set id = ..CreateSavedPersistent("PX1", 41)
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%OpenId(id)
    Set sc = o.%JSONExportToDynamicObject(.json, "Simple")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(json.%Get("name"), o.Name)
    Set si = json.%Get("SubItem")
    Do $$$AssertTrue($IsObject(si))
    Do $$$AssertEquals(si.%Get("code"), o.SubItem.Code)
    Do $$$AssertEquals(si.%Get("value"), o.SubItem.Value)
    // Ensure original-cased fields are not present
    Do $$$AssertTrue('si.%IsDefined("Code"))
    Do $$$AssertTrue('si.%IsDefined("Value"))
}

/// Spec: ParentChildAlt mapping uses child's CodeOnly mapping (code only, no value)
Method TestExportToDynamicObjectWithParentChildAlt()
{
    Set id = ..CreateSavedPersistent("PX2", 42)
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%OpenId(id)
    Set sc = o.%JSONExportToDynamicObject(.json, "ParentChildAlt")
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(json.%Get("Name"), o.Name)
    Set si = json.%Get("SubItem")
    Do $$$AssertTrue($IsObject(si))
    Do $$$AssertEquals(si.%Get("code"), o.SubItem.Code)
    Do $$$AssertTrue('si.%IsDefined("value"))
}

/// Spec: Invalid child mapping referenced in mapping causes export failure
Method TestExportToDynamicObjectInvalidChildMapping()
{
    Set id = ..CreateSavedPersistent("PX3", 43)
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%OpenId(id)
    Set sc = o.%JSONExportToDynamicObject(.json, "InvalidChildMap")
    Do $$$AssertStatusNotOK(sc)
    Do $$$AssertEquals($System.Status.GetErrorCodes(sc),$$$JSONInvalidMapping)
}

/// Spec: Ensure elements which should be escaped are indeed escaped
Method TestExportToDynamicObjectCharEscaping()
{
    Set escapeString = "Hello"_$Char(9)_"""today\/"_$Char(13,10)
    Set id = ..CreateSavedPersistent(escapeString)
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%OpenId(id)
    Set sc = o.%JSONExportToDynamicObject(.json)
    Do $$$AssertStatusOK(sc)
    Do $$$AssertEquals(json.%Get("Name"),escapeString)
}

/// Spec: Empty SubItem and SubItem collections are omitted from output
Method TestExportOmitEmptySubItems()
{
    Set o = ..BuildUnsavedPersistent("ESI", 22)
    // Ensure nothing is populated for SubItem/Items/SubList/Tags/Attr
    Do o.Tags.Clear()
    Do o.SubList.Clear()
    Do o.SubListPersistent.Clear()
    Do o.Items.Clear()
    Do o.Attr.Clear()
    Do o.ItemsPersistent.Clear()
    // Clear array properties by leaving them unset (default) for this unsaved object
    Set sc = o.%JSONExportToDynamicObject(.json, "")
    Do $$$AssertStatusOK(sc)
    // None of the collections should be defined
    Do $$$AssertTrue('json.%IsDefined("Tags"))
    Do $$$AssertTrue('json.%IsDefined("SubList"))
    Do $$$AssertTrue('json.%IsDefined("SubListPersistent"))
    Do $$$AssertTrue('json.%IsDefined("Items"))
    Do $$$AssertTrue('json.%IsDefined("ItemsPersistent"))
    Do $$$AssertTrue('json.%IsDefined("Attr"))
}

/// Spec: Nested empty objects export as null for SubList/Items, but {} for SubListPersistent/ItemsPersistent
Method TestExportOmitEmptyObjectsInCollections()
{
    // Build an unsaved object and populate collections with a mix of empty and non-empty objects
    Set o = ..BuildUnsavedPersistent("OC1", 20)

    // SubList (list of objects): insert one empty and one populated serial object
    Do o.SubList.Clear()
    Set sEmpty = ##class(UnitTest.isc.json.sample.subItem).%New()
    Do o.SubList.Insert(sEmpty)
    Set sFull = ##class(UnitTest.isc.json.sample.subItem).%New()
    Set sFull.Code = "OC1_SL"
    Set sFull.Value = 1
    Do o.SubList.Insert(sFull)

    // SubListPersistent (list of persistent objects): one empty and one populated
    Do o.SubListPersistent.Clear()
    Set spEmpty = ##class(UnitTest.isc.json.sample.subItemPersistent).%New()
    Do o.SubListPersistent.Insert(spEmpty)
    Set spFull = ##class(UnitTest.isc.json.sample.subItemPersistent).%New()
    Set spFull.Code = "OC1_SPL"
    Set spFull.Value = 11
    Do o.SubListPersistent.Insert(spFull)

    // Items (array of objects): set an empty entry and a populated entry
    Set iEmpty = ##class(UnitTest.isc.json.sample.subItem).%New()
    Do o.Items.SetAt(iEmpty, "empty")
    Set iFull = ##class(UnitTest.isc.json.sample.subItem).%New()
    Set iFull.Code = "OC1_IT"
    Set iFull.Value = 2
    Do o.Items.SetAt(iFull, "full")
    // ItemsPersistent (array of persistent objects): empty and populated
    Set ipEmpty = ##class(UnitTest.isc.json.sample.subItemPersistent).%New()
    Do o.ItemsPersistent.SetAt(ipEmpty, "empty")
    Set ipFull = ##class(UnitTest.isc.json.sample.subItemPersistent).%New()
    Set ipFull.Code = "OC1_IP"
    Set ipFull.Value = 12
    Do o.ItemsPersistent.SetAt(ipFull, "full")

    // Export
    Set sc = o.%JSONExportToDynamicObject(.json, "")
    Do $$$AssertStatusOK(sc)

    // SubList should include both entries: a null and a populated object
    Do $$$AssertTrue(json.%IsDefined("SubList"))
    Set sl = json.%Get("SubList")
    Do $$$AssertTrue($IsObject(sl))
    Do $$$AssertEquals(sl.%Size(), 2)
    Do $$$AssertEquals(sl.%GetTypeOf(0), "null")
    Do $$$AssertEquals(sl.%Get(1).%Get("Code"), "OC1_SL")
    Do $$$AssertEquals(sl.%Get(1).%Get("Value"), 1)

    // SubListPersistent: empty object exported as {}
    Do $$$AssertTrue(json.%IsDefined("SubListPersistent"))
    Set slp = json.%Get("SubListPersistent")
    Do $$$AssertTrue($IsObject(slp))
    Do $$$AssertEquals(slp.%Size(), 2)
    Do $$$AssertTrue($IsObject(slp.%Get(0)))
    Do $$$AssertEquals(slp.%Get(0).%Size(), 0)
    Do $$$AssertEquals(slp.%Get(1).%Get("Code"), "OC1_SPL")
    Do $$$AssertEquals(slp.%Get(1).%Get("Value"), 11)

    // Items: empty object exported as null; populated remains
    Do $$$AssertTrue(json.%IsDefined("Items"))
    Set it = json.%Get("Items")
    Do $$$AssertTrue($IsObject(it))
    Do $$$AssertTrue(it.%IsDefined("empty"))
    Do $$$AssertEquals(it.%GetTypeOf("empty"), "null")
    Do $$$AssertTrue(it.%IsDefined("full"))
    Do $$$AssertEquals(it.%Get("full").%Get("Code"), "OC1_IT")
    Do $$$AssertEquals(it.%Get("full").%Get("Value"), 2)

    // ItemsPersistent: empty object exported as {}
    Do $$$AssertTrue(json.%IsDefined("ItemsPersistent"))
    Set ip = json.%Get("ItemsPersistent")
    Do $$$AssertTrue($IsObject(ip))
    Do $$$AssertTrue(ip.%IsDefined("empty"))
    Do $$$AssertTrue($IsObject(ip.%Get("empty")))
    Do $$$AssertEquals(ip.%Get("empty").%Size(), 0)
    Do $$$AssertTrue(ip.%IsDefined("full"))
    Do $$$AssertEquals(ip.%Get("full").%Get("Code"), "OC1_IP")
    Do $$$AssertEquals(ip.%Get("full").%Get("Value"), 12)
}

/// Spec: Collections with only empty nested objects still export those elements as {}
Method TestExportOmitCollectionsWhenAllElementsEmpty()
{
    Set o = ..BuildUnsavedPersistent("OC2", 21)

    // SubList contains only an empty object
    Do o.SubList.Clear()
    Do o.SubList.Insert(##class(UnitTest.isc.json.sample.subItem).%New())
    // SubListPersistent contains only an empty persistent object
    Do o.SubListPersistent.Clear()
    Do o.SubListPersistent.Insert(##class(UnitTest.isc.json.sample.subItemPersistent).%New())

    // Items contains only an empty object
    Do o.Items.SetAt(##class(UnitTest.isc.json.sample.subItem).%New(), "onlyempty")
    // ItemsPersistent contains only an empty persistent object
    Do o.ItemsPersistent.SetAt(##class(UnitTest.isc.json.sample.subItemPersistent).%New(), "onlyempty")

    // Export
    Set sc = o.%JSONExportToDynamicObject(.json, "")
    Do $$$AssertStatusOK(sc)

    // SubList present with one element of null
    Do $$$AssertTrue(json.%IsDefined("SubList"))
    Do $$$AssertTrue($IsObject(json.%Get("SubList")))
    Do $$$AssertEquals(json.%Get("SubList").%Size(), 1)
    Do $$$AssertEquals(json.%Get("SubList").%GetTypeOf(0),"null")

    // SubListPersistent present with one empty object element {}
    Do $$$AssertTrue(json.%IsDefined("SubListPersistent"))
    Do $$$AssertTrue($IsObject(json.%Get("SubListPersistent")))
    Do $$$AssertEquals(json.%Get("SubListPersistent").%Size(), 1)
    Do $$$AssertTrue($IsObject(json.%Get("SubListPersistent").%Get(0)))
    Do $$$AssertEquals(json.%Get("SubListPersistent").%Get(0).%Size(), 0)

    // Items present with key mapped to null
    Do $$$AssertTrue(json.%IsDefined("Items"))
    Do $$$AssertTrue($IsObject(json.%Get("Items")))
    Do $$$AssertTrue(json.%Get("Items").%IsDefined("onlyempty"))
    Do $$$AssertEquals(json.%Get("Items").%GetTypeOf("onlyempty"), "null")

    // ItemsPersistent present with key mapped to empty object {}
    Do $$$AssertTrue(json.%IsDefined("ItemsPersistent"))
    Do $$$AssertTrue($IsObject(json.%Get("ItemsPersistent")))
    Do $$$AssertTrue(json.%Get("ItemsPersistent").%IsDefined("onlyempty"))
    Do $$$AssertTrue($IsObject(json.%Get("ItemsPersistent").%Get("onlyempty")))
    Do $$$AssertEquals(json.%Get("ItemsPersistent").%Get("onlyempty").%Size(), 0)
}

}
