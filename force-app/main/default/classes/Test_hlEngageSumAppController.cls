@isTest
public with sharing class Test_hlEngageSumAppController {
    @isTest private static void hlBasicTest() {
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        a.Ownership = 'Private';
        insert a;
        //LL20191114 - Added to custom setting creation temporarily in SF Test to accommodate parallel testing with ERP Changes present
        /*HL_Auto_Number_Settings__c setting = new HL_Auto_Number_Settings__c();
        setting.Name = 'Account';
        setting.Auto_Number__c = 100001;
        insert setting;*/
        //----
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Test_Houlihan', 1)[0];
        e.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Sellside').getRecordTypeId();
        e.Client__c = a.Id;
        e.Subject__c = a.Id;
        insert e;
        Engagement_Summary__c es = new Engagement_Summary__c(Engagement__c = e.Id);
        es.No_Credit_Facility_Data__c = false;
        insert es;
        Staff_Role__c sr = new Staff_Role__c(Name = 'Manager', Engagement__c = true);
        insert sr;
        Contact c = SL_TestSetupUtils.CreateContact('engageSumApp', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        insert c;
        User u = [SELECT Id FROM User WHERE Id = :c.User__c LIMIT 1];
        es.Approver_01__c = u.Id;
        es.Approver_02__c = u.Id;
        es.Approver_03__c = u.Id;
        es.Approver_04__c = u.Id;
        es.Approver_05__c = u.Id;
        es.Approver_06__c = u.Id;
        es.Approver_07__c = u.Id;
        es.Approver_08__c = u.Id;
        update es;
        User u2 = SL_TestSetupUtils.createUser('engageSumApp2',1)[0];
        Profile p  = [Select Id from Profile Where Name = 'Standard User Template'];
        u2.Lastname = 'User';
        u2.Email = 'tuser@yahoo.in';
        u2.Username = 'test@hl2.com';
        u2.ProfileId = p.Id;
        u2.Alias = 'tuser';
        u2.TimeZoneSidKey = 'GMT';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'ISO-8859-1';
        u2.LanguageLocaleKey = 'en_US';
        u2.Has_Delegates__c = false;
        insert u2;
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
        eet.Party__c = 'Seller';
        insert eet;
        Engagement_Financials__c ef = new Engagement_Financials__c();
        ef.Related_Engagement__c = e.Id;
        ef.Revenue_LTM_MM__c = 1;
        ef.EBITDA_LTM_MM__c = 1;
        insert ef;
        //LL20190729 - SOQL limits being reached due to triggers handlers
        // List<Engagement_Counterparty__c> ecps = SL_TestSetupUtils.CreateEC('',1);
        // ecps[0].Engagement__c = e.Id;
        // ecps[0].Closing_Round_Bid_Date__c = Date.today();
        // insert ecps;
        Debt_Structure__c deb = new Debt_Structure__c();
        deb.Engagement__c = e.Id;
        insert deb;
        Test.startTest();
        Engagement_Client_Subject__c ecs = new Engagement_Client_Subject__c();
        ecs.Client_Subject__c = a.Id;
        ecs.Engagement__c = e.Id;
        ecs.Type__c = 'Key Creditor';
        ecs.Debt_Structure__c = deb.Id;
        insert ecs;
            List<Engagement_Summary__c> esm = hlEngageSumAppController.getEngagementSummary(e.Id);
            System.debug('esm:' + esm != null);
            List<Engagement_Internal_Team__c> ets = hlEngageSumAppController.getEngageTeam(e.Id, 'Name', 'ASC', new List<String>{'Manager'});
            System.debug('ets.size:' + ets.size());
            List<String> ewcs = hlEngageSumAppController.getWinCounterparties(e.Id);
            System.debug('ewcs.size:' + ewcs.size());
            List<Engagement_External_Team__c> exts = hlEngageSumAppController.getEngageContacts(e.Id, 'Seller', new List<String>{''}, new List<String>{''}, 'Name', 'ASC');
            System.debug('exts.size:' + exts.size());
            List<Engagement_Financials__c> efs = hlEngageSumAppController.getEngageFinancials(e.Id, 'Name', 'ASC');
            System.debug('efs.size:' + efs.size());
            List<Engagement_Counterparty__c> ecbs = hlEngageSumAppController.getCounterpartyBidList(e.Id);
            System.debug('ecbs.size:' + ecbs.size());
            List<Debt_Structure__c> debs = hlEngageSumAppController.getDebtStructures(e.Id, 'Name', 'ASC');
            System.debug('debs.size:' + debs.size());
            List<Engagement_Client_Subject__c> ecls = hlEngageSumAppController.getClientSubjectLenders(deb.Id, 'Name', 'ASC');
            System.debug('debs.size:' + debs.size());
            String submit1 =  hlEngageSumAppController.doEngageSumApprovalSubmit(es.Id, 'Test Comment');
            System.debug('approval-submit1:' + submit1);
            String recall = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Recall', 'Test Comment');
            System.debug('approval-recall:' + recall);
            String submit2 =  hlEngageSumAppController.doEngageSumApprovalSubmit(es.Id, 'Test Comment');
            System.debug('approval-submit2:' + submit2);
            String approve;
            String approveUnlock;
            String approveQuick;
            Boolean approveOverride;
            System.runAs(u){
                approve = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Approve', 'Test Comment');
                System.debug('approval-approve:' + approve);
                approveUnlock = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Unlock', 'Test Comment');
                System.debug('approval-approveUnlock:' + approveUnlock);
                approveQuick = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Quick', 'Test Comment');
                System.debug('approval-approveQuick:' + approveQuick);
                approveOverride = hlEngageSumAppController.getEngageSumApprovalOverride();
                System.debug('approval-approveOverride:' + approveOverride);
            }
            String approveE;
            String approveRE;
            String approveUnlockE;
            String approveQuickE;
            System.runAs(u2){
                approveE = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Approve', 'Test Comment');
                System.debug('approval-approve:' + approveE);
                approveUnlockE = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Unlock', 'Test Comment');
                System.debug('approval-approveUnlockE:' + approveUnlockE);
                approveRE = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Approve', 'Test Comment');
                System.debug('approval-approve:' + approveE);
                approveQuickE = hlEngageSumAppController.doEngageSumApprovalNext(es.Id, 'Quick', 'Test Comment');
                System.debug('approval-approveQuickE:' + approveQuickE);
            }
            List<hlUniversalApprovalController.ApprovalWrap> aws = hlUniversalApprovalController.getApprovalHistory(es.Id);

        Test.stopTest();
        System.assert(esm.size() > 0);
        System.assert(ets.size() > 0);
        System.assert(ewcs.size() >= 0);
        System.assert(exts.size() > 0);
        System.assert(efs.size() > 0);
        System.assert(ecbs.size() >= 0);
        System.assert(debs.size() > 0);
        System.assert(ecls.size() > 0);
        System.assert(submit1 != null);
        System.assert(submit2 != null);
        System.assert(recall != null);
        System.assert(approve != null);
        System.assert(approveUnlock != null);
        System.assert(approveQuick != null);
        System.assert(approveE != null);
        System.assert(approveUnlockE != null);
        System.assert(approveQuickE != null);
    }

    @isTest
    static void GetEngagementRecordTypeInfo(){
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        a.Ownership = 'Private';
        insert a;

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Test_Houlihan', 1)[0];
        e.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Sellside').getRecordTypeId();
        e.Client__c = a.Id;
        e.Subject__c = a.Id;
        insert e;
        Engagement__c es = [SELECT Record_Type_Name__c FROM Engagement__c WHERE Id =: e.Id LIMIT 1];
        System.debug(' Engagement Id is ' + es);
        List<Engagement__c> results = hlEngageSumAppController.getEngagementRec(String.valueOf(e.Id));
        Engagement__c es2 = [SELECT Record_Type_Name__c FROM Engagement__c WHERE Id =: results[0].Id LIMIT 1];
        System.assertEquals(es.Record_Type_Name__c, es2.Record_Type_Name__c);
        
    }
}