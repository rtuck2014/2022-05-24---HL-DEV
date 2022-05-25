/**
* \arg ClassName      : SL_Test_CompanyReport
* \arg JIRATicket     : HL-25
* \arg CreatedOn      : 21/Aug/2014
* \arg LastModifiedOn : 21/AUg/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_CompanyReport page.
*/
@isTest
private class SL_Test_CompanyReport 
{
    
    static Profile getProfile()
    {
        Profile objProfile = [SELECT Id,
                                     Name 
                                FROM Profile
                               WHERE Name = 'Solution Manager'];
        
        return objProfile;

    }
    
    static List<User> insertListOfUsers()
    {
        Profile objProfile = getProfile();
        
        List<User> lstUser = new List<User>();
        For(User objUser : SL_TestSetupUtils.CreateUser('User',1))
        {
            objUser.Lastname = 'User';
            objUser.Email = 'tuser@yahoo.in';
            objUser.Username = 'test@hl2.com';
            objUser.ProfileId = objProfile.Id;
            objUser.Alias = 'tuser';
            objUser.TimeZoneSidKey = 'GMT';
            objUser.LocaleSidKey = 'en_US';
            objUser.EmailEncodingKey = 'ISO-8859-1';
            objUser.LanguageLocaleKey = 'en_US';
            objUser.Has_Delegates__c = false;
            lstUser.add(objUser);
        }
        insert lstUser;
        return lstUser;

    }
    
    
    
    static List<Account> insertListOfAcconts()
    {
         List<Account> lstAccount1 = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert lstAccount1;
        
        List<Account> lstAccount2 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account' , 1))
        {
            objAccount.ParentId = lstAccount1[0].Id;
            objAccount.Phone = '9800225544';
            objAccount.Website = 'silverlinecrm.com';
            objAccount.EBITDA_MM__c = 54545;
            objAccount.AnnualRevenue = 78754;
            objAccount.BillingStreet = '20A, RC Road';
            objAccount.BillingCity = 'Bangalore';
            objAccount.BillingState = 'Karnataka';
            objAccount.BillingPostalCode = '455544';
            objAccount.BillingCountry = 'India';
            objAccount.Total_Debt_MM__c = 4500;
            objAccount.Industry = 'Banking';
            objAccount.OwnerId = Userinfo.getUserId();
            objAccount.Description = 'Cisco Systems, Inc. designs, manufactures';
            lstAccount2.add(objAccount);                            
        }
        insert lstAccount2;
        return lstAccount2;

    }
    
    static List<Account> insertListofAccount3()
    {
        
        
 //       List<User> lstUser = insertListOfUsers();
        List<Account> lstAccount2 = insertListOfAcconts();
        
        List<Account> lstAccount3 = SL_TestSetupUtils.CreateAccount('Account' , 1);
        lstAccount3[0].ParentId = lstAccount2[0].Id;
        insert lstAccount3;
        return lstAccount3;
    }
    
