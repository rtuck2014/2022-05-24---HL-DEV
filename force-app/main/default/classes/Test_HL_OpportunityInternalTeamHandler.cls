@isTest
private class Test_HL_OpportunityInternalTeamHandler {    
    private static User testUser1;
    private static User testUser2;  
    @isTest private static void TestTeamMemberChanges(){
        Test.startTest();
        List<Account> accountList = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert accountList;
        Contact c = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.AccountId = accountList[0].Id;        
        insert c;    
        
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        List<Opportunity_Internal_Team__c> oitList = SL_TestSetupUtils.CreateOIT('', oppTeamRoles.size());
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
        {
            oitList[i].Contact__c = c.Id;
            oitList[i].Opportunity__c = opp.Id;
            oitList[i].Staff_Role__c = staffRoles[i].Id;
        }
        
        
            insert oitList;
            delete oitList[0]; 
         
        
        System.assert(([SELECT Id FROM Opportunity_Internal_Team__c]).size() > 0);
        Test.stopTest();
    }
      

    public static void createUsers(){
      Profile p  = [Select Id from Profile Where Name = 'Standard User Template'];
        testUser1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test2xyztestUser1@testorg.com');
        testUser2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test2xyztestUser2@testorg.com');
        List<User> testUserList = new list<User>();
        testUserList.add(testUser1);
        testUserList.add(testUser2);
        insert testUserList;
    }
    
    public static void createDGPAndMembers()
    {
        Delegate_Public_Group__c objDPG = new Delegate_Public_Group__c(
            Banker__c = testUser1.Id            
        );
        
        Delegate_Public_Group__c objDPG2 = new Delegate_Public_Group__c(
            Banker__c = testUser2.Id            
        );
        list<Delegate_Public_Group__c> objDPGlist = new list<Delegate_Public_Group__c>(); 
        objDPGlist.add(objDPG);
        objDPGlist.add(objDPG2);
        insert objDPGlist;
        
        Delegate_Public_Group_Member__c DPGmember1 = new Delegate_Public_Group_Member__c();
        DPGmember1.Delegate__c = testUser2.id;
        DPGmember1.Delegate_Public_Group__c = objDPG.id;
        
        Delegate_Public_Group_Member__c DPGmember2 = new Delegate_Public_Group_Member__c();
        DPGmember2.Delegate__c = testUser1.id;
        DPGmember2.Delegate_Public_Group__c = objDPG2.id;
        
        list<Delegate_Public_Group_Member__c> objDPGMemberlist = new list<Delegate_Public_Group_Member__c>(); 
        objDPGMemberlist.add(DPGmember1);
        objDPGMemberlist.add(DPGmember2);
        insert objDPGMemberlist;
    }
    @testSetup static void setup() {
        createUsers();     
        createDGPAndMembers();  
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_' + String.valueOf(i);        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;      
        }
        insert accountList;

