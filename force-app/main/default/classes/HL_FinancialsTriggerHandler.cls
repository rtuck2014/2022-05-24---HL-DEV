public class HL_FinancialsTriggerHandler 
{
    public void FinancialValidationsbeforeinsetandupdate(list<Financials__c> fin)
    {
        set<id> oppreviewids= new set<id>();
        map<id, Financials__c> mapfid = new map<id, Financials__c>();
        map<id, Financials__c> mapfinancerecords= new map<id, Financials__c>();
        
        for(Financials__c f: fin)
        {
            oppreviewids.add(f.Related_Approval__c ); 
            mapfid.put(f.id,f);
        }
        
        if(oppreviewids.size()>0)
        {
            list<Financials__c> financerecords=[select Related_Approval__c, Type__c, Year__c , id from Financials__c where Related_Approval__c in :oppreviewids];
            if(financerecords.size()>0)
            {
                for(Financials__c f: financerecords)
                {
					//if(!mapfid.containsKey(f.id))                    
                	mapfinancerecords.put(f.id, f);                    
                }
            }
            system.debug('mapfinancerecords.size()='+ mapfinancerecords.size());
        }
        
        if(mapfinancerecords.size()>0)
        {
            for(Financials__c f: fin)
            {
                for(Financials__c ff: mapfinancerecords.values())
                {                                        
                    if(ff.Related_Approval__c==f.Related_Approval__c && f.id!=ff.Id)
                    {
                        if(f.Year__c==ff.Year__c && f.Type__c==ff.Type__c)
                        {                                                                    
                            Trigger.new[0].addError('A record already exist with same Year and Type'); 
                        }
                    }                    
                }
            }
        }
    }
}