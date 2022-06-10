Class UnitTest.isc.json.mappingOverlay Extends (%RegisteredObject, %pkg.isc.json.adaptor)
{

Property Name As %String;

Property DOB As %Date;

Property SSN As %String;

XData NameOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<Property Name="Name" FieldName="name" />
</Mapping>
}

XData Everything [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<!-- Reuse the NameOnly mapping, adding dob and ssn properties. -->
<Call Mapping="NameOnly" />
<Property Name="DOB" FieldName="dob" />
<Property Name="SSN" FieldName="ssn" />
</Mapping>
}

XData SSNInputOnly [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<!-- Call the default mapping, but make SSN input only. -->
<Call />
<Property Name="SSN" FieldName="SSN" Include="INPUTONLY" />
</Mapping>
}

XData NoSSN [ XMLNamespace = "http://www.intersystems.com/_pkg/isc/json/jsonmapping" ]
{
<Mapping xmlns="http://www.intersystems.com/_pkg/isc/json/jsonmapping" IgnoreInvalidField="true">
<Call />
<Property Name="SSN" FieldName="SSN" Include="NONE" />
</Mapping>
}

}

