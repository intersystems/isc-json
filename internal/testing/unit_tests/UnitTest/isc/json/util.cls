Class UnitTest.isc.json.util Extends %UnitTest.TestCase
{

Method TestListOfDataTypesToArray()
{
    set list = ##class(%ListOfDataTypes).%New()
    do list.Insert("one")
    do list.Insert("two")
    set dynArray = ##class(%pkg.isc.json.util).ListOfDataTypesToArray(list)
    do $$$AssertEquals(dynArray.%Size(),2)
    do $$$AssertEquals(dynArray.%Get(0),"one")
    do $$$AssertEquals(dynArray.%Get(1),"two")
}

Method TestListToArray()
{
    set list = $listbuild("one","two")
    set dynArray = ##class(%pkg.isc.json.util).ListToArray(list)
    do $$$AssertEquals(dynArray.%Size(),2)
    do $$$AssertEquals(dynArray.%Get(0),"one")
    do $$$AssertEquals(dynArray.%Get(1),"two")
}

}

