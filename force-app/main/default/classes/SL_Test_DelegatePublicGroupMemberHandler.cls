/**  
* \arg ClassName		: SL_Test_DelegatePublicGroupMemberHandler
* \arg JIRATicket		: HL-30
* \arg CreatedOn		: 07/OCT/2014
* \arg LastModifiedOn	: 07/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Test class for SL_DelegatePublicGroupMemberHandler class
*/
@isTest
private class SL_Test_DelegatePublicGroupMemberHandler 
{
    static testMethod void Test_DelegatePublicGroupMemberHandler() 
    {
    	Profile objProfile = [SELECT Id,
    								 Name 
    							FROM Profile
    						   WHERE Name = 'Solution Manager'];	
    	
    	Integer i=0;
    	List<User> lstUser = new List<User>();
    	For(User objUser : SL_TestSetupUtils.CreateUser('User',2))
    	{
    		objUser.Lastname = 'User';
    		objUser.Email = 'tuser@yahoo.in';
    		objUser.Username = i+'test@hl2.com';
    		objUser.ProfileId = objProfile.Id;
    		objUser.Alias = 'tuser';
    		objUser.TimeZoneSidKey = 'GMT';
    		objUser.LocaleSidKey = 'en_US';
    		objUser.EmailEncodingKey = 'ISO-8859-1';
    		objUser.LanguageLocaleKey = 'en_US';
    		objUser.Has_Delegates__c = false;
    		lstUser.add(objUser);
    		i++;
    	}
    	insert lstUser;
        
        List<Group> lstGroup = new List<Group>{
        									   new Group(DoesIncludeBosses = false, Name='Test-01' ,Type ='Regular'),
        									   new Group(DoesIncludeBosses = false, Name='Test-02' ,Type ='Regular')};
        
        insert lstGroup;
        
        i=0;
        List<Delegate_Public_Group__c> lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 2))
        {
        	objDPG.Banker__c = lstUser[i].Id;
        	objDPG.Public_Group_ID__c = lstGroup[i].Id;
        	lstDPG.add(objDPG);
        	i++;
        }
        insert lstDPG;
        
        List<Delegate_Public_Group_Member__c> lstDPGM = new List<Delegate_Public_Group_Member__c>();
        For(Delegate_Public_Group_Member__c objDPGM : SL_TestSetupUtils.createDPGM('Delegate_Public_Group_Member__c', 1))
        {
        	objDPGM.Delegate__c = lstUser[0].Id;
        	objDPGM.Delegate_Public_Group__c = lstDPG[0].Id;
        	lstDPGM.add(objDPGM);
        }
        insert lstDPGM;

		lstDPGM[0].Delegate__c = lstUser[1].Id;
        update lstDPGM[0];        
        
        System.runAs (new User(Id = UserInfo.getUserId())) 
        {
        	Test.startTest();
        	delete lstDPGM[0];
        	Test.stopTest();
		}
    }
}