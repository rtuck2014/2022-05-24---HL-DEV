/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The validation trigger handler
 * \see https://silverline.jira.com/browse/HL-53
 */
public with sharing class SL_handler_ApprovalProperty {

	public void OnBeforeInsert( List<Approval_Properties__c> records ) {
    	this.validate( records );
    }

    public void OnBeforeUpdate( Map<ID, Approval_Properties__c> recordsOld, Map<ID, Approval_Properties__c> recordsNew ) {
    	this.validate( recordsNew.values() );
    }

    // --- VALIDATION --- //

    private void validate( List<Approval_Properties__c> records ) {
    	this.validate( this.getObjectName( records.get( 0 ) ), records );
    }

    private void validate( String sObjectName, List<Approval_Properties__c> records ) {
    	for ( Approval_Properties__c record : records ) {
            if ( String.isNotBlank( record.Field_API_Name__c ) && !SL_Describe.isExisting( sObjectName, record.Field_API_Name__c ) ) {
                record.Field_API_Name__c.addError( getFieldError( sObjectName, record.Field_API_Name__c ) );
            }
    	}
    }

    private String getObjectName( Approval_Properties__c record ) {
    	return [ SELECT Object_API_Name__c FROM Approval_Section__c WHERE Id = :record.Section__c limit 1 ].Object_API_Name__c;
    }

    public static String getFieldError( String sObjectName, String fieldName ) {
    	return 'The ' + sObjectName + ' object has no ' + fieldName + ' field';
    }

    public static String getFieldNotAccessibleError( String sObjectName, String fieldName ) {
    	return 'The ' + sObjectName + '.' + fieldName + ' field is not accessible';
    }
}