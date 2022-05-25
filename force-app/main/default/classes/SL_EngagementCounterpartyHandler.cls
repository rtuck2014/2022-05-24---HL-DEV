/**
*  ClassName      : SL_EngagementCounterpartyHandler
*  JIRATicket     : HL-11
*  CreatedOn      : 21/April/2014
*  ModifiedBy     : Edward Rivera
*  Description    : Handler class for SL_EngagementCounterparty to create counterparty contact records
*/
public with sharing class SL_EngagementCounterpartyHandler {
    /* start - global variables*/
    public static boolean isTest = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* stop - global variables*/
    
    /* start - constructor */     
    public SL_EngagementCounterpartyHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /*
        * MethodName        : onAfterInsert
        * param             : Map <Id, Engagement__c> newEngagementCounterparties
        * Description       : This function will be called to copy any opportunity counterparty contacts as ECCs
    */
    public void onAfterInsert(Map <Id, Engagement_Counterparty__c> newEngagementCounterparties){
   // this generates counterparty contacts for this new engagement counterparty if its associated Engagement
   // has an associated Opportunity or Engagement
   if(HL_ConstantsUtil.AllowExecutionForManualInsertEngCounterparty)
       SL_EngagementConversionHelper.createEngagementCounterpartyContacts(newEngagementCounterparties);
   
   //this hadles Counterparties bulk adding to Engagement with @Future Method
   if(newEngagementCounterparties.size() <= 40){
     //Calling method to create manual sharing for Engagement_Counterparty__c if added records less than 40
       SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(newEngagementCounterparties.values(), 'Engagement_Counterparty__c');
   }
   else{
      // Calling method to create manual sharing for Engagement_Counterparty__c through @Future Method if added records more than 40
       String JsonString = JSON.serialize(newEngagementCounterparties.values());
       SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRulesFuture(JsonString, 'Engagement_Counterparty__c');
   }
       
}  
}