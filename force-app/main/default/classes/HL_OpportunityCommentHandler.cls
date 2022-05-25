public with sharing class HL_OpportunityCommentHandler {
	 /* start - global variables*/
    public static boolean isTest = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* stop - global variables*/
    
    /* start - constructor */     
    public HL_OpportunityCommentHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void onAfterUpdate(Map<Id, Opportunity_Comment__c> oldMap, Map<Id, Opportunity_Comment__c> newMap){
        Set<Id> oppIds = new Set<Id>();
        //Only handle comments where the comment or comment type has changed
        for(Id ocId : newMap.keySet())
        {
          if(oldMap.get(ocId).Comment__c != newMap.get(ocId).Comment__c || oldMap.get(ocId).Comment_Type__c != newMap.get(ocId).Comment_Type__c)
             oppIds.add(newMap.get(ocId).Related_Opportunity__c);
        }
        UpdateLastComments(oppIds);
    }

    public void onAfterInsert(Map<Id, Opportunity_Comment__c> mapNewOppComments){
    	//We want Non-Administrative Comments for Sharing Rules
    	List<Opportunity_Comment__c> nonAdminComments = new List<Opportunity_Comment__c>();
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity_Comment__c oc : mapNewOppComments.values())
    	{
            oppIds.add(oc.Related_Opportunity__c);
    		if(oc.Comment_Type__c <> 'Administrative' && oc.Comment_Type__c <> 'Compliance')
    			nonAdminComments.add(oc);
    	}
        SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(nonAdminComments, 'Opportunity_Comment__c'); 
        UpdateLastComments(oppIds);
    }

    //Update the last comment fields back on the opportunity, if needed, when records are deleted
    public void onAfterDelete(Map<Id, Opportunity_Comment__c> oldMap){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity_Comment__c oc : oldMap.values())
            oppIds.add(oc.Related_Opportunity__c);
        UpdateLastComments(oppIds);
    }

    //Update the last comment fields back on the opportunity
    private void UpdateLastComments(Set<Id> oppIdSet)
    {
        List<Opportunity__c> oppsToUpdate = new List<Opportunity__c>();
        Integer nonAdminIndex;
        for(Opportunity__c o : [SELECT Opportunity_Comments__c, Last_Opportunity_Comment_Part_1__c, Last_Opportunity_Comment_Part_2__c, Last_Opportunity_Comment_Part_3__c, Last_Opportunity_Comment_Part_4__c, Last_Opportunity_Comment_Any_Part_1__c, Last_Opportunity_Comment_Any_Part_2__c, Last_Opportunity_Comment_Any_Part_3__c, Last_Opportunity_Comment_Any_Part_4__c, (SELECT Comment__c, Comment_Type__c, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName FROM Opportunity_Comments__r WHERE Include_In_Latest_Comment__c =: true ORDER BY CreatedDate DESC) FROM Opportunity__c WHERE Id IN: oppIdSet])
        {
            if(o.Opportunity_Comments__r.size() != 0)
            {
                //Our Goal Here is To Find the Earliest Non Admin Comment
                //Because we need to be sure both the Last Comment field sets (4 each) are updated properly
                nonAdminIndex = -1;
                for(Integer i = 0; i < o.Opportunity_Comments__r.size(); i++)
                {
                    if(o.Opportunity_Comments__r[i].Comment_Type__c != 'Administrative' && o.Opportunity_Comments__r[i].Comment_Type__c != 'Compliance'){
                        nonAdminIndex = i;
                        break;
                    }
                }

                if(nonAdminIndex > 0)
                    HL_OpportunityHandler.FormatLastComment(o, o.Opportunity_Comments__r[nonAdminIndex], true);
                
                HL_OpportunityHandler.FormatLastComment(o, o.Opportunity_Comments__r[0], nonAdminIndex == 0);
                if(nonAdminIndex == -1)
                    o.Last_Opportunity_Comment_Part_1__c = o.Last_Opportunity_Comment_Part_2__c = o.Last_Opportunity_Comment_Part_3__c = o.Last_Opportunity_Comment_Part_4__c = '';
            }
            else //Clear the Last Comment Fields
                o.Last_Opportunity_Comment_Part_1__c = o.Last_Opportunity_Comment_Part_2__c = o.Last_Opportunity_Comment_Part_3__c = o.Last_Opportunity_Comment_Part_4__c = o.Last_Opportunity_Comment_Any_Part_1__c = o.Last_Opportunity_Comment_Any_Part_2__c = o.Last_Opportunity_Comment_Any_Part_3__c = o.Last_Opportunity_Comment_Any_Part_4__c = '';
            
            oppsToUpdate.add(o);          
        }

        if(oppsToUpdate.size() > 0 && HL_TriggerContextUtility.isFirstRun())
            update oppsToUpdate;
    }
}