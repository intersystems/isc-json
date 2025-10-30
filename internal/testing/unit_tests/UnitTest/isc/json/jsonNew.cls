/// Test %JSONNew code generation and overrides
Class UnitTest.isc.json.jsonNew Extends %UnitTest.TestCase
{

Property tlevel As %Integer;

Method OnBeforeAllTests() As %Status
{
	Set ..tlevel = $TLevel
    TSTART
    Set sc = $$$OK
    Try {
        // Create mock data
        Set sc = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%KillExtent()
        $$$ThrowOnError(sc)
        For i = 1:1:10 {
            Set o = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%New()
            Set o.Foo = "Foo:"_i
            Set o.Bar = "Bar:"_i
            Set o.Baz = "Baz:"_i
            Set o.Another = "Another:"_i
            Set o.Combined1 = "Combined1:"_i
            Set o.Combined2 = "Combined2:"_i
            $$$ThrowOnError(o.%Save())
            Kill o
        }
    } Catch (ex) {
        Set sc = ex.AsStatus()
    }
    Return sc
}

Method OnAfterAllTests() As %Status
{
    While ($TLevel > ..tlevel) {
        TROLLBACK 1
    }
    Return $$$OK
}

Method TestNonPersistent()
{
    Set json = { "Foo": "nonPersistentFoo", "Bar": "nonPersistentBar", "Another": "nonPersistentAnother" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNew).%JSONNew(json)
    Do $$$AssertEquals(obj.Foo,"")
    Do $$$AssertEquals(obj.Bar,"")
    Do $$$AssertEquals(obj.Another,"")

    // JSONNew override
    Set json = { "_includeDefaults": true }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNew).%JSONNew(json)
    Do $$$AssertEquals(obj.Foo,"DefaultFoo")
    Do $$$AssertEquals(obj.Bar,"DefaultBar")
}

Method TestPersistent()
{
    // Insufficient matching info
    Set json = { "Another": "Another:1" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"")
    Set json = { "Foo": "Foo:1", "Combined1": "Combined1:1" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"")
    Set json = { 
        "Foo": "Foo:19", "Bar": "Bar:19", 
        "Combined1": "Combined1:28", "Combined2": "Combined2:28", 
        "Baz": "Baz:37"
    }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"")
    Set json = { 
        "Foo": "Foo:1", "Bar": "Bar:1", 
        "Combined1": "Combined1:2", "Combined2": "Combined2:2", 
        "Baz": "Baz:3"
    }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json,,"UniqueIndexPropsAbsent")
    Do $$$AssertEquals(obj.%Id(),"")
    
    // Record matching ID
    Set id = "Foo:1||Bar:1"
    Set json = { "myID": (id) }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json,,"IdIncluded")
    Do $$$AssertEquals(obj.%Id(),id)
    Set json = { "myID": 42 }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json,,"IdIncluded")
    Do $$$AssertEquals(obj.%Id(),"")

    // Record matching IdKey
    Set json = { "Foo": "Foo:3", "Bar": "Bar:3" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"Foo:3||Bar:3")
    Set json = { "Foo": "Foo:42", "Bar": "Bar:42" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"")

    // Record matching unique index Baz
    Set json = { "Baz": "Baz:5" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"Foo:5||Bar:5")
    Set json = { "Baz": "Baz:777" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"")

    // Record matching unique index Combined
    Set json = { "Combined1": "Combined1:7", "Combined2": "Combined2:7" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"Foo:7||Bar:7")
    Set json = { "Combined1": "Combined1:71", "Combined2": "Combined2:71" }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"")

    // Record matching combinations of indices
    Set json = {
        "Combined1": "Combined1:2", "Combined2": "Combined2:2", 
        "Baz": "Baz:3"
    }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"Foo:2||Bar:2")
    Set json = { 
        "Foo": "Foo:1", "Bar": "Bar:1", 
        "Combined1": "Combined1:2", "Combined2": "Combined2:2", 
        "Baz": "Baz:3"
    }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json)
    Do $$$AssertEquals(obj.%Id(),"Foo:1||Bar:1")
    Set json = { 
        "myID": "Foo:4||Bar:4",
        "Foo": "Foo:1", "Bar": "Bar:1", 
        "Combined1": "Combined1:2", "Combined2": "Combined2:2", 
        "Baz": "Baz:3"
    }
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json,,"IdIncluded")
    Do $$$AssertEquals(obj.%Id(),"Foo:4||Bar:4")
    Do json.%Set("_cloneExisting", 1, "boolean")
    Set obj = ##class(UnitTest.isc.json.sample.jsonNewPersistent).%JSONNew(json,,"IdIncluded")
    Do $$$AssertEquals(obj.%Id(),"")

    // Overridden
}

}

