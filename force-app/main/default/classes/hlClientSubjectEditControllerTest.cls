@IsTest
public class hlClientSubjectEditControllerTest {
    @isTest
    public static void testMethodFoOppClientSub(){
        
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newSubject;
        
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Client_Subject__c addClient = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = true, Client_Subject__c = newClient.Id, Type__c = 'Client');
        insert addClient;
        Opportunity_Client_Subject__c addSubject = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = true, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        insert addSubject;
        list<Id> lstIds = new list<Id>();
        lstIds.add(addSubject.Id);
        Test.startTest();
            /*hlClientSubjectEditController.getFieldSetForCreate(o.Id,'Client');
            hlClientSubjectEditController.getFieldSetForCreate(o.Id,'Contra');
            hlClientSubjectEditController.getFieldSetForCreate(o.Id,'Key Creditor');
            hlClientSubjectEditController.getFieldSetForCreate(o.Id,'PE Firm');
            hlClientSubjectEditController.getFieldSetForCreate(o.Id,'Subject');
            hlClientSubjectEditController.getFieldSetForCreate(o.Id,'Other');*/
            hlClientSubjectEditController.getFieldSet(addClient.Id);
            hlClientSubjectEditController.getFieldSetForTotalTable(addClient.Id);
            hlClientSubjectEditController.getFieldSetForTotalTable(addSubject.Id);
            hlClientSubjectEditController.getEngClientSub(addClient.Id);
            hlClientSubjectEditController.deleteRecord(lstIds,'Opportunity_Client_Subject__c');
        Test.stopTest();
    }
    @isTest
    public static void testMethodForEngClientSub(){
        Engagement__c eng = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert eng;
        System.debug('engCreated Id:'+eng.Id);
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
        list<Id> lstIds = new list<Id>();
        lstIds.add(OCSList[0].Id);
        
        
        PageReference pageRef = Page.HL_ClientSubjectEdit; // Add your VF page Name here
        pageRef.getParameters().put('eid', String.valueOf(eng.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(OCSList[0]);
        hlClientSubjectEditController testAccPlan = new hlClientSubjectEditController(sc);
        Test.startTest();
            /*hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Client');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Competitor');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Counterparty');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Equity Holder');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Key Creditor');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'PE Firm');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Subject');
            hlClientSubjectEditController.getFieldSetForCreate(OCSList[0].Id,'Other');*/
            hlClientSubjectEditController.getFieldSet(OCSList[0].Id);
            hlClientSubjectEditController.getFieldSetForTotalTable(OCSList[0].Id);
            hlClientSubjectEditController.getFieldSetForTotalTable(OCSList[0].Id);
            hlClientSubjectEditController.getEngClientSub(OCSList[0].Id);
            hlClientSubjectEditController.deleteRecord(lstIds,'Engagement_Client_Subject__c');
        
        testAccPlan.redirectToNew();
        Test.stopTest();
    }
    
}