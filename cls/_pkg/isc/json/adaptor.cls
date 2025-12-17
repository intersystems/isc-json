Include (%occInclude, %callout, %pkg.isc.json.map)

IncludeGenerator %occInclude

/// The following table displays the correspondence between JSON field values and
/// property values that will be implemented by the JSON Adaptor.<br /><br />
/// 
/// The actual conversion between registered object values and JSON values will be done by new datatype methods: JSONToLogical and LogicalToJSON.
/// In addition, a new JSONTYPE parameter will be introduced for the datatype classes
/// which indicates how the data type will be mapped to JSON.<br /><br />
/// 
/// <pre>
/// JSON                                            Registered object type
/// object                                          class referenced by property
/// array - error if all values are not literals    %ListOfDatatypes
/// array - error if all values are not objects     %ListOfObjects or relationship
/// array - error if all values are not literals    %List
/// string                                          %String, %Char, %Name, %FileCharacterStream, %GlobalCharacterStream
/// string - must be base64 encoded                 %Binary, %FileBinaryStream, %GlobalBinaryStream
/// string - ODBC format date                       %Date
/// string - ODBC format time                       %Time
/// string - ODBC format date/time                  %DateTime, %TimeStamp
/// numeric - bounds must match object type         %BigInt, %Currency, %Decimal, %Double, %Float, %Integer, %Numeric, %SmallInt, %TinyInt
/// boolean                                         %Boolean
/// 
/// </pre>
/// Note that the types %xsd package are all subclasses of base % datatypes and will map as the super type.<br /><br />
Class %pkg.isc.json.adaptor [ Abstract, PropertyClass = %pkg.isc.json.propertyParameters, System = 3 ]
{

/// If this parameter is true then JSON-enabling methods will be generated. 
/// Otherwise, the method generators do not produce a runnable method.
Parameter %JSONENABLED = 1;

/// The %JSONIGNOREINVALIDFIELD parameter allows the programmer to control handling of unexpected fields in the JSON input.
/// The default (%JSONIGNOREINVALIDFIELD = 0) will treat an unexpected field as an error.
/// If %JSONIGNOREINVALIDFIELD is set = 1, then unexpected fields will be ignored.
Parameter %JSONIGNOREINVALIDFIELD As BOOLEAN = 0;

/// If %JSONNULL is true (=1), then unspecified properties are exported as the null value.
/// Otherwise the field corresponding to the property is just skipped during export. 
/// The corresponding property parameter overrides this parameter if specified.
Parameter %JSONNULL As BOOLEAN = 0;

/// %JSONIGNORENULL allows the programmer to override the default handling of empty strings for string properties.
/// This paramneter applies to only true strings which is determined by XSDTYPE = "string" as well as JSONTYPE="string"
/// By default (%JSONIGNORENULL = 0), empty strings in the JSON input are stored as $c(0)
/// and $c(0) is written to JSON as the string "". A missing field in the JSON input is always stored as ""
/// and "" is always output to JSON according to the %JSONNULL parameter.<br />
/// If %JSONIGNORENULL is set = 1, then both missing fields in the JSON and empty strings are input as "",
/// and both "" and $c(0) are output as field values of "". 
/// The corresponding property parameter overrides this parameter if specified.
Parameter %JSONIGNORENULL As BOOLEAN = 0;

/// %JSONREFERENCE specifies the default value of the %JSONREFERENCE property parameter that specifies how to
/// project references to JSON.  %JSONREFERENCE may be specified for any property to override this default value.
/// Possible values of %JSONREFERENCE are "OBJECT", "ID", "OID", "GUID".
/// ="OBJECT" is the default and indicates that the properties of the referenced class are used to represent the referenced object.<br />
/// ="ID" indicates that the id of a persistent or serial class is used to represent the reference.<br />
/// ="OID" indicates that the oid of a persistent or serial class is used to represent the reference.
///  The form of the oid as projected to JSON will be classname,id.<br />
/// ="GUID" indicates the GUID of a persistent class is used to represent the reference.<br />
/// The corresponding property parameter overrides this parameter if specified.
Parameter %JSONREFERENCE As STRING [ Constraint = "OBJECT,ID,OID,GUID", Flags = ENUM ] = "OBJECT";

/// %JSONINCLUDEID allows the ID to be included (output-only) in representations of the object.
Parameter %JSONINCLUDEID As BOOLEAN = 0;

/// %JSONDEFAULTMAPPING may be set to 0 (default is 1) to suppress creation of the default JSON mapping for the object.
Parameter %JSONDEFAULTMAPPING As BOOLEAN = 1;

/// %JSONIDFIELD specifies the field name to use for the ID in representations of the object, if enabled by <parameter>%JSONINCLUDEID</parameter>
Parameter %JSONIDFIELD As STRING = "_id";

/// %JSONMAPPING specifies a class-default JSON mapping to use for object projections of other classes.
Parameter %JSONMAPPING As STRING;

/// %JSONFIELDNAMEASCAMELCASE auto-generates the %JSONFIELDNAME for properties (if not specified)
/// as camelCase.
Parameter %JSONFIELDNAMEASCAMELCASE As BOOLEAN = 0;

/// %JSONImport imports JSON or dynamic object input into this object.<br />
/// The input argument is either JSON as a string or stream, or a subclass of %DynamicAbstractObject.<br />
/// mappingName is the name of the mapping to use for the import.  The base mapping is represented by "" and is the default.
/// If a mapping name is provided that does not exist, an error is thrown. <br />
Method %JSONImport(input, %mappingName As %String = "") As %Status [ ServerOnly = 1 ]
{
	Try {
		Set sc=$$$OK
		New %JSONObject
		If $isobject(input),input.%IsA("%Library.DynamicAbstractObject") {
			// Already a dynamic object
			Set %JSONObject=input
		} Else {
			// A JSON stream or string
			Set %JSONObject=##class(%Library.DynamicAbstractObject).%FromJSON(input)
		}
		
		// Do the import now.
		Set sc=..%JSONImportInternal()
		
	} Catch ex {
		Set sc=ex.AsStatus()
	}

	Quit sc
}

/// Import an array of JSON records into a list of objects for this class. <var>list</var> can be provided.
/// If not provided, one is created. Imported elements are added to the end of the list. <br />
/// <var>mappingName</var> is the name of the mapping to use for the import. The base mapping is 
/// represented by "" and is the default. <br />
/// If a mapping name is provided that does not exist, an error is thrown. <br />
/// <var>behavior</var> has the following structure: <br />
/// <pre>
/// {
/// 	// Only valid for persistant records. Ignored if class is not persistent.
/// 	// Default: false.
/// 	"save": boolean;
/// 	// Whether to accumulate errors instead of quitting on the first error encountered.
/// 	// Default: true.
/// 	"accumulateErrors": boolean;
/// }
/// </pre>
/// <var>errorLog</var> contains errors that occurred indexed by the array index on which the error
/// occurred. When accumulateErrors is false, this would have at most one entry. <br />
/// <code>
/// errorLog(3) = "error status from importing index element 4 (5th element) in the JSON array" <br />
/// errorLog(7) = "error status from importing index element 7 (8th element) in the JSON array" <br />
/// </code>
ClassMethod %JSONImportArray(array As %DynamicArray, mappingName As %String = "", behavior As %DynamicObject = "", ByRef list As %ListOfObjects, Output errorLog) As %Status
{
	Set sc = $$$OK
	Set totalSc = $$$OK
	Kill errorLog
	Try {
		If '$IsObject($Get(behavior)) {
			Set behavior = {}
		}
		Set save = behavior.%Get("save", 0)
		Set accumulate = behavior.%Get("accumulateErrors", 1)
		If '(($Data(list)#2) && $IsObject(list) && list.%Extends("%ListOfObjects")) {
			Set list = ##class(%ListOfObjects).%New()
			Set list.ElementType = $ClassName()
		}
		Set isPersistent = $ClassMethod($ClassName(), "%Extends", "%Persistent")
		Set iter = array.%GetIterator()
		While iter.%GetNext(.index, .value) {
			Set iterSc = $$$OK
			#dim obj As %pkg.isc.json.adaptor
			Set obj = ..%JSONNew(value, , mappingName)
			Set importSc = obj.%JSONImport(value, mappingName)
			Set iterSc = $$$ADDSC(iterSc,importSc)
			If save && isPersistent && $$$ISOK(importSc) {
				Set iterSc = $$$ADDSC(iterSc,obj.%Save())
			}
			Set iterSc = $$$ADDSC(iterSc,list.Insert(obj))
			// Error handling
			If $$$ISERR(iterSc) {
				Set errorLog(index) = iterSc
			}
			If (accumulate) {
				Set totalSc = $$$ADDSC(totalSc,iterSc)
			} Else {
				$$$ThrowOnError(iterSc)
			}
		}
		$$$ThrowOnError(totalSc)
	} Catch (ex) {
		Set sc = ex.AsStatus()
	}
	Return sc
}

