@isTest
private class Test_HL_FEISController {
    @isTest private static void TestBasicFunctionality() {
        //Setup Test Data
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = o.Id;
        insert oa;
        
        Test.startTest();
        //Setup Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(oa);
        //Test Controller Properties/Methods
        HL_FEISController con = new HL_FEISController(sc);
        List < Opportunity_Client_Subject__c > csList = con.ClientsSubjects;
        List < Opportunity_Client_Subject__c > cpList = con.Counterparties;
        List < Opportunity_Client_Subject__c > shList = con.ShareholderCompanies;
        
        con.RefreshClientsSubjects();
        con.RefreshCounterparties();
        con.SaveRecord();
        con.SaveAndReturn();
        con.SubmitForm();
        Test.stopTest();
        
    }
    
    @isTest private static void Test2() {
        //Setup Test Data
        //Insert Additional Clients/Subjects
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newSubject;
        
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = o.Id;
        oa.Transaction_Type__c = 'Other';
        oa.Legal_Structure__c = 'Other';
        oa.Form_of_Consideration__c = 'Other';
        oa.Opinion_Parties_Affiliated__c = 'Yes';
        oa.FEIS_Opine_Option_6__c = True;
        oa.Fairness_Opinion_Publicly_Disclosed__c = 'Yes';
        oa.Fairness_In_Addition__c = 'Yes';
        oa.Fairness_Additional_Officers__c = 'Yes';
        oa.Conflicts_3a_Related_to_Transaction__c = 'Yes';
        oa.Shareholder_Vote__c = 'Yes';
        oa.Other_Shareholders__c = 'Test';
        oa.Has_Other_Shareholders__c = true;
        oa.Fairness_Disclosure_Document__c = 'Other';
        insert oa;
        
        Opportunity_Client_Subject__c addClient = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Client_Subject__c = newClient.Id, Type__c = 'Contra');
        insert addClient;
        Opportunity_Client_Subject__c addSubject = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = false, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        insert addSubject;
        
        Test.startTest();
        //Setup Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(oa);
        //Test Controller Properties/Methods
        HL_FEISController con = new HL_FEISController(sc);
        List < Opportunity_Client_Subject__c > csList = con.ClientsSubjects;
        List < Opportunity_Client_Subject__c > cpList = con.Counterparties;
        List < Opportunity_Client_Subject__c > shList = con.ShareholderCompanies;
        con.RefreshClientsSubjects();
        con.RefreshCounterparties();
        con.SaveRecord();
        con.SaveAndReturn();
        con.DelId = csList[0].Id;
        Boolean OnOIT = con.OnOIT;
        PageReference objPf = con.TriggerValidation();
        con.SubmitForm();   
        con.CancelSubmission();
        con.DeleteClientSubject();
        con.DelId = cpList[0].Id;
        con.DeleteCounterparty();
        con.FairnessAdditionalOfficers();
        Test.stopTest();
       }
    
    @isTest private static void Test3() {
        //Setup Test Data
        //Insert Additional Clients/Subjects
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newSubject;
        
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('', 1)[0];
        oa.Related_Opportunity__c = o.Id;
        oa.Transaction_Overview__c = 'This transaction overview';
        oa.Transaction_Type__c = 'Other';
        oa.FEIS_Other_Job_Type_Desc__c = 'This is text area';
        oa.Legal_Structure__c = 'Other';
        oa.FEIS_Other_Legal_Structure_Desc__c = 'This is legal structure desc';
        oa.Estimated_Transaction_Size_MM__c = 100;
        oa.Form_of_Consideration__c = 'Cash';
        oa.Opinion_Parties_Affiliated__c = 'No';
        oa.FEIS_Opine_Option_6__c = False; 
        oa.Fairness_Opinion_Publicly_Disclosed__c = 'No';
        oa.Fairness_In_Addition__c = 'No';
        oa.Fairness_Additional_Officers__c = 'No';
        oa.Fairness_Relative_Fairness__c = 'No';
        oa.Fairness_Fairness_or_Terms__c = 'No';
        oa.Fairness_Multiple_Conclusions__c = 'No';
        oa.Fairness_Committee_or_Trustee__c = 'No';
        oa.Fairness_Unusual_Opinion__c = 'No';
        oa.Conflicts_3a_Related_to_Transaction__c = 'No';
        oa.Conflicts_35a_Related_to_Client__c = 'No';
        oa.Conflicts_4a_Conflict_of_Interest__c = 'No';
        oa.Conflicts_5a_Other_Conflicts__c = 'No';
        oa.Shareholder_Vote__c = 'No';
        oa.Has_Other_Shareholders__c = false;
        oa.Opinion_Special_Committee__c = 'No';
        insert oa;
        
        Opportunity_Client_Subject__c addClient = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Client_Subject__c = newClient.Id, Type__c = 'Contra');
        insert addClient;
        Opportunity_Client_Subject__c addSubject = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = false, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        insert addSubject;
        
        Test.startTest();
        //Setup Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(oa);
        //Test Controller Properties/Methods
        HL_FEISController con = new HL_FEISController(sc);
        List < Opportunity_Client_Subject__c > csList = con.ClientsSubjects;
        List < Opportunity_Client_Subject__c > cpList = con.Counterparties;
        List < Opportunity_Client_Subject__c > shList = con.ShareholderCompanies;
      
        con.SubmitForm();  
        
        o.Line_of_Business__c = 'FVA';
        update o;
        
        con.SubmitForm();
       
        Test.stopTest();
       }

}