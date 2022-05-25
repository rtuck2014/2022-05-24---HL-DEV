@isTest
private class Test_HL_CF_EngagementSummaryController {
    @isTest private static void TestFullCompletion() {
    
        //nara:11142019 - custom setting related to Oracle ERP Project. 
        /*HL_Auto_Number_Settings__c setting = new HL_Auto_Number_Settings__c();
        setting.Name = 'Account';
        setting.Auto_Number__c = 100001;
        insert setting;*/
        
        //Setup the Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        a.Ownership = 'Private';
        insert a;

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        e.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Sellside').getRecordTypeId();
        e.Client__c = a.Id;
        e.Subject__c = a.Id;
        insert e;

        Engagement_Summary__c es = new Engagement_Summary__c(Engagement__c = e.Id);
        es.No_Credit_Facility_Data__c = false;
        insert es;

        //Need EIT Principal or Manager for Submission
        Staff_Role__c sr = new Staff_Role__c(Name = 'Manager', Engagement__c = true);
        insert sr;
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        insert c;

        Engagement_Internal_Team__c eit = SL_TestSetupUtils.CreateEIT('', 1)[0];
        eit.Engagement__c = e.Id;
        eit.Contact__c = c.Id;
        eit.Staff_Role__c = sr.Id;
        insert eit;

        Contact externalContact = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        externalContact.AccountId = a.Id;
        insert externalContact;

        Engagement_External_Team__c eet = SL_TestSetupUtils.CreateEET('', 1)[0];
        eet.Contact__c = externalContact.Id;
        eet.Engagement__c = e.Id;
        eet.Party__c = 'Buyer';
        insert eet;

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(es);
        Test.setCurrentPage(new PageReference('/' + es.id));
        HL_CF_EngagementSummaryController esc = new HL_CF_EngagementSummaryController(sc);
        List<Engagement_External_Team__c> sellerTeam = esc.SellerContacts;
        List<Engagement_External_Team__c> etList = esc.ExternalTeam;
        List<Debt_Structure__c> dsList = esc.DebtStructures;
        List<HL_CF_EngagementSummaryController.CapitalizationRecord> capitalizationList = esc.CapitalizationRecords;
        List<Engagement_Counterparty__c> wcList = esc.WinningCounterparties;
        List<Engagement_Counterparty_Contact__c> ccList = esc.CounterpartyContacts;

        //Fix Required Errors

        //Winning Counterparty Required
        Engagement_Counterparty__c ec = SL_TestSetupUtils.CreateEC('', 1)[0];
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id;
        ec.Closing_Round_Bid_Date__c = Date.today();
        insert ec;

        esc.WinningCounterparties = null;
        //Winning Counterparty Fields Required
        ec.Process_Type__c = 'Process Type';
        ec.Platform_Type__c = 'Platform Type';
        update ec;
        esc.WinningCounterparties = null;

        //Sellside Fields Required
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Seller_Detail_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Public Company Process
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Public_Company_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Purchase Price and Structure Fields Required
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Purchase_Price_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), null);
        }

        //Key Contract Terms Required
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Key_Contract_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Employee Terms
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Employee_Terms_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Credit Facility
        es.No_Credit_Facility_Data__c = true;

        update es;

        Debt_Structure__c ds = esc.NewDebtStructure;
        esc.SaveNewDebtStructure();

        esc.SubmitForApproval();
        esc.PrepareApprovalSubmission();
        esc.RejectProcess();
        esc.PrepareApprovalSubmission();
        esc.ApproveProcess();
        Test.stopTest();

        //Confirm no Error Messages
        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
    }

    @isTest private static void TestFullCompletionWithMultipleApproversAndRunAs() {
        integer approverSize = 3;

        //nara:11142019 - custom setting related to Oracle ERP Project. 
        /*HL_Auto_Number_Settings__c setting = new HL_Auto_Number_Settings__c();
        setting.Name = 'Account';
        setting.Auto_Number__c = 100001;
        insert setting;*/
        
        //Setup the Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        a.Ownership = 'Private';
        insert a;

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        e.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Sellside').getRecordTypeId();
        e.Client__c = a.Id;
        e.Subject__c = a.Id;
        insert e;

        Engagement_Summary__c es = new Engagement_Summary__c(Engagement__c = e.Id);
        es.No_Credit_Facility_Data__c = false;
        insert es;

        //Need EIT Principal or Manager for Submission/ We will Run As Using Standard User Template
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User Template'];
        Staff_Role__c sr = new Staff_Role__c(Name = 'Manager', Engagement__c = true);
        List<Contact> managerList = SL_TestSetupUtils.CreateContact('', approverSize, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        insert sr;
        List<User> userList = new List<User>();
        for (integer i = 0; i < managerList.size(); i++) {
            userList.Add(new User(Alias = 'standt', Email = 'standarduser' + i + '@testorg.com',
                                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US', ProfileId = p.Id,
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardusertemplate' + i + '@testorg.com'));

        }
        insert userList;

        for (integer i = 0; i < managerList.size(); i++)
            managerList[i].User__c = userList[i].Id;
        //insert managerList;
        
        Contact externalContact = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        externalContact.AccountId = a.Id;
        //insert externalContact;
        
        list<Contact> combineListofContacts = new list<Contact>();
        combineListofContacts.addAll(managerList);
        combineListofContacts.add(externalContact);
        insert combineListofContacts;
        List<Engagement_Internal_Team__c> eitList = SL_TestSetupUtils.CreateEIT('', approverSize);
        for (integer i = 0; i < managerList.size(); i++) {
            eitList[i].Engagement__c = e.Id;
            eitList[i].Contact__c = managerList[i].Id;
            eitList[i].Staff_Role__c = sr.Id;
        }
        
        insert eitList;
        
                
        Test.startTest();
        

        Engagement_External_Team__c eet = SL_TestSetupUtils.CreateEET('', 1)[0];
        eet.Contact__c = externalContact.Id;
        eet.Engagement__c = e.Id;
        eet.Party__c = 'Buyer';        
        insert eet;

        ApexPages.StandardController sc = new ApexPages.StandardController(es);
        Test.setCurrentPage(new PageReference('/' + es.id));
        HL_CF_EngagementSummaryController esc = new HL_CF_EngagementSummaryController(sc);
        List<Engagement_External_Team__c> sellerTeam = esc.SellerContacts;
        List<Engagement_External_Team__c> etList = esc.ExternalTeam;
        List<Debt_Structure__c> dsList = esc.DebtStructures;
        List<HL_CF_EngagementSummaryController.CapitalizationRecord> capitalizationList = esc.CapitalizationRecords;
        List<Engagement_Counterparty__c> wcList = esc.WinningCounterparties;
        List<Engagement_Counterparty_Contact__c> ccList = esc.CounterpartyContacts;

        //Fix Required Errors

        //Winning Counterparty Required
        Engagement_Counterparty__c ec = SL_TestSetupUtils.CreateEC('', 1)[0];
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id;
        ec.Closing_Round_Bid_Date__c = Date.today();
        insert ec;

        esc.WinningCounterparties = null;
        //Winning Counterparty Fields Required
        ec.Process_Type__c = 'Process Type';
        ec.Platform_Type__c = 'Platform Type';
        update ec;
        esc.WinningCounterparties = null;

        //Sellside Fields Required
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Seller_Detail_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Public Company Process
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Public_Company_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Purchase Price and Structure Fields Required
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Purchase_Price_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), null);
        }

        //Key Contract Terms Required
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Key_Contract_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Employee Terms
        for (FieldSetMember fsm : SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Employee_Terms_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.DOUBLE)
                es.put(fsm.getFieldPath(), 0);
            else
                es.put(fsm.getFieldPath(), 'N/A');
        }

        //Credit Facility
        es.No_Credit_Facility_Data__c = true;

        update es;

        Debt_Structure__c ds = esc.NewDebtStructure;
        esc.SaveNewDebtStructure();

        esc.SubmitForApproval();
        esc.PrepareApprovalSubmission();

        

        System.runAs(userList[1]) {
            esc.ApproveProcess();
        }

        System.runAs(userList[2]) {
            esc.ApproveProcess();
        }

        Test.stopTest();

        //Confirm no Error Messages
        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
    }

    @isTest private static void TestOtherFunctionality() {
 
        //nara:11142019 - custom setting related to Oracle ERP Project. 
        /*HL_Auto_Number_Settings__c setting = new HL_Auto_Number_Settings__c();
        setting.Name = 'Account';
        setting.Auto_Number__c = 100001;
        insert setting;*/
           
        //Setup the Test Data
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert e;
        Engagement_Summary__c es = new Engagement_Summary__c(Engagement__c = e.Id);
        es.No_Credit_Facility_Data__c = false;
        insert es;
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert a;

        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(es);
        Test.setCurrentPage(new PageReference('/' + es.id));
        HL_CF_EngagementSummaryController esc = new HL_CF_EngagementSummaryController(sc);
        List<Engagement_External_Team__c> sellerTeam = esc.SellerContacts;
        List<Engagement_External_Team__c> etList = esc.ExternalTeam;
        List<Debt_Structure__c> dsList = esc.DebtStructures;
        List<HL_CF_EngagementSummaryController.CapitalizationRecord> capitalizationList = esc.CapitalizationRecords;
        List<Engagement_Counterparty__c> wcList = esc.WinningCounterparties;
        List<Engagement_Counterparty_Contact__c> ccList = esc.CounterpartyContacts;
        esc.SaveAll();
        esc.SaveAndReturn();
        es.No_Credit_Facility_Data__c = true;
        es.Purchase_Type__c = 'Purchase Type';
        es.Took_338_Selection__c = 'Yes';
        es.Purchase_Price_Base__c = 0;
        es.Seller_Had_Incentive_Plan__c = 'Yes';
        es.Required_Rollover_Equity__c = 'Yes';
        es.Was_Earnout_Included__c = 'No';
        es.Consideration_Seller_Notes__c = 1.0;
        update es;
        //Debt Structure Required
        Debt_Structure__c ds = esc.NewDebtStructure;
        esc.SaveNewDebtStructure();
        esc.RefreshCreditFacilities();
        //Insert a Lender
        Engagement_Client_Subject__c lender = new Engagement_Client_Subject__c(Engagement__c = e.Id, Client_Subject__c = a.Id, Other_Related_Object_Id__c = ds.Id, Type__c = 'Key Creditor');
        insert lender;
        capitalizationList = esc.CapitalizationRecords;
        List<Engagement_Client_Subject__c> lenders = capitalizationList[0].Lenders;
        //Should now have our lender
        System.assert(lenders.size() == 1);
        //Winning Counterparty Required
        Engagement_Counterparty__c ec = SL_TestSetupUtils.CreateEC('', 1)[0];
        ec.Engagement__c = e.Id;
        ec.Company__c = a.Id;
        ec.Closing_Round_Bid_Date__c = Date.today();
        insert ec;
        esc.WinningCounterparties = null;
        //Winning Counterparty Process Type Required
        esc.SubmitForApproval();
        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
        ec.Process_Type__c = 'Process Type';
        update ec;
        esc.WinningCounterparties = null;

        esc.CancelAction();
        esc.RefreshSellerTeam();
        esc.DelId = ds.Id;
        esc.DeleteDebtStructure();

        String warningMessages = esc.WarningMessage;
        String approvalStatus = esc.ApprovalStatus;

        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
        System.assert(!String.isBlank(warningMessages));
        System.assert(String.isBlank(approvalStatus));
    }
}