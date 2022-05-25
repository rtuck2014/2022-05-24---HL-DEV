@isTest
Private Class Test_HL_Eng_VP_PositionTriggerHelper {
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
    Static List<Engagement_Internal_Team__c> oitList;
    @testSetup static void setup() {             
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = Test_HL_Eng_VP_PositionTriggerHelper.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = c.User__c;
        }
        insert dpgList; 
        
        
    }
    
    @isTest
    static void TestDupeFunctionality1(){  
        // Testing positive scenario
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];
        Eng_VP_Position__c engVPPo = [SELECT Id,Company__c FROM Eng_VP_Position__c LIMIT 1];
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        test.startTest(); 
           engVPPo.Company__c= accList2[1].Id;
           update engVPPo;
        test.stopTest();
        
        System.assertNotEquals(null, engObj);        
        System.assertEquals(null,engVPPo.Name);
    }
    
    @isTest
    static void TestDupeFunctionality2(){   
        // Testing scenario where user try to insert position with duplicate company reference
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList2[0].Name;
        engVPPos.Company__c=accList2[0].Id;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        
        test.startTest(); 
            try{
                insert engVPPos;   
            }
            catch(Exception ex){
                System.assertNotEquals(null, engObj);
            }
        test.stopTest();

        System.assertEquals('Test_0',engVPPos.Name);       
    }
    
    @isTest
    static void TestDupeFunctionality3(){   
        // Testing scenario where user try to update  position with duplicate company reference
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];               
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList2[0].Id;
        engVPPos.Company__c=accList2[0].Id;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        
        test.startTest(); 
        try{
            insert engVPPos;   
            engVPPos.Company__c=accList2[1].Id;
            update engVPPos;
        }catch(Exception e){
                Boolean isErorrMsgExist = e.getmessage().contains(Label.DuplicateVP);
                system.assertEquals(true,isErorrMsgExist);
        }
        test.stopTest();     
        System.assertNotEquals(null, engObj);
    }
        
    @isTest
    static void TestCalculateStatus1(){   
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        // Testing scenario where user delete position from VP to roll up VP's status
        Eng_VP_Position__c engVPObj = [SELECT Id FROM Eng_VP_Position__c LIMIT 1];        
        test.startTest(); 
            delete engVPObj;
        test.stopTest();     
        System.assertNOTEquals(null, engVPObj );
    }
    @isTest
    static void TestCalculateStatus2(){   
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        // Testing scenario where user insert a new position and delete existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name ASC LIMIT 2];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];        
        Eng_VP_Position__c engVPObj = [SELECT Id FROM Eng_VP_Position__c LIMIT 1];        
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList2[1].Id;
        engVPPos.Company__c=accList2[1].Id;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        engVPPos.Industry_Group_Picklist__c='SOV - Sovereigns';
        engVPPos.Sector__c='Sovereigns';
        insert engVPPos;  
        
        test.startTest(); 
        try{
            delete engVPPos;
        }catch(Exception e){
                Boolean isErorrMsgExist = e.getmessage().contains(Label.DuplicateVP);
                system.assertEquals(true,isErorrMsgExist);
        }
        test.stopTest();     
        System.assertNOTEquals(null, engVPObj );
    }
 
    @isTest
    static void TestPopulatingPositionName1(){   
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        // Testing scenario where user insert a new position and update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        
        engVPPos.Company__c=accList2[0].Id;
        engVPPos.Name=engVPPos.Company__r.Name;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        
        test.startTest(); 
            insert engVPPos; 
            engVPPos.Automation_Tool_Utilized__c = 'Yes';
            engVPPos.Status__c='In Progress';
            engVPPos.Report_Fee__c=200;
            engVPPos.Name = 'testPosition';
            update engVPPOs;
        test.stopTest();     
        System.assertNOTEquals(null, engVPPOs);
        System.assertNOTEquals(null, engVPPOs.Status__c);
    }
 
    @isTest
    static void TestPopulatingPositionName2(){   
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        // Testing scenario where user update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];
        Contact testCont = [SELECT Id FROM Contact LIMIT 1];
        Eng_VP_Position__c engObj1 =[SELECT Id FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Automation_Tool_Utilized__c = 'Yes';
        engVPPos.Industry_Group_Picklist__c='SOV - Sovereigns';
        engVPPos.Sector__c='Sovereigns';
        List<Eng_VP_TeamMember__c> engVPTMList = new List<Eng_VP_TeamMember__c>();
        Eng_VP_TeamMember__c engVPTM = new Eng_VP_TeamMember__c();
        engVPTM.Engagement_VP_Position__c = engObj1.id; 
        engVPTM.Staff__c = testCont.id;
        engVPTM.Role__c = 'Analyst';
        engVPTM.start_Date__c = Date.today();
        engVPTMList.add(engVPTM);
        
        Eng_VP_TeamMember__c engVPTM1 = new Eng_VP_TeamMember__c();
        engVPTM1.Engagement_VP_Position__c = engObj1.id; 
        engVPTM1.Staff__c = testCont.id;
        engVPTM1.Role__c = 'Analyst';
        engVPTM1.start_Date__c = Date.today()+3;
        engVPTMList.add(engVPTM1);
                
        try{
            insert engVPTMList;
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
            system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }  
        
        engVPPos.Company__c=accList2[0].Id;
        engVPPos.Name=engVPPos.Company__r.Name;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        engVPPos.Automation_Tool_Utilized__c = 'Yes';
        engVPPos.Status__c='In Progress';
                
        test.startTest(); 
        
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed;
       // engObj1.Generate_Accrual__c='yes';
        update engObj1;
        
        insert engVPPos; 
        test.stopTest();     
        System.assertNOTEquals(null, engObj1);
        System.assertNOTEquals(null, engVPPos);
    }
    
    @isTest
    static void TestPopulating1(){   
        Account accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];        
        Contact conList = [SELECT Id,Name FROM Contact LIMIT 1];
        Engagement__c engObj = [SELECT Id,Name FROM Engagement__c LIMIT 1];   
        Eng_VP__c ovObj = [SELECT Id,OwnerId,Fee_Total__c,Overall_VP_Status__c FROM Eng_VP__c LIMIT 1];
        ovObj .Fee_Total__c = 123;
        ovObj .Overall_VP_Status__c= 'Completed';
        update ovObj ;    
        List<String> engTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        List<Engagement_Internal_Team__c> eitObj = SL_TestSetupUtils.CreateEIT('', engTeamRoles.size());
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();        
        for(Integer i = 0; i<engTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=engTeamRoles[i], Display_Name__c = engTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<engTeamRoles.size(); i++)
        {
            eitObj[i].Contact__c = conList.Id;
            eitObj[i].Engagement__c = engObj.Id;
            eitObj[i].Staff_Role__c = staffRoles[i].Id;
        }

        test.startTest(); 
        try{
            insert eitObj;
            delete eitObj[0]; 
        }
        catch (Exception ex){
        }
        test.stopTest();  
        System.assertNOTEquals(null, eitObj);
    }
    @isTest
    static void TestUpdateCurrencyOnEng(){   
    
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        
        Engagement__c engObj = [SELECT Id,CurrencyISoCode FROM Engagement__c LIMIT 1]; 
        engObj.CurrencyISoCode  = 'AUD';

        test.startTest();         
            update engObj;
        test.stopTest();  
        System.assertNOTEquals(null, engObj);
    }
    @isTest
    static void TestGenerateAccrual(){ 
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c,Fee_Completed__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed; 
     //   engObj1.Generate_Accrual__c  = 'Yes';       
        Test.StartTest();
            update engObj1;
            system.assertEquals(engObj1.Fee_Completed__c, 0);
            engObj1 =[SELECT Id , Fee_Completed__c, Report_Fee__c, Status__c FROM Eng_VP_Position__c ];
            system.assertEquals(engObj1.Fee_Completed__c, 100);
        Test.StopTest();
    }
    @isTest
    static void TestModifyPositionAfterAccrualAfterRevenueMonth(){ 
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        Integer curntMonth =  System.today().Month();
        if(curntMonth == 1){
            testMRPC.Current_Month__c = '12';
            testMRPC.Current_Year__c = String.Valueof(System.today().Year()-1);
        }
        else
            testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(curntMonth-1):String.Valueof(curntMonth-1);
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed; 
     //   engObj1.Generate_Accrual__c  = 'Yes';               
        update engObj1;
        Test.StartTest(); 
        try{
            engObj1.Status__c = 'In Progress';        
            update engObj1;     
        }catch(exception e)
        {
            String myMsg = e.getMessage();
            system.assert(myMsg.contains(System.Label.HL_VP_Position_Stop_Edit));
        }
        Test.StopTest();
    }
    @isTest
    static void TestDeletePositionAfterAccrualAfterRevenueMonth(){ 
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        Integer curntMonth =  System.today().Month();
        if(curntMonth == 1){
            testMRPC.Current_Month__c = '12';
            testMRPC.Current_Year__c = String.Valueof(System.today().Year()-1);
        }
        else
            testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(curntMonth-1):String.Valueof(curntMonth-1);
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed;  
    //    engObj1.Generate_Accrual__c  = 'Yes';               
        update engObj1;
        Test.StartTest(); 
        try{
           Delete engObj1;
        }catch(exception e)
        {
            String myMsg = e.getMessage();
            system.assert(myMsg.contains(System.Label.HL_VP_Position_Stop_Deletion));
        }
        Test.StopTest();
    }
    
    @isTest
    static void TestCancelAccrual(){ 
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed;
     //   engObj1.Generate_Accrual__c  = 'Yes';               
        update engObj1;
        Test.StartTest();  
            HL_ConstantsUtil.ToStopChangesStatusToCancelled = false;          
            engObj1.Status__c = 'Cancelled';        
            update engObj1;
            engObj1 =[SELECT Id , Fee_Completed__c, Report_Fee__c, Status__c FROM Eng_VP_Position__c ];
            system.assertEquals(engObj1.Fee_Completed__c, 0);
        Test.StopTest();
    }
    @isTest
    static void TestChangesNotAllowedonCancelledAccrual(){ 
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed; 
     //   engObj1.Generate_Accrual__c  = 'Yes';               
        update engObj1;
        Test.StartTest();  
            HL_ConstantsUtil.ToStopChangesStatusToCancelled = false;
            engObj1.Status__c = 'Cancelled';        
            update engObj1;
            Try{
            engObj1.Name = engObj1.Name+'Test';
            Update engObj1;
            }
            catch(Exception e)
            {
                String myMsg = e.getMessage();
                system.assert(myMsg.contains(System.Label.HL_VP_Position_Stop_Edit_On_Cancelled));
            }
        Test.StopTest();
    }
    @isTest
    static void TestDeleteNotAllowedonCancelledAccrual(){ 

        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed; 
     //   engObj1.Generate_Accrual__c  = 'Yes';               
        update engObj1;
        Test.StartTest();  
            HL_ConstantsUtil.ToStopChangesStatusToCancelled = false;
            engObj1.Status__c = 'Cancelled';        
            update engObj1;
            Try{
            Delete engObj1;
            }
            catch(Exception e)
            {
                String myMsg = e.getMessage();
                system.assert(myMsg.contains(System.Label.HL_VP_Position_Stop_Delete_On_Cancelled));
            }
        Test.StopTest();
    }
    @isTest
    static void TestRevertAccrual(){ 
       Eng_VP_Position__c engObj1 =[SELECT Id ,Report_Fee__c, Automation_Tool_Utilized__c, Status__c FROM Eng_VP_Position__c ];
        
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;
        engObj1.Automation_Tool_Utilized__c = 'Yes';
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed;    
        update engObj1;
        
        Test.StartTest();            
            engObj1.Status__c = 'In Progress';        
            update engObj1;
            engObj1 =[SELECT Id , Fee_Completed__c, Report_Fee__c, Status__c FROM Eng_VP_Position__c ];
            system.assertEquals(engObj1.Fee_Completed__c, 0);
            HL_Eng_VP_PositionTriggerHelper.isSuperUserOrSysAdmin();
        Test.StopTest();
    }
}