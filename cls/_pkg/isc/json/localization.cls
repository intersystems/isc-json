/// Workaround to get JSON-specific errors into system message dictionary
Class %pkg.isc.json.localization [ System = 2 ]
{

/// Sets up the message dictionary for %ObjectErrors in English at compile time.
ClassMethod SetUpMsg() [ CodeMode = objectgenerator ]
{
	#Execute Set writable = 1 Try { Set ^%qMsg("%ObjectErrors","en",-1) = "" Kill ^%qMsg("%ObjectErrors","en",-1) } Catch { Set writable = 0 }
	#If writable
		#If ##Expression('($zversion [ "IRIS"))
			Set errs($i(errs)) = $$$Text("@9400@Invalid value for default class %1 in %2 mapping.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9401@Invalid value for property %1 for property %2 in %3 mapping.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9402@JSON projection of an array of streams is not supported in property: %1 in %2 mapping.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9403@JSON output string length is greater than the maximum string length using %1 mapping.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9404@Unexpected field in input, %1, using %2 mapping.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9405@Required field not present, %1, using %2 mapping","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9406@Unexpected format for value of field, %1, using %2 mapping","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9407@%1 element is not in expected namespace in Mapping XData block, %2.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9408@Only one Mapping allowed in XData block, %1.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9409@A Property element was specified without a Name attribute in mapping %1.","%ObjectErrors","en")
			Set errs($i(errs)) = $$$Text("@9410@Property name, %1, not found in class that is being mapped in mapping %2.","%ObjectErrors","en")
		#EndIf
		
		// Errors added in this implementation:
		// $$$JSONReferencedTypeIsNotAdapted, $$$JSONInvalidIDPROJECTION
		Set errs($i(errs)) = $$$Text("@9450@Property '%1' in class '%2' is specified for JSON output as an object, but is of non-%JSONENABLED type '%3'.","%ObjectErrors","en")
		Set errs($i(errs)) = $$$Text("@9451@%JSONPROJECTION for property '%1' in class '%2' may not be %3 unless this property is of a persistent type.","%ObjectErrors","en")
	#Else
		Write !,"Warning: Unable to update localization for JSON-related errors in %ObjectErrors domain."
	#EndIf
	Quit $$$OK
}

}

