/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The validation trigger
 * \see https://silverline.jira.com/browse/HL-53
 */
trigger SL_ApprovalProperty on Approval_Properties__c ( before insert, before update ) {
	SL_handler_ApprovalProperty handler = new SL_handler_ApprovalProperty();

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