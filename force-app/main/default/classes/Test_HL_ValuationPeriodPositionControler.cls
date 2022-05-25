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
private class Test_HL_ValuationPeriodPositionControler {

    @testSetup static void setup() {
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
               
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_' + String.valueOf(i);        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;      
        }
        insert accountList;
       
        List<Contact> testContactList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact',false,2);
        integer i = 0;        
        for(contact cont : testContactList) {
            cont.FirstName = 'TestFirst'+i;
            cont.LastName = 'testLastContact'+i;
            cont.AccountId = accountList[0].id;             
            i++;
        }
        insert testContactList;
        
        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accountList[0].Id;
        opportunity.Subject__c = accountList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'FVA';
        opportunity.Job_Type__c = 'FA - Portfolio-Valuation';
        opportunity.Primary_Office__c = 'AT';
        insert opportunity;
        
        List<Opportunity_Internal_Team__c> testHLTeamMemberList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c',false,2);      
        if(testHLTeamMemberList.size() == 2) { 
            testHLTeamMemberList[0].Opportunity__c = opportunity.id;
            testHLTeamMemberList[0].Contact__c = testContactList[0].id;     
            testHLTeamMemberList[1].Opportunity__c = opportunity.id;
            testHLTeamMemberList[1].Contact__c = testContactList[1].id;
        insert testHLTeamMemberList;
        }
        
