@isTest
private class Test_HL_EngagementOfficeSplitEditCon {
    @testSetup
    private static void CreateData() {
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        insert e;
        
        List<Engagement_Office_Split__c> elsList = new List<Engagement_Office_Split__c> {new Engagement_Office_Split__c(Engagement__c = e.Id, Office__c = 'CF', Office_Split__c = 80.0),
            new Engagement_Office_Split__c(Engagement__c = e.Id, Office__c = 'FVA', Office_Split__c = 20.0)
            };
                insert elsList;
    }
    
    @isTest
    private static void TestOfficeSplitOverrideSave() {
        Engagement_Office_Split__c els = [SELECT Engagement__c FROM Engagement_Office_Split__c LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(els);
        Test.setCurrentPage(new PageReference('/apex/HL_EngagementOfficeSplitEdit?Id=' + els.id));
        
        HL_EngagementOfficeSplitEditController con = new HL_EngagementOfficeSplitEditController(sc);
        
        List<String> SplitTypeList = con.SplitTypeList;
        
        //Override both to 50%
        con.OverrideOfficeSplitList[0].Percent = 50.0;
        con.OverrideOfficeSplitList[1].Percent = 50.0;
        
        con.SaveRecords();
        
        Test.stopTest();
        
        //Verify the Properties were Updated
        System.assertEquals(els.Engagement__c, con.EngagementId);
        System.assertEquals(2, con.EngagementOfficeSplitList.size());
        System.assertEquals(2, con.OfficeSplitList.size());
        System.assertEquals(2, con.OverrideOfficeSplitList.size());
        
        //Verify the Save was Successful
        for (Engagement_Office_Split__c split : [SELECT Office_Split_Override_Percent__c
                                                 FROM Engagement_Office_Split__c]) {
                                                     System.assertEquals(50.0, split.Office_Split_Override_Percent__c);
                                                 }
    }
    
    @isTest
    private static void TestOfficeSplitOverrideSaveBackToNull() {
        Engagement_Office_Split__c els = [SELECT Engagement__c FROM Engagement_Office_Split__c LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(els);
        Test.setCurrentPage(new PageReference('/apex/HL_EngagementOfficeSplitEdit?Id=' + els.id));
        
        HL_EngagementOfficeSplitEditController con = new HL_EngagementOfficeSplitEditController(sc);
        
        List<String> SplitTypeList = con.SplitTypeList;
        
        //Override both to 50%
        con.OverrideOfficeSplitList[0].Percent = 50.0;
        con.OverrideOfficeSplitList[1].Percent = 50.0;
        
        con.SaveRecords();
        
        con.OverrideOfficeSplitList[0].Percent = null;
        con.OverrideOfficeSplitList[1].Percent = null;
        
        con.SaveRecords();
        
        Test.stopTest();
        
        //Verify the Save was Successful and Override Results are Back to 0
        for (Engagement_Office_Split__c split : [SELECT Office_Split_Override_Percent__c
                                                 FROM Engagement_Office_Split__c]) {
                                                     System.assertEquals(0, split.Office_Split_Override_Percent__c);
                                                 }
    }
    
    @isTest
    private static void TestOfficeSplitOverrideSaveErrorDMLException() {
        Engagement_Office_Split__c els = [SELECT Engagement__c FROM Engagement_Office_Split__c LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(els);
        Test.setCurrentPage(new PageReference('/apex/HL_EngagementOfficeSplitEdit?Id=' + els.id));
        
        HL_EngagementOfficeSplitEditController con = new HL_EngagementOfficeSplitEditController(sc);
        
        //Override both to 50%
        con.OverrideOfficeSplitList[0].Percent = 50.0;
        con.OverrideOfficeSplitList[1].Percent = 50.0;
        
        //Delete the Records Before Save
        delete [SELECT Id FROM Engagement_Office_Split__c];
        
        con.SaveRecords();
        
        Test.stopTest();
        
        //Verify an Error is Displayed
        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
    }
    
    @isTest
    private static void TestOfficeSplitOverrideSaveErrorAbove100() {
        Engagement_Office_Split__c els = [SELECT Engagement__c FROM Engagement_Office_Split__c LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(els);
        Test.setCurrentPage(new PageReference('/apex/HL_EngagementOfficeSplitEdit?Id=' + els.id));
        
        HL_EngagementOfficeSplitEditController con = new HL_EngagementOfficeSplitEditController(sc);
        
        //Override both to 75%
        con.OverrideOfficeSplitList[0].Percent = 75.0;
        con.OverrideOfficeSplitList[1].Percent = 75.0;
        
        con.SaveRecords();
        
        Test.stopTest();
        
        //Verify an Error is Displayed
        System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
        
        //Verify the Save was not Successful
        for (Engagement_Office_Split__c split : [SELECT Office_Split_Override_Percent__c
                                                 FROM Engagement_Office_Split__c]) {
                                                     System.assertNotEquals(75.0, split.Office_Split_Override_Percent__c);
                                                 }
    }
    
    @isTest
    private static void TestOfficeSplitOverrideCancel() {
        Engagement_Office_Split__c els = [SELECT Engagement__c FROM Engagement_Office_Split__c LIMIT 1];
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(els);
        Test.setCurrentPage(new PageReference('/apex/HL_EngagementOfficeSplitEdit?Id=' + els.id));
        
        HL_EngagementOfficeSplitEditController con = new HL_EngagementOfficeSplitEditController(sc);
        
        //Override both to 50%
        con.OverrideOfficeSplitList[0].Percent = 50.0;
        con.OverrideOfficeSplitList[1].Percent = 50.0;
        
        con.CancelAndReturn();
        
        Test.stopTest();
        
        //Verify the Properties were Updated
        System.assertEquals(els.Engagement__c, con.EngagementId);
        System.assertEquals(2, con.EngagementOfficeSplitList.size());
        System.assertEquals(2, con.OfficeSplitList.size());
        System.assertEquals(2, con.OverrideOfficeSplitList.size());
        
        //Verify the Save did not happen
        for (Engagement_Office_Split__c split : [SELECT Office_Split_Override_Percent__c
                                                 FROM Engagement_Office_Split__c]) {
            System.assertNotEquals(50.0, split.Office_Split_Override_Percent__c);
        }
        
    }
}