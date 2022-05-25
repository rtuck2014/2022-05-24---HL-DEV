/**
*  Trigger Name   : SL_Opportunity
*  JIRATicket     : HL-11
*  CreatedOn      : 21/April/2014
*  ModifiedBy     : Prakash
*  Description    : Trigger used to create or update or delete 'Opportunity_Client_Subject__c' Joiner object records 
					when 'Client_c' or 'subject_c' fields on 'Opportunity__c' object has updated.
*/
trigger SL_Opportunity on Opportunity__c (after insert, after update) 
{
	
}