@isTest
private class Test_HL_EngValuationPeriodController{   
    @testSetup 
    static void setup(){  
    
        List<Monthly_Revenue_Process_Control__c> listMRPC = new List<Monthly_Revenue_Process_Control__c>();
        
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        listMRPC.add(testMRPC);
        
        /*Monthly_Revenue_Process_Control__c testMRPC2 = new Monthly_Revenue_Process_Control__c();
        testMRPC2.Current_Year__c = String.Valueof(System.today().addDays(-32).Year());
        testMRPC2.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().addDays(-32).Month()):String.Valueof(System.today().Month());
        testMRPC2.IsCurrent__c = false;
        listMRPC.add(testMRPC2);*/
        insert listMRPC;
        
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
            EngVPTMList[i].Is_Team_Member_Deactivated_Once__c = false;
        }
        insert EngVPTMList;
    }
    
    @isTest static void TestUnitWithTeamMembers() {   
        List<Monthly_Revenue_Process_Control__c>  obj = [SELECT Id,IsCurrent__c FROM Monthly_Revenue_Process_Control__c  LIMIT 2];
        Eng_VP_Position__c testEngVPPo = [SELECT Id,Company__c FROM Eng_VP_Position__c LIMIT 1];
        Engagement__c testENg = [select id from Engagement__c Limit 1] ;
        Contact testCont = [select id from Contact where FirstName = 'TestFirst0' Limit 1];
        
        Test.startTest();
            List<Eng_VP_TeamMember__c> teamMemberList = (List<Eng_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Eng_VP_TeamMember__c', false, 3);        
            for(integer i = 0; i < teamMemberList.size(); i++){
                teamMemberList[i].Name = 'Test_' + String.valueOf(i);        
                teamMemberList[i].Engagement_VP_Position__c = testEngVPPo.id;
                teamMemberList[i].Role__c = 'Analyst';
                teamMemberList[i].Staff__c = testCont.Id;
            }
            try{
            insert teamMemberList;
            }catch(Exception e)
            {
                String ErrorMsg = e.getmessage();
                system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
            }
            Test.setCurrentPageReference(new PageReference('Page.HL_EngValuationPeriodPosition'));
            System.currentPageReference().getParameters().put('id',testEngVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testEngVPPo);
            HL_EngValuationPeriodPositionController clsobj = new HL_EngValuationPeriodPositionController(sc);
            Integer AllowedTM = clsobj.AllowedMembers;            
            clsobj.voidposition();
            clsobj.Backtovp();
            integer localallowedMember = clsobj.AllowedMembers;
            String userProfileName = clsobj.userProfileName;
            Boolean isValidPosition = clsobj.isValidPosition;
            String parentId = clsobj.parentId;
            clsobj.RefreshNewStaffRoles();
            List<SelectOption> selOpts = clsobj.HLInternalEmployees;
            clsobj.RemoveMember();
            clsobj.AddMember();
            clsobj.SaveTeamMembers();
            clsobj.selectItemSrNo = 1;
            clsobj.RemoveMember();
            system.assertNotEquals(null,AllowedTM);
        Test.stopTest();
    }
    
    @isTest
    static void TestInlineEditing(){   
        Eng_VP_Position__c testEngVPPo = [SELECT Id,Company__c FROM Eng_VP_Position__c LIMIT 1];
        test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EngValuationPeriodPosition'));
            System.currentPageReference().getParameters().put('id',testEngVPPo.id) ;
            System.currentPageReference().getParameters().put('retURL',testEngVPPo.id) ;
            ApexPages.StandardController sc = new ApexPages.StandardController(testEngVPPo);
            HL_EngValuationPeriodPositionController con = new HL_EngValuationPeriodPositionController(sc);            
            con.FieldAPI = 'Name';
            con.DummyReset(); 
            con.EngVPPosition.Name = null;
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
            con.VoidPosition();
            con.ClearFeeApprovalDate();
            system.assertNotEquals(con.EngVPPosition.Name, null);   
        test.stopTest();
    } 
}