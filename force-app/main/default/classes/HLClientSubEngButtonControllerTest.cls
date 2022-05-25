@isTest
public class HLClientSubEngButtonControllerTest {
   @isTest
    public static void testMethodFoOppClientSub (){
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
        Test.startTest();
        
        
        PageReference pageRef = Page.HLClientSubEngButton; // Add your VF page Name here
        pageRef.getParameters().put('engagementId', String.valueOf(eng.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(OCSList[0]);
        HLClientSubEngButtonController testAccPlan = new HLClientSubEngButtonController(sc);
        testAccPlan.redirect();
        HLClientSubEngButtonController.findCustomFieldsid('Account');
        Test.stopTest();
    }
}