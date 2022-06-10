Include (%occInclude, %pkg.isc.json.map)

IncludeGenerator (%occInclude, %pkg.isc.json.map)

/// Generator methods for %pkg.isc.json.adaptor.<br><br>
/// 
/// This class is used internally to %pkg.isc.json.adaptor. You should not make direct
/// use of it within your applications. There is no guarantee made about either
/// the behavior or future operation of this class.
Class %pkg.isc.json.generator [ Abstract, System = 2 ]
{

ClassMethod GenerateMapping(class As %String, Output mapping) As %Status [ Internal ]
{
	// Initialize map to empty
	Kill mapping

	// Get the inheritance order
	Do ..LeftSequenceClass(class,.classSeq)

	// Get %JSONIGNOREINVALIDFIELD parameter
	Set jsonignoreinvalidfield=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONIGNOREINVALIDFIELD",$$$cPARAMdefault)
	
	// Get %JSONMAPPING class parameter.
	Set jsondefaultmapping=$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONMAPPING",$$$cPARAMdefault)

	// Get default for %JSONNULL
	Set jsondefaultnull=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONNULL",$$$cPARAMdefault)

	// Get default for %JSONIGNORENULL
	Set jsondefaultignorenull=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONIGNORENULL",$$$cPARAMdefault)
 
	// Get default for %JSONREFERENCE
	Set jsondefaultreference=$zcvt($$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONREFERENCE",$$$cPARAMdefault),"U")
	If jsondefaultreference="" Set jsondefaultreference="OBJECT"
	If $case(jsondefaultreference,"OBJECT":0,"ID":0,"OID":0,"GUID":0,:1) {
		Quit $$$ERROR($$$JSONInvalidDefaultParameter,"parameter %JSONREFERENCE","class base")
	}
	
	// Get default for %JSONINCLUDEID
	Set jsonincludeid=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONINCLUDEID",$$$cPARAMdefault)
	
	// Get default for %JSONIDFIELD
	Set jsonidfield=$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONIDFIELD",$$$cPARAMdefault)

	// Get default for %JSONFIELDNAMEASCAMELCASE
	Set jsonfieldnameascamelcase=$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONFIELDNAMEASCAMELCASE",$$$cPARAMdefault)

	// Create map node for each property
	Set sc=$$$OK
	Set property=""
	For {
		Set property=$$$comMemberNext(class,$$$cCLASSproperty,property)
		If property="" Quit

		// Get %JSONINCLUDE property parameter
		Set jsoninclude=$zcvt($$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONINCLUDE"),"L")
		Set includeProperty=$case(jsoninclude,"":"","inout":1,"inputonly":1,"outputonly":1,"none":0,:-1)
		// Change in* to outputonly automatically for calculated and read-only properties.
		If $$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPreadonly) || $$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPcalculated) {
			If (jsoninclude = "inputonly") {
				Set includeProperty = -1
			} ElseIf (jsoninclude '= "none") {
				Set jsoninclude = "outputonly"
			}
		}
		If includeProperty=-1 {
			Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"parameter %JSONINCLUDE",property,"class base")
			Quit
		}
		
		// Get details of the property's type
		Do ..GetMemberInfo(class,property,.includeProperty,.type,.membercat,.objJSONEnabled)
		
		If includeProperty {
			// Default for %JSONINCLUDE is "inout"
			If jsoninclude="" Set jsoninclude="inout"
	
			// Do not support array of streams
			If membercat["STREAM",membercat["Array" {
				Set sc=$$$ERROR($$$JSONNoStreamArray,property,"class base")
				Quit
			}
			
			// For string types, set literaltype to string, base64 or hex.
			Set literaltype=""
			If membercat["CSTREAM" {
				Set literaltype="string"
			} ElseIf membercat["BSTREAM" {
				Set encoding=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"ENCODING")
				Set literaltype=$case($zcvt(encoding,"L"),"":"base64","base64":"base64","hex":"hex",:"")
				If literaltype="" {
					Set sc=$$$ERROR($$$XMLInvalidEncoding,encoding,property)
					Quit
				}
			} ElseIf membercat["LITERAL" {
				Set literaltype=$$$comMemberKeyGet(type,$$$cCLASSparameter,"JSONTYPE",$$$cPARAMdefault)
				If literaltype="" Set literaltype="string"
			
				// We need to differentiate between registered object strings and JSON strings.
				// For example between %String and %Timestamp.
				// A string is considered a registered object string if XSDTYPE, as well as JSONTYPE, is = "string".
				If literaltype="string",$$$comMemberKeyGet(type,$$$cCLASSparameter,"XSDTYPE",$$$cPARAMdefault)'="string" {
					Set literaltype="string/json"
				}
			}
			
			// Find actual class where property is defined.
			Set defClass=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPorigin)
			
			// Find if required
			Set required=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONREQUIRED")
			If (required = "") {
				Set required=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPrequired)
			}

			// Get JSON field name. If not specified, then it defaults to the property name.
			Set jsonfieldname=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONFIELDNAME")
			If jsonfieldname="" {
				If (jsonfieldnameascamelcase) {
					Set jsonfieldname=..GetPascalCaseAsCamelCase(property)
				} Else {
					Set jsonfieldname=property
				}
			}

			// Get %JSONNULL property parameter.  Default is %JSONNULL class parameter.
			Set jsonnull=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONNULL")
			Set jsonnull=$select(jsonnull="":jsondefaultnull,1:''jsonnull)

			// Get %JSONIGNORENULL property parameter.  Default is %JSONIGNORENULL class parameter.
			If literaltype="string" {
				Set jsonignorenull=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONIGNORENULL")
				Set jsonignorenull=$select(jsonignorenull="":jsondefaultignorenull,1:''jsonignorenull)
			} Else {
				Set jsonignorenull=0
			}

			// Get %JSONREFERENCE property parameter.  Default is %JSONREFERENCE class parameter.
			If membercat["OBJ" {
				Set jsonreference=$zcvt($$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONREFERENCE"),"U")
				If jsonreference="" Set jsonreference=jsondefaultreference
				Set jsonreferenceString = jsonreference
				Set jsonreference=$case(jsonreference,
										"OBJECT":$$$jsonrefobject,
										"ID":$$$jsonrefid,
										"OID":$$$jsonrefoid,
										"GUID":$$$jsonrefguid,
										:"")
				If jsonreference="" {
					Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"parameter %JSONREFERENCE",property,"class base")
					Quit
				}
				
				If (jsonreference = $$$jsonrefobject) && 'objJSONEnabled {
					Set sc=$$$ERROR($$$JSONReferencedTypeIsNotAdapted,property,class,type)
					Quit
				}
				
				If (membercat [ "SERIAL") && (jsonreference '= $$$jsonrefobject) {
					Set sc=$$$ERROR($$$JSONInvalidIDPROJECTION,property,class,jsonreferenceString)
					Quit
				}

				// Get JSON mapping for object references.
				Set jsonmapping=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONMAPPING")
				If jsonmapping="" Set jsonmapping=jsondefaultmapping

			} Else {
				Set jsonreference=""
			}

			// Set the node
			Set node=$lb(property,$$$QN(property),jsoninclude,jsonfieldname,jsonnull,jsonignorenull,jsonreference,required,literaltype,membercat,type,jsonmapping)
			Set item=$increment(tempmap)
			Set tempmap(
			    +classSeq-classSeq(defClass)+1,
			    +$$$defMemberKeyGet(defClass,$$$cCLASSproperty,property,$$$cPROPsequencenumber),
			    item)=node
		}
	}
	
	// Special case: ID
	If jsonincludeid && ($$$comClassKeyGet(class,$$$cCLASSclasstype) = $$$cCLASSCLASSTYPEPERSISTENT) {
		Set item = $increment(tempmap)
		Set offset = $Case($Data(defClass),0:0,:classSeq(defClass))
		Set tempmap(+classSeq-offset+1,0,item) = ..GetIDNode(jsonidfield,jsondefaultnull,jsondefaultignorenull)
	}
	
	// Copy nodes to map ordered by Sequence Number
	If $$$ISOK(sc) {
		Set mapping($c(1),0)=$lb(class,jsonignoreinvalidfield)

		Set mapping($c(1))=0
		Set cls=""
		For {
			Set cls=$order(tempmap(cls))
			If cls="" Quit
			Set prop=""
			For {
				Set prop=$order(tempmap(cls,prop))
				If prop="" Quit
				Set num=""
				For {
					Set num=$order(tempmap(cls,prop,num))
					If num="" Quit

					Set item=mapping($c(1))+1
					Set mapping($c(1))=item
					Set mapping($c(1),item)=tempmap(cls,prop,num)
				}
			}
		}
	}

	Quit sc
}

ClassMethod GetIDNode(pIDFieldName, pJSONDefaultNull, pJSONDefaultIgnoreNull) As %List [ Internal, Private ]
{
	Quit $lb($c(1),"%Id()","outputonly",pIDFieldName,pJSONDefaultNull,pJSONDefaultIgnoreNull,"",0,"string","LITERAL","%Library.String","")
}

/// Return member type information about a property
/// <pre>
/// includeProperty is set if passed in as "" which means not specified
/// member cat is defined by
///    <base cat> = "LITERAL" | "OBJPERSISTENT" | "OBJSERIAL" | "OBJREGISTERED" | "CSTREAM" | "BSTREAM"
///    If RELATIONSHIP MANY|CHILDREN, then ListCollectionOBJPERSISTENT
///    If List Of, then { ArrayCollection | ListCollection } <base cat>
///    If %ListOf... or %ArrayOf... { ArrayCollection | ListCollection } <ELEMENTTYPE cat>
///    Otherwis <base cat>
/// type is the type referenced by the property.
ClassMethod GetMemberInfo(class As %String, property As %String, ByRef includeProperty As %Boolean, Output type As %String, Output membercat As %String, Output refJSONEnabled As %Boolean) [ Internal ]
{
	Set refJSONEnabled = 0
	Set collection=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPcollection)
	Set relationship=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPrelationship)
	Set cardinality=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPcardinality)

	// Determine default property include if not already specified
	If includeProperty = "" {
		If $$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPmultidimensional) {
			Set includeProperty = 0
		} ElseIf $$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPprivate)||(property="%Concurrency") {
			Set includeProperty = 0
		} ElseIf relationship,cardinality'="children",cardinality'="many" {
			Set includeProperty = 0
		} Else {
			Set includeProperty = 1
		}
	}
	
	If includeProperty {
		Set type=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPtype)
		If type="" Set type="%Library.String"
		Set typecat=$$$getClassType(type)

		// Get member category for base type
		Set membercat=##class(%Compiler.XML.Generator.Adaptor).TypeToMembercat(type,typecat,.mixed)
	
		// If no membercat, then do not include property
		If membercat="" Set includeProperty=0
	}
		
	If includeProperty {
		// Modify membercat for collections
		If relationship {
			If (cardinality = "many") || (cardinality = "children") {
				// RELATIONSHIP MANY|CHILDREN = ListCollectionOBJPERSISTENT
				Set membercat = "ListCollection"_membercat
			}
		} Else {
			If collection="" {
				// Not a collection - LITERAL|OBJPERSISTENT|OBJSERIAL|OBJREGISTERED
				If (membercat'="LITERAL") {
					// Get list of super classes
					Kill typeSeq
					Do ##class(%Compiler.XML.Generator.Adaptor).SequenceClass(type,.typeSeq)
					// Check for collection
					If $data(typeSeq("%Library.ArrayOfDataTypes")) {
						Set membercat = "ArrayCollection"
					} ElseIf $data(typeSeq("%Library.ArrayOfObjects")) {
						Set membercat = "ArrayCollection"
					} ElseIf $data(typeSeq("%Library.ListOfDataTypes")) {
						Set membercat = "ListCollection"
					} ElseIf $data(typeSeq("%Library.ListOfObjects")) {
						Set membercat = "ListCollection"
					}
					If membercat["Collection" {
						Set type=$$$comMemberKeyGet(type,$$$cCLASSparameter,"ELEMENTTYPE",$$$cPARAMdefault)
						If membercat'["OBJ",type="" Set type="%Library.String"
						If type="" {
							Set sc=$$$ERROR($$$XMLNeedElementType,property)
							Quit
						}
						Set type=$$$NormalizeClassname(type)
						Set typecat=$$$getClassType(type)
						Set membercat=membercat_##class(%Compiler.XML.Generator.Adaptor).TypeToMembercat(type,typecat,.mixed)
					}
				}
			} Else {
				if collection = $$$cPROPCOLLECTIONLIST {
					// LIST COLLECTION and LITERAL     = ListCollectionLITERAL
					// LIST COLLECTION and otherwise   = ListCollectionOBJ
					Set membercat="ListCollection"_membercat
				} ElseIf collection = $$$cPROPCOLLECTIONARRAY {
					// ARRAY and LITERAL               = ArrayCollectionLITERAL
					// ARRAY and otherwise             = ArrayCollectionOBJ
					Set membercat="ArrayCollection"_membercat
				}
			}
		}
		
		// For obj member types, ensure JSON-enabled
		If membercat [ "OBJ" {
			Set refJSONEnabled = ..IsTypeJSONEnabled(type)
		}
	}
}

/// Returns true if a type is JSON-enabled (based on compiled class / class definition metadata)
ClassMethod IsTypeJSONEnabled(pType As %Dictionary.Classname, ByRef visited) As %Boolean
{
	Set type = $$$NormalizeClassname(pType)
	If $$$comMemberDefined(type,$$$cCLASSparameter,"%JSONENABLED") {
		Quit $$$comMemberKeyGet(type,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault)
	} Else {
		// Covers case where related class has not been fully compiled.
		Set supers = $ListFromString($$$defClassKeyGet(type,$$$cCLASSsuper))
		Set pointer = 0
		While $ListNext(supers,pointer,super) {
			If $Data(visited(super))#2 {
				Continue
			}
			Set visited(super) = ""
			If ..IsTypeJSONEnabled(super,.visited) {
				Return 1
			}
		}
		Quit 0
	}
}

