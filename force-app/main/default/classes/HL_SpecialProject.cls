public with sharing class HL_SpecialProject {
	public static List<Special_Project__c> GetAll()
	{
		return [SELECT Name, Location_Group__c, Is_Billable__c, Require_Comments__c FROM Special_Project__c WHERE Is_Active__c = true ORDER BY Name];
	}

	public static List<Special_Project__c> GetByRecordTypeId(Id recordTypeId)
	{
		return [SELECT Name, Location_Group__c, Is_Billable__c, Require_Comments__c FROM Special_Project__c WHERE RecordTypeId =: recordTypeId AND Is_Active__c = true ORDER BY Name];
	}
}