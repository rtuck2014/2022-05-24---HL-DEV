/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The validation trigger
 * \see https://silverline.jira.com/browse/HL-53
 */
trigger SL_ApprovalSection on Approval_Section__c ( before insert, before update ) {
	SL_handler_ApprovalSection handler = new SL_handler_ApprovalSection();

	if ( trigger.IsInsert ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeInsert( Trigger.new );
        }
    } else if ( trigger.IsUpdate ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeUpdate( Trigger.oldMap, Trigger.newMap );
        }
    }
}