/// Return all super classes in sequence of left to right with super class immediately following its child.
ClassMethod LeftSequenceClass(class As %String, ByRef seqArray)
{
	If '$data(seqArray(class)) Set seqArray(class)=$increment(seqArray)
	Set superList=$$$comClassKeyGet(class,$$$cCLASSsuper)
	Set len=$length(superList,",")
	For i=len:-1:1 {
		Set super=$piece(superList,",",i)
		If super'="" {
			Do ..LeftSequenceClass(super,.seqArray)
		}
	}
	Quit
}

/// Get the JSON adaptor configuration information  from class and property parameters.
ClassMethod GenerateMappingFromXdata(class As %String, ByRef mapping) As %Status [ Internal ]
{
	Set compiledclass=##class(%Dictionary.CompiledClass).%OpenId(class,,.sc)
	If $$$ISERR(sc) Quit sc

	Set count=compiledclass.XDatas.Count()

	For i=1:1:count {
		#dim xdata As %Dictionary.CompiledXData
		Set xdata=compiledclass.XDatas.GetAt(i)
		Set configName=xdata.Name
		If configName="" Continue
		If '(xdata.MimeType [ "xml") Continue
		If (xdata.Data.Size = 0) Continue
		
		#dim reader As %XML.Reader=##class(%XML.Reader).%New()
		Set reader.KeepWhitespace=0
		Set sc=reader.OpenStream(xdata.Data)
		If $$$ISERR(sc) Quit
	
		#dim document As %XML.Document=reader.Document
		#dim node As %XML.Node=document.GetDocumentElement()
	
		If node="" Continue
		If node.LocalName'="Mapping" Continue
		If node.Namespace'=##class(%pkg.isc.json.mapping).#NAMESPACE {
			Set sc=$$$ERROR($$$JSONUnexpectedNamespace,node.QName,$$$mappingNameDisplay(configName))
			Quit
		}
		
		Do reader.CorrelateRoot("%pkg.isc.json.mapping")
		
		If 'reader.Next(.obj,.sc) Quit
		
		If reader.Next(.dummy) {
			Set sc=$$$ERROR($$$JSONExtraMapping,$$$mappingNameDisplay(configName))
			Quit
		}
		
		Set sc=..GenerateMappingFromClass(class,configName,obj,.mapping)
		If $$$ISERR(sc) Quit
	}
	
	//This method will handle any <Call> tags present in the mapping.
	//It will add any properties contained in those mappings to the current one,
	//overwriting any duplicate property references with whatever the most recent is.
	do ..addCallsIntoMapping(.mapping)

	Quit sc
}

