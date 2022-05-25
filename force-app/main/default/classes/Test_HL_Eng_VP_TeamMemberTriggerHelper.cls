@isTest
Private Class Test_HL_Eng_VP_TeamMemberTriggerHelper {
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
        usr = Test_HL_Eng_VP_TeamMemberTriggerHelper.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
        engVPPos.Automation_Tool_Utilized__c = 'Yes';
        engVPPos.Industry_Group_Picklist__c = 'SOV - Sovereigns';
        engVPPos.Sector__c = 'Sovereigns';
        insert engVPPos; 
        
        List<Eng_VP_TeamMember__c> engVPTMList = new List<Eng_VP_TeamMember__c>();
        Eng_VP_TeamMember__c engVPTM = new Eng_VP_TeamMember__c();
        engVPTM.Engagement_VP_Position__c = engVPPos.id; 
        engVPTM.Staff__c = c.id;
        engVPTM.Role__c = 'Analyst';
        engVPTM.start_Date__c = Date.today();
        engVPTMList.add(engVPTM); 
        insert engVPTMList;
        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = c.User__c;
        }
        insert dpgList; 
        
       /* User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'CAO'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US'
        );
        insert u;*/
    }
    
    @isTest
    static void TestEngMethod(){   
        // Testing scenario where user update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        //User objUser = [SELECT Id FROM User where Email='puser000@amamama.com'];
        
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];
        Contact testCont = [SELECT Id FROM Contact LIMIT 1];
        Eng_VP_Position__c engObj1 =[SELECT Id FROM Eng_VP_Position__c ];
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        
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
        engVPPos.Status__c='In Progress';
        engVPPos.Automation_Tool_Utilized__c = 'Yes';
        engVPPos.Industry_Group_Picklist__c = 'SOV - Sovereigns';
        engVPPos.Sector__c = 'Sovereigns';
        //engVPPos.Generate_Accrual__c = 'Yes';
        //System.runAs(objUser){
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        insert testMRPC;       
       
        test.startTest(); 
        
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed;
       // engObj1.Generate_Accrual__c = 'Yes';
        update engObj1;
        
        insert engVPPos;         
        test.stopTest();     
        System.assertNOTEquals(null, engObj1);
        System.assertNOTEquals(null, engVPPos);
       // }
    }
    
    @isTest
    static void TestEngMethoddelete(){   
        // Testing scenario where user delete existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Eng_VP__c engObj = [SELECT Id FROM Eng_VP__c LIMIT 1];
        Contact testCont = [SELECT Id FROM Contact LIMIT 1];
        Eng_VP_Position__c engObj1 =[SELECT Id FROM Eng_VP_Position__c ];
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        
        List<Eng_VP_TeamMember__c> engVPTMList = new List<Eng_VP_TeamMember__c>();
        Eng_VP_TeamMember__c engVPTM = new Eng_VP_TeamMember__c();
        engVPTM.Engagement_VP_Position__c = engObj1.id; 
        engVPTM.Staff__c = testCont.id;
        engVPTM.Role__c = 'Principal';
        engVPTM.start_Date__c = Date.today();
        engVPTMList.add(engVPTM);
        
        Eng_VP_TeamMember__c engVPTM1 = new Eng_VP_TeamMember__c();
        engVPTM1.Engagement_VP_Position__c = engObj1.id; 
        engVPTM1.Staff__c = testCont.id;
        engVPTM1.Role__c = 'Manager';
        engVPTM1.start_Date__c = Date.today()+3;
        engVPTMList.add(engVPTM1);
        try{
            insert engVPTMList;
            delete engVPTMList;
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
          //  system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }        
        engVPPos.Company__c=accList2[0].Id;
        engVPPos.Name=engVPPos.Company__r.Name;
        engVPPos.Engagement_VP__c=engObj.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        engVPPos.Status__c='In Progress';
        engVPPos.Automation_Tool_Utilized__c = 'Yes';
        engVPPos.Industry_Group_Picklist__c = 'SOV - Sovereigns';
        engVPPos.Sector__c = 'Sovereigns';
        //engVPPos.Generate_Accrual__c = 'Yes';
        
        Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month());
        testMRPC.IsCurrent__c = true;
        try{
        insert testMRPC;
        list<Monthly_Revenue_Process_Control__c> MRPC1 = [select id,Current_Year__c,Current_Month__c,IsCurrent__c from Monthly_Revenue_Process_Control__c where id =: testMRPC.id AND Current_Month__c =:null];
        if(MRPC1 == null)
        {
        insert MRPC1;
        }   
      
        }catch(Exception e)
         {
             String ErrorMsg = e.getmessage();
             system.assert(ErrorMsg.contains('Please reach out to Accounting to setup a Revenue Month for this engagement.'));
         }
        test.startTest(); 
        insert engVPPos;
        engObj1.Status__c = System.Label.HL_Eng_VP_Status_Completed;
               
         
        test.stopTest();     
     
    }
}