    static List<Contact> InsertContact() 
    {   
        List<Account> lstAccount2 = insertListOfAcconts();
        List<User> lstUser = [SELECT Id,
                                     LastName 
                                FROM User
                               WHERE LastName = 'User'];
        
        List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE))
        {
            objContact.AccountId = lstAccount2[0].Id;
            objContact.User__c = lstUser[0].Id;
            lstContactHL.add(objContact);
        }
        insert lstContactHL;
        System.assertEquals(lstContactHL.size(), 2);
        return lstContactHL;
        
    }
    
    
    static List<Contact> InsertExternalContact() 
    {
        //List<User> lstUser = insertListOfUsers();
        List<Account> lstAccount2 = insertListOfAcconts();


       
         List<Contact> lstContactEX = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT))
        {
            objContact.AccountId = lstAccount2[0].Id;
            lstContactEX.add(objContact);
        }
        insert lstContactEX;
        System.assertEquals(lstContactEX.size(), 2);
        return lstContactEX;
        
        
    }
    
    static List<Opportunity__c> InsertListOfOpportunity() 
    {
        List<Account> lstAccount1 = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert lstAccount1;
        List<Account> lstAccount2 = insertListOfAcconts();        
        List<Account> lstAccount3 = insertListofAccount3();

         List<Contact> lstContactEX = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT))
        {
            objContact.AccountId = lstAccount2[0].Id;
            lstContactEX.add(objContact);
        }
        insert lstContactEX;
        System.assertEquals(lstContactEX.size(), 2);
        
         List<Opportunity__c> lstOpportunity = new List<Opportunity__c>();
        for(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 2))
        {
            objOpportunity.Client__c = lstAccount2[0].Id;
            objOpportunity.Subject__c = lstAccount1[0].Id;
            objOpportunity.Stage__c = 'Low';
            objOpportunity.Pitch_Date__c = Date.today();
            objOpportunity.Referral_Company__c = lstAccount3[0].Id; 
            objOpportunity.Beneficial_Owner_Control_Person_form__c = 'No';
            objOpportunity.Estimated_Engagement_Date__c = Date.today().addDays(3);
            objOpportunity.Estimated_Fee__c = 2500;
            lstOpportunity.add(objOpportunity);
        }
        insert lstOpportunity;
        System.assertEquals(lstOpportunity.size(), 2);
        return lstOpportunity;
        
        
    }
    
    static Staff_Role__c InsertStaffRole()
    {
        Staff_Role__c staffRole = new Staff_Role__c(Name='Principal',
                                                    Display_Name__c='Principal', 
                                                    Display_Order__c=1,
                                                    CF__c=true, 
                                                    Engagement__c=true,
                                                    Execution_Team__c=true,
                                                    FAS__c=true,
                                                    FR__c=true,
                                                    Opportunity__c=true,
                                                    SC__c=true);
        insert staffRole;
        return staffRole;
    }
    static testMethod void insertOpportunityInternalTeam()
    {
        List<Opportunity_Internal_Team__c> lstOIT = new List<Opportunity_Internal_Team__c>();
        Staff_Role__c staffRole = InsertStaffRole();
        
        List<Contact> lstContactHL = insertCOntact();
        List<Opportunity__c> lstOpportunity = InsertListOfOpportunity();
        for(Opportunity_Internal_Team__c objOIT : SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c', 2))
        {
            objOIT.Opportunity__c = lstOpportunity[0].Id;
            objOIT.Contact__c = lstContactHL[0].Id;
            objOIT.Staff_Role__c = staffRole.Id;
            lstOIT.add(objOIT);
        }
        Test.StartTest();
        insert lstOIT;
        Test.StopTest();
        System.assertEquals(lstOIT.size(), 2);
    }
    
    
    static List<Engagement__c> insertListOfEngagement()
    {
        List<Account> lstAccount2 = insertListOfAcconts();        

        List<Engagement__c> lstEngagement = new List<Engagement__c>();
        for(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 2))
        {
            objEngagement.Client__c = lstAccount2[0].Id;
            objEngagement.Subject__c = lstAccount2[0].Id;            
            objEngagement.Start_Date__c = Date.Today();
            objEngagement.Job_Type__c = 'Special Situations';
            lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 2);
        return lstEngagement;
    }
    
    
    static List<Engagement_Counterparty__c> InsertListEngagementCounterparty()
    {
        List<Engagement__c> lstEngagement = insertListOfEngagement();   
        List<Account> lstAccount2 = insertListOfAcconts();     
        
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 2))
        {
            objEC.Company__c = lstAccount2[0].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            lstEC.add(objEC);
        }
        insert lstEC;
        System.assertEquals(lstEC.size(), 2);
        return lstEC;
    }
    
    static testMethod void Test_InsertEngagementInternalTeam()
    {
        List<Engagement_Counterparty__c> lstEC = InsertListEngagementCounterparty();
        List<Contact> lstContactEX = InsertExternalContact() ;
        List<Contact> lstContactHL = insertCOntact();
    List<Engagement__c> lstEngagement = [SELECT Client__c, Subject__c, Start_Date__c, Job_Type__c FROM Engagement__c WHERE Job_Type__c = 'Special Situations'];         
        Staff_Role__c staffRole = InsertStaffRole();
  
        Integer i = 0, j = 0;
        List<Engagement_Counterparty_Contact__c> lstECC = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', 2))
        {
            objECC.Counterparty__c = lstEC[0].Id;
            objECC.Contact__c = lstContactEX[i].Id;
            objECC.Type__c = 'Primary';
            lstECC.add(objECC);
            i++;
        }
        insert lstECC;
        System.assertEquals(lstECC.size(), 2);
        List<Engagement_Internal_Team__c> lstEIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objEIT : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 2))
        {
            objEIT.Contact__c = lstContactHL[0].Id;
            objEIT.Engagement__c = lstEngagement[0].Id;
            objEIT.Staff_Role__c = staffRole.Id;
            lstEIT.add(objEIT);
        }
        insert lstEIT;
        System.assertEquals(lstEIT.size(), 2);
        
    }
    
    
    static List<Engagement_Counterparty_Contact__c> InsertEngagementCounterpartyContact(list<Contact> lstContactEX)
    {
        List<Engagement_Counterparty__c> lstEC;
        try
        {
            lstEC = InsertListEngagementCounterparty();
        }
        catch (exception e)
        {
            lstEC= [SELECT Company__c,  Engagement__c FROM Engagement_Counterparty__c];
        }
        //List<Contact> lstContactEX = InsertExternalContact() ;
           
        Integer i = 0, j = 0;
        List<Engagement_Counterparty_Contact__c> lstECC = new List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', 2))
        {
            objECC.Counterparty__c = lstEC[0].Id;
            objECC.Contact__c = lstContactEX[i].Id;
            objECC.Type__c = 'Primary';
            lstECC.add(objECC);
            i++;
        }
        insert lstECC;
        System.assertEquals(lstECC.size(), 2);
        return lstECC;
       
    }
    
    static testMethod void Test_CompanyReport () 
    {   
        List<User> lstUser = insertListOfUsers();
        List<Account> lstAccount2 = insertListOfAcconts();     
        List<Engagement_Counterparty__c> lstEC = InsertListEngagementCounterparty();
        List<Contact> AllContacts = new List<Contact>();
        List<Contact> lstContactEX = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT))
        {
            objContact.AccountId = lstAccount2[0].Id;
            lstContactEX.add(objContact);
        }
        AllContacts.addAll(lstContactEX);
        
       
        
        List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE))
        {
            objContact.AccountId = lstAccount2[0].Id;
            objContact.User__c = lstUser[0].Id;
            lstContactHL.add(objContact);
        }
        AllContacts.addAll(lstContactHL);
        insert AllContacts;
        
    List<Engagement__c> lstEngagement = [SELECT Client__c, Subject__c, Start_Date__c, Job_Type__c FROM Engagement__c WHERE Job_Type__c = 'Special Situations'];
 
        
         Staff_Role__c staffRole = InsertStaffRole();
         Test.StartTest();
    List<Opportunity__c> lstOpportunity = InsertListOfOpportunity();
        

    List<Engagement_Counterparty_Contact__c> lstECC = InsertEngagementCounterpartyContact(lstContactEX);
      List<Delegate_Public_Group__c> lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 1))
        {
            objDPG.Banker__c = lstUser[0].Id;
            lstDPG.add(objDPG);
        }
        insert lstDPG;
        
     
       
      
        Integer i = 0, j = 0;

        List<Event> lstEvent = new List<Event>();
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.Subject = 'Email';
            objEvent.WhatId = lstEC[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.Subject = 'Email';
            objEvent.WhatId = lstEngagement[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.Subject = 'Email';
            objEvent.WhatId = lstOpportunity[0].Id;
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now().addHours(-2);
            objEvent.EndDateTime = datetime.now().addHours(-2);
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhatId = lstAccount2[0].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today();
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhatId = lstAccount2[0].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now().addHours(2);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[j].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
            i++;
            if (i > 2)
                j = 1; 
        }
        
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now().addHours(-2);
            objEvent.EndDateTime = datetime.now().addHours(-2);
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactEX[0].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
        }
        
        i = 0; j = 0; 
        for(Event objEvent : SL_TestSetupUtils.CreateEvent('Event', 2))
        {
            objEvent.StartDateTime = datetime.now();
            objEvent.EndDateTime = datetime.now();
            objEvent.ActivityDate = date.Today().addDays(-1);
            objEvent.OwnerId = Userinfo.getUserId();
            objEvent.WhoId = lstContactHL[j].Id;
            objEvent.Subject = 'Email';
            lstEvent.add(objEvent);
            i++;
            if(i > 2)
                j = 1;
        }
        insert lstEvent;
        
        System.assertEquals(lstEvent.size(), 16);
        
        List<Task> lstTask = new List<Task>();
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[0].Id;
            objTask.Status = 'Not Started';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstECC[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstEngagement[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.ActivityDate = date.Today();
            objTask.Subject = 'Email';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstOpportunity[0].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
        }
        
        i = 0; j = 0;
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.Subject = 'Email';
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactHL[j].Id;
            lstTask.add(objTask);
            i++;
            if(i > 2)
                j = 1;
        }
        
        i = 0; j = 0;
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.Subject = 'Email';
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactHL[j].Id;
            objTask.Status = 'Completed';
            lstTask.add(objTask);
            i++;
            if(i > 2)
                j = 1;
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))
        {
            objTask.ActivityDate = date.Today();
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhoId = lstContactEX[0].Id;
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))  
        {
            objTask.ActivityDate = date.Today().addDays(-180);
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstAccount2[0].Id;
            lstTask.add(objTask);
        }
        
        for(Task objTask : SL_TestSetupUtils.CreateTask('Task', 2))  
        {
            objTask.ActivityDate = date.Today().addDays(-180);
            objTask.Status = 'Completed';
            objTask.OwnerId = Userinfo.getUserId();
            objTask.WhatId = lstAccount2[0].Id;
            lstTask.add(objTask);
        }
        insert lstTask;
       
       // System.assertEquals(lstTask.size(), 50);
       
        System.currentPageReference().getParameters().put('Id',''+lstAccount2[0].Id);  
        SL_CompanyReport objCompanyReport = new SL_CompanyReport();
        //objCompanyReport.getCompany();
       
        objCompanyReport.getCompanyRelationship();
        objCompanyReport.getHLRelationship();
        objCompanyReport.getRecentActivities();
        objCompanyReport.getOpenOpportunities();
        
        objCompanyReport.getTransInvolvement(); 
        objCompanyReport.getDealsData();
        Test.stopTest();
        
       
    }
     
}