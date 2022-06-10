ROUTINE %pkg.isc.json.map [Type=INC]
#;-----------------Stolen from %jsonMap-----------------
#;Macros for JSON map
#define jsonclass(%map,%name)               $listget(%map(%name,0),1)
#define jsonignoreinvalidfield(%map,%name)  $listget(%map(%name,0),2)
#define jsonpropertycount(%map,%name)       $get(%map(%name))
#define jsongetprop(%map,%name,%idx)        $get(%map(%name,%idx))
#define jsonproperty(%node)     $list(%node,1)
#define jsonpropertyQN(%node)   $list(%node,2)
#; Possible values of jsoninclude are "N","I","O","IO"
#define jsoninclude(%node)      $list(%node,3)
#define jsonfieldname(%node)    $list(%node,4)
#define jsonnull(%node)         $list(%node,5)
#define jsonignorenull(%node)   $list(%node,6)
#; Possible jsonreference values
#define jsonrefobject    1
#define jsonrefid        2
#define jsonrefoid       3
#define jsonrefguid      4
#define jsonreference(%node)    $list(%node,7)
#define jsonrequired(%node)     $list(%node,8)
#define jsonliteraltype(%node)  $list(%node,9)
#define jsonmembercat(%node)    $list(%node,10)
#define jsontype(%node)         $list(%node,11)
#define jsonmapping(%node)      $list(%node,12)
#;
#; isCollectionValue possibilities
#define isCollectionList   1
#define isCollectionArray  2
#; External display format for mapping name
#define mappingNameDisplay(%name)  $select(%name="":"class base",1:%name)
#;------------Helpers for %pkg.isc.json.path--------------
#define jsonIsValidArraySubscript(%val) ((%val = (%val\1)) && (%val >= 0))
#define jsonKeyDefined(%obj,%key) (%obj.%IsDefined(%key) && ('%obj.%IsA("%Library.DynamicArray") || $$$jsonIsValidArraySubscript(%key)))
#;-----------------Error macro stubs-----------------
#;----------Custom errors added in %pkg.isc.*-------------
#define JSONReferencedTypeIsNotAdapted	9450
#; JSONInvalidIDPROJECTION is similar to %ObjectErrors 6259 (XMLInvalidIDPROJECTION)
#define JSONInvalidIDPROJECTION			9451
#define JSONPathExpressionError			9460
#define JSONPathEvalError				9461