ClassMethod addCallsIntoMapping(ByRef mapping) [ Internal, Private ]
{
	//First, flag all mappings which contain a "calls" subtree as pending.
	Set mappingsPending = 0
	
	//For each xdata block mapping that's defined, there's a key in the "mapping" global
	//We're looping over all of those xdata blocks here
	Set mappingKey = ""
	For {
		Set mappingKey = $Order(mapping(mappingKey))
		If (mappingKey = "") {
			Quit
		}
		//mark any mappings which contain a "calls" subtree as pending
		//we'll have to handle these calls before we quit
		If $Data(mapping(mappingKey,"calls")) {
			Set mapping(mappingKey,"pending") = 1
			Set mappingsPending = 1
		}
	}
	

	// Next, we loop over all the mapping's calls and consolodate all the properties they
	// include into this mapping.  No properties will be duplicated; later references to
	// them will overwrite previous ones.
	
	//a check to see if we processed the calls of a mapping in this iteration of the loop
	//we start with a value of 1 to force the loop to start
	Set mappingsProcessed = 1
	While mappingsPending && mappingsProcessed {
		Set mappingsProcessed = 0
		Set mappingsPending = 0
		
		// Iterate over all the xdata block mappings again
		Set mappingKey = ""
		For {
			Set mappingKey = $Order(mapping(mappingKey))
			If (mappingKey = "") {
				Quit
			}
			
			//if this mapping hasn't been marked as pending, skip it; there are no calls to process
			If '$Get(mapping(mappingKey,"pending")) {
				Continue
			}
			
			// Are any calls this mapping has still pending?
			Set myMappingsPending = 0
			For callIndex=1:1:mapping(mappingKey,"calls") {
				Set refMapping = mapping(mappingKey,"calls",callIndex)
				If (refMapping '= "") {
					If $Get(mapping(refMapping,"pending")) {
						Set myMappingsPending = 1
						Quit
					}
				}
			}
			
			// If so, skip it; we have to process those pending calls first
			If myMappingsPending {
				Set mappingsPending = 1
				Continue
			}
			
			// At this point, we're dealing with a mapping which has only non pending calls.
			// Therefore, assemble the property data from this mapping's calls, as well as its own properties.
			
			// We'll use two variables to store this info (in order to preserve its order):
			
			//fieldList is an indexed, subscripted array
			//key: integer index
			//value: a $lb property definition
			//ex: fieldList(1) = $lb("Comment","Comment","inout","Comment",0,0,"","1","string","LITERAL","%Library.String","")
			Kill fieldList
			
			//fieldArray is a map that maps a jsonFieldName to where it's data is stored in fieldList
			//key:   jsonFieldName
			//value: index (where in fieldList to I go to find the $lb for the prop matching this jsonFieldName)
			Kill fieldArray
			
			//loop over the mapping's calls first
			For callIndex=1:1:mapping(mappingKey,"calls") {
				Set callName = mapping(mappingKey,"calls",callIndex)
				kill mappingArray
				merge mappingArray = mapping(callName)
				do ..getDataFromMappingArray(.mappingArray, .fieldList, .fieldArray)
			}
			
			//next, get the data listed in the mapping itself
			kill mappingArray
			merge mappingArray = mapping(mappingKey)
			do ..getDataFromMappingArray(.mappingArray, .fieldList, .fieldArray)
			
			//store some metadata before we kill and rebuild the mapping from our fieldList
			Set meta = mapping(mappingKey,0)
			Kill mapping(mappingKey)
			Set mapping(mappingKey,0) = meta
			
			//iterate over the $lb items in our field list (skipping the missing items where duplicates
			//were deleted) and add them to the mapping we just killed
			For fieldIndex = 1:1:$Get(fieldList) {
				If $Data(fieldList(fieldIndex),fieldData)#2 {
					Set mapping(mappingKey,$increment(mapping(mappingKey))) = fieldData
				}
			}
			
			//we processed a mapping during this iteration of the loop
			//if we have a circular dependency, we'll never get here
			Set mappingsProcessed = 1
		}
	}
	
	If mappingsPending {
		Quit $$$ERROR($$$GeneralError,"Mapping processing hit an infinite loop, you fool!")
	}
}

ClassMethod getDataFromMappingArray(ByRef mappingArray, ByRef fieldList, ByRef fieldArray) [ Internal, Private ]
{
	For callPropIndex=1:1:$Get(mappingArray) {
					
		//fieldData is the $lb that defines this property
		Set fieldData = mappingArray(callPropIndex)
					
		//this $lb, by convention, stores the jsonFieldName for the property in the 4th slot
		Set jsonFieldName = $ListGet(fieldData,4)
		Set include = $ListGet(fieldData,3)
		
		For type = "in","out" {
			//if fieldArray(jsonFieldName) exists, then we already have $lb data for the property
			//with this jsonFieldName. So, to avoid duplicates, we're going to kill the entry in
			//fieldList matching what we found in fieldArray(jsonFieldName).
			If $Data(fieldArray(jsonFieldName,type),listIndex)#2 {
				If ($Get(fieldList(listIndex)) = fieldData) {
					//if unmodified, leave the property in the original place.
					Continue
				}
				Kill fieldList(listIndex)
				Kill fieldArray(jsonFieldName,type)
			}
			If (include = "inout") {
				Set fieldList($increment(fieldList)) = fieldData
				Set fieldArray(jsonFieldName,"in") = fieldList
				Set fieldArray(jsonFieldName,"out") = fieldList
			} ElseIf (include [ type) {
				//Add this property's data to fieldList, and store the index at which we can find it
				//in fieldArray. This WILL leave gaps in field list, if there were duplicate jsonFieldNames.
				Set fieldList($increment(fieldList)) = fieldData
				Set fieldArray(jsonFieldName,type) = fieldList
			}
		}
	}
}

