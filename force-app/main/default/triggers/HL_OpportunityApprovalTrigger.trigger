trigger HL_OpportunityApprovalTrigger on Opportunity_Approval__c (before insert, before update, after insert, after update) {
    
        if(Trigger.IsInsert && trigger.isbefore)
        { 
            //Get Map of Subject Id with Related Transaction Text (including when Client)
            Map<Id, String> cse = HL_OpportunityApprovalHandler.GetRelatedTransactionData(Trigger.New, True);
            //Get Map of Subject Id with Related Transaction Text (subject only)
            Map<Id, String> se = HL_OpportunityApprovalHandler.GetRelatedTransactionData(Trigger.New, True);
            //Assign the Related Transaction (Previous Transaction) Text
            for(Opportunity_Approval__c oa : Trigger.New)
            {
                if(oa.Job_Type__c == 'Buyside') //For Buyside we want to include client engagements
                    oa.Previous_Transactions__c = cse.get(oa.Subject_Company_ID__c);
                else
                    oa.Previous_Transactions__c = se.get(oa.Subject_Company_ID__c);
            }
            
            HL_OpportunityApprovalHandler.UpdatevaluesforInsert(Trigger.New);
        }
        
        if((Trigger.IsInsert && trigger.isbefore) || (Trigger.IsUpdate && trigger.isbefore)){
            HL_OpportunityApprovalHandler.UpdateFormApproved(Trigger.New);    
            //HL_OpportunityApprovalHandler.updateestimatedtransactionsize(Trigger.New);   
        }
        
        if((Trigger.IsInsert && trigger.isafter) || (Trigger.IsUpdate && trigger.isafter)){
            //HL_OpportunityApprovalHandler.Updatevalues_afterInsertupdate(Trigger.New); 
            system.debug('test===');
        }
        
        if(Trigger.IsUpdate && trigger.isbefore){
            //Added by Shruthi on 4th Dec 2021
            HL_OpportunityApprovalHandler handler1= new HL_OpportunityApprovalHandler();
            handler1.SubmitReviewCancel(trigger.new);
        }
    
}