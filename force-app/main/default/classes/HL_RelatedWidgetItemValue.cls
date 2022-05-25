global with sharing class HL_RelatedWidgetItemValue {
    @AuraEnabled
    global String fieldName { get; set; }

	@AuraEnabled
	global String label { get; set; }

	@AuraEnabled
	global String value { get; set; }

	global HL_RelatedWidgetItemValue(String fieldName, String label) {
        this.fieldName = fieldName;
		this.label = label;
	}

	global HL_RelatedWidgetItemValue(String fieldName, String label, String value) {
        this.fieldName = fieldName;
		this.label = label;
        this.value = value;
	}
}