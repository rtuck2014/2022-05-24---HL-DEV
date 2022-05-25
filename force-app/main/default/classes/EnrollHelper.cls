public with sharing class EnrollHelper {
    
    // Assign LO object with id and object type to current user.
    public static Boolean enroll(String objectId, String objectType){
	    
	    String methodName = MobileConstants.ENROLL_METHODS.get(objectType);
	    if (methodName == null || String.isEmpty(methodName)){
	        throw new MobileHelper.MobileException('Can not find enroll method for object type: ' + objectType);
	    }
	    
	    String enrollObjectType = MobileConstants.ENROLL_OBJECT_TYPES.get(objectType);
	    if (enrollObjectType == null || String.isEmpty(enrollObjectType)){
	        throw new MobileHelper.MobileException('Can not find enroll parametr name for object type: ' + objectType);
	    }
	    
	    Map<String, Object> invokeParams = new Map<String, Object>{
	        'MethodName' => methodName,  'userId' => UserInfo.getUserId(), enrollObjectType => new Set<Id>{objectId}      
	    };
	    
	    Map<String, Object> invokeResult;
	    
	    try{
	        invokeResult = lmscons.LMSUtil.InvokePackageMethod(invokeParams);    
            if (invokeResult == null || !invokeResult.containsKey('Result')){
                throw new MobileHelper.MobileException('Error with assign method');
            }	        
            
	        lmscons.TriggerManagementAssign.AssignResult assignResult = (lmscons.TriggerManagementAssign.AssignResult)invokeResult.get('Result'); 
            
            if (!assignResult.status){
                throw new MobileHelper.MobileException('Error with enrollment. Error code: ' + assignResult.errorCode);
            }
            
	    } catch(Exception e){
	        throw new MobileHelper.MobileException('Error with enrollment. Error: ' + e.getMessage());        
	    }
	    
	    return true;
	}
}