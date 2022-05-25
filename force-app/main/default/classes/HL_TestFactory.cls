public with sharing class HL_TestFactory extends SmartFactory {
    public Enum ContactRecordType{Houlihan_Employee, External_Contact}
    
    public static boolean SetFillAllFields(boolean fillAllFields){
        SmartFactory.FillAllFields = fillAllFields;
        return SmartFactory.FillAllFields;
    }
    
    public static Map<String, Set<String>> AddIncludedField(string objectType, Set<String> fieldSet){
        SmartFactory.IncludedFields.put(objectType, fieldSet);
        return SmartFactory.IncludedFields;
    }
    
    public static Map<String, Set<String>> AddExcludedField(string objectType, Set<String> fieldSet){
        SmartFactory.ExcludedFields.put(objectType, fieldSet);
        return SmartFactory.ExcludedFields;
    }
    
    public static SObject CreateSObject(string objectType, boolean cascade) {
        return SmartFactory.CreateSObject(objectType, cascade, 1);
    }
    
    public static List<SObject> CreateSObjectList(string objectType, boolean cascade, integer numberOfObjects) {
        return SmartFactory.CreateSObjectList(objectType, cascade, numberOfObjects);
    }
    
    public static Campaign CreateCampaign(boolean cascade){
        return CreateCampaignList(cascade, 1)[0];
    }
    
    public static List<Campaign> CreateCampaignList(boolean cascade, integer numberOfObjects){
        List<Campaign> campaignList = (List<Campaign>)SmartFactory.CreateSObjectList('Campaign', cascade, numberOfObjects);
        
        for(integer i = 0; i < campaignList.size(); i++)
            campaignList[i].Name = 'Test_' + String.valueOf(i);
        
        return campaignList;
    }
    
    public static Contact CreateContact(ContactRecordType recordType, boolean cascade){
        return CreateContactList(recordType, cascade, 1)[0];
    }
    
    public static List<Contact> CreateContactList(ContactRecordType recordType, boolean cascade, integer numberOfObjects){
        List<Contact> contactList = (List<Contact>)SmartFactory.CreateSObjectList('Contact', cascade, numberOfObjects);
        string recordTypeDeveloperName = recordType == ContactRecordType.Houlihan_Employee ? 'Houlihan_Employee' : 'External_Contact';
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND RecordType.DeveloperName =: recordTypeDeveloperName].Id;
        
        for(integer i = 0; i < contactList.size(); i++){
            contactList[i].FirstName = 'Test_' + String.valueOf(i);
            contactList[i].LastName = 'Test_' + String.valueOf(i);
            contactList[i].Status__c = 'Active';
            contactList[i].RecordTypeId = recordTypeId;
        }
        
        return contactList;
    }
    
    public static Engagement__c CreateEngagement(boolean cascade){
        return CreateEngagementList(cascade, 1)[0];
    }
    
    public static List<Engagement__c> CreateEngagementList(boolean cascade, integer numberOfObjects){
        List<Engagement__c> engagementList = (List<Engagement__c>)SmartFactory.CreateSObjectList('Engagement__c', cascade, numberOfObjects);
        
        for(integer i = 0; i < engagementList.size(); i++){
            engagementList[i].Name = String.valueOf(i);
            engagementList[i].Engagement_Number__c = String.valueOf(i);
        }
        
        return engagementList;
    }
    
}