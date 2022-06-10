/// Workaround to get JSON-specific errors into system message dictionary
Class %pkg.isc.json.localization [ System = 2 ]
{

/// Sets up the message dictionary for %ObjectErrors in English at compile time.
ClassMethod SetUpMsg() [ CodeMode = objectgenerator ]
{
	#Execute Set writable = 1 Try { Set ^%qMsg("%ObjectErrors","en",-1) = "" Kill ^%qMsg("%ObjectErrors","en",-1) } Catch { Set writable = 0 }
	#If writable
		// Errors added in this implementation:
		// $$$JSONReferencedTypeIsNotAdapted, $$$JSONInvalidIDPROJECTION
		Set errs($i(errs)) = $$$Text("@9450@Property '%1' in class '%2' is specified for JSON output as an object, but is of non-%JSONENABLED type '%3'.","%ObjectErrors","en")
		Set errs($i(errs)) = $$$Text("@9451@%JSONPROJECTION for property '%1' in class '%2' may not be %3 unless this property is of a persistent type.","%ObjectErrors","en")
		
		// $$$JSONPathExpressionError, $$$JSONPathEvalError
		Set errs($i(errs)) = $$$Text("@9460@Error evaluating JSON path expression '%1'","%ObjectErrors","en")
		Set errs($i(errs)) = $$$Text("@9461@Error evaluating expression: %1","%ObjectErrors","en")
	#Else
		Write !,"Warning: Unable to update localization for JSON-related errors in %ObjectErrors domain."
	#EndIf
	Quit $$$OK
}

}

