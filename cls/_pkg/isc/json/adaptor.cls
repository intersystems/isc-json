Include (%occInclude, %callout, %pkg.isc.json.map)

IncludeGenerator %occInclude

/// The following table displays the correspondence between JSON field values and
/// property values that will be implemented by the JSON Adaptor.<br><br>
/// 
/// The actual conversion between registered object values and JSON values will be done by new datatype methods: JSONToLogical and LogicalToJSON.
/// In addition, a new JSONTYPE parameter will be introduced for the datatype classes
/// which indicates how the daat type will be mapped to JSON.<br><br>
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
/// Note that the types %xsd package are all subclasses of base % datatypes and will map as the super type.<br><br>
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
/// and "" is always output to JSON according to the %JSONNULL parameter.<br>
/// If %JSONIGNORENULL is set = 1, then both missing fields in the JSON and empty strings are input as "",
/// and both "" and $c(0) are output as field values of "". 
/// The corresponding property parameter overrides this parameter if specified.
Parameter %JSONIGNORENULL As BOOLEAN = 0;

/// %JSONREFERENCE specifies the default value of the %JSONREFERENCE property parameter that specifies how to
/// project references to JSON.  %JSONREFERENCE may be specified for any property to override this default value.
/// Possible values of %JSONREFERENCE are "OBJECT", "ID", "OID", "GUID".
/// ="OBJECT" is the default and indicates that the properties of the referenced class are used to represent the referenced object.<br>
/// ="ID" indicates that the id of a persistent or serial class is used to represent the reference.<br>
/// ="OID" indicates that the oid of a persistent or serial class is used to represent the reference.
///  The form of the oid as projected to JSON will be classname,id.<br>
/// ="GUID" indicates the GUID of a persistent class is used to represent the reference.<br>
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

/// %JSONImport imports JSON or dynamic object input into this object.<br>
/// The input argument is either JSON as a string or stream, or a subclass of %DynamicAbstractObject.<br>
/// mappingName is the name of the mapping to use for the import.  The base mapping is represened by "" and is the default.
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

/// Get an instance of an JSON enabled class.<br><br>
/// 
/// You may override this method to do custom processing (such as initializing
/// the object instance) before returning an instance of this class.
/// However, this method should not be called directly from user code.<br>
/// Arguments:<br>
///     dynamicObject is the dynamic object with thee values to be assigned to the new object.<br>
///     containerOref is the containing object instance when called from JSONImport.
ClassMethod %JSONNew(dynamicObject As %DynamicObject, containerOref As %RegisteredObject = "") As %RegisteredObject [ CodeMode = generator, GenerateAfter = %JSONGenerate, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).JSONNew(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// Serialize a JSON enabled class as a JSON document and write it to the current device.<br>
/// mappingName is the name of the mapping to use for the export.  The base mapping is represened by "" and is the default.
Method %JSONExport(%mappingName As %String = "") As %Status
{
	Try {
		Set sc=$$$OK
		
		// Do the export to current device now.
		Set sc=..%JSONExportInternal()

	} Catch ex {
		Set sc=ex.AsStatus()
	}

	Quit sc
}

/// Serialize a JSON enabled class as a JSON document and write it to a stream.<br>
/// mappingName is the name of the mapping to use for the export.  The base mapping is represened by "" and is the default.
Method %JSONExportToStream(ByRef export As %Stream.Object, %mappingName As %String = "") As %Status
{
	// Save current device
	Set io=$io
	
	Try {
		// Always output to %FileCharacterStream
		If $get(export)="" {
			Set export=##class(%FileCharacterStream).%New()
			// JSON is always UTF-8
			Set export.TranslateTable="UTF8"
			Set filestream=1
		} Else {
			Set filestream = ($zobjclass(export)="%Library.FileCharacterStream")
		}
		If filestream {
			Set stream=export
		} Else {
			Set stream=##class(%FileCharacterStream).%New()
			Set stream.TranslateTable="UTF8"
		}
		
		// Force stream's file to open
		Set sc=stream.Write("")
		
		// Export JSON to the stream
		If $$$ISOK(sc) {
			Set file=stream.Filename ; get filename and make current device
			Use file:(/NOXY)
			Set sc=..%JSONExportInternal()
			// Don't Close file to leave stream positioned
			Use io
		}
		
		// Need to ensdure that LineTerminator is correct for the platform
		If $$$ISOK(sc) Set stream.LineTerminator=$select($$$isUNIX:$char(10),1:$char(13,10))

		// If we created the stream and caller passed in stream, then copy it to the caller's stream
		If 'filestream,$$$ISOK(sc) {	
			Set sc=export.CopyFrom(stream)
		}

	} Catch ex {
		Set sc=ex.AsStatus()
	}

	Quit sc
}

/// Serialize a JSON enabled class as a JSON document and return it as a string.<br>
/// mappingName is the name of the mapping to use for the export.  The base mapping is represened by "" and is the default.
Method %JSONExportToString(ByRef %export As %String, %mappingName As %String = "") As %Status
{
	Try {
		Set sc=$$$OK
		
		// Do the export to current device now.
		Set %export=""
		Set sc=..%JSONExportToStringInternal()

	} Catch ex {
		If ex.Name="<MAXSTRING>" {
			Set sc=$$$ERROR($$$JSONMaxString,$$$mappingNameDisplay(%mappingName))
		} Else {
			Set sc=ex.AsStatus()
		}
	}

	Quit sc
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
Method %JSONExportInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).JSONExportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// %JSONExportToStringInternal is internal method used by %JSONExport
Method %JSONExportToStringInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
	Quit ##class(%pkg.isc.json.generator).JSONExportToStringInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

}

