Class UnitTest.isc.json.sample.related Extends (%Persistent, %pkg.isc.json.adaptor)
{

Property Label As %String(MAXLEN = 80);

Relationship Owner As UnitTest.isc.json.sample.generalPersistent [ Cardinality = one, Inverse = Relateds ];

Storage Default
{
<Data name="relatedDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Label</Value>
</Value>
<Value name="3">
<Value>Owner</Value>
</Value>
</Data>
<DataLocation>^UnitTest.isc.json7E30.relatedD</DataLocation>
<DefaultData>relatedDefaultData</DefaultData>
<IdLocation>^UnitTest.isc.json7E30.relatedD</IdLocation>
<IndexLocation>^UnitTest.isc.json7E30.relatedI</IndexLocation>
<StreamLocation>^UnitTest.isc.json7E30.relatedS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

