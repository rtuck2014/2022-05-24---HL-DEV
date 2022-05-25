public with sharing class HL_DebtStructure {
    public static List<Debt_Structure__c> GetByPrePostTransaction(id engagementId, string tran){
        return [SELECT Amoritization__c, Call_Provisions_Prepayment_Premiums__c, Constituent_Debt__c, Covenants__c, Facility_Balance_MM__c, Fees_Expenses__c, Interest__c, Mandatory_Prepayments_ECF_Sweep__c, Maturity_Date__c, OID_Percent__c, Security_Type__c FROM Debt_Structure__c WHERE Pre_Post_Transaction__c =: tran AND Engagement__c =: engagementId ORDER BY Security_Type__c];
    }
}