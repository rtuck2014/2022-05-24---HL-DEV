@IsTest
private class Test_HL_Staff_Role {
    
    @testSetup static void InsertRoles() {
        List<Staff_Role__c> roles = new List<Staff_Role__c>();
        roles.add(new Staff_Role__c(Name = 'Analyst', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
    roles.add(new Staff_Role__c(Name = 'Associate', Opportunity__c = True, CF__c = False, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Fairness', Opportunity__c = True, CF__c = False, FS__c = False, Registered_Only__c = False, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Final Reviewer', Opportunity__c = True, CF__c = True, FS__c = True, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Ind/Prod/Geog Person', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Initiator', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Intern', Opportunity__c = True, CF__c = True, FS__c = True, Registered_Only__c = False, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = True));
        roles.add(new Staff_Role__c(Name = 'Manager', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Analyst', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Marketing Team', Opportunity__c = True, CF__c = True, FS__c = True, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Non-Registered', Opportunity__c = True, CF__c = True, FS__c = True, Registered_Only__c = False, Non_Registered_Only__c = True, Fin_Only__c = True, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'PE/Hedge Fund', Opportunity__c = True, CF__c = True, FS__c = True, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
    roles.add(new Staff_Role__c(Name = 'Prelim Reviewer', Opportunity__c = True, CF__c = False, FS__c = True, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Pricing Committee Approver', Opportunity__c = False, CF__c = True, FS__c = True, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Principal', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Public Person', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Reviewer', Opportunity__c = True, CF__c = False, FS__c = True, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));
        roles.add(new Staff_Role__c(Name = 'Seller', Opportunity__c = True, CF__c = True, FS__c = False, Registered_Only__c = True, Non_Registered_Only__c = False, Fin_Only__c = False, Non_Fin_Only__c = False));

        insert roles;
        
        Job_Type__c job1 = new Job_Type__c(Name = 'Tech+IP - Patent Sales', Job_Code__c = '6000');
        Job_Type__c job2 = new Job_Type__c(Name = 'Private Funds: Primary Advisory', Job_Code__c = '6001');
        
        insert job1;
        insert job2;
  }
    
    @isTest private static void TestGetByName(){
        Test.startTest();

        //Result Found
        List<Staff_Role__c> resultList = HL_Staff_Role.GetByName('Associate');

        //No Result Found
        List<Staff_Role__c> noResultList = HL_Staff_Role.GetByName('NoRole');

        Test.stopTest();

        System.assert(resultList.size() == 1);
        System.assert(noResultList.size() == 0);
    }

     @isTest private static void TestRoleSort(){
       Test.startTest();

       List<Staff_Role__c> cfOppRoleList = HL_Staff_Role.GetRoles(HL_Staff_Role.RoleType.Opportunity, HL_Staff_Role.RoleLOB.CF);
       Set<String> rolesToSortSet = new Set<String>();
       for(Staff_Role__c sr : cfOppRoleList)
            rolesToSortSet.Add(sr.Name);
       List<String> sortedRoleList = HL_Staff_Role.GetSortedRoles(rolesToSortSet);

       Test.stopTest();

       //Verify the sorted roles list still contains roles
      System.assert(sortedRoleList.size() > 0);
    }
    
    @isTest private static void TestFilterSelectableRolesFS(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'CM - Capital Markets';
        c.Department = 'FS';
        c.Registered__c = true;
        insert c;
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                     FROM Staff_Role__c WHERE Name = 'Associate'];

        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', 'jobCode', false, false, roles);

        Test.stopTest();

        System.assert(roleResultList.size() == 0);
    }
    
    @isTest private static void TestFilterSelectableRolesAdmin(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'CM - Capital Markets';
        c.Department = 'FS';
        c.Registered__c = true;
        c.Staff_type__c = 'Admin';
        insert c;
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                     FROM Staff_Role__c WHERE Name = 'Associate'];

        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', 'jobCode', false, false, roles);

        Test.stopTest();

        System.assert(roleResultList.size() == 0);
    }
    
    
     @isTest private static void TestFilterSelectableRolesRegisteredStaffNonRegisteredOnlyRole(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
         c.Registered__c = true;
         c.Industry_Group__c = 'CM - Capital Markets';
        insert c;
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                     FROM Staff_Role__c WHERE Name = 'Associate'];

        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', 'jobCode', false, false, roles);

        Test.stopTest();

        System.assertEquals(roleResultList.size(), 1);
    }
    
    @isTest private static void TestFilterSelectableRolesFinStaffNonFinOnlyRole(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'CM - Capital Markets';
        c.Registered__c = true;
        c.Staff_Type__c = 'FIN';
        insert c;
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                     FROM Staff_Role__c WHERE Name = 'Associate'];

        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', 'jobCode', false, false, roles);

        Test.stopTest();

        System.assertEquals(roleResultList.size(), 1);
    }
    
    @isTest private static void TestFilterSelectableRolesNonFinStaffFinOnlyRole(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'CM - Capital Markets';
        c.Registered__c = true;
        c.Staff_Type__c = '';
        insert c;
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                     FROM Staff_Role__c WHERE Name = 'Associate'];

        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', 'jobCode', false, false, roles);

        Test.stopTest();

        System.assert(roleResultList.size() == 1);
    }

    @isTest private static void TestFilterSelectableRolesNonRegistered(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'CM - Capital Markets';
        c.Office__c = 'LA';
        c.Registered__c = false;
        
        insert c;
        c = [SELECT Department, Is_Foreign_Office__c, Registered__c, Industry_Group__c, Staff_Type__c FROM Contact WHERE Id =: c.Id];
        
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c,  Registered_Excluded_Job_Codes__c
                                     FROM Staff_Role__c WHERE Name = 'Associate'];

        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', '', false, false, roles);

        Test.stopTest();

        System.assert(roleResultList.size() == 0);
    }
    
