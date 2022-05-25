@isTest
Private Class Test_HL_Opp_VP_PositionTriggerHelper {
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
    @testSetup static void setup() {   
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT;          
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = Test_HL_Opp_VP_PositionTriggerHelper.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
        test.starttest();
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
        test.stoptest();
        
    }
    
    @isTest
    static void TestDupeFunctionality1(){  
        // Testing positive scenario
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];
        Opp_VP_Position__c oppVPPo = [SELECT Id,Company__c FROM Opp_VP_Position__c LIMIT 1];
       
        test.startTest(); 
           oppVPPo.Company__c= accList2[1].Id;
           update oppVPPo;
        test.stopTest();
        
        System.assertNotEquals(null, oppObj);        
        System.assertEquals(null,oppVPPo.Name);
    }
    
    @isTest
    static void TestDupeFunctionality2(){   
        // Testing scenario where user try to insert position with duplicate company reference
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        oppVPPos.Name=accList2[0].Name;
        oppVPPos.Company__c=accList2[0].Id;
        oppVPPos.Opportunity_VP__c=oppObj.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        
        test.startTest(); 
            try{
                insert oppVPPos;   
            }
            catch(Exception ex){
               System.debug('An Exception Occured '+ex.getmessage() + 'at line number'+ ex.getlinenumber());
            }
        test.stopTest();

        System.assertEquals('Test_0',oppVPPos.Name);
        System.assertNotEquals(null, oppObj);
    }
    
    @isTest
    static void TestDupeFunctionality3(){   
        // Testing scenario where user try to update  position with duplicate company reference
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];               
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        oppVPPos.Name=accList2[0].Id;
        oppVPPos.Company__c=accList2[0].Id;
        oppVPPos.Opportunity_VP__c=oppObj.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        
        test.startTest(); 
        try{
            insert oppVPPos;   
            oppVPPos.Company__c=accList2[1].Id;
            update oppVPPos;
        }catch(Exception e){
                Boolean isErorrMsgExist = e.getmessage().contains(Label.DuplicateVP);
                system.assertEquals(true,isErorrMsgExist);
        }
        test.stopTest();     
        System.assertNotEquals(null, oppObj);
    }
        
    @isTest
    static void TestCalculateStatus1(){   
        // Testing scenario where user delete position from VP to roll up VP's status
        Opp_VP_Position__c oppVPObj = [SELECT Id FROM Opp_VP_Position__c LIMIT 1];        
        test.startTest(); 
            delete oppVPObj;
        test.stopTest();     
        System.assertNOTEquals(null, oppVPObj );
    }
    @isTest
    static void TestCalculateStatus2(){   
        // Testing scenario where user insert a new position and delete existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];        
        Opp_VP_Position__c oppVPObj = [SELECT Id FROM Opp_VP_Position__c LIMIT 1];        
        
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        oppVPPos.Name=accList2[1].Id;
        oppVPPos.Company__c=accList2[1].Id;
        oppVPPos.Opportunity_VP__c=oppObj.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        insert oppVPPos;  
        
        test.startTest(); 
        try{
            delete oppVPPos;
        }catch(Exception e){
                Boolean isErorrMsgExist = e.getmessage().contains(Label.DuplicateVP);
                system.assertEquals(true,isErorrMsgExist);
        }
        test.stopTest();     
        System.assertNOTEquals(null, oppVPObj );
    }
 
    @isTest
    static void TestPopulatingPositionName1(){   
        // Testing scenario where user insert a new position and update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        
        oppVPPos.Company__c=accList2[0].Id;
        oppVPPos.Name=oppVPPos.Company__r.Name;
        oppVPPos.Opportunity_VP__c=oppObj.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        
        test.startTest(); 
            insert oppVPPos;              
            oppVPPos.Status__c='In Progress';
            oppVPPos.Report_Fee__c=200;
            oppVPPos.Name = 'testPosition';
            update oppVPPOs;
        test.stopTest();     
        System.assertNOTEquals(null, oppVPPOs);
        System.assertNOTEquals(null, oppVPPOs.Status__c);
    }
 
    @isTest
    static void TestPopulatingPositionName2(){   
        // Testing scenario where user update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];
        Contact testCont = [SELECT Id FROM Contact LIMIT 1];
        Opp_VP_Position__c oppObj1 =[SELECT Id FROM Opp_VP_Position__c ];
        
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        
        List<Opp_VP_TeamMember__c> oppVPTMList = new List<Opp_VP_TeamMember__c>();
        Opp_VP_TeamMember__c oppVPTM = new Opp_VP_TeamMember__c();
        oppVPTM.Opportunity_VP_Position__c = oppObj1.id; 
        oppVPTM.Staff__c = testCont.id;
        oppVPTM.Role__c = 'Analyst';
        oppVPTM.start_Date__c = Date.today();
        oppVPTMList.add(oppVPTM);
        
        Opp_VP_TeamMember__c oppVPTM1 = new Opp_VP_TeamMember__c();
        oppVPTM1.Opportunity_VP_Position__c = oppObj1.id; 
        oppVPTM1.Staff__c = testCont.id;
        oppVPTM1.Role__c = 'Manager';
        oppVPTM1.start_Date__c = Date.today()+3;
        oppVPTMList.add(oppVPTM1);
        
        insert oppVPTMList;
        
        oppVPPos.Company__c=accList2[0].Id;
        oppVPPos.Name=oppVPPos.Company__r.Name;
        oppVPPos.Opportunity_VP__c=oppObj.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        oppVPPos.Status__c='In Progress';
        
        test.startTest(); 
        
        //oppObj1.Status__c ='Completed';
        //update oppObj1;
        
        insert oppVPPos; 
        test.stopTest();     
        System.assertNOTEquals(null, oppObj1);
        System.assertNOTEquals(null, oppVPPos);
    }
    
    @isTest
    static void TestPopulating1(){   
        Account accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];        
        Contact conList = [SELECT Id,Name FROM Contact LIMIT 1];
        Opportunity__c oppObj = [SELECT Id,Name FROM Opportunity__c LIMIT 1];   
        /*Opp_VP__c ovObj = [SELECT Id,OwnerId,Fee_Total__c,Overall_VP_Status__c  FROM Opp_VP__c LIMIT 1];     
        ovObj .Fee_Total__c = 123;
        ovObj .Overall_VP_Status__c= 'Completed';
        update ovObj ;*/
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
    static void TestCaseToChangeCurrencyonOpp(){   
        Opportunity__c oppObj = [SELECT Id,currencyISOCode, Name FROM Opportunity__c LIMIT 1];   
        test.startTest(); 
        oppObj.currencyISOCode = 'AUD';
        update  oppObj;            
        test.stopTest();  
    }
}