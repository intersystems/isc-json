Class %pkg.isc.json.dataType.date Extends %Library.Date [ System = 2 ]
{

/// Converts the SOAP encoded input date value into a Cache %Date value.
ClassMethod JSONToLogical(%val As %String) As %Date [ CodeMode = generator, ServerOnly = 1 ]
{
    If ($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
        $$$GENERATE("   Quit $select(%val="""":"""",1:$zdateh(%val,3,,,,,"_$s(%parameter("MINVAL")="":-672045,1:%parameter("MINVAL"))_","_%parameter("MAXVAL")_",""""))")
	} Else {
		Set %code=0
	}
    Quit $$$OK
}

/// Converts the Cache %Date value to the canonical SOAP encoded value.
ClassMethod LogicalToJSON(%val As %Date) As %String [ CodeMode = generator, ServerOnly = 1 ]
{
    If ($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
        $$$GENERATE("   quit $select(%val="""":"""",1:$zdate(%val,3,,,,,"_$s(%parameter("MINVAL")="":-672045,1:%parameter("MINVAL"))_"))")
	} Else {
		Set %code=0
    }
    Quit $$$OK
}

}

