@isTest
private class Test_HL_AccountHandler {
    @isTest
    private static void TestAccountUltimateParentAssignment() {
        List<Account> accountList = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert accountList;

        Test.startTest();

        List<Account> accountList1 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2)) {
            objAccount.ParentId = accountList[0].Id;
            accountList1.add(objAccount);
        }

        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2)) {
            objAccount.ParentId = accountList[1].Id;
            accountList1.add(objAccount);
        }
        insert accountList1;

        Account acc = [SELECT Ultimate_Parent__c FROM Account WHERE Id = :accountList1[0].Id];
        System.assertEquals(acc.Ultimate_Parent__c, accountList[0].Id);

        List<Account> accountList2 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2)) {
            objAccount.ParentId = accountList1[0].Id;
            accountList2.add(objAccount);
        }

        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2)) {
            objAccount.ParentId = accountList1[2].Id;
            accountList2.add(objAccount);
        }
        insert accountList2;

        List<Account> accountList3 = new List<Account>();
        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2)) {
            objAccount.ParentId = accountList2[1].Id;
            accountList3.add(objAccount);
        }

        For(Account objAccount : SL_TestSetupUtils.CreateAccount('Account', 2)) {
            objAccount.ParentId = accountList2[3].Id;
            accountList3.add(objAccount);
        }
        insert accountList3;

        accountList1[0].ParentId = accountList1[3].Id;
        update accountList1[0];

        Account acc1 = [SELECT Ultimate_Parent__c FROM Account WHERE Id = :accountList3[1].Id];

        accountList[1].ParentId = accountList[0].Id;
        update accountList[1];

        Account acc2 = [SELECT Ultimate_Parent__c FROM Account WHERE Id = :accountList3[3].Id];

        delete accountList1[0];

        Account acc3 = [SELECT Ultimate_Parent__c FROM Account WHERE Id = :accountList3[1].Id];

        Account acc4 = [SELECT ParentId, Ultimate_Parent__c FROM Account WHERE Id = :accountList2[1].Id];

        Test.stopTest();

        //Verify the Parent Ids were Assigned Correctly
        System.assertEquals(acc1.Ultimate_Parent__c, accountList[1].Id);
        System.assertEquals(acc2.Ultimate_Parent__c, accountList[0].Id);
        System.assertEquals(acc3.Ultimate_Parent__c, accountList2[1].Id);
        System.assertEquals(acc4.ParentId, null);
        System.assertEquals(acc4.Ultimate_Parent__c, null);
    }

    @isTest
    private static void TestEventUpdateAfterAccountMerge() {
        Account masterAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Account childAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Contact contact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];

        Event e = SL_TestSetupUtils.CreateEvent('', 1)[0];

        masterAccount.Name = 'Test Account Master';
        childAccount.Name = 'Test Account Child';
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';

        insert masterAccount;
        insert childAccount;

        contact.AccountId = childAccount.Id;
        insert contact;

        e.StartDateTime = System.now();
        e.EndDateTime = e.StartDateTime;
        e.Start_Date__c = System.today();
        e.Start_Time__c = '12:00 AM';
        e.End_Date__c = System.today();
        e.End_Time__c = '12:00 AM';
        e.DurationInMinutes = 0;
        e.WhoId = contact.Id;
        e.Primary_External_Contact_Id__c = contact.Id;
        e.Primary_External_Contact__c = contact.Name;
        e.Primary_External_Contact_Company_Id__c = contact.AccountId;
        insert e;

        Test.startTest();

        Database.MergeResult mergeResult = Database.merge(masterAccount, childAccount.Id);

        Test.stopTest();

        //Verify the Event Record was Updated with the Survivor
        Event eUpdated = [SELECT Primary_External_Contact_Company_Id__c
                          FROM Event
                          WHERE Id = : e.Id];

        System.assertEquals(masterAccount.Id, eUpdated.Primary_External_Contact_Company_Id__c);
    }

    @isTest
    private static void TestCapIQHierarchyAssignmentFromParent(){
        CapIQ_Company__c capIQAccount = SL_TestSetupUtils.CreateCapIQCompany('CapIQCompany', 1)[0];
        insert capIQAccount;
        Account parentAccount = SL_TestSetupUtils.CreateAccount('Account', 1)[0];
        List<Account> childAccountList = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert parentAccount;
        for(Account a : childAccountList)
            a.ParentId = parentAccount.Id;
        insert childAccountList;

        Test.startTest();

        parentAccount.CapIQ_Company__c = capIQAccount.Id;
        update parentAccount;

        Test.stopTest();

        //Validate the CapIQ Company was assigned to all Accounts
        //for(Account a : [SELECT CapIQ_Company__c FROM Account])
        //    System.assertEquals(capIQAccount.Id, a.CapIQ_Company__c);
    }

    @isTest
    private static void TestCapIQHierarchyAssignmentFromChild(){
        CapIQ_Company__c capIQAccount = SL_TestSetupUtils.CreateCapIQCompany('CapIQCompany', 1)[0];
        insert capIQAccount;
        Account parentAccount = SL_TestSetupUtils.CreateAccount('Account', 1)[0];
        List<Account> childAccountList = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert parentAccount;
        for(Account a : childAccountList)
            a.ParentId = parentAccount.Id;
        insert childAccountList;

        Test.startTest();

        childAccountList[0].CapIQ_Company__c = capIQAccount.Id;
        update childAccountList[0];

        Test.stopTest();

        //Validate the CapIQ Company was Assigned to All Accounts
        //for(Account a : [SELECT CapIQ_Company__c FROM Account])
            //System.assertEquals(capIQAccount.Id, a.CapIQ_Company__c);
    }

    @isTest
    private static void TestCapIQHierarchyAssignmentFromInsertOfNewChildToExistingHierarchy(){
        CapIQ_Company__c capIQAccount = SL_TestSetupUtils.CreateCapIQCompany('CapIQCompany', 1)[0];
        insert capIQAccount;
        Account parentAccount = SL_TestSetupUtils.CreateAccount('Account', 1)[0];
        List<Account> childAccountList = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert parentAccount;
        for(Account a : childAccountList)
            a.ParentId = parentAccount.Id;
        //Only Insert the First Child here so we can Test a New Insert
        insert childAccountList[0];

        Test.startTest();

        childAccountList[1].CapIQ_Company__c = capIQAccount.Id;
        insert childAccountList[1];

        Test.stopTest();

        //Validate the CapIQ Company was assigned to all Accounts
        //for(Account a : [SELECT CapIQ_Company__c FROM Account])
            //System.assertEquals(capIQAccount.Id, a.CapIQ_Company__c);
    }

    @isTest
    private static void TestCapIQHierarchyAssignmentAtParentDoesNotOverwriteExistingCapIQAssignmentAtChildren(){
        List<CapIQ_Company__c> capIQAccountList = SL_TestSetupUtils.CreateCapIQCompany('CapIQCompany', 2);
        insert capIQAccountList;
        Account parentAccount = SL_TestSetupUtils.CreateAccount('Account', 1)[0];
        parentAccount.CapIQ_Company__c = capIQAccountList[0].Id;
        List<Account> childAccountList = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert parentAccount;
        for(Account a : childAccountList){
            a.CapIQ_Company__c = capIQAccountList[0].Id;
            a.ParentId = parentAccount.Id;
        }
        insert childAccountList;

        Test.startTest();

        parentAccount.CapIQ_Company__c = capIQAccountList[1].Id;
        update parentAccount;

        Test.stopTest();

        //Validate the CapIQ Company assigned to the Child Accounts did not Change with the Parent's Update
        for(Account a : [SELECT CapIQ_Company__c FROM Account WHERE Id !=: parentAccount.Id])
            System.assertEquals(capIQAccountList[0].Id, a.CapIQ_Company__c);
    }

    @isTest
    private static void TestCapIQHierarchyAssignmentAtChildDoesNotOverwriteExistingCapIQAssignmentAtParent(){
        List<CapIQ_Company__c> capIQAccountList = SL_TestSetupUtils.CreateCapIQCompany('CapIQCompany', 2);
        insert capIQAccountList;
        Account parentAccount = SL_TestSetupUtils.CreateAccount('Account', 1)[0];
        parentAccount.CapIQ_Company__c = capIQAccountList[0].Id;
        List<Account> childAccountList = SL_TestSetupUtils.CreateAccount('Account', 2);
        insert parentAccount;
        for(Account a : childAccountList)
            a.ParentId = parentAccount.Id;
        insert childAccountList;

        Test.startTest();

        childAccountList[0].CapIQ_Company__c = capIQAccountList[1].Id;
        update childAccountList[0];

        Test.stopTest();

        //Validate the CapIQ Company Assigned to the Child Account did not Change the One Already Assigned to the Parent
        for(Account a : [SELECT CapIQ_Company__c FROM Account WHERE Id =: parentAccount.Id])
            System.assertEquals(capIQAccountList[0].Id, a.CapIQ_Company__c);

        //Validate both Child Accounts were Populated with the Assigned Cap IQ Company
        //for(Account a : [SELECT CapIQ_Company__c FROM Account WHERE Id !=: parentAccount.Id])
            //System.assertEquals(capIQAccountList[1].Id, a.CapIQ_Company__c);
    }
