ROUTINE %pkg.isc.json.cos [Type=INC]
#include %occReference
#if $$$comClassDefined("%Library.Object")
    #define jsonClassIsLatestVersion $classIsLatestVersion 	
    						//usage: obj.$$$jsonClassIsLatestVersion()
    #define jsonExtends $extends							
    						//usage: {}.$$$jsonExtends(classname) 
    #define jsonFromJSON $fromJSON							
    						//usage: {}.$$$jsonFromJSON(string) 
    #define jsonGetIterator $getIterator 					
    						//usage: obj.$$$jsonGetIterator()
    #define jsonGetNext $getNext 					
    						//usage: iterator.$$$jsonGetNext(.key, .value)
    #define jsonIsA $isA									
    						//usage: obj.$$$jsonIsA(classname)
    #define jsonToJSON $toJSON								
    						//usage: obj.$$$jsonToJSON()
    #define jsonGet $get									
    						//usage: obj.$$$jsonGet(key)
    #define jsonIsDefined $isDefined						
    						//usage: obj.$$$jsonIsDefined(key) 
    #define jsonRemove $remove								
    						//usage: obj.$$$jsonRemove(key)
    #define jsonSet $set									
    						//usage: obj.$$$jsonSet(key, val)
    #define jsonSize $size									
    						// usage: obj.$$$jsonSize()
    #define jsonPop $pop									
    						//usage: obj.$$$jsonPop()
    #define jsonPush $push									
    						//usage: obj.$$$jsonPush(val) 
	#define jsonAbstractClass %Library.AbstractObject
	#define jsonObjectClass %Library.Object
	#define jsonArrayClass %Library.Array

	#define jsonInitialArrayIndex 0
#else
    #define jsonClassIsLatestVersion %ClassIsLatestVersion 	
    						//usage: obj.$$$jsonClassIsLatestVersion()
    #define jsonExtends %Extends							
    						//usage: {}.$$$jsonExtends(classname) 
    #define jsonFromJSON %FromJSON							
    						//usage: {}.$$$jsonFromJSON(string) 
    #define jsonGetIterator %GetIterator 					
    						//usage: obj.$$$jsonGetIterator()
	#define jsonGetNext %GetNext 					
    						//usage: iterator.$$$jsonGetNext(.key, .value)
	#define jsonIsA %IsA									
    						//usage: obj.$$$jsonIsA(className)
    #define jsonToJSON %ToJSON								
    						//usage: obj.$$$jsonToJSON()
    #define jsonGet %Get									
    						//usage: obj.$$$jsonGet(key)
    #define jsonIsDefined %IsDefined						
    						//usage: obj.$$$jsonIsDefined(key) 
    #define jsonRemove %Remove								
    						//usage: obj.$$$jsonRemove(key)
    #define jsonSet %Set									
    						//usage: obj.$$$jsonSet(key, val)
    #define jsonSize %Size									
    						//usage: obj.$$$jsonSize()
    #define jsonPop %Pop									
    						//usage: obj.$$$jsonPop()
    #define jsonPush %Push									
    						//usage: obj.$$$jsonPush(val) 
	#define jsonAbstractClass %Library.DynamicAbstractObject
	#define jsonObjectClass %Library.DynamicObject
	#define jsonArrayClass %Library.DynamicArray
	
	#define jsonInitialArrayIndex 0
#endif

#def1arg jsonIsAbstract %IsA(##Quote($$$jsonAbstractClass))
							//usage: obj.$$$jsonIsAbstract
#def1arg jsonIsObject %IsA(##Quote($$$jsonObjectClass))
							//usage: obj.$$$jsonIsObject
#def1arg jsonIsArray %IsA(##Quote($$$jsonArrayClass))
							//usage: obj.$$$jsonIsArray

#; Workarounds for behavior of array.%IsDefined("string") returning 1
#define jsonIsValidArraySubscript(%val) ((%val = (%val\1)) && (%val >= 0))
#define jsonKeyDefined(%obj,%key) (%obj.$$$jsonIsDefined(%key) && ('%obj.$$$jsonIsArray || $$$jsonIsValidArraySubscript(%key)))
