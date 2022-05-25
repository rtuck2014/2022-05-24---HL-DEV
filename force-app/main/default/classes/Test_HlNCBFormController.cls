@istest
public class Test_HlNCBFormController {

    testmethod static void checkOpportunityReview(){
        
        
        List<Opportunity__c> opps = SL_TestSetupUtils.CreateOpp('', 1);
        
        for(Opportunity__c o : opps)
        {
          o.Beneficial_Owner_Control_Person_form__c = 'No';
          o.CurrencyIsoCode = 'USD';
        }
        insert opps;
        HlNCBFormController.checkOpportunityReview(opps[0].Id,'NBC','USD');
    }
    
    testmethod static void checkOpportunityReviewErro(){
        
        HlNCBFormController.checkOpportunityReview('','NBC','USD');
    }
    
    testmethod static void getOpportunityReview(){
        
        
        List<Opportunity__c> opps = SL_TestSetupUtils.CreateOpp('', 1);
        
        for(Opportunity__c o : opps)
        {
          o.Beneficial_Owner_Control_Person_form__c = 'No';
          o.CurrencyIsoCode = 'USD';
        }
        insert opps;
        
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c(Related_Opportunity__c = opps[0].Id,Form_Type__c = 'NBC', CurrencyIsoCode = 'USD');
        insert destRecord;
        HlNCBFormController.getOpportunityReview(destRecord.Id);
    }
}