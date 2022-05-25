/**  
* \arg ClassName		: SL_Test_EngagementCounterpartyHandler
* \arg JIRATicket		: HL-31
* \arg CreatedOn		: 19/Jan/2014
* \arg LastModifiedOn	: 19/Jan/2014
* \arg CreatededBy		: Edward Rivera
* \arg ModifiedBy		: -
* \arg Description		: Test class for SL_EngagementCounterpartyHandler class
*/
@isTest
private class SL_Test_EngagementCounterpartyHandler 
{
    static testMethod void Test_EngagementCounterpartyHandler() 
    {
        Id directAssociation = [SELECT Id From RecordType WHERE DeveloperName='Direct_Association' AND SobjectType='SL_Convert__Object_Relationship__c' LIMIT 1].Id;
        Id relatedList = [SELECT Id From RecordType WHERE DeveloperName='Related_List' AND SobjectType='SL_Convert__Object_Relationship__c' LIMIT 1].Id;
        Id reference = [SELECT Id From RecordType WHERE DeveloperName='Reference' AND SobjectType='SL_Convert__Field_Mapping__c' LIMIT 1].Id;
        List<SL_Convert__Custom_Mapping__c> custMap = new List<SL_Convert__Custom_Mapping__c>{new SL_Convert__Custom_Mapping__c(SL_Convert__Sobject_API_Name__c='Opportunity__c')};
        insert custMap;
        List <SL_Convert__Object_Relationship__c> objectRels = new List <SL_Convert__Object_Relationship__c>();
        objectRels.add(new SL_Convert__Object_Relationship__c
            (Name='a',
             RecordTypeId=directAssociation,
             SL_Convert__Order__c=1,
             SL_Convert__Custom_Mapping__c=custMap[0].Id,
             SL_Convert__Context_Object_API__c='Opportunity__c',
             SL_Convert__Target_Object_API__c='Engagement__c',
             SL_Convert__Context_Relationship_Id__c='id',
             SL_Convert__Target_Relationship_Id__c='Opportunity__c'));
        insert objectRels;
        objectRels=new List <SL_Convert__Object_Relationship__c>{new SL_Convert__Object_Relationship__c
            (Name='b',
             RecordTypeId=relatedList,
             SL_Convert__Order__c=2,
             SL_Convert__Custom_Mapping__c=custMap[0].Id,
             SL_Convert__Context_Object_API__c='Opportunity__c',
             SL_Convert__Target_Object_API__c='Engagement_Counterparty__c',
             SL_Convert__Context_Relationship_Id__c='Opportunity_Counterparty__c',
             SL_Convert__Target_Relationship_Id__c='Engagement__r.Opportunity__c',
             SL_Convert__Related_Record_Parent_Id__c='Opportunity__c',
             SL_Convert__Parent_Object_Relationship__c=objectRels[0].id)};
        insert objectRels;
       List <SL_Convert__Object_Relationship__c> objectRelsCont=new List <SL_Convert__Object_Relationship__c>{new SL_Convert__Object_Relationship__c
            (Name='c',
             RecordTypeId=relatedList,
             SL_Convert__Order__c=3,
             SL_Convert__Custom_Mapping__c=custMap[0].Id,
             SL_Convert__Context_Object_API__c='Opportunity_Counterparty_Contact__c',
             SL_Convert__Target_Object_API__c='Engagement_Counterparty_Contact__c',
             SL_Convert__Context_Relationship_Id__c='Opportunity_Counterparty_Contact__c',
             SL_Convert__Target_Relationship_Id__c='Engagement__r.Opportunity__c',
             SL_Convert__Related_Record_Parent_Id__c='Counterparty__r.Opportunity__c',
             SL_Convert__Parent_Object_Relationship__c=objectRels[0].id)};
        insert objectRelsCont;

        List <SL_Convert__Field_Mapping__c> fieldMappings = new List <SL_Convert__Field_Mapping__c>();
        fieldMappings.add(new SL_Convert__Field_Mapping__c(
            SL_Convert__Object_Relationship__c=objectRelsCont[0].id,
            RecordTypeId=reference,
            SL_Convert__Active__c=true,
            SL_Convert__Context_Field_Name__c='Contact__c',
            SL_Convert__Target_Field_Name__c='Contact__c'
            ));
                
        List <SL_Convert__Object_Relationship__c> objectRelsComs =new List <SL_Convert__Object_Relationship__c>{new SL_Convert__Object_Relationship__c
            (Name='d',
             RecordTypeId=relatedList,
             SL_Convert__Order__c=4,
             SL_Convert__Custom_Mapping__c=custMap[0].Id,
             SL_Convert__Context_Object_API__c='Opportunity_Counterparty__c',
             SL_Convert__Target_Object_API__c='Engagement_Counterparty_Comment__c',
             SL_Convert__Context_Relationship_Id__c='Opportunity_Counterparty_Comment__c',
             SL_Convert__Target_Relationship_Id__c='Engagement__r.Opportunity__c',
             SL_Convert__Related_Record_Parent_Id__c='Related_Opportunity_Counterparty__c',
             SL_Convert__Parent_Object_Relationship__c=objectRels[0].id)};
        insert objectRelsComs;

        fieldMappings.add(new SL_Convert__Field_Mapping__c(
            SL_Convert__Object_Relationship__c=objectRelsComs[0].id,
            RecordTypeId=reference,
            SL_Convert__Active__c=true,
            SL_Convert__Context_Field_Name__c='Comment__c',
            SL_Convert__Target_Field_Name__c='Comment__c'
            ));
        
        
        fieldMappings.add(new SL_Convert__Field_Mapping__c(
            SL_Convert__Object_Relationship__c=objectRelsComs[0].id,
            RecordTypeId=reference,
            SL_Convert__Active__c=true,           
            SL_Convert__Context_Field_Name__c='Comment_Type__c',
            SL_Convert__Target_Field_Name__c='Comment_Type__c'
            ));
        
        
        fieldMappings.add(new SL_Convert__Field_Mapping__c(
            SL_Convert__Object_Relationship__c=objectRelsComs[0].id,
            RecordTypeId=reference,
            SL_Convert__Active__c=true,
            SL_Convert__Context_Field_Name__c='Line_of_Business__c',
            SL_Convert__Target_Field_Name__c='Line_of_Business__c'
            ));
        insert fieldMappings;
        
    	Profile objProfile = [SELECT Id,
    								 Name 
    							FROM Profile
    						   WHERE Name = 'Solution Manager'];	
    	
    	List<User> lstUser = new List<User>();
    	For(User objUser : SL_TestSetupUtils.CreateUser('User',1))
    	{
    		objUser.Lastname = 'User';
    		objUser.Email = 'tuser@yahoo.in';
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
    	
    	List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 1);
		insert lstAccount;
    	
    	List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE ))
        {
            objContact.AccountId = lstAccount[0].Id;
            objContact.User__c = lstUser[0].Id;
            lstContactHL.add(objContact);
        }
        insert lstContactHL;

        List<Contact> lstContactExternal = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 4, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT ))
        {
            objContact.AccountId = lstAccount[0].Id;
            lstContactExternal.add(objContact);
        }
        insert lstContactExternal;
    	
        List<Opportunity__c> lstOpp = new List<Opportunity__c>();
        For(Opportunity__c objOpp : SL_TestSetupUtils.CreateOpp('Opportunity__c', 1))
        {
        	objOpp.Client__c = lstAccount[0].Id;
        	objOpp.Subject__c = lstAccount[0].Id;
			objOpp.Beneficial_Owner_Control_Person_form__c = 'No';
        	lstOpp.add(objOpp);
        }
        insert lstOpp;

        List<Opportunity_Counterparty__c> lstOC = new List<Opportunity_Counterparty__c>();
        For(Opportunity_Counterparty__c objOC : SL_TestSetupUtils.CreateOC('Opportunity_Counterparty__c', 1))
        {
            objOC.Company__c = lstAccount[0].Id;
            objOC.Opportunity__c = lstOpp[0].Id;
            lstOC.add(objOC);
        }
        insert lstOC;
		
        Integer i = 0;
        List<Opportunity_Counterparty_Contact__c> lstOCC = new List<Opportunity_Counterparty_Contact__c>();
        For(Opportunity_Counterparty_Contact__c objOCC : SL_TestSetupUtils.CreateOCC('Opportunity_Counterparty_Contact__c', 4))
        {
            objOCC.Contact__c = lstContactExternal[i].Id;
            objOCC.Counterparty__c = lstOC[0].Id;
            lstOCC.add(objOCC);
            i++;
        }
        insert lstOCC;
        
        i = 0;
        List<Opportunity_Counterparty_Comment__c> lstOCCms = new List<Opportunity_Counterparty_Comment__c>();
        For(Opportunity_Counterparty_Comment__c objOCCms : SL_TestSetupUtils.CreateOCCm('Opportunity_Counterparty_Comment__c', 4))
        {
            objOCCms.Comment__c = 'test comment'+i;
            objOCCms.Comment_Type__c = 'External';
            objOCCms.Related_Opportunity_Counterparty__c = lstOC[0].Id;
            lstOCCms.add(objOCCms);
            i++;
        }
        insert lstOCCms;

        List<Engagement__c> lstEngagement = new List<Engagement__c>();
        For(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 1))
        {
        	objEngagement.Client__c = lstAccount[0].Id;
        	objEngagement.Subject__c = lstAccount[0].Id;
        	objEngagement.Opportunity__c = lstOpp[0].Id;
        	lstEngagement.add(objEngagement);
        }
        insert lstEngagement;

        List<Engagement_Counterparty__c> lstEC = new List<Engagement_Counterparty__c>();
        For(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 1))
        {
        	objEC.Company__c = lstAccount[0].Id;
        	objEC.Engagement__c = lstEngagement[0].Id;
        	lstEC.add(objEC);
        }
        Test.startTest();
        insert lstEC;
        Test.stopTest();

        List<Engagement_Counterparty_Contact__c> lstECC = [Select ID From Engagement_Counterparty_Contact__c];
        //System.assertEquals(4, lstECC.size());
    }
}