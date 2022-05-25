@isTest
private class Test_HL_MonthlyRevProcessControlHandler {
    @isTest static void TestUpdateRecord(){
        HL_General__c hg =  new HL_General__c();
        insert hg;

        Account clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert clientAccount;

        Account subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert subjectAccount;

        Engagement__c eFVA = new Engagement__c(
                                                Name='Test FVA Engagement',
                                                Engagement_Number__c = '123456',
                                                Client__c = clientAccount.Id,
                                                Subject__c = subjectAccount.Id,
                                                Stage__c = 'Retained',
                                                Line_of_Business__c = 'FVA',
                                                Job_Type__c = 'Fairness',
                                                Primary_Office__c = 'NY'
                                              );
        insert eFVA;

        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c();
            
        Monthly_Revenue_Process_Control__c mrpc = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpc;

        Revenue_Accrual__c raNew = new Revenue_Accrual__c(Engagement__c = eFVA.Id,
                                                              Period_Accrued_Fees__c = 100000, Total_Estimated_Fee__c = 250000);
        insert raNew;

        hg.Revenue_Accrual_Locked__c = true;
        update hg;

        Test.startTest();

        //Test the Unlock and Clearing of the Current Revenue Accrual Fields
        mrpc.Revenue_Accruals_Locked__c = true;
        mrpc.Staff_Summary_Report_Sent__c = true;
        update mrpc;

        Test.stopTest();

        mrpc = [SELECT IsCurrent__c, Revenue_Accruals_Locked__c FROM Monthly_Revenue_Process_Control__c WHERE Id =: mrpc.Id];
        //Verify the current and locked fields are unchecked
        System.assertEquals(false, mrpc.IsCurrent__c);
        System.assertEquals(false, mrpc.Revenue_Accruals_Locked__c);
        //Verify that the next Monthly Revenue Process Control was created
        mrpcNew = [SELECT Current_Month__c, Current_Year__c FROM Monthly_Revenue_Process_Control__c WHERE IsCurrent__c = true];
        System.assertEquals('03', mrpcNew.Current_Month__c);
        System.assertEquals('2015', mrpcNew.Current_Year__c);
        //Verify the Current Revenue Accrual and Period Accrued Fee Fields on the Engagement have been cleared
        //The Current Revenue Accrual value should have been moved to the Latest Revenue Accrual value
        eFVA = [SELECT Current_Revenue_Accrual__c, Latest_Revenue_Accrual__c, Period_Accrued_Fees__c, Actual_Monthly_Fee__c, Actual_Transaction_Fee__c 
                FROM Engagement__c WHERE Id =: eFVA.Id];
        System.assert(String.isBlank(eFVA.Current_Revenue_Accrual__c));
       // System.assertEquals(null, eFVA.Period_Accrued_Fees__c);
        System.assertEquals(null, eFVA.Actual_Monthly_Fee__c);
        System.assertEquals(null, eFVA.Actual_Transaction_Fee__c);
        System.assertEquals(raNew.Id, eFVA.Latest_Revenue_Accrual__c);
    }

