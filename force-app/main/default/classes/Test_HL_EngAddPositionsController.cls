@isTest
Private Class Test_HL_EngAddPositionsController { 
    
    @testSetup 
    static void setup() {
                
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
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
        
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Client__c = accountList[0].Id;
        Engagement.Subject__c = accountList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        insert Engagement;
        
        List<Eng_VP__c> EngVPList = (List<Eng_VP__c>)HL_TestFactory.CreateSObjectList('Eng_VP__c',false,2);
        for(integer i = 0; i < EngVPList.size(); i++){
            EngVPList[i].Name='Test_Engagement_VP'+i;        
            EngVPList[i].Engagement__c=Engagement.id;
            EngVPList[i].Valuation_Date__c=System.Today();
            EngVPList[i].CurrencyIsoCode='USD';    
        }
        Insert EngVPList; 
        
        
        List<Eng_VP_Position__c> EngVPPosList = (List<Eng_VP_Position__c>)HL_TestFactory.CreateSObjectList('Eng_VP_Position__c',false,4);
        for(integer i = 0; i < EngVPPosList.size(); i++){
            EngVPPosList[i].Report_Fee__c=100;
            EngVPPosList[i].Asset_Classes__c='Debt';
            EngVPPosList[i].CurrencyIsoCode='USD';
            if(i == 0 || i == 1)
            {
                EngVPPosList[i].Engagement_VP__c=EngVPList[0].Id;
                EngVPPosList[i].Company__c=accountList[0].Id;
            }
            if(i == 2 || i == 3)
            {
                EngVPPosList[i].Engagement_VP__c=EngVPList[1].Id;
                EngVPPosList[i].Company__c=accountList[1].Id;
            }
        }
        insert EngVPPosList;  
        List<Staff_Role__c> roleList = new List<Staff_Role__c> {new Staff_Role__c(Name = 'Initiator', Display_Order__c = 1, Engagement__c = True, CF__c = True), new Staff_Role__c(Name = 'Analyst', Display_Order__c = 2, Engagement__c = True, CF__c = True), new Staff_Role__c(Name = 'Associate', Display_Order__c = 3, Engagement__c = True, CF__c = True)};
            insert roleList;
                    
        List<Eng_VP_TeamMember__c> EngVPTMList = (List<Eng_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Eng_VP_TeamMember__c',false,4);
        for(integer i = 0; i < EngVPTMList.size(); i++){
          EngVPTMList[i].Engagement_VP_Position__c = EngVPPosList[i].id; 
          if(i == 0 || i == 1)
            EngVPTMList[i].Staff__c = CList[0].id;
          else
            EngVPTMList[i].Staff__c = CList[1].id;
          EngVPTMList[i].Role__c = 'Analyst';
          EngVPTMList[i].start_Date__c = Date.today();
        }
        insert EngVPTMList;
    }
    
     @isTest
     static void ImporPositionPositiveTestCase(){   
        Engagement__c testEng = [select id from Engagement__c limit 1];
        List<Eng_VP__c> EngVPList = [select id, Name from Eng_VP__c];
        Eng_VP__c testEgVP1 = new Eng_VP__c();
        Eng_VP__c testEgVP2 = new Eng_VP__c();
        for(Eng_VP__c vp : EngVPList) {
            if(vp.Name == 'Test_Engagement_VP0')
                testEgVP1 = vp;
            else 
                testEgVP2 = vp;
        }
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_AddPositions'));
            System.currentPageReference().getParameters().put('srcId',testEgVP1.id) ;
            System.currentPageReference().getParameters().put('srcParentId', testEng.id);
            HL_EngAddPositionsController  clsObj = new HL_EngAddPositionsController();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsObj.SelectedPVId = testEgVP2.id; 
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
            for(HL_EngAddPositionsController.RelatedPositionClass position : clsobj.RelatedPositionList ) { 
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
    }
    
    @isTest
     static void ImporPositionNegativeTestCase(){   
        Engagement__c testEng = [select id from Engagement__c limit 1];
        List<Eng_VP__c> EngVPList = [select id, Name from Eng_VP__c];
        Account AccWithNameTest_Account1 = [select id from Account where Name = 'Test_Account1'] ;
        Eng_VP__c testEgVP1 = new Eng_VP__c();
        Eng_VP__c testEgVP2 = new Eng_VP__c();
        for(Eng_VP__c vp : EngVPList) {
            if(vp.Name == 'Test_Engagement_VP0')
                testEgVP1 = vp;
            else 
                testEgVP2 = vp;
        }
        Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_AddPositions'));
            System.currentPageReference().getParameters().put('srcId',testEgVP1.id) ;
            System.currentPageReference().getParameters().put('srcParentId', testEng.id);
            HL_EngAddPositionsController  clsObj = new HL_EngAddPositionsController();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsObj.SelectedPVId = testEgVP2.id; 
            boolean isPrev   =  clsobj.hasPrevious;
            boolean isNext   =  clsobj.hasNext;
            integer pageNo   =  clsobj.pageNumber;
            clsobj.SearchRelatedPositions();       
            for(HL_EngAddPositionsController.RelatedPositionClass position : clsobj.RelatedPositionList ) { 
                position.isSelected = true;
            }
        Test.StopTest();
        try{
            Eng_VP_Position__c additionalPosition =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
            additionalPosition.Report_Fee__c=100;
            additionalPosition.Asset_Classes__c='Debt';
            additionalPosition.CurrencyIsoCode='USD';
            additionalPosition.Engagement_VP__c = testEgVP1.Id;
            additionalPosition.Company__c = AccWithNameTest_Account1.Id;   
            insert additionalPosition;  
            clsobj.SavePositions();             
        }
        catch (exception e) {
            Boolean isErorrMsgExist = e.getmessage().contains(Label.DuplicateVP);
            system.assertEquals(true,isErorrMsgExist); 
        }
                
    }
}