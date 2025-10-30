Class UnitTest.isc.json.sample.generalPersistent Extends (%Persistent, %pkg.isc.json.adaptor)
{

// Scalars

Property Name As %String(MAXLEN = 80) [ Required ];

Property NameIgnoreNull As %String(%JSONIGNORENULL = 1, MAXLEN = 80);

Property "Snake_Case" As %String(MAXLEN = 100);

Property Age As %Integer;

Property DoubleVal As %Double;

Property Active As %Boolean;

Property Timestamp As %TimeStamp;

Property IntOrString As UnitTest.isc.json.sample.intOrString;

Property jsonObj As %DynamicObject;

Property jsonArr As %DynamicArray;

// Streams

Property CharStream As %Stream.GlobalCharacter;

Property BinaryStream As %Stream.GlobalBinary;

Property BinaryStreamHex As %Stream.GlobalBinary(ENCODING = "hex");

// Nested objects

Property SubItem As UnitTest.isc.json.sample.subItem;

Property SubItemPersistent As UnitTest.isc.json.sample.subItemPersistent;

Property SubItemPersistentID As UnitTest.isc.json.sample.subItemPersistent(%JSONREFERENCE = "ID");

Property SubItemPersistentOID As UnitTest.isc.json.sample.subItemPersistent(%JSONREFERENCE = "OID");

Property SubItemPersistentGUID As UnitTest.isc.json.sample.subItemPersistent(%JSONREFERENCE = "GUID");

// Lists / Arrays

Property Tags As list Of %String(MAXLEN = 60);

Property SubList As list Of UnitTest.isc.json.sample.subItem;

Property Attr As array Of %String(MAXLEN = 200);

Property Items As array Of UnitTest.isc.json.sample.subItem;

// Persistent Lists / Arrays

Property SubListPersistent As list Of UnitTest.isc.json.sample.subItemPersistent;

Property ItemsPersistent As array Of UnitTest.isc.json.sample.subItemPersistent;

// Relationships

Relationship Children As UnitTest.isc.json.sample.child [ Cardinality = children, Inverse = Parent ];

Relationship Relateds As UnitTest.isc.json.sample.related [ Cardinality = many, Inverse = Owner ];

ClassMethod Count()
{
    #dim resultSet As %SQL.StatementResult
    Set query = "SELECT Count(ID) As Total FROM UnitTest_isc_json_sample.generalPersistent"
    Set resultSet = ##class(%SQL.Statement).%ExecDirect(, query)
    $$$ThrowSQLIfError(resultSet.%SQLCODE,resultSet.%Message)
    Do resultSet.%Next(.sc)
    $$$ThrowOnError(sc)
    Return resultSet.%Get("Total")
}

Storage Default
{
<Data name="Attr">
<Attribute>Attr</Attribute>
<Structure>subnode</Structure>
<Subscript>"Attr"</Subscript>
</Data>
<Data name="Items">
<Attribute>Items</Attribute>
<Structure>subnode</Structure>
<Subscript>"Items"</Subscript>
</Data>
<Data name="ItemsPersistent">
<Attribute>ItemsPersistent</Attribute>
<Structure>subnode</Structure>
<Subscript>"ItemsPersistent"</Subscript>
</Data>
<Data name="generalPersistentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Age</Value>
</Value>
<Value name="4">
<Value>Active</Value>
</Value>
<Value name="5">
<Value>Tags</Value>
</Value>
<Value name="6">
<Value>SubList</Value>
</Value>
<Value name="7">
<Value>Timestamp</Value>
</Value>
<Value name="8">
<Value>IntOrString</Value>
</Value>
<Value name="9">
<Value>CharStream</Value>
</Value>
<Value name="10">
<Value>BinaryStream</Value>
</Value>
<Value name="11">
<Value>BinaryStreamHex</Value>
</Value>
<Value name="12">
<Value>SubItem</Value>
</Value>
<Value name="13">
<Value>SubItemPersistent</Value>
</Value>
<Value name="14">
<Value>SubItemPersistentID</Value>
</Value>
<Value name="15">
<Value>SubItemPersistentOID</Value>
</Value>
<Value name="16">
<Value>SubItemPersistentGUID</Value>
</Value>
<Value name="17">
<Value>Snake_Case</Value>
</Value>
<Value name="18">
<Value>NameIgnorNull</Value>
</Value>
<Value name="19">
<Value>NameIgnoreNull</Value>
</Value>
<Value name="20">
<Value>SubListPersistent</Value>
</Value>
<Value name="21">
<Value>DoubleVal</Value>
</Value>
</Data>
<Data name="jsonArr">
<Attribute>jsonArr</Attribute>
<Structure>node</Structure>
<Subscript>"jsonArr"</Subscript>
</Data>
<Data name="jsonObj">
<Attribute>jsonObj</Attribute>
<Structure>node</Structure>
<Subscript>"jsonObj"</Subscript>
</Data>
<DataLocation>^UnitTest.i7E30.generalPersiE85D</DataLocation>
<DefaultData>generalPersistentDefaultData</DefaultData>
<IdLocation>^UnitTest.i7E30.generalPersiE85D</IdLocation>
<IndexLocation>^UnitTest.i7E30.generalPersiE85I</IndexLocation>
<StreamLocation>^UnitTest.i7E30.generalPersiE85S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

XData NameOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <Property Name="Name" FieldName="name" />
  <!-- Only Name is included; all others excluded -->
  <!-- Streams, relationships, arrays, etc. are omitted by default in this mapping -->
  <!-- Reference projection, include flags, etc. can be customized per property as needed -->
  <!-- This mapping is used by tests to verify selective projection + field rename. -->
  
</Mapping>
}

XData NameAge [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Minimal mapping that includes just Name and Age with lowercase field names -->
  <Property Name="Name" FieldName="name" />
  <Property Name="Age" FieldName="age" />
</Mapping>
}

XData NoStreams [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Start from the default mapping, but exclude all stream properties from both input and output -->
  <Call />
  <Property Name="CharStream" Include="NONE" />
  <Property Name="BinaryStream" Include="NONE" />
  <Property Name="BinaryStreamHex" Include="NONE" />
</Mapping>
}

XData Simple [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Demonstrate passing the same mapping name to child SubItem -->
  <Property Name="Name" FieldName="name" />
  <!-- Execute the child's 'Simple' mapping on SubItem -->
  <Property Name="SubItem" Mapping="Simple" />
</Mapping>
}

XData ParentChildAlt [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Parent mapping chooses a different child mapping on SubItem -->
  <Property Name="Name" FieldName="Name" />
  <Property Name="SubItem" Mapping="CodeOnly" />
</Mapping>
}

XData InvalidChildMap [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Intentionally reference a non-existent mapping for SubItem and SubItemPersistent to test error handling -->
  <Property Name="Name" FieldName="Name" />
  <Property Name="SubItem" Mapping="NoSuchMap" />
  <Property Name="SubItemPersistent" Mapping="NoSuchMap" />
</Mapping>
}

}
