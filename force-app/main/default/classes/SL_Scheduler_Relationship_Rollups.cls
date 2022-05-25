/**  
* \arg ClassName      : SL_Scheduler_Relationship_Rollups
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 30/MAY/2014
* \arg LastModifiedOn : 25/June/2018
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Kavi Patel
* \arg Description    : Scheduler class to schedule the Batch Relationship fields rollup.
*/
global with sharing class SL_Scheduler_Relationship_Rollups implements Schedulable
{
    /* Start - Variables */
    /* End - Variables */
    
    /* Start - Constructor */
    global SL_Scheduler_Relationship_Rollups()
    {
        //do nothing.
    }
    /* End - Constructor */
    /*
        @MethodName : execute.
        @param      : SchedulableContext
        @Description: This Class calls Batch class
    */
    global void execute(SchedulableContext sc)
    {
        try
        {
            // An instance of a SL_Batch_Relationship_Rollups Class created  
            SL_Batch_Relationship_Rollups objBatch = new SL_Batch_Relationship_Rollups();
            
            // Database.executeBatch method called to begin a batch job.
            Database.executeBatch(objBatch, 40);
            
        }
        catch(Exception e)
        {
            //Show exception in debug logs if any
            System.debug('### Exception: ' + e);
        }
        
    }
    /* End */
}