    @isTest static void TestUpdateFRResetRevenueProjection(){
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

        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c();
            
        Monthly_Revenue_Process_Control__c mrpc = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpc;

        Revenue_Accrual__c raNew = new Revenue_Accrual__c(Engagement__c = eFR.Id,
                                                              Actual_Monthly_Fee__c = 100000, Actual_Transaction_Fee__c = 200000, Total_Estimated_Fee__c = 250000);
        insert raNew;

        Revenue_Projection__c newRevenueProjection = new Revenue_Projection__c(Line_of_Business__c = 'FR', Year__c = '2015', Month__c = '02', Engagement__c = eFR.Id, Projected_Monthly_Fee__c = 1000, Projected_Transaction_Fee__c = 200);

        insert newRevenueProjection;

        hg.Revenue_Accrual_Locked__c = true;
        update hg;

        Test.startTest();

        //Test the Unlock and Clearing of the Current Revenue Accrual Fields
        mrpc.Revenue_Accruals_Locked__c = true;
        mrpc.Staff_Summary_Report_Sent__c = true;
        update mrpc;

        Test.stopTest();

        mrpc = [SELECT IsCurrent__c, Revenue_Accruals_Locked__c FROM Monthly_Revenue_Process_Control__c WHERE Id =: mrpc.Id];
        //Verify the current and locked fields are unchecked
        System.assertEquals(false, mrpc.IsCurrent__c);
        System.assertEquals(false, mrpc.Revenue_Accruals_Locked__c);
        //Verify that the next Monthly Revenue Process Control was created
        mrpcNew = [SELECT Current_Month__c, Current_Year__c FROM Monthly_Revenue_Process_Control__c WHERE IsCurrent__c = true];
        System.assertEquals('03', mrpcNew.Current_Month__c);
        System.assertEquals('2015', mrpcNew.Current_Year__c);
        //Verify the Current Revenue Accrual and Period Accrued Fee Fields on the Engagement have been cleared
        //The Current Revenue Accrual value should have been moved to the Latest Revenue Accrual value
        eFR = [SELECT Current_Revenue_Accrual__c, Current_Revenue_Projection__c, Latest_Revenue_Accrual__c, Period_Accrued_Fees__c, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Projected_Total_Fee__c, Actual_Monthly_Fee__c, Actual_Transaction_Fee__c
                FROM Engagement__c WHERE Id =: eFR.Id];
     //   System.assert(String.isBlank(eFR.Current_Revenue_Accrual__c));
        System.assert(String.isBlank(eFR.Current_Revenue_Projection__c));
      //  System.assertEquals(null, eFR.Period_Accrued_Fees__c);
        System.assertEquals(null, eFR.Actual_Monthly_Fee__c);
        System.assertEquals(null, eFR.Actual_Transaction_Fee__c);
        System.assertEquals(null, eFR.Projected_Monthly_Fee__c);
        System.assertEquals(null, eFR.Projected_Transaction_Fee__c);
        System.assertEquals(null, eFR.Projected_Total_Fee__c);
        System.assertEquals(raNew.Id, eFR.Latest_Revenue_Accrual__c);
    }

    @isTest static void TestUpdateFRAssignUpdatedRevenueProjection(){
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

        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c();
            
        Monthly_Revenue_Process_Control__c mrpc = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpc;

        Revenue_Accrual__c raNew = new Revenue_Accrual__c(Engagement__c = eFR.Id,
                                                              Actual_Monthly_Fee__c = 100000, Actual_Transaction_Fee__c = 200000, Total_Estimated_Fee__c = 250000);
        insert raNew;

        Revenue_Projection__c newRevenueProjection = new Revenue_Projection__c(Year__c = '2015', Month__c = '02', Engagement__c = eFR.Id, Line_of_Business__c = 'FR', Projected_Monthly_Fee__c = 1000, Projected_Transaction_Fee__c = 200);

        insert newRevenueProjection;

        Revenue_Projection__c nextRevenueProjection = new Revenue_Projection__c(Year__c = '2015', Month__c = '03', Engagement__c = eFR.Id, Line_of_Business__c = 'FR', Projected_Monthly_Fee__c = 3000, Projected_Transaction_Fee__c = 400);

        insert nextRevenueProjection;

        hg.Revenue_Accrual_Locked__c = true;
        update hg;

        Test.startTest();

        //Test the Unlock and Clearing of the Current Revenue Accrual Fields
        mrpc.Revenue_Accruals_Locked__c = true;
        mrpc.Staff_Summary_Report_Sent__c = true;
        update mrpc;

        Test.stopTest();

        mrpc = [SELECT IsCurrent__c, Revenue_Accruals_Locked__c FROM Monthly_Revenue_Process_Control__c WHERE Id =: mrpc.Id];
        //Verify the current and locked fields are unchecked
        System.assertEquals(false, mrpc.IsCurrent__c);
        System.assertEquals(false, mrpc.Revenue_Accruals_Locked__c);
        //Verify that the next Monthly Revenue Process Control was created
        mrpcNew = [SELECT Current_Month__c, Current_Year__c FROM Monthly_Revenue_Process_Control__c WHERE IsCurrent__c = true];
        System.assertEquals('03', mrpcNew.Current_Month__c);
        System.assertEquals('2015', mrpcNew.Current_Year__c);
        //Verify the Current Revenue Accrual and Period Accrued Fee Fields on the Engagement have been cleared
        //The Current Revenue Accrual value should have been moved to the Latest Revenue Accrual value
        eFR = [SELECT Current_Revenue_Accrual__c, Current_Revenue_Projection__c, Latest_Revenue_Accrual__c, Period_Accrued_Fees__c, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Projected_Total_Fee__c, Actual_Monthly_Fee__c, Actual_Transaction_Fee__c
                FROM Engagement__c WHERE Id =: eFR.Id];
      //  System.assert(String.isBlank(eFR.Current_Revenue_Accrual__c));
        System.assert(String.isNotBlank(eFR.Current_Revenue_Projection__c));
      //  System.assertEquals(null, eFR.Period_Accrued_Fees__c);
        System.assertEquals(null, eFR.Actual_Monthly_Fee__c);
        System.assertEquals(null, eFR.Actual_Transaction_Fee__c); 
        System.assertEquals(nextRevenueProjection.Projected_Monthly_Fee__c, eFR.Projected_Monthly_Fee__c);
        System.assertEquals(nextRevenueProjection.Projected_Transaction_Fee__c, eFR.Projected_Transaction_Fee__c);
        System.assertEquals(nextRevenueProjection.Projected_Monthly_Fee__c + nextRevenueProjection.Projected_Transaction_Fee__c, eFR.Projected_Total_Fee__c);
        System.assertEquals(raNew.Id, eFR.Latest_Revenue_Accrual__c);
    }