        List<Contact> contactList = new List<Contact>();
        for(Contact contactRecord : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1))
        {
            contactRecord.AccountId = accountList[0].Id;
            contactRecord.Title = 'Title-1';
            contactRecord.Phone = '989898989';
            contactRecord.MobilePhone = '989898989';
            contactRecord.Email = 'abc@silverlinecrm.com';      
            contactRecord.AssistantName = 'TestAsst.-1';
            contactRecord.AssistantPhone = '9875487884';
            contactRecord.User__c = testuser1.id;
            contactList.add(contactRecord);
        }
        for(Contact contactRecord2 : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1))
        {
            contactRecord2.AccountId = accountList[0].Id;
            contactRecord2.Title = 'Title-1';
            contactRecord2.Phone = '989898989';
            contactRecord2.MobilePhone = '989898989';
            contactRecord2.Email = 'abc@silverlinecrm.com';      
            contactRecord2.AssistantName = 'TestAsst.-1';
            contactRecord2.AssistantPhone = '9875487884';
            contactRecord2.User__c = testuser1.id;
            contactList.add(contactRecord2);
        }
        insert contactList;  
        
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test Engagement';
        Engagement.Client__c = accountList[0].Id;
        Engagement.Subject__c = accountList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        insert Engagement;
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;        
               
        List<Engagement_Internal_Team__c> testHLTeamMembers = new List<Engagement_Internal_Team__c>();
        Engagement_Internal_Team__c testHLTeamMember1 = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c',false);        
        testHLTeamMember1.Engagement__c = Engagement.id;
        testHLTeamMember1.Contact__c = contactList[0].id;
        testHLTeamMember1.Staff_Role__c = staffRoles[0].id;
        testHLTeamMember1.Start_Date__c= System.Today();        
        testHLTeamMembers.add(testHLTeamMember1);
        
        Engagement_Internal_Team__c testHLTeamMember2 = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c',false);        
        testHLTeamMember2.Engagement__c = Engagement.id;
        testHLTeamMember2.Contact__c = contactList[1].id;
        testHLTeamMember2.Start_Date__c= System.Today();
        testHLTeamMembers.add(testHLTeamMember2);
        
        Engagement_Internal_Team__c testHLTeamMember3 = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c',false);        
        testHLTeamMember3.Engagement__c = Engagement.id;
        testHLTeamMember3.Contact__c = contactList[0].id;
        testHLTeamMember3.Staff_Role__c = staffRoles[0].id;
        testHLTeamMember3.Start_Date__c= System.Today();
        testHLTeamMembers.add(testHLTeamMember3);
        
        insert testHLTeamMembers;   
        
        Eng_VP__c engVP =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);
        engVP.Name='Test Opp Vp';        
        engVP.Engagement__c=Engagement.id;
        engVP.Valuation_Date__c=System.Today();
        engVP.CurrencyIsoCode='USD';        
        Insert engVP; 
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accountList[0].Id;
        engVPPos.Company__c=accountList[0].Id;
        engVPPos.Engagement_VP__c=engVP.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        insert engVPPos;     
        
        List<Eng_VP_TeamMember__c> teamMemberList = (List<Eng_VP_TeamMember__c>)HL_TestFactory.CreateSObjectList('Eng_VP_TeamMember__c', false, 2);        
        for(integer i = 0; i < teamMemberList.size(); i++){
            teamMemberList[i].Name = 'Test_' + String.valueOf(i);        
            teamMemberList[i].Engagement_VP_Position__c = engVPPos.id;
            teamMemberList[i].Role__c = 'Analyst';
            if(i == 0 )
                teamMemberList[i].Staff__c = contactList[0].Id;
            else if (i == 1) {
                teamMemberList[i].Staff__c = contactList[1].Id;
            }
        }
        insert teamMemberList;  
    }
    @isTest static void UpdateOppVPPositionTeamMembers() {
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
        delete testEngIntTeamMembers;
        Test.StopTest();
    }
    
    @isTest static void UpdateOppVPPositionTeamMembersWithFutureStartTest() {
        List<Eng_VP_TeamMember__c> teamMemberList = [Select id,Start_Date__c,End_Date__c from Eng_VP_TeamMember__c];
        for(Eng_VP_TeamMember__c engVPTM : teamMemberList) {
            engVPTM.Start_Date__C = system.today()+2;
        }
        update teamMemberList;
        
        List<Engagement_Internal_Team__c> testEngIntTeamMembers = [SELECT Start_Date__c,End_Date__c,Contact__r.User__c,Engagement__c From Engagement_Internal_Team__c]; 
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
        List<Engagement_Internal_Team__c> testEngIntTeamMembers = [SELECT Start_Date__c,End_Date__C,Contact__c,Engagement__c From Engagement_Internal_Team__c]; 
        Engagement__c engObj =[SELECT Id FROM Engagement__c Limit 1];
        Eng_VP__c evpObj =[SELECT Id,Engagement__c,ownerId FROM Eng_VP__c LIMIT 1];
        Eng_VP_Position__c evposObj = [SELECT Id,Engagement_VP__c FROM Eng_VP_Position__c LIMIT 1];
        Eng_VP_TeamMember__c evpTMObj = [SELECT Id,Engagement_VP_Position__r.Engagement_VP__r.Engagement__c FROM Eng_VP_TeamMember__c LIMIT 1];
        
        Test.StartTest();
        Set<id> ContIdSet = new Set<Id>();
        for(Engagement_Internal_Team__c enIntTM : testEngIntTeamMembers) { 
          enIntTM.End_Date__c = system.today();  
        }
        update testEngIntTeamMembers; 
        Test.StopTest();
    }
    
    @isTest static void UpdateOppInternalTeamMember4() {
        List<Engagement_Internal_Team__c> testEngIntTeamMembers = [SELECT Start_Date__c,End_Date__C,Contact__c,Engagement__c From Engagement_Internal_Team__c]; 
        Set<Id>idSet = new Set<Id>();
        For (Engagement_Internal_Team__c objEng : testEngIntTeamMembers){
            idSet.add(objEng.Engagement__c); 
        }
        HL_EngagementInternalTeamHandler obj = new HL_EngagementInternalTeamHandler(true,1);
        boolean IsTriggerContext = obj.IsTriggerContext ;
        HL_EngagementInternalTeamHandler.fetchingVPFamily(idSet);
        Test.StartTest();
        Set<id> ContIdSet = new Set<Id>();
        for(Engagement_Internal_Team__c enIntTM : testEngIntTeamMembers) { 
          enIntTM.End_Date__c = system.today();  
        }
        update testEngIntTeamMembers; 
        Test.StopTest();
    }
}