        Opp_VP__c oppVP =(Opp_VP__c)HL_TestFactory.CreateSObject('Opp_VP__c',false);
        oppVP.Name='Test Opp Vp';        
        oppVp.Opportunity__c=opportunity.id;
        oppVP.Valuation_Date__c=System.Today();
        oppVp.CurrencyIsoCode='USD';        
        Insert oppVP; 
        
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        oppVPPos.Name=accountList[0].Id;
        oppVPPos.Company__c=accountList[0].Id;
        oppVPPos.Opportunity_VP__c=oppVP.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        insert oppVPPos;  
    }
    
     @isTest static void TestUnitWithoutTeamMembers() {
        Opp_VP_Position__c testoppVPPo = [SELECT Id,Company__c FROM Opp_VP_Position__c LIMIT 1];
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_ValuationPeriodPosition'));
            System.currentPageReference().getParameters().put('id',testoppVPPo.id) ;
            System.currentPageReference().getParameters().put('retURL',testoppVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testoppVPPo);
            HL_ValuationPeriodPositionController clsobj = new HL_ValuationPeriodPositionController(sc);
            clsobj.AddMember();
            clsobj.SaveTeamMembers();
            clsobj.RemoveMember();
            clsobj.Backtovp();
            clsobj.DummyReset();
            integer localallowedMember = clsobj.AllowedMembers;
            double myOffSet = clsobj.offset;
            String myProfileName = clsobj.userProfileName;
            system.assertNotEquals(myProfileName, null);
        Test.stopTest();
        System.assertNotEquals(clsobj.AllowedMembers, 0);
    }
    
     @isTest static void TestUnitWithTeamMembers() {
        
        Opp_VP_Position__c testoppVPPo = [SELECT Id,Company__c FROM Opp_VP_Position__c LIMIT 1];
        Opportunity__c testOpty = [select id from Opportunity__c Limit 1] ;
        Contact testCont = [select id from Contact where FirstName = 'TestFirst0' Limit 1];
        Test.startTest();
            List<Opp_VP_TeamMember__c> teamMemberList = (List<Opp_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Opp_VP_TeamMember__c', false, 3);        
            for(integer i = 0; i < teamMemberList.size(); i++){
                teamMemberList[i].Name = 'Test_' + String.valueOf(i);        
                teamMemberList[i].Opportunity_VP_Position__c = testoppVPPo.id;
                if(i == 0)
                    teamMemberList[i].Role__c = 'Analyst';
                else if(i == 1) 
                    teamMemberList[i].Role__c = 'Manager';
                else if(i == 2) 
                    teamMemberList[i].Role__c = 'Principal';                
                teamMemberList[i].Staff__c = testCont.Id;
            }
            insert teamMemberList;
            Test.setCurrentPageReference(new PageReference('Page.HL_ValuationPeriodPosition'));
            System.currentPageReference().getParameters().put('id',testoppVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testoppVPPo);
            HL_ValuationPeriodPositionController clsobj = new HL_ValuationPeriodPositionController(sc);
            integer localallowedMember = clsobj.AllowedMembers;
            clsobj.AddMember();
            clsobj.SaveTeamMembers();
            clsobj.selectItemSrNo = 1;
            clsobj.RemoveMember();
        Test.stopTest();
        // there is only one allowed as we have added one from here. 
        System.assertNotEquals(clsobj.AllowedMembers, 0);
    }
    
      @isTest static void TestgetterProperties() {
        Opp_VP_Position__c testoppVPPo = [SELECT Id,Company__c FROM Opp_VP_Position__c LIMIT 1];
        Opportunity__c testOpty = [select id from Opportunity__c Limit 1] ;        
        Contact testCont = [select id from Contact where FirstName = 'TestFirst0' Limit 1];
        Test.startTest();
            List<Opp_VP_TeamMember__c> teamMemberList = (List<Opp_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Opp_VP_TeamMember__c', false, 3);        
            for(integer i = 0; i < teamMemberList.size(); i++){
                teamMemberList[i].Name = 'Test_' + String.valueOf(i);        
                teamMemberList[i].Opportunity_VP_Position__c = testoppVPPo.id;
                if(i == 0)
                    teamMemberList[i].Role__c = 'Analyst';
                else if(i == 1) 
                    teamMemberList[i].Role__c = 'Manager';
                else if(i == 2) 
                    teamMemberList[i].Role__c = 'Principal';
                teamMemberList[i].Staff__c = testCont.Id;                
            }
            insert teamMemberList;
            Test.setCurrentPageReference(new PageReference('Page.HL_ValuationPeriodPosition'));
            System.currentPageReference().getParameters().put('id',testoppVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testoppVPPo);
            HL_ValuationPeriodPositionController clsobj = new HL_ValuationPeriodPositionController(sc);
            List<SelectOption> localHLInternalEmployees = clsobj.HLInternalEmployees ;
            String localparentId = clsobj.parentId ;
            clsobj.RefreshNewStaffRoles();
            clsobj.AddMember();
            for (HL_ValuationPeriodPositionController.VPTeamMember localvptm : clsobj.VPTeamMemberList) { 
                localvptm.OppVPTeamMember.End_Date__c = system.today() -1; 
            }
            clsobj.SaveTeamMembers();
        Test.stopTest();
        System.assertNotEquals(clsobj.VPTeamMemberList, null);
    }
    @isTest
    static void TestInlineEditing(){   
        Opp_VP_Position__c testEngVPPo = [SELECT Id,Company__c FROM Opp_VP_Position__c LIMIT 1];
        test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_ValuationPeriodPosition'));
            System.currentPageReference().getParameters().put('id',testEngVPPo.id) ;
            System.currentPageReference().getParameters().put('retURL',testEngVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testEngVPPo);
            HL_ValuationPeriodPositionController con = new HL_ValuationPeriodPositionController(sc);            
            con.FieldAPI = 'Name';
            con.DummyReset(); 
            con.OppVPPosition.Name = null;
            con.saveRc();
            con.FieldAPI = 'Asset_Classes__c';
            con.DummyReset();
            con.FieldAPI = 'Notes__c';
            con.DummyReset();
            con.FieldAPI = 'Report_Fee__c';
            con.DummyReset();
            con.FieldAPI = 'Status__c';
            con.DummyReset(); 
            con.FieldAPI = 'Company__c';
            con.DummyReset();
            double i = con.offset;
            con.DeleteRecord();   
            system.assertNotEquals(con.OppVPPosition.Name, null);          
        test.stopTest();
    } 
}