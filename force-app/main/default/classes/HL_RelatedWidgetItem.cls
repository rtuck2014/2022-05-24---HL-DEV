global with sharing class HL_RelatedWidgetItem {
	@AuraEnabled
	global String recordId { get; set; }

	@AuraEnabled
	global String recordName { get; set; }

	@AuraEnabled
	global List<HL_RelatedWidgetItemValue> values { get; set; }

	global HL_RelatedWidgetItem(String recordId, String recordName) {
		this.recordId = recordId;
		this.recordName = recordName;
	}

	global void addValue(HL_RelatedWidgetItemValue newValue) {
		if (values == null) {
			values = new List<HL_RelatedWidgetItemValue>();
		}

		values.add(newValue);
	}
}