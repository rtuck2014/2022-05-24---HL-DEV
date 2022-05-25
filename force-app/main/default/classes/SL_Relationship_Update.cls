/**  
* \arg ClassName      : SL_Relationship_Update
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 6/NOV/2014
* \arg LastModifiedOn : 6/NOV/2014
* \arg CreatededBy    : Edward Rivera
* \arg ModifiedBy     : -
* \arg Description    : Class for handling updates of Relationship__c objects
*/
public with sharing class SL_Relationship_Update {

	private List<Relationship__c> relationshipsToUpdate; // list received on instantiation of relationships to be updated
	private Map<Id, Relationship__c> mapRelationship; // map of relationships being updated generated from list
	private Map<String, Id> StringToRelationship; // maps 'User.Id+:+'Contact.Id' to the Id of the corresponding relationship
	private Map<Id, Relationship__c> mapRelationshipToUpdate;//!< Relationship records to update.
	
	private Set<Id> setHLContactUserId;//!< set to hold the HL Contact User Ids.
    private Set<Id> setHLContactId;//!< set to hold the HL Contact Ids.
    private Set<Id> setExContactId;//!< set to hold the External Contact Ids.
    private Set<Id> allRelatedIds;

    private Set<Id> setEngagementIds;//!< set to hold the Engagement record Ids.
    private Map<Id, Id> mapHLContactToUserId; // maps an HL contact ID to their user ID to save queries

    private Map<Id, Set<Id>> mapEngagementIdToSetHLClosed = new Map<Id, Set<Id >>();//!<map ContactIds corresponding to EngagementIds closeactivity.
    private Map<Id, Set<Id>> mapEngagementIdToSetHLActive = new Map<Id, Set<Id>>();//!< map ContactIds corresponding to EngagementIds activeactivity.

	public SL_Relationship_Update(List<Relationship__c> relationshipsToUpdate) {
		this.relationshipsToUpdate = relationshipsToUpdate;
	}
	/*
        @MethodName : calculateAllFields
        @param 		: Set<Id> setHLContactId and Set<Id> setExContactId
        @Description: Generates the map from engagement Ids to a list of Ids comprising the internal engagement team
    */
	public void calculateAllFields(){
		lazyLoadSetsAndMaps(); // load the previous sets and maps
 		getLastActivity(); // calculate the Last Activity Date field
 		getNextActivity(); // calculate the Next Activity Date field
 		getActivityLTM(); // calculate the # of Activities LTM field
    	getOpenOpportunities(); // calculate the Share Open Opp? field
     	getSharedEngagements(); // calculate the Share Active Deal?, # of Deals Shown, # of Deals on Client/External Team fields
    }
    /*
        @MethodName : updateAll
        @param 		: 
        @Description: updates based off the calculations performed
    */
    public void updateAll(){
    	update mapRelationshipToUpdate.values();  
    }  
    
    /*
        @MethodName : lazyLoadSetsAndMaps
        @param 		: 
        @Description: lazy loads the id sets, the string-to-id map and the id to record map
    */
    private void lazyLoadSetsAndMaps(){
    	if (setHLContactId!=null){
    		return;
    	}
    	mapRelationship = new Map<Id, Relationship__c>();
        StringToRelationship = new Map<String,Id>();
        mapRelationshipToUpdate = new Map<Id, Relationship__c>();
    	setHLContactUserId = new Set<Id>();
        setHLContactId = new Set<Id>();
        setExContactId = new Set<Id>();   
        mapHLContactToUserId = new Map<Id, Id>();
    	for(Relationship__c objRelationship :relationshipsToUpdate){
    		mapRelationship.put(objRelationship.id, objRelationship);
    		StringToRelationship.put(objRelationship.HL_Contact__r.User__c + ':' + (String) objRelationship.External_Contact__c, objRelationship.Id);
            if(objRelationship.HL_Contact__r.User__c != null)
                setHLContactUserId.add(objRelationship.HL_Contact__r.User__c);
    		if(objRelationship.HL_Contact__c != null)
                setHLContactId.add(objRelationship.HL_Contact__c);
            if (objRelationship.External_Contact__c!=null)
                setExContactId.add(objRelationship.External_Contact__c);
    		mapHLContactToUserId.put(objRelationship.HL_Contact__c, objRelationship.HL_Contact__r.User__c);
        }
        allRelatedIds = new Set<Id>();
        allRelatedIds.addAll(setHlContactUserId);
        allRelatedIds.addAll(setHlContactId);
        allRelatedIds.addAll(setExContactId);  
    }
    /*
        @MethodName : addToUpdateMap
        @param 		: Map<Id, Object> genericMap - map of new records to update, String fieldName - field to be updated
        @Description: adds to the update map records whose associated field have changed, or updates them in the map
    */
    private void addToUpdateMap(Map<Id, Object> genericMap, String fieldName ){
    	for (Id relationshipId: genericMap.keySet()){
    		Relationship__c relationship = mapRelationship.get(relationshipId);

            // relationship already in update map
        	if (mapRelationshipToUpdate.keyset().contains(relationshipId)){
        		mapRelationshipToUpdate.get(relationshipId).put(fieldName,genericMap.get(relationshipId));
        	}
        	else if(relationship.get(fieldName)!=genericMap.get(relationshipId)){
        		relationship.put(fieldName,genericMap.get(relationshipId));
        		mapRelationshipToUpdate.put(relationshipId, relationship);
        	}
    	}
    }

    /*
        @MethodName : getEngagementHLTeams
        @param 		: 
        @Description: Generates the map from engagement Ids to a list of Ids comprising the internal engagement team
    */
    private void getEngagementHLTeams(){
    	//!< Iterating to get close deal and active deal in Internal Team.
    	if (setEngagementIds!=null){
    		return;
    	}
    	setEngagementIds = new Set<Id>();
    	mapEngagementIdToSetHLClosed = new Map<Id, Set<Id>>();
    	mapEngagementIdToSetHLActive = new Map<Id, Set<Id>>();  
        for(Engagement_Internal_Team__c objEIT : [SELECT Id, 
        												 Engagement__c,
        												 Contact__c,
                                                         Contact__r.User__c,
        												 Engagement__r.Closed__c,
                                                         Start_Date__c,
                                                         End_Date__c
        										    FROM Engagement_Internal_Team__c 
        										   WHERE Contact__c IN: setHLContactId])
        {
        	setEngagementIds.add(objEIT.Engagement__c);
        	if(objEIT.Engagement__r.Closed__c)
        	{
        		if(mapEngagementIdToSetHLClosed.containsKey(objEIT.Engagement__c)){
                    if (!mapEngagementIdToSetHLClosed.get(objEIT.Engagement__c).contains(objEIT.Contact__r.User__c)){
                        mapEngagementIdToSetHLClosed.get(objEIT.Engagement__c).add(objEIT.Contact__r.User__c);
                    }
                }
        		else {
        			mapEngagementIdToSetHLClosed.put(objEIT.Engagement__c, new Set<Id>{objEIT.Contact__r.User__c});
                }
        	}
        	else
        	{
                if(!mapEngagementIdToSetHLActive.containsKey(objEIT.Engagement__c)){
                    mapEngagementIdToSetHLActive.put(objEIT.Engagement__c, new Set<Id>());
                }
                if ( (objEIT.Start_Date__c <= Date.Today() || objEIT.Start_Date__c==null) &&
                     (objEIT.End_Date__c >= Date.Today() || objEIT.End_Date__c==null)){
                    if (!mapEngagementIdToSetHLActive.get(objEIT.Engagement__c).contains(objEIT.Contact__r.User__c)){
            			mapEngagementIdToSetHLActive.get(objEIT.Engagement__c).add(objEIT.Contact__r.User__c);
                    }
                }
        	}
        }
    }
    
    /*
        @MethodName : getUpdateActivityMap
        @param      : List<EventRelation> eventRelations, SObjType type
        @Description: Generates the map from a relationship to a potential updated field value
    */
    private Map<Id, Object> getUpdateActivityMap (List<Event> events, System.Type type){
        Map<Id, Object> genericMap = new Map<Id, Object>();
        Map<Id, Set<Id>> HoulihanMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> ExternalMap = new Map<Id, Set<Id>>();
        Boolean Houlihan;
        Set<Id> Others;
        Id HoulihanId;
        Id ExternalId;    
        for (Event tr: events){
            if (!HoulihanMap.keyset().contains(tr.ParentId__c)){
                HoulihanMap.put(tr.ParentId__c, new Set<Id>());
                ExternalMap.put(tr.ParentId__c, new Set<Id>());
            }
            if (setHLContactId.contains(tr.WhoId)||setHLContactUserId.contains(tr.WhoId)){
                Houlihan=true;
                HoulihanId = tr.WhoId;
                if (setHLContactId.contains(tr.WhoId)){
                    HoulihanId = mapHLContactToUserId.get(HoulihanId);  // convert contact Id to User Id
                }
                HoulihanMap.get(tr.ParentId__c).add(HoulihanId);
                Others = ExternalMap.get(tr.ParentId__c);
            }
            else{
                Houlihan=false;
                ExternalId = tr.WhoId;
                ExternalMap.get(tr.ParentId__c).add(tr.WhoId); 
                Others = HoulihanMap.get(tr.ParentId__c);
            }
            if(Integer.class <> type){
                for (Id OtherId: Others){
                if (Houlihan){
                    ExternalId=OtherId;
                }
                else{
                    HoulihanId=OtherId;
                } 
                if (StringToRelationship.keyset().contains(HoulihanId+':'+ExternalId)){
                    Id relationshipId = StringToRelationship.get(HoulihanId+':'+ExternalId);
                   if (!genericMap.keyset().contains(relationshipId)){
                        genericMap.put( relationshipId, tr.ActivityDate);
                    }
                }
            }
            }
        }
        if(Integer.class == type){
        for(Id parentId: HoulihanMap.keyset()){
            for(Id hlId : HoulihanMap.get(parentId)){
                Others = ExternalMap.get(parentId);
                for (Id OtherId: Others){
                    ExternalId=OtherId;
                    if (StringToRelationship.keyset().contains(hlId+':'+ExternalId)){
                        Id relationshipId = StringToRelationship.get(hlId+':'+ExternalId);
                        if (Integer.class==type){                     
                            if (!genericMap.keyset().contains(relationshipId)){
                                genericMap.put(relationshipId, 1);
                            }
                            else{
                                genericMap.put( relationshipId, ((Integer)genericMap.get(relationshipId))+1);
                            }
                        }
                    }
                }
            }
        }
        if (Integer.class==type){  
            // create the set of relationships that have had 0 events in the last 12 months
            Set<Id> nilActivitiesLTM = new Set<Id>(mapRelationship.keySet());
            nilActivitiesLTM.removeAll(genericMap.keySet());
            for (Id id: nilActivitiesLTM){
                // put the relationship in the map with 0 activities
                genericMap.put( id, 0);
            }
        }
    }
    else{
    }
        return genericMap;
    
    }
    /*
        @MethodName : getLastActivity
        @param 		: 
        @Description: Generates the map from relationship Ids to their date field 'Last_Activity_Date__c'
    */
    private void getLastActivity(){
    	Map<Id, Date> mapLastActivity = new Map<Id, Date>();//!< map to hold last activity date
        Map<Id, Date> mapLastEvent = new Map<Id, Date>();//!< map to hold last activity date
        Map<Id, Object> temp = new Map<Id, Object>();

        temp = getUpdateActivityMap([SELECT WhoId,
                                            ParentId__c,
                                            OwnerId,
                                            ActivityDate
                                    FROM    Event
                                    WHERE   ParentId__c <> null 
                                    AND     (ActivityDate < TODAY OR (IsAllDayEvent=False AND ActivityDateTime < :DateTime.Now()))
                                    AND     WhoId IN :allRelatedIds
                                    ORDER BY ActivityDate DESC]
                                    , Date.class);
        for (Id id: temp.keySet()){
            mapLastEvent.put(id, (Date)temp.get(id));
        }
        Set <Id> AllIdsWithPastActivity = new Set<Id>();
        AllIdsWithPastActivity.addAll(mapLastEvent.keyset());
        for (Id relationshipId: allIdsWithPastActivity){
            if (mapLastEvent.keySet().contains(relationshipId) ){
                    mapLastActivity.put(relationshipId, mapLastEvent.get(relationshipId));
            }
            else{
                mapLastActivity.put(relationshipId, mapLastEvent.get(relationshipId));
            }
        }
        addToUpdateMap(mapLastActivity, 'Last_Activity_Date__c');
	}

	/*
        @MethodName : getNextActivity
        @param 		: 
        @Description: Generates the map from relationship Ids to their numeric field 'Next_Activity_Date__c'
    */
    private void getNextActivity(){
    	Map<Id, Date> mapNextActivity = new Map<Id, Date>();//!< map to hold next activity date
        Map<Id, Date> mapNextEvent = new Map<Id, Date>();//!< map to hold next activity date
        Map<Id, Object> temp = new Map<Id, Object>();

        temp = getUpdateActivityMap([SELECT WhoId,
                                            ParentId__c,
                                            OwnerId,
                                            ActivityDate
                                    FROM    Event
                                    WHERE   ParentId__c <> null 
                                    AND     (ActivityDate >= TODAY OR (IsAllDayEvent=False AND ActivityDateTime >= :DateTime.Now()))
                                    AND     WhoId IN :allRelatedIds
                                    ORDER BY ActivityDate ASC]
                                    , Date.class);
        for (Id id: temp.keySet()){
            mapNextEvent.put(id, (Date)temp.get(id));
        }
        Set <Id> AllIdsWithFutureActivity = new Set<Id>();
        AllIdsWithFutureActivity.addAll(mapNextEvent.keyset());
        for (Id relationshipId: allIdsWithFutureActivity){
            if (mapNextEvent.keySet().contains(relationshipId) ){
                    mapNextActivity.put(relationshipId, mapNextEvent.get(relationshipId));
            }
            else{
                mapNextActivity.put(relationshipId, mapNextEvent.get(relationshipId));
            }
        }
        addToUpdateMap(mapNextActivity, 'Next_Activity_Date__c');
    }

    /*
        @MethodName : getActivityLTM
        @param 		: Set<Id> setHLContactId and Set<Id> setExContactId
        @Description: Generates the map from relationship Ids to their date field 'Number_of_Activities_LTM__c'
    */
    private void getActivityLTM(){
    	Map<Id, Integer> mapActivityLTM = new Map<Id, Integer>();//!< map to hold next activity date
        Map<Id, Object> temp = new Map<Id, Object>();
        temp = getUpdateActivityMap([SELECT WhoId,
                                            ParentId__c,
                                            OwnerId,
                                            ActivityDate
                                    FROM    Event
                                    WHERE   ParentId__c <> null
                                    AND     ActivityDate = LAST_N_DAYS:365
                                    AND     WhoId IN :allRelatedIds]
                                    , Integer.class);
        for (Id id: temp.keySet())
            mapActivityLTM.put(id, (Integer)temp.get(id));
        addToUpdateMap(mapActivityLTM, 'Number_of_Activities_LTM__c');
    }
    

    /*
        @MethodName : getSharedEngagements
        @param 		:
        @Description: Generates the map from relationship Ids to their checkbox field 'Share_Active_Deal__c' and 'Number_of_Deals_Shown__c'
    */
    private void getSharedEngagements(){

    	getEngagementHLTeams();
    	List<Engagement_External_Team__c> externalTeam = [SELECT Id, 
        												 Engagement__c,
        												 Contact__c,
        												 Engagement__r.Closed__c
        										    FROM Engagement_External_Team__c 
        										   WHERE Contact__c IN: setExContactId 
        										     AND Engagement__c IN: setEngagementIds];
        Map<Id, Integer> mapAllRelsNoClosed = new Map<Id, Integer>();
        Map<Id, Integer> mapAllRelsNoShown= new Map<Id, Integer>();
        Map<Id, Boolean> mapAllRelsActive = new Map<Id, Boolean>();
        for (Id id: mapRelationship.keySet()){
            mapAllRelsNoClosed.put(id, 0);
            mapAllRelsNoShown.put(id, 0);
            mapAllRelsActive.put(id, false);
        }

    	Map<Id, Integer> mapNoOfDealsClosed = new Map<Id, Integer>();//!< map to hold no of deal close.
    	Map<Id, Integer> mapNoOfDealShown = new Map<Id, Integer>();//!< map to hold no of deal shown.
        Map<Id, Boolean> mapActiveDeal = new Map<Id, Boolean>();//!< map to hold is there is active deal present.

        for(Engagement_External_Team__c objEET : externalTeam)
        {
        	if(objEET.Engagement__r.Closed__c && mapEngagementIdToSetHLClosed.containsKey(objEET.Engagement__c))
        	{
        		// for all of the HL employees on this closed engagement, pair them up with this external team member and add 1 to their number of deals closed together
        		for(Id strHLUserId : mapEngagementIdToSetHLClosed.get(objEET.Engagement__c))
        		{
                    Id relId = StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c);
                    // if a relationship exists
                    if (relId!=null){
                        if(mapNoOfDealsClosed.containsKey(relId))
                            mapNoOfDealsClosed.put(relId, mapNoOfDealsClosed.get(relId) + 1);
                        else
                            mapNoOfDealsClosed.put(relId, 1);
                    }

        		}
        	}
        	else
        	{
                for(Id strHLUserId : mapEngagementIdToSetHLActive.get(objEET.Engagement__c)) {
                    Id relId = StringToRelationship.get(strHLUserId + ':' + objEET.Contact__c);
                    // if a relationship exists
                    if (relId!=null){
        			    mapActiveDeal.put(relId, true);
        		    }
                }
        	}
        }
        
        //!< Iterating to get deal shown.
        for(Engagement_Counterparty_Contact__c objECC : [SELECT Id,
        														Contact__c, 
        														Counterparty__r.Engagement__c,
        														Counterparty__r.Engagement__r.Closed__c 
        												   FROM Engagement_Counterparty_Contact__c 
        												  WHERE Counterparty__r.Engagement__r.Closed__c = true 
        												    AND Counterparty__r.Engagement__c IN : mapEngagementIdToSetHLClosed.keySet()
        												    AND Contact__c IN: setExContactId])
		{
			// for all of the HL employees on this closed engagement, pair them up with this external team member and add 1 to their number of deals shown
			for(Id strHLUserId : mapEngagementIdToSetHLClosed.get(objECC.Counterparty__r.Engagement__c))
    		{
                Id relId = StringToRelationship.get(strHLUserId + ':' + objECC.Contact__c);
                // if a relationship exists
                if (relId!=null){
                    if(mapNoOfDealShown.containsKey(relId))
                        mapNoOfDealShown.put(relId, mapNoOfDealShown.get(relId) + 1);
                    else
                        mapNoOfDealShown.put(relId, 1);
                }
    		}
		}
        for (Id id: mapNoOfDealsClosed.keySet()){
            mapAllRelsNoClosed.put(id, mapNoOfDealsClosed.get(id));
        }
        for (Id id: mapNoOfDealShown.keySet()){
            mapAllRelsNoShown.put(id, mapNoOfDealShown.get(id));
        }
        for (Id id: mapActiveDeal.keySet()){
            mapAllRelsActive.put(id, mapActiveDeal.get(id));
        }
        
		addToUpdateMap(mapAllRelsNoClosed, 'Number_of_Deals_on_Client_External_Team__c');
        addToUpdateMap(mapAllRelsNoShown, 'Number_of_Deals_Shown__c');
		addToUpdateMap(mapAllRelsActive, 'Share_Active_Deal__c');
    }
    /*
        @MethodName : getOpenOpportunities.
        @param 		: 
        @Description: Generates the map from relationship Ids to their checkbox field 'Share_Open_Opp__c'
    */
    private void getOpenOpportunities(){
    	Map<Id, Set<Id>> mapOpportunityIdToSetHLContactOpen = new Map<Id, Set<Id>>();//!< map ContactIds corresponding to OpportunityIds open activity.
    	Map<Id, Boolean> mapOpenOpportunity = new Map<Id, Boolean>();//!< map to hold, is there open Opportunity available.
    	Map<Id, Boolean> mapAllRels = new Map<Id, Boolean>();
        for (Id id: mapRelationship.keySet()){
            mapAllRels.put(id, false);
        }
        //!< Iterating to get open Opportunity.
        for(Opportunity_Internal_Team__c objOIT : [SELECT Id, 
        												  Opportunity__c,
        												  Contact__c,
                                                          Contact__r.User__c, 
        												  Opportunity__r.Closed__c 
        										     FROM Opportunity_Internal_Team__c 
        										    WHERE Contact__c IN :setHLContactId 
        										      AND Opportunity__r.Closed__c = false
                                                      AND (Start_Date__c <= TODAY OR Start_Date__c=null)
                                                      AND (End_Date__c >= TODAY OR End_Date__c=null)])
       	{
       		// add this HL employee to the set of employees on the related opportunity
    		if(mapOpportunityIdToSetHLContactOpen.containsKey(objOIT.Opportunity__c)){
                if (!mapOpportunityIdToSetHLContactOpen.get(objOIT.Opportunity__c).contains(objOIT.Contact__r.User__c)){
                    mapOpportunityIdToSetHLContactOpen.get(objOIT.Opportunity__c).add(objOIT.Contact__r.User__c);
                }
            }
    		else
    			mapOpportunityIdToSetHLContactOpen.put(objOIT.Opportunity__c, new Set<Id>{objOIT.Contact__r.User__c});
    	}
    	//!< Iterating to get open Opportunity.
    	for(Opportunity_External_Team__c objOET : [SELECT Id, 
        												  Opportunity__c,
        												  Contact__c, 
        												  Opportunity__r.Closed__c 
        										     FROM Opportunity_External_Team__c 
        										    WHERE Contact__c IN:setExContactId 
        										      AND Opportunity__r.Closed__c = false])
       	{
       		// if this opportunity has an associated internal op team
       		if(mapOpportunityIdToSetHLContactOpen.containsKey(objOET.Opportunity__c))
       		{
       			// for each member of the internal op team, pair them up with this external op team member; they're on an open opportunity together
	       		for(Id strHLId : mapOpportunityIdToSetHLContactOpen.get(objOET.Opportunity__c))
	    		{
                    Id relId = StringToRelationship.get(strHLId + ':' + objOET.Contact__c);
                    if (relId!=null){
                        mapOpenOpportunity.put(relId, true);
                    }
	    		}
       		}
    	}

        for (Id id: mapOpenOpportunity.keySet()){
            mapAllRels.put(id, mapOpenOpportunity.get(id));
        }
    	addToUpdateMap(mapAllRels, 'Share_Open_Opp__c');
    }
}