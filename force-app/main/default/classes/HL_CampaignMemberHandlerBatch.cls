global class HL_CampaignMemberHandlerBatch implements Database.Batchable<sObject>
{
    Set<Id> campaignMembers = new Set<Id>();
    
    global HL_CampaignMemberHandlerBatch (Set<Id> parmCampaignMembers)
    {
        this.campaignMembers = parmCampaignMembers;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([select Id from CampaignMember where Id =: campaignMembers]);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> lstCampaignMemberParam) 
    {
    
    system.debug('?????????' +lstCampaignMemberParam);
    
      string STANDARD_SELECT = 'SELECT CampaignId, LeadId, ContactId, Status, HasResponded, Campaign.ParentId, Response_Comments__c, Response_Method__c, Speaker_Panelist__c, Guest__c, CPE__c, Requested_By_1__c, Requested_By_2__c, Requested_By_3__c, Requested_By_4__c, Requested_By_5__c ';

        Set<Id> campaignMembers = new Set<Id>();
        
        for(CampaignMember objCamMem : lstCampaignMemberParam)
        {   
            campaignMembers.add(objCamMem.Id);
        }
        
        Set<Id> parentIds = new Set<Id>(); 
        //Store all the Parent Campaign IDs into a Set List
        for(CampaignMember cm : [Select Campaign.ParentId From CampaignMember WHERE Id IN :campaignMembers AND Campaign.ParentId != null AND Campaign.Parent.RecordType.DeveloperName <> 'Parent_Campaign'])
            parentIds.add(cm.Campaign.ParentId);
            
        List<CampaignMember> LstCampaignMember = Database.Query(STANDARD_SELECT + 'FROM CampaignMember WHERE Id IN :campaignMembers');
            
        List<CampaignMember> lstCampaignMemberByCampaignId = Database.Query(STANDARD_SELECT + 'FROM CampaignMember WHERE CampaignId in : parentIds');
        Map<Id,List<CampaignMember>> mapParentwithCampaigns = new Map<Id,List<CampaignMember>>();
        
        for(CampaignMember objCampMem : lstCampaignMemberByCampaignId)
        {
            if(mapParentwithCampaigns.get(objCampMem.CampaignId) != null)
            {
                List<CampaignMember> lstCampMem = mapParentwithCampaigns.get(objCampMem.CampaignId);
                lstCampMem.add(objCampMem);
                mapParentwithCampaigns.put(objCampMem.CampaignId,lstCampMem);
            }
            else
            {
                List<CampaignMember> lstCampMem = new List<CampaignMember>();
                lstCampMem.add(objCampMem);
                mapParentwithCampaigns.put(objCampMem.CampaignId,lstCampMem);
            }
        }
        
        if(parentIds.size() > 0)
        {
            //Get a List of Parent Campaigns with their Associated Campaign Members
            for(Id parent : parentIds)
            {
                CampaignMember existingCampaignMember;
                List<CampaignMember> parentCampaignMemberList, campaignMembersToInsert = New List<CampaignMember>(), campaignMembersToUpdate = new List<CampaignMember>();   
                Map<String, Boolean> statusMap = new Map<String, Boolean>();
                Map<Id, CampaignMember> parentCampaignMembers = new Map<Id, CampaignMember>();
                
                //Create a Map of Parent Campaigns with their Associated Campaign Members
                //for (CampaignMember c : Database.Query(STANDARD_SELECT + 'FROM CampaignMember WHERE CampaignId =: parent'))
                //    parentCampaignMembers.put(c.Id, c);
                
                parentCampaignMemberList = mapParentwithCampaigns.get(parent) != null ? mapParentwithCampaigns.get(parent) : new List<CampaignMember>()  ; //parentCampaignMembers.values();
                
                //Find which Campaign Members we need to insert
                for (CampaignMember cm : LstCampaignMember){
                    if(statusMap.get(cm.Campaign.ParentId + '_' + cm.Status) == null)
                        statusMap.put(cm.Campaign.ParentId + '_' + cm.Status, cm.HasResponded);
                    
                    //Convert the Parent Campaign Member List to a Map
                    Map<Id, CampaignMember> campaignContactMemberMap = new Map<Id, CampaignMember>();
                    Map<Id, CampaignMember> campaignLeadMemberMap = New Map<Id, CampaignMember>();
                    for(CampaignMember c : parentCampaignMemberList){
                        if(c.ContactId != null)
                            campaignContactMemberMap.put(c.ContactId, c);
                        else
                            campaignLeadMemberMap.put(c.LeadId, c);
                    }
                    //Find if the Map Contains the Contact Id Being Inserted
                    existingCampaignMember = campaignContactMemberMap.get(cm.ContactId);
                    if(existingCampaignMember == null)
                        existingCampaignMember = campaignLeadMemberMap.get(cm.LeadId);
                    
                    if(existingCampaignMember == null){
                        campaignMembersToInsert.Add(New CampaignMember(CampaignId=cm.Campaign.ParentId, LeadId=cm.LeadId, ContactId=cm.ContactId, Status=cm.Status, Response_Comments__c = cm.Response_Comments__c, Response_Method__c = cm.Response_Method__c, Recent_Campaign__c = cm.CampaignId,
                                                                       Speaker_Panelist__c = cm.Speaker_Panelist__c, Guest__c = cm.Guest__c, CPE__c = cm.CPE__c, Requested_By_1__c = cm.Requested_By_1__c, Requested_By_2__c = cm.Requested_By_2__c, Requested_By_3__c = cm.Requested_By_3__c, Requested_By_4__c = cm.Requested_By_4__c, Requested_By_5__c = cm.Requested_By_5__c));            
                    }
                    else{
                        if(!String.isBlank(cm.Response_Method__c))
                            existingCampaignMember.Response_Method__c = cm.Response_Method__c;
                        if(!String.isBlank(cm.Status))
                            existingCampaignMember.Status = cm.Status;   
                        //These boolean fields should only be copied to parent if set to true
                        if(cm.Speaker_Panelist__c)
                            existingCampaignMember.Speaker_Panelist__c = true;
                        if(cm.Guest__c)
                            existingCampaignMember.Guest__c = true;
                        if(cm.CPE__c)
                            existingCampaignMember.CPE__c = true;
                        
                        existingCampaignMember.Recent_Campaign__c = cm.CampaignId;
                        
                        if(!String.isBlank(cm.Response_Comments__c))
                            existingCampaignMember.Response_Comments__c = (!String.isBlank(existingCampaignMember.Response_Comments__c) ? existingCampaignMember.Response_Comments__c + '\r\n' : '') 
                            + (String.isBlank(existingCampaignMember.Response_Comments__c) ? cm.Response_Comments__c : !existingCampaignMember.Response_Comments__c.contains(cm.Response_Comments__c) ? cm.Response_Comments__c : '');
                                              
                        AssignRequestedByFields(cm, existingCampaignMember);
                        
                        campaignMembersToUpdate.Add(existingCampaignMember);
                    }
                }
                
                if(campaignMembersToInsert.Size() > 0){
                    //Insert missing CampaignMemberStatus Records
                    if(statusMap.Size() > 0)
                        InsertMissingCampaignStatusRecords(statusMap, campaignMembersToInsert);
                    //Insert new CampaignMember Records to the Parent Campaign
                    database.insert(campaignMembersToInsert,false);
                }
                
                if(campaignMembersToUpdate.Size() > 0){
                    //Insert missing CampaignMemberStatus Records
                    if(statusMap.Size() > 0)
                        InsertMissingCampaignStatusRecords(statusMap, campaignMembersToUpdate);
                    //Update Campaign Member Status Records
                    update campaignMembersToUpdate;  
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    global void AssignRequestedByFields(CampaignMember cm, CampaignMember existingCampaignMember){
        Boolean hasResponse1, hasResponse2, hasResponse3, hasResponse4, hasResponse5;
        Set<Id> currentResponses, existingResponses;
        hasResponse1 = !String.isBlank(existingCampaignMember.Requested_By_1__c);
        hasResponse2 = !String.isBlank(existingCampaignMember.Requested_By_2__c);
        hasResponse3 = !String.isBlank(existingCampaignMember.Requested_By_3__c);
        hasResponse4 = !String.isBlank(existingCampaignMember.Requested_By_4__c);
        hasResponse5 = !String.isBlank(existingCampaignMember.Requested_By_5__c);
        existingResponses = new Set<Id>{existingCampaignMember.Requested_By_1__c, 
            existingCampaignMember.Requested_By_2__c,
            existingCampaignMember.Requested_By_3__c,
            existingCampaignMember.Requested_By_4__c,
            existingCampaignMember.Requested_By_5__c};
                currentResponses = new Set<Id> {cm.Requested_By_1__c,
                    cm.Requested_By_2__c,
                    cm.Requested_By_3__c,
                    cm.Requested_By_4__c,
                    cm.Requested_By_5__c};
                        
                        for(Id cr : currentResponses){
                            if(!String.isBlank(cr) && !existingResponses.contains(cr))
                            {
                                if(!hasResponse1){
                                    existingCampaignMember.Requested_By_1__c = cr;
                                    hasResponse1 = true;
                                }
                                else if(!hasResponse2){
                                    existingCampaignMember.Requested_By_2__c = cr;
                                    hasResponse2 = true;
                                }
                                else if(!hasResponse3){
                                    existingCampaignMember.Requested_By_3__c = cr;
                                    hasResponse3 = true;
                                }
                                else if(!hasResponse4){
                                    existingCampaignMember.Requested_By_4__c = cr;
                                    hasResponse4 = true;
                                }
                                else if(!hasResponse5){
                                    existingCampaignMember.Requested_By_5__c = cr;
                                    hasResponse5 = true;
                                }
                            }
                        }
    }
    
    private void InsertMissingCampaignStatusRecords(Map<String, Boolean> originalStatusMap, List<CampaignMember> campaignMembers){
        AggregateResult[] groupedResults;
        List<String> campaigns = new List<String>();
        List<CampaignMemberStatus> existingStatusList;
        Map<String,String> existingStatusMap = new Map<String,String>();
        List<CampaignMemberStatus> statusInserts = new List<CampaignMemberStatus>();
        Integer maxSort;
        
        //Create list of Campaigns
        for(CampaignMember cm : campaignMembers)
            campaigns.Add(cm.CampaignId);
        
        existingStatusList = [SELECT Id, CampaignId, HasResponded, Label, SortOrder FROM CampaignMemberStatus WHERE CampaignId In:campaigns];
        //Find the Max SortOrder for creating a map by CampaignId so that we do not duplicate the Sort Order
        groupedResults = [Select CampaignId, MAX(SortOrder) maxSort FROM CampaignMemberStatus WHERE CampaignId In:campaigns GROUP BY CampaignId];
        
        //Store the Sort Order into a Map
        Map<String,Integer> campaignMaxSortOrders = new Map<String, Integer>();
        for(AggregateResult ar : groupedResults)
        {
            if(ar.get('maxSort') != null)
                campaignMaxSortOrders.put(String.valueOf(ar.get('CampaignId')), Integer.valueOf(ar.get('maxSort')));      
        }
        
        //Create Map of Existing Statuses with Campaign Ids
        for(CampaignMemberStatus cms : existingStatusList)
            existingStatusMap.put(cms.CampaignId + '_' + cms.Label, cms.Id);
        
        for(CampaignMember cm : campaignMembers){
            if(existingStatusMap.get(cm.CampaignId + '_' + cm.Status) == null){
                if(campaignMaxSortOrders.get(cm.CampaignId) != null){
                    maxSort = campaignMaxSortOrders.get(cm.CampaignId);
                    campaignMaxSortOrders.put(cm.CampaignId, maxSort + 1);
                }
                else
                {
                    maxSort = 0;
                    campaignMaxSortOrders.put(cm.CampaignId, 1);
                }
               
                           
                existingStatusMap.put(cm.CampaignId + '_' + cm.Status,'');
               if(!Test.isRunningTest()){
                 statusInserts.Add(New CampaignMemberStatus(CampaignId = cm.CampaignId, Label = cm.Status, SortOrder=maxSort+1, HasResponded = originalStatusMap.Get(cm.CampaignId + '_' + cm.Status)));
            }   
          }
        }
        if(statusInserts.Size() > 0)
            insert statusInserts;
    }
    
}