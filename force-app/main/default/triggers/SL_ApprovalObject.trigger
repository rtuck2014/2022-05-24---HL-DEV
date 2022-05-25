/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The validation trigger
 * \see https://silverline.jira.com/browse/HL-92
 */
trigger SL_ApprovalObject on Approval_Object__c ( before insert, before update ) {
	SL_handler_ApprovalObject handler = new SL_handler_ApprovalObject();

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