/// Get an instance of an JSON enabled class.<br /><br />
/// 
/// You may override this method to do custom processing (such as initializing
/// the object instance) before returning an instance of this class.
/// However, this method should not be called directly from user code.<br />
/// Arguments:<br />
///     dynamicObject is the dynamic object with thee values to be assigned to the new object.<br />
///     containerOref is the containing object instance when called from JSONImport. <br />
/// 	mappingName is the name of the mapping to use for the export. The base mapping is represented by "" and is the default.
/// 	If a mapping name is provided that does not exist, an error is thrown. <br />
ClassMethod %JSONNew(dynamicObject As %DynamicObject, containerOref As %RegisteredObject = "", %mappingName As %String = "") As %RegisteredObject
{
	Return ..%JSONNewDefault(dynamicObject, containerOref, %mappingName)
}

/// Serialize a JSON enabled class as a JSON document and write it to the current device.<br />
/// mappingName is the name of the mapping to use for the export. The base mapping is represented by "" and is the default.
/// If a mapping name is provided that does not exist, an error is thrown. <br />
Method %JSONExport(%mappingName As %String = "") As %Status
{
	Set sc=$$$OK
	Try {
		// Do the export to current device now.
		$$$ThrowOnError(..%JSONExportToDynamicObject(.json, %mappingName))
		Do json.%ToJSON()
	} Catch ex {
		Set sc=ex.AsStatus()
	}
	Return sc
}

