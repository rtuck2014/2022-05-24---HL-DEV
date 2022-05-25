/**
*  Trigger Name   : SL_EngagementCounterparty
*  JIRATicket     : HL-66
*  CreatedOn      : 19/JAN/2015
*  ModifiedBy     : 
*  Description    : Trigger used to add Counterparty Contacts from Opportunity Counterparty to Engagement Counterparty
*/
trigger SL_EngagementCounterparty on Engagement_Counterparty__c (after insert) 
{
    //Creating instance of handler class.
    SL_EngagementCounterpartyHandler objEC = new SL_EngagementCounterpartyHandler(Trigger.isExecuting, Trigger.size);
    
    //If trigger is after insert
    if(Trigger.isAfter && Trigger.isInsert)
        objEC.onAfterInsert(Trigger.newMap);
}
/* End */