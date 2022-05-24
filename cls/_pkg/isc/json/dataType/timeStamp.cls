Class %pkg.isc.json.dataType.timeStamp Extends %Library.TimeStamp [ System = 2 ]
{

/// Converts the SOAP encoded input dateTime value into a Cache %TimeStamp value.
ClassMethod XSDToLogical(%val As %String) As %TimeStamp [ CodeMode = generator, ServerOnly = 1 ]
{
	If ($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"XMLENABLED",$$$cPARAMdefault) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		$$$GENERATE("	If $length($get(%val),""T"")'=2 Quit """"")
		$$$GENERATE("	Set dt=$translate(%val,""T"","" "")")
		$$$GENERATE("	Set len=$length(%val)")
		$$$GENERATE("	If $extract(%val,len)=""Z"" {")
		$$$GENERATE("		Set dt=$extract(dt,1,len-1)")
		$$$GENERATE("	} ElseIf $case($extract(%val,len-5),""+"":1,""-"":1,:0) {")
		$$$GENERATE("		If $extract(%val,len-2)'="":"" Quit """"")
		$$$GENERATE("		Set dt=$extract(dt,1,len-6)")
		If %parameter("XMLTIMEZONE")'="IGNORE" {
			$$$GENERATE("		Set f=$piece(dt,""."",2) If f'="""" Set f="".""_f,dt=$piece(dt,""."")")
			$$$GENERATE("		Set t=$zdatetimeh(dt,3,1,,,,,,,"""") If t="""" Quit """_%parameter("XMLDEFAULTVALUE")_"""")
			$$$GENERATE("		Set d=$piece(t,"","")")
			$$$GENERATE("		Set s=$piece(t,"","",2)")
			$$$GENERATE("		Set z=($extract(%val,len-4,len-3)*60+$extract(%val,len-1,len))*60")
			$$$GENERATE("		If $extract(%val,len-5)=""-"" {")
			$$$GENERATE("			Set s=s+z")
			$$$GENERATE("			If s>=(24*60*60) Set d=d+1,s=s-(24*60*60)")
			$$$GENERATE("		} Else {")
			$$$GENERATE("			Set s=s-z")
			$$$GENERATE("			If s<0 Set d=d-1,s=s+(24*60*60)")
			$$$GENERATE("		}")
			$$$GENERATE("		Set dt=$zdatetime(d_"",""_s,3,1,0,,,,,,,"""")")
			$$$GENERATE("		Quit $select(dt="""":"""",1:dt_f)")
		}
		$$$GENERATE("	}")
		$$$GENERATE("	If $zdatetimeh(dt,3,1,,,,,,,"""")="""" Quit """_%parameter("XMLDEFAULTVALUE")_"""")
		$$$GENERATE("	Quit dt")
	} Else {
		Set %code=0 
	}
	Quit $$$OK
}

/// Converts the Cache %TimeStamp value to the canonical SOAP encoded value.
ClassMethod LogicalToXSD(%val As %TimeStamp) As %String [ CodeMode = generator, ServerOnly = 1 ]
{
	If ($$$getClassType(%class)=$$$cCLASSCLASSTYPEDATATYPE) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"XMLENABLED",$$$cPARAMdefault) || $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		Set %codemode=$$$cMETHCODEMODEEXPRESSION
		If %parameter("XMLTIMEZONE")="IGNORE" {
			Set %code="$translate(%val,"" "",""T"")"
		} Else {
			Set %code="$select(%val="""":"""",1:$translate(%val,"" "",""T"")_""Z"")"
		}
	} Else {
		Set %code=0 
	}
	Quit $$$OK
}

}

