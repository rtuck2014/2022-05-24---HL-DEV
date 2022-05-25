@isTest
private class Test_HL_ContactHandler {

  @testSetup
  private static void CreateData() {
    List<Account> accountList = SL_TestSetupUtils.CreateAccount('Account' , 2);
    insert accountList;

    List<Contact> hlContactList = new List<Contact>();
    for (Contact c : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)) {
      c.AccountId = accountList[0].Id;
      hlContactList.add(c);
    }
    insert hlContactList;

    List<Contact> externalContactList = new List<Contact>();
    for (Contact c : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)) {
      c.AccountId = accountList[0].Id;
      externalContactList.add(c);
    }
    insert externalContactList;
  }

  @isTest
  private static void TestContactInsert() {
    List<Account> accountList = [SELECT Id FROM Account];
    List<Contact> hlContactList = new List<Contact>();

    for (Contact c : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)) {
      c.AccountId = accountList[0].Id;
      hlContactList.add(c);
    }

    List<Contact> externalContactList = new List<Contact>();
    for (Contact c : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)) {
      c.AccountId = accountList[0].Id;
      externalContactList.add(c);
    }

    Test.startTest();

    insert hlContactList;
    insert externalContactList;

    Test.stopTest();

    //Verify no Affiliation records are created on Insert
    System.assertEquals(0, [SELECT Id FROM Affiliation__c WHERE Contact__c = : hlContactList[0].Id].size());
    System.assertEquals(0, [SELECT Id FROM Affiliation__c WHERE Contact__c = : externalContactList[0].Id].size());
  }

  @isTest
  private static void TestContactAccountUpdate() {
    Id externalContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
    Id hlContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
    List<Account> accountList = [SELECT Id FROM Account];
    List<Contact> hlContactList = [SELECT Id, Status__c FROM Contact WHERE RecordTypeId = : hlContactRT];
    List<Contact> externalContactList = [SELECT Id, Status__c FROM Contact WHERE RecordTypeId = : externalContactRT];

    //Verify test account user has contact move rights, else assign
    User u = [SELECT Contact_Move_Rights__c FROM User WHERE Id = : UserInfo.getUserId()];

    if (!u.Contact_Move_Rights__c) {
      u.Contact_Move_Rights__c = true;
      update u;
    }

    Test.startTest();

    hlContactList[0].AccountId = accountList[1].Id;
    update hlContactList[0];

    externalContactList[0].AccountId = accountList[1].Id;
    update externalContactList[0];

    Test.stopTest();

    //Verify no Affiliation Record was created for the HL Contact
    System.assertEquals(0, [SELECT Id FROM Affiliation__c WHERE Contact__c = : hlContactList[0].Id].size());
    //Verify an Affiliation Record was created for the External Contact
    System.assertEquals(1, [SELECT Id FROM Affiliation__c WHERE Contact__c = : externalContactList[0].Id].size());
  }

  @isTest
  private static void TestContactAccountDeletionAndUpdate() {
    Id externalContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
    List<Account> accountList = [SELECT Id FROM Account];
    List<Contact> externalContactList = [SELECT Id, Status__c FROM Contact WHERE RecordTypeId = : externalContactRT];

    //Verify test account user has contact move rights, else assign
    User u = [SELECT Contact_Move_Rights__c FROM User WHERE Id = : UserInfo.getUserId()];

    if (!u.Contact_Move_Rights__c) {
      u.Contact_Move_Rights__c = true;
      update u;
    }

    Test.startTest();

    externalContactList[0].AccountId = accountList[1].Id;
    update externalContactList[0];

    delete [SELECT Id FROM Affiliation__c WHERE Contact__c = : externalContactList[0].Id AND Status__c = 'Current'];

    externalContactList[0].AccountId = accountList[0].Id;
    update externalContactList[0];

    Test.stopTest();

    //Verify that two former Affiliation Records were Created
    System.assertEquals([SELECT Id FROM Affiliation__c WHERE Contact__c = : externalContactList[0].Id].size(), 2);
    System.assertEquals([SELECT Id FROM Affiliation__c WHERE Contact__c = : externalContactList[0].Id AND Status__c = 'Former'].size(), 2);
  }

  @isTest
  private static void TestRivaActivityLinkOnContactEmailInsert() {
    List<Account> accountList = [SELECT Id FROM Account];
    Activity__c rivaActivity = new Activity__c();
    Contact c = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];

    c.AccountId = accountList[0].Id;
    insert rivaActivity;
    Activity_Link__c rivaActivityLink = new Activity_Link__c(ActivityId__c = rivaActivity.Id, Email__c = 'test@example.com');
    insert rivaActivityLink;

    Test.startTest();
        c.Email = rivaActivityLink.Email__c;
        insert c;
    Test.stopTest();

    //Verify the ContactId was populated back on the Riva Activity Link
    System.assertEquals(c.Id, [SELECT ContactId__c FROM Activity_Link__c WHERE Id = : rivaActivityLink.Id][0].ContactId__c);
  }

  @isTest
  private static void TestRivaActivityLinkOnContactEmailUpdate() {
    List<Account> accountList = [SELECT Id FROM Account];
    Activity__c rivaActivity = new Activity__c();
    Contact c = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];

    c.AccountId = accountList[0].Id;
    insert rivaActivity;
    insert c;
    Activity_Link__c rivaActivityLink = new Activity_Link__c(ActivityId__c = rivaActivity.Id, Email__c = 'test@example.com');
    insert rivaActivityLink;

    Test.startTest();

    c.Email = rivaActivityLink.Email__c;
    try{
        update c;
    }
    catch (Exception ex){
         System.assertEquals(null, [SELECT ContactId__c FROM Activity_Link__c WHERE Id = : rivaActivityLink.Id][0].ContactId__c);
    }
    Test.stopTest();

    //Verify the ContactId was populated back on the Riva Activity Link
    //System.assertNotEquals(c.Id, [SELECT ContactId__c FROM Activity_Link__c WHERE Id = : rivaActivityLink.Id][0].ContactId__c);
  }

  @isTest
  private static void TestAffiliationMergeForSeparateAccounts() {
    Account masterAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
    Account childAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
    Contact masterContact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
    Contact childContact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];

    insert masterAccount;
    insert childAccount;
    masterContact.AccountId = masterAccount.Id;
    childContact.AccountId = childAccount.Id;
    insert masterContact;
    insert childContact;

    Test.startTest();
        Database.MergeResult mergeResult = Database.merge(masterContact, childContact.Id);
    Test.stopTest();

    //Verify the Affiliation Record is Created
    System.assertEquals(1, [SELECT Id FROM Affiliation__c].size());
  }

  @isTest
  private static void TestAffiliationMergeForSameAccounts() {
    Account masterAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
    Contact masterContact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
    Contact childContact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];

    insert masterAccount;
    masterContact.AccountId = masterAccount.Id;
    childContact.AccountId = masterAccount.Id;
    insert masterContact;
    insert childContact;

    Test.startTest();
        Database.MergeResult mergeResult = Database.merge(masterContact, childContact.Id);
    Test.stopTest();

    //Verify the Affiliation Record is not Created
    System.assertEquals(0, [SELECT Id FROM Affiliation__c].size());
  }

  @isTest
  private static void TestEventUpdateAfterContactMerge() {
    Account masterAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
    Contact masterContact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
    Contact childContact = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
    Event e = SL_TestSetupUtils.CreateEvent('', 1)[0];

    masterAccount.Name = 'Test Account Merge';
    masterContact.FirstName = 'Master';
    masterContact.LastName = 'Contact';
    childContact.FirstName = 'Child';
    childContact.LastName = 'Contact';

    insert masterAccount;
    masterContact.AccountId = masterAccount.Id;
    childContact.AccountId = masterAccount.Id;
    insert masterContact;
    insert childContact;

    e.StartDateTime = System.now();
    e.EndDateTime = e.StartDateTime;
    e.Start_Date__c = System.today();
    e.Start_Time__c = '12:00 AM';
    e.End_Date__c = System.today();
    e.End_Time__c = '12:00 AM';
    e.DurationInMinutes = 0;
    e.WhoId = childContact.Id;
    e.Primary_External_Contact_Id__c = childContact.Id;
    e.Primary_External_Contact__c = childContact.Name;
    e.Primary_External_Contact_Company_Id__c = childContact.AccountId;
    insert e;

    Test.startTest();
        Database.MergeResult mergeResult = Database.merge(masterContact, childContact.Id);
    Test.stopTest();

    //Verify the Event Record was Updated with the Survivor
    Event eUpdated = [SELECT WhoId, Primary_External_Contact_Id__c, Primary_External_Contact__c, Primary_External_Contact_Company_Id__c
                      FROM Event
                      WHERE Id = : e.Id];

    System.assertEquals(masterContact.Id, eUpdated.Primary_External_Contact_Id__c);
    System.assertEquals('Master Contact', eUpdated.Primary_External_Contact__c);
    System.assertEquals(masterContact.AccountId, eUpdated.Primary_External_Contact_Company_Id__c);
    System.assertEquals(masterContact.Id, eUpdated.WhoId);
  }
  
    @isTest
    private static void TestCreateAlumniContact() {
        
        // Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        
        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA'];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;
    
        // Create HL Employee Contact  
        Contact ct = new Contact();
      
        ct.FirstName = 'Abc';
        ct.MiddleName = 'Hij';
        ct.LastName = 'Xyz';
        ct.Legal_First_Name__c = ct.FirstName;
        ct.Legal_Middle_Name__c = ct.MiddleName;
        ct.Legal_Last_Name__c = ct.LastName;
        ct.Line_of_Business__c = 'CORP';
        ct.Office__c = 'LA';
        ct.Industry_Group__c = 'BUS - Business Services';
        ct.Status__c = 'Active';   
        ct.RecordTypeId = hlTypeId;
        if (ctAccountList.size() > 0) {
            ct.AccountId = ctAccountList[0].Id;
        }        
        insert ct;
   
        // Set to Inactive
        ct.Status__c = 'Inactive';
        
        Test.startTest();        
            update ct;
        Test.stopTest();
        
    //Verify the Alumni Contact is Created
    Contact alumni = [SELECT Id, FirstName, MiddleName, LastName, HL_Alumni_Line_of_Business__c, HL_Alumni_Office__c, HL_Alumni_Industry_Group__c,
                          Hire_Date__c, Departure_Date__c, HR_EMPLOYEEID__c, HL_Alumni_Contact__c, HL_Alumni__c
                          FROM Contact 
                          WHERE RecordType.Name = 'External Contact' AND FirstName = 'Abc' AND MiddleName = 'Hij' 
                          AND LastName = 'Xyz' AND HL_Alumni__c = true LIMIT 1];
    System.assertEquals(1, [SELECT Id, Name 
                                FROM Contact 
                                WHERE RecordType.Name = 'External Contact' AND FirstName = 'Abc' AND MiddleName = 'Hij' 
                                AND LastName = 'Xyz' AND HL_Alumni__c = true].size());
        System.assertEquals(ct.Legal_First_Name__c, alumni.FirstName);
        System.assertEquals(ct.Legal_Middle_Name__c, alumni.MiddleName);
        System.assertEquals(ct.Legal_Last_Name__c, alumni.LastName);
        System.assertEquals(ct.Line_of_Business__c, alumni.HL_Alumni_Line_of_Business__c);
        System.assertEquals(ct.Office__c, alumni.HL_Alumni_Office__c);
        System.assertEquals(ct.Industry_Group__c, alumni.HL_Alumni_Industry_Group__c);
        System.assertEquals(ct.Hire_Date__c, alumni.Hire_Date__c);
        System.assertEquals(ct.Departure_Date__c, alumni.Departure_Date__c);
        System.assertEquals(ct.HR_EMPLOYEEID__c, alumni.HR_EMPLOYEEID__c);
        System.assertEquals(ct.Id, alumni.HL_Alumni_Contact__c);
        System.assertEquals(true, alumni.HL_Alumni__c); 
  }
    
    @isTest
    private static void TestCreateAlumniContactInsertExternalContact() {
    
        // Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA'];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;

    // Create Bulk HL Employee 
    List<Contact> bulkContacts = new List<Contact>();
        
        for (integer i = 0; i < 10; i++) {
            Contact ct = new Contact();
      
            ct.FirstName = 'Abc';
            ct.MiddleName = 'Hij';
            ct.LastName = 'Xyz';
            ct.Legal_First_Name__c = ct.FirstName;
            ct.Legal_Middle_Name__c = ct.MiddleName;
            ct.Legal_Last_Name__c = ct.LastName;
            ct.Line_of_Business__c = 'CORP';
            ct.Office__c = 'LA';
            ct.Industry_Group__c = 'BUS - Business Services';
            ct.Status__c = 'Active';   
            ct.RecordTypeId = hlTypeId;
            if (ctAccountList.size() > 0) {
                ct.AccountId = ctAccountList[0].Id;
            }
            bulkContacts.add(ct);
        }

        insert bulkContacts;        
        
        // Set to Inactive
        Integer count = 1; 
        
        // Test Active and Inactive
    for (Contact c : bulkContacts) {
      count++;
            
            if (count > 5) {
                c.Status__c = 'Active';
            } else {
                c.Status__c = 'Inactive';
            }   
    }
  
    Test.startTest();
        update bulkContacts;
    Test.stopTest();
    
    //Verify the Alumni Contact is Created
    List<Contact> externalContacts = new List<Contact>([SELECT Id, Name FROM Contact WHERE RecordType.Name = 'External Contact' AND HL_Alumni__c = true AND Id IN :bulkContacts]);
    
    System.assertEquals(0, externalContacts.size());
  }
    
    @isTest
    private static void TestCreateAlumniContactInvalidLegalFirstNameLegalLastName() {
        // Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA'];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;
    
        // Create HL Employee Contact with No Legal First Name or Legal Last Name
        Contact ct = new Contact();
      
        ct.FirstName = 'Abc';
        ct.MiddleName = 'Hij';
        ct.LastName = 'Xyz';
        ct.Line_of_Business__c = 'CORP';
        ct.Office__c = 'LA';
        ct.Industry_Group__c = 'BUS - Business Services';
        ct.Status__c = 'Active';   
        ct.RecordTypeId = hlTypeId;
        if (ctAccountList.size() > 0) {
            ct.AccountId = ctAccountList[0].Id;
        }        
        insert ct;
        
        // Set to Inactive
    ct.Status__c = 'Inactive';

    Test.startTest();    
        update ct;              
    Test.stopTest();
        
        List<Contact> externalContacts = new List<Contact>([SELECT Id, Name 
                                                            FROM Contact 
                                                            WHERE RecordType.Name = 'External Contact' AND FirstName = 'Abc' AND MiddleName = 'Hij' AND LastName = 'Xyz' AND HL_Alumni__c = true]);
    
    //Verify the Alumni Contact is Created
    System.assertEquals(1, externalContacts.size());
    }
    
    @isTest
    private static void TestCreateAlumniContactInsertRepeat() {
    
    // Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA'];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;
    
    // Create HL Employee Contact  
        Contact ct = new Contact();
      
        ct.FirstName = 'Abc';
        ct.MiddleName = 'Hij';
        ct.LastName = 'Xyz';
        ct.Legal_First_Name__c = ct.FirstName;
        ct.Legal_Middle_Name__c = ct.MiddleName;
        ct.Legal_Last_Name__c = ct.LastName;
        ct.Line_of_Business__c = 'CORP';
        ct.Office__c = 'LA';
        ct.Industry_Group__c = 'BUS - Business Services';
        ct.Status__c = 'Active';   
        ct.RecordTypeId = hlTypeId;
        if (ctAccountList.size() > 0) {
            ct.AccountId = ctAccountList[0].Id;
        }
        
        insert ct;
        
        // Set to Inactive
    ct.Status__c = 'Inactive';

    Test.startTest();    
        update ct;        
        ct.Status__c = 'Active';    
        update ct;
        
        ct.Status__c = 'Inactive';        
        update ct;        
    Test.stopTest();
        
        List<Contact> externalContacts = new List<Contact>([SELECT Id, Name 
                                                            FROM Contact 
                                                            WHERE RecordType.Name = 'External Contact' AND FirstName = 'Abc' AND MiddleName = 'Hij' AND LastName = 'Xyz' AND HL_Alumni__c = true]);
    
    //Verify the Alumni Contact is Created
    System.assertEquals(1, externalContacts.size());
    }
    
    @isTest
    private static void TestCreateAlumniContactBulk() {
    
    // Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        
        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA' LIMIT 1];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;
    
        // Create Bulk HL Employee 
    List<Contact> bulkContacts = new List<Contact>();
        
        for (integer i = 0; i < 30; i++) {
            Contact ct = new Contact();
      
            ct.FirstName = 'Abc';
            ct.MiddleName = 'Hij';
            ct.LastName = 'Xyz';
            ct.Legal_First_Name__c = ct.FirstName;
            ct.Legal_Middle_Name__c = ct.MiddleName;
            ct.Legal_Last_Name__c = ct.LastName;
            ct.Line_of_Business__c = 'CORP';
            ct.Office__c = 'LA';
            ct.Industry_Group__c = 'BUS - Business Services';
            ct.Status__c = 'Active';   
            ct.RecordTypeId = hlTypeId;
            if (ctAccountList.size() > 0) {
                ct.AccountId = ctAccountList[0].Id;
            }
            bulkContacts.add(ct);
        }

        insert bulkContacts;
        
        // Set to Inactive
        for (Contact c : bulkContacts) {
            c.Status__c = 'Inactive';
        }

    Test.startTest();    
        update bulkContacts;              
    Test.stopTest();
        
        List<Contact> externalContacts = new List<Contact>([SELECT Id, Name 
                                                            FROM Contact 
                                                            WHERE RecordType.Name = 'External Contact' AND FirstName = 'Abc' AND MiddleName = 'Hij' AND LastName = 'Xyz' AND HL_Alumni__c = true]);
    
    //Verify the Alumni Contact is Created
    //Should be 1 because the same name, same employee Id
    System.assertEquals(1, externalContacts.size());
  }
    
    @isTest
    private static void TestCreateAlumniContactDuplicateNameDifferentEmployeeId() {
    
    //Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();

        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA' LIMIT 1];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;
    
        List<decimal> employeeIdKeys = new List<decimal>();
        
        //Create First HL Employee
        Contact fct = new Contact(
            FirstName = 'Abc',
            MiddleName = 'Hij',
            LastName = 'Xyz',
            Legal_First_Name__c = 'Abc',
            Legal_Middle_Name__c = 'Hij',
            Legal_Last_Name__c = 'Xyz',
            Line_of_Business__c = 'CORP',
            Office__c = 'LA',
            Industry_Group__c = 'BUS - Business Services',
            Status__c = 'Active',
            RecordTypeId = hlTypeId,
            HR_EMPLOYEEID__c = 31 * 10000
        );
        
        if (ctAccountList.size() > 0) {
            fct.AccountId = ctAccountList[0].Id;
        }
        employeeIdKeys.add(fct.HR_EMPLOYEEID__c);
        
        insert fct;
        
        //Create Bulk HL Employee 
    List<Contact> bulkContacts = new List<Contact>();
        
        for (integer i = 0; i < 30; i++) {
            Contact ct = new Contact();
      
            ct.FirstName = 'Abc';
            ct.MiddleName = 'Hij';
            ct.LastName = 'Xyz';
            ct.Legal_First_Name__c = ct.FirstName;
            ct.Legal_Middle_Name__c = ct.MiddleName;
            ct.Legal_Last_Name__c = ct.LastName;
            ct.Line_of_Business__c = 'CORP';
            ct.Office__c = 'LA';
            ct.Industry_Group__c = 'BUS - Business Services';
            ct.Status__c = 'Active';   
            ct.RecordTypeId = hlTypeId;
            ct.HR_EMPLOYEEID__c = i * 10000;
            if (ctAccountList.size() > 0) {
                ct.AccountId = ctAccountList[0].Id;
            }
            bulkContacts.add(ct);
            
            employeeIdKeys.add(ct.HR_EMPLOYEEID__c);
        }

        insert bulkContacts;        
        //Set to Inactive
        fct.Status__c = 'Inactive';
        
        for (Contact c : bulkContacts) {
            c.Status__c = 'Inactive';
        }

    Test.startTest();    
        //Update First Contact
        update fct;
        
        //Update Rest of the Contacts
        //Even though alumni exists for the same name, each employee ID is different
        update bulkContacts;          
    Test.stopTest();
        
        List<Contact> externalContacts = new List<Contact>([SELECT Id, Name 
                                                            FROM Contact 
                                                            WHERE RecordType.Name = 'External Contact' AND HL_Alumni_HR_Employee_ID__c IN :employeeIdKeys]);
    
    //Verify that all Alumni Contacts are Created
    System.assertEquals(31, externalContacts.size());
    }
    
    @isTest
    private static void TestCreateAlumniContactUncheckAlumniUpdateIntenalToInactiveTwice() {
    
    //Set Up - Create Accounts, Get IDs
        string hlTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();

        List<Account> ctAccountList = [SELECT Id, Name 
                                       FROM Account 
                                       WHERE Name = 'Houlihan Lokey - LA' LIMIT 1];
        Account newAccount = new Account();
        newAccount.Name = 'Contacts in Transition';
        insert newAccount;
    
        List<decimal> employeeIdKeys = new List<decimal>();
        
        //Create First HL Employee
        Contact fct = new Contact(
            FirstName = 'Abc',
            MiddleName = 'Hij',
            LastName = 'Xyz',
            Legal_First_Name__c = 'Abc',
            Legal_Middle_Name__c = 'Hij',
            Legal_Last_Name__c = 'Xyz',
            Line_of_Business__c = 'CORP',
            Office__c = 'LA',
            Industry_Group__c = 'BUS - Business Services',
            Status__c = 'Active',
            RecordTypeId = hlTypeId,
            HR_EMPLOYEEID__c = 31 * 10000
        );
        
        if (ctAccountList.size() > 0) {
            fct.AccountId = ctAccountList[0].Id;
        }
        employeeIdKeys.add(fct.HR_EMPLOYEEID__c);
        
        insert fct;
        
        //Set to Inactive
        fct.Status__c = 'Inactive';

    Test.startTest();    
    //Update Contact
    update fct;
    
    //Get Alumni Record
    List<Contact> externalContactList = new List<Contact>([SELECT Id, Name, HL_Alumni__c 
                                                               FROM Contact 
                                                               WHERE RecordType.Name = 'External Contact' AND HL_Alumni_HR_Employee_ID__c IN :employeeIdKeys]);
    
        System.assertEquals(1, externalContactList.size());
        System.assertEquals(true, externalContactList[0].HL_Alumni__c);
        
        //Set Alumni flag to false
        externalContactList[0].HL_Alumni__c = false;
             
        update externalContactList[0];        
        //Set to Active
        fct.Status__c = 'Active';        
        //Update Contact
        update fct;        
        //Set to Inactive
        fct.Status__c = 'Inactive';        
        //Update Contact
        update fct;        
    Test.stopTest();
        
        List<Contact> alumniContactList = new List<Contact>([SELECT Id, Name, HL_Alumni__c
                                                             FROM Contact 
                                                             WHERE RecordType.Name = 'External Contact' AND HL_Alumni_HR_Employee_ID__c IN :employeeIdKeys]);
    
    //Verify that all Alumni Contacts are Created
    System.assertEquals(1, alumniContactList.size());
    System.assertEquals(true, alumniContactList[0].HL_Alumni__c);
    }
  
    @isTest
    private static void testPopulatingEndDateofOppVPPositionTM() {
        List<Account> accList = [Select Id From Account ];
        List<Contact> ContList = [Select Id, Status__c From Contact];
        
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
        
        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accList[0].Id;
        opportunity.Subject__c = accList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'FVA';
        opportunity.Job_Type__c = 'FA - Portfolio-Valuation';

        opportunity.Primary_Office__c = 'AT';
        insert opportunity;
        
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
        
        List<Opp_VP_TeamMember__c> oppVPTMList = new List<Opp_VP_TeamMember__c>();
        Opp_VP_TeamMember__c oppVPTM = new Opp_VP_TeamMember__c();
        oppVPTM.Opportunity_VP_Position__c = oppVPPos.id; 
        oppVPTM.Staff__c = ContList[0].id;
        oppVPTM.Role__c = 'Analyst';
        oppVPTM.start_Date__c = Date.today();
        oppVPTMList.add(oppVPTM);
        
        Opp_VP_TeamMember__c oppVPTM1 = new Opp_VP_TeamMember__c();
        oppVPTM1.Opportunity_VP_Position__c = oppVPPos.id; 
        oppVPTM1.Staff__c = ContList[0].id;
        oppVPTM1.Role__c = 'Analyst';
        oppVPTM1.start_Date__c = Date.today()+3;
        oppVPTMList.add(oppVPTM1);
        try{
            insert oppVPTMList;
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
            system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }
        
        ContList[0].Status__c = 'Inactive';        
        try{
            update ContList[0];
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
            system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }
        Set<Opp_VP_TeamMember__c> oppSet = new Set<Opp_VP_TeamMember__c>();
        oppSet.addAll(oppVPTMList);
        HL_ContactHandler.removeDuplicateOppVpTMRecrds(oppSet);
        
    }
    
    Static testMethod void removeDuplicateEngVpTMRecrdsTest(){
        
        List<Account> accList = [Select Id From Account ];
        List<Contact> ContList = [Select Id, Status__c From Contact];
        
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
        
        Engagement__c engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        engagement.Name='Test Opportunity';
        engagement.Client__c = accList[0].Id;
        engagement.Subject__c = accList[0].Id;
        engagement.Stage__c = 'Pitched';
        engagement.Line_of_Business__c = 'CF';
        engagement.Job_Type__c = 'FA - Portfolio-Valuation';
        engagement.Primary_Office__c = 'AT';
        insert engagement;
        
        Eng_VP__c engVP =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);
        engVP.Name='Test Eng';        
        engVP.Engagement__c=engagement.id;
        engVP.Valuation_Date__c=System.Today()+5;
        engVP.CurrencyIsoCode='USD';        
        Insert engVP; 
        
        Eng_VP_Position__c engVPPos =(Eng_VP_Position__c)HL_TestFactory.CreateSObject('Eng_VP_Position__c',false);
        engVPPos.Name=accList[0].Id;
        engVPPos.Company__c=accList[0].Id;
        engVPPos.Engagement_VP__c=engVP.Id;
        engVPPos.Report_Fee__c=100;
        engVPPos.Asset_Classes__c='Debt';
        engVPPos.CurrencyIsoCode='USD';
        insert engVPPos;  
        
        List<Eng_VP_TeamMember__c> engVPTMList = new List<Eng_VP_TeamMember__c>();
        Eng_VP_TeamMember__c engVPTM = new Eng_VP_TeamMember__c();
        engVPTM.Engagement_VP_Position__c = engVPPos.id; 
        engVPTM.Staff__c = ContList[0].id;
        engVPTM.Role__c = 'Analyst';
        engVPTM.start_Date__c = Date.today();
        engVPTMList.add(engVPTM);
        
        Eng_VP_TeamMember__c engVPTM1 = new Eng_VP_TeamMember__c();
        engVPTM1.Engagement_VP_Position__c = engVPPos.id;  
        engVPTM1.Staff__c = ContList[0].id;
        engVPTM1.Role__c = 'Analyst';
        engVPTM1.start_Date__c = Date.today()+3;
        engVPTMList.add(engVPTM1);
        try{
            insert engVPTMList;
            System.debug(engVPTMList);
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
            system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }
        Set<Eng_VP_TeamMember__c> engIdSet = new Set<Eng_VP_TeamMember__c>();
        engIdSet.addAll(engVPTMList);
        HL_ContactHandler.removeDuplicateEngVpTMRecrds(engIdSet);
    }
    
    Static testMethod void PopulateEndDateonVpPositionTMEngTest(){
        
        Account account = new Account();
        account.name = 'Test account';
        account.Billing_County__c = 'United State';
      	insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        contact.Status__c = 'active';
        insert contact;
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        oldContactMap.put(contact.id,contact);
        system.debug(oldContactMap);
        
        
        contact.Status__c = 'Inactive';
        ///update contact;
        
        Monthly_Revenue_Process_Control__c Mrpc = new Monthly_Revenue_Process_Control__c();
        Mrpc.Name = 'Test MPRC';
        insert Mrpc;
        
        Map<Id, Contact> newContactMap = new Map<Id, Contact>();
        newContactMap.put(contact.id, contact);
        system.debug(newContactMap);
        
        HL_ContactHandler hlHandler = new HL_ContactHandler();
        hlHandler.PopulateEndDateonVpPositionTMEng(oldContactMap, newContactMap, Mrpc);
    }
    
      @isTest
  private static void TestContactUpdate() {
    List<Account> accountList = [SELECT Id FROM Account];
    List<Account> accountListToUpdate = new List<Account>();

    List<Contact> hlContactList = new List<Contact>();
    for (Contact c : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)) {
        c.AccountId = accountList[0].Id;
        c.Inherit_Company_Address__c = true;
        hlContactList.add(c);
      }
      insert hlContactList;

    for(Account a : accountList){
        a.BillingStreet = 'ABC Street';
       // a.BillingPostalCode = '1234';
        accountListToUpdate.add(a);
    }
    Test.startTest();
    update accountListToUpdate;
  // Test.stopTest();
	
      
      accountListToUpdate.clear();
      
    for(Account a : accountList){
        a.BillingPostalCode = '1234';
        accountListToUpdate.add(a);
    }
   // Test.startTest();
    update accountListToUpdate;
    Test.stopTest();
     Contact contactRec = [SELECT MailingStreet FROM Contact WHERE Id = : hlContactList[0].Id];
    System.assertEquals('ABC Street', contactRec.MailingStreet);
	Contact contactRec2 = [SELECT MailingPostalCode FROM Contact WHERE Id = : hlContactList[0].Id];
    System.assertEquals('1234', contactRec2.MailingPostalCode);
  }
}