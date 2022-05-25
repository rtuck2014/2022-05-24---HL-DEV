@isTest
private class Test_HL_CoverageTeamHandler {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert a;
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert c;
        List<Coverage_Team__c> ctList = new List<Coverage_Team__c>();
        ctList.add(new Coverage_Team__c(Company__c = a.Id, Officer__c = c.Id));
        insert ctList;
        Account acc = [SELECT Coverage_Team_Aggregate__c FROM Account WHERE Id =: a.Id];
        System.debug('Account Query>>>> ' + acc);
        //Verify that the Coverage Team Aggregate Field was Updated
        System.assertNotEquals('0', acc.Coverage_Team_Aggregate__c);
       // System.assert(acc.Coverage_Team_Aggregate__c != null);
        delete ctList;
        //Verify that the Coverage Team Aggregate Field was Updated/Removed
        a = [SELECT Coverage_Team_Aggregate__c FROM Account WHERE Id =: a.Id];
        System.assert(a.Coverage_Team_Aggregate__c == null);
    }

    @isTest
    private static void TestCoverageHandlerFuture(){
        Id recTypeIdHLEmployee = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();

        Id recTypeIdCovTeamFS = Schema.SObjectType.Coverage_Team__c.getRecordTypeInfosByName().get('FS Coverage Team Member').getRecordTypeId();

        Account a = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert a;

        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert c;

        Contact cFS = new Contact(FirstName = 'Test A', 
                                  LastName = 'Test BBBX',
                                  RecordTypeId = recTypeIdHLEmployee,
                                  AccountId = a.Id,
                                  Industry_Group__c = 'FS - Financial Sponsors');
                        

        insert cFS;

        List<Coverage_Team__c> ctList = new List<Coverage_Team__c>();
        ctList.add(new Coverage_Team__c(Company__c = a.Id, Officer__c = c.Id));
        insert ctList;

        //FS_Coverage_Team_Member
        List<Coverage_Team__c> ctListFS = new List<Coverage_Team__c>();
        ctListFS.add(new Coverage_Team__c(Company__c = a.Id, Officer__c = cFS.Id, RecordTypeId = recTypeIdCovTeamFS));
        insert ctListFS;

        Account acc = [SELECT Coverage_Team_Aggregate__c FROM Account WHERE Id =: a.Id];

        Set<Id> cList = new Set<Id>();
        Set<Id> cListFS = new Set<Id>();

        for(Coverage_Team__c ct : ctList){
            cList.add(ct.Id);
        }

        for(Coverage_Team__c ct : ctListFS){
            cListFS.add(ct.Id);
        }
        HL_CoverageTeamHandler.UpdateCoverageTeamAggregate(cList);
        HL_CoverageTeamHandler.UpdateCoverageTeamAggregate(cListFS);

    }
}