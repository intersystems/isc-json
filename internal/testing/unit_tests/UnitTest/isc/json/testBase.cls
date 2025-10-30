Include %pkg.isc.json.map

/// Base class for unit tests to generate test data
Class UnitTest.isc.json.testBase Extends %UnitTest.TestCase
{

Method OnBeforeAllTests() As %Status
{
    Do ##class(UnitTest.isc.json.sample.child).%KillExtent()
    Do ##class(UnitTest.isc.json.sample.related).%KillExtent()
    Do ##class(UnitTest.isc.json.sample.generalPersistent).%KillExtent()
    Quit $$$OK
}

Method CreateSavedPersistent(name As %String = "User", age As %Integer = 30) As %Integer
{
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set o.Name = name
    Set o.Age = age
    Set o.DoubleVal = 123.456
    Set o.NameIgnoreNull = name_"_IGN"
    Set o."Snake_Case" = name_"_snake"
    Set o.Active = 1
    Set o.Timestamp = $ZDATETIME($ZTIMESTAMP,3)
    Set o.IntOrString = 777
    Set o.jsonObj = {"k":"v"}
    Set o.jsonArr = [1,2]
    Set cs = ##class(%Stream.GlobalCharacter).%New()
    Do cs.Write("chars-"_name)
    Set o.CharStream = cs
    Set bs = ##class(%Stream.GlobalBinary).%New()
    Do bs.Write($C(1,2,3,4))
    Set o.BinaryStream = bs
    Set bhex = ##class(%Stream.GlobalBinary).%New()
    Do bhex.Write($C(171,205,239))
    Set o.BinaryStreamHex = bhex
    Set sub = ##class(UnitTest.isc.json.sample.subItem).%New()
    Set sub.Code = name_"_C"
    Set sub.Value = age
    Set o.SubItem = sub
    Set subp = ##class(UnitTest.isc.json.sample.subItemPersistent).%New()
    Set subp.Code = name_"_PC"
    Set subp.Value = age+1
    $$$ThrowOnError(subp.%Save())
    Set o.SubItemPersistent = subp
    Set o.SubItemPersistentID = subp
    Set o.SubItemPersistentOID = subp
    Set o.SubItemPersistentGUID = subp
    Do o.Tags.Insert(name_"_t1")
    Do o.Tags.Insert(name_"_t2")
    Set sl = ##class(UnitTest.isc.json.sample.subItem).%New()
    Set sl.Code = name_"_SL"
    Set sl.Value = age+2
    Do o.SubList.Insert(sl)
    Do o.Attr.SetAt(name_"_val1","key1")
    Do o.Attr.SetAt(name_"_val2","key2")
    Set it = ##class(UnitTest.isc.json.sample.subItem).%New()
    Set it.Code = name_"_IT"
    Set it.Value = age+3
    Do o.Items.SetAt(it,"first")
    $$$ThrowOnError(o.%Save())
    Quit o.%Id()
}

Method BuildUnsavedPersistent(name As %String = "UP", age As %Integer = 25) As UnitTest.isc.json.sample.generalPersistent
{
    Set o = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set o.Name = name
    Set o.Age = age
    Quit o
}

Method BuildUnsavedNonPersistent(name As %String = "NP") As UnitTest.isc.json.sample.generalNonPersistent
{
    Set o = ##class(UnitTest.isc.json.sample.generalNonPersistent).%New()
    Set o.Name = name
    Do o.Tags.Insert("t")
    Quit o
}

}
