public  with sharing class HL_EngValuationPeriodPositions {
    public static List<Eng_VP_Position__c> GetEngVPPosition(Id id){
        // commented Industry_Group_Picklist__c from below
        return [SELECT Engagement_VP__c, Company__r.Name, Report_Fee__c,Asset_Classes__c,Industry_Group__c FROM Eng_VP_Position__c WHERE Engagement_VP__c =: id  AND Status__c != 'Cancelled' AND (Report_Fee__c > 0) ORDER BY Company__r.Name ASC];
    }
    
    public static Eng_VP__c GetById(Id id){
        List<Eng_VP__c> EngVPList = Database.Query(GetFullSelect() + 
                                          ', Engagement__r.Transaction_Description__c, Engagement__r.Engagement_Number__c, Engagement__r.Primary_Contact_Email__c, Engagement__r.Primary_Contact_Title__c, Engagement__r.Primary_External_Contact__r.Name, Engagement__r.Client__r.Name, Engagement__r.Client_Number__c, Engagement__r.Opportunity_Number__c, Engagement__r.Client_Billing_Address__c, Engagement__r.Retainer__c FROM Eng_VP__c ' + 
                                          ' WHERE Id =: Id');
        return EngVPList.size() > 0 ? EngVPList[0] : null;
    }
    
    
    public static string GetFullSelect(){
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Eng_VP__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String q = 'SELECT ';
        // Build dynamic query string
        for(Schema.SObjectField s : fldObjMapValues)
        q += s.getDescribe().getName() + ',';
        // Trim last comma
        q = q.subString(0, q.length() - 1);
        return q + ' ';
    }
}