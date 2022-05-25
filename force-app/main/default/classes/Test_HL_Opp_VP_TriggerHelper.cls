@isTest
Private Class Test_HL_Opp_VP_TriggerHelper {
   public static User createTestUser(Id profID, String fName, String lName)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId
                             );
        return tuser;
    }
    
    Static List<Delegate_Public_Group__c> dpgList;
    Static User usr;    
    Static List<Opportunity_Internal_Team__c> oitList;
   
    @testSetup static void objSetup() {  
               
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = Test_HL_Opp_VP_TriggerHelper.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
        insert usr;
        List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
        Contact c = new contact(); 
        c.FirstName = 'test1';
        c.LastName = 'test2';
        c.AccountId = accList[0].id;
        c.User__c = usr.Id;
        Insert c; 

        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accList[0].Id;
        opportunity.Subject__c = accList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'FVA';
        opportunity.Job_Type__c = 'FA - Portfolio-Valuation';
        opportunity.Primary_Office__c = 'AT';
        insert opportunity;
        
        Opp_VP__c oppVP =(Opp_VP__c)HL_TestFactory.CreateSObject('Opp_VP__c',false);
        oppVP.Name='Test Opp Vp';        
        oppVp.Opportunity__c=opportunity.id;
        oppVP.Valuation_Date__c=System.Today();
        oppVp.CurrencyIsoCode='USD';        
        Insert oppVP; 
        
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        oppVPPos.Name=accList[0].Id;
        oppVPPos.Company__c=accList[0].Id;
        oppVPPos.Opportunity_VP__c=oppVP.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        insert oppVPPos;  
        
        oitList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, 1);
        for(integer i = 0; i < oitList.size(); i++){
            oitList[i].Contact__c = c.Id;
            oitList[i].Opportunity__c = opportunity.Id;
            oitList[i].End_Date__c = Date.today();
            oitList[i].Start_Date__c = Date.today();
        }
        insert oitList; 
        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = c.User__c;
        }
        insert dpgList;         
    }    
    @isTest
    static void TestHelperFunctionality(){   
        Account accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];        
        Contact conList = [SELECT Id,Name FROM Contact LIMIT 1];
        Opportunity__c oppObj = [SELECT Id,Name FROM Opportunity__c LIMIT 1];   
        Opp_VP__c ovObj = [SELECT Id,OwnerId FROM Opp_VP__c LIMIT 1];     
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        List<Opportunity_Internal_Team__c> oitObj = SL_TestSetupUtils.CreateOIT('', oppTeamRoles.size());
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
        {
            oitObj[i].Contact__c = conList.Id;
            oitObj[i].Opportunity__c = oppObj.Id;
            oitObj[i].Staff_Role__c = staffRoles[i].Id;
        }

        test.startTest(); 
        try{
            insert oitObj;
            delete oitObj[0]; 
        }
        catch (Exception ex){
        }
        test.stopTest();  
        System.assertNOTEquals(null, oitObj);
    }
    
    @isTest
    static void TestCustomLinkFunctionality(){   
        Opp_VP__c ovObj = [SELECT Id,OwnerId FROM Opp_VP__c LIMIT 1]; 
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(ovObj);
            HL_Opp_VP_Custom_Links con = new HL_Opp_VP_Custom_Links(sc);            
        test.stopTest();
    }
    
    @isTest
    static void TestOppVPViewFunctionality(){   
        Opp_VP__c ovObj = [SELECT Id,OwnerId FROM Opp_VP__c LIMIT 1];
        Opportunity__c oppObj = [SELECT Id,OwnerId,name FROM Opportunity__c LIMIT 1]; 
        test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_OppVP_View'));
            System.currentPageReference().getParameters().put('id',ovObj.id) ;
            System.currentPageReference().getParameters().put('OppId',oppObj.id) ;
            System.currentPageReference().getParameters().put('retURL',oppObj.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(ovObj);
            HL_OppVP_ViewController con = new HL_OppVP_ViewController(sc); 
            con.ImportPosition();
            con.Backtovp(); 
            con.deleterecord();
            con.first();
            con.Next();
            con.Previous();
            con.last();       
            con.CurPageSize = 1;
            con.first();
            con.Next();
            con.Previous();
            con.last();
            con.newposition();
            con.editrecord();
            con.DummyReset();
            con.deleteselectedrecord();
            Integer myPageNo = con.pageNumber;
            Integer myPageSize = con.pagesize;
            String myProfName = con.userProfileName;
            system.assertNotEquals(myPageSize,null);
            Double myOffSet = con.offset;
            Integer mySelectInProg = con.NoOfInProgressItems;
            con.showmore();
            system.assertNotEquals(null,myOffSet);          
        test.stopTest();
    }
    
    @isTest
    static void TestCustomLinkClass(){   
        Opp_VP__c ovObj = [SELECT Id,OwnerId FROM Opp_VP__c LIMIT 1]; 
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(ovObj);
            HL_Opp_VP_Custom_Links con = new HL_Opp_VP_Custom_Links(sc); 
            String localLink1 = con.ReportLink1;
            String localLink2 = con.ReportLink2;
            String localLink3 = con.ReportLink3;
            system.assertNotEquals(null,con);                     
            system.assertEquals(null,localLink3);                     
        test.stopTest();
    }
    @isTest
    static void TestInlineEditing(){   
        Opp_VP__c testEngVPPo = [SELECT Id,Name FROM Opp_VP__c LIMIT 1];
        test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_OppVP_View'));
            System.currentPageReference().getParameters().put('id',testEngVPPo.id) ;
            System.currentPageReference().getParameters().put('retURL',testEngVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testEngVPPo);
            HL_OppVP_ViewController con = new HL_OppVP_ViewController(sc);            
            con.FieldAPI = 'Name';
            con.DummyReset(); 
            con.OppVPView.Name = null;
            con.saveRc();
            con.FieldAPI = 'Frequency__c';
            con.DummyReset();
            con.FieldAPI = 'Month_Quarter__c';
            con.DummyReset();
            con.FieldAPI = 'Summary__c';
            con.DummyReset();
            con.FieldAPI = 'Valuation_Date__c';
            con.DummyReset();             
            double i = con.offset;
            con.DeleteRecord();  
            system.assertNotEquals(con.OppVPView.Name, null);            
        test.stopTest();
    } 
     
}