    @isTest private static void TestFilterSelectableRolesNonRegisteredForeign(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'CM - Capital Markets';
        c.Office__c = 'HK';
        c.Staff_Type__c = '';
        c.Registered__c = false;
        
        insert c;
        c = [SELECT Department, Is_Foreign_Office__c, Registered__c, Industry_Group__c, Staff_Type__c FROM Contact WHERE Id =: c.Id];
        
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                     FROM Staff_Role__c WHERE Name = 'Associate'];
        
        Test.startTest();

        List<Staff_Role__c> roleResultList = HL_Staff_Role.FilterSelectableRoles(c, 'CF', 'jobCode', false, false, roles);

        Test.stopTest();

        System.assert(roleResultList.size() == 0);
    }
    
    //Test that the new Bear Tooth Rules work
    //A contact in Private Funds Group Industry can be staffed on any role on an Engagement/Opp that is of job type Private Funds: Primary Advisory
    //A contact that is non-registered can still be staffed as non-registered
    @isTest private static void TestFilterSelectableRolesPrivateFundsAdvisory(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'PFG - Private Funds Group';
        c.Office__c = 'HK';
        c.Staff_Type__c = 'FIN';
        c.Registered__c = true;
        
        
        insert c;
        c = [SELECT Department, Is_Foreign_Office__c, Registered__c, Industry_Group__c, Staff_Type__c FROM Contact WHERE Id =: c.Id];
        
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c
                                     FROM Staff_Role__c];

        Test.startTest();  
        String pfaJobCode = HL_JobType.GetJobCode('Private Funds: Primary Advisory');
        List<Staff_Role__c> roleResultCFListPFA = HL_Staff_Role.FilterSelectableRoles(c, 'CF', pfaJobCode, false, false, roles);
        c.Registered__c = false;
        List<Staff_Role__c> roleResultNonRegisteredCFListPFA = HL_Staff_Role.FilterSelectableRoles(c, 'CF', pfaJobCode, false, false, roles);      
        Test.stopTest();
        
        System.assertEquals(roleResultCFListPFA.size(), 17, 'All roles except Non-Registered');
        System.assertEquals(roleResultNonRegisteredCFListPFA.size(), 18, 'All roles and Non-Registered for foreign HK PFG');
    }
    
    //Test that the new Bear Tooth Rules work
    //A contact in Private Funds Group Industry can be staffed on Initiator and Seller for CF/FR Engagement/Opp that is NOT of job type Private Funds: Primary Advisory
    //A contact that is non-registered can still be staffed as non-registered
    @isTest private static void TestFilterSelectableRolesNonPrivateFundsAdvisory(){
        //Setup Test Data
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        c.Industry_Group__c = 'PFG - Private Funds Group';
        c.Office__c = 'HK';
        c.Staff_Type__c = 'FIN';
        c.Registered__c = true;
        
        insert c;
        c = [SELECT Department, Is_Foreign_Office__c, Registered__c, Industry_Group__c, Staff_Type__c FROM Contact WHERE Id =: c.Id];
        
        List<Staff_Role__c> roles = [SELECT Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c
                                     FROM Staff_Role__c];

        
        Test.startTest();  

        String ifaJobCode = HL_JobType.GetJobCode('Tech+IP - Patent Sales');
        List<Staff_Role__c> roleResultCFListIFA = HL_Staff_Role.FilterSelectableRoles(c, 'CF', ifaJobCode, false, false, roles);
        List<Staff_Role__c> roleResultFRListIFA = HL_Staff_Role.FilterSelectableRoles(c, 'FR', ifaJobCode, false, false, roles);
        c.Registered__c = false;
        List<Staff_Role__c> roleResultNonRegisteredCFListIFA = HL_Staff_Role.FilterSelectableRoles(c, 'CF', ifaJobCode, false, false, roles);
        List<Staff_Role__c> roleResultNonRegisteredFRListIFA = HL_Staff_Role.FilterSelectableRoles(c, 'FR', ifaJobCode, false, false, roles);      
        Test.stopTest();
        
        System.assertEquals(4, roleResultCFListIFA.size(), 'Seller, Marketing, Specialty, and Initiator Only');
        System.assertEquals(4, roleResultFRListIFA.size(), 'Seller, Marketing, Specialty, and Initiator Only');    
        System.assertEquals(1, roleResultNonRegisteredCFListIFA.size(), 'Only Non-Registered');
        System.assertEquals(1, roleResultNonRegisteredFRListIFA.size(), 'Only Non-Registered');
    }
}