/// Generate mapping based on imported configuration info from Xdata block
ClassMethod GenerateMappingFromClass(class As %String, name As %String, obj As %pkg.isc.json.mapping, ByRef mapping) As %Status [ Internal ]
{
	kill mapping(name)

	// Get %JSONIGNOREINVALIDFIELD parameter
	Set jsonignoreinvalidfield=obj.IgnoreInvalidField
	
	// Get %JSONMAPPING class parameter.
	Set jsondefaultmapping=obj.Mapping

	// Get default for %JSONNULL
	Set jsondefaultnull=''obj.Null

	// Get default for %JSONIGNORENULL
	Set jsondefaultignorenull=''obj.IgnoreNull
 
	// Get default for %JSONREFERENCE
	Set jsondefaultreference=$zcvt(obj.Reference,"U")
	If jsondefaultreference="" Set jsondefaultreference="OBJECT"
	If $case(jsondefaultreference,"OBJECT":0,"ID":0,"OID":0,"GUID":0,:1) {
		Quit $$$ERROR($$$JSONInvalidDefaultParameter,"attribute reference",$$$mappingNameDisplay(name))
	}

	// Get default for %JSONFIELDNAMEASCAMELCASE
	Set jsonfieldnameascamelcase=''obj.FieldNameAsCamelCase

	// Save mappng parameterd for entire class
	Set mapping(name,0)=$lb(class,jsonignoreinvalidfield)
	
	// Special case: ID
	If ''obj.IncludeID && ($$$comClassKeyGet(class,$$$cCLASSclasstype) = $$$cCLASSCLASSTYPEPERSISTENT) {
		Set mapping(name,$increment(mapping(name))) = ..GetIDNode(obj.IDField,jsondefaultnull,jsondefaultignorenull)
	}

	// Create map node for each property
	#dim property As %pkg.isc.json.mappingProperty
	Set sc=$$$OK
	For i=1:1:obj.propertyList.Count() {
		Set property=obj.propertyList.GetAt(i)
		If property="" {
			Set sc=$$$ERROR($$$JSONNoPropertyName,$$$mappingNameDisplay(name))
			Quit
		}

		Set propertyName=property.Name
		If '$$$comMemberDefined(class,$$$cCLASSproperty,propertyName) {
			Set sc=$$$ERROR($$$JSONUnexpectedPropertyName,propertyName,$$$mappingNameDisplay(name))
			Quit
		}

		// Get %JSONINCLUDE property parameter
		Set jsoninclude=$zcvt(property.Include,"L")
		Set includeProperty=$case(jsoninclude,"":"","inout":1,"inputonly":1,"outputonly":1,"none":0,:-1)
		If includeProperty=-1 {
			Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"attribute Include",property,$$$mappingNameDisplay(name))
			Quit
		}
		
		// Get details of the property's type
		Do ..GetMemberInfo(class,propertyName,.includeProperty,.type,.membercat,.objJSONEnabled)

		// Get JSON field name. If not specified, then it defaults to the property name.
		Set jsonfieldname=property.FieldName
		If jsonfieldname="" {
			If (jsonfieldnameascamelcase) {
				Set jsonfieldname=..GetPascalCaseAsCamelCase(propertyName)
			} Else {
				Set jsonfieldname=propertyName
			}
		} 
		
		If includeProperty {
			// Default for %JSONINCLUDE is "inout"
			If jsoninclude="" Set jsoninclude="inout"
	
			// Do not support array of streams
			If membercat["STREAM",membercat["Array" {
				Set sc=$$$ERROR($$$JSONNoStreamArray,property,$$$mappingNameDisplay(name))
				Quit
			}
			
			// For string types, set literaltype to string, base64 or hex.
			Set literaltype=""
			If membercat["CSTREAM" {
				Set literaltype="string"
			} ElseIf membercat["BSTREAM" {
				Set encoding=$$$comMemberArrayGet(class,$$$cCLASSproperty,propertyName,$$$cPROPparameter,"ENCODING")
				Set literaltype=$case($zcvt(encoding,"L"),"":"base64","base64":"base64","hex":"hex",:"")
				If literaltype="" {
					Set sc=$$$ERROR($$$XMLInvalidEncoding,encoding,property)
					Quit
				}
			} ElseIf membercat["LITERAL" {
				Set literaltype=$$$comMemberKeyGet(type,$$$cCLASSparameter,"JSONTYPE",$$$cPARAMdefault)
				If literaltype="" Set literaltype="string"
			
				// We need to differentiate between registered object strings and JSON strings.
				// For example between %String and %Timestamp.
				// A string is considered a registered object string if XSDTYPE, as well as JSONTYPE, is = "string".
				If literaltype="string",$$$comMemberKeyGet(type,$$$cCLASSparameter,"XSDTYPE",$$$cPARAMdefault)'="string" {
					Set literaltype="string/json"
				}
			}
			
			// Find if required
			Set required=property.Required
			If (required = "") {
				Set required=$$$comMemberKeyGet(class,$$$cCLASSproperty,propertyName,$$$cPROPrequired)
			}

			// Get %JSONNULL property parameter.  Default is %JSONNULL class parameter.
			Set jsonnull=property.Null
			Set jsonnull=$select(jsonnull="":jsondefaultnull,1:''jsonnull)

			// Get %JSONIGNORENULL property parameter.  Default is %JSONIGNORENULL class parameter.
			If literaltype="string" {
				Set jsonignorenull=property.IgnoreNull
				Set jsonignorenull=$select(jsonignorenull="":jsondefaultignorenull,1:''jsonignorenull)
			} Else {
				Set jsonignorenull=0
			}

			// Get %JSONREFERENCE property parameter.  Default is %JSONREFERENCE class parameter.
			If membercat["OBJ" {
				Set jsonreference=$zcvt(property.Reference,"U")
				If jsonreference="" Set jsonreference=jsondefaultreference
				Set jsonreferenceString = jsonreference
				Set jsonreference=$case(jsonreference,
										"OBJECT":$$$jsonrefobject,
										"ID":$$$jsonrefid,
										"OID":$$$jsonrefoid,
										"GUID":$$$jsonrefguid,
										:"")
				If jsonreference="" {
					Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"attribute Reference",property)
					Quit
				}
				
				If (jsonreference = $$$jsonrefobject) && 'objJSONEnabled {
					Set sc=$$$ERROR($$$JSONReferencedTypeIsNotAdapted,propertyName,class,type)
					Quit
				}
				
				If (membercat [ "SERIAL") && (jsonreference '= $$$jsonrefobject) {
					Set sc=$$$ERROR($$$JSONInvalidIDPROJECTION,propertyName,class,jsonreferenceString)
					Quit
				}

				// Get JSON mapping for object references.
				Set jsonmapping=property.Mapping
				If jsonmapping="" Set jsonmapping=jsondefaultmapping

			} Else {
				Set jsonreference=""
			}

			// Set the node
			Set mapping(name,$increment(mapping(name)))=
			   $lb(propertyName,$$$QN(propertyName),jsoninclude,jsonfieldname,jsonnull,jsonignorenull,jsonreference,required,literaltype,membercat,type,jsonmapping)	
		} Else {
			// Stub for JSONINCLUDE=none
			Set mapping(name,$increment(mapping(name)))=
			   $lb(propertyName,$$$QN(propertyName),jsoninclude,jsonfieldname)
		}
	}
	
	// Build array of other mappings to call.
	For i=1:1:obj.callList.Count() {
		Set call = obj.callList.GetAt(i).Mapping
		Set mapping(name,"calls",$increment(mapping(name,"calls"))) = $Case(call,"":$lb(),:call)
	}

	Quit sc
}

/// %JSONGenerate creates thee metadata structure and generates the code for all methods.
ClassMethod %JSONGenerate(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
	Set %code=0
	If '$$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) Quit $$$OK

	Set abstract=$$$comClassKeyGet(%class,$$$cCLASSabstract)
	Set sc=$$$OK

	If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONDEFAULTMAPPING",$$$cPARAMdefault) {
		Set sc=..GenerateMapping(%class,.mapping)
		If $$$ISERR(sc) Quit sc
	}

	Set sc=..GenerateMappingFromXdata(%class,.mapping)
	If $$$ISERR(sc) Quit sc

	// Create the map from class properties
	If 'abstract {
		If $$$ISOK(sc) {
			Set sc=..GenerateAllImportInternal(%class,.mapping)
		}

		If $$$ISOK(sc) {
			Set sc=..GenerateAllExportInternal(%class,.mapping,1)
		}

		If $$$ISOK(sc) {
			Set sc=..GenerateAllExportInternal(%class,.mapping,0)
		}
	}

	Quit sc
}

/// Get the code for the %JSONImportInternal method to actually do the method generation
ClassMethod JSONImportInternal(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
	Set %code=0
	If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		Merge %code=$$$tEXTcode("%JSONImportInternal")
	}
	Quit $$$OK
}

/// Get the code for the %JSONExportInternal method to actually do the method generation
ClassMethod JSONExportInternal(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
	Set %code=0
	If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		Merge %code=$$$tEXTcode("%JSONExportInternal")
	}
	Quit $$$OK
}

/// Get the code for the %JSONExportToStringInternal method to actually do the method generation
ClassMethod JSONExportToStringInternal(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
	Set %code=0
	If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		Merge %code=$$$tEXTcode("%JSONExportToStringInternal")
	}
	Quit $$$OK
}

ClassMethod JSONNew(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status
{
	Set %code=0
	If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
		// Get default for %JSONINCLUDEID
		Set jsonincludeid=''$$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONINCLUDEID",$$$cPARAMdefault)
		// Get default for %JSONIDFIELD
		Set jsonidfield=$$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONIDFIELD",$$$cPARAMdefault)
		
		If (($$$comClassKeyGet(%class,$$$cCLASSclasstype) = "persistent") && jsonincludeid) {
			$$$GENERATE("  Set id = dynamicObject."_$$$QN(jsonidfield))
			$$$GENERATE("  If ##class("_%class_").%ExistsId(id) {")
			$$$GENERATE("    Quit ##class("_%class_").%OpenId(id)")
			$$$GENERATE("  } Else {")
			$$$GENERATE("    Quit ##class("_%class_").%New()")
			$$$GENERATE("  }")
		} Else {
			$$$GENERATE("  Quit ##class("_%class_").%New()")
		}
	}
	Quit $$$OK
}

