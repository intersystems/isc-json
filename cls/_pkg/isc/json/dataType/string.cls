Class %pkg.isc.json.dataType.string Extends %Library.String [ System = 2 ]
{

/// Used to specify the name of the parameter which contains the enumeration list for JSON values.
/// The parameter which contains the list must be in the format used for VALUELIST and DISPLAYLIST.
/// The default is VALUELIST.
Parameter JSONLISTPARAMETER;

/// JSONTYPE is JSON type used for this datatype.
Parameter JSONTYPE = "string";

/// If JSONLISTPARAMETER is specified, XSDToLogical is generated which imports using the list specified by JSONLISTPARAMETER.
ClassMethod JSONToLogical(%val As %String) As %String [ CodeMode = generator, ServerOnly = 1 ]
{
	Set %code=0
	Set jsonlist=$get(%parameter("JSONLISTPARAMETER"))
	If $case(jsonlist,"":0,"VALUELIST":0,:1),%parameter("VALUELIST")'="",$get(%parameter(jsonlist))'="",($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		do GenerateValConv^%occLibrary(%parameter(jsonlist),%parameter("VALUELIST"))
	}
	Quit $$$OK
}

/// If JSONLISTPARAMETER is specified, XSDToLogical is generated which exports using the list specified by JSONLISTPARAMETER.
ClassMethod LogicalToJSON(%val As %String) As %String [ CodeMode = generator, ServerOnly = 1 ]
{
	Set %code=0
	Set jsonlist=$get(%parameter("JSONLISTPARAMETER"))
	If $case(jsonlist,"":0,"VALUELIST":0,:1),%parameter("VALUELIST")'="",$get(%parameter(jsonlist))'="",($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		do GenerateValConv^%occLibrary(%parameter("VALUELIST"),%parameter(jsonlist),%parameter("COLLATION"))
	}
	Quit $$$OK
}

}

