public with sharing class HL_EngagementAllocationHandler {
    private boolean IsExecuting = false;
    private integer BatchSize = 0;

    public HL_EngagementAllocationHandler(boolean executing, integer size){
        IsExecuting = executing;
        BatchSize = size;
    }


    //When creating a new EngagementAllocation record
    public void OnBeforeInsert(List<Engagement_Allocation__c> newEngagementAllocationList){
    
    Set<Id> setEngagement = new Set<Id>();
    Map<Id,Engagement__c> mapEngagement;
    
    for(Engagement_Allocation__c objEngagementAllocation : newEngagementAllocationList)
    {
        setEngagement.add(objEngagementAllocation.Engagement__c);
    }
    
    if(setEngagement != null && setEngagement.size() > 0)
    {
        mapEngagement = new Map<Id,Engagement__c>([select id,Line_of_Business__c from Engagement__c where id in :setEngagement]);
        if(mapEngagement != null && mapEngagement.size() > 0)
        {
            for(Engagement_Allocation__c objEngagementAllocation : newEngagementAllocationList)
            {
                if(mapEngagement.get(objEngagementAllocation.Engagement__c) != null)
                {
                    objEngagementAllocation.Line_of_Business__c = mapEngagement.get(objEngagementAllocation.Engagement__c).Line_of_Business__c;
                }
            }
        }
    }
    
        
    }

    //Manage EngagementAllocation Sharing Rules
    public void OnAfterInsert(Map<Id, Engagement_Allocation__c> newEngagementAllocationMap){
        //We want Non-Administrative Comments
          
        Set<Id> engIds = new Set<Id>();
        for(Engagement_Allocation__c ec : newEngagementAllocationMap.values())
        {
            engIds.add(ec.Engagement__c);
        }
        // Commmon methods is written in all the Sharingobjects/Related objects of Engagement 
        SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(newEngagementAllocationMap.values(), 'Engagement_Allocation__c');
        UpdateEngagement(engIds);
    }


  
   // public void OnBeforeUpdate(Map<Id, Engagement_Allocation__c> newEngagementAllocationMap , Map<Id, Engagement_Allocation__c> oldEngagementAllocationMap){
        
   // }

    //Update Engagement Record Values from Revenue Accrual changes
   // public void OnAfterUpdate(Map<Id, Engagement_Allocation__c> newEngagementAllocationMap , Map<Id, Engagement_Allocation__c> oldEngagementAllocationMap){
        
   // }
   
   //Update the last comment fields back on the engagement
    private void UpdateEngagement(Set<Id> engIdSet)
    {
        List<Engagement__c> engsToUpdate = new List<Engagement__c>();
        

        for(Engagement__c e : [SELECT id,Engagement_Allocation_Insertfield__c FROM Engagement__c WHERE Id IN: engIdSet])
        {
            e.Engagement_Allocation_Insertfield__c = 'Test1';
            
            engsToUpdate.add(e);          
        }

        if(engsToUpdate.size() > 0 && HL_TriggerContextUtility.isFirstRun())
            update engsToUpdate;
    }

    

    public class ApplicationException extends Exception {}
    }