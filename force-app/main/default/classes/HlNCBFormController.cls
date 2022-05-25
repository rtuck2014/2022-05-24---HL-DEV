public class HlNCBFormController {
    @AuraEnabled(cacheable=true)
    public static String checkOpportunityReview(String oppId,String action,String parentcurrency){
        String oppreviewId;
        try{
            List<Opportunity_Approval__c> oppLst =  [SELECT Id, Form_Type__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =: oppId];
            if(oppLst.size()>0){
                oppreviewId = oppLst[0].Id;
            }
            else{
                Opportunity_Approval__c destRecord = new Opportunity_Approval__c(Related_Opportunity__c = oppId,Form_Type__c = action.toUpperCase(), CurrencyIsoCode = parentcurrency);
                insert destRecord;
                oppreviewId = destRecord.id;
            }
            return oppreviewId;
        }catch(Exception e){
            system.debug('Exception in checkOpportunityReview'+e.getMessage());
            return null;
            
        }
        
    }
     @AuraEnabled
    public static Opportunity_Approval__c getOpportunityReview(String oppReviewId){
        return [Select id,Related_Opportunity__c,Related_Opportunity__r.Name,Locked__c,PDF_View__c,Opportunity_Number__c,Client_Company__c,
        Subject_Company__c,Client_Ownership__c,Company_Ownership_Type__c,Client_Country__c,Subject_Country__c,Secondary_Job_Type__c,Is_Majority_Sale__c,Head_Approval__c,Is_Client_EU__c 
         FROM Opportunity_Approval__c where id=: oppReviewId];
    }
}