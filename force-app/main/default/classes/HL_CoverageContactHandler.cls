public with sharing class HL_CoverageContactHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isAfterInsertFlag = false;

    public HL_CoverageContactHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }

    public void OnAfterInsert(List<Coverage_Contact__c> ccList, Map<Id, Coverage_Contact__c> insertedMap){
        if(!isAfterInsertFlag){            
            isAfterInsertFlag = true;
            RelationshipHandler(ccList);
            HL_OffsiteTemplate.HandleInsertedContactRecords(insertedMap);
        }
    }

    public static void RelationshipHandler(List<Coverage_Contact__c> ccList){
        //Create a Set of the Coverage Contact Ids
        Set<Id> ccIds = new Set<Id>();
        Set<Id> cmIds = new Set<Id>();
        
        //Create a Set of Coverage Team Ids
        for(Coverage_Contact__c cc : ccList)
            cmIds.Add(cc.Coverage_Team_Member__c);
        //Create a map of Officers with the Coverage Team
        Map<Id, Coverage_Team__c> mapOfOfficers = new Map<Id,Coverage_Team__c>([SELECT Id, Officer__c FROM Coverage_Team__c WHERE Id In: cmIds]);

        //Create a Set of Coverage Contact with Officer Id
        Set<String> newCCToOfficerIds = new Set<String>();
        Set<String> existingCCToOfficerIds = new Set<String>();
        //Create a Map of Coverage Contact with Officer Id 
        for(Coverage_Contact__c cc : ccList)
        {
            if(mapOfOfficers.get(cc.Coverage_Team_Member__c) != null)
            {
            	newCCToOfficerIds.Add(cc.Coverage_Contact__c + ':' + ((Coverage_Team__c)mapOfOfficers.get(cc.Coverage_Team_Member__c)).Officer__c);
            	ccIds.Add(cc.Coverage_Contact__c);
            }
        }
        List<Relationship__c> relationships = [SELECT Id, HL_Contact__c, External_Contact__c FROM Relationship__c WHERE External_Contact__c IN :  ccIds];
        for(Relationship__c r : relationships)
            existingCCToOfficerIds.Add(r.External_Contact__c + ':' + r.HL_Contact__c);
        List<Relationship__c> recordsToInsert = new List<Relationship__c>();
        for(String newRel : newCCToOfficerIds)
        {
            //If a Relationship does not exist, we need to create it
            if(!existingCCToOfficerIds.contains(newRel)) //, 
                recordsToInsert.Add(New Relationship__c(External_Contact__c = newRel.split(':')[0], HL_Contact__c = newRel.split(':')[1], Type__c = 'Business'));
        }
 
        if(recordsToInsert.size() > 0)
            insert recordsToInsert;
    }
    
    public static void RelationshipUpdateHandler(List<Coverage_Contact__c> oldRecords, Map<Id, Coverage_Contact__c> newRecordsMap){
        //Store the Changed Coverage Contact Records to Insert the New Relationship
        List<Coverage_Contact__c> updatedRecords = new List<Coverage_Contact__c>();

        for(Coverage_Contact__c ctOld : oldRecords)
        {
            if(ctOld.Coverage_Contact__c <> ((Coverage_Contact__c)newRecordsMap.get(ctOld.Id)).Coverage_Contact__c)
                updatedRecords.add(newRecordsMap.get(ctOld.Id));
        }
        
        if(updatedRecords.size() > 0)
            HL_CoverageContactHandler.RelationshipHandler(updatedRecords);
    }
}