Class %pkg.isc.json.util
{

ClassMethod ArrayToObject(ByRef array) As %Library.DynamicArray
{
 	Set out = [] //##class(%Library.DynamicArray).%New()

 	// Iterate over array elements (first subscript)
 	For i=1:1:$Get(array) {
 		Set element = {} //##class(%Library.DynamicObject).%New()
 		Set key = ""

 		// Iterate over array sub-elements (second subscript -> properties of the object in the array)
 		For {
 			Set key = $Order(array(i,key),1,value)
 			If (key = "") {
 				Quit
 			}

 			// Set element.<key> = <value>
 			// E.g., sets element.square = array(i,"square")
 			if ($ListValid(value) && (value '= "")){
				Set $Property(element,key) = ..ListToArray(value)
 			} 
 			else {
 				Set $Property(element,key) = value
 			}
		}
		// Add element i to the array
		Do out.%Push(element)
	}
	Quit out
}

ClassMethod ListToArray(list As %List) As %DynamicArray
{
	Set pointer = 0
	Set array = []
	While $ListNext(list,pointer,item) {
		Do array.%Push(item)
 	}
 	Quit array
}

ClassMethod ListOfDataTypesToArray(list As %ListOfDataTypes) As %DynamicArray
{
	Set array = []
	For i=1:1:list.Count() {
		Do array.%Push(list.GetAt(i))
	}
	Quit array
}

}

