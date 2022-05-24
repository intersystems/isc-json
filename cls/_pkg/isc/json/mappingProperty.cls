/// %pkg.isc.json.mappingProperty is the internal class which represents the Property elements in the
/// XData block which defines a JSON Adaptor mapping.
Class %pkg.isc.json.mappingProperty Extends (%RegisteredObject, %XML.Adaptor) [ System = 2 ]
{

Parameter NAMESPACE = "http://www.intersystems.com/_pkg/isc/json/jsonmapping";

Parameter XMLNAME = "Property";

Parameter XMLFORMAT = "literal";

Parameter XMLIGNOREINVALIDATTRIBUTE = 0;

/// Property name.
Property Name As %String(XMLPROJECTION = "attribute") [ Required ];

/// See %JSONFIELDNAME property parameter in %pkg.isc.json.propertyParameters
Property FieldName As %String(XMLPROJECTION = "attribute");

/// See %JSONINCLUDE property parameter in %pkg.isc.json.propertyParameters
Property Include As %String(XMLPROJECTION = "attribute");

/// See %JSONNULL property parameter in %pkg.isc.json.propertyParameters
Property Null As %Boolean(XMLPROJECTION = "attribute");

/// See %JSONIGNORENULL property parameter in %pkg.isc.json.propertyParameters
Property IgnoreNull As %Boolean(XMLPROJECTION = "attribute");

/// See %JSONMAPPING property parameter in %pkg.isc.json.propertyParameters
Property Mapping As %String(XMLPROJECTION = "attribute");

/// See %JSONREFERENCE property parameter in %pkg.isc.json.propertyParameters
Property Reference As %String(XMLPROJECTION = "attribute");

/// See %JSONREQUIRED property parameter in %pkg.isc.json.propertyParameters
Property Required As %Boolean(XMLPROJECTION = "attribute");

}

