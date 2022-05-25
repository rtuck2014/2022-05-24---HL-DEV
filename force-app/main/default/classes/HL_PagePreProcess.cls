//This class is used to create/evaluate a record prior to redirecting to the destination page.
public with sharing class HL_PagePreProcess {
    public static PageReference PreProcess()
    {
        PageReference dest;
        List<SObject> existingRecords;
        SObject destRecord;
        string action = HL_PageUtility.GetParameter('action');
        string parentcurrency = HL_PageUtility.GetParameter('parentcurrency');
        if(action == 'feis'||action =='nbc' || action == 'cnbc'){ 
            string oppId = HL_PageUtility.GetParameter('opp');
            existingRecords = [SELECT Id FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:oppId LIMIT 1];
            if(existingRecords.size() == 0){
                destRecord = new Opportunity_Approval__c(Related_Opportunity__c = oppID,Form_Type__c = action.toUpperCase(), CurrencyIsoCode = parentcurrency);
                insert destRecord;
            }
            else
                destRecord = existingRecords[0];

            dest = new PageReference('/apex/HL_' + action.toUpperCase() + '?id=' + destRecord.Id);
        }
        else
        {
            if(action == 'summary_cf'){
                string engId = HL_PageUtility.GetParameter('eng');
                existingRecords = [SELECT Id FROM Engagement_Summary__c WHERE Engagement__c =:engId LIMIT 1];
                if(existingRecords.size() == 0){
                    destRecord = new Engagement_Summary__c(Engagement__c = engId);
                    insert destRecord;
                }
                else
                    destRecord = existingRecords[0];
                
                dest = New PageReference('/apex/HL_CF_EngagementSummary?id=' + destRecord.Id);
            }
            else
                dest = new PageReference('/');
        }
        
        return dest;
    }
}