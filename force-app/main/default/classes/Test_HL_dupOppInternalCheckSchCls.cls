@isTest
private class Test_HL_dupOppInternalCheckSchCls {
	private static User testUser1;
    private static User testUser2;  
    @isTest private static void TestTeamMemberChanges(){
        
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
            oitList[i].Staff_Role__c = staffRoles[0].Id;
        }
        
        
            insert oitList;
            Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(oitList[0].Id, yesterday);
        Test.setCreatedDate(oitList[1].Id, yesterday);
        Test.startTest();
        HL_dupOppInternalCheckSchCls obj = new HL_dupOppInternalCheckSchCls();
        String Exp = '0 0 23 * * ?';
        system.Schedule('mybatchtest', Exp, obj);
        Test.stopTest();
    }
}