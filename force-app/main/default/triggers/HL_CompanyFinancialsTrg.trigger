trigger HL_CompanyFinancialsTrg on Company_Financial__c (after insert, after delete, after update) {
    Set<Id> accIds = new Set<Id>();
    List<Account> accsToUpdate = new List<Account>();
	
    if(Trigger.isInsert || Trigger.isUpdate){
    	for (Company_Financial__c cf : Trigger.new)
        accIds.add(cf.Company__c);   
    }

    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Company_Financial__c cf : Trigger.old)
            accIds.add(cf.Company__c);
    }

    // get a map of the Accounts
    Map<id,Account> accMap = new Map<id,Account>([SELECT id, Most_Recent_Company_Financial__c FROM Account WHERE id IN :accIds]);

    // query the Accounts and the Company Financials and add the most recent one based on ASC Year
    for (Account acc : [SELECT Id, Name, Most_Recent_Company_Financial__c,(SELECT Id from Company_Financials__r ORDER BY Year__c ASC LIMIT 1 ) FROM Account WHERE Id IN :accIds]) {
        if(acc.Company_Financials__r.size() == 0){
            accMap.get(acc.Id).Most_Recent_Company_Financial__c = null;
        }
        else{
        	accMap.get(acc.Id).Most_Recent_Company_Financial__c = acc.Company_Financials__r[0].Id;
        }
        accsToUpdate.add(accMap.get(acc.Id));
    }

    update accsToUpdate;

}