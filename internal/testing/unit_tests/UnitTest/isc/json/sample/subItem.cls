Class UnitTest.isc.json.sample.subItem Extends (%SerialObject, %pkg.isc.json.adaptor)
{

Property Code As %String(MAXLEN = 64);

Property Value As %Integer;

Storage Default
{
<Data name="subItemState">
<Value name="1">
<Value>Code</Value>
</Value>
<Value name="2">
<Value>Value</Value>
</Value>
</Data>
<State>subItemState</State>
<StreamLocation>^UnitTest.isc.json7E30.subItemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

XData Simple [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Child mapping with lowercase field names for import/export -->
  <Property Name="Code" FieldName="code" />
  <Property Name="Value" FieldName="value" />
 </Mapping>
}

XData CodeOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
  <!-- Only import/export the Code property -->
  <Property Name="Code" FieldName="code" />
 </Mapping>
}

}
