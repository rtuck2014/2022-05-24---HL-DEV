public with sharing class HL_LegalEntity {
    private static Map<Id, Legal_Entity__c> legalEntityMap;

    static {
        legalEntityMap = new Map<Id, Legal_Entity__c>([
            SELECT Id, Name, ERP_Business_Unit__c, ERP_Business_Unit_Id__c, ERP_Entity_Code__c, 
            ERP_Legislation_Code__c, ERP_VAT_Legal_Entity__c, ERP_Legal_Entity_Id__c , 
            ERP_Opportunity_Type_Template_number__c, ERP_Event_Type_Template_Number__c, ERP_Ledger_Name__c
            FROM Legal_Entity__c
        ]);
    }

    public static List<Legal_Entity__c> getLegalEntitiesByIdSet(Set<Id> ids) {
        List<Legal_Entity__c> results = new List<Legal_Entity__c>();

        for (Id theId : ids) {
            Legal_Entity__c legalEntity = legalEntityMap.get(theId);

            if (legalEntity != null) {
                results.add(legalEntity);
            }
        }

        return results;
    }
}