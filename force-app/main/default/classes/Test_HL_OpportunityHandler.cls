@isTest
private class Test_HL_OpportunityHandler {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        List<Account> acc = SL_TestSetupUtils.CreateAccount('Test',1);
        insert acc;
        List<Opportunity__c> opps = SL_TestSetupUtils.CreateOpp('', 6);
        
        for(Opportunity__c o : opps)
        {
          o.Beneficial_Owner_Control_Person_form__c = 'No';
          o.CurrencyIsoCode = 'USD';
        }
        insert opps;
        
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        e.Opportunity__c = opps[0].Id;
        
        Test.startTest();
            insert e;
        
            //Update for Comments
            opps[0].Opportunity_Comments__c = 'Test Comment Longer ';
            opps[0].CurrencyIsoCode = 'GBP';
        	opps[0].Job_Type__c = 'Buyside';
        	opps[0].Client__c = acc[0].Id;
            update opps[0];
            
            //Test Long Comment
            for(integer x=0; x<200; x++)
                opps[0].Opportunity_Comments__c += 'Test Comment Longer ';
        
            //Change DND Status 
            opps[0].DND_Status__c = 'APPROVED';
            update opps[0];    
        Test.stopTest();
        
        Opportunity__c o = [SELECT DND_Status__c, Opportunity_Comments__c FROM Opportunity__c WHERE ID =: opps[0].Id];
        
