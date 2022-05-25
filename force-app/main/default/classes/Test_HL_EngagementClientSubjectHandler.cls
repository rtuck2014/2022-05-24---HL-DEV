@IsTest
private class Test_HL_EngagementClientSubjectHandler {
     @isTest private static void TestBasicFunctionality(){
        //Setup Test Data
        Engagement__c eng = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert eng;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
        Test.startTest();
            HL_EngagementClientSubjectHandler handler = new HL_EngagementClientSubjectHandler(false,1);
            System.assertEquals(handler.IsTriggerContext,false);
            //Test Public or Private Field Trigger Updates
            //Insert a Private Company ECS record
            Engagement_Client_Subject__c ecs = new Engagement_Client_Subject__c(Engagement__c = eng.Id, Client_Subject__c = aList[0].Id, Loan_Amount__c = 0);
                        
            insert ecs;
            //Verify the PublicOrPrivate field is now Private
            eng = [SELECT Client__c, Subject__c, Public_Or_Private__c FROM Engagement__c WHERE Id =: eng.Id];
            System.assert(eng.Public_Or_Private__c == 'Private');
            
            //Update the ECS record and verify the engagement is still Private
            ecs.Loan_Amount__c = 1.0;
            update ecs;
            eng = [SELECT Client__c, Subject__c, Public_Or_Private__c FROM Engagement__c WHERE Id =: eng.Id];
            System.assert(eng.Public_Or_Private__c == 'Private');

            //Delete the ecs
            delete ecs; 
        Test.stopTest();
    }
    @isTest private static void TestBasicFunctionalityToUpdate(){
        //Setup Test Data
        Engagement__c eng = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert eng;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
             //Test Public or Private Field Trigger Updates
            //Insert a Private Company ECS record
            Engagement_Client_Subject__c ecs1 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Client', Client_Subject__c = aList[0].Id, Loan_Amount__c = 0);
            Engagement_Client_Subject__c ecs2 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id, Loan_Amount__c = 0);
            List<Engagement_Client_Subject__c > OCSList = new List<Engagement_Client_Subject__c>();
            OCSList.add(ecs1);
            OCSList.add(ecs2); 
            insert OCSList;
            //Verify the PublicOrPrivate field is now Private
             ecs1.type__c = 'Subject';
             update ecs1;
     }   
     
      @isTest private static void TestBasicFunctionalityToDelete(){
        //Setup Test Data
        Engagement__c eng = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert eng;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
             //Test Public or Private Field Trigger Updates
            //Insert a Private Company ECS record
            Engagement_Client_Subject__c ecs1 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Client', Client_Subject__c = aList[0].Id, Loan_Amount__c = 0);
            Engagement_Client_Subject__c ecs2 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id, Loan_Amount__c = 0);
            List<Engagement_Client_Subject__c > OCSList = new List<Engagement_Client_Subject__c>();
            OCSList.add(ecs1);
            OCSList.add(ecs2); 
            insert OCSList;
            //Verify the PublicOrPrivate field is now Private
             //ecs1.type__c = 'Subject';
             //update ecs1;
            Delete ocslist;
     }   
    
    
    @isTest private static void TestBasicFunctionalityToDelete2(){
        //Setup Test Data
        Engagement__c eng = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert eng;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
             //Test Public or Private Field Trigger Updates
            //Insert a Private Company ECS record
            Engagement_Client_Subject__c ecs1 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Client', Client_Subject__c = aList[0].Id, Loan_Amount__c = 0);
            Engagement_Client_Subject__c ecs2 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id, Loan_Amount__c = 0);
            List<Engagement_Client_Subject__c > OCSList = new List<Engagement_Client_Subject__c>();
            OCSList.add(ecs1);
            OCSList.add(ecs2); 
            insert OCSList;
            //Verify the PublicOrPrivate field is now Private
             //ecs1.type__c = 'Subject';
             //update ecs1;
            Delete ecs1;
     }   
    
}