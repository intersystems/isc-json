Include %occErrors

/// Based on https://code.google.com/archive/p/jsonpath/
/// JSONPath 0.8.5 - XPath for JSON
/// 
/// Copyright (c) 2007 Stefan Goessner (goessner.net)
/// Licensed under the MIT (MIT-LICENSE.txt) licence.
Class UnitTest.isc.json.path Extends %UnitTest.TestCase
{

Method TestSimpleObjectPaths()
{
	Set tTargetObject =	{
		"a": "a",
		"b": "b",
		"c d": "e"
	}
	Set tTestCases = {
		"$.a": {
			"$['a']": "a"
		},
		"$['a']": {
			"$['a']": "a"
		},
		"$.'c d'": {
			"$['c d']": "e"
		},
		"$.*": {
			"$['a']": "a",
			"$['b']": "b",
			"$['c d']": "e"
		},
		"$['*']": {
			"$['a']": "a",
			"$['b']": "b",
			"$['c d']": "e"
		},
		"$[*]": {
			"$['a']": "a",
			"$['b']": "b",
			"$['c d']": "e"
		}
	}
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestSimpleArrayPaths()
{
	Set tTargetObject = [1, "2", 3.14, true, null]
	Set tTestCases = {
		"$[0]": {
			"$[0]": 1
		},
		"$[4]": {
			"$[4]": null
		},
		"$[*]": {
			"$[0]": 1,
			"$[1]": "2",
			"$[2]": 3.14,
			"$[3]": true,
			"$[4]": null
		},
		"$[-1:]": {
			"$[4]": null
		}
	}
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestPointPaths()
{
	Set tTargetObject =	{
		"points": [{
			"id": "i1",
			"x": 4,
			"y": -5
		}, {
			"id": "i2",
			"x": -2,
			"y": 2,
			"z": 1
		}, {
			"id": "i3",
			"x": 8,
			"y": 3
		}, {
			"id": "i4",
			"x": -6,
			"y": -1
		}, {
			"id": "i5",
			"x": 0,
			"y": 2,
			"z": 1
		}, {
			"id": "i6",
			"x": 1,
			"y": 4
		}]
	}
	Set tTestCases = {
		"$.points[1]": {
			"$['points'][1]": {
				"id": "i2",
				"x": -2,
				"y": 2,
				"z": 1
			}
		},
		"$.points[4].x": {
			"$['points'][4]['x']": 0
		},
		"$.points[*].x": {
			"$['points'][0]['x']": 4,
			"$['points'][1]['x']": -2,
			"$['points'][2]['x']": 8,
			"$['points'][3]['x']": -6,
			"$['points'][4]['x']": 0,
			"$['points'][5]['x']": 1
		},
		"$['points'][?(@.x*@.x+@.y*@.y > 50)].id": {
			"$['points'][2]['id']": "i3"
		},
		"$.points[?(@.z)].id": {
			"$['points'][1]['id']": "i2",
			"$['points'][4]['id']": "i5"
		},
		"$.points[(@.%Size()-1)].id": {
			"$['points'][5]['id']": "i6"
		}
	}
	
	// This is for v2016.1.x/2016.2.x compatibility
	Do tTestCases.%Set("$.points[?(@.id=""i4"")].x",{"$['points'][3]['x']": -6})
	
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestMenuPaths()
{
	Set tTargetObject = {
		"menu": {
			"header": "SVG Viewer",
			"items": [{
					"id": "Open"
				}, {
					"id": "OpenNew",
					"label": "Open New"
				},
				null, {
					"id": "ZoomIn",
					"label": "Zoom In"
				}, {
					"id": "ZoomOut",
					"label": "Zoom Out"
				}, {
					"id": "OriginalView",
					"label": "Original View"
				},
				null, {
					"id": "Quality"
				}, {
					"id": "Pause"
				}, {
					"id": "Mute"
				},
				null, {
					"id": "Find",
					"label": "Find..."
				}, {
					"id": "FindAgain",
					"label": "Find Again"
				}, {
					"id": "Copy"
				}, {
					"id": "CopyAgain",
					"label": "Copy Again"
				}, {
					"id": "CopySVG",
					"label": "Copy SVG"
				}, {
					"id": "ViewSVG",
					"label": "View SVG"
				}, {
					"id": "ViewSource",
					"label": "View Source"
				}, {
					"id": "SaveAs",
					"label": "Save As"
				},
				null, {
					"id": "Help"
				}, {
					"id": "About",
					"label": "About Adobe CVG Viewer..."
				}
			]
		}
	}
	
	Set tTestCases = {
		"$..[0]": {
			"$['menu']['items'][0]": {
				"id": "Open"
			}
		}
	}
	Set tLabelResults = {
		"$['menu']['items'][0]['id']": "Open",
		"$['menu']['items'][7]['id']": "Quality",
		"$['menu']['items'][8]['id']": "Pause",
		"$['menu']['items'][9]['id']": "Mute",
		"$['menu']['items'][13]['id']": "Copy",
		"$['menu']['items'][20]['id']": "Help"
	}
	Set tSvgResults = {
		"$['menu']['items'][15]['id']": "CopySVG",
		"$['menu']['items'][16]['id']": "ViewSVG"
	}
	
	// This is for v2016.1.x/2016.2.x compatibility
	Do tTestCases.%Set("$.menu.items[?(@ && (@.id'="""") && (@.label=""""))].id",tLabelResults)
	Do tTestCases.%Set("$.menu.items[?(@ && (@.label'="""") && (@.label [ ""SVG""))].id",tSvgResults)
	Do tTestCases.%Set("$.menu.items[?(@="""")]",{})
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestParallelArrays()
{
	Set tTargetObject = {
		"a": [1, 2, 3, 4],
		"b": [5, 6, 7, 8]
	}
	Set tTestCases = {
		"$..[0]": {
			"$['a'][0]": 1,
			"$['b'][0]": 5
		},
		"$..[-1:]": {
			"$['a'][3]": 4,
			"$['b'][3]": 8
		},
		"$..[?('$IsObject(@) && (@#2=0))]": {
			"$['a'][1]": 2,
			"$['a'][3]": 4,
			"$['b'][1]": 6,
			"$['b'][3]": 8
		}
	}
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestLineColors()
{
	Set tTargetObject = {
		"lin": {
			"color": "red",
			"x": 2,
			"y": 3
		},
		"cir": {
			"color": "blue",
			"x": 5,
			"y": 2,
			"r": 1
		},
		"arc": {
			"color": "green",
			"x": 2,
			"y": 4,
			"r": 2,
			"phi0": 30,
			"dphi": 120
		},
		"pnt": {
			"x": 0,
			"y": 7
		}
	}
	Set tTestCases = {
		"$.'?(@.color)'.x": {},
		"$['lin','cir'].color": {
			"$['lin']['color']": "red",
			"$['cir']['color']": "blue"
		},
		"$['lin','arc'].color": {
			"$['lin']['color']": "red",
			"$['arc']['color']": "green"
		}
	}
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestTextFilterExpressions()
{
	Set tTargetObject = {"text": ["hello", "world2.0"]}
	Set tTestCases = {
		"$.text[?($Length(@) > 5)]": {
			"$['text'][1]": "world2.0"
		}
	}
	
	// This is for v2016.1.x/2016.2.x compatibility
	Do tTestCases.%Set("$.text[?($Extract(@) = ""h"")]",{"$['text'][0]": "hello"})
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestRecursiveDescent()
{
	Set tTargetObject = {
		"a": {
			"a": 2,
			"b": 3
		},
		"b": {
			"a": 4,
			"b": 5
		},
		"c": {
			"a": {
				"a": 6,
				"b": 7
			},
			"c": 8
		}
	}
	Set tTestCases = {
		"$..a": {
			"$['a']": {
				"a": 2,
				"b": 3
			},
			"$['a']['a']": 2,
			"$['b']['a']": 4,
			"$['c']['a']": {
				"a": 6,
				"b": 7
			},
			"$['c']['a']['a']": 6
		}
	}
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method TestSpecialCharacters()
{
	Set tTargetObject = {
		"a": [{
				"a": 5,
				"@": 2,
				"$": 3
			}, // issue 7: resolved by escaping the '@' character 
			{
				"a": 6,
				"@": 3,
				"$": 4
			}, // in a JSONPath expression.
			{
				"a": 7,
				"@": 4,
				"$": 5
			}
		]
	}
	
	// This is for v2016.1.x/2016.2.x compatibility
	Set tTestCases = {}
	Set tExpr1Results = {
		"$['a'][1]": {
			"a": 6,
			"@": 3,
			"$": 4
		}
	}
	Do tTestCases.%Set("$.a[?(@.%Get(""\@"")=3)]",tExpr1Results)
	Set tExpr1Results = {
		"$['a'][1]": {
			"a": 6,
			"@": 3,
			"$": 4
		}
	}
	Set tExpr2Results = {
		"$['a'][2]": {
			"a": 7,
			"@": 4,
			"$": 5
		}
	}
	Do tTestCases.%Set("$.a[?(@.""$""=5)]",tExpr2Results)
	Do ..UtilEvaluateTestCases(tTargetObject,tTestCases)
}

Method UtilEvaluateTestCases(pTargetObject As %SystemBase, pExpectedResults As %SystemBase)
{
	Do $$$LogMessage("Target Object: "_pTargetObject.%ToJSON())
	Set tPathIter = pExpectedResults.%GetIterator()
	While tPathIter.%GetNext(.tPath,.tExpectedResults) {
		Do $$$LogMessage("Testing path: "_tPath)
		Set tResults = ##class(%pkg.isc.json.path).%Evaluate(pTargetObject,tPath,2,.tStatus)
		If $$$ISOK(tStatus) {
			If '$$$AssertEquals(tResults.%ToJSON(),tExpectedResults.%ToJSON()) {
				Do $$$AssertTrue(0,"Expected result: "_tExpectedResults.%ToJSON())
				//TODO: Instead, detailed analysis of differences.
			}
		} Else {
			If ($System.Status.GetErrorCodes(tStatus) = $$$NotImplemented) {
 				Set manager = r%Manager
				Do manager.LogAssert(2,"TestSkipped","Test skipped due to 'NotImplemented' error.")
			} Else {
				Do $$$AssertStatusOK(tStatus)
			}
		}
	}
}

}

