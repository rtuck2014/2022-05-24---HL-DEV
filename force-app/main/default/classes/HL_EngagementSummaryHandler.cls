public with sharing class HL_EngagementSummaryHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isBeforeInsertFlag = false;
    public static Boolean isBeforeUpdateFlag = false;

    public HL_EngagementSummaryHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    public void recordvalidations(List<Engagement_Summary__c> newRecords)
    {
        for(Engagement_Summary__c oa:newRecords)
        {
            //Ratcher FROM and TO amounts mandatory when respective percentage field non empty
        	if(oa.First_Ratchet_Percent__c!=null && oa.First_Ratchet_From_Amount__c==null)    
            	oa.First_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
            if(oa.First_Ratchet_Percent__c!=null &&  oa.First_Ratchet_To_Amount__c==null)    
                oa.First_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation);
            if(oa.Second_Ratchet_Percent__c!=null && oa.Second_Ratchet_From_Amount__c==null)
                oa.Second_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
            if(oa.Second_Ratchet_Percent__c!=null && oa.Second_Ratchet_To_Amount__c==null)
                oa.Second_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation); 
            if(oa.Third_Ratchet_Percent__c!=null && oa.Third_Ratchet_From_Amount__c==null)
                oa.Third_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
            if(oa.Third_Ratchet_Percent__c!=null && oa.Third_Ratchet_To_Amount__c==null)
                oa.Third_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation); 
            if(oa.Fourth_Ratchet_Percent__c!=null && oa.Fourth_Ratchet_From_Amount__c==null)
                oa.Fourth_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
            if(oa.Fourth_Ratchet_Percent__c!=null && oa.Fourth_Ratchet_To_Amount__c==null)
                oa.Fourth_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation);
            if(oa.Final_Ratchet_Percent__c!=null && oa.Final_Ratchet_Amount__c==null)
                oa.Final_Ratchet_Amount__c.addError(Label.Ratchet_Validation);
            //Ratcher validation for TO amount 
            if(oa.First_Ratchet_To_Amount__c <= oa.First_Ratchet_From_Amount__c)
                oa.First_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
            if(oa.Second_Ratchet_To_Amount__c <= oa.Second_Ratchet_From_Amount__c)
                oa.Second_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
            if(oa.Third_Ratchet_To_Amount__c <= oa.Third_Ratchet_From_Amount__c)
                oa.Third_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
            if(oa.Fourth_Ratchet_To_Amount__c <= oa.Fourth_Ratchet_From_Amount__c)
                oa.Fourth_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
        }      
    }
    
    public void OnBeforeUpdate(List<Engagement_Summary__c> newRecords){
        if(!isBeforeUpdateFlag){
            isBeforeUpdateFlag = true;
            CalculateMetrics(newRecords);
        }
    }
      
    public void OnBeforeInsert(List<Engagement_Summary__c> newRecords){
        if(!isBeforeInsertFlag){            
            isBeforeInsertFlag = true;
            CalculateMetrics(newRecords);
        }
    }
    
    private void CalculateMetrics(List<Engagement_Summary__c> esList){
        Engagement_Summary__c esCurrent;
        //Map of Engagement Id to Engagement Summary
        Map<Id,Engagement_Summary__c> esMap = new Map<Id, Engagement_Summary__c>();
        //We want the ones without the Marketing Overrides
        for(Engagement_Summary__c es : esList){
            if(es.Use_Marketing_Overrides__c == 'No'){
                es.Contacted_Strategic_Domestic__c = es.Contacted_Strategic_International__c = es.Contacted_Financial_Total__c = 0;
                es.Books_Sent_Strategic_Domestic__c = es.Books_Sent_Strategic_International__c = es.Books_Sent_Financial_Total__c = 0;
                es.Prelim_Bids_Strategic_Domestic__c = es.Prelim_Bids_Strategic_International__c = es.Prelim_Bids_Financial_Total__c = 0;
                es.Presentations_Strategic_Domestic__c = es.Presentations_Strategic_International__c = es.Presentations_Financial_Total__c = 0;
                es.Final_Bids_Strategic_Domestic__c = es.Final_Bids_Strategic_International__c = es.Final_Bids_Financial_Total__c = 0;
                esMap.put(es.Engagement__c, es);
            }
        }    
        //Get the Counterparty Metrics
        for(List<Engagement_Counterparty__c> ecList : [SELECT Engagement__c, Type__c, Initial_Contact__c, Sent_Book__c, Received_Book__c, Proposal_Indication__c, Met_With_Management__c, Letter_of_Intent__c, Company_Country__c FROM Engagement_Counterparty__c WHERE Engagement__c In : esMap.keySet()])
        {
            for(Engagement_Counterparty__c ec : ecList){
                esCurrent = esMap.get(ec.Engagement__c);
                if(ec.Type__c == 'Strategic'){
                     //Modified condition for State/Country picklist changes
                     if(ec.Company_Country__c == 'United States' || ec.Company_Country__c == 'USA' || ec.Company_Country__c == 'US'){
                        if(ec.Initial_Contact__c <> null)
                            esCurrent.Contacted_Strategic_Domestic__c += 1;
                        if(ec.Sent_Book__c <> null || ec.Received_Book__c <> null)
                            esCurrent.Books_Sent_Strategic_Domestic__c += 1;
                        if(ec.Proposal_Indication__c <> null)
                            esCurrent.Prelim_Bids_Strategic_Domestic__c += 1;
                        if(ec.Met_With_Management__c <> null)
                            esCurrent.Presentations_Strategic_Domestic__c += 1;
                        if(ec.Letter_of_Intent__c <> null)
                            esCurrent.Final_Bids_Strategic_Domestic__c += 1;
                    }
                    else{
                        if(ec.Initial_Contact__c <> null)
                            esCurrent.Contacted_Strategic_International__c += 1;
                        if(ec.Sent_Book__c <> null || ec.Received_Book__c <> null)
                            esCurrent.Books_Sent_Strategic_International__c += 1;
                        if(ec.Proposal_Indication__c <> null)
                            esCurrent.Prelim_Bids_Strategic_International__c += 1;
                        if(ec.Met_With_Management__c <> null)
                            esCurrent.Presentations_Strategic_International__c += 1;
                        if(ec.Letter_of_Intent__c <> null)
                            esCurrent.Final_Bids_Strategic_International__c += 1;
                    }
                }
                else if(ec.Type__c == 'Financial'){
                   if(ec.Initial_Contact__c <> null)
                        esCurrent.Contacted_Financial_Total__c += 1;
                   if(ec.Sent_Book__c <> null || ec.Received_Book__c <> null)
                        esCurrent.Books_Sent_Financial_Total__c += 1;
                   if(ec.Proposal_Indication__c <> null)
                        esCurrent.Prelim_Bids_Financial_Total__c += 1;
                   if(ec.Met_With_Management__c <> null)
                        esCurrent.Presentations_Financial_Total__c += 1;
                   if(ec.Letter_of_Intent__c <> null)
                        esCurrent.Final_Bids_Financial_Total__c += 1;
                }   
                esMap.put(esCurrent.Engagement__c, esCurrent);
            }
        }  
    }
}