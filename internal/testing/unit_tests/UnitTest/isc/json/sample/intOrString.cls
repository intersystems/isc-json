/// Can be an integer or a string.
Class UnitTest.isc.json.sample.intOrString Extends (%String, %Integer)
{

Parameter JSONTYPE = "runtime";

ClassMethod GetJSONTYPE(value As %String) As %String
{
    Set intSc = ##class(%Integer).IsValid(value)
    If $$$ISOK(intSc) {
        Return "number"
    }
    Return "string"
}

ClassMethod IsValid(value As %String) As %Status
{
    Set intSc = ##class(%Integer).IsValid(value)
    Set strSc = ##class(%String).IsValid(value)
    If $$$ISERR(intSc) && $$$ISERR(strSc) {
        Return $$$ADDSC(intSc,strSc)
    }
    Return $$$OK
}

ClassMethod JSONToLogical(value As %String) As %String
{
    Return value
}

ClassMethod LogicalToJSON(value As %String) As %String
{
    If ##class(%Integer).IsValid(value) {
        Return value
    }
    Return value
}

}

