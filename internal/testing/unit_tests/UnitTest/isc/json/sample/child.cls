Class UnitTest.isc.json.sample.child Extends (%Persistent, %pkg.isc.json.adaptor)
{

Property Name As %String(MAXLEN = 128);

Relationship Parent As UnitTest.isc.json.sample.generalPersistent [ Cardinality = parent, Inverse = Children ];

Storage Default
{
<Data name="childDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("Children")</DataLocation>
<DefaultData>childDefaultData</DefaultData>
<IdLocation>^UnitTest.i7E30.generalPersiE85C("Children")</IdLocation>
<IndexLocation>^UnitTest.isc.json.sa7E30.childI</IndexLocation>
<StreamLocation>^UnitTest.isc.json.sa7E30.childS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

