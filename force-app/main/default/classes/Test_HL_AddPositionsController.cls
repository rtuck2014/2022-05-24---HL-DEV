@isTest
Private Class Test_HL_AddPositionsController { 
    
    @testSetup 
    static void setup() {
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT;      
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_Account' +i;        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;
        }
        
        insert accountList;
        
        List<Contact> CList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 2);        
        for(integer i = 0; i < CList.size(); i++){
            CList[i].FirstName = 'TestFirst' +i;
            CList[i].LastName = 'TestLast' +i;
            CList[i].AccountId = accountList[0].id;
        }
        Insert CList; 
        
        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test_Opportunity';
        opportunity.Client__c = accountList[0].Id;
        opportunity.Subject__c = accountList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'FVA';
        opportunity.Job_Type__c = 'FA - Portfolio-Valuation';
        opportunity.Primary_Office__c = 'AT';
        insert opportunity;
        
        List<Opp_VP__c> oppVPList = (List<Opp_VP__c>)HL_TestFactory.CreateSObjectList('Opp_VP__c',false,2);
        for(integer i = 0; i < oppVPList.size(); i++){
            oppVPList[i].Name='Test_Opportunity_VP'+i;        
            oppVPList[i].Opportunity__c=opportunity.id;
            oppVPList[i].Valuation_Date__c=System.Today();
            oppVPList[i].CurrencyIsoCode='USD';    
        }
        Insert oppVPList; 
        test.startTest();
        
        List<Opp_VP_Position__c> oppVPPosList = (List<Opp_VP_Position__c>)HL_TestFactory.CreateSObjectList('Opp_VP_Position__c',false,4);
        for(integer i = 0; i < oppVPPosList.size(); i++){
            oppVPPosList[i].Report_Fee__c=100;
            oppVPPosList[i].Asset_Classes__c='Debt';
            oppVPPosList[i].CurrencyIsoCode='USD';
            if(i == 0 || i == 1)
            {
                oppVPPosList[i].Opportunity_VP__c=oppVPList[0].Id;
                oppVPPosList[i].Company__c=accountList[0].Id;
            }
            if(i == 2 || i == 3)
            {
                oppVPPosList[i].Opportunity_VP__c=oppVPList[1].Id;
                oppVPPosList[i].Company__c=accountList[1].Id;
            }
        }
        insert oppVPPosList;  
        List<Staff_Role__c> roleList = new List<Staff_Role__c> {new Staff_Role__c(Name = 'Initiator', Display_Order__c = 1, Opportunity__c = True, CF__c = True), new Staff_Role__c(Name = 'Analyst', Display_Order__c = 2, Opportunity__c = True, CF__c = True), new Staff_Role__c(Name = 'Associate', Display_Order__c = 3, Opportunity__c = True, CF__c = True)};
            insert roleList;
         //Add some members
        List<Opportunity_Internal_Team__c> oitList = new List<Opportunity_Internal_Team__c> {
            new Opportunity_Internal_Team__c(Opportunity__c = opportunity.Id, Contact__c = CList[0].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[0].Id, Office__c = 'LA'),
                new Opportunity_Internal_Team__c(Opportunity__c = opportunity.Id, Contact__c = CList[0].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[1].Id, Office__c = 'LA'),
                new Opportunity_Internal_Team__c(Opportunity__c = opportunity.Id, Contact__c = CList[1].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[0].Id, Office__c = 'CH')
                };
        insert oitList;
                    
        List<Opp_VP_TeamMember__c> oppVPTMList = (List<Opp_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Opp_VP_TeamMember__c',false,4);
        for(integer i = 0; i < oppVPTMList.size(); i++){
            oppVPTMList[i].Opportunity_VP_Position__c = oppVPPosList[i].id; 
            if(i == 0 || i == 1)
                oppVPTMList[i].Staff__c = CList[0].id;
            else
                oppVPTMList[i].Staff__c = CList[1].id;
            oppVPTMList[i].Role__c = 'Analyst';
            oppVPTMList[i].start_Date__c = Date.today();
        }
        insert oppVPTMList;
        test.stoptest();
    }
    
     @isTest
     static void ImporPositionPositiveTestCase(){   
        Opportunity__c testOpp = [select id from Opportunity__c limit 1];
        List<Opp_VP__c> oppVPList = [select id, Name from Opp_VP__c];
        Opp_VP__c testOpVP1 = new Opp_VP__c();
        Opp_VP__c testOpVP2 = new Opp_VP__c();
        for(Opp_VP__c vp : oppVPList) {
            if(vp.Name == 'Test_Opportunity_VP0')
                testOpVP1 = vp;
            else 
                testOpVP2 = vp;
        }
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_AddPositions'));
            System.currentPageReference().getParameters().put('srcId',testOpVP1.id) ;
            System.currentPageReference().getParameters().put('srcParentId', testOpp.id);
            HL_AddPositionsController  clsObj = new HL_AddPositionsController();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsObj.SelectedPVId = testOpVP2.id; 
            boolean isPrev   =  clsobj.hasPrevious;
            boolean isNext   =  clsobj.hasNext;
            integer pageNo   =  clsobj.pageNumber;        
            clsobj.first();
            clsobj.Next();
            clsobj.Previous();
            clsobj.last();
            clsobj.doSavePageSize();
            clsobj.SearchRelatedPositions();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsobj.first();
            clsobj.Next();
            clsobj.Previous();
            clsobj.last();
            for(HL_AddPositionsController.RelatedPositionClass position : clsobj.RelatedPositionList ) { 
                position.isSelected = true;
            }
            clsobj.getImportOptions();
            clsobj.SelectedImportOption = 'Import Positions with team members';
            clsobj.SavePositions();
            clsobj.doSavePageSize();
            clsobj.BackToVP();
            clsobj.backToVPScreen();
            clsobj.Cancel();
            clsobj.goCurPageNumber();
        test.StopTest();
        system.assertNotequals(clsobj.hasPrevious, true);
        system.assertNotequals(clsobj.hasNext, true);
        system.assertNotequals(clsobj.pageNumber, null);
        system.assertNotequals(clsobj.RelatedPositionList, null);
        system.assertequals(clsobj.RelatedPositionList.size(), 0);    
    }
    
    @isTest
     static void ImporPositionNegativeTestCase(){   
        Opportunity__c testOpp = [select id from Opportunity__c limit 1];
    Test.startTest();
        List<Opp_VP__c> oppVPList = [select id, Name from Opp_VP__c];
        Account AccWithNameTest_Account1 = [select id from Account where Name = 'Test_Account1'] ;
        Opp_VP__c testOpVP1 = new Opp_VP__c();
        Opp_VP__c testOpVP2 = new Opp_VP__c();
        for(Opp_VP__c vp : oppVPList) {
            if(vp.Name == 'Test_Opportunity_VP0')
                testOpVP1 = vp;
            else 
                testOpVP2 = vp;
        }
        
            Test.setCurrentPageReference(new PageReference('Page.HL_AddPositions'));
            System.currentPageReference().getParameters().put('srcId',testOpVP1.id) ;
            System.currentPageReference().getParameters().put('srcParentId', testOpp.id);
            HL_AddPositionsController  clsObj = new HL_AddPositionsController();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsObj.SelectedPVId = testOpVP2.id; 
            boolean isPrev   =  clsobj.hasPrevious;
            boolean isNext   =  clsobj.hasNext;
            integer pageNo   =  clsobj.pageNumber;
            clsobj.SearchRelatedPositions();       
            for(HL_AddPositionsController.RelatedPositionClass position : clsobj.RelatedPositionList ) { 
                position.isSelected = true;
            }
        
        try{
            Opp_VP_Position__c additionalPosition =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
            additionalPosition.Report_Fee__c=100;
            additionalPosition.Asset_Classes__c='Debt';
            additionalPosition.CurrencyIsoCode='USD';
            additionalPosition.Opportunity_VP__c = testOpVP1.Id;
            additionalPosition.Company__c = AccWithNameTest_Account1.Id;   
            insert additionalPosition;  
            clsobj.SavePositions(); 
            //system.assertEquals(String.valueOf(AccWithNameTest_Account1.Id), String.valueof(clsobj.ExistingCompanyIdSet));
        }catch (exception e) {
            Boolean isErorrMsgExist = e.getmessage().contains(Label.DuplicateVP);
            system.assertEquals(true,isErorrMsgExist); 
        }
         Test.StopTest();
                
    }
}