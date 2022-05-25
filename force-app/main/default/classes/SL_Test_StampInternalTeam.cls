@isTest
private class SL_Test_StampInternalTeam {

    static void dataFactory() {
        List<Role_Split__c> lstSplit = SL_TestSetupUtils.CreateRoleSplit('Role_Split__c', 1);
        lstSplit[0].Percentage_Allocation__c = 9;
        lstSplit[0].Role__c = 'Principal';

        insert lstSplit;
    }

    //Insertion of Engagement Internal Team records, workflows should populate the Office and LOBs
    @isTest
    static void addNewEIT()
    {
        List<Account> aList = SL_TestSetupUtils.CreateAccount('Account', 3);
        insert aList;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 3, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        cList[0].AccountId = aList[0].Id;
        cList[1].AccountId = aList[1].Id;
        cList[2].AccountId = aList[2].Id;

        cList[0].Line_Of_Business__c = 'CF';
        cList[1].Line_Of_Business__c = 'FVA';
        cList[2].Line_Of_Business__c = 'CF';
        cList[0].Office__c = 'AB';
        cList[1].Office__c = 'BC';
        cList[2].Office__c = 'AB';
		cList[0].Industry_Group__c = 'ADG';
        cList[2].Industry_Group__c = 'ADG';
        insert cList;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, Office__c, Line_Of_Business__c from Contact]);

        //Create EIT records and assert the values
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        insert e;
        Test.startTest();
        Engagement_Internal_Team__c et1 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0];
        et1.Contact__c = cList[0].Id;
        et1.Engagement__c = e.Id;
        et1.Start_Date__c = System.today().addDays(- 1);
        et1.End_Date__c = System.today().addDays(1);
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

        et1.Staff_Role__c = staffRole.Id;
        insert et1;

        et1 = [Select Id, Staff_Revenue_Split__c,Office__c, LOB__c from Engagement_Internal_Team__c Where Id = : et1.Id];

        //Check if the EIT workflows are working fine
        Contact c1 = contactMap.get(cList[0].Id);
        //System.assertEquals(c1.Office__c.substring(0,2), et1.Office__c, 'Incorrect EIT OFfice');
        //System.assertEquals(c1.Line_Of_Business__c, et1.LOB__c, 'Incorrect EIT LOB');
        Test.stopTest();
    }

    // Insert new Opportunity Internal Team and validate the Office and LOB values coming from related Contact
    @isTest
    static void addNewOIT()
    {
        List<Account> aList = SL_TestSetupUtils.CreateAccount('Account', 3);
        insert aList;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 3, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        cList[0].AccountId = aList[0].Id;
        cList[0].Line_Of_Business__c = 'CF';
        cList[0].Office__c = 'AB';
        cList[0].Industry_Group__c = 'ADG';
        insert cList;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, Office__c, Line_Of_Business__c from Contact]);
        //Create EIT records and assert the values
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('Opportunity__c', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;

        Test.startTest();
        Opportunity_Internal_Team__c ot1 = SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c',1)[0];
        ot1.Contact__c = cList[0].Id;
        ot1.Opportunity__c = o.Id;
        ot1.Start_Date__c = System.today().addDays( - 1);
        ot1.End_Date__c = System.today().addDays(1);

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

        ot1.Staff_Role__c = staffRole.Id;
        insert ot1;

        ot1 = [Select Id,Office__c, LOB__c from Opportunity_Internal_Team__c Where Id = : ot1.Id];

        //Check if the EIT workflows are working fine
        Contact c1 = contactMap.get(cList[0].Id);
        System.assertEquals(c1.Office__c.substring(0,2), ot1.Office__c, 'Incorrect EIT OFfice');
        System.assertEquals(c1.Line_Of_Business__c, ot1.LOB__c, 'Incorrect EIT LOB');
        Test.stopTest();

    }

    @isTest
    static void validateOfficeSplits()
    {
        dataFactory();
        List<Account> aList = SL_TestSetupUtils.CreateAccount('Account', 3);
        insert aList;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 3, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        cList[0].AccountId = aList[0].Id;
        cList[1].AccountId = aList[1].Id;
        cList[2].AccountId = aList[2].Id;
        cList[0].Office__c = 'AB';
        cList[1].Office__c = 'BC';
        cList[2].Office__c = 'AB';
        insert cList;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, Office__c, Line_Of_Business__c from Contact]);

        //Create EIT records and assert the values
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        insert e;
        Test.startTest();
        List<Engagement_Internal_Team__c> etList = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',3);
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
        for(Engagement_Internal_Team__c et: etList)
        {
            et.Engagement__c = e.Id;
            et.Start_Date__c = System.today().addDays(-1);
            et.End_Date__c = System.today().addDays(1);
            et.Staff_Role__c = staffRole.Id;
        }

        etList[0].Contact__c = cList[0].Id;
        etList[1].Contact__c = cList[1].Id;
        etList[2].Contact__c = cList[2].Id;

        insert etList;

       Map<Id, Engagement_Internal_Team__c> etMap = new Map<Id, Engagement_Internal_Team__c>([Select Id, Staff_Revenue_Split__c,Office__c, LOB__c, Office_Revenue_Split__c, Contact__c
                    FROM Engagement_Internal_Team__c Where Engagement__c = : e.Id]);

       Engagement_Internal_Team__c et1 = etMap.get(etList[0].Id);
       Engagement_Internal_Team__c et2 = etMap.get(etList[1].Id);
       Engagement_Internal_Team__c et3 = etMap.get(etList[2].Id);

       //System.assertEquals('AB', et1.Office__c, 'Incorrect Office');
       //System.assertEquals('BC', et2.Office__c, 'Incorrect Office');
       //System.assertEquals('AB', et3.Office__c, 'Incorrect Office');

       System.assertEquals(null, et1.Staff_Revenue_Split__c, 'Incorrect Staff_Revenue_Split');
       System.assertEquals(null, et2.Staff_Revenue_Split__c, 'Incorrect Staff_Revenue_Split');
       System.assertEquals(null, et3.Staff_Revenue_Split__c, 'Incorrect Staff_Revenue_Split');

       System.assertEquals(null, et1.Office_Revenue_Split__c, 'Incorrect Office_Revenue_Split');
       System.assertEquals(null, et2.Office_Revenue_Split__c, 'Incorrect Office_Revenue_Split');
       System.assertEquals(null, et3.Office_Revenue_Split__c, 'Incorrect Office_Revenue_Split');

        //Check if the EIT workflows are working fine
        Contact c1 = contactMap.get(cList[0].Id);
        System.assertEquals(c1.Office__c.substring(0,2), et1.Office__c, 'Incorrect EIT OFfice');
        System.assertEquals(c1.Line_Of_Business__c, et1.LOB__c, 'Incorrect EIT LOB');
        Test.stopTest();
    }

    @isTest
    static void updateOIT()
    {
        List<Account> aList = SL_TestSetupUtils.CreateAccount('Account', 1);
        insert aList;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        cList[0].AccountId = aList[0].Id;
        cList[0].Line_Of_Business__c = 'CF';
        cList[0].Office__c = 'AB';
        cList[0].Industry_Group__c = 'ADG';
        insert cList;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, Office__c, Line_Of_Business__c from Contact]);

        //Create EIT records and assert the values
        Opportunity__c e = SL_TestSetupUtils.CreateOpp('Opportunity__c', 1)[0];
        e.Beneficial_Owner_Control_Person_form__c = 'No';
        insert e;

        Opportunity_Internal_Team__c et1 = SL_TestSetupUtils.CreateOIT('Opportunity_Internal_Team__c',1)[0];
        et1.Contact__c = cList[0].Id;
        et1.Opportunity__c = e.Id;
        et1.Start_Date__c = System.today().addDays(-1);
        et1.End_Date__c = System.today().addDays(1);

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
        et1.Staff_Role__c = staffRole.Id;
        insert et1;

        et1 = [Select Id,Office__c, LOB__c from Opportunity_Internal_Team__c Where Id = : et1.Id];

        //Check if the EIT workflows are working fine
        Contact c1 = contactMap.get(cList[0].Id);
        System.assertEquals(c1.Office__c.substring(0,2), et1.Office__c, 'Incorrect EIT OFfice');
        System.assertEquals(c1.Line_Of_Business__c, et1.LOB__c, 'Incorrect EIT LOB');

        cList[0].Office__c = 'BC';
        update cList;

        Test.startTest();


        //Call the batch job explicilty
        String eitQuery = HL_PercentageSplitHandler.GetCreatableFieldsSOQL('Opportunity_Internal_Team__c');
        eitQuery = eitQuery + ' WHERE Invalid_Office_LOB__c=\'true\'';

        SL_Batch_StampInternalTeam batch = new SL_Batch_StampInternalTeam(eitQuery);
        Database.executeBatch(batch, 200);

        Test.stopTest();

        List<Opportunity_Internal_Team__c> teamRecords = [Select Id,Office__c, LOB__c, Start_Date__c, End_Date__c from Opportunity_Internal_Team__c Where Opportunity__c = : e.Id];

        System.assertEquals(2,teamRecords.size(),'Team Record count not correct');
        Map<String, Opportunity_Internal_Team__c> teamMap = new Map<String, Opportunity_Internal_Team__c>();
        for(Opportunity_Internal_Team__c et: teamRecords)
        {
            teamMap.put(et.Office__c, et);
        }
        System.assertEquals(System.today(),teamMap.get('AB').End_Date__c,'End Date error');

        System.assertEquals(null,teamMap.get('BC').End_Date__c,'End Date erorr');
        System.assertEquals(System.today().addDays(1),teamMap.get('BC').Start_Date__c,'End Date erorr');
    }

    @isTest
    static void udpateEIT()
    {
        List<Account> aList = SL_TestSetupUtils.CreateAccount('Account', 1);
        insert aList;

        List<Contact> cList = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        cList[0].AccountId = aList[0].Id;
        cList[0].Line_Of_Business__c = 'CF';
        cList[0].Office__c = 'AB';
        cList[0].Industry_Group__c = 'ADG';
        insert cList;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, Office__c, Line_Of_Business__c from Contact]);

        //Create EIT records and assert the values
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('Engagement__c', 1)[0];
        insert e;

        Engagement_Internal_Team__c et1 = SL_TestSetupUtils.CreateEIT('Engagement_Internal_Team__c',1)[0];
        et1.Contact__c = cList[0].Id;
        et1.Engagement__c = e.Id;
        et1.Start_Date__c = System.today().addDays(-1);
        et1.End_Date__c = System.today().addDays(1);
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
        et1.Staff_Role__c = staffRole.Id;
        insert et1;


        et1 = [Select Id, Staff_Revenue_Split__c,Office__c, LOB__c from Engagement_Internal_Team__c Where Id = : et1.Id];

        //Check if the EIT workflows are working fine
        Contact c1 = contactMap.get(cList[0].Id);
        //System.assertEquals(c1.Office__c.substring(0,2), et1.Office__c, 'Incorrect EIT OFfice');
        //System.assertEquals(c1.Line_Of_Business__c, et1.LOB__c, 'Incorrect EIT LOB');

        cList[0].Office__c = 'BC';
        update cList;

        Test.startTest();


        //This code covers the scheudle class but not the batch job.

        String CRON_EXP = '20 30 8 10 2 ?';
        String jobId = System.schedule('SL_Scheduler_Stamp_InternalTeamTest',CRON_EXP, new SL_Scheduler_Stamp_InternalTeam());


        //Call the batch job explicilty
        String eitQuery = HL_PercentageSplitHandler.GetCreatableFieldsSOQL('Engagement_Internal_Team__c');
        eitQuery = eitQuery + ' WHERE Invalid_Office_LOB__c=\'true\'';

        SL_Batch_StampInternalTeam batch = new SL_Batch_StampInternalTeam(eitQuery);
        Database.executeBatch(batch, 200);

        Test.stopTest();

        List<Engagement_Internal_Team__c> teamRecords = [Select Id, Staff_Revenue_Split__c,Office__c, LOB__c, Start_Date__c, End_Date__c from Engagement_Internal_Team__c Where Engagement__c = : e.Id];

        System.assertEquals(2,teamRecords.size(),'Team Record count not correct');
        Map<String, Engagement_Internal_Team__c> teamMap = new Map<String, Engagement_Internal_Team__c>();
        for(Engagement_Internal_Team__c et: teamRecords)
        {
            teamMap.put(et.Office__c, et);
        }
        System.assertEquals(System.today(),teamMap.get('AB').End_Date__c,'End Date error');

        System.assertEquals(null,teamMap.get('BC').End_Date__c,'End Date erorr');
        System.assertEquals(System.today().addDays(1),teamMap.get('BC').Start_Date__c,'End Date erorr');
    }
    @isTest
    static void testMail()
    {
        HL_PercentageSplitHandler.SendEmail('test@test.com', 'test subject', 'test body');
    }
}