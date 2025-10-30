Class UnitTest.isc.json.general Extends %UnitTest.TestCase
{

Method TestExportToNewStream()
{
	Set inst = ##class(UnitTest.isc.json.dataTypes).%New($$$NULLOREF)
	Do $$$AssertStatusOK(inst.%JSONExportToStream(.stream))
	Try {
		Set sc = $$$OK
		Do inst.%JSONImport(.stream)
	} Catch e {
		Set sc = e.AsStatus()
	}
	Do $$$AssertStatusOK(sc,"Imported fomr JSON successfully.")
}

Method TestExportToExistingStream()
{
	Set inst = ##class(UnitTest.isc.json.dataTypes).%New($$$NULLOREF)
	Set stream = ##class(%Stream.GlobalCharacter).%New()
	Do $$$AssertStatusOK(inst.%JSONExportToStream(stream))
	Try {
		Set sc = $$$OK
		Do inst.%JSONImport(stream)
	} Catch e {
		Set sc = e.AsStatus()
	}
	Do $$$AssertStatusOK(sc,"Imported fomr JSON successfully.")
}

Method TestFormatter()
{
	Set formatter = ##class(%pkg.isc.json.formatter).%New()
	Set buffer = ##class(%pkg.isc.json.util.buffer).%New()
	Do buffer.BeginCaptureOutput()
	Set status = formatter.Format({"foo":"bar","baz":[1,2,3]})
	Do buffer.EndCaptureOutput(.formatted)
	Do $$$AssertStatusOK(status,"Formatter ran without error.")
	Do $$$AssertEquals(formatted,"{"_$c(13,10)_"  ""foo"":""bar"","_$c(13,10)_"  ""baz"":["_$c(13,10)_"    1,"_$c(13,10)_"    2,"_$c(13,10)_"    3"_$c(13,10)_"  ]"_$c(13,10)_"}")
}

Method TestFormatToStream()
{
	Set formatter = ##class(%pkg.isc.json.formatter).%New()
	Set status = formatter.FormatToStream({"foo":"bar","baz":[1,2,3]},.export)
	Do $$$AssertStatusOK(status,"Formatter ran without error.")
	Set nl = $Select($$$isUNIX:$c(10),1:$c(13,10))
	Do $$$AssertEquals(export.Read(),"{"_nl_"  ""foo"":""bar"","_nl_"  ""baz"":["_nl_"    1,"_nl_"    2,"_nl_"    3"_nl_"  ]"_nl_"}")
}

}