/* 
    @isTest
    private static void TestIsEUCF(){
        List<Account> updateList = SL_TestSetupUtils.CreateAccount('UpdateListAcc', 551);
        
        for(Account a : updateList){
            a.BillingCountry = '';
        }

        insert updateList;

        Test.startTest();

        List<Account> nonEUList = SL_TestSetupUtils.CreateAccount('NonEUAcc', 251);
        List<Account> eUList = SL_TestSetupUtils.CreateAccount('EUAcc', 251);

        for(Account a : nonEUList){
            //Modified as part of State/Country Picklist
            a.BillingCountry = 'UNITED STATES';
        }
        for(Account a : eUList){
            a.BillingCountry = 'SERBIA';
        }

        insert nonEUList;
        insert eUList;

        for(Account a : updateList){
            a.BillingCountry = 'FRANCE';
        }

        update updateList;

        Test.stopTest();

        for(Account a : [SELECT Is_Client_EU_CF__c FROM Account WHERE Id =: nonEUList])
            System.assertEquals(FALSE, a.Is_Client_EU_CF__c);

        for(Account a : [SELECT Is_Client_EU_CF__c FROM Account WHERE Id =: eUList])
            System.assertEquals(TRUE, a.Is_Client_EU_CF__c);

        for(Account a : [SELECT Is_Client_EU_CF__c FROM Account WHERE Id =: updateList])
            System.assertEquals(TRUE, a.Is_Client_EU_CF__c);
    }  
    */
    @isTest
    private static void testCleanJobByPass(){
       List<Account> AccList = SL_TestSetupUtils.CreateAccount('Account', 1);
       insert AccList;       
       AccList[0].Clean_Job_By_Pass__c = true;
       update AccList;
       
     //  for(Account a : [SELECT Clean_Job_By_Pass__c,cleanStatus FROM Account limit 1])
       //    System.assertEquals('Skipped', a.cleanStatus);
    } 
    @isTest
    private static void testCleanJobByPass_Notcompared(){
       List<Account> AccList = SL_TestSetupUtils.CreateAccount('Account', 1);
       insert AccList;
       AccList[0].Clean_Job_By_Pass__c = true;
       update AccList;
       AccList[0].Clean_Job_By_Pass__c = false;
       update AccList;              
       //Commented out reference to data.com fields - 05Jan2020
       //for(Account a : [SELECT Clean_Job_By_Pass__c,cleanStatus FROM Account limit 1]){
       //      System.assertNotEquals('Skipped', a.cleanStatus);       
       //} 
    }
    @isTest
    static void updatePrimaryBillingContactDataTest(){
        
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        insert contact;
        
        
        account.Primary_Billing_Contact__c = contact.Id;
        update account;
    }
    
    @isTest
    static void setERPAccountContactFlagsTest(){
        
        Account account = new Account();
        account.Name = 'Test1 Account';
        account.BillingCity = 'New York';
        account.ShippingCity = 'Amsterdam';
        account.ERP_Org_Party_ID__c = '123456';
        account.ERP_Contact_Email__c = 'test@gmail.com';
        insert account;
       
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        insert contact;
        
        account.BillingCity = 'London';
        account.ShippingCity = 'New Port';
        account.Primary_Billing_Contact__c = contact.Id;
        account.ERP_Contact_Email__c = 'test1@gmail.com';
        update account;
        
       Account acc = [Select ERP_Bill_To_Address_Flag__c,ERP_Ship_To_Address_Flag__c,ERP_Contact_Flag__c,ERP_Contact_Point_Email_Flag__c,ERP_Contact_Point_Phone_Flag__c from Account where Id = :account.Id] ;
       system.assertEquals('Update', acc.ERP_Bill_To_Address_Flag__c);
       system.assertEquals('Update', acc.ERP_Ship_To_Address_Flag__c);
       system.assertEquals('New', acc.ERP_Contact_Flag__c);
       system.assertEquals('New', acc.ERP_Contact_Point_Email_Flag__c);
       system.assertEquals('New', acc.ERP_Contact_Point_Phone_Flag__c);   
               
    }
    
    @isTest
    static void setERPAccountContactFlagsTest1(){
      
        Account account = new Account();
        account.Name = 'Test1 Account';
        insert account;
        
        account.ERP_Org_Party_ID__c = '123456';
        account.BillingCity = 'Delhi';
        account.ShippingCity = 'Mumbai';
        update account;
        
       Account acc = [Select ERP_Bill_To_Address_Flag__c,ERP_Ship_To_Address_Flag__c from Account where Id = :account.Id] ;
       system.assertEquals('New', acc.ERP_Bill_To_Address_Flag__c);
       system.assertEquals('New', acc.ERP_Ship_To_Address_Flag__c);
       
        
        Account a = new Account();
        a.Name = 'Test1 Account';
        insert a;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.ERP_Contact_Point_Phone_ID__c = '456789';
        contact.ERP_Contact_Flag__c = 'New';
        contact.ERP_Contact_Point_Relationship_ID__c ='3456789';
        contact.ERP_Contact_Point_Email_ID__c = '12345';
        contact.ERP_Contact_Point_Email_Flag__c = 'New';
        contact.ERP_Contact_Point_Phone_Flag__c = 'New';
        contact.AccountId = a.Id;
        insert contact;
        
             a.Primary_Billing_Contact__c = contact.Id;
             a.ERP_Contact_First_Name__c = contact.FirstName;
             a.ERP_Contact_Last_Name__c = contact.LastName;
             a.ERP_Contact_Email__c = contact.Email;
             a.ERP_Contact_Phone__c = contact.Phone;
             a.ERP_Contact_ID__c = '1234567';
             //a.ERP_Parent_Party_ID__c = '456789';
             a.ERP_Contact_Flag__c = contact.ERP_Contact_Flag__c;
             a.ERP_Contact_Point_Email_Flag__c = contact.ERP_Contact_Point_Email_Flag__c;
             a.ERP_Contact_Point_Email_ID__c = contact.ERP_Contact_Point_Email_ID__c;
             a.ERP_Contact_Point_Phone_Flag__c = contact.ERP_Contact_Point_Phone_Flag__c;
             a.ERP_Contact_Point_Phone_ID__c = contact.ERP_Contact_Point_Phone_ID__c;
             a.ERP_Contact_Point_Relationship_ID__c = contact.ERP_Contact_Point_Relationship_ID__c;
         
        update a;
        
        a.Primary_Billing_Contact__c = Null;
        update a;
    
             a.ERP_Contact_First_Name__c = Null;
             a.ERP_Contact_Last_Name__c = Null;
             a.ERP_Contact_Email__c = Null;
             a.ERP_Contact_Phone__c = Null;
             a.ERP_Person_Party_ID__c = Null;
             a.ERP_Contact_ID__c = Null;
             a.ERP_Contact_Flag__c = Null;
             a.ERP_Contact_Point_Email_Flag__c = Null;
             a.ERP_Contact_Point_Email_ID__c = Null;
             a.ERP_Contact_Point_Phone_Flag__c = Null;
             a.ERP_Contact_Point_Phone_ID__c = Null;
             a.ERP_Contact_Point_Relationship_ID__c = Null;
         
        update a;
        
    }
}