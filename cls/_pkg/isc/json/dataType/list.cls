/// Special list datatype projected to/from JSON as an array
Class %pkg.isc.json.dataType.list Extends %Library.List [ System = 2 ]
{

Parameter JSONTYPE = "array";

ClassMethod LogicalToJSON(val As %List) As %String
{
	If '$ListValid(val) {
		Quit ""
	}
	Set array = ##class(%Library.DynamicArray).%New()
	Set pointer = 0
	While $ListNext(val,pointer,item) {
		If $Data(item)#2 {
			Do array.%Push(item)
		} Else {
			Do array.%Push("","null")
		}
	}
	Quit array
}

/// Converts the SOAP encoded input list value into an ObjectScript $list value.
ClassMethod JSONToLogical(val As %Library.DynamicArray) As %List
{
	If '$IsObject(val) && ('val.%IsA("%Library.DynamicArray")) {
		// Signal invalid by returning an empty string.
		Quit ""
	}
	Set list = ""
	Set iter = val.%GetIterator()
	While iter.%GetNext(.key,.value) {
		Set list = list_$Case(val.%GetTypeOf(key),
			"null":$ListBuild(),
			:$ListBuild(value))
	}
	Quit list
}

}

