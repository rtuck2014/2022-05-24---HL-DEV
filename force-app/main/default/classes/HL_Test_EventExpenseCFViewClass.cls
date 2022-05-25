/**************************************************************
* Name : HL_Test_EventExpenseCFViewClass
* Purpose : To provide code coverage for "HL_EventExpenseCFViewPage" page
*************************************************************************/
@isTest
Private Class HL_Test_EventExpenseCFViewClass { 
    
    @testSetup 
    static void setup() {
            
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        insert user1;
        
        List<Delegate_Public_Group__c> delegatePublicGroupList = new List<Delegate_Public_Group__c>();
        for(Delegate_Public_Group__c delegatePublicGroupRecord : (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1)){
            delegatePublicGroupRecord.Banker__c = user1.Id;
            delegatePublicGroupList.add(delegatePublicGroupRecord);
        }
        insert delegatePublicGroupList;
        
        Delegate_Public_Group_Member__c DPGmember1 = new Delegate_Public_Group_Member__c();
        DPGmember1.Delegate__c = userInfo.getUserId();
        DPGmember1.Delegate_Public_Group__c = delegatePublicGroupList[0].id;        
        insert DPGmember1;  
        
        
        Id HoulihanEmployeeRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();

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
            CList[i].User__c = user1.id;
            CList[i].Status__c = 'Active';
        }
        Insert CList; 
        
        List<Sub_Ledger_Number__c> slnList = (List<Sub_Ledger_Number__c>)HL_TestFactory.CreateSObjectList('Sub_Ledger_Number__c', false, 4);        
        for(integer i = 0; i < slnList.size(); i++){
            slnList[i].Spend_Type__c = 'ADM';
            slnList[i].Subledger_Description__c = 'Test ' +i;
            slnList[i].Name = 'Test ' +i;
        }
        Insert slnList; 
        
        
        List<Event_Expense__c> eventExp = (List<Event_Expense__c>)HL_TestFactory.CreateSObjectList('Event_Expense__c', false, 4);        
        for(integer i = 0; i < eventExp.size(); i++){
            eventExp[i].Requestor_Name__c=CList[i].Id;
            eventExp[i].Event_Contact__c=CList[i].Id;
            eventExp[i].Start_Date__c = system.today();
            eventExp[i].When_this_event_will_be_evaluated__c = system.today();
            eventExp[i].Product_Type__c = 'TO';
            eventExp[i].Event_Name__c = 'Test '+i;
            eventExp[i].Event_Purpose__c = 'Test '+i;
            eventExp[i].What_is_desired_outcome_of_this_event__c = 'Test '+i;
            eventExp[i].City__c = 'LA';
            eventExp[i].Target_Audience__c = 'Directors';
            eventExp[i].LOB__c = 'CF';
            eventExp[i].Event_Type_Format__c = 'Staff Entertainment';
            eventExp[i].Event_Format__c = 'Staff Entertainment';
            eventExp[i].Number_of_guests__c = '1-10';
            eventExp[i].Marketing_support__c = 'No';
            eventExp[i].Expected_Travel_cost__c = 2500;
            eventExp[i].Expected_F_B_cost__c = 1;
            eventExp[i].Any_additional_cost_Specify__c = 0;
            eventExp[i].SubLedger_Number__c = slnList[i].Id;
            eventExp[i].Any_additional_cost_Specify__c = 0;
            eventExp[i].Status__c = 'Saved';
        }
        insert eventExp;
        List_of_team_member__c testTM ;
        List<List_of_team_member__c> ListOFtestTM = new List<List_of_team_member__c>();
        for(Event_expense__c exp : eventExp)
        {
            testTM = new List_of_team_member__c();
            testTM.Event_Expense__c = exp.Id;
            testTM.Contact__c = CList[0].id;
            ListOFtestTM.add(testTM);
        }
        
        insert ListOFtestTM;
        
        List<Event_Expense_Approval_History__c> EEAHList = (List<Event_Expense_Approval_History__c>)HL_TestFactory.CreateSObjectList('Event_Expense_Approval_History__c', false, 4);        
        for(integer i = 0; i < EEAHList.size(); i++){
            EEAHList[i].Is_Archive__c = false;
            EEAHList[i].Event_Expense__c = eventExp[i].id;
            EEAHList[i].Status__c = 'Pending';
            EEAHList[i].Approver__c = UserInfo.getUserId();
        }
        Insert EEAHList; 
        
        List<Potential_confirmed_external_guests__c> PCEGList = (List<Potential_confirmed_external_guests__c>)HL_TestFactory.CreateSObjectList('Potential_confirmed_external_guests__c', false, 4);
        for(integer i = 0; i < PCEGList.size(); i++){
            PCEGList[i].Contact__c = CList[0].id;
            PCEGList[i].Event_Expense__c = eventExp[0].id;
        }
        Insert PCEGList; 
        
        List<Presenter__c> presenterList = (List<Presenter__c>)HL_TestFactory.CreateSObjectList('Presenter__c', false, 4);
        for(integer i = 0; i < presenterList.size(); i++){
            presenterList[i].Contact__c = CList[0].id;
            presenterList[i].Event_Expense__c = eventExp[0].id;
        }
        Insert presenterList; 
        
    }
       
    
   @isTest
    static void testMethod1(){
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,
            Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
            Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
            City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
            What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
            Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
            Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
            Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c, 
            SubLedger_Number__c, Any_additional_requests__c,
            Notes__c FROM Event_Expense__c Limit 1];
            update eExp[0];
            
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseViewPage'));
            System.currentPageReference().getParameters().put('id',eExp[0].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
            HL_EventExpenseViewClass clsObj = new HL_EventExpenseViewClass(sc);
           
            clsObj.toApprove();
            eExp[0].Potential_Revenue__c = 2;
            update eExp[0];
            clsObj.toReject();
            clsObj.toRequestMoreInformation();
            clsObj.closePopup();
            clsObj.backToRecord();
            clsObj.SubmitForApproval();
            clsObj.Edit();
            clsObj.backToMainPage();
            HL_EventExpenseViewClass.ishavingApprovalPermission(eExp[0].id);           
            
        test.StopTest(); 
        
        system.assertequals(eExp[0].Start_Date__c, eExp[0].When_this_event_will_be_evaluated__c);
        clsObj.Edit();
        clsObj.SubmitForApproval();
    }
    @isTest
    static void testMethod2(){
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,
            Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
            Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
            City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
            What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
            Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
            Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
            Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c,
            SubLedger_Number__c, Any_additional_requests__c,
            Notes__c FROM Event_Expense__c Limit 1];
            update eExp[0];
            
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseViewPage'));
            System.currentPageReference().getParameters().put('id',eExp[0].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
            HL_EventExpenseViewClass clsObj = new HL_EventExpenseViewClass(sc);
           
            eExp[0].Expected_Travel_cost__c = 2;
            update eExp[0];
            clsObj.SubmitForApproval();
            clsObj.toApprove();
            system.assertEquals(eExp[0].Expected_Travel_cost__c, 2);
        test.StopTest(); 
        
    }
    
    @isTest
    static void testMethod3(){
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,
            Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
            Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
            City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
            What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
            Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
            Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
            Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c, 
            SubLedger_Number__c, Any_additional_requests__c,
            Notes__c FROM Event_Expense__c Limit 1];
            eExp[0].Potential_Revenue__c = 2;
            update eExp[0];
            
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseViewPage'));
            System.currentPageReference().getParameters().put('id',eExp[0].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
            HL_EventExpenseViewClass clsObj = new HL_EventExpenseViewClass(sc);
            clsObj.EveExpRecord.Current_Approval_Level__c = '1';
             clsObj.SubmitForApproval();
            clsObj.toReject();
            clsObj.currentPopUpSource = 'More Information Requested';
            HL_Event_Expense_ApprovalActionUtil.doReject_MIR(eExp[0], 'More Information Requested', 'Test comment');    
            clsObj.EveExpRecord.Current_Approval_Level__c = '1';
            clsObj.backToRecord();      
            
            clsObj.toReject();
            clsObj.currentPopUpSource = 'More Information Requested';
            HL_Event_Expense_ApprovalActionUtil.doReject_MIR(eExp[0], 'More Information Requested', 'Test comment');    
            clsObj.EveExpRecord.Current_Approval_Level__c = '2';
            clsObj.backToRecord();          
            system.assertEquals(eExp[0].Potential_Revenue__c, 2);
        test.StopTest();        
    }
    
    @isTest
    static void testMethod4(){
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,Current_Approval_Level__c, 
            Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
            Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
            City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
            What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
            Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
            Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
            Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c, 
            SubLedger_Number__c, Any_additional_requests__c,
            Notes__c FROM Event_Expense__c Limit 1];
            eExp[0].Potential_Revenue__c = 2;
            update eExp[0];
            
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseViewPage'));
            System.currentPageReference().getParameters().put('id',eExp[0].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
            HL_EventExpenseViewClass clsObj = new HL_EventExpenseViewClass(sc);
        
            clsObj.SubmitForApproval();
            clsObj.toReject();
            clsObj.currentPopUpSource = 'Rejected';
            HL_Event_Expense_ApprovalActionUtil.doReject_MIR(eExp[0], 'Rejected', 'Test comment');  
            clsObj.EveExpRecord.Current_Approval_Level__c = '1';
            clsObj.backToRecord();      
            
            clsObj.toReject();
            clsObj.currentPopUpSource = 'Rejected';
            HL_Event_Expense_ApprovalActionUtil.doReject_MIR(eExp[0], 'Rejected', 'Test comment');  
            clsObj.EveExpRecord.Current_Approval_Level__c = '2';
            clsObj.backToRecord();
            
            clsObj.currentPopUpSource = 'Deleted';
            clsObj.backToRecord();
            clsObj.toDelete();
            
            system.assertEquals(eExp[0].Potential_Revenue__c, 2);
        test.StopTest();        
    }
    
    
    @isTest
    static void testMethod5(){
        
        List<Contact> con = [Select id from Contact limit 1];
        
        List<Event_Expense__c> eventExp = (List<Event_Expense__c>)HL_TestFactory.CreateSObjectList('Event_Expense__c', false, 4);        
        for(integer i = 0; i < eventExp.size(); i++){
            eventExp[i].Requestor_Name__c=con[0].Id;
        }
        insert eventExp;
        
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseEditPage'));
            System.currentPageReference().getParameters().put('id',eventExp[0].id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(eventExp[0]);
            HL_EventExpenseViewClass clsObj = new HL_EventExpenseViewClass(sc);
            
            clsObj.requiredForCS = true;
            clsObj.requiredForSE = true;
            clsObj.requiredForCE = true;
            clsObj.validate();
            system.assertNotequals(clsObj, null);
        Test.StopTest(); 
        
    }
    
    @isTest
    static void testCloneFunctionality(){
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,
            Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
            Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
            City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
            What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
            Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
            Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
            Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c, 
            SubLedger_Number__c, Any_additional_requests__c,
            Notes__c FROM Event_Expense__c Limit 1];
            update eExp[0];
        ApexPages.currentPage().getParameters().put('id',eExp[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
        HL_EventExpenseViewClass clsObj1 = new HL_EventExpenseViewClass(sc);
        clsObj1.cloneEventExpense();
        system.assertNotEquals(eExp[0].Id, null);
    }
    
    private static User createTestUser(Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName, lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US', ProfileId = profId,IsActive = true
                             );
        return tuser;
    }
}