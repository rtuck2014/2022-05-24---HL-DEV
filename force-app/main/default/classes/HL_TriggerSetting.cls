public with sharing class HL_TriggerSetting {
    public enum TriggerType{Account, Audit_Account, Audit_Bid, Audit_Campaign_Member, Audit_Contact, Audit_Coverage_Team, 
                            Audit_Engagement, Audit_Engagement_Counterparty, Audit_Engagement_External_Team, Audit_Engagement_Internal_Team,
                            Audit_Event, Audit_FS_Engagement, Audit_FS_Opp, Audit_Opportunity, Audit_Opportunity_Counterparty,
                            Audit_Opportunity_External_Team, Audit_Opportunity_Internal_Team, Audit_Relationship, Audit_Revenue_Accrual,
                            Engagement, Engagement_Comment, EngagementClientSubject, Engagement_External_Team, Event, Gift, Monthly_Revenue_Process_Control,
                            Opportunity_Comment, Opportunity_Counterparty, Opportunity_External_Team, Revenue_Accrual, Riva_Activity,
                            Riva_Activity_Link, Time_Record_Period,Engagement_Allocation,Engagement_VatTreatment, Opportunity_Legal_Entity_Change,
                            Engagement_Legal_Entity_Change, Valuation_Period_Position, Opportunity, OpportunityClientSubject, Event_Expense, Opportunity_VatTreatment, 
                            Contract, Opportunity_Set_DFF_Flags, Engagement_Set_DFF_Flags, Contract_Billing_Information, 
                            Contract_Update_Account_Client_Numbers, Account_Primary_Billing_Contact, Opportunity_Clone_Contracts,
                            Opportunity_Assign_Number_Suffix, Opportunity_Update_VAT_Treatments, Engagement_Clone_Contracts,
                            Engagement_Assign_Number_Suffix, Engagement_Update_VAT_Treatments, Engagement_Move_Internal_Team_To_Project,
                            Engagement_External_Team_Bill_To_Country, Engagement_External_Team_Create_Contract, CapIQ_Company, Investment, Audit_Investment
                           }

    private static Map<String, Boolean> triggerSettingMap;

    static {
        triggerSettingMap = new Map<String, Boolean>();

        for (Trigger_Setting__mdt triggerSetting : [
            SELECT Id, DeveloperName, Enabled__c 
            FROM Trigger_Setting__mdt]) {

            triggerSettingMap.put(triggerSetting.DeveloperName, triggerSetting.Enabled__c);
        }
    }

    public static Boolean IsEnabled(TriggerType triggerName) {
        Boolean result = triggerSettingMap.get(triggerName.name());

        return (result == null) ? true : result;
    }  
}