/// Serialize a JSON enabled class as a JSON document and write it to a stream.<br />
/// mappingName is the name of the mapping to use for the export.  The base mapping is represetned by "" and is the default.
/// If a mapping name is provided that does not exist, an error is thrown. <br />
Method %JSONExportToStream(ByRef export As %Stream.Object, %mappingName As %String = "") As %Status
{
	Set sc = $$$OK
	Try {
		// Always output to %FileCharacterStream
		If $get(export)="" {
			Set export=##class(%Stream.FileCharacter).%New()
			// JSON is always UTF-8
			Set export.TranslateTable="UTF8"
			Set filestream=1
		}
		$$$ThrowOnError(..%JSONExportToDynamicObject(.json, %mappingName))
		Do json.%ToJSON(.export)
	} Catch ex {
		Set sc=ex.AsStatus()
	}
	Return sc
}

/// Serialize a JSON enabled class as a JSON document and return it as a string.<br />
/// mappingName is the name of the mapping to use for the export.  The base mapping is represented by "" and is the default.
/// If a mapping name is provided that does not exist, an error is thrown. <br />
Method %JSONExportToString(ByRef export As %String, %mappingName As %String = "") As %Status
{
	Set sc=$$$OK
	Try {
		// Do the export to current device now.
		Set export=""
		$$$ThrowOnError(..%JSONExportToDynamicObject(.json, %mappingName))
		Set export = json.%ToJSON()
	} Catch ex {
		If ex.Name="<MAXSTRING>" {
			Set sc=$$$ERROR($$$JSONMaxString,$$$mappingNameDisplay(%mappingName))
		} Else {
			Set sc=ex.AsStatus()
		}
	}
	Return sc
}

/// Serialize a JSON enabled class as a JSON document and return it as JSON.<br />
/// mappingName is the name of the mapping to use for the export.  The base mapping is reprtesened by "" and is the default.
/// If a mapping name is provided that does not exist, an error is thrown. <br />
Method %JSONExportToDynamicObject(Output %export As %DynamicObject, %mappingName As %String = "") As %Status
{
	Set sc = $$$OK
	Try {
		Set %export = {}
		Do ..%JSONExportInternal()
	} Catch (ex) {
		Set sc = ex.AsStatus()
	}
	Return sc
}

