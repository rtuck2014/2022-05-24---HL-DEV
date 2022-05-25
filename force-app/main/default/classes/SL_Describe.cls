/**
 * \author Vladimir Dobrelya
 * \date Dec 4, 2014
 * \brief The high-level class of the describe logic
 * \see https://silverline.jira.com/browse/LIB-271
 * \see Schema.SObjectType [ https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_class_Schema_SObjectType.htm ]
 * \see Schema.SObjectField [ https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_class_Schema_SObjectField.htm ]
 * \see Schema.DescribeSObjectResult - [ https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_sobject_describe.htm ]
 * \see Schema.DescribeFieldResult - [ https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_fields_describe.htm ]
 */
public with sharing class SL_Describe {
	
	// getToken
	public static Schema.SObjectType getToken( String sObjectName ) {
		return SL_DescribeTokens.get( sObjectName );
	}

	public static Schema.SObjectField getToken( String sObjectName, String fieldName ) {
		return SL_DescribeTokens.get( sObjectName, fieldName );
	}

	public static Schema.SObjectField getToken( Schema.SObjectType objectToken, String fieldName ) {
		return SL_DescribeTokens.get( objectToken, fieldName );
	}

	// getDescribe
	public static Schema.DescribeSObjectResult getDescribe( String sObjectName ) {
		return SL_DescribeResults.get( sObjectName );
	}

	public static Schema.DescribeFieldResult getDescribe( String sObjectName, String fieldName ) {
		return SL_DescribeResults.get( sObjectName, fieldName );
	}

	public static Schema.DescribeSObjectResult getDescribe( Schema.SObjectType objectToken ) {
		return SL_DescribeResults.get( objectToken );
	}

	public static Schema.DescribeFieldResult getDescribe( Schema.SObjectType objectToken, String fieldName ) {
		return  SL_DescribeResults.get( objectToken, fieldName );
	}

	public static Schema.DescribeFieldResult getDescribe( Schema.SObjectField fieldToken ) {
		return SL_DescribeResults.get( fieldToken );
	}

	// isExisting
	public static Boolean isExisting( String sObjectName ) {
		return SL_DescribeTokens.isExisting( sObjectName );
	}

	public static Boolean isExisting( String sObjectName, String fieldName ) {
		return SL_DescribeTokens.isExisting( sObjectName, fieldName );
	}

	public static Boolean isExisting( Schema.SObjectType objectToken, String fieldName ) {
		return SL_DescribeTokens.isExisting( objectToken, fieldName );
	}

	public static Boolean isExisting( Schema.SObjectType objectToken ) {
		return objectToken != null;
	}

	public static Boolean isExisting( Schema.SObjectField fieldToken ) {
		return fieldToken != null;
	}

	// isAccessible
	public static Boolean isAccessible( String sObjectName ) {
		return isAccessible( getToken( sObjectName ) );
	}

	public static Boolean isAccessible( Schema.SObjectType objectToken ) {
		return isExisting( objectToken ) && getDescribe( objectToken ).isAccessible();
	}

	public static Boolean isAccessible( String sObjectName, String fieldName ) {
		return isAccessible( getToken( sObjectName, fieldName ) );
	}

	public static Boolean isAccessible( Schema.SObjectType objectToken, String fieldName ) {
		return isAccessible( getToken( objectToken, fieldName ) );
	}

	public static Boolean isAccessible( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) && getDescribe( fieldToken ).isAccessible();
	}

	// isUpdateable
	public static Boolean isUpdateable( String sObjectName ) {
		return isUpdateable( getToken( sObjectName ) );
	}

	public static Boolean isUpdateable( Schema.SObjectType objectToken ) {
		return isExisting( objectToken ) && getDescribe( objectToken ).isUpdateable();
	}

	public static Boolean isUpdateable( String sObjectName, String fieldName ) {
		return isUpdateable( getToken( sObjectName, fieldName ) );
	}

	public static Boolean isUpdateable( Schema.SObjectType objectToken, String fieldName ) {
		return isUpdateable( getToken( objectToken, fieldName ) );
	}

	public static Boolean isUpdateable( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) && getDescribe( fieldToken ).isUpdateable();
	}

	// isDeletable
	public static Boolean isDeletable( String sObjectName ) {
		return isDeletable( getToken( sObjectName ) );
	}

	public static Boolean isDeletable( Schema.SObjectType objectToken ) {
		return isExisting( objectToken ) && getDescribe( objectToken ).isDeletable();
	}

	// isSortable
	public static Boolean isSortable( String sObjectName, String fieldName ) {
		return isSortable( getToken( sObjectName, fieldName ) );
	}

	public static Boolean isSortable( Schema.SObjectType objectToken, String fieldName ) {
		return isSortable( getToken( objectToken, fieldName ) );
	}

	public static Boolean isSortable( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) && getDescribe( fieldToken ).isSortable();
	}

	// isFilterable
	public static Boolean isFilterable( String sObjectName, String fieldName ) {
		return isFilterable( getToken( sObjectName, fieldName ) );
	}

	public static Boolean isFilterable( Schema.SObjectType objectToken, String fieldName ) {
		return isFilterable( getToken( objectToken, fieldName ) );
	}

	public static Boolean isFilterable( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) && getDescribe( fieldToken ).isFilterable();
	}

	// isReference
	public static Boolean isReference( String sObjectName, String fieldName ) {
		return isReference( getToken( sObjectName, fieldName ) );
	}

	public static Boolean isReference( Schema.SObjectType objectToken, String fieldName ) {
		return isReference( getToken( objectToken, fieldName ) );
	}

	public static Boolean isReference( Schema.SObjectField fieldToken ) {
		return getType( fieldToken ) == DisplayType.REFERENCE;
	}

	// isRequired
	public static Boolean isRequired( String sObjectName, String fieldName ) {
		return isRequired( getToken( sObjectName, fieldName ) );
	}

	public static Boolean isRequired( Schema.SObjectType objectToken, String fieldName ) {
		return isRequired( getToken( objectToken, fieldName ) );
	}

	public static Boolean isRequired( Schema.SObjectField fieldToken ) {
		Schema.DescribeFieldResult fieldDescribe = getDescribe( fieldToken );
		if ( fieldDescribe == null ) {
			return false;
		}
		return fieldDescribe.isCreateable() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate();
	}

	// getType
	public static Schema.DisplayType getType( String sObjectName, String fieldName ) {
		return getType( getToken( sObjectName, fieldName ) );
	}

	public static Schema.DisplayType getType( Schema.SObjectType objectToken, String fieldName ) {
		return getType( getToken( objectToken, fieldName ) );
	}

	public static Schema.DisplayType getType( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) ? getDescribe( fieldToken ).getType() : null;
	}

	// getRelationshipName
	public static String getRelationshipName( String sObjectName, String fieldName ) {
		return getRelationshipName( getToken( sObjectName, fieldName ) );
	}

	public static String getRelationshipName( Schema.SObjectType objectToken, String fieldName ) {
		return getRelationshipName( getToken( objectToken, fieldName ) );
	}

	public static String getRelationshipName( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) ? getDescribe( fieldToken ).getRelationshipName() : null;
	}

	// getReferenceTo
	public static Schema.SObjectType getReferenceTo( String sObjectName, String fieldName ) {
		return getReferenceTo( getToken( sObjectName, fieldName ) );
	}

	public static Schema.SObjectType getReferenceTo( Schema.SObjectType objectToken, String fieldName ) {
		return getReferenceTo( getToken( objectToken, fieldName ) );
	}

	public static Schema.SObjectType getReferenceTo( Schema.SObjectField fieldToken ) {
		if ( isReference( fieldToken ) ) {
			for ( Schema.SObjectType objectType : getDescribe( fieldToken ).getReferenceTo() ) {
				return objectType;
			}
		}
		return null;
	}

	public static String getLabel( String sObjectName ) {
		return getLabel( getToken( sObjectName ) );
	}

	public static String getLabel( Schema.SObjectType objectToken ) {
		return isExisting( objectToken ) ? getDescribe( objectToken ).getLabel() : null;
	}

	public static String getLabel( String sObjectName, String fieldName ) {
		return getLabel( getToken( sObjectName, fieldName ) );
	}

	public static String getLabel( Schema.SObjectType objectToken, String fieldName ) {
		return getLabel( getToken( objectToken, fieldName ) );
	}

	public static String getLabel( Schema.SObjectField fieldToken ) {
		return isExisting( fieldToken ) ? getDescribe( fieldToken ).getLabel() : null;
	}

	// use for the fields with dot notation like: Field1__r.Field2__r.Field__c
    public static Boolean isExisting( String sObjectName, String fieldName, Boolean dotNotation ) {
        if ( dotNotation ) {
            return validateFieldName( sObjectName, fieldName ) == null; 
        }
        return SL_DescribeTokens.isExisting( sObjectName, fieldName );
    }

    public static String validateFieldName( String sObjectName, String fieldName ) {
    	return validateFieldName( sObjectName, fieldName.split( '\\.' ) ); 
    }

    public static String validateFieldName( String sObjectName, String fieldName, String errorFormat ) {
    	return validateFieldName( sObjectName, fieldName.split( '\\.' ), errorFormat ); 
    }

    public static String validateFieldName( String sObjectName, List<String> fieldParts ) {
    	return validateFieldName( sObjectName, fieldParts, null ); 
    }

    public static String validateFieldName( String sObjectName, List<String> fieldParts, String errorFormat ) {
        if ( !isExisting( sObjectName ) ) {
        	return 'Invalid object name: ' + sObjectName;
        }
        if ( fieldParts == null || fieldParts.isEmpty() ) {
            return 'Invalid fieldParts: ' + fieldParts;
        }
        if ( String.isBlank( errorFormat ) ) {
    		errorFormat = 'The {0} object has no {1} field.';
    	}
        
        String curObjectName = sObjectName, curFieldName = null, referenceTo = sObjectName; // referenceTo is used for exception building

        for ( String fieldPart : fieldParts ) {
        	if ( referenceTo == null ) {
        		return String.format( 'The {0} object has no {1} field with REFERENCE type.', new List<String>{ curObjectName, curFieldName } );
        	}
        	curObjectName = referenceTo;
            curFieldName = getFieldNameByRelationshipName( curObjectName, fieldPart );
            if ( !isExisting( curObjectName, curFieldName ) ) { // when Field1__c.Field2__c.Field__c
	           return String.format( errorFormat, new List<String>{ curObjectName, curFieldName } );
	        }
            referenceTo = String.valueOf( getReferenceTo( curObjectName, curFieldName ) );
        }
        return null;
    }

    public static String getFieldNameByRelationshipName( String sObjectName, String relationshipFieldName ) {
        if ( String.isBlank( relationshipFieldName ) ) {
            return null;
        }

        if ( !relationshipFieldName.endsWithIgnoreCase( '__c' ) ) {
            if ( relationshipFieldName.endsWithIgnoreCase( '__r' ) && isExisting( sObjectName, relationshipFieldName.substring( 0, relationshipFieldName.length() - 3 ) + '__c' ) ) {
            	relationshipFieldName = relationshipFieldName.substring( 0, relationshipFieldName.length() - 3 ) + '__c';
                //relationshipFieldName = relationshipFieldName.replace( '__r', '__c' );
            } else if ( !relationshipFieldName.endsWithIgnoreCase( 'id' ) && isExisting( sObjectName, relationshipFieldName + 'Id' ) ) {
                relationshipFieldName = relationshipFieldName + 'Id';
            }
        }
        return relationshipFieldName;
    }

	/*public static String getRelationshipFieldName( String sObjectName, String relatedTo ) {
		if ( isExisting( sObjectName ) && isExisting( relatedTo ) ) {
			for ( Schema.ChildRelationship relationship : getDescribe( relatedTo ).getChildRelationships() ) {
			    if ( String.valueOf( relationship.getChildSObject() ).equalsIgnoreCase( sObjectName ) ) {
			        return String.valueOf( relationship.getField() ).toLowerCase();
			    }
			}
		}
		return null;
	}*/
}