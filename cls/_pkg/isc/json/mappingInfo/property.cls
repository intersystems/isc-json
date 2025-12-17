/// Class representation of a single property of a JSON mapping that has been 
/// processed during compilation.
Class %pkg.isc.json.mappingInfo.property Extends %pkg.isc.json.mappingProperty
{

/// Normalized name of the property in the source class.
Property NormalizedName As %Dictionary.Identifier;

/// If the property is a literal, the specific JSON type of the literal.
Property LiteralType As %String;

/// ObjectScript representation of the member category that the property falls into.
/// Available options are enumerated in the GetMemberInfo() method of
/// <class>%pkg.isc.json.generator</class>.
Property MemberCategory As %String;

/// ObjectScript type of the property.
Property Type As %Dictionary.Classname;

Method %OnNew(name As %String, normalizedName As %String, include As %String, fieldName As %String, null As %Boolean, ignoreNull As %Boolean, reference As %String, required As %Boolean, literalType As %String, memberCategory As %String, type As %String, mapping As %String) As %Status [ Private, ServerOnly = 1 ]
{
	Set sc = $$$OK
    Try {
        Set ..Name = name
        Set ..NormalizedName = normalizedName
        Set ..Include = include
        Set ..FieldName = fieldName
        Set ..Null = null
        Set ..IgnoreNull = ignoreNull
        Set ..Reference = reference
        Set ..Required = required
        Set ..LiteralType = literalType
        Set ..MemberCategory = memberCategory
        Set ..Type = type
        Set ..Mapping = mapping
    } Catch (ex) {
        Set sc = ex.AsStatus()
    }
    Return sc
}

}

