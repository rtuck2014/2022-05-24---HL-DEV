@isTest
private class Test_HL_PercentageSplitHandler {

    static void dataFactory() {
        List<Role_Split__c> lstSplit = SL_TestSetupUtils.CreateRoleSplit('Role_Split__c', 2);
        lstSplit[0].Percentage_Allocation__c = 15;

        lstSplit[1].Percentage_Allocation__c = 25; 
        lstSplit[1].Role__c = 'Initiator';

        insert lstSplit;
    }
    
    //Add three team members, 1 at at time and check the splits after each addition.
    @isTest
    static void singleAdditions() {
        dataFactory();

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        insert e;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        insert cList;

        Test.startTest();
        //Add 1 Team and check if the Perent is 15
        Engagement_Internal_Team__c et1 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0]; 
        et1.Contact__c = cList[0].Id;
        et1.Engagement__c = e.Id;
        et1.Start_Date__c = System.today() - 1;
        et1.End_Date__c = System.today() + 1;
        Staff_Role__c staffRole = new Staff_Role__c(Name='Principal',
                                                    Display_Name__c='Principal', 
                                                    Display_Order__c=1,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
        insert staffRole;
        et1.Staff_Role__c = staffRole.Id;
        insert et1;

        et1 = [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c Where Id = : et1.Id];
        System.assertEquals(null, et1.Staff_Revenue_Split__c, 'Wrong Percent Split');

        //Add another and check the split
        Engagement_Internal_Team__c et2 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0];
        et2.Contact__c = cList[1].Id;
        et2.Engagement__c = e.Id;
        et2.Start_Date__c = System.today() - 1;
        et2.End_Date__c = System.today() + 1;
        et2.Staff_Role__c = staffRole.Id;
        insert et2;

        for (Engagement_Internal_Team__c et : [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c WHERE Engagement__c=: e.Id]) {
            System.assertEquals(null, et.Staff_Revenue_Split__c, 'Wrong Percent Split');
        }

