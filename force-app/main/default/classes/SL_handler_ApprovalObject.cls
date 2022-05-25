/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The validation trigger handler
 * \see https://silverline.jira.com/browse/HL-92
 */
public with sharing class SL_handler_ApprovalObject {

	public void OnBeforeInsert( List<Approval_Object__c> records ) {
    	this.validate( records );
    }

    public void OnBeforeUpdate( Map<ID, Approval_Object__c> recordsOld, Map<ID, Approval_Object__c> recordsNew ) {
    	this.validate( recordsNew.values() );
    }

    // --- VALIDATION --- //

    private void validate( List<Approval_Object__c> records ) {
    	for ( Approval_Object__c record : records ) {
    		if ( !SL_Describe.isExisting( record.Base_Object__c ) ) {
    			record.Base_Object__c.addError( record.Base_Object__c + ' object does not exist.' );
    		}
    		if ( String.isNotBlank( record.Master_Detail_Field__c ) ) {
    			if ( !SL_Describe.isExisting( record.Base_Object__c, record.Master_Detail_Field__c ) ) {
    				record.Master_Detail_Field__c.addError( getFieldError( record.Base_Object__c, record.Master_Detail_Field__c ) );
    			}
            }
    	}
    }

    public static String getFieldError( String sObjectName, String fieldName ) {
    	return 'The ' + ( SL_Describe.isExisting( sObjectName ) ? SL_Describe.getLabel( sObjectName ) : sObjectName ) + ' object has no ' + fieldName + ' field';
    }
}