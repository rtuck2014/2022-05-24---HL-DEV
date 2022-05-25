@isTest
private class Test_HL_OpportunityClientSubjectHandler {
   @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
        //Test Public or Private Field Trigger Updates
        //Insert a Private Company OCS record
        Opportunity_Client_Subject__c ocs = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id, Client_Subject__c = aList[0].Id);
        insert ocs;

        //Verify the PublicOrPrivate field is now Private
        opp = [SELECT Client__c, Subject__c, Public_Or_Private__c FROM Opportunity__c WHERE Id =: opp.Id];
        System.assert(opp.Public_Or_Private__c == 'Private');
        
        //Insert a Public Company OCS record
        ocs = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id, Client_Subject__c = aList[1].Id);
        insert ocs;
                
        //Verify the PublicOrPrivate field is now Public
        opp = [SELECT Client__c, Subject__c, Public_Or_Private__c FROM Opportunity__c WHERE Id =: opp.Id];
        System.assert(opp.Public_Or_Private__c == 'Public');  
    }
    
    @isTest private static void TestBasicFunctionalityToUpdate(){
        //Setup Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
        //Test Public or Private Field Trigger Updates
        //Insert a Private Company OCS record
        Opportunity_Client_Subject__c ocs1 = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id,type__c = 'Client', Client_Subject__c = aList[0].Id);
        Opportunity_Client_Subject__c ocs2 = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id);
        List<Opportunity_Client_Subject__c > OCSList = new List<Opportunity_Client_Subject__c >();
        OCSList.add(ocs1);
        OCSList.add(ocs2);        
        insert OCSList ;

        ocs1.type__c = 'Subject'; 
        update ocs1;
        
    }
    
     @isTest private static void TestBasicFunctionalityToDelete(){
        //Setup Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
        //Test Public or Private Field Trigger Updates
        //Insert a Private Company OCS record
        Opportunity_Client_Subject__c ocs1 = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id,type__c = 'Client', Client_Subject__c = aList[0].Id);
        Opportunity_Client_Subject__c ocs2 = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id);
        List<Opportunity_Client_Subject__c > OCSList = new List<Opportunity_Client_Subject__c >();
        OCSList.add(ocs1);
        OCSList.add(ocs2);        
        insert OCSList ;

       // ocs1.type__c = 'Subject'; 
      //  update ocs1;
        Delete ocs1;
        
        
    }
    
}