@isTest
private class SL_Test_OpportunityTrigger 
{
	@isTest 
	static void test_OpportunityTrigger() 
	{
		Account objClientAccount = new Account(Name='Test Client Account');
		insert objClientAccount;
		
		Account objClientAccountToUpdate = new Account(Name='Test Client Account');
		insert objClientAccountToUpdate;

		Account objSubjectAccount = new Account(Name='Test Subject Account');
		insert objSubjectAccount;

		Opportunity__c objOpportunityNew = new Opportunity__c(Name='Test Opportunity', Client__c = objClientAccount.Id, 
															  Subject__c = objSubjectAccount.Id, Stage__c = 'Pitched',
															  Line_of_Business__c = 'CF', Job_Type__c = 'Financing',
															  Primary_Office__c = 'AT',Beneficial_Owner_Control_Person_form__c = 'No');
		insert objOpportunityNew;
		//check whether 2 client subject records are created
		system.AssertEquals([Select Id From Opportunity_Client_Subject__c where Opportunity__c = :objOpportunityNew.Id].Size(), 2);
		
		objOpportunityNew.Name = 'dndOpporutnity';
		objOpportunityNew.Client__c = objClientAccountToUpdate.Id;
		update objOpportunityNew; 

		// check whether the previous combination of joiner record is deleted, Now it should be deleted
		//system.AssertEquals([Select Id From Opportunity_Client_Subject__c where Opportunity__c = :objOpportunityNew.Id AND Client_Subject__c = :objClientAccount.Id].Size(), 0);
		// check whether the updated client Account is created in the Joiner
		//system.AssertEquals([Select Id From Opportunity_Client_Subject__c where Opportunity__c = :objOpportunityNew.Id].Size(), 2);
	}
		
}