Class %pkg.isc.json.saSchema Extends %pkg.isc.json.util.saSchemaClass
{

/// This is the namespace value used to identify this SA schema.
/// This corresponds to the XMLNamespace keyword of a Studio XData block.
Parameter XMLNAMESPACE As STRING = "http://www.intersystems.com/_pkg/isc/json/jsonmapping";

/// This is comma-separated list of the classes whose xml elements
/// can be used as the root level element of a document.
Parameter ROOTCLASSES As STRING = "%pkg.isc.json.mapping:Mapping";

}

