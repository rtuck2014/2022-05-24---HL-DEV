public with sharing class HL_EngagementFinancial {
    public static List<Engagement_Financials__c> GetByEngagementIdAndType(id engagementId, string type){

        return [SELECT Revenue_FY_minus1_MM__c, Revenue_FY_MM__c, Revenue_LTM_MM__c, Revenue_FY_1_MM__c, Revenue_FY_2_MM__c, Revenue_FY_3_MM__c, Revenue_FY_4_MM__c, Revenue_FY_5_MM__c, EBITDA_FY_minus1_MM__c, EBITDA_FY_MM__c, EBITDA_LTM_MM__c, EBITDA_FY_1_MM__c, EBITDA_FY_2_MM__c, EBITDA_FY_3_MM__c, EBITDA_FY_4_MM__c, EBITDA_FY_5_MM__c, Capex_FY_minus1_MM__c, Capex_FY_MM__c, Capex_LTM_MM__c, Capex_FY_1_MM__c, Capex_FY_2_MM__c, Capex_FY_3_MM__c, Capex_FY_4_MM__c, Capex_FY_5_MM__c FROM Engagement_Financials__c WHERE Related_Engagement__c =: engagementId AND Type__c =: type ORDER BY As_Of_Date__c DESC LIMIT 1];
    }
}