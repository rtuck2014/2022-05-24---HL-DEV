/**  
* \arg ClassName        : SL_RelationshipHandler
* \arg JIRATicket       : HL-111
* \arg CreatedOn        : 25/Feb/2015
* \arg LastModifiedOn   : 27/Feb/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : 
* \arg Description      : Handler class for SL_Relationship trigger.
*/
public without sharing class SL_RelationshipHandler 
{
    public static Boolean ENABLED = true;

    /* Start - Variable */
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* End - Variable */
    
    /* Start - Constructor */
    public SL_RelationshipHandler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    /* End - Constructor */ 
    
    /*
        @MethodName         : onAfterInsert
        @param              : Map of Relationship__c
        @Description        : Creating manual sharing records on after insert 
                              of Relationship__c records 
    */
    public void onAfterInsert(Map<Id, Relationship__c> mapIdToRelationshipNew)
    {
        createDeleteSharingRules(new Map<Id, Relationship__c>(), mapIdToRelationshipNew);
    }
    /* End */
    
    /*
        @MethodName         : onAfterUpdate
        @param              : Old and new map of Relationship__c
        @Description        : Creating manual sharing records on after update 
                              of Relationship__c records and delete old manual shares
    */
    public void onAfterUpdate(Map<Id, Relationship__c> mapIdToRelationshipOld, Map<Id, Relationship__c> mapIdToRelationshipNew)
    {
        createDeleteSharingRules(mapIdToRelationshipOld, mapIdToRelationshipNew);  
    }
    /* End */
    
    /*
        @MethodName         : createDeleteSharingRules
        @param              : Old and New map of Relationship__c
        @Description        : Creating and deleting the relationship sharing rules on creation and updation of relationship records
    */
    private void createDeleteSharingRules(Map<Id, Relationship__c> mapIdToRelationshipOld, Map<Id, Relationship__c> mapIdToRelationshipNew)
    {
        if (!ENABLED) {
            return;
        }

        Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();//Map of contact id to user id 
        Map<Id, Id> mapUserIdToGroupId = new Map<Id, Id>();//Map of user id to group id 
        Map<String, Relationship__Share> mapParentId_GroupIdToExistShare = new Map<String, Relationship__Share>();//Map of relationship id group id to relatioship shares
        Map<String, Relationship__Share> mapParentId_GroupIdToShareInsert = new Map<String, Relationship__Share>();//Map of relationship id group id to relatioship shares to insert
        Map<String, Relationship__Share> mapParentId_GroupIdToShareDelete = new Map<String, Relationship__Share>();//Map of relationship id group id to relatioship shares to delete
        List<Relationship__c> lstFilteredRelationship = new List<Relationship__c>();//List of relationship for updating owner id 
        Set<Id> setContactId = new Set<Id>();//Set of contact ids
        
        //Iterating on relationship to get set of contact id
        for(Relationship__c objRelationship : mapIdToRelationshipNew.values())
        {
            if(objRelationship.HL_Contact__c != null && (mapIdToRelationshipOld.isEmpty() 
               || objRelationship.HL_Contact__c != mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c))
            {   
                lstFilteredRelationship.add(objRelationship);          
                setContactId.add(objRelationship.HL_Contact__c);
                if(!mapIdToRelationshipOld.isEmpty() && mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c != null)
                    setContactId.add(mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c);
            }
        }
        
        //Iterating on contact to get a map of contact id to user id 
        for(Contact objContact : [SELECT Id,
                                         User__c
                                    FROM Contact     
                                   WHERE Id IN : setContactId
                                     AND User__r.IsActive = true])
        {
            mapContactIdToUserId.put(objContact.Id, objContact.User__c);
        }

        //Iterating on Delegate_Public_Group__c to get a map of user id to group id
        for(Delegate_Public_Group__c objDPG : [SELECT Id,
                                                      Banker__c,
                                                      Public_Group_ID__c
                                                 FROM Delegate_Public_Group__c
                                                WHERE Banker__c IN : mapContactIdToUserId.values()])
        {
            mapUserIdToGroupId.put(objDPG.Banker__c, objDPG.Public_Group_ID__c);
        }   

        //Iterating on exsting relationship sharing records 
        for(Relationship__Share objRS : [SELECT Id, 
                                                UserOrGroupId, 
                                                ParentId 
                                           FROM Relationship__Share
                                          WHERE RowCause='Manual' 
                                            AND AccessLevel ='Edit'
                                            AND ParentId IN : mapIdToRelationshipNew.keySet()
                                            AND UserOrGroupId IN : mapUserIdToGroupId.values()])    
        {
            mapParentId_GroupIdToExistShare.put(objRS.ParentId +'_'+ objRS.UserOrGroupId, objRS);
        }

        //Creating and deleting the relationship sharing records on insert and update of relationship 
        for(Relationship__c objRelationship : lstFilteredRelationship)
        {
            if(mapContactIdToUserId.containsKey(objRelationship.HL_Contact__c))
            {
                if(mapUserIdToGroupId.containsKey(mapContactIdToUserId.get(objRelationship.HL_Contact__c)) 
                   && !mapParentId_GroupIdToExistShare.containsKey(objRelationship.Id +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get(objRelationship.HL_Contact__c))))
                {
                    mapParentId_GroupIdToShareInsert.put(objRelationship.Id +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get(objRelationship.HL_Contact__c)), 
                                                                     new Relationship__Share(ParentId = objRelationship.Id, AccessLevel = 'Edit',
                                                                                             UserOrGroupId = mapUserIdToGroupId.get(mapContactIdToUserId.get(objRelationship.HL_Contact__c))));
                }
                
                if(!mapIdToRelationshipOld.isEmpty() && objRelationship.HL_Contact__c != mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c 
                   && mapUserIdToGroupId.containsKey(mapContactIdToUserId.get(mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c))
                   && mapParentId_GroupIdToExistShare.containsKey(objRelationship.Id +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get(mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c))))
                {
                    mapParentId_GroupIdToShareDelete.put(objRelationship.Id +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get(mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c)),
                                                        mapParentId_GroupIdToExistShare.get(objRelationship.Id +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get(mapIdToRelationshipOld.get(objRelationship.Id).HL_Contact__c))));
                }
            }
        }
        
        //Deleting old relationship sharing record when contact is updated on relationship records 
        if(!mapParentId_GroupIdToShareDelete.isEmpty())
            delete mapParentId_GroupIdToShareDelete.values();     
        
        //Inserting relationship sharing records when a new relationship record is inserted or contact is updated on relationship
        if(!mapParentId_GroupIdToShareInsert.isEmpty())
            insert mapParentId_GroupIdToShareInsert.values();   
    }
    /* End */
}