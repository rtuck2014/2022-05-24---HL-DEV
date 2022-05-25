@isTest
private class Test_HL_AddClientsSubjectsController {
    @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Additional_Client__c = 'No';
        o.Additional_Subject__c = 'No';
        o.Client__c = client.Id;
        o.Subject__c = subject.Id;
		o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        //Insert Additional Clients/Subjects
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newSubject;
        Opportunity_Client_Subject__c addClient = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Client_Subject__c = newClient.Id, Type__c = 'Client');
        insert addClient;
        Opportunity_Client_Subject__c addSubject = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        insert addSubject;
        
        ApexPages.currentPage().getParameters().put('Id',o.Id);
        
        Test.startTest();
            //Test Controller Functionality
            HL_AdditionalClientsSubjectsController con = new HL_AdditionalClientsSubjectsController();
            Opportunity__c opp = con.Opp;
            System.assert(opp.Id == o.Id);
            List<Opportunity_Client_Subject__c> additionalClients = con.AdditionalClients;
            //Should now have two (one from trigger on opp and another we added above)
            System.assert(additionalClients.size() == 2);
            List<Opportunity_Client_Subject__c> additionalSubjects = con.AdditionalSubjects;
            //Should now have two (one from trigger on opp and another we added above)
            System.assert(additionalSubjects.size() == 2);
            con.Opp.Completed_Additional_Client__c = false;
            con.RefreshAdditionalClients();
            con.ClientToRemove = addClient.Id;
            con.RemoveClient();     
            //Should now have one after removal
            System.assert(con.AdditionalClients.size() == 1);
            con.Opp.Completed_Additional_Subject__c = false;
            con.RefreshAdditionalSubjects();
            con.SubjectToRemove = addSubject.Id;
            con.RemoveSubject();
            //Should now have one after removal
            System.assert(con.AdditionalSubjects.size() == 1);
            con.SaveOpp();
        Test.stopTest();
    }
}