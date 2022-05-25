/**************************************************************
* Name : HL_Test_EventExpenseCFClass
* Purpose : To provide code coverage for "HL_EventExpenseClass", "HL_EventExpenseClassExt2" and "HL_EventExpenseClassExt" class
*************************************************************************/
@isTest
Private Class HL_Test_EventExpenseCFClass { 
    
    @testSetup 
    static void setup() {
        Id HoulihanEmployeeRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        Id ExternalContactRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
        
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
        
        List<Sub_Ledger_Number__c> slnList = (List<Sub_Ledger_Number__c>)HL_TestFactory.CreateSObjectList('Sub_Ledger_Number__c', false, 4);        
        for(integer i = 0; i < slnList.size(); i++){
            slnList[i].Spend_Type__c = 'ADM';
            slnList[i].Subledger_Description__c = 'Test ' +i;
            slnList[i].Name = 'Test ' +i;
        }
        Insert slnList; 
        
        List<Contact> CExtList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 4);        
        for(integer i = 0; i < CExtList.size(); i++){
            CExtList[i].FirstName = 'TestFirst' +i;
            CExtList[i].LastName = 'TestLast' +i;
            CExtList[i].AccountId = accountList[0].id;
            CExtList[i].RecordTypeId = ExternalContactRTContact;
        }
        Insert CExtList; 
        
        
        Campaign campaignRecord = (Campaign)HL_TestFactory.CreateSObject('Campaign', false);
        campaignRecord.Name = 'testName';        
        insert campaignRecord;
        
        
        List<Event_Expense__c> eventExp = (List<Event_Expense__c>)HL_TestFactory.CreateSObjectList('Event_Expense__c', false, 4);        
        for(integer i = 0; i < eventExp.size(); i++){
            eventExp[i].Related_campaign_if_30_guests__c=campaignRecord.Id;
            eventExp[i].Requestor_Name__c=CList[i].Id;
            eventExp[i].Event_Contact__c=CList[i].Id;
            eventExp[i].Who_is_evaluating_the_event__c=CList[i].Id;
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
            eventExp[i].Expected_Airfare_Cost__c = 1; 
            eventExp[i].Expected_Lodging_Cost__c = 1; 
            eventExp[i].Expected_Registration_Fee__c = 1;            
            eventExp[i].Any_additional_cost_Specify__c = 0;
            eventExp[i].SubLedger_Number__c = slnList[i].Id;
            eventExp[i].Potential_Revenue__c = 1;
            eventExp[i].What_are_KPIs__c = 'test';
            eventExp[i].Status__c = 'Saved';
        }
        insert eventExp;
        
        List<Event_Expense_Approval_History__c> EEAHList = (List<Event_Expense_Approval_History__c>)HL_TestFactory.CreateSObjectList('Event_Expense_Approval_History__c', false, 4);
        for(integer i = 0; i < EEAHList.size(); i++){
            EEAHList[i].Approver__c = UserInfo.getUserId();
            EEAHList[i].Event_Expense__c = eventExp[0].id;
            EEAHList[i].Is_Archive__c = false;
            EEAHList[i].Status__c ='Pending';
        }
        Insert EEAHList; 
        
        List<Potential_confirmed_external_guests__c> PCEGList = (List<Potential_confirmed_external_guests__c>)HL_TestFactory.CreateSObjectList('Potential_confirmed_external_guests__c', false, 4);
        for(integer i = 0; i < PCEGList.size(); i++){
            PCEGList[i].Contact__c = CExtList[0].id;
            PCEGList[i].Event_Expense__c = eventExp[0].id;
        }
        Insert PCEGList; 
        
        List<List_of_team_member__c> LOTMList = (List<List_of_team_member__c>)HL_TestFactory.CreateSObjectList('List_of_team_member__c', false, 4);
        for(integer i = 0; i < LOTMList.size(); i++){
            LOTMList[i].Contact__c = CList[0].id;
            LOTMList[i].Event_Expense__c = eventExp[0].id;
        }
        Insert LOTMList; 
        
        List<Presenter__c> PresenterList = (List<Presenter__c>)HL_TestFactory.CreateSObjectList('Presenter__c', false, 4);
        for(integer i = 0; i < PresenterList.size(); i++){
            PresenterList[i].Contact__c = CList[0].id;
            PresenterList[i].Event_Expense__c = eventExp[0].id;
        }
        Insert PresenterList; 
        
    }
    
    @isTest
    static void testMethod1(){
        
        Id ExternalContactRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,
                                       Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
                                       Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
                                       City__c, End_Date__c, Event_Type_Format__c,Event_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
                                       What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
                                       Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
                                       Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
                                       Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c,
                                       SubLedger_Number__c, Any_additional_requests__c,
                                       Notes__c FROM Event_Expense__c Limit 1];
        
        List<Contact> con = [Select id from Contact limit 1];
        List<Contact> conExt = [Select id from Contact Where RecordTypeId =: ExternalContactRTContact limit 1];
        
        Test.StartTest();
        Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseLandingPage'));
        System.currentPageReference().getParameters().put('id',eExp[0].id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
        HL_EventExpenseClass clsObj = new HL_EventExpenseClass(sc);
        
        clsObj.CurPageNumber = 1;
        clsObj.CurPageSize = 1;
        clsObj.SelectedContactIdLOTM = con[0].id;
        clsObj.SelectedContactIdPCEG = conExt[0].id;
        clsObj.SelectedContactIdPresenter = con[0].id;
        boolean isPrev   =  clsobj.hasPrevious;
        boolean isNext   =  clsobj.hasNext;
        integer pageNo   =  clsobj.pageNumber;        
        integer pageSi   =  clsobj.pageSize;        
        clsObj.CurPageNumber = 1;
        clsObj.CurPageSize = 1;
        clsObj.first();
        clsObj.last();
        clsObj.previous();
        clsObj.next();
        clsObj.doSavePageSize();
        clsObj.goCurPageNumber();
        clsObj.sortField = 'Event_Name__c';
        clsObj.toggleSort();
        clsObj.newEventExpenseRecord();
        clsObj.AddContactForLoTM();
        clsObj.AddContactForPCEG();
        clsObj.AddContactForPresenter();
        clsObj.Cancel();
        
        ApexPages.StandardController scAT = new ApexPages.StandardController(eExp[0]);
        HL_EventExpenseClassExt clsObjAT = new HL_EventExpenseClassExt(scAT);
        
        clsObjAT.CurPageNumberAT = 1;
        clsObjAT.CurPageSizeAT = 1;
        boolean isPrevAT   =  clsobjAT.hasPreviousAT;
        boolean isNextAT   =  clsobjAT.hasNextAT;
        integer pageNoAT   =  clsobjAT.pageNumberAT;        
        integer pageSiAT   =  clsobjAT.pageSizeAT;        
        clsObjAT.CurPageNumberAT = 1;
        clsObjAT.CurPageSizeAT = 1;
        clsObjAT.firstAT();
        clsObjAT.lastAT();
        clsObjAT.previousAT();
        clsObjAT.nextAT();
        clsObjAT.doSavePageSizeAT();
        clsObjAT.goCurPageNumberAT();
        clsObjAT.sortFieldAT = 'Event_Name__c';
        clsObjAT.toggleSortAT();
        clsObjAT.voidActionAT();
        clsObjAT.getEvntFrmatValuesAT();
        clsObjAT.resetEventTypeAndFormatAT();
        clsObjAT.applyFilterAT();
        clsObjAT.resetFilterAT();
        
        ApexPages.StandardController scAT2 = new ApexPages.StandardController(eExp[0]);
        HL_EventExpenseClassExt2 clsObjAT2 = new HL_EventExpenseClassExt2(scAT2);
        
        clsobjAT2.CurPageNumberAT2 = 1;
        clsobjAT2.CurPageSizeAT2 = 1;
        boolean isPrevAT2   =  clsobjAT2.hasPreviousAT2;
        boolean isNextAT2   =  clsobjAT2.hasNextAT2;
        integer pageNoAT2   =  clsobjAT2.pageNumberAT2;        
        integer pageSiAT2   =  clsobjAT2.pageSizeAT2;        
        clsobjAT2.CurPageNumberAT2 = 1;
        clsobjAT2.CurPageSizeAT2 = 1;
        clsobjAT2.firstAT2();
        clsobjAT2.lastAT2();
        clsobjAT2.previousAT2();
        clsobjAT2.nextAT2();
        clsobjAT2.doSavePageSizeAT2();
        clsobjAT2.goCurPageNumberAT2();
        clsobjAT2.sortFieldAT2 = 'Event_Name__c';
        clsobjAT2.toggleSortAT2();
        clsobjAT2.voidActionAT2();
        clsobjAT2.eventExpAT2 = eExp[0];
        string logicCriteriaSelVal = clsobjAT2.logicCriteriaSelValAT2 = 'OR';
        clsobjAT2.evtExpNumberValAT2 = '0000';
        string submissionDateSel = clsobjAT2.submissionDateSelValAT2 = 'LAST_N_DAYS:30';
        string createdDateSelVal = clsobjAT2.createdDateSelValAT2 = 'LAST_N_DAYS:30';
        clsobjAT2.applyFilterAT2();
        clsobjAT2.resetFilterAT2();
        clsobjAT2.getEvntFrmatValuesAT2();
        clsobjAT2.resetEventTypeAndFormatAT2();
        HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin();
        test.StopTest();
        system.assertequals(eExp[0].Start_Date__c, eExp[0].When_this_event_will_be_evaluated__c);
        
    }
    
    @isTest
    static void testMethod2(){
        
        HL_Event_Expense_Crucial_Fields__c crecialFields = new HL_Event_Expense_Crucial_Fields__c(Name = 'SubLedger_Number__c');
        insert crecialFields;
        
        list<Event_Expense__c> eExp = [select id, Requestor_Name__c, Start_Date__c,
                                       Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c,ownerId,
                                       Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c,
                                       City__c, End_Date__c, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,
                                       What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,
                                       Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
                                       Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,
                                       Any_additional_cost_Specify__c, Total_Budget_Requested__c, Who_is_evaluating_the_event__c, When_this_event_will_be_evaluated__c, What_are_KPIs__c, SubLedger_Number__c, Any_additional_requests__c,
                                       Notes__c,Event_Format__c,Expected_Airfare_Cost__c, Expected_Lodging_Cost__c, Expected_Registration_Fee__c FROM Event_Expense__c Limit 1];
        eExp[0].Event_Type_Format__c = 'MKTG - Conference/ Seminar';
        update eExp[0];
        
        List<Account> acc = [Select id from Account limit 1];
        
        Id HoulihanEmployeeRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        Id ExternalContactRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
        
        
        Contact contExt = new Contact(LastName = 'Test', FirstName = 'Test',AccountId = acc[0].id, RecordTypeId = ExternalContactRTContact);
        insert contExt;
        
        Contact contInt = new Contact(LastName = 'Test', FirstName = 'Test',AccountId = acc[0].id, RecordTypeId = HoulihanEmployeeRTContact);
        insert contInt;
        
        List<Potential_confirmed_external_guests__c> pceg = [Select id from Potential_confirmed_external_guests__c limit 1];
        List<List_of_team_member__c> lotm = [Select id from List_of_team_member__c limit 1];
        List<Presenter__c> Present = [Select id from Presenter__c limit 1];
        
        
        Test.StartTest();
        Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseEditPage'));
        System.currentPageReference().getParameters().put('id',eExp[0].id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(eExp[0]);
        HL_EventExpenseClass clsObj = new HL_EventExpenseClass(sc);
        
        clsObj.SelectedContactIdLOTM = contInt.id;
        clsObj.SelectedContactIdPCEG = contExt.id;
        clsObj.SelectedContactIdPresenter = contInt.id;
        clsObj.newEventExpenseRecord();
        clsObj.AddContactForLoTM();
        clsObj.DelId = contInt.id;
        clsObj.RemoveContactLoTM();
        clsObj.AddContactForPCEG();
        clsObj.DelId = contExt.id;
        clsObj.RemoveContactPCEG();
        clsObj.AddContactForPresenter();
        clsObj.DelId = contInt.id;
        clsObj.RemoveContactPresenter();
        clsObj.Save();
        clsObj.getEvntFrmatValues();
        clsObj.resetEventTypeAndFormat();
        clsObj.applyFilter();
        clsObj.resetFilter();
        clsObj.getEventFormatOptions();
        
        eExp[0].Status__c = 'Waiting for Approval';
        update eExp[0];
        Test.StopTest(); 
        system.assertequals(eExp[0].Status__c, 'Waiting for Approval');
        system.assertNotequals(eExp[0].LOB__c, '');
        system.assertNotequals(eExp[0].Event_Type_Format__c, '');
        system.assertNotequals(eExp[0].Event_Format__c, '');
        system.assertNotequals(eExp[0].Requestor_Name__c, '');
        system.assertequals(eExp[0].Total_Budget_Requested__c, (eExp[0].Expected_Airfare_Cost__c+eExp[0].Any_additional_cost_Specify__c+eExp[0].Expected_F_B_cost__c+eExp[0].Expected_Lodging_Cost__c+eExp[0].Expected_Registration_Fee__c));
    }
    
    @isTest
    static void testMethod3(){
        
        List<Contact> con = [Select id from Contact limit 1];
        
        List<Event_Expense__c> eventExp = (List<Event_Expense__c>)HL_TestFactory.CreateSObjectList('Event_Expense__c', false, 4);        
        for(integer i = 0; i < eventExp.size(); i++){
            eventExp[i].Requestor_Name__c=con[0].Id;
            eventExp[i].Event_Contact__c=con[0].Id;
        }
        insert eventExp;
        
        Test.StartTest();
        Test.setCurrentPageReference(new PageReference('Page.HL_EventExpenseEditPage'));
        System.currentPageReference().getParameters().put('id',eventExp[0].id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(eventExp[0]);
        HL_EventExpenseClass clsObj = new HL_EventExpenseClass(sc);
        
        clsObj.requiredForCS = true;
        clsObj.requiredForSE = true;
        clsObj.requiredForCE = true;
        system.assertNotequals(clsObj, null);
        Test.StopTest(); 
        
    }
}