/// Generate the code for the %JSONImportInternal method
ClassMethod GenerateAllImportInternal(class As %String, ByRef mapping As %String) As %Status [ Internal ]
{
	New %code
	Set %code=0
	Set sc=$$$OK
	
	Try {
		$$$GENERATE("  Set sc=$$$OK")
		Set needTestInvalidField=0
		Set needRequired=0
		
		// Process all mappings except base
		Set indent=""
		Set mappingName=$c(1)
		Set count=0
		For {
			Set mappingName=$order(mapping(mappingName))
			If mappingName="" Quit
			$$$GENERATE("  "_$select(count=0:"If",1:"} ElseIf")_" %mappingName="""_mappingName_""" {")
			Set count=count+1
			Set indent="  "
			Set sc=..GenerateImportInternal(class,indent,mappingName,.mapping,.needRequired,.needTestInvalidField)
			If $$$ISERR(sc) Quit
		}
		If $$$ISERR(sc) Quit

		// Add in base mapping.
		If $Data(mapping($c(1))) {
			If count>0 $$$GENERATE("  } Else {")
			Set sc=..GenerateImportInternal(class,indent,$c(1),.mapping,.needRequired,.needTestInvalidField)
			If $$$ISERR(sc) Quit
		}
		If count>0 $$$GENERATE("  }")
		
		// Generate code to check for invalid field
		If needTestInvalidField {
			$$$GENERATE("  If $get(testInvalidField) {")
			$$$GENERATE("    Set invalid=0,iterator=%JSONObject.%GetIterator()")
			$$$GENERATE("    While iterator.%GetNext(.key,.value) { If $data(proplist(key))=0 Set invalid=1 Quit  }")
			$$$GENERATE("    If invalid Quit $$$ERROR($$$JSONImportBadField,key,$$$mappingNameDisplay(%mappingName))")
			$$$GENERATE("  }")
		}

		$$$GENERATE("%JSONImportExit Quit sc")
		$$$GENERATE("%JSONImportError Quit $$$ERROR($$$JSONImportError,field,$$$mappingNameDisplay(%mappingName))")
		If needRequired $$$GENERATE("%JSONImportRequired Quit $$$ERROR($$$JSONImportRequired,field,$$$mappingNameDisplay(%mappingName))")

		// Save the code for this method
		Merge $$$tEXTcode("%JSONImportInternal")=%code

	} Catch ex {
		Set sc=ex.AsStatus()
	}

	Quit sc
}

/// Generate the code for the %JSONImportInternal method for the specified mappingName.
ClassMethod GenerateImportInternal(class As %String, indent As %String, mappingName As %String, ByRef mapping As %String, ByRef needRequired As %Boolean, ByRef needTestInvalidField As %Boolean) As %Status [ Internal ]
{
	Set sc=$$$OK
	Set ignoreInvalidField=$$$jsonignoreinvalidfield(mapping,mappingName)
	If 'ignoreInvalidField {
		Set needTestInvalidField=1
		$$$GENERATE(indent_"  Set testInvalidField=1")
	}

	For index=1:1:$$$jsonpropertycount(mapping,mappingName) {
		Set propertyMap=$$$jsongetprop(mapping,mappingName,index)
		Set fieldname=$replace($$$jsonfieldname(propertyMap),"""","""""")
		
		// Code to indicate property seen
		If 'ignoreInvalidField {
			$$$GENERATE(indent_"  Set proplist("""_fieldname_""")=""""")
		}
		
		// Skip processing for outputonly and none values of JSONINCLUDE.
		If $$$jsoninclude(propertyMap)'["in" Continue
		
		// Code to test if field is present
		$$$GENERATE(indent_"  Set field="""_fieldname_""" Set jsontype=%JSONObject.%GetTypeOf(field)")
		$$$GENERATE(indent_"  If jsontype'=""unassigned"" {")
		$$$GENERATE(indent_"    If jsontype=""null"" {")
		// null value does not satisfy field required.
		If $$$jsonrequired(propertyMap) {
			$$$GENERATE(indent_"      Goto %JSONImportRequired")
		} Else {
			$$$GENERATE(indent_"      Set .."_$$$jsonpropertyQN(propertyMap)_"=""""")
		}
		$$$GENERATE(indent_"    } Else {")

		// Generate code to import this property.
		Set membercat=$$$jsonmembercat(propertyMap)
		If membercat["Collection" {
			// Generate code to import collections
			If membercat["List" {
				// Generate code to import lists
				Do ..GenImportList(class,propertyMap,indent_"    ")
			} Else {
				// Generate code to import arrays
				Do ..GenImportArray(class,propertyMap,indent_"    ")
			}
			
		} Else {
			// Generate code to import this non-collection field
			Do ..GenImportField(class,propertyMap,indent_"    ",0)
		}

		// Handle checking for field required.
		If $$$jsonrequired(propertyMap) {
			$$$GENERATE(indent_"  } Else { Goto %JSONImportRequired }")
			Set needRequired=1
		} Else {
			$$$GENERATE(indent_"  }")
		}
	}
		
	Quit sc
}

/// Generate code for importing a JSON array as a List collection.
ClassMethod GenImportList(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
	// If present, then must be the expected JSON array type
	$$$GENERATE(indent_"  If jsontype'=""array"" Goto %JSONImportError")
	$$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
	// Get each element of the array.
	$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Clear()")
	$$$GENERATE(indent_"  For index=0:1:data.%Size()-1 {")
	// Get the field value
	$$$GENERATE(indent_"    Set jsontype=data.%GetTypeOf(index)")
	$$$GENERATE(indent_"    If jsontype=""null"" {")
	$$$GENERATE(indent_"      Do .."_$$$jsonpropertyQN(propertyMap)_".Insert("""")")
	$$$GENERATE(indent_"    } Else {")
	$$$GENERATE(indent_"      Set value=data.%Get(index)")
	// Generate code to import list element
	Do ..GenImportField(class,propertyMap,indent_"    ",$$$isCollectionList)
	$$$GENERATE(indent_"  }}")
}

/// Generate code for importing an array value from JSON object of the form {"key":value,...}
ClassMethod GenImportArray(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
	// If present, then must be the expected JSON object type
	$$$GENERATE(indent_"  If jsontype'=""object"" Goto %JSONImportError")
	$$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
	$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Clear()")
	$$$GENERATE(indent_"  Set iterator=data.%GetIterator()")
	$$$GENERATE(indent_"  While iterator.%GetNext(.index,.value) {")
	$$$GENERATE(indent_"    Set jsontype=data.%GetTypeOf(index)")
	$$$GENERATE(indent_"    If jsontype=""null"" {")
	$$$GENERATE(indent_"      Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt("""",index)")
	$$$GENERATE(indent_"    } Else {")
	Do ..GenImportField(class,propertyMap,indent_"    ",$$$isCollectionArray)
	$$$GENERATE(indent_"  }}")
}

/// Generate code for importing a single field value.
ClassMethod GenImportField(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) As %Boolean [ Internal ]
{
	// Generate code to import this property.
	Set membercat=$$$jsonmembercat(propertyMap)
	If membercat["OBJ" {
		Set reference=$$$jsonreference(propertyMap)
		If reference=$$$jsonrefid {
			// Generate code to import object ID.
			Do ..GenImportID(class,propertyMap,indent,isCollectionValue)
		} ElseIf reference=$$$jsonrefoid {
			// Generate code to import object OID.
			Do ..GenImportOID(class,propertyMap,indent,isCollectionValue)
		} ElseIf reference=$$$jsonrefguid {
			// Generate code to import object GUID.
			Do ..GenImportGUID(class,propertyMap,indent,isCollectionValue)
		} Else {
			// Generate code to import object references.
			Do ..GenImportObject(class,propertyMap,indent,isCollectionValue)
		}

	} ElseIf membercat["STREAM" {
		// Input stream
		If membercat="BSTREAM" {
			// Generate code to import binary stream
			Do ..GenImportBinaryStream(class,propertyMap,indent,isCollectionValue)
		} Else {
			// Generate code to import character stream
			Do ..GenImportCharacterStream(class,propertyMap,indent,isCollectionValue)
		}

	} Else {
		// Generate code to import literals
		Do ..GenImportLiteral(class,propertyMap,indent,isCollectionValue)
	}

	$$$GENERATE(indent_"}")
}

/// Generate code for importing an object ID and storing the object reference in variable named data.
ClassMethod GenImportID(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	// If present, then must be the expected JSON type
	$$$GENERATE(indent_"  If jsontype'=""string"",jsontype'=""number"" Goto %JSONImportError")
	// Get the field value
	If isCollectionValue {
		Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
		$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetObjectIdAt(value,"_indexarg_")")
	} Else {
		$$$GENERATE(indent_"  Do .."_$$$QN($$$jsonproperty(propertyMap)_"SetObjectId")_"(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_")")
	}
}

/// Generate code for importing an object OID and storing the object reference in variable named data.
ClassMethod GenImportOID(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	// If present, then must be the expected JSON type
	$$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
	// Get the field value
	Set var=$select(isCollectionValue:"value",1:"data")
	Set exp="$lb($piece("_var_","","",2,*),$piece("_var_","","",1))"
	If isCollectionValue {
		Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
		$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetObjectAt("_exp_","_indexarg_")")
	} Else {
		$$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
		$$$GENERATE(indent_"  Do .."_$$$QN($$$jsonproperty(propertyMap)_"SetObject")_"("_exp_")")
	}
}

/// Generate code for importing an object GUID and storing the object reference in variable named data.
ClassMethod GenImportGUID(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	// If present, then must be the expected JSON type
	$$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
	// Get the field value
	If isCollectionValue {
		Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
		$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetObjectAt(##class(%Library.GUID).%GUIDFind(value),"_indexarg_")")
	} Else {
		$$$GENERATE(indent_"  Do .."_$$$QN($$$jsonproperty(propertyMap)_"SetObject")_"(##class(%Library.GUID).%GUIDFind(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_"))")
	}
}

/// Generate code for importing a referenced object and storing in variable named data.
ClassMethod GenImportObject(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Set mappingName=$$$jsonmapping(propertyMap)
	// If present, then must be the expected JSON type
	$$$GENERATE(indent_"  If jsontype=""object"" {")
	// Get a new empty object
	$$$GENERATE(indent_"    Set saveJSON=%JSONObject")
	$$$GENERATE(indent_"    Set %JSONObject="_$select(isCollectionValue:"value",1:"%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))))
	$$$GENERATE(indent_"    Set newobj=##class("_$$$jsontype(propertyMap)_").%JSONNew(%JSONObject,$this)")
	// Get the field value
	If mappingName'="" {
		$$$GENERATE(indent_"    Set saveMapping=%mappingName,%mappingName="""_mappingName_"""")
	}
	// Call adapter for referenced object.
	$$$GENERATE(indent_"    Set sc=newobj.%JSONImportInternal()")
	$$$GENERATE(indent_"    Set %JSONObject=saveJSON")
	If mappingName'="" {
		$$$GENERATE(indent_"    Set %mappingName=saveMapping")
	}
	$$$GENERATE(indent_"    If $$$ISERR(sc) Goto %JSONImportExit")
	If isCollectionValue=$$$isCollectionList {
		// Generate code to save value in list
		$$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(newobj)")
	} ElseIf isCollectionValue=$$$isCollectionArray {
		// Generate code to save value in array
		$$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(newobj,index)")
	} Else {
		// Code to store the property value
		$$$GENERATE(indent_"    Set .."_$$$jsonpropertyQN(propertyMap)_"=newobj")
	}
	$$$GENERATE(indent_"  } ElseIf jsontype=""oref"" {")
	If isCollectionValue=$$$isCollectionList {
		// Generate code to save value in list
		$$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(value)")
	} ElseIf isCollectionValue=$$$isCollectionArray {
		// Generate code to save value in array
		$$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(value,index)")
	} Else {
		// Code to store the property value
		$$$GENERATE(indent_"    Set .."_$$$jsonpropertyQN(propertyMap)_"=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
	}
	$$$GENERATE(indent_"  } Else { Goto %JSONImportError }")
}

/// Generate code for getting the field value from a binary stream and storing in variable named data.
ClassMethod GenImportBinaryStream(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Set property=$$$jsonproperty(propertyMap)
	
	// If present, then must be the expected JSON type
	$$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
	// Get the field value
	If isCollectionValue {
		// Code for new stream to insert
		Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
		$$$GENERATE(indent_"  Set stream=..##class("_$$$jsontype(propertyMap)_").%New()")
		If $$$jsonliteraltype(propertyMap)["hex" {
			$$$GENERATE(indent_"  For i=1:2:$length(value) {")
			$$$GENERATE(indent_"    Set bin=bin_$char($zhex($extract(value,i,i+1)))")
			$$$GENERATE(indent_"  }")
			$$$GENERATE(indent_"  Set sc=stream.Write(value) If $$$ISERR(sc) Goto %JSONImportExit")
		} Else {
			$$$GENERATE(indent_"  Set sc=stream.Write($system.Encryption.Base64Decode(value)) If $$$ISERR(sc) Goto %JSONImportExit")
		}
		If isCollectionValue=$$$isCollectionList {
			// Generate code to save value in list
			$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(stream)")
		} Else {
			// Generate code to save value in array
			$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(stream,index)")
		}
	} Else {
		// Code to use property stream
		$$$GENERATE(indent_"  Set stream=.."_$$$jsonpropertyQN(propertyMap)_" Do stream.Rewind()")
		If $$$jsonliteraltype(propertyMap)["hex" {
			$$$GENERATE(indent_"  Set value=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_",bin=""""")
			$$$GENERATE(indent_"  For i=1:2:$length(value) {")
			$$$GENERATE(indent_"    Set bin=bin_$char($zhex($extract(value,i,i+1)))")
			$$$GENERATE(indent_"  }")
			$$$GENERATE(indent_"  Set sc=stream.Write(bin) If $$$ISERR(sc) Goto %JSONImportExit")
		} Else {
			$$$GENERATE(indent_"  Set sc=stream.Write($system.Encryption.Base64Decode(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_")) If $$$ISERR(sc) Goto %JSONImportExit")
		}
	}
}

/// Generate code for getting the field value from a character stream and storing in variable named data.
ClassMethod GenImportCharacterStream(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Set property=$$$jsonproperty(propertyMap)
	
	// If present, then must be the expected JSON type
	$$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
	// Get the field value
	If isCollectionValue {
		// Code for new stream to insert
		Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
		$$$GENERATE(indent_"  Set stream=..##class("_$$$jsontype(propertyMap)_").%New()")
		$$$GENERATE(indent_"  Set sc=stream.Write(value) If $$$ISERR(sc) Goto %JSONImportExit")
		If isCollectionValue=$$$isCollectionList {
			// Generate code to save value in list
			$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(stream)")
		} Else {
			// Generate code to save value in array
			$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(stream,index)")
		}
	} Else {
		// Code to use property stream
		$$$GENERATE(indent_"  Set stream=.."_$$$jsonpropertyQN(propertyMap)_" Do stream.Rewind()")
		$$$GENERATE(indent_"  Set sc=stream.Write(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_") If $$$ISERR(sc) Goto %JSONImportExit")
	}
}

/// Generate code for getting the field value and storing in variable named data.
ClassMethod GenImportLiteral(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Set property=$$$jsonproperty(propertyMap)
	Set type=$$$jsontype(propertyMap)
	Set literaltype=$$$jsonliteraltype(propertyMap)
	
	// If present, then must be the expected JSON type
	If literaltype="double" {
		$$$GENERATE(indent_"  If jsontype'=""number"",jsontype'=""string"" Goto %JSONImportError")
	} Else {
		$$$GENERATE(indent_"  If jsontype'="""_$piece(literaltype,"/",1)_""" Goto %JSONImportError")
	}
	// Get the field value
	If isCollectionValue {
		Set var="value"
	} Else {
		Set var="data"
	}
	
	Set useProperty='isCollectionValue
	If literaltype'="boolean" { // boolean JSON values need nop additional processing.
		// Get information about data type class
		Do ##class(%Compiler.XML.Generator.Adaptor).getPropertyParameters(class,property,.parms)
		Set haveJSONToLogical=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"JSONToLogical",.parms,var,.codeJSONToLogical)
		// Try to use XSDToLogical if JSONToLogical is not specified.  
		// The point is to avoid extra property mnethods being geenrated.
		If 'haveJSONToLogical {
			Set haveJSONToLogical=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"XSDToLogical",.parms,var,.codeJSONToLogical)
		}
		Set haveIsValid=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"IsValid",.parms,var,.codeIsValid)
		
		// Call datatype methods
		Set line=""
		If haveJSONToLogical {
			Set line=line_" Set "_var_"="_codeJSONToLogical_" Goto:"_var_"="""" %JSONImportError"
		}
		If haveIsValid {
			Set line=line_" If $$$ISERR("_codeIsValid_") Goto %JSONImportError"
		}
		If line'="" {
			If useProperty {
				Set useProperty=0
				$$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
			}
			$$$GENERATE(indent_" "_line)
		}
		// Handle the ignorenull case
		If literaltype="string",'$$$jsonignorenull(propertyMap) {
			If useProperty {
				Set useProperty=0
				$$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
			}
			$$$GENERATE(indent_"  If "_var_"="""" Set "_var_"=$c(0)")
		}
	}
	If isCollectionValue=$$$isCollectionList {
		// Generate code to save value in list
		$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Insert("_var_")")
	} ElseIf isCollectionValue=$$$isCollectionArray {
		// Generate code to save value in array
		$$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt("_var_",index)")
	} Else {
		// Code to store the property value
		If useProperty Set var="%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))
		$$$GENERATE(indent_"  Set .."_$$$jsonpropertyQN(propertyMap)_"="_var)
	}
}

/// Generate the code for the %JSONExportInternal method
ClassMethod GenerateAllExportInternal(class As %String, ByRef mapping As %String, useWrite As %Boolean) As %Status [ Internal ]
{
	New %code,%outputCode,%exitCode,%objectCode
	Set %code=0
	Set sc=$$$OK
	
	Try {
		// Setup the output code for write or string concatenation.
		If useWrite {
			Set %outputCode="Write "
			Set %exitCode="%JSONExportExit"
			Set %objectCode="%JSONExportInternal"
		} Else {
			Set %outputCode="Set %export=%export_"
			Set %exitCode="%JSONExportExitToString"
			Set %objectCode="%JSONExportToStringInternal"
		}
		
		// Begin output of code
		$$$GENERATE("  Set sc=$$$OK")
		$$$GENERATE("  "_%outputCode_"""{"" Set sep=""""")
		
		// Process all mappings except base
		Set indent=""
		Set mappingName=$c(1)
		Set count=0
		For {
			Set mappingName=$order(mapping(mappingName))
			If mappingName="" Quit
			$$$GENERATE("  "_$select(count=0:"If",1:"} ElseIf")_" %mappingName="""_mappingName_""" {")
			Set count=count+1
			Set indent="  "
			Set sc=..GenerateExportInternal(class,indent,mappingName,.mapping)
			If $$$ISERR(sc) Quit
		}
		If $$$ISERR(sc) Quit

		// Add in base mapping.
		If count>0 $$$GENERATE("  } Else {")
		Set sc=..GenerateExportInternal(class,indent,$c(1),.mapping)
		If $$$ISERR(sc) Quit
		If count>0 $$$GENERATE("  }")
		
    	$$$GENERATE("  "_%outputCode_"""}""")
		$$$GENERATE(%exitCode_" Quit sc")

		// Save the code for this method
		Merge $$$tEXTcode("%JSONExport"_$select(useWrite:"",1:"ToString")_"Internal")=%code

	} Catch ex {
		Set sc=ex.AsStatus()
	}

	Quit sc
}

/// Generate the code for the specified mapping of %JSONExportInternal method
ClassMethod GenerateExportInternal(class As %String, indent As %String, mappingName As %String, ByRef mapping As %String) As %Status [ Internal ]
{
	Set sc=$$$OK
	
	// Loop over all properties
	For index=1:1:$$$jsonpropertycount(mapping,mappingName) {
		Set propertyMap=$$$jsongetprop(mapping,mappingName,index)
		Set fieldname=$$$jsonfieldname(propertyMap)
		
		// Skip procssing for inputonly and none values of JSONINCLUDE.
		If $$$jsoninclude(propertyMap)'["out" Continue
		
		// Generate code to import this property.
		Set membercat=$$$jsonmembercat(propertyMap)
		If membercat["Collection" {
			// Generate code to import collections
			$$$GENERATE("    Set aval=.."_$$$jsonpropertyQN(propertyMap))
			If membercat["List" {
				// Generate code to import lists
				Do ..GenExportList(class,propertyMap,indent)
			} Else {
				// Generate code to import arrays
				Do ..GenExportArray(class,propertyMap,indent)
			}
			
		} Else {
			// Generate code to import this non-collection field
			$$$GENERATE(indent_"  Set value=.."_$$$jsonpropertyQN(propertyMap))
			Do ..GenExportField(class,propertyMap,fieldname,indent,0)
		}
	}
		
	Quit sc
}

/// Generate code for exporting a List collection as a JSON array.
ClassMethod GenExportList(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
	Set jsonreference=$$$jsonreference(propertyMap) 
	If jsonreference=$$$jsonrefoid {
		Set nextFunction="GetObjectNext"
	} ElseIf jsonreference=$$$jsonrefguid {
		Set nextFunction="GetNext"
	} ElseIf jsonreference=$$$jsonrefid {
		Set nextFunction="GetObjectIdNext"
	} Else {
		Set nextFunction="GetNext"
	}
	$$$GENERATE(indent_"  If aval.Count()>0 {")
	Do ..GenWriteField($$$jsonfieldname(propertyMap),indent_"  ","")
	$$$GENERATE(indent_"    Set sep=""[""")
	$$$GENERATE(indent_"    Set k="""" For {")
	$$$GENERATE(indent_"      Set value=aval."_nextFunction_"(.k) If k="""" Quit")
	Do ..GenExportField(class,propertyMap,"","      ",$$$isCollectionList)
	$$$GENERATE(indent_"    }")
   	$$$GENERATE(indent_"    "_%outputCode_"""]""")
   	$$$GENERATE(indent_"  }")
}

/// Generate code for exporting an array collection value from JSON object of the form {"key":value,...}
ClassMethod GenExportArray(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
	Set jsonreference=$$$jsonreference(propertyMap)
	If jsonreference=$$$jsonrefoid {
		Set nextFunction="GetObjectNext"
	} ElseIf jsonreference=$$$jsonrefguid {
		Set nextFunction="GetNext"
	} ElseIf jsonreference=$$$jsonrefid {
		Set nextFunction="GetObjectIdNext"
	} Else {
		Set nextFunction="GetNext"
	}
	$$$GENERATE(indent_"  If aval.Count()>0 {")
	Do ..GenWriteField($$$jsonfieldname(propertyMap),indent_"  ","")
	$$$GENERATE(indent_"    Set sep=""{""")
	$$$GENERATE(indent_"    Set aval=.."_$$$jsonpropertyQN(propertyMap)_",k=""""")
	$$$GENERATE(indent_"    For {")
	$$$GENERATE(indent_"      Set value=aval."_nextFunction_"(.k) If k="""" Quit")
	Do ..GenExportField(class,propertyMap,$c(1)_"k",indent_"    ",$$$isCollectionArray)
	$$$GENERATE(indent_"    }")
   	$$$GENERATE(indent_"    "_%outputCode_"""}""")
   	$$$GENERATE(indent_"  }")
}

/// Generate code for exporting a single field value.
ClassMethod GenExportField(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) As %Integer [ Internal ]
{
	Set needClosingBrace=1
	// Generate code to import this property.
	Set membercat=$$$jsonmembercat(propertyMap)
	If membercat["OBJ" {
		// Handle no object specified.
		Set serialTest=$select(membercat["SERIAL":"&&'value.%IsNull()",1:"")
		$$$GENERATE(indent_"  If value'="""""_serialTest_" {")
		Set indent=indent_"  "
		// Output JSON for the object reference
		Set reference=$$$jsonreference(propertyMap)
		If reference=$$$jsonrefid {
			// Generate code to export object ID.
			Do ..GenExportID(class,propertyMap,fieldName,indent,isCollectionValue)
		} ElseIf reference=$$$jsonrefoid {
			// Generate code to export object OID.
			Do ..GenExportOID(class,propertyMap,fieldName,indent,isCollectionValue)
		} ElseIf reference=$$$jsonrefguid {
			// Generate code to export object GUID.
			Do ..GenExportGUID(class,propertyMap,fieldName,indent,isCollectionValue)
		} Else {
			// Generate code to export object references.
			Do ..GenExportObject(class,propertyMap,fieldName,indent,isCollectionValue)
		}

	} ElseIf membercat["STREAM" {
		// Handle no stream specified.
		If $$$jsonliteraltype(propertyMap)="string",$$$jsonignorenull(propertyMap) {
			Set needClosingBrace=0
		} Else {
			$$$GENERATE(indent_"  If (value'="""")&&'value.IsNull() {")
			Set indent=indent_"  "
		}
		// Output stream
		If membercat="BSTREAM" {
			// Generate code to export binary stream
			Do ..GenExportBinaryStream(class,propertyMap,fieldName,indent,isCollectionValue)
		} Else {
			// Generate code to export character stream
			Do ..GenExportCharacterStream(class,propertyMap,fieldName,indent,isCollectionValue)
		}

	} Else {
		// Handle no value specified.
		If $$$jsonliteraltype(propertyMap)="string",$$$jsonignorenull(propertyMap) {
			Set needClosingBrace=0
		} Else {
			$$$GENERATE(indent_"  If value'="""" {")
			Set indent=indent_"  "
		}
		// Generate code to export literals
		Do ..GenExportLiteral(class,propertyMap,fieldName,indent,isCollectionValue)
	}
	
   	If needClosingBrace {
		If isCollectionValue || ($$$jsonnull(propertyMap) && '$$$jsonignorenull(propertyMap)) {
			$$$GENERATE(indent_"} Else {")
			Do ..GenWriteField(fieldName,indent,"""null""")
	   		$$$GENERATE(indent_"}")
		   	$$$GENERATE(indent_"Set $extract(sep,1)="",""")
		} Else {
		   	$$$GENERATE(indent_"  Set $extract(sep,1)="",""")
	   		$$$GENERATE(indent_"}")
		}
	} Else {
	   	$$$GENERATE(indent_"  Set $extract(sep,1)="",""")
	}
}

/// Generate code for exporting an object ID as JSON.
ClassMethod GenExportID(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	// Write the field value
	If isCollectionValue {
		// GetObjectNextId already returned id
		Do ..GenWriteField(fieldName,indent,"""""""""_$zcvt(value,""O"",""JSON"")_""""""""")
	} Else {
		Do ..GenWriteField(fieldName,indent,"""""""""_$zcvt(value.%Id(),""O"",""JSON"")_""""""""")
	}
}

/// Generate code for exporting an object OID as JSON.
ClassMethod GenExportOID(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	// Write the field value
	If isCollectionValue {
		// GetObjectNextId already returned oid
		Do ..GenWriteField(fieldName,indent,"""""""""_$select($listget(value,2)="""":$listget(aval.GetAt(k).%Oid(),2),1:$listget(value,2))_"",""_$listget(value)_""""""""")
	} Else {
		Do ..GenWriteField(fieldName,indent,"""""""""_$listget(value.%Oid(),2)_"",""_$listget(value.%Oid())_""""""""")
	}
}

/// Generate code for exporting an object GUID as JSON.
ClassMethod GenExportGUID(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Do ..GenWriteField(fieldName,indent,"""""""""_value.%GUID(value.%Oid())_""""""""")
}

/// Generate code for exporting a referenced object as JSON.
ClassMethod GenExportObject(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Set mappingName=$$$jsonmapping(propertyMap)
	If mappingName'="" {
		$$$GENERATE(indent_"  Set saveMapping=%mappingName,%mappingName="""_mappingName_"""")
	}
	// Write the field value
	Do ..GenWriteField(fieldName,indent,"")
	$$$GENERATE(indent_"  Set sc=value."_%objectCode_"() If $$$ISERR(sc) Goto "_%exitCode)
	If mappingName'="" {
		$$$GENERATE(indent_"  Set %mappingName=saveMapping")
	}
}

/// Generate code for exporting a binary stream as JSON.
ClassMethod GenExportBinaryStream(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Do ..GenWriteField(fieldName,indent,"")
	If $$$jsonliteraltype(propertyMap)["hex" {
		$$$GENERATE(indent_"  "_%outputCode_""""""""" Do value.Rewind() If value.Size>0 { While 'value.AtEnd { ")
		$$$GENERATE(indent_"    Set first=value.Read(.len,.sc) If $$$ISERR(sc) Goto "_%exitCode)
    	$$$GENERATE(indent_"    For k=1:1:$length(first) {"_%outputCode_"$select($ascii(first,k)<16:""0"",1:"""")_$zhex($ascii(first,k)) }")
		$$$GENERATE(indent_"  }} "_%outputCode_"""""""""")
	} Else {
		$$$GENERATE(indent_"  "_%outputCode_""""""""" Do value.Rewind() If value.Size>0 { While 'value.AtEnd { "_%outputCode_"$system.Encryption.Base64Encode(value.Read(,.sc),1) If $$$ISERR(sc) Goto "_%exitCode_" }} "_%outputCode_"""""""""")
	}
}

/// Generate code for exporting a character stream as JSON.
ClassMethod GenExportCharacterStream(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Do ..GenWriteField(fieldName,indent,"")
	$$$GENERATE(indent_"  "_%outputCode_""""""""" Do value.Rewind() If value.Size>0 { While 'value.AtEnd { "_%outputCode_"$zcvt(value.Read(,.sc),""O"",""JSON"") If $$$ISERR(sc) Goto "_%exitCode_" }} "_%outputCode_"""""""""")
}

/// Generate code for exporting a literal value as JSON.
ClassMethod GenExportLiteral(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
	Set property=$$$jsonproperty(propertyMap)
	Set type=$$$jsontype(propertyMap)
	
	// Get information about data type class
	Do ##class(%Compiler.XML.Generator.Adaptor).getPropertyParameters(class,property,.parms)
	Set haveLogicalToJSON=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"LogicalToJSON",.parms,"value",.codeLogicalToJSON)
	// Try to use LogicalToXSD if LogicalToJSON is not specified.  
	// The point is to avoid extra property mnethods being geenrated.
	If 'haveLogicalToJSON {
		Set haveLogicalToJSON=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"LogicalToXSD",.parms,"value",.codeLogicalToJSON)
	}
	If 'haveLogicalToJSON Set codeLogicalToJSON="value"
	Set literaltype=$$$jsonliteraltype(propertyMap)
	If $piece(literaltype,"/",1)="string" {
		If literaltype="string" {
			Set codeLogicalToJSON="$select("_$select($$$jsonignorenull(propertyMap):"(value="""""""")||",1:"")_"(value=$c(0)):"""",1:$zcvt("_codeLogicalToJSON_",""O"",""JSON""))"
		}
		Set codeLogicalToJSON="""""""""_"_codeLogicalToJSON_"_"""""""""
	} ElseIf literaltype="boolean" {
		Set codeLogicalToJSON="$select(value:""true"",1:""false"")"
	}
	Do ..GenWriteField(fieldName,indent,codeLogicalToJSON)
}

/// Generate code to write out the field name and value
ClassMethod GenWriteField(fieldName As %String, indent As %String, valueText As %String)
{
	If fieldName'="" {
		// If first character of fieldName is $c(1), then the name is actually a variable name that contains field name
		If $extract(fieldName,1)=$c(1) {
			Set field="""_"_$replace($zcvt($extract(fieldName,2,*),"O","JSON"),"""","""""")_"_"""
		} Else {
			set field=$replace($zcvt(fieldName,"O","JSON"),"""","""""")
		}
		If valueText'="" {
			$$$GENERATE(indent_"  "_%outputCode_"sep_"_""""""""_field_""""""_$select($extract(valueText,1)="""":":"_$extract(valueText,2,*),1:":""_"_valueText))
		} Else {
			$$$GENERATE(indent_"  "_%outputCode_"sep_"_""""""""_field_""""":""")
		}
	} Else {
		$$$GENERATE(indent_"  "_%outputCode_"sep"_$select(valueText="":"",1:"_")_valueText)
	}
}

ClassMethod GetPascalCaseAsCamelCase(pStr As %String) As %String [ Internal ]
{
	If (pStr = $ZConvert(pStr,"U")) {
		// Exception where full string is upper case
		Return $ZConvert(pStr,"L")
	}
	Set result = ""
	Set isInitialCheck = 0
	Set firstChar = $Extract(pStr,1)
	Set secondChar = $Extract(pStr,2)
	Set result = $ZConvert(firstChar,"L") // Always convert at least first char to lower case
	If (secondChar = $ZConvert(secondChar,"U")) {
		// If second character is upper-case, keep iterating until a lower case
		// value is found
		For i=2:1:$Length(pStr) {
			Set c = $Extract(pStr,i)
			If ($ZConvert(c,"L") = c) {
				Quit
			}
		}
		Set lowerCasePart = $Extract(pStr,2,i-2) // Go 2 characters back as the last upper case letter is part of a new word
		Set remaining = $Extract(pStr,i-1,*)
		Set result = result _ $ZConvert(lowerCasePart,"L") _ remaining
	} Else {
		Set result = result _ $Extract(pStr,2,*)
	}
	Return result
}

}

