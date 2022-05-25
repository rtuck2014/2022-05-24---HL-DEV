global with sharing class HL_RelatedWidgetRequest {
	@AuraEnabled
	global String recordId { get; set; }

	@AuraEnabled
	global String sObjectName { get; set; }
	
	@AuraEnabled
	global String objectApiName { get; set; }

	@AuraEnabled
	global String relationshipFieldApiName { get; set; }

    @AuraEnabled
    global String titleField { get; set; }

	@AuraEnabled
	global String fields { get; set; }

	@AuraEnabled
	global String whereClause { get; set; }

	@AuraEnabled
	global String orderByClause { get; set; }

	@AuraEnabled
	global Boolean hideEmpty { get; set; }
}