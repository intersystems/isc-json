/// Class representation of a single JSON mapping that has been processed during 
/// compilation for either the default JSON mapping or one created by an XData block
/// represented by <class>%pkg.isc.json.mapping</class>.
Class %pkg.isc.json.mappingInfo Extends %RegisteredObject
{

/// Name of class for which mapping is returned.
Property Classname As %Dictionary.Classname;

/// Name of mapping. Will be empty for default mapping.
Property Mapping As %String;

/// Whether invalid fields are ignored.
/// Default matches default value of %JSONIGNOREINVALIDFIELD in <class>%pkg.isc.json.adaptor</class>.
Property IgnoreInvalidField As %Boolean [ InitialExpression = 0 ];

/// List of properties present in the mapping.
Property Properties As list Of %pkg.isc.json.mappingInfo.property;

/// Whether to allow the ID to be included (output-only) in representations of the object
Property IncludeID As %Boolean;

/// The field name to use for the ID in representations of the object, if enabled by <parameter>%JSONINCLUDEID</parameter>
Property IDField As %String;

}

