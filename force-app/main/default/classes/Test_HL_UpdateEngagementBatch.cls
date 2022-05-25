@isTest
private class Test_HL_UpdateEngagementBatch{
    
    private static testmethod void testEngUpdateBatch(){
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
        
        List<Engagement__c> lstEngToUpdate = new List<Engagement__c>();
        //Change the Stage to 50% Complete
        eFVA_Stage50.Stage__c = 'Performing Analysis';
        lstEngToUpdate.add(eFVA_Stage50);
            Database.Executebatch(new HL_UpdateEngagementBatch(lstEngToUpdate));
        Test.stopTest();
        //Change the Stage to 100% Complete
        eFVA_Stage100.Final_Report_Sent_Date__c = Date.today();
        eFVA_Stage100.Stage__c = 'Bill/File';
        update eFVA_Stage100;
        
    }
    private static testmethod void testAsyncMonthlyProcessQueue(){
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
        
        
        Test.startTest();
        
        System.enqueueJob(new HL_AsyncMonthlyProcessControl(eFVA_List, true));
        
        Test.stopTest();
        
        
    }
 }