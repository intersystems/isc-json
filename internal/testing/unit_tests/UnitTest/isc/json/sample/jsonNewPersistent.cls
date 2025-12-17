/// For testing %JSONNew code generation
Class UnitTest.isc.json.sample.jsonNewPersistent Extends (%Persistent, UnitTest.isc.json.sample.jsonNew)
{

Index FooBarIdx On (Foo, Bar) [ IdKey ];

Index UniqueBazIdx On Baz [ Unique ];

Index UniqueCombinedIdx On (Combined1, Combined2) [ Unique ];

Index AnotherIdx On Another;

XData IdIncluded [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IncludeID="true" IDField="myID">
<Call />
</Mapping>
}

XData UniqueIndexPropsAbsent [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<Call />
<Property Name="Bar" Include="None" />
<Property Name="Baz" Include="None" />
<Property Name="Combined2" Include="None" />
</Mapping>
}

/// Get an instance of an JSON enabled class.<br><br>
/// 
/// You may override this method to do custom processing (such as initializing
/// the object instance) before returning an instance of this class.
/// However, this method should not be called directly from user code.<br>
/// Arguments:<br>
///     dynamicObject is the dynamic object with thee values to be assigned to the new object.<br>
///     containerOref is the containing object instance when called from JSONImport.
/// 	mappingName is the name of the mapping to use for the export.  The base mapping is represened by "" and is the default.
ClassMethod %JSONNew(dynamicObject As %DynamicObject, containerOref As %RegisteredObject = "", %mappingName As %String = "") As %RegisteredObject
{
	Set obj = ..%JSONNewDefault(dynamicObject, containerOref, %mappingName)
    // Force returning a new object as a clone of any existing found
    If (dynamicObject.%Get("_cloneExisting", 0)) {
        Return obj.%ConstructClone()
    }
    Return obj
}

Storage Default
{
<Data name="jsonNewPersistentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Baz</Value>
</Value>
<Value name="3">
<Value>Another</Value>
</Value>
<Value name="4">
<Value>Combined1</Value>
</Value>
<Value name="5">
<Value>Combined2</Value>
</Value>
</Data>
<DataLocation>^UnitTest.i7E30.jsonNewPers2F84D</DataLocation>
<DefaultData>jsonNewPersistentDefaultData</DefaultData>
<IdLocation>^UnitTest.i7E30.jsonNewPers2F84D</IdLocation>
<IndexLocation>^UnitTest.i7E30.jsonNewPers2F84I</IndexLocation>
<StreamLocation>^UnitTest.i7E30.jsonNewPers2F84S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

