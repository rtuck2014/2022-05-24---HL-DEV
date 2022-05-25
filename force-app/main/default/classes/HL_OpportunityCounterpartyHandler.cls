public with sharing class HL_OpportunityCounterpartyHandler {
	private List<Opportunity_Counterparty__c> OpportunityCounterparties {get; set;}
	public HL_OpportunityCounterpartyHandler(List<Opportunity_Counterparty__c> opportunityCounterparties) {
		this.OpportunityCounterparties = opportunityCounterparties;
	}

    public void onAfterInsert(List<Opportunity_Counterparty__c> ocList){
        Set<Id> acctSet = new Set<Id>();
        for(Opportunity_Counterparty__c ocs : ocList) {
            acctSet.add(ocs.Company__c);
        }
        IndicateCounterparty(acctSet);
    }
    
    public void onAfterUpdate(List<Opportunity_Counterparty__c> oldOCList, Map<Id,Opportunity_Counterparty__c> newOCMap){
        Set<Id> acctSet = new Set<Id>();
        for (Opportunity_Counterparty__c ocs : oldOCList) {
             Opportunity_Counterparty__c newOCs = newOCMAP.get(ocs.id);   
            if(ocs.Company__c <> newOCs.Company__c){
                acctSet.add(ocs.Company__c);
                acctSet.add(newOCs.Company__c);
            }
        }
        IndicateCounterparty(acctSet);
    }
    
    public void onAfterDelete(List<Opportunity_Counterparty__c> ocList){
        Set<Id> acctSet = new Set<Id>();
        for(Opportunity_Counterparty__c ocs : ocList) {
            acctSet.add(ocs.Company__c);
        }
        IndicateCounterparty(acctSet);
    }
    
    public void onAfterUndelete(List<Opportunity_Counterparty__c> ocList){
        Set<Id> acctSet = new Set<Id>();
        for(Opportunity_Counterparty__c ocs : ocList) {
            acctSet.add(ocs.Company__c);
        }
        IndicateCounterparty(acctSet);
    }

	public List<Opportunity_Counterparty_Comment__c> InsertCounterpartyComments(){
         List<Opportunity_Counterparty_Comment__c> commentList = new List<Opportunity_Counterparty_Comment__c>();
         for(Opportunity_Counterparty__c ocp: OpportunityCounterparties){
            //Check to see if the new comment has a value or not
            if(!String.isBlank(ocp.Opportunity_Counterparty_Comment__c)){
                //If a value is found, create a new Opportunity_Comments Object
                commentList.add(new Opportunity_Counterparty_Comment__c(
                	Comment__c = ocp.Opportunity_Counterparty_Comment__c,
                	Comment_Type__c = 'Internal',
                	Line_of_Business__c = 'CF',
                	Related_Opportunity_Counterparty__c = ocp.Id
                ));
                
                //Remove the value for the new comments field so it is never saved to the object and will be blank the next time Pipeline Manager is displayed
                ocp.Opportunity_Counterparty_Comment__c = null;
             }      
         }
         if(commentList.size() > 0)
         	insert commentList;

         return commentList;
     }
    
    //Assign the Coverage Officer (if exists)
    public List<Opportunity_Counterparty__c> UpdateDefaultFields(){
        Set<Id> accounts = new Set<Id>();
        Map<Id, Id> coverageMap = new Map<Id, Id>();
        for(Opportunity_Counterparty__c oc : OpportunityCounterparties)
            accounts.add(oc.Company__c);  
        
        //Get the accounts
        for(Account a : [SELECT Primary_Coverage_Officer__c, Ultimate_Parent__c FROM Account WHERE Id IN:accounts]){
            if(!String.isBlank(a.Primary_Coverage_Officer__c))
                coverageMap.put(a.Id, a.Primary_Coverage_Officer__c);
        }

        for(Opportunity_Counterparty__c oc : OpportunityCounterparties)
            oc.Coverage_Officer__c = coverageMap.get(oc.Company__c);

        return  OpportunityCounterparties;
    }

    public void IndicateCounterparty(Set<Id> opportunityCounterpartySet){
        List<Account> updateAcctList = new List<Account>();      
        for(Account account : [SELECT Id, (SELECT Id FROM Opportunity_Counterparties__r LIMIT 1), (SELECT Id FROM Engagement_Counterparties__r LIMIT 1) FROM Account WHERE Id IN : opportunityCounterpartySet]) {
            account.CounterParty__c = (account.Opportunity_Counterparties__r.size() > 0 || account.Engagement_Counterparties__r.size() > 0) ? true : false;
            updateAcctList.add(account);
        }
        update updateAcctList;
    }
}