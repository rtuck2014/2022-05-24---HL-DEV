@isTest
private class Test_HL_Eng_VP_TriggerHelper{
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
        usr = Test_HL_Eng_VP_TriggerHelper.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
              
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
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
        
        Eng_VP__c EngVPList =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);        
        EngVPList.Name='Test Eng Vp';        
        EngVPList.Engagement__c=Engagement.id;
        EngVPList.Valuation_Date__c=System.Today();
        EngVPList.CurrencyIsoCode='USD';   
        EngVPList.Fee_Total__c = 10.00;
        EngVPList.Client_Complexity__c ='1';
        EngVPList.Client_Draft_Deadline__c = System.Today().addDays(30);
      //  EngVPList.Client_Final_Deadline__c =  System.Today().addDays(60);
        Insert EngVPList; 
    }
    
    @isTest static void TestUnitWithTeamMembers() {             
        Eng_VP__c ovObj = [SELECT Id,OwnerId FROM Eng_VP__c LIMIT 1];     
        System.assertNOTEquals(null, ovObj );
    }
    
    @isTest
    static void TestCustomLinkFunctionality(){   
        Eng_VP__c evObj = [SELECT Id,OwnerId FROM Eng_VP__c LIMIT 1]; 
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(evObj);
            HL_Eng_VP_Custom_Links con = new HL_Eng_VP_Custom_Links(sc);            
        test.stopTest();
    }
    @isTest
    static void TestInsertFeeFunctionality(){   
        test.startTest();
            Eng_VP__c evObj = [SELECT Id,OwnerId,Fee_Total__c,Overall_VP_Status__c  FROM Eng_VP__c LIMIT 1]; 
            evObj.Fee_Total__c = 123;
            evObj.Overall_VP_Status__c= System.Label.HL_Eng_VP_Status_Completed;
        update evObj ;
        test.stopTest();  
        evObj = [SELECT Id,OwnerId,Fee_Total__c,Overall_VP_Status__c  FROM Eng_VP__c LIMIT 1]; 
       //System.assertEquals(evObj.Fee_Total__c , 0.00);
        System.assertNotEquals(evObj.Fee_Total__c , 10.20);      
    }
    @isTest
    static void TestUpdateFeeFunctionality(){  
        Engagement__c engObj = [SELECT Id FROM Engagement__c LIMIT 1];
        Eng_VP__c EngVP = new Eng_VP__c();        
        EngVP.Name='Test Eng Vp 2';        
        EngVP.Engagement__c=EngObj.id;
        EngVP.Valuation_Date__c=System.Today();
        EngVP.CurrencyIsoCode='USD';    
        EngVP.OwnerId= userinfo.getuserId();
        EngVP.Client_Complexity__c ='1';
        EngVP.Client_Draft_Deadline__c = System.Today().addDays(30);
      //  EngVP.Client_Final_Deadline__c =  System.Today().addDays(60);
        Insert EngVP; 
        EngVP.Fee_Total__c = 200.10;
        test.startTest();
            update EngVP;
        test.stopTest();
        System.assertEquals(EngVP.Fee_Total__c , 200.10);
        System.assertNotEquals(EngVP.Fee_Total__c , 10.20);
    }
    @isTest
    static void TestDeleteFeeFunctionality(){   
        Eng_VP__c evObj = [SELECT Id,Fee_Total__c FROM Eng_VP__c LIMIT 1];
        test.startTest();
            delete evObj ; 
        test.stopTest();
        System.assertEquals(evObj.Fee_Total__c , 0.00);
        System.assertNotEquals(evObj.Fee_Total__c , 10.20);
    }
    @isTest
    static void TestupdateStatusFunctionality(){ 
         test.startTest();
         List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Eng_VP__c engObj = [SELECT Id,Overall_VP_Status__c FROM Eng_VP__c LIMIT 1];                
        System.assertEquals(engObj.Overall_VP_Status__c , 'New');
        List<Eng_VP_Position__c> delete_new = new List<Eng_VP_Position__c>();
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList2[1].Id;
        engVPPos.Company__c=accList2[1].Id;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        engVPPos.Automation_Tool_Utilized__c = 'Yes';
        engVPPos.Status__c='In Progress';
        engVPPos.Industry_Group_Picklist__c='SOV - Sovereigns';
        engVPPos.Sector__c='Sovereigns';
        delete_new.add(engVPPos);
        insert engVPPos; 
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        engVPPos.Status__c=System.Label.HL_Eng_VP_Status_Completed; 
        update engVPPos;
        Eng_VP_Position__c engVPPos1 =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos1.Name=accList2[1].Id;
        engVPPos1.Company__c=accList2[1].Id;
        engVPPos1.Engagement_VP__c=engObj.Id;
        engVPPos1.Report_Fee__c=100;
        engVPPos1.Asset_Classes__c='Equity';
        engVPPos.Industry_Group_Picklist__c='SOV - Sovereigns';
        engVPPos.Sector__c='Sovereigns';
        engVPPos1.CurrencyIsoCode='USD';
        engVPPos1.Automation_Tool_Utilized__c = 'Yes';
        engVPPos1.Status__c='In Progress';
        delete_new.add(engVPPos1);
        insert engVPPos1; 
        HL_ConstantsUtil.ToStopChangesStatusToCancelled = false;
        engVPPos1.Status__c='Cancelled';
        update engVPPos1;   
        
         Eng_VP__c evObj1 = [SELECT Id,Overall_VP_Status__c FROM Eng_VP__c LIMIT 1]; 
         System.assertnotEquals(evObj1.Overall_VP_Status__c , 'In Progress');
         evObj1.Overall_VP_Status__c='In Progress';
         HL_ConstantsUtil.stopUpdatingPVValueStatusChange = false;
         update evObj1;
         delete engVPPos;           
        test.stopTest();  
        
        System.assertEquals(evObj1.Overall_VP_Status__c , 'In Progress');
        System.assertNotEquals(evObj1.Overall_VP_Status__c , 'Completed');      
    }
    
    @isTest
    static void TestBeforeUpdateFunctionality(){   
        Engagement__c engObj = [SELECT Id FROM Engagement__c LIMIT 1];
        
        Eng_VP__c EngVP = new Eng_VP__c();        
        EngVP.Name='Test Eng Vp';        
        EngVP.Engagement__c=engObj.id;
        EngVP.Valuation_Date__c=System.Today();
        EngVP.CurrencyIsoCode='USD';    
        EngVP.OwnerId= userinfo.getuserId();   
        EngVP.Client_Complexity__c ='1';
        EngVP.Client_Draft_Deadline__c = System.Today().addDays(30);
        //EngVP.Client_Final_Deadline__c =  System.Today().addDays(60);
        Insert EngVP; 
        EngVP.Fee_Total__c = 2.10;
        test.startTest();
            update EngVP;
        test.stopTest();
    }
    
    @isTest
    static void TestCustomLinkClass(){   
        Eng_VP__c ovObj = [SELECT Id,OwnerId FROM Eng_VP__c LIMIT 1]; 
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(ovObj);
            HL_Eng_VP_Custom_Links con = new HL_Eng_VP_Custom_Links(sc);            
        test.stopTest();
    }
}