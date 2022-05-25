@isTest
private class Test_HL_InternalTeamController {
    
    Static List<Contact> cList ;
    Static List<Staff_Role__c> roleList;
    Static List<Engagement__c> engagementList;
    Static List<Opportunity_Internal_Team__c> oitList;
    Static List<Engagement_Internal_Team__c> eitList;
    Static Opportunity__c opp;
    
    
    static void PreparecommonData()
    {  
        cList = SL_TestSetupUtils.CreateContact('', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        for (Integer index = 0; index < cList.size(); index++)
            cList[index].User__c = UserInfo.getUserId();
        insert cList;
        
        roleList = new List<Staff_Role__c> {
                                             new Staff_Role__c(Name = 'Initiator', Display_Order__c = 1, Opportunity__c = True, CF__c = True), 
                                             new Staff_Role__c(Name = 'Analyst', Display_Order__c = 2, Opportunity__c = True, CF__c = True), 
                                             new Staff_Role__c(Name = 'Associate', Display_Order__c = 3, Opportunity__c = True, CF__c = True)
                };
        insert roleList;
    }
    static void createOppData(){ 
        PreparecommonData();
        opp = SL_TestSetupUtils.CreateOpp('', 1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = opp.id;
        insert oa;  
        
        oitList = new List<Opportunity_Internal_Team__c> {
                new Opportunity_Internal_Team__c(Opportunity__c = opp.Id, Contact__c = cList[0].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[0].Id, Office__c = 'LA'),
                new Opportunity_Internal_Team__c(Opportunity__c = opp.Id, Contact__c = cList[1].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[0].Id, Office__c = 'CH')
                };
        insert oitList;
    }
    
    static void createEnggData(){ 
        PreparecommonData();
        engagementList = SL_TestSetupUtils.CreateEngagement('', 2);
        insert engagementList;
      
        eitList = new List<Engagement_Internal_Team__c> {
                new Engagement_Internal_Team__c(Engagement__c = engagementList[1].Id, Contact__c = cList[1].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[0].Id),
                new Engagement_Internal_Team__c(Engagement__c = engagementList[0].Id, Contact__c = cList[1].Id, Start_Date__c = Date.today(), Staff_Role__c = roleList[1].Id)
                };
        insert eitList;
    }
    
    @isTest 
    private static void TestBasicFunctionality1() {
        createOppData();
        Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', opp.Id);
            HL_InternalTeamController itc = new HL_InternalTeamController();       
            List<HL_InternalTeamRecord> team = itc.TeamRecords;
            String customFilter = itc.CustomFilter;
            itc.BackToEntity();
            itc.EditClicked();
            itc.RefreshNewStaffRoles();
            Boolean ShowReturn = itc.ShowReturn;
            itc.SelectedStaffId = cList[0].id;
            itc.StaffMemberToAdd.RoleAssignments[0].Assigned = True;
            itc.SaveTeamEdits();   
        Test.stopTest();        
        System.assertEquals(itc.TeamRecords.size(), 2);        
    }
    
    @isTest 
    private static void TestBasicFunctionality2() {
        createEnggData();        
        Test.startTest();       
            ApexPages.currentPage().getParameters().put('Id', engagementList[0].Id);
            HL_InternalTeamController engITC = new HL_InternalTeamController();
            List<HL_InternalTeamRecord> engTeam = engITC.TeamRecords;
            engITC.BackToEntity();
            engITC.EditClicked();
            engITC.SelectedStaffId = cList[1].id;
            engITC.StaffMemberToAdd.RoleAssignments[0].Assigned = True;
            engITC.SaveTeamEdits();
            Contact cr = engITC.TeamRecords[0].ContactRecord;
            engITC.TeamRecords[0].RoleAssignments[0].Assigned = False;
            engITC.SaveTeamEdits();   
        Test.stopTest(); 
        System.assertEquals(engITC.TeamRecords.size(), 1);  
    }
 }