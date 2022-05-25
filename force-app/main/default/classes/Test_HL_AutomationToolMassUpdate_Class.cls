/*
test class for HL_AutomationToolMassUpdate_Class 
Author : Himanshu Sharma
*/
@istest

private class Test_HL_AutomationToolMassUpdate_Class{
    
    @testSetup static void setup() {        
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
        
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        e.Client__c = client.Id;
        e.Subject__c = subject.Id;
        insert e;
        
        Eng_VP__c testEngVP = new Eng_VP__c(); 
        testEngVP .Valuation_Date__c = system.today(); 
        testEngVP.Engagement__c = e.id; 
        insert testEngVP; 
        
    }
    
    @isTest static void myUnitTest1() {
        
        Eng_VP__c  testEngVP = [Select id from Eng_VP__c Limit 1 ]; 
        Account testClient = [Select id from Account where Name = 'TestClient' ];
        List<Eng_VP_Position__c> vppList = new List<Eng_VP_Position__c>();
        
        Test.StartTest();
            Eng_VP_Position__c testPosition = new Eng_VP_Position__c();        
            testPosition.Engagement_VP__c = testEngVP.id;
            testPosition.Company__c = testClient .id; 
            testPosition.Report_Fee__c = 100.0;
            testPosition.Asset_Classes__c = 'Equity';
            testPosition.Status__c = 'In Progress';
            testPosition.Automation_Tool_Utilized__c = 'No';
            insert testPosition;
            vppList.add(testPosition);
            
            HL_AutomationToolMassUpdate_Class objHLAutomationToolMassUpdate = new HL_AutomationToolMassUpdate_Class();
            objHLAutomationToolMassUpdate.VPPostionList = vppList;
            objHLAutomationToolMassUpdate.SavePosition();
            objHLAutomationToolMassUpdate.CancelPosition();
        Test.StopTest();  
        
        System.assertNotEquals(testPosition.id, null );
        System.assert(objHLAutomationToolMassUpdate.VPPostionList.size()>0);
    }
    
    @isTest static void myUnitTest2() {
        
        Eng_VP__c  testEngVP = [Select id from Eng_VP__c Limit 1 ]; 
        Account testClient = [Select id from Account where Name = 'TestClient' ];
        List<Eng_VP_Position__c> vppList = new List<Eng_VP_Position__c>();
        
        Test.StartTest();
            Eng_VP_Position__c testPosition = new Eng_VP_Position__c();        
            testPosition.Engagement_VP__c = testEngVP.id;
            testPosition.Company__c = testClient .id; 
            testPosition.Report_Fee__c = 100.0;
            testPosition.Asset_Classes__c = 'Equity';
            testPosition.Status__c = 'In Progress';
            testPosition.Automation_Tool_Utilized__c = 'Yes';
            insert testPosition;
            vppList.add(testPosition);
            
            HL_AutomationToolMassUpdate_Class objHLAutomationToolMassUpdate = new HL_AutomationToolMassUpdate_Class();
            objHLAutomationToolMassUpdate.VPPostionList = vppList;
            objHLAutomationToolMassUpdate.SavePosition();
            objHLAutomationToolMassUpdate.CancelPosition();
        Test.StopTest();  
        
        System.assertNotEquals(testPosition.id, null );
        System.assert(objHLAutomationToolMassUpdate.VPPostionList.size()>0);
    }
    
}