        //Add third record check the split
        Engagement_Internal_Team__c et3 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0];
        et3.Contact__c = cList[1].Id; 
        et3.Engagement__c = e.Id;
        et3.Start_Date__c = System.today() - 1;
        et3.End_Date__c = System.today() + 1;
        et3.Staff_Role__c = staffRole.Id;
        insert et3;

        for (Engagement_Internal_Team__c et : [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c WHERE Engagement__c=: e.Id]) {
            System.assertEquals(null, et.Staff_Revenue_Split__c, 'Wrong Percent Split');
        }

        Test.stopTest();
    }
    //Add All three team members in bulk, check the splits after all the inserts.
     @isTest
    static void bulkAdditions() {
        dataFactory();

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        insert e;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        insert cList;

        Test.startTest();
        
        Staff_Role__c staffRole = new Staff_Role__c(Name='Principal',
                                                    Display_Name__c='Principal', 
                                                    Display_Order__c=1,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
        insert staffRole;

        List<Engagement_Internal_Team__c> lstET = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',3);
        for(Engagement_Internal_Team__c et: lstEt)
        {            
            et.Engagement__c = e.Id;
            et.Staff_Role__c = staffRole.Id;
            et.End_Date__c = System.today() + 1;
            et.Start_Date__c = System.today() - 1;
        }

        lstEt[0].Contact__c = cList[0].Id;                
        lstEt[1].Contact__c = cList[1].Id;
        //Add third record check the split        
        lstEt[2].Contact__c = cList[1].Id;

        insert lstEt; 

        for (Engagement_Internal_Team__c et : [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c WHERE Engagement__c=: e.Id]) {
            System.assertEquals(null, et.Staff_Revenue_Split__c, 'Wrong Percent Split');
        }

        Test.stopTest();
    }
    //Add a team menber, check the split, delete it and undelete a team member and check the splits
     @isTest
    static void checkDeletionUndeletion() {
        dataFactory();

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        insert e;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        insert cList;

        Test.startTest();
        //Add 1 Team and check if the Perent is 15
        Engagement_Internal_Team__c et1 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0]; 
        et1.Contact__c = cList[0].Id;
        et1.Engagement__c = e.Id;
        et1.Start_Date__c = System.today() - 1;
        et1.End_Date__c = System.today() + 1;
        Staff_Role__c staffRole = new Staff_Role__c(Name='Principal',
                                                    Display_Name__c='Principal', 
                                                    Display_Order__c=1,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
        insert staffRole;
        et1.Staff_Role__c = staffRole.Id;
        insert et1;
        
        et1 = [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c Where Id = : et1.Id];
        System.assertEquals(null, et1.Staff_Revenue_Split__c, 'Wrong Percent Split');

        //Add another and check the split
        Engagement_Internal_Team__c et2 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0]; 
        et2.Contact__c = cList[1].Id;
        et2.Engagement__c = e.Id;        
        et2.Start_Date__c = System.today() - 1;
        et2.End_Date__c = System.today() + 1;
        et2.Staff_Role__c = staffRole.Id;
        insert et2;

        for (Engagement_Internal_Team__c et : [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c WHERE Engagement__c=: e.Id]) {
            System.assertEquals(null, et.Staff_Revenue_Split__c, 'Wrong Percent Split');
        }

       delete et1;
        

        et2 = [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c Where Id = : et2.Id];
        System.assertEquals(null, et1.Staff_Revenue_Split__c, 'Wrong Percent Split');

        Database.undelete(et1);

        for (Engagement_Internal_Team__c et : [Select Id, Staff_Revenue_Split__c from Engagement_Internal_Team__c WHERE Engagement__c=: e.Id]) {
            //System.assertEquals(7.5, et.Staff_Revenue_Split__c, 'Wrong Percent Split');
        }

        Test.stopTest();
    }
    
    @isTest
    static void checkbatchJob() {
        dataFactory();

        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];        
        e.Recalculate_Deal_Percentages__c = true;
        insert e;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        insert cList;
        
        Staff_Role__c staffRole = new Staff_Role__c(Name='Principal',
                                                    Display_Name__c='Principal', 
                                                    Display_Order__c=1,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
        insert staffRole;
        
        Engagement_Internal_Team__c et1 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0]; 
        et1.Contact__c = cList[0].Id;
        et1.Engagement__c = e.Id;
        et1.Start_Date__c = System.today() - 1;
        et1.End_Date__c = System.today() + 1;
        et1.Staff_Role__c = staffRole.Id;
        insert et1;
        
        Engagement_Internal_Team__c et2 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0]; 
        et2.Contact__c = cList[1].Id;
        et2.Engagement__c = e.Id;
        et2.Start_Date__c = System.today() - 1;
        et2.End_Date__c = System.today() + 1;
        et2.Staff_Role__c = staffRole.Id;
        insert et2;

        //Add third record check the split
        Engagement_Internal_Team__c et3 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0]; 
        et3.Contact__c = cList[1].Id;
        et3.Engagement__c = e.Id;
        et3.Start_Date__c = System.today() - 1;
        et3.End_Date__c = System.today() - 1;
        et3.Staff_Role__c = staffRole.Id;       
        insert et3;

        et3.Staff_Revenue_Split__c = 5;
        update et3;

        //Test.startTest();

        //String CRON_EXP = '0 0 0 15 3 ? 2022';
        //String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP, new SL_Scheduler_PercentageSplit());
        //e = [Select Recalculate_Deal_Percentages__c from Engagement__c where Id=: e.Id]; 
        //System.assertEquals(false, e.Recalculate_Deal_Percentages__c, 'Split not refreshed');    
   
        //Test.stopTest();
    }

    @isTest
    static void OfficeSplitRevenueAllocation() {
        dataFactory();
        
        List<Job_Type__c> listJobTypeSplit = new List<Job_Type__c>();
        
        Job_Type__c jt = new Job_Type__c();
        jt.Name = 'Fairness';
        jt.Job_Code__c = '5141';
        jt.Primary_Line_of_Business__c = 'FVA';
        jt.Role_Analyst_Percent__c = 0.1300;
        jt.Role_Associate_Percent__c = 0.1500;
        jt.Role_Initiator_Percent__c = 0.2100;
        jt.Role_Manager_Percent__c = 0.1900;
        jt.Role_Principal_Percent__c = 0.1800;
        jt.Role_Seller_Percent__c = 0.1400;
        
        insert jt;
        
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        e.Line_of_Business__c = 'FVA';
        e.Primary_Office__c = 'LA';
        e.Job_Type__c = 'Fairness';
        insert e;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 3, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        
        for(Contact c : cList) {
            c.Line_of_Business__c = 'FVA';
        }
        
        cList[0].Office__c = 'LA';  
        cList[0].Revenue_Allocation__c = 'LA-Leonardo';                
        cList[1].Office__c = 'LA';
        cList[2].Office__c = 'LO';  
        
        insert cList;

        Test.startTest();
        
        Staff_Role__c staffRole = new Staff_Role__c(Name='Principal',
                                                    Display_Name__c='Principal', 
                                                    Display_Order__c=1,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
 
        Staff_Role__c staffRole2 = new Staff_Role__c(Name='Initiator',
                                                    Display_Name__c='Initiator', 
                                                    Display_Order__c=2,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
        insert staffRole;
        insert staffRole2;

        List<Engagement_Internal_Team__c> lstET = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',3);
        for(Engagement_Internal_Team__c et: lstEt)
        {            
            et.Engagement__c = e.Id;
            et.Staff_Role__c = staffRole.Id;
            et.End_Date__c = System.today() + 1;
            et.Start_Date__c = System.today() - 1;
        }

        lstEt[0].Contact__c = cList[0].Id;                
        lstEt[1].Contact__c = cList[1].Id;   
        lstEt[2].Contact__c = cList[1].Id;
        lstEt[2].Staff_Role__c = staffRole2.Id;
        lstEt[2].Contact__c = cList[2].Id;
        
        insert lstEt; 

        Set<String> offices = new Set<String>();

        List<Engagement_Office_Split__c> os = [Select ID, Office__c from Engagement_Office_Split__c WHERE Engagement__c=: e.Id];
        
        for (Engagement_Office_Split__c o : os) {
            offices.add(o.Office__c);
        }

       // System.assertEquals(3, os.Size(), 'Office and Revenue Allocation are distinct.');
        System.assert(offices.Contains('LA'));
        System.assert(offices.Contains('LO'));
        System.assert(offices.Contains('LA-Leonardo'));

        Test.stopTest();
    }
    
    @isTest static void lobRecalculation(){
                        Date previousMonthDate = System.Today().toStartOfMonth().addDays(-1);
                HL_General__c hg =  new HL_General__c();
        insert hg;

        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert clientAccount;

        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert subjectAccount;

        Engagement__c eFR = new Engagement__c(
                                                Name='Test FVA Engagement',
                                                Engagement_Number__c = '123456',
                                                Client__c = clientAccount.Id,
                                                Subject__c = subjectAccount.Id,
                                                Stage__c = 'Retained',
                                                Line_of_Business__c = 'FR',
                                                Job_Type__c = 'Fairness',
                                                Primary_Office__c = 'NY'
                                              );
        insert eFR;
        Set<Id> engagementIds = new Set<Id>();
        engagementIds.add(eFR.Id);

        Id hlEmpId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Houlihan_Employee').getRecordTypeId();
        
        Contact c = new Contact(FirstName = 'ABC', Line_Of_Business__c = 'FVA', LastName = 'XYZ', RecordTypeId =hlEmpId,
                               AccountId = subjectAccount.Id, Email = 'abc@testxyz.com');
        insert c;
        
         Contact c1 = new Contact(FirstName = 'FFF', Line_Of_Business__c = 'CORP', LastName = 'XYZ', RecordTypeId =hlEmpId,
                               AccountId = subjectAccount.Id, Email = 'xxt@testxyz.com');
        insert c1;
        
        Staff_Role__c sr = new Staff_Role__c(Name='Seller');
        insert sr;

        Engagement_Internal_Team__c eit1 = new Engagement_Internal_Team__c(Engagement__c = eFR.Id, 
                                                                           Staff_Role__c = sr.Id, Contact__c = c.Id, 
                                                                           Staff_Revenue_Split__c = 0.15,
                                                                          Office__c = 'LO',
                                                                          LOB__c = 'FVA');
        insert eit1;
        
        
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c();
            
        Monthly_Revenue_Process_Control__c mrpc = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '10', Current_Year__c = '2020', Revenue_Date__c=previousMonthDate, Staff_Summary_Report_Sent__c = false);
        insert mrpc;

        Revenue_Accrual__c raNew = new Revenue_Accrual__c(Engagement__c = eFR.Id,
                                                              Actual_Monthly_Fee__c = 100000, Actual_Transaction_Fee__c = 200000, Total_Estimated_Fee__c = 250000);
        insert raNew;
        
        Staffing_Details__c sdNew = new Staffing_Details__c(Engagement__c = eFR.Id, Revenue_Accrual__c = raNew.Id,
                                                           Contact__c = c.Id, Staff_LOB__c = c.Line_Of_Business__c, Role_Allocation__c = 0.25);
        insert sdNew;
               Test.startTest();

        //Test the Unlock and Clearing of the Current Revenue Accrual Fields
        mrpc.Revenue_Accruals_Locked__c = true;
        mrpc.Staff_Summary_Report_Sent__c = true;
        update mrpc;
        
        HL_PercentageSplitHandler handler = new HL_PercentageSplitHandler();
        handler.RecalculateLOBSplits(engagementIds);
         Staffing_Details__c sdNew1 = new Staffing_Details__c(Engagement__c = eFR.Id, Revenue_Accrual__c = raNew.Id,
                                                           Contact__c = c1.Id, Staff_LOB__c = c.Line_Of_Business__c, Role_Allocation__c = 0.18);
        insert sdNew1;
                handler.RecalculateLOBSplits(engagementIds);

        Test.stopTest();
       // System.assertEquals(eOS.Engagement_LOB__c, os[0].Engagement_LOB__c); 
    }
}