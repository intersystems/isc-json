Include (%occInclude, %pkg.isc.json.map)

/// %pkg.isc.json.formatter implements the ability to format JSON documents which are
/// expressed as strings, text or dynamic objects.
Class %pkg.isc.json.formatter Extends %RegisteredObject [ System = 4 ]
{

/// Indent specifies that indentation of the JSON output should take place.
Property Indent As %Boolean [ InitialExpression = 1 ];

/// IndentChars specifies the character sequence to be used for each indent level if Indent=1.
Property IndentChars As %String [ InitialExpression = "  " ];

/// LineTerminator specifies the character sequence to terminate eaach line when indenting.
Property LineTerminator As %String [ InitialExpression = {$char(13,10)} ];

/// Format a JSON document using the specified indentation and write it to the current device.<br>
/// The <var>input</var> argument is either JSON as a string or stream, or a subclass of %DynamicAbstractObject.<br>
Method Format(input) As %Status
{
	Quit ..FormatInternal(input,"",1)
}

/// Format a JSON document using the specified indentation and write it to a stream.<br>
/// The <var>input</var> argument is either JSON as a string or stream, or a subclass of %DynamicAbstractObject.<br>
Method FormatToStream(input, ByRef export As %Stream.Object) As %Status
{
	Try {
		Set io=""
		// Always output to %FileCharacterStream
		If $get(export)="" {
			Set export=##class(%FileCharacterStream).%New()
			// JSON is always UTF-8
			Set export.TranslateTable="UTF8"
			Set filestream=1
		} Else {
			Set filestream = ($zobjclass(export)="%Library.FileCharacterStream")
		}
		If filestream {
			Set stream=export
		} Else {
			Set stream=##class(%FileCharacterStream).%New()
			Set stream.TranslateTable="UTF8"
		}
		
		// Force stream's file to open
		Set sc=stream.Write("")
		
		// Export JSON to the stream
		If $$$ISOK(sc) {
			// Save current device
			Set io=$io
			// Make the stream file be the current device
			Set file=stream.Filename ; get filename and make current device
			Use file:(/NOXY)
			Set sc=..FormatInternal(input,"",1)
			// Don't Close file to leave stream positioned
			Use io
		}
		
		// Need to ensure that LineTerminator is correct for the platform
		If $$$ISOK(sc) Set stream.LineTerminator=$select($$$isUNIX:$char(10),1:$char(13,10))
		
		// If we created the stream and caller passed in stream, then copy it to the caller's stream
		If 'filestream,$$$ISOK(sc) {	
			Set sc=export.CopyFrom(stream)
		}

	} Catch ex {
		If io'="" Use io
		Set sc=ex.AsStatus()
	}

	Quit sc
}

/// Format a JSON document using the specified indentation and write it to a string.<br>
/// Serialize a JSON enabled class as a JSON document and return it as a string.<br>
Method FormatToString(input, ByRef export As %String = "") As %Status
{
	Quit ..FormatInternal(input,.export,0)
}

/// Internal method to actually do the formatting
Method FormatInternal(input, ByRef export As %String, toDevice As %Boolean) [ Internal ]
{
	Set sc=$$$OK
	Try {
		// If writing to current device then we need to clear our string buffer for each iteraation of loop
		If toDevice Set export=""

		// initialize indentation
		Set indent=..Indent
		If indent {
			Set lineTerminator=..LineTerminator
			Set indentChars=..IndentChars
			Set indentLength=$length(indentChars)
		} Else {
			Set lineTerminator=""
			Set indentChars=""
			Set indentLength=0
		}
		Set currentIndent=""
		
		// If a JSON string, then convert to dynamic object or array before formatting
		If $isobject(input),input.%IsA("%Library.DynamicAbstractObject") {
			// Already a dynamic object
			Set currentContainer=input
		} Else {
			// A JSON stream or string
			Set currentContainer=##class(%Library.DynamicAbstractObject).%FromJSON(input)
		}

		// Initialize loop variables
		Set stackCount=0
		Set currentType=$select(currentContainer.%IsA("%Library.DynamicObject"):"object",1:"array")
		Set currentIterator=currentContainer.%GetIterator()
		Set sep=""
		// Push stack
		Set iteratorStack(stackCount)=currentIterator
		Set containerStack(stackCount)=currentContainer
		Set typeStack(stackCount)=currentType
		Set stackCount=stackCount+1
		
		// Start output of object or array
		Set export=export_$select(currentType="object":"{",1:"[")
		If indent {
			Set currentIndent=currentIndent_indentChars
		}
				
		// Main loop to walk tree without using recursion
		For {
			// Finish up for this value and prepare for next
			Set currentIteratorIsObject=currentIterator.%IsA("%Iterator.Object")
			If currentIterator.%GetNext(.key,.current) {
				// There is another value in this object or array.
				Set currentType=currentContainer.%GetTypeOf(key)
				// Output , and indentation
				Set export=export_sep
				If indent Set export=export_lineTerminator_currentIndent
				Set sep=","

			} Else {
				// There are no more values in this array or object
				// Output closing } or ] with indentation
    			If indent {
	    			Set currentIndent=$extract(currentIndent,1,*-indentLength)
	    			Set export=export_lineTerminator_currentIndent
    			}
				Set export=export_$select(currentIteratorIsObject:"}",1:"]")
				
				// Pop stack to make containing object or array the current object or array.
				Set stackCount=stackCount-1
				If stackCount=0 Quit
				Set currentIterator=iteratorStack(stackCount)
				Set currentContainer=containerStack(stackCount)
				Set currentType=typeStack(stackCount)
				Set sep=","
				
				// Get next value at previous level
				Continue
			}

			// If this is an object, then output next field name.
			If currentIteratorIsObject {
				Set export=export_""""_key_""":"
			}

			// Stack processing for object and array values
			If (currentType="object") || (currentType="array") {
				// Push stack
				Set iteratorStack(stackCount)=currentIterator
				Set containerStack(stackCount)=currentContainer
				Set typeStack(stackCount)=currentType
				Set sep=""
				Set stackCount=stackCount+1
				
				// Setup for loop over object values
				Set currentIterator=current.%GetIterator()
				Set currentContainer=current
				
				// Start output of object or array
				Set export=export_$select(currentType="object":"{",1:"[")
				If indent {
					Set currentIndent=currentIndent_indentChars
					If lineTerminator="" Set lineTerminator=..LineTerminator
				}
				
			// Output of string
			} ElseIf currentType="string" {
				Set export=export_""""_$zcvt(current,"O","JSON")_""""

			// Output of boolean
			} ElseIf currentType="boolean" {
				Set export=export_$select(current:"true",1:"false")

			// Output null
			} ElseIf currentType="null" {
				Set export=export_"null"

			// Output of number
			} Else {
				If $extract(current)="." Set current="0"_current
				If $extract(current,1,2)="-." Set current="-0."_$extract(current,3,*)
				Set export=export_current
			}
			
			// If writing to current device then write buffer and clear our string buffer for each iteraation of loop
			If toDevice {
				Write export
				Set export=""
			}
		}
		
		// Write the remainder
		If toDevice,export'="" {
			Write export
		}

	} Catch ex {
		Set sc=ex.AsStatus()
	}

	Quit sc
}

}

