/**  
* \arg ClassName		: SL_DelegatePublicGroupHandler
* \arg JIRATicket		: HL-30
* \arg CreatedOn		: 1/OCT/2014
* \arg LastModifiedOn	: 1/OOCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Handler class for Delegate_Public_Group__c Trigger
*/

public with sharing class SL_DelegatePublicGroupHandler 
{
	/* Start - Variables */
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* End - Variables */

    /* Start - Constructor */
	public SL_DelegatePublicGroupHandler(boolean isExecuting, integer size) 
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	}
	/* End - Constructor */
	
	/*
        @MethodName        : onBeforeInsert
        @param             : List of Delegate_Public_Group__c
        @Description       : This function will be called after insert of the Delegate_Public_Group__c to create Groups
    */
	public void onBeforeInsert(List<Delegate_Public_Group__c> lstDelegatePublicGroupNew)
    {
    	createGroup(lstDelegatePublicGroupNew);//calling method to create the Group records.
    }
	/* End */
	
	/*
        @MethodName        : onAfterDelete
        @param             : List of Delegate_Public_Group__c
        @Description       : This function used to delete the Delegate_Public_Group__c related to the Group 
    */
    public void onAfterDelete(List<Delegate_Public_Group__c> lstDelegatePublicGroupOld)
    {
    	Set<Id> setPublicGroupId = new Set<Id>();//Set of public group id
    	
    	//Iterating on Delegate_Public_Group__c for getting the public group id
    	for(Delegate_Public_Group__c objDPG : lstDelegatePublicGroupOld)
    	{
    		if(objDPG.Public_Group_ID__c != null)
    			setPublicGroupId.add(objDPG.Public_Group_ID__c);
    	}
    	if(!setPublicGroupId.isEmpty())
    		deleteRelatedPublicGroup(setPublicGroupId);//calling method to delete the Group Member records related to 'Delegate Public Group' record.
    } 
    /* End */
	
	/*
		@MethodName : createGroup 
		@param 	    : List of Delegate_Public_Group__c
		@Description: method to create the Group. 
	*/
	private void createGroup(List<Delegate_Public_Group__c> lstDelegatePublicGroup)
	{
		Set<Id> setUserIdToQuery = new Set<Id>(); //set contains User Id 
		Map<Id, Group> mapUserIdToGroup = new Map<Id, Group>();//Map of user id to group id
		List<String> lstUserId_GroupId = new List<String>();//List of string with combination of user id and group id
		
		//Iterating on Delegate_Public_Group__c for getting user id
		for(Delegate_Public_Group__c objDPG : lstDelegatePublicGroup)
    	{
    		setUserIdToQuery.add(objDPG.Banker__c);//Users Id added in set
    	}
    	
    	//Iterating on user for creating the group
    	for(User objUser : [SELECT Id,
    							   Email 
							 FROM User 
						    WHERE Id IN: setUserIdToQuery])
		{
		    String strTruancatedEmail = (String.valueOf(objUser.Email).split('@')[0].length() > 21) 
		                                ? String.valueOf(objUser.Email).split('@')[0].substring(0, 21)
		                                : String.valueOf(objUser.Email).split('@')[0];
			
			mapUserIdToGroup.put(objUser.Id, new Group(DoesIncludeBosses = false,
    												   Name = strTruancatedEmail + '-' + objUser.Id,
    									 			   Type = 'Regular'));      
		}
		//Insert the group records
		if(!mapUserIdToGroup.isEmpty())
			insert mapUserIdToGroup.values();
		
		//Iterating on Delegate_Public_Group__c to update the Public_Group_ID__c field with group id
		for(Delegate_Public_Group__c objDPG : lstDelegatePublicGroup)
		{
			if(objDPG.Banker__c != null && mapUserIdToGroup.containsKey(objDPG.Banker__c))
			{
				lstUserId_GroupId.add(objDPG.Banker__c + '_' + mapUserIdToGroup.get(objDPG.Banker__c).Id);
				objDPG.Public_Group_ID__c = mapUserIdToGroup.get(objDPG.Banker__c).Id;
			}
		}
		createGroupMembers(lstUserId_GroupId);// method to create group members records using future method.
	}
	/* End */
	
	/*
		@MethodName : createGroupMembers 
		@param 	    : list of string with combination of user id and group id
		@Description: method to create Group Members records. 
	*/
	@future
	private static void createGroupMembers(List<String> lstUserId_GroupId)
	{
		List<GroupMember> lstGroupMemberToInsert = new List<GroupMember>();//List of GroupMember to insert.
		
		//Creating the groupmember records
		for(String strUserId_GroupId : lstUserId_GroupId)
		{
			if(strUserId_GroupId.split('_').size() > 1)
			{
				lstGroupMemberToInsert.add(new GroupMember(UserOrGroupId = strUserId_GroupId.split('_')[0], 
														   GroupId = strUserId_GroupId.split('_')[1]));
			}
		}
		//Insert the groupmember records
		if(!lstGroupMemberToInsert.isEmpty())
			Database.insert(lstGroupMemberToInsert, false);
	}
	/* End */
	
	/*
		@MethodName : deleteRelatedPublicGroup 
		@param 	    : list of Delegate Public Group
		@Description: method to delete Group if its respective Delegate Public Group record is deleted.
	*/
	@future
	private static void deleteRelatedPublicGroup(Set<Id> setPublicGroupId)
	{
		List<Group> lstGroupToDelete = new List<Group>();//List of group to delete
		
		//to delete the group records when its related Delegate_Public_Group__c is deleted. 
		for(Id PGId : setPublicGroupId)
		{
			lstGroupToDelete.add(new Group(Id = PGId));
		}
		//Delete the group records
		if(!lstGroupToDelete.isEmpty())
			delete lstGroupToDelete;
	}
	/* End */
}