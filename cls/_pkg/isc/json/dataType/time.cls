Class %pkg.isc.json.dataType.time Extends %Library.Time [ System = 2 ]
{

/// Converts the SOAP encoded input time value into a Cache %Time value.
ClassMethod XSDToLogical(%val As %String) As %Time [ CodeMode = generator, ServerOnly = 1 ]
{
	If ($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"XMLENABLED",$$$cPARAMdefault) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		$$$GENERATE(" If $get(%val)="""" Quit """"")
		$$$GENERATE(" If $length(%val,""T"")=2 Set %val=$piece(%val,""T"",2)")
		$$$GENERATE(" Set len=$length(%val)")
		$$$GENERATE(" If $extract(%val,len)=""Z"" {")
		$$$GENERATE("   Set %val=$extract(%val,1,len-1)")
		$$$GENERATE(" } ElseIf $case($extract(%val,len-5),""+"":1,""-"":1,:0) {")
		$$$GENERATE("   If $extract(%val,len-2)'="":"" Quit """"")
		If %parameter("XMLTIMEZONE")="IGNORE" {
			$$$GENERATE("   Set %val=$extract(%val,1,len-6)")
		} Else {
			$$$GENERATE("   Set s=$ztimeh($extract(%val,1,len-6),1,"""",1) If s="""" Quit """"")
			$$$GENERATE("   Set z=($extract(%val,len-4,len-3)*60+$extract(%val,len-1,len))*60")
			$$$GENERATE("   If $extract(%val,len-5)=""-"" {")
			$$$GENERATE("     Set s=s+z")
			$$$GENERATE("   } Else {")
			$$$GENERATE("     Set s=s-z")
			$$$GENERATE("   }")
			If $get(%parameter("PRECISION"))="" {
				$$$GENERATE("   Quit s#86400")
			} Else {
				$$$GENERATE("   Quit $fnumber(s#86400,"""","_$get(%parameter("PRECISION"))_")")
			}
		}
		$$$GENERATE(" }")
		If $get(%parameter("PRECISION"))="" {
			$$$GENERATE(" Quit $ztimeh(%val,1,"""",1)")
		} Else {
			$$$GENERATE(" Quit $fnumber($ztimeh(%val,1,"""",1),"""","_$get(%parameter("PRECISION"))_")")
		}
	} Else {
		Set %code=0 
	}
	Quit $$$OK
}

/// Converts the Cache %Time value to the canonical SOAP encoded value.
ClassMethod LogicalToXSD(%val As %Time) As %String [ CodeMode = generator, ServerOnly = 1 ]
{
	If ($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"XMLENABLED",$$$cPARAMdefault) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		Set %codemode=$$$cMETHCODEMODEEXPRESSION
		If %parameter("XMLTIMEZONE")="IGNORE" {
			Set %code="$select(%val="""":"""",1:$ztime(%val,1,"_$select($get(%parameter("PRECISION"))="":"$l($p(%val,""."",2))",1:$get(%parameter("PRECISION")))_",,1))"
		} Else {
			Set %code="$select(%val="""":"""",1:$ztime(%val,1,"_$select($get(%parameter("PRECISION"))="":"$l($p(%val,""."",2))",1:$get(%parameter("PRECISION")))_",,1)_""Z"")"
		}
	} Else {
		Set %code=0 
	}
	Quit $$$OK
}

}

