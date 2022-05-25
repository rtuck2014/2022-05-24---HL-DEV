public with sharing class HL_CoverageTeam {
	public HL_CoverageTeam() {}

	public static Map<Id, Coverage_Team__c> GetCoverageTeams(Set<Id> ids){
		return new Map<Id, Coverage_Team__c>([SELECT Officer__c, Officer__r.Name, Company__r.BillingCity, Company__r.BillingState, Company__r.BillingCountry, Company__r.CapIQ_Company__r.Name, Company__r.CapIQ_Company__r.Equity_Investment_From__c, Company__r.CapIQ_Company__r.Equity_Investment_To__c, Company__r.CapIQ_Company__r.Most_Recent_Fund_Size_MM__c, Company__r.CapIQ_Company__r.City__c, Company__r.CapIQ_Company__r.State__c, Company__r.CapIQ_Company__c FROM Coverage_Team__c WHERE Id In:ids]);
	}
}