global class InternalNotesEmailHandler implements Messaging.InboundEmailHandler{
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String body=email.plainTextBody;
        String refId,note;
        System.debug('received:'+body);
        
        if(body.containsIgnoreCase('<refid>')){
          refId=body.substring((body.indexOfIgnoreCase('<refid>')+7),body.indexOfIgnoreCase('</refId>'));
    	    note=body.substring((body.indexOfIgnoreCase('<note>')+6),body.indexOfIgnoreCase('</note>'));
          System.debug('refId:'+refId);
          upsert new Activity_Supplement__c(Activity__c = refId,Sync_Description__c = note) Activity__c;
        }
        result.success=true;
		    return result;
    }
}