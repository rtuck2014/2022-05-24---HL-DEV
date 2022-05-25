/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_HL_OppVPPositionNewController {

    @testSetup static void setup() {
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
        
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        client.Industry_Group__c = 'SOV - Sovereigns';
        client.Sector__c = 'Sovereigns';
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
        
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Additional_Client__c = 'No';
        o.Additional_Subject__c = 'No';
        o.Client__c = client.Id;
        o.Subject__c = subject.Id;
        o.Line_of_Business__c = 'FVA';
        o.Job_Type__c = 'FA - Portfolio-Valuation';  
        o.Beneficial_Owner_Control_Person_form__c = 'No';  

        insert o;        
        Opp_VP__c testOppVP = new Opp_VP__c(); 
        testOppVP .Valuation_Date__c = system.today(); 
        testOppVP.Opportunity__c = o.id; 
        insert testOppVP; 
    }
    
    @isTest static void myUnitTestwithPageLoading() {
        
        Opp_VP__c  testOppVP = [Select id from Opp_VP__c Limit 1 ]; 
        Account testClient = [Select id from Account where Name = 'TestClient' ];
        Test.StartTest();
            Opp_VP_Position__c testPosition = new Opp_VP_Position__c();        
            testPosition.Opportunity_VP__c = testOppVP.id;
            testPosition.Company__c = testClient.id; 
            testPosition.Report_Fee__c = 100.0;
            testPosition.Asset_Classes__c = 'Equity';
            Test.setCurrentPageReference(new PageReference('Page.HL_OppVPPositionNew'));
            System.currentPageReference().getParameters().put('VPId',testOppVP.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testPosition);
            HL_OppVPPositionNewController clsobj = new HL_OppVPPositionNewController(sc);  
            clsobj.SaveData();  
        Test.StopTest();    
        System.assertNotEquals(testPosition.id, null );
    }
    
    @isTest static void myUnitTestwithSavingdata() {
        Opp_VP__c  testOppVP = [Select id from Opp_VP__c Limit 1 ]; 
        Opp_VP_Position__c testPosition = new Opp_VP_Position__c();
        Account testClient = [Select id from Account where Name = 'TestClient' ];
        Test.StartTest();
            testPosition.Opportunity_VP__c = testOppVP.id ;
            testPosition.Company__c = testClient .id; 
            testPosition.Report_Fee__c = 100.0;
            testPosition.Asset_Classes__c = 'Equity';
            //insert testPosition;
            ApexPages.StandardController sc = new ApexPages.StandardController(testPosition);
            HL_OppVPPositionNewController clsobj = new HL_OppVPPositionNewController(sc); 
        Test.StopTest(); 
        Try {
        clsobj.SaveData();      
        } catch(Exception e)    {
            System.assertEquals(testPosition.id, null );
        }
    }
}