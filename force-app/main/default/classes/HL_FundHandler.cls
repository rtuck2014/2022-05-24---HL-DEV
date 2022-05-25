public class HL_FundHandler {
    public static void HandleLatestFlag(List<Fund__c> funds){
        //Create a Set of IDs for the Latest Flags
        Set<Id> lFunds = new Set<Id>();
        //Create a Map of Companies to the New/Update Size
        Map<Id,Decimal> companies = new Map<Id,Decimal>();
        for(Fund__c f:funds)
        {
            if(f.Latest__c){
                lFunds.add(f.Id);
                companies.put(f.CapIQ_Company__c,f.Size__c);        
            }         
        }

        //Remove the latest from any records that are marked as latest
        for(List<Fund__c> fToUpdate : [SELECT Id, Latest__c FROM Fund__c WHERE CapIQ_Company__c <> null AND CapIQ_Company__c IN:companies.keyset() AND Latest__c =:true And Id NOT IN:lFunds])
        {
            for(Fund__c f:fToUpdate)
                f.Latest__c = false;
            update fToUpdate;
        }
        //Get the Cap IQ Companies to Update the Most Recent Fund Size Field
        if(companies.size() > 0)
        {
        	for(List<CapIQ_Company__c> ccs : [SELECT Most_Recent_Fund_Size_MM__c FROM CapIQ_Company__c WHERE Id IN:companies.keySet()])
            {
                for(CapIQ_Company__c c: ccs)
                    c.Most_Recent_Fund_Size_MM__c = companies.get(c.Id);  
                
                if(ccs.size() > 0)
                    update ccs;
            }
        }
    }
}