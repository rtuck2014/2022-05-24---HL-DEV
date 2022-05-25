//Assigns Apex Sharing Rules to HL_Report_Link__c Records based on Subscription Records
public without sharing class HL_SubscriptionHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    
    public HL_SubscriptionHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    //Create/Share Report Link Records when Necessary/Specified
    public void OnAfterInsert(List<HL_Subscription__c> newSubscriptionList){
        List<HL_Subscription__c> recordsToShare = new List<HL_Subscription__c>();
        for(HL_Subscription__c sub : newSubscriptionList){
            if(sub.Active__c && !String.isBlank(sub.Subscriber__c) && !String.isBlank(sub.HL_Report_Link__c))
                recordsToShare.add(sub);
        }
        if(recordsToShare.size() > 0)
            CreateReportLinkShareRecords(recordsToShare);
    }
    
    //May Need to Update this at a later time to handle more complex Updates
    public void OnAfterUpdate(Map<Id, HL_Subscription__c> oldSubscriptionMap, Map<Id, HL_Subscription__c> newSubscriptionMap){
        List<HL_Subscription__c> recordsToShare = new List<HL_Subscription__c>();
        List<HL_Subscription__c> recordsToUnshare = new List<HL_Subscription__c>();
        
        for(HL_Subscription__c sub : newSubscriptionMap.values()){
            if(!String.isBlank(sub.HL_Report_Link__c)){
                if(!sub.Active__c)
                    recordsToUnshare.add(sub);
                else
                    recordsToShare.add(sub);
            }
        }
        
        if(recordsToShare.size() > 0)
            CreateReportLinkShareRecords(recordsToShare);
        if(recordsToUnshare.size() > 0)
            RemoveReportLinkShareRecords(recordsToUnshare);
    }
    
    //Remove Shared Report Link Records
    public void OnAfterDelete(List<HL_Subscription__c> deletedSubscriptionList){
        List<HL_Subscription__c> recordsToUnshare = new List<HL_Subscription__c>();
        for(HL_Subscription__c sub : deletedSubscriptionList){
            if(!String.isBlank(sub.HL_Report_Link__c) && !String.isBlank(sub.Subscriber__c))
                recordsToUnshare.add(sub);
        }
        if(recordsToUnshare.size() > 0)
            RemoveReportLinkShareRecords(recordsToUnshare);
    }
    
    private List<HL_Report_Link__Share> CreateReportLinkShareRecords(List<HL_Subscription__c> subscriptionList){
        List<HL_Report_Link__Share> recordsToInsert = new List<HL_Report_Link__Share>();
        Map<Id, Contact> contactMap = GetContactMap(subscriptionList);
        
        for(HL_Subscription__c sub : subscriptionList)
            recordsToInsert.add(new HL_Report_Link__Share(ParentId = sub.HL_Report_Link__c, UserOrGroupId = contactMap.get(sub.Subscriber__c).User__c, AccessLevel='Read', RowCause=Schema.HL_Report_Link__Share.RowCause.Subscription__c));
        
        if(recordsToInsert.size() > 0)
            insert recordsToInsert;
        
        return recordsToInsert;
    }
    
    private Map<Id, Contact> GetContactMap(List<HL_Subscription__c> subscriptionList){
        //Get a List of Contact Records to Get the Corresponding User Id
        List<Contact> contactIdList = new List<Contact>();
        
        for(HL_Subscription__c sub : subscriptionList) // We scrub these in the trigger handler so should all have Subscriber
            	contactIdList.add(new Contact(Id = sub.Subscriber__c));
        
        return HL_Contact.GetMap(contactIdList);
    }
    
    private List<HL_Report_Link__Share> RemoveReportLinkShareRecords(List<HL_Subscription__c> subscriptionList){
        List<HL_Report_Link__Share> recordsToDelete = new List<HL_Report_Link__Share>();
        List<Id> userIdList = new List<Id>();
        Map<Id, Contact> contactMap = GetContactMap(subscriptionList);
        for(Contact c : contactMap.values())
            userIdList.add(c.User__c);
        //Create a Set of User and Report to Record
        Set<String> keySet = new Set<String>();
        for(HL_Subscription__c sub : subscriptionList)
        {
            Id userId = contactMap.get(sub.Subscriber__c).User__c;
            if(!String.isBlank(userId) && !String.isBlank(sub.HL_Report_Link__c) && !keySet.contains(userId + '_' + sub.HL_Report_Link__c))
                keySet.add(userId + '_' + sub.HL_Report_Link__c);
        }
        
        for(HL_Report_Link__Share reportLinkShare : [SELECT ParentId, UserOrGroupId FROM HL_Report_Link__Share WHERE UserOrGroupId IN : userIdList AND RowCause =: Schema.HL_Report_Link__Share.RowCause.Subscription__c]){
             if(keySet.contains(reportLinkShare.UserOrGroupId + '_' + reportLinkShare.ParentId))
                 recordsToDelete.add(reportLinkShare);
        }
        
        if(recordsToDelete.size() > 0)
            delete recordsToDelete;
        
        return recordsToDelete;
    }
}