    @isTest static void TestUpdateEnterMonthlyOfficeSplit(){
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

        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c();
            
        Monthly_Revenue_Process_Control__c mrpc = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpc;

        Revenue_Accrual__c raNew = new Revenue_Accrual__c(Engagement__c = eFR.Id,
                                                              Actual_Monthly_Fee__c = 100000, Actual_Transaction_Fee__c = 200000, Total_Estimated_Fee__c = 250000);
        insert raNew;

        Engagement_Office_Split__c eOS = new Engagement_Office_Split__c(Engagement__c = eFR.Id, Office__c = 'LA', Engagement_LOB__c = 'FVA', Office_Split__c = 100.00);
        
        insert eOS;
        
        Revenue_Projection__c newRevenueProjection = new Revenue_Projection__c(Year__c = '2015', Month__c = '02', Engagement__c = eFR.Id, Line_of_Business__c = 'FR', Projected_Monthly_Fee__c = 1000, Projected_Transaction_Fee__c = 200);

        insert newRevenueProjection;

        Revenue_Projection__c nextRevenueProjection = new Revenue_Projection__c(Year__c = '2015', Month__c = '03', Engagement__c = eFR.Id, Line_of_Business__c = 'FR', Projected_Monthly_Fee__c = 3000, Projected_Transaction_Fee__c = 400);

        insert nextRevenueProjection;

        hg.Revenue_Accrual_Locked__c = true;
        update hg;

        Test.startTest();

        //Test the Unlock and Clearing of the Current Revenue Accrual Fields
        mrpc.Revenue_Accruals_Locked__c = true;
        mrpc.Staff_Summary_Report_Sent__c = true;
        update mrpc;

        Test.stopTest();
        List<Revenue_Accrual_Office_Split__c> os = [SELECT Office__c, Office_Split__c, Engagement_LOB__c, Office_Split_Percent__c, Revenue_Accrual__c
                                                    FROM Revenue_Accrual_Office_Split__c 
                                                    WHERE Revenue_Accrual__c =: raNew.Id];

        System.assertEquals(os.size(), 1); 
        System.assertEquals(raNew.Id, os[0].Revenue_Accrual__c); 
        System.assertEquals(eOS.Office__c, os[0].Office__c); 
        System.assertEquals(eOS.Engagement_LOB__c, os[0].Engagement_LOB__c); 
        System.assertEquals(eOS.Office_Split__c, os[0].Office_Split__c); 
    }
    @isTest static void TestengagementSplitLOB(){
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
        
        Contact c = new Contact(FirstName = 'ABC', Line_Of_Business__c = 'FVA', LastName = 'XYZ', RecordTypeId ='012i0000000tEhe',
                               AccountId = subjectAccount.Id, Email = 'abc@testxyz.com');
		insert c;
        
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
    //    mrpc.Revenue_Accruals_Locked__c = true;
        mrpc.Staff_Summary_Report_Sent__c = true;
        update mrpc;

        Test.stopTest();
       // System.assertEquals(eOS.Engagement_LOB__c, os[0].Engagement_LOB__c); 
    }
}