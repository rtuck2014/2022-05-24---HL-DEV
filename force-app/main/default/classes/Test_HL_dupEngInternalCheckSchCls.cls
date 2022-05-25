@isTest
private class Test_HL_dupEngInternalCheckSchCls{
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
        usr = Test_HL_dupEngInternalCheckSchCls.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
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
            oitObj[i].Staff_Role__c = staffRoles[0].Id;
            oitObj[i].Start_Date__c = Date.today();            
        }
        Insert oitObj;
        
        System.debug(oitObj[0].End_Date__c);
        
        Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(oitObj[0].Id, yesterday);
        Test.setCreatedDate(oitObj[1].Id, yesterday);        
        
        
   
    Engagement_Internal_Team__c newEIT = new Engagement_Internal_Team__c(Contact__c = contactList[0].Id,Engagement__c = Engagement.Id,Staff_Role__c = newSR.Id);
    insert newEIT;
       
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = contactList[0].User__c;
        }
        insert dpgList;                  
    }  
   
    @isTest static void testEngScheduleCls() {        
        Test.StartTest();

        HL_dupEngInternalCheckSchCls obj = new HL_dupEngInternalCheckSchCls();
        String Exp = '0 0 23 * * ?';
        system.Schedule('mybatch1', Exp, obj);
        
        Test.StopTest();
    }
   

}