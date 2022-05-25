public with sharing class HL_EngagementTitleRateSheet {
		public static List<Engagement_Title_Rate_Sheet__c> GetByEngagementId(Id id){
			return [SELECT Engagement__c,
										 Title_Rate_Sheet__c,
										 Title_Rate_Sheet__r.Name,
										 Engagement__r.Name,
										 Start_Date__c,
										 End_Date__c
					    FROM Engagement_Title_Rate_Sheet__c
					    WHERE Engagement__c =: id
					    ORDER BY Start_Date__c];
		}
}