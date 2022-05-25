/**  
* \arg ClassName		: SL_Test_UserHandler
* \arg JIRATicket		: HL-30
* \arg CreatedOn		: 06/OCT/2014
* \arg LastModifiedOn	: 06/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Test class for SL_UserHandler class
*/
@isTest
private class SL_Test_UserHandler 
{
    static testMethod void Test_UserHandler() 
    {
    	Profile objProfile = [SELECT Id,
    								 Name 
    							FROM Profile
    						   WHERE Name = 'Solution Manager'];	
    	
    	Boolean isDelegate = false;
    	List<User> lstUser = new List<User>();
    	For(User objUser : SL_TestSetupUtils.CreateUser('User',2))
    	{
    		objUser.Lastname = 'User'+String.valueOf(Date.today());
    		objUser.Email = 'tuser@yahoo.in';
    		objUser.Username = isDelegate+'test@hl2.com';
    		objUser.ProfileId = objProfile.Id;
    		objUser.Alias = 'tuser';
    		objUser.TimeZoneSidKey = 'GMT';
    		objUser.LocaleSidKey = 'en_US';
    		objUser.EmailEncodingKey = 'ISO-8859-1';
    		objUser.LanguageLocaleKey = 'en_US';
    		objUser.Has_Delegates__c = isDelegate;
    		lstUser.add(objUser);
    		isDelegate = true;
    	}
    	
    	insert lstUser;
    	
    	User objUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
 		System.RunAs(objUser)
		{
			Test.startTest();
			lstUser[0].Has_Delegates__c = true;
    		update lstUser[0];
			Test.stopTest();
		}
	}
}