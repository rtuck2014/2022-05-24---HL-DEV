//TO DELETE
@isTest
private class SL_Test_RemoveInactiveUsersFromEngShare 
{
    static List<User> lstUser;
    static List<Engagement__c> Engagement2nd;
    static List<Engagement_Internal_Team__c> lstEIT;
    static List<Delegate_Public_Group__c> lstDPG; 
    static List<Engagement__c> lstEngagement;
    static List<Engagement_Internal_Team__c> lstOIT;
    static List<Account> lstAccount;
    static List<Contact> lstContactHL; 
    
    private static void createcommandData() 
    {
         Profile objProfile = [SELECT Id,
                                     Name 
                                FROM Profile
                               WHERE Name = 'Solution Manager'];    
        
        Integer i = 0;
        Integer j = 0;
        lstUser = new List<User>();
        For(User objUser : SL_TestSetupUtils.CreateUser('User',3))
        {
            objUser.Lastname = 'User';
            objUser.Email = 'tuser@yahoo.in';
            objUser.Username =  i+'test543552542@hl2.com';
            objUser.ProfileId = objProfile.Id;
            objUser.Alias = 'tuser';
            objUser.TimeZoneSidKey = 'GMT';
            objUser.LocaleSidKey = 'en_US';
            objUser.EmailEncodingKey = 'ISO-8859-1';
            objUser.LanguageLocaleKey = 'en_US';
            objUser.Has_Delegates__c = false;
            objUser.IsActive = true;
            lstUser.add(objUser);
            i++;
        }
        insert lstUser;
        
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpcNew;
        
        lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert lstAccount;
        System.assertEquals(lstAccount.size(), 1);
        
        i = 0;
        lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 3, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE))
        {
            objContact.AccountId = lstAccount[0].Id;
            objContact.User__c = lstUser[i].Id;
            lstContactHL.add(objContact);
            i++;
        }
        insert lstContactHL;
        System.assertEquals(lstContactHL.size(), 3);
    }   
    
    private static void createDataEngagement() 
    {   
        
        Integer i = 0;
        Integer j = 0;
        lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 1))
        {
            objDPG.Banker__c = lstUser[0].Id;
            lstDPG.add(objDPG);
        }
        insert lstDPG;
        System.assertEquals(lstDPG.size(), 1);
        
        lstEngagement = new List<Engagement__c>();
        For(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 2))
        {
            objEngagement.Client__c = lstAccount[0].Id;
            objEngagement.Subject__c = lstAccount[0].Id;
            objEngagement.Line_of_Business__c = 'FVA';
            objEngagement.Job_Type__c = 'FMV Non-Transaction Based Opinion';
            objEngagement.Industry_Group__c = 'ADG';
            objEngagement.Sector__c = 'Defense';
            objEngagement.Stage__c = 'Evaluating Prospect';
            //objEngagement.Referral_Contact__c = lstContactHL[0].Id;
            objEngagement.Referral_Type__c = 'Attorney';
            lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        
        i = 0; j = 0;
        lstOIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objOIT : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 6))
        {
            if(i > 2)
            {
                i = 0;
                j = 1;
            }
            objOIT.Contact__c = lstContactHL[i].Id;
            objOIT.Engagement__c = lstEngagement[j].Id;
            objOIT.End_Date__c = Date.today();
            objOIT.Start_Date__c = Date.today();
            lstOIT.add(objOIT);
            i++;
        }
        insert lstOIT;
        System.assertEquals(lstOIT.size(), 6);        
    }
    
    private static void createDataEngagements()
    {
        
        Integer i = 0;
        Integer j = 0;
        lstEngagement = new List<Engagement__c>();
        For(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 2))
        {
            objEngagement.Client__c = lstAccount[0].Id;
            objEngagement.Subject__c = lstAccount[0].Id;
            lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 2);
        
        i = 0;
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 4))
        {
            if(i>1)
                j = 1;
            objEC.Company__c = lstAccount[0].Id;
            objEC.Engagement__c = lstEngagement[j].Id;
            lstEC.add(objEC);
            i++;
        }
        insert lstEC;
        System.assertEquals(lstEC.size(), 4);
        
        List<Revenue_Accrual__c> lstRA = new List<Revenue_Accrual__c>{new Revenue_Accrual__c(Engagement__c = lstEngagement[0].Id, Month__c = 'Jan', Year__c = '2014'),
                                                                      new Revenue_Accrual__c(Engagement__c = lstEngagement[1].Id, Month__c = 'Feb', Year__c = '2015')};
        insert lstRA;
        System.assertEquals(lstRA.size(), 2);
        
        i = 0; j = 0;
        lstEIT = new List<Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c objEIT : SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c', 6))
        {
            if(i > 2)
            {
                i = 0;
                j = 1;
            }
            objEIT.Contact__c = lstContactHL[i].Id;
            objEIT.Engagement__c = lstEngagement[j].Id;
            objEIT.End_Date__c = Date.today();
            objEIT.Start_Date__c = Date.today();
            lstEIT.add(objEIT);
            i++;
        }
        insert lstEIT;
    }
    
    private static testMethod void Test_RemoveInactiveUsers()
    {   
        createcommandData();
        createDataEngagement();
        lstUser[0].IsActive = false;
        lstUser[1].IsActive = false;
        lstUser[2].IsActive = false;
        system.runAs(new user(Id = UserInfo.getUserId()))
        {    
            test.startTest();
       //     createDataEngagement();
            System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 6); 
            //update lstUser[0];
            //update lstUser[1];
            //update lstUser[2];
            List<User> overallUserList = new List<User>();
            overallUserList.add(lstUser[0]);
            overallUserList.add(lstUser[1]);
            overallUserList.add(lstUser[2]);
            update overallUserList;
            SL_Batch_RemoveInactiveUsersFromOppShare objBatchRIU = new SL_Batch_RemoveInactiveUsersFromOppShare();
            Database.executeBatch(objBatchRIU, 50);             
            test.stopTest();
        }
     //   System.assertEquals([SELECT Id FROM Engagement__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 0);         
    }
}