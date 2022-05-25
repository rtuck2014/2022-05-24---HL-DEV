public with sharing class HL_Industry {
	public HL_Industry() {}

	public static List<Industry__c> GetAllActiveFS(){
		return [SELECT Id FROM Industry__c WHERE Active__c = true AND FSC__c = true];
	}
}