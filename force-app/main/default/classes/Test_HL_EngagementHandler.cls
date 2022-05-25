@isTest
private class Test_HL_EngagementHandler {
    
    private static testmethod void TestFVA_StageUpdates(){
        Account clientAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert clientAccount;
        
        Account subjectAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subjectAccount;
        
        //FVA Engagements
        List<Engagement__c> eFVA_List = SL_TestSetupUtils.CreateEngagement('', 2);
        for(Engagement__c e : eFVA_List){
            e.Name='Test FVA Engagement';
            e.Client__c = clientAccount.Id;
            e.Subject__c = subjectAccount.Id;
            e.Line_of_Business__c = 'FVA';
            e.Job_Type__c = 'FMV Transaction Based Opinion';
            e.Primary_Office__c = 'NY';
            e.Total_Estimated_Fee__c = 100000;
            e.RecordTypeId = '012i0000001NDwh';
        }
        //Create one with 0% completed to Update to 50%
        Engagement__c eFVA_Stage50 = eFVA_List[0];
        eFVA_Stage50.Stage__c = 'Retained';
        
        //Create one with 75% completed to Update to 100%
        Engagement__c eFVA_Stage100 = eFVA_List[1];
        eFVA_Stage100.Stage__c = 'Opinion Report';
        
        insert eFVA_Stage50;
        insert eFVA_Stage100;
        
        Test.startTest();
        
        //Change the Stage to 50% Complete
        eFVA_Stage50.Stage__c = 'Performing Analysis';
        update eFVA_Stage50;
        
        //Change the Stage to 100% Complete
        eFVA_Stage100.Final_Report_Sent_Date__c = Date.today();
        eFVA_Stage100.Stage__c = 'Bill/File';
        update eFVA_Stage100;
        
        Test.stopTest();
        
        //Validate the Period Accrued Fees were updated appropriately
        eFVA_Stage50 = [SELECT Total_Estimated_Fee__c, Period_Accrued_Fees__c FROM Engagement__c WHERE Id=:eFVA_Stage50.Id];
        System.assertEquals(eFVA_Stage50.Total_Estimated_Fee__c / 2, eFVA_Stage50.Period_Accrued_Fees__c);
        eFVA_Stage100 = [SELECT Total_Estimated_Fee__c, Period_Accrued_Fees__c FROM Engagement__c WHERE Id=:eFVA_Stage100.Id];
        System.assertEquals(eFVA_Stage100.Total_Estimated_Fee__c, eFVA_Stage100.Period_Accrued_Fees__c);
    }
    
    private static testmethod void TestOnBeforeInsert(){
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        
        Test.startTest();
        
        HL_EngagementHandler handler = new HL_EngagementHandler(false, 1);
        insert e;
        
        Test.stopTest();
        
        System.assert(!String.isBlank(e.Id));
    }
    
    private static testmethod void TestOnBeforeUpdate(){
        Exchange_Rate__c ex = new Exchange_Rate__c(CurrencyIsoCode = 'AUD');
        insert ex;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert e;
        List<Engagement__c> oldEngagementList = [SELECT CurrencyIsoCode, Engagement_Comment__c, Job_Type__c FROM Engagement__c WHERE Id =: e.Id];
        Map<Id, Engagement__c> oldEngagementMap = new Map<Id, Engagement__c>();
        oldEngagementMap.put(oldEngagementList[0].Id, oldEngagementList[0]);
        
        Engagement__c newEng = e.Clone();
        newEng.Engagement_Comment__c = 'Test Comment';
        newEng.CurrencyIsoCode = 'AUD';
        newEng.Engagement_Number__c = '123456';
        insert newEng;
        List<Engagement__c> newEngagementList = new List<Engagement__c>{newEng};
            Map<Id, Engagement__c> newEngagementMap = new Map<Id, Engagement__c>();
        newEngagementMap.put(e.Id, newEng);
        newEng.Stage__c = 'Hold';
        newEng.Stage_Comments__c = 'test';
        update newEng;
        newEng.Stage__c = 'Advisory';
        newEng.Stage_Comments__c = '';
        update newEng;
        Test.startTest();
        
        HL_EngagementHandler handler = new HL_EngagementHandler(false, 1);
        handler.OnBeforeUpdate(newEngagementList, newEngagementMap, oldEngagementList, oldEngagementMap);
        
        Test.stopTest();
        
        System.assertEquals(handler.IsTriggerContext,false);
    }
    
