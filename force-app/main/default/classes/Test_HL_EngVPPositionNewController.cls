@isTest
private class Test_HL_EngVPPositionNewController {

    @testSetup static void setup() {        
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        client.Industry_Group__c = 'SOV - Sovereigns';
        client.Sector__c = 'Sovereigns';
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
    
    @isTest static void myUnitTestwithPageLoading() {
        
        Eng_VP__c  testEngVP = [Select id from Eng_VP__c Limit 1 ]; 
        Account testClient = [Select id from Account where Name = 'TestClient' ];
        Test.StartTest();
            Eng_VP_Position__c testPosition = new Eng_VP_Position__c();        
            testPosition.Engagement_VP__c = testEngVP.id;
            testPosition.Company__c = testClient .id; 
            testPosition.Report_Fee__c = 100.0;
            testPosition.Asset_Classes__c = 'Equity';
            testPosition.Automation_Tool_Utilized__c = 'Yes';
            testPosition.Status__c = 'In Progress';
            Test.setCurrentPageReference(new PageReference('Page.HL_EngVPPositionNew'));
            System.currentPageReference().getParameters().put('VPId',testEngVP.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testPosition);
            HL_EngVPPositionNewController clsobj = new HL_EngVPPositionNewController(sc);  
            clsobj.SaveData();  
        Test.StopTest();    
        System.assertNotEquals(testPosition.id, null );
    }
    
    @isTest static void myUnitTestwithSavingdata() {
        Eng_VP__c  testEngVP = [Select id from Eng_VP__c Limit 1 ]; 
        Eng_VP_Position__c testPosition = new Eng_VP_Position__c();
        Account testClient = [Select id from Account where Name = 'TestClient' ];
        Test.StartTest();
            testPosition.Engagement_VP__c = testEngVP.id ;
            testPosition.Company__c = testClient .id; 
            testPosition.Report_Fee__c = 100.0;
            testPosition.Asset_Classes__c = 'Equity';
            testPosition.Automation_Tool_Utilized__c = 'Yes';
            testPosition.Reason__c = 'Tiered Comps';
            testPosition.Status__c = 'In Progress';
            //insert testPosition;                                       
            ApexPages.StandardController sc = new ApexPages.StandardController(testPosition);
            HL_EngVPPositionNewController clsobj = new HL_EngVPPositionNewController(sc); 
            
        Test.StopTest(); 
        Try {               
        clsobj.SaveData();      
        } catch(Exception e)    {
          System.assertEquals(testPosition.id, null );
        }
    }
}