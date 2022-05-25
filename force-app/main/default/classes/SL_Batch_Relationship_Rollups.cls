/**  
* \arg ClassName      : SL_Batch_Relationship_Rollups
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 28/MAY/2014
* \arg LastModifiedOn : 6/NOV/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Batch class to Relationship fields rollup.
*/
global with sharing class SL_Batch_Relationship_Rollups implements Database.Batchable<sObject> 
{
	/* Start Variables */
    private String query;
	/* End Variables */
	
	/* Start Constructor */
	global SL_Batch_Relationship_Rollups()
	{
		this('SELECT Id, HL_Contact__c, HL_Contact__r.User__c, External_Contact__c, Last_Activity_Date__c, '
                       +'Next_Activity_Date__c, Number_of_Activities_LTM__c, Number_of_Deals_on_Client_External_Team__c, Number_of_Deals_Shown__c, '
                       +'Share_Active_Deal__c, Share_Open_Opp__c FROM Relationship__c');
	}

    global SL_Batch_Relationship_Rollups(String query){
       this.query = query; 
    }

	/* End Constructor */
	
	/*
        @MethodName : start.
        @param 		: Database.BatchableContext 
        @Description: This function is used to set the query to fetch the records
    */
	global Database.QueryLocator start(Database.BatchableContext BC) 
    {
    	return Database.getQueryLocator(query);
    }
    /* End */
    
    /*
        @MethodName : execute.
        @param 		: Database.BatchableContext and List of Event.
        @Description: This function will roll up fields of Relationship records.
    */
    global void execute(Database.BatchableContext BC, List<Relationship__c> lstRelationship)  
    {
        SL_Relationship_Update updater = new SL_Relationship_Update(lstRelationship);
        updater.calculateAllFields();
        updater.updateAll();
    }
    /* End */

    /*
        @MethodName : finish.
        @param 		: Database.BatchableContext .
        @Description: do nothing
    */
    global void finish(Database.BatchableContext BC)
    {
    	
    }
    /* End */
}