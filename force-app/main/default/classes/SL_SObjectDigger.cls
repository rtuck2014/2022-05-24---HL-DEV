/**
 * \author Vladimir Dobrelya
 * \date Nov 26, 2014
 * \see https://silverline.jira.com/browse/HL-61
 * \brief The simple class to get a field value like: (SObject:Opportunity_Approval__c).Related_Opportunity__r.Client__r.Name
 * \using SL_SObjectDigger.get( opportunityApproval, 'Related_Opportunity__r.Client__r.Name' );
 */
public class SL_SObjectDigger {

    public static Object get( SObject obj, String field ) {
        return get( obj, field.split( '\\.' ) );
    }

    public static Object get( SObject obj, List<String> fieldParts ) {
        Object result = obj;

        for ( String fieldPart : fieldParts ) {
            result = getQuietly( (SObject)result, fieldPart );
            
            if ( result == null ) {
	    		return null;
	    	}
        }
        return result;
    }

    private static Object getQuietly( SObject obj, String fieldPart ) {
    	if ( obj == null ) {
    		return null;
    	}

        try {
            return obj.getSObject( fieldPart );
        } catch ( Exception e ) { }

        return obj.get( fieldPart );
    }
}