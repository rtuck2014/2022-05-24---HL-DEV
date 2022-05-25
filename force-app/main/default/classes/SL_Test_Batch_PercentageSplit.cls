@isTest
public class SL_Test_Batch_PercentageSplit{
    
    @testSetup static void setup(){
        Date previousMonthDate = System.Today().toStartOfMonth().addDays(-1);
        HL_General__c hg =  new HL_General__c();
        insert hg;
        
        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert clientAccount;
        
        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert subjectAccount;
        List<Engagement__c> eFR = new List<Engagement__c>();
        List<Contact> c = new List<Contact>();
        Id hlEmpId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Houlihan_Employee').getRecordTypeId();
        for(Integer i = 0; i < 2; i++){
            eFR.add(new Engagement__c(
                Name='Test FVA Engagement ' +i,
                Engagement_Number__c = '123456'+i,
                Client__c = clientAccount.Id,
                Subject__c = subjectAccount.Id,
                Stage__c = 'Retained',
                Line_of_Business__c = 'FR',
                Job_Type__c = 'Fairness',
                Primary_Office__c = 'NY',
                Recalculate_Deal_Percentages__c=true
            ));
            c.add(new Contact(FirstName = 'ABC ' +i, Line_Of_Business__c = 'FVA', LastName = 'XYZ '+i, RecordTypeId =hlEmpId,
                              AccountId = subjectAccount.Id, Email = 'abc@testxyz.com'));
            
        }
        insert eFR;
        insert c;
        
        List<Id> engIds = new List<Id>();
        for(Engagement__c e1 : eFR){
            engIds.add(e1.Id);
        }
        List<Id> cIds = new List<Id>();
        for(Contact c1 : c){
            cIds.add(c1.Id);
        }
        Map<Id, Engagement__c> mapEngagement = new Map<Id, Engagement__c>([SELECT Id, Engagement_Number__c FROM Engagement__c where ID In: engIds]);
        Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, LastName, Line_Of_Business__c FROM Contact where Id =: cIds]);
        
        List<Engagement_Internal_Team__c> eit1 = new List<Engagement_Internal_Team__c>();
        List<Revenue_Accrual__c> raNew = new List<Revenue_Accrual__c>();

        Staff_Role__c sr = new Staff_Role__c(Name='Seller');
        insert sr;
        
        for(Id e : mapEngagement.keySet()){
            for(Id con : mapContact.keySet()){
                eit1.add(new Engagement_Internal_Team__c(Engagement__c = e, 
                                                         Staff_Role__c = sr.Id, Contact__c = con, 
                                                         Staff_Revenue_Split__c = 0.15,
                                                         Office__c = 'LO',
                                                         LOB__c = 'FVA',
                                                         End_Date__c = Date.today().addDays(-3)
                                                         ));
            }
        }
        insert eit1;
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c();
        
        Monthly_Revenue_Process_Control__c mrpc = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                                                         Current_Month__c = '10', Current_Year__c = '2020', Revenue_Date__c=previousMonthDate, Staff_Summary_Report_Sent__c = false);
        insert mrpc;
        
        for(Id e : mapEngagement.keySet()){
            raNew.add(new Revenue_Accrual__c(Engagement__c = e,Monthly_Revenue_Process_Control__c = mrpc.Id,
                                             Actual_Monthly_Fee__c = 100000, Actual_Transaction_Fee__c = 200000, Total_Estimated_Fee__c = 250000));
            
        }
        insert raNew;
        Revenue_Accrual__c rRec = [SELECT Id, Actual_Monthly_Fee__c FROM Revenue_Accrual__c Where Id =: raNew[0].Id];
        
        List<Staffing_Details__c> sdNew = new List<Staffing_Details__c>();
        
        for(Id e : mapEngagement.keySet()){
            for(Id con2 : mapContact.keySet()){
                sdNew.add(new Staffing_Details__c(Engagement__c = e, Revenue_Accrual__c = rRec.Id,
                                                  Contact__c = con2, Staff_LOB__c = 'FVA', Role_Allocation__c = 0.25));
            } 
        }
        insert sdNew;
    }
    
    @isTest static void runBatch1(){
        Test.startTest();
        SL_Batch_PercentageSplit bps = new SL_Batch_PercentageSplit();
        Id batchId = Database.executeBatch(bps);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //    System.assertNotEquals(0, [select count() from Engagement_LOB_Split__c where Name = 'Test FVA Engagement 1']);
    }
    
}