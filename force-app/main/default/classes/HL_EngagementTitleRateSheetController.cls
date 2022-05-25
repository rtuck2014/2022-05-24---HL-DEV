public without sharing class HL_EngagementTitleRateSheetController {
    @AuraEnabled
    public static Engagement_Title_Rate_Sheet__c InsertRecord(Engagement_Title_Rate_Sheet__c engagementTitleRateSheet){
        insert engagementTitleRateSheet;
        return engagementTitleRateSheet;
    }
    
    @AuraEnabled
    public static Engagement_Title_Rate_Sheet__c UpdateRecord(Engagement_Title_Rate_Sheet__c engagementTitleRateSheet){
        update engagementTitleRateSheet;
        return engagementTitleRateSheet;
    }
    
    @AuraEnabled
    public static Engagement_Title_Rate_Sheet__C DeleteRecord(Id id){
        Engagement_Title_Rate_Sheet__c titleRateSheet = new Engagement_Title_Rate_Sheet__c(Id = id);
        delete titleRateSheet;
        return titleRateSheet;
    }
    
    @AuraEnabled
    public static List<Engagement_Title_Rate_Sheet__c> GetEngagementTitleRateSheets(Id engagementId){
        List<Engagement_Title_Rate_Sheet__c> titleRateSheetList = new List<Engagement_Title_Rate_Sheet__c>();
        
        //Verify the User has access to the fields we want to query
        if(HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Name', 'Engagement__c', 'Title_Rate_Sheet__c', 'Start_Date__c', 'End_Date__c'},
                                                Schema.sObjectType.Engagement_Title_Rate_Sheet__c.fields.getMap()))
            titleRateSheetList = HL_EngagementTitleRateSheet.GetByEngagementId(engagementId);
        
        return titleRateSheetList;
    }
    
    @AuraEnabled
    public static List<Title_Rate_Sheet__c> GetTitleRateSheets(){
        List<Title_Rate_Sheet__c> titleRateSheetList = new List<Title_Rate_Sheet__c>();
        
        //Verify the User has access to the fields we want to query
        if(HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Name'}, Schema.sObjectType.Title_Rate_Sheet__c.fields.getMap()))
            titleRateSheetList = HL_TitleRateSheet.GetActive();
        
        return titleRateSheetList;
    }
    
    @AuraEnabled
    public static List<Engagement__c> GetEngagements(string category){
        List<Engagement__c> engagementList = new List<Engagement__c>();
        
        if(String.isBlank(category))
            category = 'Litigation';
        
        //Verify the User has access to the fields we want to query
        if(HL_SecurityUtility.VerifyFieldAccess(new List<String> {'Id', 'Name', 'Engagement_Number__c'}, Schema.SObjectType.Engagement__c.fields.getMap()))
            engagementList = HL_Engagement.GetByPublicGroup('Time_Tracking_' + category, new Set<String> {'Active','Hold','Closed'}, Date.today().addMonths(-2));
        
        return engagementList;
    }
}