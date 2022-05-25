public with sharing class HL_RelationshipHandler 
{
    public static Boolean ENABLED = true;

	public static void UpdateOwnerOnInsert(List<Relationship__c> rList){
		updateOwnerIdOnInsertUpdate(new Map<Id, Relationship__c>(), rList);
    }
    
    public static void UpdateOwnerOnUpdate(Map<Id, Relationship__c> mapIdToRelationshipOld, List<Relationship__c> rList){
        updateOwnerIdOnInsertUpdate(mapIdToRelationshipOld, rList);
    }
	
	private static void updateOwnerIdOnInsertUpdate(Map<Id, Relationship__c> mapIdToRelationshipOld, List<Relationship__c> lstRelationshipNew)
	{
        if (!ENABLED) {
            return;
        }
        
		Set<Id> setContactId = new Set<Id>();//Set of contact ids
		Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();//Map of contact id to user id 
		List<Relationship__c> lstFilteredRelationship = new List<Relationship__c>();
				
		for(Relationship__c objRelationship : lstRelationshipNew)   
		{
			if(objRelationship.HL_Contact__c != null && (mapIdToRelationshipOld.isEmpty() 
			   || objRelationship.HL_Contact__c != mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c))
			{
				lstFilteredRelationship.add(objRelationship);
				setContactId.add(objRelationship.HL_Contact__c);
			}
		}
		
		//Iterating on contact to get a map of contact id to user id 
		for(Contact objContact : [SELECT Id,
										 User__c,
										 User__r.Name
									FROM Contact	 
								   WHERE Id IN : setContactId
								     AND User__r.IsActive = true])
		{
			mapContactIdToUserId.put(objContact.Id, objContact.User__c);
		}
		
		//Iterating on relationship record to update the owner id 
		for(Relationship__c objRelationship : lstFilteredRelationship)
		{
			if(objRelationship.HL_Contact__c != null)  
			{
				if(mapContactIdToUserId.containsKey(objRelationship.HL_Contact__c))
					objRelationship.OwnerId = mapContactIdToUserId.get(objRelationship.HL_Contact__c);
				else
					objRelationship.OwnerId = UserInfo.getUserId();
			}			
		}	
	}
}