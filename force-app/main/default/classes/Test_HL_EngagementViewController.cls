@isTest
private class Test_HL_EngagementViewController {
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
    
    Static User usr;    
    @testSetup static void setup() {             
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = Test_HL_EngagementViewController.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
        Test.startTest();
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

        Engagement__c engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        engagement.Name='Test Engagement';
        engagement.Client__c = accList[0].Id;
        engagement.Subject__c = accList[0].Id;
        engagement.Stage__c = 'Pitched';
        engagement.Line_of_Business__c = 'CF';
        engagement.Job_Type__c = 'Financing';
        engagement.Primary_Office__c = 'AT';
        insert engagement;
        
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
        
        List<Delegate_Public_Group__c> dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = contactList[0].User__c;
        }
        insert dpgList;  
        test.stopTest();
    }
    @isTest private static void TestBasicFunctionality(){
    
        Engagement__c e = [SELECT Id, Name FROM Engagement__c LIMIT 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(e);
        HL_EngagementViewController con = new HL_EngagementViewController(sc);
        Boolean OnEIT = con.OnEIT; 
        Boolean AddCommentsAccess = con.AddCommentsAccess;
        HL_ConstantsUtil.isSupervisorMethodExecuted = false;
        HL_EngagementViewController.IsUserMemberofPVSuperVisorOrItschildGroup();
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
   
    @isTest
    public static void testRunAsNonSysAdm() {
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CAO' LIMIT 1]; 
        User u = new User(Alias = 'tooiyr', Email='standardtestusersfdc@force.com', 
                    EmailEncodingKey='UTF-8', LastName='TestUserQADEV', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@force.com');  
        insert u;       
             
        Account accObj = [SELECT Id, OwnerId, Name FROM Account LIMIT 1];
        accObj.OwnerId=u.id;
        update accObj;     
        Contact conObj =[SELECT Id,Name,OwnerId,User__c FROM Contact LIMIT 1];
        conObj.OwnerId=u.Id;
        conObj.User__c =u.Id;
        update conObj;
        
        Engagement__c opp  = [SELECT Id, Name, OwnerId FROM Engagement__c];  
        opp.OwnerId= u.id;
        update opp;    
        
        Engagement_Internal_Team__c oitObj =[SELECT Id, OwnerId, Name FROM Engagement_Internal_Team__c LIMIT 1];
        oitObj.OwnerId =u.Id;
        update oitObj;
        
        System.runAs(u) {   
          //  test.startTest(); 
            Delegate_Public_Group__c dpg = new Delegate_Public_Group__c();
            dpg.Banker__c = u.Id;
            insert dpg;            
            Delegate_Public_Group_Member__c dpmg = new Delegate_Public_Group_Member__c();
            dpmg.Delegate__c=u.id;
            dpmg.Delegate_Public_Group__c =dpg.Id;
            Insert dpmg;
  test.stopTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            HL_EngagementViewController con = new HL_EngagementViewController(sc);            
           // test.stopTest();
            System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
        }
    }
}