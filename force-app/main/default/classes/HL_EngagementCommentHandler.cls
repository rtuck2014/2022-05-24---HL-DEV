public with sharing class HL_EngagementCommentHandler {
	 /* start - global variables*/
    public static boolean isTest = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* stop - global variables*/
    
    /* start - constructor */     
    public HL_EngagementCommentHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void onAfterUpdate(Map<Id, Engagement_Comment__c> oldMap, Map<Id, Engagement_Comment__c> newMap){
        Set<Id> engIds = new Set<Id>();
        //Only handle comments where the comment or comment type has changed
        for(Id ecId : newMap.keySet())
        {
          if(oldMap.get(ecId).Comment__c != newMap.get(ecId).Comment__c || oldMap.get(ecId).Comment_Type__c != newMap.get(ecId).Comment_Type__c)
             engIds.add(newMap.get(ecId).Engagement__c);
        }

        UpdateLastComments(engIds);
    }

    public void onAfterInsert(Map<Id, Engagement_Comment__c> mapNewEngagementComments){
    	//We want Non-Administrative Comments
    	List<Engagement_Comment__c> nonAdminComments = new List<Engagement_Comment__c>();     
        Set<Id> engIds = new Set<Id>();
    	for(Engagement_Comment__c ec : mapNewEngagementComments.values())
    	{
            engIds.add(ec.Engagement__c);
    		if(ec.Comment_Type__c <> 'Administrative' && ec.Comment_Type__c <> 'Compliance')
    			nonAdminComments.add(ec);
    	}
        SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(nonAdminComments, 'Engagement_Comment__c');  
        UpdateLastComments(engIds);
    }


    //Update the last comment fields back on the engagement, if needed, when records are deleted
    public void onAfterDelete(Map<Id, Engagement_Comment__c> oldMap){
        Set<Id> engIds = new Set<Id>();
        for(Engagement_Comment__c ec : oldMap.values())
            engIds.add(ec.Engagement__c);
        UpdateLastComments(engIds);
    }

    //Update the last comment fields back on the engagement
    private void UpdateLastComments(Set<Id> engIdSet)
    {
        List<Engagement__c> engsToUpdate = new List<Engagement__c>();
        Integer nonAdminIndex;

        for(Engagement__c e : [SELECT Engagement_Comment__c, Last_Engagement_Comment_Part_1__c, Last_Engagement_Comment_Part_2__c, Last_Engagement_Comment_Part_3__c, Last_Engagement_Comment_Part_4__c, Last_Engagement_Comment_Any_Part_1__c, Last_Engagement_Comment_Any_Part_2__c, Last_Engagement_Comment_Any_Part_3__c, Last_Engagement_Comment_Any_Part_4__c, (SELECT Comment__c, Comment_Type__c, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, Opp_Comment_Creator__c, Opp_Comment_Create_Date__c FROM Engagement_Comments__r WHERE Include_In_Latest_Comment__c =: true ORDER BY CreatedDate DESC) FROM Engagement__c WHERE Id IN: engIdSet])
        {
            if(e.Engagement_Comments__r.size() != 0)
            {
                //Our Goal Here is To Find the Earliest Non Admin Comment
                //Because we need to be sure both the Last Comment field sets (4 each) are updated properly
                nonAdminIndex = -1;
                for(Integer i = 0; i < e.Engagement_Comments__r.size(); i++)
                {
                    if(e.Engagement_Comments__r[i].Comment_Type__c != 'Administrative' && e.Engagement_Comments__r[i].Comment_Type__c != 'Compliance'){
                        nonAdminIndex = i;
                        break;
                    }
                }
                if(nonAdminIndex > 0)
                    HL_EngagementHandler.FormatLastComment(e, e.Engagement_Comments__r[nonAdminIndex], true);
                
                HL_EngagementHandler.FormatLastComment(e, e.Engagement_Comments__r[0], nonAdminIndex == 0);
                if(nonAdminIndex == -1)
                    e.Last_Engagement_Comment_Part_1__c = e.Last_Engagement_Comment_Part_2__c = e.Last_Engagement_Comment_Part_3__c = e.Last_Engagement_Comment_Part_4__c = '';
            }
            else //Clear the Last Comment Fields
                e.Last_Engagement_Comment_Part_1__c = e.Last_Engagement_Comment_Part_2__c = e.Last_Engagement_Comment_Part_3__c = e.Last_Engagement_Comment_Part_4__c = e.Last_Engagement_Comment_Any_Part_1__c = e.Last_Engagement_Comment_Any_Part_2__c = e.Last_Engagement_Comment_Any_Part_3__c = e.Last_Engagement_Comment_Any_Part_4__c = '';
            
            engsToUpdate.add(e);          
        }

        if(engsToUpdate.size() > 0 && HL_TriggerContextUtility.isFirstRun())
            update engsToUpdate;
    }
}