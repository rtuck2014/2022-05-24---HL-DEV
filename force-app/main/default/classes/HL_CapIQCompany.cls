public with sharing class HL_CapIQCompany {
	public HL_CapIQCompany() {}

	public static CapIQ_Company__c GetById(Id id){
		List<CapIQ_Company__c> companies = [SELECT City__c, Equity_Investment_From__c, Equity_Investment_To__c, State__c FROM CapIQ_Company__c WHERE Id =: id];
		return companies.size() > 0 ? companies[0] : new CapIQ_Company__c();
	}
}