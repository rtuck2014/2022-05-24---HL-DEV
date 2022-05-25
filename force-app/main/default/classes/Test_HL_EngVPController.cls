@isTest
private class Test_HL_EngVPController{   
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
    
    @testSetup 
    static void setup(){    
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = Test_HL_EngVPController.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
        
        List<Contact> contactList = new List<Contact>();
        for(Contact contactRecord : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1))
        {
            contactRecord.AccountId = accList[0].Id;
            contactRecord.Title = 'Title-1';
            contactRecord.Phone = '989898989';
            contactRecord.MobilePhone = '989898989';
            contactRecord.Email = 'abc@silverlinecrm.com';      
            contactRecord.AssistantName = 'TestAsst.-1';
            contactRecord.AssistantPhone = '9875487884';
            contactRecord.User__c = usr.Id;
            contactList.add(contactRecord);
        }
        insert contactList;     
        id EngRTid;
        for(RecordType RT : [Select id from RecordType Where SobjectType = 'Engagement__c' AND developername = 'Portfolio_Valuation'])
        {
            EngRTid = RT.Id; 
        }
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Client__c = accList[0].Id;
        Engagement.Subject__c = accList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        Engagement.Total_Estimated_Fee__c = 0.00;
        Engagement.RecordTypeId  = EngRTid ;
        insert Engagement;
              
