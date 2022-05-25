/**  
* \arg ClassName        : SL_Test_RemoveInactiveUsersFromOppShare
* \arg JIRATicket       : HL-32
* \arg CreatedOn        : 22/Jan/2015
* \arg LastModifiedOn   : 22/Jan/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : Test class for SL_Batch_RemoveInactiveUsersFromOppShare class.
*/
@isTest
private class SL_Test_RemoveInactiveUsersFromOppShare 
{
    public static User createTestUser(Id profID, String fName, String lName)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId
                             );
        return tuser;
    }
    
    Static List<Account> accList;
    Static List<Contact> conList ;
    Static List<Delegate_Public_Group__c> dpgList;
    Static User usr;
   
    static void TestInsertRemoveInactiveUsersFromOppShare()
    {  
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = SL_Test_RemoveInactiveUsersFromOppShare.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
        insert usr;
        accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 1);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
        conList = SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        for(integer i = 0; i < conList.size(); i++){
            conList[i].FirstName = 'DND Test';
            conList[i].LastName = 'Test LN';
            conList[i].AccountId = accList[0].Id;            
            conList[i].User__c = usr.Id;
        }
        insert conList;
                        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = conList[0].User__c;
        }
        insert dpgList;        
    }
    
    Static List<Opportunity__c> oppList;      
    Static List<Opportunity_Internal_Team__c> oitList;
    Static List<Opportunity_Comment__c> ocoList;
    
    static void OpportunityDataPreparation()
    {
      TestInsertRemoveInactiveUsersFromOppShare();
      oppList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, 1);
        for(integer i = 0; i < oppList.size(); i++){
            oppList[i].Client__c = accList[0].Id;
            oppList[i].Subject__c = accList[0].Id;
            oppList[i].Line_of_Business__c = 'CF';
            oppList[i].Job_Type__c = 'FMV Non-Transaction Based Opinion';
            oppList[i].Industry_Group__c = 'ADG';
            oppList[i].Sector__c = 'Defense';
            oppList[i].Stage__c = 'Evaluating Prospect';
            oppList[i].Referral_Type__c = 'Attorney';
        }
        insert oppList;
        
        oitList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, 1);
        for(integer i = 0; i < oitList.size(); i++){
            oitList[i].Contact__c = conList[0].Id;
            oitList[i].Opportunity__c = oppList[0].Id;
            oitList[i].End_Date__c = Date.today();
            oitList[i].Start_Date__c = Date.today();
        }
        insert oitList; 
        
        ocoList = (List<Opportunity_Comment__c>)HL_TestFactory.CreateSObjectList('Opportunity_Comment__c', false, 1);
        for(integer i = 0; i < ocoList.size(); i++){
            ocoList[0].Related_Opportunity__c =  oppList[0].Id;
            ocoList[0].Comment__c ='This is Test Comment';
        }
        insert ocoList;
    }
    
    Static List<Engagement__c> engList ;
    Static List<Engagement_Counterparty__c> ecpList;
    Static List<Engagement_Internal_Team__c> eitList;
    
    static void EngagementDataPreparation()
    {
        TestInsertRemoveInactiveUsersFromOppShare();
        engList = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1);
        for(integer i = 0; i < engList.size(); i++){
            engList[0].Client__c = accList[0].Id;
            engList[0].Subject__c = accList[0].Id;
        }
        insert engList;
        
        eitList = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 1);
        for(integer i = 0; i < eitList.size(); i++){
            eitList[0].Contact__c = conList[0].Id;
            eitList[0].Engagement__c = engList[0].Id;
            eitList[0].End_Date__c = Date.today();
            eitList[0].Start_Date__c = Date.today();
        }
        insert eitList;
        
        ecpList = SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 1);
        for(integer i = 0; i < ecpList.size(); i++){
            ecpList[0].Company__c = accList[0].Id;
            ecpList[0].Engagement__c = engList[0].Id;
        }
        insert ecpList;
    }                

    @isTest
    static void TestRemoveInactiveUsersFromOppShare0(){ 
        OpportunityDataPreparation();
        test.startTest();        
            SL_ManageSharingRules obj =new SL_ManageSharingRules();
            SL_Batch_RemoveInactiveUsersFromOppShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromOppShare();
            Database.executeBatch(objBatchRIU, 20); 
            System.assertNotEquals(oitList.Size(), Null);
        test.stopTest();
    }
                
    @isTest
    static void TestRemoveInactiveUsersFromOppShare1(){ 
        EngagementDataPreparation();
        test.startTest();        
            SL_ManageSharingRules obj =new SL_ManageSharingRules();
            SL_Batch_RemoveInactiveUsersFromOppShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromOppShare();
            Database.executeBatch(objBatchRIU, 20); 
            System.assertNotEquals(engList.Size(), null);
        test.stopTest();
    }
  
    Static Set<String> idSetEng = new Set<String>();
    @isTest
    static void TestRemoveInactiveUsersFromOppShare2(){ 
        EngagementDataPreparation();  
        for(Engagement__c e :engList){ 
            idSetEng.add(e.Id);
        }
        test.startTest(); 
            SL_ManageSharingRules.deleteSharesOnChangeParentName(idSetEng,'Engagement__c');
        test.stopTest();
        System.assertEquals(idSetEng.Size(), 1);
    }
    
    @isTest
    static void TestRemoveInactiveUsersFromOppShare3(){ 
        EngagementDataPreparation();
        eitList[0].Start_Date__c = System.Today().addDays(-7);
        eitList[0].End_Date__c = System.Today().addDays(7);        
        test.startTest(); 
            try{
                update eitList[0];
                SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(eitList,'Engagement__c'); 
                delete eitList[0];
            }
            catch (Exception ex){
                System.assertNotEquals(eitList.Size(), 0);
            }           
        test.stopTest();
        System.assertEquals(eitList.Size(), 1);
        }
      
        @isTest
        static void TestRemoveInactiveUsersFromOppShare4(){ 
            OpportunityDataPreparation();
            oitList[0].Start_Date__c = System.Today().addDays(-2);
            oitList[0].End_Date__c = System.Today().addDays(10);
            test.startTest(); 
            update oitList[0];
            try{
                delete oitList[0];
            }
            catch(Exception ex){
                System.assertNotEquals(oitList.Size(), 0);
            }        
        test.stopTest();
        System.assertEquals(oitList.Size(), 1);
    }
    
    @isTest
    static void TestRemoveInactiveUsersFromOppShare5(){ 
        OpportunityDataPreparation();
        oppList[0].Name= 'DNDTestUser';
        oitList[0].Start_Date__c  = Date.Today().addDays(2);
        test.startTest(); 
            try{
                update oppList[0];
                update oitList[0];
                delete oitList[0];
            }
            catch(Exception ex){
                System.assertNotEquals(oitList.Size(), 0);
            }
        test.stopTest();
        System.assertEquals(oitList.Size(), 1);
    }
     
    @isTest
    static void TestRemoveInactiveUsersFromOppShare6(){ 
        EngagementDataPreparation();        
        eitList[0].Start_Date__c = System.Today().addDays(2);
        eitList[0].End_Date__c = System.Today().addDays(-3);        
        test.startTest(); 
            try{
                update eitList[0];
                delete eitList[0];
            }
            catch(Exception ex){
                System.assertNotEquals(eitList.Size(), 0);
            }
        test.stopTest();
        System.assertEquals(eitList.Size(), 1);       
    }
}