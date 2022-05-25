@isTest
public class HLClientSubOppButtonControllerTest {
    @isTest
    public static void testMethodFoOppClientSub (){
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newClient;
        Account newSubject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert newSubject;
        
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('', 1)[0];
        o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Client_Subject__c addClient = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Client_Subject__c = newClient.Id, Type__c = 'Contra');
        insert addClient;
        Opportunity_Client_Subject__c addSubject = new Opportunity_Client_Subject__c(Opportunity__c = o.Id, Primary__c = false, Client_Subject__c = newSubject.Id, Type__c = 'Subject');
        insert addSubject;
        Test.startTest();
        
        
        PageReference pageRef = Page.HLClientSubOppButton; // Add your VF page Name here
        pageRef.getParameters().put('opportunityId', String.valueOf(o.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        HLClientSubOppButtonController testAccPlan = new HLClientSubOppButtonController(sc);
        testAccPlan.redirect();
        HLClientSubEngButtonController.findCustomFieldsid('Account');
        Test.stopTest();
    }
}