        /*List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        List<Engagement_Internal_Team__c> oitObj = SL_TestSetupUtils.CreateEIT('', oppTeamRoles.size());        
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
        {
            oitObj[i].Contact__c = contactList[0].Id;
            oitObj[i].Engagement__c = Engagement.Id;
            oitObj[i].Staff_Role__c = staffRoles[i].Id;
            oitObj[i].Start_Date__c = Date.today();
        }
        Insert oitObj;
        
         dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = contactList[0].User__c;
        }
        insert dpgList;  
        */
         Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = String.Valueof(System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month()));
        testMRPC.IsCurrent__c = true;
        insert testMRPC;  
        
        Eng_VP__c EngVPList =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);        
        EngVPList.Name='Test Eng Vp';        
        EngVPList.Engagement__c=Engagement.id;
        EngVPList.Valuation_Date__c=System.Today();
        EngVPList.CurrencyIsoCode='USD';   
        EngVPList.Fee_Total__c = 10.00;            
        Insert EngVPList;
         
        List<Eng_VP_Position__c> EngVPPosList = (List<Eng_VP_Position__c>)HL_TestFactory.CreateSObjectList('Eng_VP_Position__c',false,4);
        for(integer i = 0; i < EngVPPosList.size(); i++){
            EngVPPosList[i].Company__c=accList[0].Id;
            EngVPPosList[i].Engagement_VP__c = EngVPList.id;
            EngVPPosList[i].Asset_Classes__c='Debt';
            EngVPPosList[i].CurrencyIsoCode='USD';
            EngVPPosList[i].Revenue_month__c=testMRPC.Current_Month__c;
        /*    if(i == 0 || i == 1)
            {
                EngVPPosList[i].Engagement_VP__c=EngVPList[0].Id;
                EngVPPosList[i].Company__c=accList[0].Id;
            }
            if(i == 2 || i == 3)
            {
                EngVPPosList[i].Engagement_VP__c=EngVPList[1].Id;
                EngVPPosList[i].Company__c=accList[1].Id;
            }  */
        }
        insert EngVPPosList; 
         List<Staff_Role__c> roleList = new List<Staff_Role__c> {new Staff_Role__c(Name = 'Initiator', Display_Order__c = 1, Engagement__c = True, CF__c = True), new Staff_Role__c(Name = 'Analyst', Display_Order__c = 2, Engagement__c = True, CF__c = True), new Staff_Role__c(Name = 'Associate', Display_Order__c = 3, Engagement__c = True, CF__c = True)};
            insert roleList;           
       
       List<Eng_VP_TeamMember__c> EngVPTMList = (List<Eng_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Eng_VP_TeamMember__c',false,4);
        for(integer i = 0; i < EngVPTMList.size(); i++){
          EngVPTMList[i].Engagement_VP_Position__c = EngVPPosList[0].id; 
          EngVPTMList[i].Staff__c = contactList[0].id;         
          EngVPTMList[i].Role__c = 'Analyst';
          EngVPTMList[i].start_Date__c = Date.today();
          EngVPTMList[i].End_Date__c = Date.today();
        }
        insert EngVPTMList; 
    }   
    
    @isTest
    static void TestEngVPViewFunctionality(){ 
        String Engname;  
        Eng_VP__c enObj = [SELECT Id,OwnerId FROM Eng_VP__c LIMIT 1];
        Engagement__c engObj = [SELECT Id,OwnerId,name FROM Engagement__c LIMIT 1]; 
         Eng_VP__c  EngVP = new Eng_VP__c ();               
        EngVP.Name='Test Eng Vp 2';        
        EngVP.Engagement__c=EngObj.id;
        EngVP.Valuation_Date__c=System.Today();
        EngVP.CurrencyIsoCode='USD';    
        EngVP.OwnerId= userinfo.getuserId();    
        Insert EngVP; 
        EngVP.Engagement__c=EngVP.id; 
        Test.setCurrentPageReference(new PageReference('Page.HL_EngValuationPeriodView')); 
        System.currentPageReference().getParameters().put('id', enObj.Id );     
        System.currentPageReference().getParameters().put('EngId', engObj.Id );     
        System.currentPageReference().getParameters().put('retURL', 'engObj.Id' );
        test.startTest();           
            ApexPages.StandardController sc = new ApexPages.StandardController(enObj);
            HL_EngVPController con = new HL_EngVPController(sc);             
            con.ImportPosition();
            con.DeleteSelectedRecord();
            con.Backtovp();
            List<Eng_VP_Position__c> engvpPos = [Select id From Eng_VP_Position__c Limit 1];
            List<HL_EngVPController.RelatedPositionClass> RelatedPositionList = new List<HL_EngVPController.RelatedPositionClass>();  
            RelatedPositionList.add(new HL_EngVPController.RelatedPositionClass(true, engvpPos[0]));               
            con.RelatedPositionList = RelatedPositionList;
            con.GenerateAccrual(); 
            con.GenerateAccrualFinal();
            con.NewPosition();
            String myProfName = con.userProfileName;
            system.assertNotEquals(con.CurSelIDsSet.size(),0);
            
            Integer i = con.pageNumber;
         //   con.AccrualSelected(); 
            con.first();
            con.Next();
            con.Previous();
            con.last();            
            con.CurPageSize = 1;
            con.first();
            con.Next();
            con.Previous();
            con.last();   
            double myOffSet = con.offset;  
            integer selectedInProgItems = con.NoOfInProgressItems;
            con.EditRecord();
            Integer mypageSize = con.pageSize;
            con.showmore();     
        	con.DeleteRecord();
            con.getReportFeeOption();
            con.reportFeeSelected = 'TotalReportFee';
            con.reportFeeRedirect();            
        test.stopTest();
    } 
    
    @isTest
    static void TestCustomLinkFunctionality(){   
        Eng_VP__c evObj = [SELECT Id,OwnerId FROM Eng_VP__c LIMIT 1]; 
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(evObj);
            HL_Eng_VP_Custom_Links con = new HL_Eng_VP_Custom_Links(sc);  
            String link1 = con.ReportLink1;           
            String link2 = con.ReportLink2;           
            String link3 = con.ReportLink3;   
            system.assertEquals(null, link1);        
        test.stopTest();
    }  
    
    @isTest
    static void TestInlineEditing(){   
        Eng_VP__c evObj = [SELECT Id,OwnerId, Name, Frequency__c,Summary__c,Month_Quarter__c,Valuation_Date__c FROM Eng_VP__c LIMIT 1]; 
        test.startTest();            
            Test.setCurrentPageReference(new PageReference('Page.HL_EngValuationPeriodView')); 
            System.currentPageReference().getParameters().put('id', evObj.Id ); 
            ApexPages.StandardController sc = new ApexPages.StandardController(evObj);        
            HL_EngVPController con = new HL_EngVPController(sc);
            con.FieldAPI = 'Name';
            con.DummyReset(); 
            con.EngVPView.Name = null;
            con.SaveRc(); 
            con.FieldAPI = 'Frequency__c';
            con.DummyReset();
            con.FieldAPI = 'Summary__c';
            con.DummyReset();
            con.FieldAPI = 'Valuation_Date__c';
            con.DummyReset();
            con.IsCheckAll = true;
            con.getSortDirection();
            con.setSortDirection('ASC');                 
            Delete [Select id From Monthly_Revenue_Process_Control__c ];
            con.GenerateAccrual();  
            HL_EngVPController cont = new HL_EngVPController();
            //system.assertNotEquals(con.EngVPView.Name, null);   
        test.stopTest();
    } 
}