/// Export the provided list to a JSON array. <var>array</var> can be provided. Entries are appended
/// to the end of the array. <br />
/// The list can be one of the following: <br />
/// If the class is NOT persistent: <br />
/// <ul>
/// 	<li>%ListOfObjects: List of objects of the current class to export.</li>
/// </ul>
/// If the class is persistent: <br />
/// <ul>
/// 	<li>%ListOfObjects: List of objects of the current class to export.</li>
/// 	<li>%List: List of IDs</li>
/// 	<li>%ListOfDataTypes: List of IDs</li>
/// 	<li>%DynamicArray: Array of IDs</li>
/// 	<li>%SQL.StatementResult: ResultSet where the ID column is used to identify records to export.</li>
/// </ul>
/// mappingName is the name of the mapping to get metadata for. 
/// The base mapping is represented by "" and is the default.
/// If a mapping name is provided that does not exist, an error is thrown. <br />
/// <var>behavior</var> has the following structure: <br />
/// <pre>
/// {
/// 	// Whether to accumulate errors instead of quitting on the first error encountered.
/// 	// Default: true.
/// 	"accumulateErrors": boolean;
/// }
/// </pre>
/// <var>errorLog</var> contains errors that occurred indexed by the list index on which the error
/// occurred. When accumulateErrors is false, this would have at most one entry. <br />
/// <code>
/// errorLog(3) = "error status from importing index element 4 (5th element) in the JSON array" <br />
/// errorLog(7) = "error status from importing index element 7 (8th element) in the JSON array" <br />
/// </code>
ClassMethod %JSONExportArray(list As %RawString, mappingName As %String = "", behavior As %DynamicObject = "", ByRef array As %DynamicArray, Output errorLog) As %Status
{
	#dim objList as %ListOfObjects
	#dim idList as %ListOfDataTypes
	#dim obj as %pkg.isc.json.adaptor
	#dim arrList as %DynamicArray
	#dim rs as %SQL.StatementResult
	Set invalidInputError = $$$ERROR($$$JSONInvalidListForExportArray,$ClassName())
	Set sc = $$$OK
	Set totalSc = $$$OK
	Kill errorLog
	Try {
		Set isPersistent = $ClassMethod($ClassName(),"%Extends","%Persistent")
		If '$IsObject($Get(array)) {
			Set array = []
		}
		If '$IsObject($Get(behavior)) {
			Set behavior = {}
		}
		Set accumulate = behavior.%Get("accumulateErrors", 1)
		If $IsObject(list) {
			If isPersistent && list.%Extends("%DynamicArray") {
				Set arrList = list
				Set iter = arrList.%GetIterator()
				While iter.%GetNext(.index, .id) {
					Set iterSc = $$$OK
					Set obj = $ClassMethod($ClassName(), "%OpenId", id, 0, .sc)
					Set iterSc = $$$ADDSC(iterSc,sc)
					If $IsObject(obj) {
						Set iterSc = $$$ADDSC(iterSc,obj.%JSONExportToDynamicObject(.json,mappingName))
						If $$$ISOK(iterSc) {
							Do array.%Push(json)
						}
					}
					// Clear up memory
					Kill obj
					// Error handling
					If $$$ISERR(iterSc) {
						Set errorLog(index) = iterSc
					}
					If (accumulate) {
						Set totalSc = $$$ADDSC(totalSc,iterSc)
					} Else {
						$$$ThrowOnError(iterSc)
					}
				}
			} ElseIf list.%Extends("%ListOfObjects") {
				// Only one that supports non-persistent
				Set objList = list
				For i = 1:1:objList.Count() {
					Set iterSc = $$$OK
					Set obj = objList.GetAt(i)
					Set iterSc = $$$ADDSC(iterSc,obj.%JSONExportToDynamicObject(.json,mappingName))
					If $$$ISOK(iterSc) {
						Do array.%Push(json)
					}
					// Clear up memory
					Kill obj
					// Error handling
					If $$$ISERR(iterSc) {
						Set errorLog(i-1) = iterSc
					}
					If (accumulate) {
						Set totalSc = $$$ADDSC(totalSc,iterSc)
					} Else {
						$$$ThrowOnError(iterSc)
					}
				}
			} ElseIf isPersistent && list.%Extends("%ListOfDataTypes") {
				Set idList = list
				For i = 1:1:idList.Count() {
					Set iterSc = $$$OK
					Set id = idList.GetAt(i)
					Set obj = $ClassMethod($ClassName(), "%OpenId", id, 0, .sc)
					Set iterSc = $$$ADDSC(iterSc,sc)
					If $IsObject(obj) {
						Set iterSc = $$$ADDSC(iterSc,obj.%JSONExportToDynamicObject(.json,mappingName))
						If $$$ISOK(iterSc) {
							Do array.%Push(json)
						}
					}
					// Clear up memory
					Kill obj
					// Error handling
					If $$$ISERR(iterSc) {
						Set errorLog(i-1) = iterSc
					}
					If (accumulate) {
						Set totalSc = $$$ADDSC(totalSc,iterSc)
					} Else {
						$$$ThrowOnError(iterSc)
					}
				}
			} ElseIf isPersistent && list.%Extends("%SQL.StatementResult") {
				Set rs = list
				Set index = 0
				While rs.%Next(.sc) {
					Set iterSc = $$$OK
					Set id = rs.%Get("ID")
					If (id = "") {
						Continue
					}
					Set obj = $ClassMethod($ClassName(), "%OpenId", id, 0, .sc)
					Set iterSc = $$$ADDSC(iterSc,sc)
					If $IsObject(obj) {
						Set iterSc = $$$ADDSC(iterSc,obj.%JSONExportToDynamicObject(.json,mappingName))
						If $$$ISOK(iterSc) {
							Do array.%Push(json)
						}
					}
					// Clear up memory
					Kill obj
					// Error handling
					If $$$ISERR(iterSc) {
						Set errorLog(index) = iterSc
					}
					If (accumulate) {
						Set totalSc = $$$ADDSC(totalSc,iterSc)
					} Else {
						$$$ThrowOnError(iterSc)
					}
					Do $Increment(index)
				}
			} Else {
				$$$ThrowStatus(invalidInputError)
			}
		} ElseIf isPersistent && $ListValid(list) {
			Set ptr = 0
			Set index = 0
			While $ListNext(list,ptr,id) {
				Set iterSc = $$$OK
				Set obj = $ClassMethod($ClassName(), "%OpenId", id, 0, .sc)
				Set iterSc = $$$ADDSC(iterSc,sc)
				If $IsObject(obj) {
					Set iterSc = $$$ADDSC(iterSc,obj.%JSONExportToDynamicObject(.json,mappingName))
					If $$$ISOK(iterSc) {
						Do array.%Push(json)
					}
				}
				// Clear up memory
				Kill obj
				// Error handling
				If $$$ISERR(iterSc) {
					Set errorLog(index) = iterSc
				}
				If (accumulate) {
					Set totalSc = $$$ADDSC(totalSc,iterSc)
				} Else {
					$$$ThrowOnError(iterSc)
				}
				Do $Increment(index)
			}
		} Else {
			$$$ThrowStatus(invalidInputError)
		}
		// Throw on error at the end
		$$$ThrowOnError(totalSc)
	} Catch (ex) {
		Set sc = ex.AsStatus()
	}
	Return sc
}

