@isTest
private class Test_HL_EngagementInternalTeamHandler{
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
        usr = Test_HL_EngagementInternalTeamHandler.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
            contactRecord.Revenue_Allocation__c = 'test';
            contactList.add(contactRecord);
        }
        insert contactList;    
        
        RecordType PVRecordTypeId = [select id,Name from RecordType where SobjectType='Engagement__c' and Name='Portfolio Valuation' Limit 1];
        
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Client__c = accList[0].Id;
        Engagement.Subject__c = accList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'FVA';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        Engagement.RecordTypeId = PVRecordTypeId.id;
        Engagement.Engagement_Number__c = 'testEngNum';
        insert Engagement;
        system.debug('Engagement'+Engagement.RecordTypeId);
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
            List<Engagement_Internal_Team__c> oitObj = SL_TestSetupUtils.CreateEIT('', oppTeamRoles.size());        
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        Staff_Role__c newSR = new Staff_Role__c(Name='Analyst', Display_Name__c = 'Analyst', CF__c = true, FAS__c = true);
        insert newSR;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
        {
            oitObj[i].Contact__c = contactList[0].Id;
            oitObj[i].Engagement__c = Engagement.Id;
            oitObj[i].Staff_Role__c = staffRoles[i].Id;
            oitObj[i].Start_Date__c = Date.today();            
        }
        Insert oitObj;
        
        Engagement_Internal_Team__c newEIT = new Engagement_Internal_Team__c(Contact__c = contactList[0].Id,Engagement__c = Engagement.Id,Staff_Role__c = newSR.Id);
        insert newEIT;
        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = contactList[0].User__c;
        }
        insert dpgList;  
        Monthly_Revenue_Process_Control__c monthRev = new  Monthly_Revenue_Process_Control__c();
        monthRev.name = 'test';
        monthRev.Current_Month__c = '5';
        monthRev.Current_Year__c = '2021';
        monthRev.IsCurrent__c = true;
        insert monthRev;
    }  
    
    @isTest static void UpdateOppVPPositionTeamMembers() {
        List<Engagement_Internal_Team__c> testOppIntTeamMembers = [SELECT End_Date__C,Contact__c,Engagement__r.recordtype.name  From Engagement_Internal_Team__c]; 
        Test.StartTest();
        Set<id> ContIdSet = new Set<Id>();
        for(Engagement_Internal_Team__c opIntTM : testOppIntTeamMembers) { 
            system.debug('RecordType.name : '+opIntTM.Engagement__r.recordtype.name );
            if(!ContIdSet.contains(opIntTM.Contact__c)) {
                opIntTM.End_Date__C = System.today();
                ContIdSet.add(opIntTM.Contact__c);
            }
        }
        update testOppIntTeamMembers; 
        Test.StopTest();
    }
    
    @isTest static void UpdateOppVPPositionTeamMembersWithFutureStartTest() {
        List<Eng_VP_TeamMember__c> teamMemberList = [Select id,Start_Date__C from Eng_VP_TeamMember__c];
        
        for(Eng_VP_TeamMember__c engVPTM : teamMemberList) {
            engVPTM.Start_Date__C = system.today()+2;
        }
        update teamMemberList;
        
        List<Engagement_Internal_Team__c> testEngIntTeamMembers = [SELECT End_Date__C,Contact__c  From Engagement_Internal_Team__c]; 
        Test.StartTest();
        Set<id> ContIdSet = new Set<Id>();
        for(Engagement_Internal_Team__c enIntTM : testEngIntTeamMembers) { 
            if(!ContIdSet.contains(enIntTM.Contact__c)) {
                enIntTM.End_Date__C = System.today();
                ContIdSet.add(enIntTM.Contact__c);
            }
        }
        update testEngIntTeamMembers; 
        Test.StopTest();
    }
    
    @isTest static void UpdateOppInternalTeamMembers() {
        List<Engagement_Internal_Team__c> testOppIntTeamMembers = [SELECT End_Date__C,Contact__c  From Engagement_Internal_Team__c]; 
        Test.StartTest();
        Set<id> ContIdSet = new Set<Id>();
        for(Engagement_Internal_Team__c opIntTM : testOppIntTeamMembers) { 
            opIntTM.End_Date__c = system.today();  
        }
        update testOppIntTeamMembers; 
        Test.StopTest();
    }
    
    @isTest private static void Test_InsertUpdateCaseEng1()
    {
        
        Engagement_Internal_Team__c eit = [SELECT Id,Engagement__c FROM Engagement_Internal_Team__c LIMIT 1];
        eit.End_Date__c = Date.today().addDays(2);       
        HL_EngagementInternalTeamHandler obj = new HL_EngagementInternalTeamHandler(true, 1);
        Boolean IsTriggerContext = obj.IsTriggerContext;   
        test.startTest();
        update eit;
        delete eit;
        test.stopTest();        
    }  
    
    @isTest static void UpdateTeamMembers() {
        Engagement__c Engagement = new Engagement__c();
        Engagement  = [Select id From Engagement__c Limit 1];
        List<Account> accList = new List<Account>();
        accList = [Select id From Account ];
        
        List<Contact> contactList = new List<Contact>();
        contactList = [Select id From Contact];
        
        Test.StartTest();
        Eng_VP__c EngVPList =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);        
        EngVPList.Name='Test Eng Vp';        
        EngVPList.Engagement__c=Engagement.id;
        EngVPList.Valuation_Date__c=System.Today();
        EngVPList.CurrencyIsoCode='USD';        
        Insert EngVPList; 
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList[0].Id;
        engVPPos.Company__c=accList[0].Id;
        engVPPos.Engagement_VP__c=EngVPList.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        insert engVPPos;     
        
        List<Eng_VP_TeamMember__c> teamMemberList = (List<Eng_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Eng_VP_TeamMember__c', false, 2);        
        for(integer i = 0; i < teamMemberList.size(); i++){
            teamMemberList[i].Name = 'Test_' + String.valueOf(i);        
            teamMemberList[i].Engagement_VP_Position__c = engVPPos.id;
            teamMemberList[i].Role__c = 'Analyst';
            teamMemberList[i].Staff__c = contactList[0].Id;
        }
        
        try{
            insert teamMemberList;
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
            system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }
        teamMemberList = [Select id, Start_Date__C  From Eng_VP_TeamMember__c  Where Id IN: teamMemberList ];
        for(Eng_VP_TeamMember__c engVPTM : teamMemberList) {
            engVPTM.Start_Date__C = system.today()+2;
        }
        update teamMemberList;
        Test.StopTest();
    }
    
    
}