@isTest
private class EnrollHelperTest {

	private static testMethod void test() {
	    
	    Boolean enrollResult;
	    
	    try{
	        enrollResult = EnrollHelper.enroll('00590000002F2Rt', MobileConstants.MODULE_TYPE);
	        System.Assert(!enrollResult, '');
	    } catch(Exception e){
	        System.Assert(e instanceof MobileHelper.MobileException, '');
	    }
            
	}

}