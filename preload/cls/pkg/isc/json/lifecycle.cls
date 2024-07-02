Class pkg.isc.json.lifecycle Extends %ZPM.PackageManager.Developer.Lifecycle.Module
{

ClassMethod GetClass(tOld, tNew) [ Internal, Private ]
{
	Return $Select(##class(%Dictionary.ClassDefinition).%ExistsId(tNew):tNew, 1:tOld)
}

ClassMethod GetUtilClass() As %String 
{
	Return ..GetClass("%ZPM.PackageManager.Developer.Utils", "%IPM.Utils.Module")
}

ClassMethod GetLifecycleClass() As %String 
{
	Return ..GetClass("%ZPM.PackageManager.Developer.Lifecycle.Module", "%IPM.Lifecycle.Module")
}

ClassMethod RunOnLoad() [ CodeMode = objectgenerator ]
{
	Quit:$Extract($Namespace)="^" $$$OK
	Set sc = $$$OK
	Try {
		set tUtilCls = $Select(##class(%Dictionary.ClassDefinition).%ExistsId("%IPM.Utils.Module"):"%IPM.Utils.Module", 1:"%ZPM.PackageManager.Developer.Utils")
		Set sourceDB = $ClassMethod(tUtilCls, "GetRoutineDatabase",$Namespace)
		Set sc = $ClassMethod(tUtilCls, "AddGlobalMapping", $Namespace, "oddPKG(""%pkg.isc.json"")", sourceDB)
		$$$ThrowOnError(sc)
		Set sc = $ClassMethod(tUtilCls, "AddPackageMapping", $Namespace, "%pkg.isc.json", sourceDB)
		$$$ThrowOnError(sc)
	} Catch e {
		Set sc = e.AsStatus()
	}
	Return sc
}

Method %Reload(ByRef pParams) As %Status
{
	Set sc = $$$OK
	Try {
		Set sourceDB = $ClassMethod(..GetUtilClass(), "GetRoutineDatabase", $Namespace)
		Set sc = $ClassMethod(..GetUtilClass(), "AddGlobalMapping", $Namespace, "oddPKG(""%pkg.isc.json"")", sourceDB)
		$$$ThrowOnError(sc)
		Set sc = $ClassMethod(..GetUtilClass(), "AddPackageMapping", $Namespace, "%pkg.isc.json", sourceDB)
		$$$ThrowOnError(sc)
		// Ensure super is called AFTER mappings are set up
		Set sc = ##super(.pParams)
		$$$ThrowOnError(sc) 
	} Catch e {
		Set sc = e.AsStatus()
	}
	Return sc
}

Method %Clean(ByRef pParams) As %Status
{
	Set sc = $$$OK
	Try {
		Set sc = ##super(.pParams)
		$$$ThrowOnError(sc)
		Do $ClassMethod(..GetUtilClass(), "RemoveGlobalMapping", $Namespace, "oddPKG(""%pkg.isc.json"")")
		Do $ClassMethod(..GetUtilClass(), "RemovePackageMapping", $Namespace, "%pkg.isc.json")
	} Catch e {
		Set sc = e.AsStatus()
	}
	Return sc
}

}

