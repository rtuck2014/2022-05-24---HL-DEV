/**  
* \arg JIRATicket     : HL-43
* \arg CreatedOn      : 13/JAN/2015
* \arg LastModifiedOn : 13/JAN/2015
* \arg CreatededBy    : GM
* \arg ModifiedBy     : -
* \arg Description    : Scheduler class to schedule the Batch Percent Split Calulations. 
*/
global with sharing class SL_Scheduler_PercentageSplit implements Schedulable
{
    /* Start - Variables */
    /* End - Variables */
    
    /* Start - Constructor */
    global SL_Scheduler_PercentageSplit()
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
            // An instance of a SL_Batch_PercentageSplit Class created  
            SL_Batch_PercentageSplit objBatch = new SL_Batch_PercentageSplit();
            System.debug('\n\nSchedule Job');
            // Database.executeBatch method called to begin a batch job.
            Database.executeBatch(objBatch, 200); 
            
        }
        catch(Exception e)
        {
            //Show exception in debug logs if any
            System.debug('### Exception: ' + e);
        }
        
    }
    /* End */
}