    private static testmethod void TestEngagementJoinerCreations()
    {
        Account objClientAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert objClientAccount;
        
        Account objClientAccountToUpdate = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert objClientAccountToUpdate;
        
        Account objSubjectAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert objSubjectAccount;
        
        List<Opportunity__c> opportunityList = new List<Opportunity__c>();
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 1))
        {
            objOpportunity.Estimated_Capital_Raised_MM__c = 123456789;
            objOpportunity.Job_Type__c = 'Board Advisory Services (BAS)';
            objOpportunity.Beneficial_Owner_Control_Person_form__c = 'No';
            opportunityList.add(objOpportunity);
        }
        insert opportunityList;
        
        Engagement__c objEngagementNew = new Engagement__c(Name='Test Engagement', Engagement_Number__c = '123456', Client__c = objClientAccount.Id, Opportunity__c = opportunityList[0].Id,
                                                           Subject__c = objSubjectAccount.Id, Stage__c = 'Advisory',
                                                           Line_of_Business__c = 'CF', Job_Type__c = 'Take Over Defense',
                                                           Primary_Office__c = 'AT', Industry_Group__c = 'BUS');
         insert objEngagementNew;
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = true,
                                                                                            Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpcNew;
        
        Test.startTest();
        
       
        
        Engagement_Counterparty__c objEC = new Engagement_Counterparty__c(Name = 'TestEC', Company__c = objSubjectAccount.Id,
                                                                          Engagement__c = objEngagementNew.Id);
        insert objEC;
        
        Revenue_Accrual__c objRA = new Revenue_Accrual__c(Engagement__c = objEngagementNew.Id, Month__c = 'Jan', Year__c = '2003');
        insert objRA;
        
        List<Engagement_Client_Subject__c> ecsAfterInsertResultList = [SELECT Id FROM Engagement_Client_Subject__c WHERE Engagement__c = :objEngagementNew.Id];
        
        objEngagementNew.Name = 'dndTestEngagement';
        objEngagementNew.Client__c = objClientAccountToUpdate.Id;
        update objEngagementNew;
        
        Test.stopTest();
        
        //check whether client subject records are created  - they shouldn't be because of our conversion process
        System.AssertEquals(ecsAfterInsertResultList.Size(), 0);
        
        // check whether the previous combination of joiner record is deleted, Now it should be deleted
        System.AssertEquals([SELECT Id FROM Engagement_Client_Subject__c WHERE Engagement__c = :objEngagementNew.Id AND Client_Subject__c = :objClientAccount.Id].Size(), 0);
        // check whether the updated client Account is created in the Joiner
        System.AssertEquals([SELECT Id FROM Engagement_Client_Subject__c WHERE Engagement__c = :objEngagementNew.Id].Size(), 1);
    }
    
    
    private static testmethod void TestEngagementFeeNewUpdate(){
        Account objClientAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert objClientAccount;
        
        Job_Type__c jobType = new Job_Type__c();
        jobType.Name = 'Board Advisory Services (BAS)';
        jobType.Primary_Line_of_Business__c = 'FVA';
        jobType.Job_Code__c = '100';
        jobType.Product_Type__c ='Transaction Opinions';
        insert jobType;
        
        //PLEASE REMOVE THIS OPPTY INSERTION IF NOT NEEDED
        List<Opportunity__c> opportunityList = new List<Opportunity__c>();
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 1))
        {
            objOpportunity.Estimated_Capital_Raised_MM__c = 123456789;
            objOpportunity.Job_Type__c = 'Board Advisory Services (BAS)';
            objOpportunity.Beneficial_Owner_Control_Person_form__c = 'No';
            opportunityList.add(objOpportunity);
        }
        insert opportunityList;
        
        Engagement__c objEngagementNew = new Engagement__c(Name='Test Engagement', Engagement_Number__c = '123456', Client__c = objClientAccount.Id, Opportunity__c = opportunityList[0].Id,
                                                           Subject__c = objClientAccount.Id, Stage__c = 'Advisory',
                                                           Line_of_Business__c = 'CF', Job_Type__c = 'Take Over Defense',
                                                           Primary_Office__c = 'AT', Industry_Group__c = 'BUS',Total_Estimated_Fee__c=10.00);
        
        insert objEngagementNew;
        
        Eng_VP__c EngVPList =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);        
        EngVPList.Name='Test Eng Vp';        
        EngVPList.Engagement__c=objEngagementNew.id;
        EngVPList.Valuation_Date__c=System.Today();
        EngVPList.CurrencyIsoCode='USD';   
        EngVPList.Fee_Total__c = 10.00;     
        Insert EngVPList;
        
        test.startTest();
        EngVPList.Fee_Total__c = 1000.00;
        update EngVPList;
        objEngagementNew.Total_Estimated_Fee__c = 100.00;
        update objEngagementNew;
        test.stopTest();
        System.AssertEquals(EngVPList.Fee_Total__c , 1000.00);
        System.AssertNotEquals(objEngagementNew.Total_Estimated_Fee__c , 20000.10);
        System.AssertEquals(objEngagementNew.Total_Estimated_Fee__c , 100.00);
        System.AssertNotEquals(objEngagementNew.Total_Estimated_Fee__c ,200.10);
    }
    
    private static testmethod void TestEngagementFeeUpdate(){
        Account objClientAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert objClientAccount;
        
        List<Opportunity__c> opportunityList = new List<Opportunity__c>();
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 1))
        {
            objOpportunity.Estimated_Capital_Raised_MM__c = 123456789;
            objOpportunity.Job_Type__c = 'Board Advisory Services (BAS)';
            objOpportunity.Beneficial_Owner_Control_Person_form__c = 'No';
            opportunityList.add(objOpportunity);
        }
        insert opportunityList;
        
        Engagement__c objEngagementNew = new Engagement__c(Name='Test Engagement', Engagement_Number__c = '123456', Client__c = objClientAccount.Id, Opportunity__c = opportunityList[0].Id,
                                                           Subject__c = objClientAccount.Id, Stage__c = 'Advisory',
                                                           Line_of_Business__c = 'CF', Job_Type__c = 'Take Over Defense',
                                                           Primary_Office__c = 'AT', Industry_Group__c = 'BUS',Total_Estimated_Fee__c=10.00);
        
        insert objEngagementNew;
        
        test.startTest();
        objEngagementNew.Total_Estimated_Fee__c = 100.00;
        update objEngagementNew;
        
        test.stopTest();
        System.AssertEquals(objEngagementNew.Total_Estimated_Fee__c ,100.00);
        System.AssertNotEquals(objEngagementNew.Total_Estimated_Fee__c ,100.10);
    }
    
    @isTest
    private static void TestCreateFRRevenueAccrualRecord()
    {
        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert clientAccount;
        
        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert subjectAccount;
        
        //FVA Engagement - We should create another test case for PV later 10/13/2017 Hideki
        Engagement__c eFR = new Engagement__c(
            Name='Test FR Engagement',
            Engagement_Number__c = '654321',
            Client__c = clientAccount.Id,
            Subject__c = subjectAccount.Id,
            Stage__c = 'Retained',
            Line_of_Business__c = 'FR',
            Job_Type__c = 'Fairness',
            RecordTypeId = '012i0000000tIWNAA2',
            Primary_Office__c = 'NY'
        );
        
        
        Test.startTest(); 
        
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                                                            Current_Month__c = '03', Current_Year__c = '2018');
        insert mrpcNew;
        
        insert eFR;
        
        eFR.Actual_Transaction_Fee__c = 200000;
        eFR.Actual_Monthly_Fee__c = 100000;
        
        SL_Statics.ByPassEngagementTrigger = false;
        SL_CheckRecursive.SkipOnConvert = false;
        
        update eFR;
        
        Test.stopTest();
        
        eFR = [SELECT Current_Revenue_Accrual__c, Period_Accrued_Fees__c, Actual_Transaction_Fee__c, Actual_Monthly_Fee__c FROM Engagement__c WHERE Id =: eFR.Id];
        List<Revenue_Accrual__c> raFR = [SELECT Period_Accrued_Fees__c, Actual_Transaction_Fee__c, Actual_Monthly_Fee__c FROM Revenue_Accrual__c 
                                         WHERE Engagement__c =: eFR.Id LIMIT 1];
        System.assert(eFR.Current_Revenue_Accrual__c != null);
        System.assertEquals(eFR.Period_Accrued_Fees__c, eFR.Actual_Transaction_Fee__c + eFR.Actual_Monthly_Fee__c);
        System.assertEquals(eFR.Period_Accrued_Fees__c, raFR[0].Period_Accrued_Fees__c);
        System.assertEquals(eFR.Actual_Transaction_Fee__c, raFR[0].Actual_Transaction_Fee__c);
        System.assertEquals(eFR.Actual_Monthly_Fee__c, raFR[0].Actual_Monthly_Fee__c);
        System.assertEquals(raFR[0].Period_Accrued_Fees__c, raFR[0].Actual_Transaction_Fee__c + raFR[0].Actual_Monthly_Fee__c);
    }
    
    @isTest
    private static void TestCreateFVARevenueAccrualRecord()
    {
        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert clientAccount;
        
        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert subjectAccount;
        
        //FVA Engagement - We should create another test case for PV later 10/13/2017 Hideki
        Engagement__c eFR = new Engagement__c(
            Name='Test FVA Engagement',
            Engagement_Number__c = '654321',
            Client__c = clientAccount.Id,
            Subject__c = subjectAccount.Id,
            Stage__c = 'Retained',
            Line_of_Business__c = 'FVA',
            Job_Type__c = 'Fairness',
            RecordTypeId = '012i0000000tIWNAA2',
            Primary_Office__c = 'NY'
        );
        
        
        Test.startTest(); 
        
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                                                            Current_Month__c = '03', Current_Year__c = '2018');
        insert mrpcNew;
        
        insert eFR;
        
        eFR.Total_Estimated_Fee__c = 100000;
        
        SL_Statics.ByPassEngagementTrigger = false;
        SL_CheckRecursive.SkipOnConvert = false;
        
        update eFR;
        
        Test.stopTest();
        
        eFR = [SELECT Current_Revenue_Accrual__c, Period_Accrued_Fees__c, Total_Estimated_Fee__c, Line_of_Business__c FROM Engagement__c WHERE Id =: eFR.Id];
        List<Revenue_Accrual__c> raFR = [SELECT Period_Accrued_Fees__c, Total_Estimated_Fee__c, Line_of_Business__c FROM Revenue_Accrual__c 
                                         WHERE Engagement__c =: eFR.Id LIMIT 1];
        System.assert(eFR.Current_Revenue_Accrual__c != null);
        System.assertEquals(eFR.Total_Estimated_Fee__c, raFR[0].Total_Estimated_Fee__c);
        System.assertEquals(eFR.Line_of_Business__c, raFR[0].Line_of_Business__c);
    }
    
    @isTest
    private static void TestSyncToRevenueAccrual()
    {
        // Test if Exclude from Reversal, Has Multiple Delivarables and Accrual Adjustment on Engagement are copied to Revenue Accrual 
        
        string currentMonth = '03';
        string currentYear = '2018';
        
        // Generate Test Data
        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        Engagement__c engagement = new Engagement__c(
            Name='Test Engagement',
            Engagement_Number__c = '09090',
            Client__c = clientAccount.Id,
            Subject__c = subjectAccount.Id,
            Stage__c = 'Retained',
            Line_of_Business__c = 'FVA',
            Job_Type__c = 'Fairness',
            RecordTypeId = '012i0000000tIWNAA2',
            Primary_Office__c = 'NY'
        );
        Monthly_Revenue_Process_Control__c monthlyRevenueProcessControl = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE
                                                                                                                 ,Current_Month__c = currentMonth
                                                                                                                 , Current_Year__c = currentYear);
        
        //Load Test Data
        insert subjectAccount;
        insert clientAccount;
        insert engagement;
        insert monthlyRevenueProcessControl;        
        
        Test.startTest(); 
        
        // Change the value of Exclude form Reversal, Has Multiple Delivarables and Accrual Adjustment
        engagement.Exclude_From_Reversal__c = true;  
        engagement.Exclusion_Comment__c = 'Excluded for testing';
        engagement.Has_Multiple_Deliverables__c = true;      
        engagement.Accrual_Adjustment__c = 500;
        engagement.Job_Type__c = 'ESOP Advisory';
        
        
        // Make sure to fire the trigger
        SL_Statics.ByPassEngagementTrigger = false;
        SL_CheckRecursive.SkipOnConvert = false;
        
        update engagement;
        
        Test.stopTest();
        
        // Verify the results
        engagement = [SELECT Exclude_From_Reversal__C
                      ,Has_Multiple_Deliverables__c
                      ,Accrual_Adjustment__c 
                      FROM Engagement__c
                      WHERE Id = :engagement.Id];
        List<Revenue_Accrual__c> revenueAccrualList = [SELECT Exclude_From_Reversal__C
                                                       ,Has_Multiple_Deliverables__c
                                                       ,Accrual_Adjustment__c 
                                                       FROM Revenue_Accrual__c 
                                                       WHERE Engagement__c = :engagement.Id];
        
        System.Assert(engagement.Exclude_From_Reversal__C == true);
        System.Assert(engagement.Has_Multiple_Deliverables__c == true);
        System.Assert(engagement.Accrual_Adjustment__c == 500);
        
        System.AssertEquals(engagement.Exclude_From_Reversal__C, revenueAccrualList[0].Exclude_From_Reversal__C);
        // System.AssertEquals(engagement.Has_Multiple_Deliverables__c, revenueAccrualList[0].Has_Multiple_Deliverables__c);
        // System.AssertEquals(engagement.Accrual_Adjustment__c, revenueAccrualList[0].Accrual_Adjustment__c);
    }
    
    @isTest
    private static void TestHasMultipleDeliveralble()
    {
        // Test if Has Multiple Delivarables defaults to the value on Job Type
        
        string jobTypeName = 'Test Job';
        string LOB = 'FVA';
        
        // Generate Test Data        
        Job_Type__c jobType = new Job_Type__c(Name = jobTypeName 
                                              ,Job_Code__c = '9999'
                                              ,Primary_Line_of_Business__c = LOB
                                              ,Has_Multiple_Deliverables__c = true);
        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        
        //Load Test Data
        insert jobType;
        insert subjectAccount;
        insert clientAccount;
        
        Test.startTest(); 
        
        // Create a new engagement
        Engagement__c engagement = new Engagement__c(
            Name='Test Engagement',
            Engagement_Number__c = '09090',
            Client__c = clientAccount.Id,
            Subject__c = subjectAccount.Id,
            Stage__c = 'Retained',
            Line_of_Business__c = LOB,
            Job_Type__c = jobTypeName,
            RecordTypeId = '012i0000000tIWNAA2',
            Primary_Office__c = 'NY'
        );
        insert engagement;
        
        Test.stopTest();
        
        // Verify the results
        engagement = [SELECT Has_Multiple_Deliverables__c
                      FROM Engagement__c
                      WHERE Id = :engagement.Id];
        
        System.AssertEquals(engagement.Has_Multiple_Deliverables__c, jobType.Has_Multiple_Deliverables__c);
    }
    
    @isTest
    private static void TestOnAfterEngagementCommentInsert(){
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        e.Line_of_Business__c = 'FVA';
        e.CurrencyIsoCode = 'AUD';
        e.Engagement_Comment__c = 'Testing Comment';
        
        Engagement_Comment__c ec = new Engagement_Comment__c(Engagement__c = e.Id, Comment_Type__c = 'Internal', Comment__c = 'Test');
        
        HL_EngagementCommentHandler handler = new HL_EngagementCommentHandler(false, 1);
        // insert ec;
        
        List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
        Contact c = new contact(); 
        c.FirstName = 'test1';
        c.LastName = 'test2';
        c.AccountId = accList[0].id;
        //  c.User__c = usr.Id;
        Insert c; 
        Eng_VP__c engVP =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);
        engVP.Name='Test Eng Vp';        
        engVp.Engagement__c=e.id;
        engVP.Valuation_Date__c=System.Today();
        engVp.CurrencyIsoCode='USD';        
        Insert engVP; 
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList[0].Id;
        engVPPos.Company__c=accList[0].Id;
        engVPPos.Engagement_VP__c=engVP.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        engVPPos.Industry_Group_Picklist__c='SOV - Sovereigns';
        engVPPos.Sector__c='Sovereigns';
        insert engVPPos;  
        
        HL_EngagementHandler.IsbeforeUpdateFlag = False;
        update e;
        
    }
    
    
    @isTest
    private static void TestOnAfterEngagementCommentInsert1(){
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        e.Line_of_Business__c = 'FVA';
        e.CurrencyIsoCode = 'AUD';
        e.Engagement_Comment__c = 'Testing Comment';
        e.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Portfolio Valuation').getRecordTypeId();
        e.Total_Estimated_Fee__c = 500;
        
        Eng_VP__c engVP =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);
        engVP.Name='Test Eng Vp';        
        engVp.Engagement__c=e.id;
        engVP.Valuation_Date__c=System.Today();
        engVp.CurrencyIsoCode='USD';        
        Insert engVP; 
        HL_EngagementHandler.IsbeforeUpdateFlag = False;
        update e;
        
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
        contact.Title = 'CFO';
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
        
        Opportunity_External_Team__c oppExternal = new Opportunity_External_Team__c();
        oppExternal.Contact__c = contact.id;
        oppExternal.Opportunity__c = opportunity.id;
        oppExternal.Billing_Contact__c = True;
        oppExternal.Acknowledge_Billing_Contact__c = True;
        insert oppExternal;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        engagement.Legal_Entity__c = legalEntity.Id;
        engagement.Opportunity__c = opportunity.Id;
        insert engagement;
        
        Engagement_External_Team__c engExternal = new Engagement_External_Team__c();
        engExternal.Contact__c = contact.id;
        engExternal.Engagement__c = engagement.id;
        engExternal.Billing_Contact__c = True;
        engExternal.Acknowledge_Billing_Contact__c = True;
        insert engExternal;
        
        test.startTest();
        Contract__c contract = new Contract__c();
        contract.Name = 'Contract Test 1';
        contract.Bill_To__c = account.Id;
        contract.Client__c = account.Id;
        contract.Ship_To__c = account.Id;
        contract.Billing_Contact__c = contact.Id;
        contract.Engagement__c = engagement.Id;
        contract.ERP_Contract_Type__c = 'Engagement';
        contract.HL_Entity__c = '030';
        insert contract;
        
        engagement.Legal_Entity__c = legalEntityChina.Id;
        update engagement;
        
        engagement.Legal_Entity__c = legalEntity.Id;
        update engagement;
        test.stopTest();
    }
}