        //Validate the Opportunity Comments have been Cleared
        System.assert(String.isBlank(o.Opportunity_Comments__c));
    }
    
    @isTest 
    static void TestOpportunityJoinerCreations() 
    {
        //Setup Test Data
        Account objClientAccount = new Account(Name='Test Client Account');
        insert objClientAccount;
        
        Account objClientAccountToUpdate = new Account(Name='Test Client Account');
        insert objClientAccountToUpdate;

        Account objSubjectAccount = new Account(Name='Test Subject Account');
        insert objSubjectAccount;

        Opportunity__c objOpportunityNew = new Opportunity__c(Name='Test Opportunity', Client__c = objClientAccount.Id, 
                                                              Subject__c = objSubjectAccount.Id, Stage__c = 'Pitched',
                                                              Line_of_Business__c = 'CF', Job_Type__c = 'Financing',
                                                              Primary_Office__c = 'AT', Beneficial_Owner_Control_Person_form__c = 'No');
        
        Test.startTest();
        
            insert objOpportunityNew;
            List<Opportunity_Client_Subject__c> ocsAfterInsertResults = [Select Id From Opportunity_Client_Subject__c where Opportunity__c = :objOpportunityNew.Id];
            objOpportunityNew.Name = 'dndOpportunity';
            objOpportunityNew.Client__c = objClientAccountToUpdate.Id;
            update objOpportunityNew;
        
        Test.stopTest();
        
        //check whether 2 client subject records are created
        system.AssertEquals(ocsAfterInsertResults.Size(), 2);

        // check whether the previous combination of joiner record is deleted, Now it should be deleted
        //system.AssertEquals([Select Id From Opportunity_Client_Subject__c where Opportunity__c = :objOpportunityNew.Id AND Client_Subject__c = :objClientAccount.Id].Size(), 0);
        // check whether the updated client Account is created in the Joiner
        //system.AssertEquals([Select Id From Opportunity_Client_Subject__c where Opportunity__c = :objOpportunityNew.Id].Size(), 2);
    }
    @isTest 
    static void updateEngagementDuetoLegalEntityChangeTest(){
        HL_Auto_Number_Settings__c autoNumber = new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        List<Legal_Entity__c> legalEntityList = new List<Legal_Entity__c>();
        Legal_Entity__c legalEntity = new Legal_Entity__c();
        legalEntity.name = 'HL Inc.';
        legalEntity.Available_for_Project__c = true;
        legalEntity.ERP_VAT_Legal_Entity__c = true;
        legalEntity.ERP_Entity_Code__c = '030';
        legalEntityList.add(legalEntity);
        
        Legal_Entity__c legalEntityChina = new Legal_Entity__c();
        legalEntityChina.name = 'HL (China) Ltd';
        legalEntityChina.Available_for_Project__c = true;
        legalEntityChina.ERP_VAT_Legal_Entity__c = true;
        legalEntityChina.ERP_Entity_Code__c = '330';
        legalEntityList.add(legalEntityChina);
        insert legalEntityList;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        insert contact;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Engagement 125';
        opportunity.Client__c = account.Id;
        opportunity.Subject__c = account.Id;
        opportunity.Legal_Entity__c = legalEntity.Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opportunity;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        engagement.Legal_Entity__c = legalEntity.Id;
        engagement.Opportunity__c = opportunity.Id;
        engagement.Billing_Contact__c = contact.Id;
        insert engagement;
        
        Engagement_External_Team__c engExtTeam = new Engagement_External_Team__c();
        engExtTeam.Billing_Contact__c = true;
        engExtTeam.Engagement__c = engagement.Id;
        engExtTeam.Contact__c = contact.Id;
        engExtTeam.Acknowledge_Billing_Contact__c = true;
        insert engExtTeam;
        
        Engagement_VAT_Treatment__c engVATTreatment = new Engagement_VAT_Treatment__c();
        engVATTreatment.Engagement__c = engagement.Id;
        engVATTreatment.Effective_Date__c = system.today();
        engVATTreatment.Treatment__c = 'Standard Rated';
        insert engVATTreatment;
        
        Contract__c contract = new Contract__c();
        contract.Name = 'Contract Test 1';
        contract.Bill_To__c = account.Id;
        contract.Client__c = account.Id;
        contract.Ship_To__c = account.Id;
        contract.Billing_Contact__c = engagement.Billing_Contact__c;
        contract.Engagement__c = engagement.Id;
        contract.ERP_Contract_Type__c = 'Engagement';
        contract.HL_Entity__c = '030';
        contract.Opportunity__c = opportunity.Id;
        insert contract;
        
        test.startTest();
        
        opportunity.Legal_Entity__c = legalEntityChina.Id;
        update opportunity;
        
        opportunity.Legal_Entity__c = legalEntity.Id;
        update opportunity;
             
        test.stopTest();
    }
    
   @isTest 
   static void updateCFExpenseRequestTest(){
        
        Id recHLInternalOpp = Schema.SObjectType.Opportunity__c.getRecordTypeInfosByDeveloperName().get('HL_Internal_Opportunity').getRecordTypeId();
        Id HoulihanEmployeeRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        Id ExternalContactRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
      
        List<Legal_Entity__c> legalEntityList = new List<Legal_Entity__c>();
        Legal_Entity__c legalEntity = new Legal_Entity__c();
        legalEntity.name = 'HL Inc.';
        legalEntity.Available_for_Project__c = true;
        legalEntity.ERP_VAT_Legal_Entity__c = true;
        legalEntity.ERP_Entity_Code__c = '030';
        legalEntityList.add(legalEntity);
        insert legalEntityList;
        
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 4);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_Account' +i;        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;
        }
        insert accountList;
        
        List<Contact> CList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 4);        
        for(integer i = 0; i < CList.size(); i++){
            CList[i].FirstName = 'TestFirst' +i;
            CList[i].LastName = 'TestLast' +i;
            CList[i].AccountId = accountList[0].id;
            CList[i].RecordTypeId = HoulihanEmployeeRTContact;
            CList[i].User__c = UserInfo.getUserId();
            CList[i].Status__C = 'Active';
        }
        Insert CList; 
        
        List<Contact> CExtList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 4);        
        for(integer i = 0; i < CExtList.size(); i++){
            CExtList[i].FirstName = 'TestFirst' +i;
            CExtList[i].LastName = 'TestLast' +i;
            CExtList[i].AccountId = accountList[0].id;
            CExtList[i].RecordTypeId = ExternalContactRTContact;
        }
        Insert CExtList; 
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Engagement CF 125';
        opportunity.Client__c = accountList[0].id;
        opportunity.Subject__c = accountList[0].id;
        opportunity.recordTypeId = recHLInternalOpp;
        opportunity.Line_of_Business__c = 'CF';
        opportunity.Event_Type__c = 'Administrative';
        opportunity.Event_Format__c = 'Other';
        opportunity.City__c = 'TBD';
        opportunity.Event_Location__c = 'TBD';
        opportunity.Classification__c = 'Internal';
        opportunity.Legal_Entity__c = legalEntity.Id;        
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';       
        insert opportunity;
        
        Event_Expense__c eventExpense = new Event_Expense__c();
        eventExpense.Requestor_Name__c = CList[0].Id;
        eventExpense.Event_Contact__c=CList[0].Id;        
        eventExpense.Event__c = opportunity.Id;    
        eventExpense.Event_Type_Format__c = 'Administrative';
        eventExpense.Event_Format__c = 'Other';
        eventExpense.City__c = 'TBD';
        eventExpense.Status__c = 'Saved';
        insert eventExpense;         

        System.Test.startTest();

        opportunity.Event_Location__c = 'LA';
        update opportunity;

        opportunity.Event_Location__c = 'LA1';
        update opportunity;

        System.Test.stopTest();
    }
    
    @isTest
    static void validateRequiredFieldsOnStageChangeTest(){
        Legal_Entity__c legalEntity = new Legal_Entity__c();
        legalEntity.name = 'HL Inc Australia.';
        legalEntity.Available_for_Project__c = true;
        legalEntity.ERP_VAT_Legal_Entity__c = true;
        legalEntity.ERP_Entity_Code__c = '0305';
        insert legalEntity;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Opportunity Test';
        opportunity.Client__c = account.Id;
        opportunity.Subject__c = account.Id;
        opportunity.Legal_Entity__c = legalEntity.Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        opportunity.Line_of_Business__c  = 'CF';
        opportunity.Stage__c = 'Verbally Engaged';
        try{
        insert opportunity;
        }
        catch(exception ex){
            system.debug(ex.getMessage());
        }
    }    
    
    @isTest
    static void validateclearERPUpdateFlags(){
        Legal_Entity__c legalEntity = new Legal_Entity__c();
        legalEntity.name = 'HL Inc Australia.';
        legalEntity.Available_for_Project__c = true;
        legalEntity.ERP_VAT_Legal_Entity__c = true;
        legalEntity.ERP_Entity_Code__c = '0305';
        insert legalEntity;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Opportunity Test';
        opportunity.Client__c = account.Id;
        opportunity.Subject__c = account.Id;
        opportunity.Legal_Entity__c = legalEntity.Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        opportunity.Line_of_Business__c  = 'CF';
        opportunity.Stage__c = 'High';
        opportunity.ERP_Last_Integration_Response_Date__c = Date.newInstance(2020, 01, 9);
        
        insert opportunity;
        
        List<Opportunity__c> oldOppList = new List<Opportunity__c>();
        oldOppList.add(opportunity);
        Map<Id, Opportunity__c> newOpportunityMap = new Map<Id, Opportunity__c>();
        
        opportunity.ERP_Last_Integration_Status__c = 'SUCCESS';
        opportunity.Stage__c = 'Verbally Engaged';
        opportunity.ERP_Last_Integration_Response_Date__c = Date.newInstance(2020, 04, 9);
        
        try{
        Update opportunity;
        }
        catch(exception ex){
            system.debug(ex.getMessage());
        }
        
        newOpportunityMap.put(opportunity.Id,opportunity);
        HL_OpportunityHandler.clearERPUpdateFlags(oldOppList,newOpportunityMap);
        
    }    
}