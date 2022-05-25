@isTest
Private Class Test_HL_RelatedVPController{
    @testSetup
    static void testDataSetup() {
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
        
        List <Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
                
        List <Opportunity__c> oppList = (List<Opportunity__c>)HL_TestFactory.CreateSObjectList('Opportunity__c', false, 2);  
        for(integer i = 0; i < oppList.size(); i++){
            oppList[i].Name='Test Opportunity_' + String.valueOf(i);
            oppList[i].Client__c = accList[i].Id;
            oppList[i].Subject__c = accList[i].Id;
            oppList[i].Stage__c = 'Pitched';
            oppList[i].Line_of_Business__c = 'FVA';
            oppList[i].Job_Type__c = 'FA - Portfolio-Valuation';
            oppList[i].Primary_Office__c = 'AT';
        }
        insert oppList;

        List <Opp_VP__c> oppVPList = (List<Opp_VP__c>)HL_TestFactory.CreateSObjectList('Opp_VP__c', false, 2); 
        for(integer i = 0; i < oppVPList.size(); i++){
        oppVPList[i].Name='Test Opp Vp'+ String.valueOf(i);        
        oppVPList[i].Opportunity__c=oppList[i].id;
        oppVPList[i].Valuation_Date__c=System.Today();
        oppVPList[i].CurrencyIsoCode='USD';        
        }
        insert oppVPList;
    }
     
    @isTest
    static void TestVPListBuildingflow(){ 
        
        List <Opp_VP__c> oppVPRecList = new List <Opp_VP__c>();
        oppVPRecList = [SELECT Id, Opportunity__c FROM Opp_VP__c ORDER BY Name DESC LIMIT 2];  
        Opportunity__c oppRec = new Opportunity__c();
        
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_Related_PortfolioValuations'));
            System.currentPageReference().getParameters().put('Id',oppVPRecList[0].Opportunity__c ) ;
            System.currentPageReference().getParameters().put('relatedObjType', 'OppVP');
            
            HL_RelatedVPController objIns = new HL_RelatedVPController();
            objIns.getSortDirection();
            objIns.setSortDirection('ASC');
            objIns.SelectedRecId = oppVPRecList[0].id;
            objIns.DeleteRecord();
            objIns.CreateNewRecord();
            objIns.EditRecord();   
            objIns.CancelRecord(); 
            objIns.redirectToPVConversion();    
            // testing getter property
            List<sobject> localRecordList = new List<sobject>(); 
            localRecordList = objIns.RecordList;
            oppVPRecList[0].clear();
        Test.stopTest();
        System.assert(oppVPRecList.size() > 0);
        System.assertNotEquals(oppVPRecList[0], null);
    }
     @isTest
    static void TestVPListBuildingflowEngVP(){ 
         List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        List <Opp_VP__c> oppVPRecList = new List <Opp_VP__c>();
        oppVPRecList = [SELECT Id, Opportunity__c FROM Opp_VP__c ORDER BY Name DESC LIMIT 2];  
        Opportunity__c oppRec = new Opportunity__c();
       Engagement__c engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        engagement.Name='Test Engagement';
        engagement.Client__c = accList[0].Id;
        engagement.Subject__c = accList[0].Id;
        engagement.Stage__c = 'Pitched';
        engagement.Line_of_Business__c = 'CF';
        engagement.Job_Type__c = 'Financing';
        engagement.Primary_Office__c = 'AT';
        insert engagement;
        
        Eng_VP__c engVP =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);
        engVP.Name='Test Eng Vp';        
        engVp.Engagement__c=engagement.id;
        engVP.Valuation_Date__c=System.Today();
        engVp.CurrencyIsoCode='USD';        
        Insert engVP; 
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList[0].Id;
        engVPPos.Company__c=accList[0].Id;
        engVPPos.Engagement_VP__c=engVP.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
    engVPPos.Industry_Group_Picklist__c='SOV - Sovereigns';
    engVPPos.Sector__c='Sovereigns';
        insert engVPPos;  
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_Related_PortfolioValuations'));
            System.currentPageReference().getParameters().put('Id',engVP.Id) ;
            System.currentPageReference().getParameters().put('relatedObjType', 'OppVP');
            
            HL_RelatedVPController objIns = new HL_RelatedVPController();
           
            objIns.getSortDirection();
            objIns.setSortDirection('ASC');
            objIns.SelectedRecId = engVP.Id;
            objIns.DeleteRecord();
            objIns.CreateNewRecord();
            objIns.EditRecord();   
            objIns.CancelRecord(); 
            objIns.redirectToPVConversion();    
            // testing getter property
            List<sobject> localRecordList = new List<sobject>(); 
            localRecordList = objIns.RecordList;
            oppVPRecList[0].clear();
        Test.stopTest();
        System.assert(oppVPRecList.size() > 0);
        System.assertNotEquals(oppVPRecList[0], null);
    }
    @isTest
    static void TestVPListBuildingflowENG(){ 
         List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        List <Opp_VP__c> oppVPRecList = new List <Opp_VP__c>();
        oppVPRecList = [SELECT Id, Opportunity__c FROM Opp_VP__c ORDER BY Name DESC LIMIT 2];  
        Opportunity__c oppRec = new Opportunity__c();
         Engagement__c engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        engagement.Name='Test Engagement';
        engagement.Client__c = accList[0].Id;
        engagement.Subject__c = accList[0].Id;
        engagement.Stage__c = 'Pitched';
        engagement.Line_of_Business__c = 'CF';
        engagement.Job_Type__c = 'Financing';
        engagement.Primary_Office__c = 'AT';
        insert engagement;
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_Related_PortfolioValuations'));
            System.currentPageReference().getParameters().put('Id',engagement.id) ;
            System.currentPageReference().getParameters().put('relatedObjType', 'OppVP');
            
            HL_RelatedVPController objIns = new HL_RelatedVPController();
            objIns.getSortDirection();
            objIns.setSortDirection('ASC');
            objIns.SelectedRecId = oppVPRecList[0].id;
            objIns.DeleteRecord();
            objIns.CreateNewRecord();
            objIns.EditRecord();   
            objIns.CancelRecord(); 
            objIns.redirectToPVConversion();    
            // testing getter property
            List<sobject> localRecordList = new List<sobject>(); 
            localRecordList = objIns.RecordList;
            oppVPRecList[0].clear();
        Test.stopTest();
        System.assert(oppVPRecList.size() > 0);
        System.assertNotEquals(oppVPRecList[0], null);
    }
 }