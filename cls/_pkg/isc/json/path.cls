Include %pkg.isc.json.map

/// An ObjectScript implementation of JSONPath
/// Expressions syntax is ObjectScript rather than JavaScript.
/// Derived from:
/// JSONPath 0.8.5 - XPath for JSON
/// 
/// Copyright (c) 2007 Stefan Goessner (goessner.net)
/// Licensed under the MIT (MIT-LICENSE.txt) licence.
Class %pkg.isc.json.path Extends %RegisteredObject
{

/// Collected results matching the path expression
Property %result As %Library.DynamicAbstractObject [ Private ];

/// Mode: <br />
/// 0 (default): return array of values matching the expression. <br />
/// 1 : return array of paths matching the expression. <br />
/// 2 : return object with values matching the expression keyed by their associated paths.
Property %mode As %Integer(VALUELIST = ",0,1,2") [ Private ];

/// Returns the result of applying <var>pExpr</var> to <var>pObj</var>. <br />
/// Possible values for <var>pMode</var>: <br />
/// 0 (default): return array of values matching the expression. <br />
/// 1 : return array of paths matching the expression. <br />
/// 2 : return object with values matching the expression keyed by their associated paths.
ClassMethod %Evaluate(pObj As %Library.DynamicAbstractObject, pExpr As %String, pMode As %Boolean = 0, Output pStatus As %Status) As %SystemBase
{
	Set pStatus = $$$OK
	Set tInst = ..%New(pMode)
	Try {
		Set tNormExpr = ..normalize(pExpr)
		If ($ListGet(tNormExpr,1) = "$") {
			Set tNormExpr = $List(tNormExpr,2,*)
		}
		Do tInst.walk(tNormExpr, pObj, $ListBuild("$"))
	} Catch e {
		Set outerSC = $$$ERROR($$$JSONPathExpressionError,pExpr)
		Set innerSC = e.AsStatus()
		Set pStatus = $$$EMBEDSC(outerSC,innerSC)
	}
	Return tInst.%result
}

/// Initialize result based on mode.
Method %OnNew(pMode As %Integer) As %Status [ Private, ServerOnly = 1 ]
{
	Set ..%mode = pMode
	Set ..%result = $Case(pMode,2:{},:[])
	Quit $$$OK
}

/// Converts a JSONPath expression to a normalized format.
ClassMethod normalize(pExpression As %String) As %List [ Private, PublicList = tCapturedExpressions ]
{
	New tCapturedExpressions
	Set tCapturedExpressions = []

	#; Strip expressions to avoid issues
	Set tExpression = ..replaceRegEx(pExpression,"[\['](\??\(.*?\))[\]']|\['(.*?)'\]",,"normalizeAnonStripExpressions")

	#; Starts of path pieces
	Set tExpression = ..replaceRegEx(tExpression,"'?\.'?|\['?",";")

	#; Put recursive descent back in
	Set tExpression = ..replaceRegEx(tExpression,";;;|;;",";..;")

	#; Ends of path pieces
	Set tExpression = ..replaceRegEx(tExpression,";$|'?\]|'$")
	
	#; Make pExpr a %ListBuild list instead of semicolon-delimited
	Set tExpressionAsList = $ListFromString(tExpression,";")
	
	#; Restore expressions previously stripped
	Set tReturnList = ""
	Set tPointer = 0
	While $ListNext(tExpressionAsList,tPointer,tExpressionPart) {
		Set tReturnList = tReturnList_$ListBuild(..replaceRegEx(tExpressionPart,"#([0-9]+)",,"normalizeAnonGetExpression"))
	}
	
	Quit tReturnList
}

/// Converts a normalized path expression to a readable format.
ClassMethod asPath(pPath As %List) As %String [ Private ]
{
	Set tPath = "$"
	Set tPtr = 0
	While $ListNext(pPath,tPtr,tPiece) {
		If ($Increment(tCount)=1) Continue
		Set tIsInt = (tPiece = (+tPiece/1))
		Set tPath = tPath_$Select(tIsInt:"["_tPiece_"]",1:"['"_tPiece_"']")
	}
	Quit tPath
}

/// Stores a match to a path expression.
/// Type of pValue may vary and is therefore unspecified.
Method store(pPath As %List, pValue, pType As %String = "") As %Boolean [ Private ]
{
	If (pPath '= "") {
		If (..%mode = 0) {
			Do ..%result.%Push(pValue)
		} ElseIf (..%mode = 1) {
			Do ..%result.%Push(..asPath(pPath))
		} ElseIf (..%mode = 2) {
			If (pType = "") || $IsObject(pValue) {
				Do ..%result.%Set(..asPath(pPath), pValue)
			} Else {
				Do ..%result.%Set(..asPath(pPath), pValue, pType)
			}
		}
	}
	Quit ''pPath
}

/// Walks through a path expression, applying it to the target object.
/// Type of pValue may vary and is therefore unspecified.
Method walk(pExpression As %List, pValue, pPath As %List, pType As %String) [ Private ]
{
	If (pExpression '= "") {
		Set tPathPiece = $List(pExpression)
		Set tPathRemainder = $List(pExpression,2,*)
		Try {
			Set tHasOwnProperty = $$$jsonKeyDefined(pValue,tPathPiece)
		} Catch e {
			Set tHasOwnProperty = 0
		}
		If tHasOwnProperty {
			Do ..walk(tPathRemainder, pValue.%Get(tPathPiece), pPath_$ListBuild(tPathPiece), pValue.%GetTypeOf(tPathPiece))
		} ElseIf (tPathPiece = "*") {
			Do ..descend(tPathPiece, tPathRemainder, pValue, pPath, "walkAnonStar")
		} ElseIf (tPathPiece = "..") {
			Do ..walk(tPathRemainder, pValue, pPath)
			Do ..descend(tPathPiece, tPathRemainder, pValue, pPath, "walkAnonDotDot")
		} ElseIf (..testRegEx(tPathPiece,"^\(.*?\)$")) {  // [(expr)]
			Do ..walk($ListBuild(..eval(tPathPiece, pValue, $List(pPath,1,*-1)))_tPathRemainder, pValue, pPath)
		} ElseIf (..testRegEx(tPathPiece,"^\?\(*.*?\)$")) { // [?(expr)]
			Do ..descend(tPathPiece, tPathRemainder, pValue, pPath, "walkAnonEval")
		} ElseIf (..testRegEx(tPathPiece,"^(-?[0-9]*):(-?[0-9]*):?([0-9]*)$")) { // [start:end:step]  python slice syntax
			Do ..slice(tPathPiece, tPathRemainder, pValue, pPath)
		} ElseIf (tPathPiece [ ",") { // [name1,name2,...]
			Set tNameList = ..splitRegEx(tPathPiece,"'?,'?")
			Set tPtr = 0
			While $ListNext(tNameList,tPtr,tName) {
				Do ..walk($ListBuild(tName)_tPathRemainder, pValue, pPath)
			}
		}
	} Else {
		Do ..store(pPath,pValue,pType)
	}
}

/// Navigates down a layer in an object/array, passing the result to the specified <var>pHandlerFunction</var>
Method descend(pCurrentExpression As %String, pTrailingExpression As %List, pValue, pPath As %List, pHandlerFunction As %String) [ Private ]
{
	If $IsObject(pValue) && (pValue.%IsA("%Library.DynamicAbstractObject")) {
		// Original JS implementation had separate array/object cases; iterators remove this need and generally simplify things.
		Set tIter = pValue.%GetIterator()
		While tIter.%GetNext(.tKey,.tValue) {
			Do $Method($this,pHandlerFunction,tKey,pCurrentExpression,pTrailingExpression,pValue,pPath)
		}
	}
}

/// Performs array slicing based on a [start:end:step] expression <br />
/// Array indices are 0-based.
Method slice(pCurrentExpression As %String, pTrailingExpression As %List, pValue, pPath As %List) [ Private ]
{
	If $IsObject(pValue) && pValue.%IsA("%Library.DynamicArray") {
		Set tLength = pValue.%Size()
		Set tStart = $Piece(pCurrentExpression,":",1)
		Set:(tStart="") tStart = 0
		Set tEnd = $Piece(pCurrentExpression,":",2)
		Set:(tEnd="") tEnd = tLength
		Set tStep = $Piece(pCurrentExpression,":",3)
		Set:(tStep="") tStep = 1
		If (tStart < 0) {
			Set tStart = $Select((tStart+tLength)<0:0,1:(tStart+tLength))
		} Else {
			Set tStart = $Select(tLength<tStart:tLength,1:tStart)
		}
		If (tEnd < 0) {
			Set tEnd = $Select((tEnd+tLength)<0:0,1:(tEnd+tLength))
		} Else {
			Set tEnd = $Select(tLength<tEnd:tLength,1:tEnd)
		}
		For tI = tStart:tStep:(tEnd-1) {
			Do ..walk($ListBuild(tI)_pTrailingExpression, pValue, pPath)
		}
	}
}

/// JSONPath (http://goessner.net/articles/JsonPath/) is defined as: <br />
/// ?() applies a filter (script) expression. <br />
/// () script expression, using the underlying script engine. <br />
/// In this case, the "underlying script engine" is ObjectScript, so these are ObjectScript expressions.
Method eval(pExpression As %String, pValue, pPath As %List) [ Private ]
{
	If (pValue = "") {
		Quit 0
	}
	Set tExpr = ..replaceRegEx(pExpression,"(^|[^\\])@","$1pV")
	Set tExpr = ..replaceRegEx(tExpr,"\\@","@")
	Try {
		Set tExecString = "(tExprResult,pV) Set tExprResult = ("_tExpr_")"
		Xecute (tExecString,.tExprResult,pValue)
	} Catch e {
		Set tStatus = $System.Status.EmbedStatus($$$ERROR($$$JSONPathEvalError,tExecString),e.AsStatus())
		$$$ThrowStatus(tStatus)
	}
	Quit tExprResult
}

/// Converted from anonymous method to strip expressions from a path expression before normalizing.
/// Expressions are replaced with [#n] during normalization.
ClassMethod normalizeAnonStripExpressions(pFilterExpression As %String, pDataExpression As %String) As %String [ Private, PublicList = tCapturedExpressions ]
{
	Set tVal = $Case(pFilterExpression,"":pDataExpression,:pFilterExpression)
	Set tRV = "[#"_tCapturedExpressions.%Size()_"]"
	Do tCapturedExpressions.%Push(tVal)
	Quit tRV
}

/// Restores expressions previously replaced with [#n] in normalizeAnonStripExpressions
ClassMethod normalizeAnonGetExpression(pExpressionReference As %Integer) As %String [ Private, PublicList = tCapturedExpressions ]
{
	Quit tCapturedExpressions.%Get(pExpressionReference)
}

/// Method called while walking through an array/object's members to evaluate "*"
Method walkAnonStar(pSubKey As %String, pCurrentExpression As %String, pTrailingExpression As %List, pValue, pPath As %List) [ Private ]
{
	Do ..walk($ListBuild(pSubKey)_pTrailingExpression,pValue,pPath)
}

/// Method called while walking through an array/object's members to evaluate ".."
Method walkAnonDotDot(pSubKey As %String, pCurrentExpression As %String, pTrailingExpression As %List, pValue, pPath As %List) [ Private ]
{
	If $IsObject(pValue) && $$$jsonKeyDefined(pValue,pSubKey) && $IsObject(pValue.%Get(pSubKey)) {
		Do ..walk($ListBuild("..")_pTrailingExpression,pValue.%Get(pSubKey),pPath_$ListBuild(pSubKey),pValue.%GetTypeOf(pSubKey))
	}
}

/// Method called while walking through an array/object's members to evaluate an expression for each of them.
Method walkAnonEval(pSubKey As %String, pCurrentExpression As %String, pTrailingExpression As %List, pValue, pPath As %List) [ Private ]
{
	If (..eval(..replaceRegEx(pCurrentExpression,"^\?\((.*?)\)$","$1"), $Select(pValue.%IsA("%Library.DynamicArray"):pValue.%Get(pSubKey),1:pValue), pSubKey)) {
		Do ..walk($ListBuild(pSubKey)_pTrailingExpression,pValue,pPath)
	}
}

/// Tests string <var>pTarget</var> for a match to <var>pRegEx</var>
ClassMethod testRegEx(pTargetString As %String, pRegEx As %String) As %Boolean [ Private ]
{
	Set tMatcher = ##class(%Regex.Matcher).%New(pRegEx)
	Set tMatcher.Text = pTargetString
	Quit tMatcher.Match()
}

/// Splits a string (<var>pTarget</var>) into a $ListBuild list by a regular expression (<var>pRegEx</var>).
ClassMethod splitRegEx(pTargetString As %String, pRegEx As %String) As %List [ Private ]
{
	Set tList = ""
	Set tMatcher = ##class(%Regex.Matcher).%New(pRegEx)
	Set tMatcher.Text = pTargetString
	Set tLastEnd = 1
	While tMatcher.Locate() {
		Set tList = tList_$ListBuild($Extract(pTargetString,tLastEnd,tMatcher.Start-1))
		Set tLastEnd = tMatcher.End
	}
	Set tList = tList_$ListBuild($Extract(pTargetString,tLastEnd,*))
	Quit tList
}

/// Replaces a regex within a string.
/// Not ProcedureBlock to allow sharing of variables between the caller and pReplacementFunction.
ClassMethod replaceRegEx(pSubject As %String, pRegEx As %String, pReplacement As %String = "", pReplacementFunction As %String = "") As %String [ Private, ProcedureBlock = 0 ]
{
	New tMatcher,tGroupVals,tResultText,tLastEnd,tReplacementValue,i
	Set tMatcher = ##class(%Regex.Matcher).%New(pRegEx)
	Set tMatcher.Text = pSubject
	If (pReplacementFunction = "") {
		Quit tMatcher.ReplaceAll(pReplacement)
	} Else {
		Set tResultText = ""
		Set tLastEnd = 1
	    While tMatcher.Locate() {
		    Kill tGroupVals
		    // Note: Merge tGroupVals = tMatcher.Group would be nice... but there's an overridden accessor (GroupGet).
		    Set tGroupVals = tMatcher.GroupCount
		    For i=1:1:tGroupVals {
			    Set tGroupVals(i) = tMatcher.Group(i)
		    }
		    Set tReplacementValue = $ClassMethod($classname(),pReplacementFunction,tGroupVals...)
		    Set tResultText = tResultText_$Extract(pSubject,tLastEnd,tMatcher.Start-1)_tReplacementValue
			Set tLastEnd = tMatcher.End
	    }
	    Set tResultText = tResultText_$Extract(pSubject,tLastEnd,*)
	    Quit tResultText
	}
}

}