/// Returns metadata about a provided JSON mapping for the current JSON serializable class. <br />
/// mappingName is the name of the mapping to get metadata for. The base mapping is represented by "" and is the default.
ClassMethod %JSONMappingInfo(Output mappingInfo As %pkg.isc.json.mappingInfo, %mappingName As %String = "") As %Status
{
	Set sc = $$$OK
	Try {
		Set mappingInfo = ..%JSONMappingInfoInternal()
	} Catch (ex) {
		Set sc = ex.AsStatus()
	}
	Return sc
}

/// Dummy method which exists to force GenerateAfter code to take affect for %JSONGenerate.
/// The GenerateAfter will not have affect unless the after method is laterin collating sequence.
/// All this is necessary to force geenrator methods to be run after member methods are created.
/// 
/// This method is for internal use only. You should not make direct
/// use of it within your applications. There is no guarantee made about either
/// the behavior or future operation of this method.		
Method %JSONX() [ Abstract, Internal, ServerOnly = 1 ]
{
	Quit
}

/// %JSONGenerate is an internal method that controls the generation of the other methods in %pkg.isc.json.adaptor.
/// If %JSONGenerate is overridden, then JSON meta data and the other generator methods
/// of %pkg.isc.json.adaptor will not be created.<p>
ClassMethod %JSONGenerate() [ CodeMode = generator, GenerateAfter = %JSONX, Internal, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).%JSONGenerate(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// %JSONImportInternal is internal method used by %JSONImport
Method %JSONImportInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).JSONImportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// %JSONExportInternal is internal method used by %JSONExport
Method %JSONExportInternal() [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).JSONExportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// Internal method used by %JSONMappingInfo
ClassMethod %JSONMappingInfoInternal() As %pkg.isc.json.mappingInfo [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).JSONMappingInfo(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// Generates default handling for JSONNew implementation. If overriding <method>%JSONNew</method>,
/// this can be called to retain the generated default handling (similar to calling super for non-generated
/// but inherited methods)
ClassMethod %JSONNewDefault(dynamicObject As %DynamicObject, containerOref As %RegisteredObject = "", %mappingName As %String = "") As %RegisteredObject [ CodeMode = generator, GenerateAfter = %JSONGenerate ]
{
	Quit ##class(%pkg.isc.json.generator).JSONNewDefault(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

}
