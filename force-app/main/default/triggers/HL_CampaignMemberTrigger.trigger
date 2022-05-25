trigger HL_CampaignMemberTrigger on CampaignMember (before update, before delete, after insert, after update) {
   if(Trigger.isAfter)
   {
         if(Trigger.IsInsert)
         {
                if(!System.IsFuture() && !System.IsBatch())
                {
                    Set<Id> setCamMemIds = new Set<Id>();
                    integer count = 0;
                    for(CampaignMember objCamMember : Trigger.New)
                    {
                        count++;
                        setCamMemIds.add(objCamMember.Id);
                        
                        if(count == 4 && setCamMemIds.size() == 4)
                        {
                            HL_CampaignMemberHandler.SynchronizeParentCampaignMembers(setCamMemIds);
                            
                            //reset values for next chunk
                            count = 0;
                            setCamMemIds.clear();
                        }
                    
                   }
                    // initiate remaining Campaign Members
                    if(setCamMemIds.size() > 0)
                        HL_CampaignMemberHandler.SynchronizeParentCampaignMembers(setCamMemIds);
                    
           
                }
         }
         else if(Trigger.IsUpdate)
         {
                if(!System.IsFuture() && !System.IsBatch())
                {
                    HL_CampaignMemberHandlerBatch obj = new HL_CampaignMemberHandlerBatch(Trigger.newMap.keySet());
                    database.executebatch(obj, 5);
                }
         }
             
        system.debug('???????  ' +Trigger.newMap.size());
   }

    //Audit Tracking
    if(Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsDelete) &&
            HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Audit_Campaign_Member))
    {
        HL_AuditRecordHandler auditHandler = new HL_AuditRecordHandler(SObjectType.CampaignMember.getSobjectType());
        auditHandler.RecordAudit(Trigger.oldMap, Trigger.newMap);
    }
  }