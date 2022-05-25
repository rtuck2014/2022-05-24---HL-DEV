/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The validation trigger handler
 * \see https://silverline.jira.com/browse/HL-53
 */
public with sharing class SL_handler_ApprovalSection {
		
	public void OnBeforeInsert( List<Approval_Section__c> records ) {
    	this.validate( records );
    }

    public void OnBeforeUpdate( Map<ID, Approval_Section__c> recordsOld, Map<ID, Approval_Section__c> recordsNew ) {
    	this.validate( recordsNew.values(), recordsOld );
    }

    // --- VALIDATION --- //

    private void validate( List<Approval_Section__c> records ) {
    	this.validate( records, null );
    }

    private void validate( List<Approval_Section__c> records, Map<ID, Approval_Section__c> recordsOld ) {
    	Map<ID, List<Approval_Properties__c>> properties;
    	if ( recordsOld != null ) {
    		properties = this.getProperties( records );
    	}
    	String message;

        Map<ID, String> baseObjects = this.getBaseObjectsByPageId( records );

    	for ( Approval_Section__c record : records ) {
    		if ( recordsOld != null && properties.containsKey( record.Id )  ) { // child properties check
                if ( ( message = this.validateProperties( record.Object_API_Name__c, properties.get( record.Id ) ) ) != null ) {
    				record.Object_API_Name__c.addError( message );
    			}
	    	}

    		if ( !SL_Describe.isExisting( record.Object_API_Name__c ) ) {
    			record.Object_API_Name__c.addError( this.getObjectError( record.Object_API_Name__c ) );
    		}

            if ( record.RecordTypeId == relatedListRecordTypeId ) {
                if ( String.isBlank( record.Relationship_Field__c ) ) {
                    record.Relationship_Field__c.addError( 'This field is required if the section is Related List' );
                } else {  
                    if ( !SL_Describe.isReference( record.Object_API_Name__c, record.Relationship_Field__c ) ) {
                        record.Relationship_Field__c.addError( 'The ' + record.Object_API_Name__c + ' object has no ' + record.Relationship_Field__c + ' field with REFERENCE type.' );
                    }
                }
            }

            if ( String.isNotBlank( record.Parent_Relationship_Field__c ) ) {
                if ( !record.Parent_Relationship_Field__c.contains( '.' ) ) {
                    if ( !SL_Describe.isReference( baseObjects.get( record.Approval_Page__c ), record.Parent_Relationship_Field__c ) ) {
                        record.Parent_Relationship_Field__c.addError( 'The ' + baseObjects.get( record.Approval_Page__c ) + ' object has no ' + record.Parent_Relationship_Field__c + ' field with REFERENCE type.' );
                    }
                } else {
                    String exceptionMessage = SL_Describe.validateFieldName( baseObjects.get( record.Approval_Page__c ), record.Parent_Relationship_Field__c );
                    if ( exceptionMessage != null ) {
                        record.Parent_Relationship_Field__c.addError( exceptionMessage );
                    }
                }
            }
    	}
    }

    // --- HL-92 - Parent_Relationship_Field__c validation fix ---
    private Map<ID, String> getBaseObjectsByPageId( List<Approval_Section__c> sections ) {
        Map<ID, String> result = new Map<ID, String>();
        for ( Approval_Page__c page : this.getPagesWithBaseObject( sections ).values() ) {
            result.put( page.Id, page.Approval_Object__r.Base_Object__c );
        }
        return result;
    }

    private Map<ID, Approval_Page__c> getPagesWithBaseObject( List<Approval_Section__c> sections ) {
        return this.getPagesWithBaseObject( this.getPageIdsWithParentRelationshipField( sections ) );
    }

    private Set<ID> getPageIdsWithParentRelationshipField( List<Approval_Section__c> sections ) {
        Set<ID> result = new Set<ID>();
        for ( Approval_Section__c section : sections ) {
            if ( section.Parent_Relationship_Field__c != null ) {
                result.add( section.Approval_Page__c );
            }
        }
        return result;
    }

    private Map<ID, Approval_Page__c> getPagesWithBaseObject( Set<ID> pageIds ) {
        if ( pageIds.isEmpty() ) {
            return new Map<ID, Approval_Page__c>();
        }
        return new Map<ID, Approval_Page__c>( [ SELECT Id, Approval_Object__r.Base_Object__c FROM Approval_Page__c WHERE Id IN :pageIds ] );
    }
    // --- //

    private Map<ID, List<Approval_Properties__c>> getProperties( List<Approval_Section__c> sections ) {
    	Map<ID, List<Approval_Properties__c>> result = new Map<ID, List<Approval_Properties__c>>();
    	for ( Approval_Properties__c property : [ SELECT Name, Section__c, Field_API_Name__c FROM Approval_Properties__c WHERE Field_API_Name__c != null AND Section__c IN :sections ] ) {
    		if ( !result.containsKey( property.Section__c ) ) {
    			result.put( property.Section__c, new List<Approval_Properties__c>() );
    		}
    		result.get( property.Section__c ).add( property );
    	}
    	return result;
    }

    private String validateProperties( String sObjectName, List<Approval_Properties__c> properties ) {
    	for ( Approval_Properties__c property : properties ) {
    		if ( !SL_Describe.isExisting( sObjectName, property.Field_API_Name__c ) ) {
    			return property.Name + ' property has incorrect Field_API_Name__c(' + property.Field_API_Name__c + ') for the ' + sObjectName + ' object.';
    		}
    	}
    	return null;
    }

    private String getObjectError( String sObjectName ) {
    	return 'The ' + sObjectName + ' object does not exist.';
    }

    private ID relatedListRecordTypeId {
        get {
            if ( relatedListRecordTypeId == null ) {
                for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Approval_Section__c' AND DeveloperName = 'Related_List' ] ) {
                    relatedListRecordTypeId = record.Id;
                }
            }
            return relatedListRecordTypeId;
        } set;
    }
}