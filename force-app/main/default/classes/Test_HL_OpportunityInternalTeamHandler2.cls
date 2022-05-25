/*Test class for HL_OpportunityInternalTeamHandler: In order to avoid SOQL 101 error*/
@isTest
private class Test_HL_OpportunityInternalTeamHandler2 { 
    @isTest private static void TestTeamMemberChanges(){
        
        List<Account> accountList = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert accountList;
        Contact c = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.AccountId = accountList[0].Id;        
        insert c;    
        Test.startTest();
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
		Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        List<Opportunity_Internal_Team__c> oitList = SL_TestSetupUtils.CreateOIT('', oppTeamRoles.size());
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++){
            oitList[i].Contact__c = c.Id;
            oitList[i].Opportunity__c = opp.Id;
            oitList[i].Staff_Role__c = staffRoles[i].Id;
        }        
        
        insert oitList;
        oitList[0].End_Date__c = system.today();
        update oitList[0];
        delete oitList[0]; 
        Test.stopTest();
        Opportunity_Internal_Team__c newOIT = new Opportunity_Internal_Team__c(Contact__c = c.Id,Opportunity__c = opp.Id,Staff_Role__c = staffRoles[0].Id);
        insert newOIT;        
        
        System.assert(([SELECT Id FROM Opportunity_Internal_Team__c]).size() > 0);
    }
}