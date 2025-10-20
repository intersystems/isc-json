/// %pkg.isc.json.mapping is the internal class which represents the contents of the
/// XData block which defines a JSON Adaptor mapping.
Class %pkg.isc.json.mapping Extends (%RegisteredObject, %XML.Adaptor) [ System = 2 ]
{

Parameter NAMESPACE = "http://www.intersystems.com/_pkg/isc/json/jsonmapping";

Parameter XMLFORMAT = "literal";

Parameter XMLIGNOREINVALIDATTRIBUTE = 0;

/// See %JSONIGNOREINVALIDFIELD class parameter in %pkg.isc.json.adaptor
Property IgnoreInvalidField As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONNULL class parameter in %pkg.isc.json.adaptor
Property Null As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONIGNORENULL class parameter in %pkg.isc.json.adaptor
Property IgnoreNull As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONMAPPING class parameter in %pkg.isc.json.adaptor
Property Mapping As %String(XMLPROJECTION = "attribute");

/// See %JSONREFERENCE class parameter in %pkg.isc.json.adaptor
Property Reference As %String(XMLPROJECTION = "attribute") [ InitialExpression = "OBJECT" ];

/// See %JSONINCLUDEID class parameter in %pkg.isc.json.adaptor
Property IncludeID As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONIDFIELD class parameter in %pkg.isc.json.adaptor
Property IDField As %String(XMLPROJECTION = "attribute") [ InitialExpression = "_id" ];

/// See %JSONFIELDNAMEASCAMELCASE class parameter in %pkg.isc.json.adaptor
Property FieldNameAsCamelCase As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// The list of property definitions
Property propertyList As list Of %pkg.isc.json.mappingProperty(XMLNAME = "Property", XMLPROJECTION = "element");

/// The list of other mappings to call
Property callList As list Of %pkg.isc.json.mappingCall(XMLNAME = "Call", XMLPROJECTION = "element");

}

