/**  
* \arg ClassName		: SL_Test_DelegatePublicGroupHandler
* \arg JIRATicket		: HL-30
* \arg CreatedOn		: 07/OCT/2014
* \arg LastModifiedOn	: 07/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Test class for SL_DelegatePublicGroupHandler class
*/
@isTest
private class SL_Test_DelegatePublicGroupHandler 
{
    static testMethod void Test_DelegatePublicGroupHandler() 
    {
        Profile objProfile = [SELECT Id,
    								 Name 
    							FROM Profile
    						   WHERE Name = 'Solution Manager'];	
    	
    	List<User> lstUser = new List<User>();
    	For(User objUser : SL_TestSetupUtils.CreateUser('User',1))
    	{
    		objUser.Lastname = 'User';
    		objUser.Email = 'tusertusertusertusertusertuser@yahoo.in';
    		objUser.Username = 'test@hl2.com';
    		objUser.ProfileId = objProfile.Id;
    		objUser.Alias = 'tuser';
    		objUser.TimeZoneSidKey = 'GMT';
    		objUser.LocaleSidKey = 'en_US';
    		objUser.EmailEncodingKey = 'ISO-8859-1';
    		objUser.LanguageLocaleKey = 'en_US';
    		objUser.Has_Delegates__c = false;
    		lstUser.add(objUser);
    	}
    	insert lstUser;
        
        List<Delegate_Public_Group__c> lstDPG1 = [SELECT Id
        						  			  	    FROM Delegate_Public_Group__c];
        System.assertEquals(lstDPG1.size(),0);
        
        List<Delegate_Public_Group__c> lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 1))
        {
        	objDPG.Banker__c = lstUser[0].Id;
        	lstDPG.add(objDPG);
        }
        insert lstDPG;
        
        List<Delegate_Public_Group__c> lstDPG2 = [SELECT Id,
        												 Banker__c,
        												 Public_Group_ID__c
        						  			  	    FROM Delegate_Public_Group__c];
        
		System.assertEquals(lstDPG2[0].Public_Group_ID__c != null, true);
        
        User objUser = [SELECT Id,
        					   Email
        				  FROM User
        				 WHERE Id =: lstUser[0].Id];
        String strTruancatedEmail = (String.valueOf(objUser.Email).split('@')[0].length() > 21) 
		                                ? String.valueOf(objUser.Email).split('@')[0].substring(0, 21)
		                                : String.valueOf(objUser.Email).split('@')[0];
        
        List<Group> lstGroup = [SELECT Id,
        							   Name
        						  FROM Group
        						 WHERE Name =: strTruancatedEmail+'-'+objUser.Id] ;
        System.assertEquals(lstGroup.size(),1);
        
        System.runAs (new User(Id = UserInfo.getUserId())) 
        {
        	Test.startTest();
        	delete lstDPG[0];
        	Test.stopTest();
		}
    }
}