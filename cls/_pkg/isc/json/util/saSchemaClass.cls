Class %pkg.isc.json.util.saSchemaClass Extends %Studio.SASchemaClass
{

/// Outputs the schema to the current device.
/// Useful for testing/debugging.
ClassMethod Display()
{
	Try {
		Set tStream = ##class(%Stream.GlobalCharacter).%New()
		$$$ThrowOnError(..OutputToStream(tStream))
		Do tStream.OutputToDevice()
	} Catch e {
		Write $System.Status.GetErrorText(e.AsStatus())
	}
}

}

