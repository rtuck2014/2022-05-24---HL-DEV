/**  
* \arg ClassName		: SL_UserHandler
* \arg JIRATicket		: HL-30
* \arg CreatedOn		: 1/OCT/2014
* \arg LastModifiedOn	: 1/OCT/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Handler class for User Trigger
*/

public with sharing class SL_UserHandler 
{
	/* Start - Variables */
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* End - Variables */

	/* Start - Constructor */
	public SL_UserHandler(boolean isExecuting, integer size) 
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	} 
	/* End - Constructor */

	/*
        @MethodName        : onAfterInsert
        @param             : Map<Id,User> mapUserNew
        @Description       : This function will be called after insert of the User Records to create Delegate_public_group_c  
    */
	public void onAfterInsert(Map<Id,User> mapUserNew)
    {
    	createDelegatePublicGroup(new Map<Id,User>(), mapUserNew); //Method to insert Delegated Public group record
    }
	/* End */
	
	/*
        @MethodName        : onAfterUpdate
        @param             : Map<Id, User> mapUserOld, Map<Id,User> mapUserNew
        @Description       : This function will be called after update of the User Records to update Delegate_public_group_c  
    */
    public void onAfterUpdate(Map<Id, User> mapUserOld, Map<Id,User> mapUserNew)
    {
    	createDelegatePublicGroup(mapUserOld, mapUserNew); //Method to Update Delegate Public Group record
    }
	/* End */
	
	/*
        @MethodName        : createDelegatePublicGroup
        @param             : Map<Id, User> mapUserOld, Map<Id,User> mapUserNew
        @Description       : This function will be called after insert of the User Records to create Delegate_public_group_c  
    */
    private void createDelegatePublicGroup(Map<Id, User> mapUserOld, Map<Id,User> mapUserNew)
    {
    	List<Delegate_Public_Group__c> lstDelegatePublicGroupToInsert = new List<Delegate_Public_Group__c>(); //List of the Delegated Public Group
		Set<Id> setUserId = new Set<Id>();// set of user id to avoid to create Delegate_Public_Group__c records if already have corresponing to the user.
		for(Delegate_Public_Group__c objDPG : [SELECT Id, 
													  Banker__c 
											     FROM Delegate_Public_Group__c 
											    WHERE Banker__c IN: mapUserNew.keySet()])
		{
			setUserId.add(objDPG.Banker__c);
		}
		
    	for(User objUser : mapUserNew.values())
    	{   
    		//performs check to check Has Delegated is checked or unchecked
    		if(!setUserId.contains(objUser.Id) && objUser.Has_Delegates__c && mapUserOld.containsKey(objUser.Id) && mapUserOld.get(objUser.Id).Has_Delegates__c != objUser.Has_Delegates__c)
    		{
    			lstDelegatePublicGroupToInsert.add(new Delegate_Public_Group__c(Banker__c = objUser.Id));
    		}
    		else if(!setUserId.contains(objUser.Id) && objUser.Has_Delegates__c && !mapUserOld.containsKey(objUser.Id))
    		{
    			lstDelegatePublicGroupToInsert.add(new Delegate_Public_Group__c(Banker__c = objUser.Id));
    		}
    	}
    	
    	//Insert the Delegated Public Group Record
    	if(!lstDelegatePublicGroupToInsert.isEmpty())
	    	insert lstDelegatePublicGroupToInsert;
    }
    /* End */
    
}