/**  
* \arg ClassName      : SL_Scheduler_Stamp_InternalTeam
* \arg JIRATicket     : HL-91
* \arg CreatedOn      : 20/JAN/2015
* \arg LastModifiedOn : 20/JAN/2015
* \arg CreatededBy    : GM
* \arg ModifiedBy     : -
* \arg Description    : Scheduler class to schedule the Batch Stamp Internal Teams
*/
global with sharing class SL_Scheduler_Stamp_InternalTeam implements Schedulable
{
    /* Start - Variables */
    /* End - Variables */
    
    /* Start - Constructor */
    global SL_Scheduler_Stamp_InternalTeam()
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
        //Initiate 2 instances of batch job, 1 for Opportunity Internal Team and other for 
        System.debug('\n\nIn Schedule: ');
        try
        {            
            //Engagement Internal Team.            
            
            String oitQuery = HL_PercentageSplitHandler.GetCreatableFieldsSOQL('Opportunity_Internal_Team__c');
            oitQuery = oitQuery + ' WHERE Invalid_Office_LOB__c=\'true\'';
            SL_Batch_StampInternalTeam batch = new SL_Batch_StampInternalTeam(oitQuery);
            Database.executeBatch(batch, 200);                        
        }
        catch(Exception e)
        {
            //Show exception in debug logs if any
            System.debug('\n\n### OIT Batch job Exception: ' + e);
        }
        try
        {            
            //Engagement Internal Team.                        
            String eitQuery = HL_PercentageSplitHandler.GetCreatableFieldsSOQL('Engagement_Internal_Team__c');
            eitQuery = eitQuery + ' WHERE Invalid_Office_LOB__c=\'true\'';
            
            SL_Batch_StampInternalTeam batch = new SL_Batch_StampInternalTeam(eitQuery);
            Database.executeBatch(batch, 200);                        
        }
        catch(Exception e)
        {
            //Show exception in debug logs if any
            System.debug('\n\n### EIT Batch job Exception: ' + e);
        }
        
    }
    /* End */
}