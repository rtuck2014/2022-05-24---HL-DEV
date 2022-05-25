/********************************************************************
Modified: 11/04/2020
Author: Guru Sandhu
Change: Updated the AggregateResults query in AggregateLOBSplits method to query the results from Staffing_Details__c object instead of Engagement_Internal_Team__c.
ServiceNow Reference: DMND0024695

Modified: 01/21/2021
Author: Guru Sandhu
Change: Update the Aggregate Query to filter the staffing detail records to include records where "Is_Bad_Debt__c = false"
Method: AggregateLOBSplits
Ticket Reference : DMND0024924
******************************************************************* */
public without sharing class HL_PercentageSplitHandler {
    Map<String, Job_Type__c> mapJobTypeSplit {get; set;}
    
    //Get aggregate role counts per engagement, this is used to split the total percent per role
    private Map<String, Integer> GetRoleCountPerEngagement(List<Engagement_Internal_Team__c> team) {
        Map<String, Integer> count = new Map<String, Integer>();
        if (team != null && !team.isEmpty()) {
            for (Engagement_Internal_Team__c t : team) {
                if (t.Role__c != null) {
                    if (count.containsKey(t.Role__c)) {
                        if (t.Active_On_Engagement__c) {
                            Integer c = count.get(t.Role__c);
                            count.put(t.Role__c, ++c);
                        }
                    } else if (t.Active_On_Engagement__c) {
                        
                        count.put(t.Role__c, 1);
                    }
                }
            }
        }
        
        return count;
    }
    //Calculate the split per Member based on number of other members with same role.
    private List<Engagement_Internal_Team__c> CalculateStaffSplit(String jobType, List<Engagement_Internal_Team__c> team, Map<String, Integer> count) {
        
        Job_Type__c jt = mapJobTypeSplit.get(jobType);
        
        for (Engagement_Internal_Team__c t : team) {
            if (jt != null && t.Active_On_Engagement__c) {
                Decimal percent = t.Role__c == 'Analyst' ? jt.Role_Analyst_Percent__c : t.Role__c == 'Associate' ? jt.Role_Associate_Percent__c : t.Role__c == 'Initiator' ? jt.Role_Initiator_Percent__c : t.Role__c == 'Manager' ? jt.Role_Manager_Percent__c : t.Role__c == 'Principal' ? jt.Role_Principal_Percent__c : t.Role__c == 'Seller' ? jt.Role_Seller_Percent__c : 0;
                Integer roleCount = (count != null && count.containsKey(t.Role__c)) ? count.get(t.Role__c) : 1;
                t.Staff_Revenue_Split__c = (percent / roleCount);
            } else
                t.Staff_Revenue_Split__c = null;
            
        }
        
        return team;
    }
    
    private List<Engagement_Internal_Team__c> ProcessEngagement(Engagement__c e) {
        List<Engagement_Internal_Team__c> lst;
        if (e != null && e.Engagement_Teams__r != null && !e.Engagement_Teams__r.isEmpty()) {
            Map<String, Integer> countMap = GetRoleCountPerEngagement(e.Engagement_Teams__r);
            lst =  CalculateStaffSplit(e.Job_Type__c, e.Engagement_Teams__r, countMap);
        }
        if (e != null) {
            e.Recalculate_Deal_Percentages__c = false;
        }
        return lst;
    }
    
    
    //Create a Map by Job Type, this is used to fetch the role percent related to a LOB
    private Map<String, Job_Type__c> GetSplitsByJobType(List<Engagement__c> lstEngagement) {
        Set<String> jobTypes = new Set<String>();
        for (Engagement__c e : lstEngagement) {
            if (e.Job_Type__c != null)
                jobTypes.add(e.Job_Type__c);
        }
        
        List<Job_Type__c> lstJobTypeSplit = [Select Name, Job_Code__c, Primary_Line_of_Business__c, Role_Analyst_Percent__c, Role_Associate_Percent__c, Role_Initiator_Percent__c, Role_Manager_Percent__c, Role_Principal_Percent__c, Role_Seller_Percent__c
                                             FROM Job_Type__c
                                             WHERE Name IN: jobTypes];
        Map<String, Job_Type__c> splitMap = new Map<String, Job_Type__c>();
        if (lstJobTypeSplit != null) {
            for (Job_Type__c split : lstJobTypeSplit) {
                if (!splitMap.containsKey(split.Name)) {
                    splitMap.put(split.Name, split);
                }
            }
        }
        return splitMap;
    }
    //This is called from batch job
    public void Recalculate(Set<Id> engagementIds) {
        
        if (engagementIds != null && !engagementIds.isEmpty()) {
            List<Engagement__c> lstEngagement = [SELECT Id,
                                                 Line_of_Business__c,
                                                 Job_Type__c,
                                                 (SELECT Id,
                                                  Start_Date__c,
                                                  Role__c,
                                                  End_Date__c,
                                                  Active_On_Engagement__c,
                                                  Staff_Revenue_Split__c FROM Engagement_Teams__r )
                                                 FROM Engagement__c WHERE Id IN: engagementIds FOR UPDATE];
            
            if (!lstEngagement.isEmpty()) {
                List<Engagement_Internal_Team__c> lstTeamUpdate = new List<Engagement_Internal_Team__c>();
                
                //Add all the EIT records in a Map, these would be used to compare the new calculated values.
                Map<Id, Decimal> existingEITMap = new Map<Id, Decimal>();
                for (Engagement__c e : lstEngagement) {
                    if (e.Engagement_Teams__r != null && !e.Engagement_Teams__r.isEmpty()) {
                        for (Engagement_Internal_Team__c et : e.Engagement_Teams__r) {
                            existingEITMap.put(et.Id, et.Staff_Revenue_Split__c);
                        }
                    }
                }
                //Fetch the required Role Percents
                mapJobTypeSplit = GetSplitsByJobType(lstEngagement);
                
                for (Engagement__c e : lstEngagement) {
                    List<Engagement_Internal_Team__c> lstTeam = ProcessEngagement(e);
                    
                    if (lstTeam != null) {
                        
                        for (Engagement_Internal_Team__c eit : lstTeam) {
                            //Compare if the new calculated values are different from the existing ones, add to the list
                            //only if they are different
                            
                            if (existingEITMap.containsKey(eit.Id) && existingEITMap.get(eit.Id) != eit.Staff_Revenue_Split__c)
                                lstTeamUpdate.add(eit);
                        }//for
                    }//if
                    //lstTeamUpdate.addAll(lstTeam);
                }//for
                
                
                if (lstEngagement != null && !lstEngagement.isEmpty()) {
                    Database.SaveResult[] MySaveResult = Database.Update(lstEngagement);
                    System.debug('\n\nResults: ' + MySaveResult);
                }
                
                
                if (!lstTeamUpdate.isEmpty()) {
                    if (System.isBatch()) {
                        //Do not handle errors, need the complete batch to fail in case of an error of any records.
                        //and let the reords be recalculated in the next run
                        update lstTeamUpdate;
                    } else {
                        //Do not do a partial update, let the user get an error for all the records being processed.
                        try {
                            update lstTeamUpdate;
                        } catch (Exception dmle) {
                            for (Engagement_Internal_Team__c team : lstTeamUpdate) {
                                if (Trigger.newMap != null && Trigger.newMap.containsKey(team.Id))
                                    Trigger.newMap.get(team.Id).addError('\n\nError Calculating Split: ' + dmle.getMessage());
                            } //for
                        }//catch
                    }//else
                }//if
                
            }
        }
        //Aggregate the Office Splits
        UpdateEITStaffSplitValues(engagementIds);
        
        //if(!System.isBatch()){
        //AggregateOfficeSplitsFuture(engagementIds);
        //AggregateLOBSplitsFuture(engagementIds);
        //}
        //else
        //{
            AggregateOfficeSplits(engagementIds);
            
        
        //    AggregateLOBSplits(engagementIds);
            
        
        
        //}
    }

    public void RecalculateLOBSplits(Set<Id> engagementIds) {
        
        if (engagementIds != null && !engagementIds.isEmpty()) {
            List<Engagement__c> lstEngagement = [SELECT Id,
                                                 Line_of_Business__c,
                                                 Job_Type__c,
                                                 (SELECT Id,
                                                  Start_Date__c,
                                                  Role__c,
                                                  End_Date__c,
                                                  Active_On_Engagement__c,
                                                  Staff_Revenue_Split__c FROM Engagement_Teams__r )
                                                 FROM Engagement__c WHERE Id IN: engagementIds FOR UPDATE];
            
            if (!lstEngagement.isEmpty()) {
                List<Engagement_Internal_Team__c> lstTeamUpdate = new List<Engagement_Internal_Team__c>();
                
                //Add all the EIT records in a Map, these would be used to compare the new calculated values.
                Map<Id, Decimal> existingEITMap = new Map<Id, Decimal>();
                for (Engagement__c e : lstEngagement) {
                    if (e.Engagement_Teams__r != null && !e.Engagement_Teams__r.isEmpty()) {
                        for (Engagement_Internal_Team__c et : e.Engagement_Teams__r) {
                            existingEITMap.put(et.Id, et.Staff_Revenue_Split__c);
                        }
                    }
                }
                //Fetch the required Role Percents
                mapJobTypeSplit = GetSplitsByJobType(lstEngagement);
                
                for (Engagement__c e : lstEngagement) {
                    List<Engagement_Internal_Team__c> lstTeam = ProcessEngagement(e);
                    
                    if (lstTeam != null) {
                        
                        for (Engagement_Internal_Team__c eit : lstTeam) {
                            //Compare if the new calculated values are different from the existing ones, add to the list
                            //only if they are different
                            
                            if (existingEITMap.containsKey(eit.Id) && existingEITMap.get(eit.Id) != eit.Staff_Revenue_Split__c)
                                lstTeamUpdate.add(eit);
                        }//for
                    }//if
                    //lstTeamUpdate.addAll(lstTeam);
                }//for
                
                
                if (lstEngagement != null && !lstEngagement.isEmpty()) {
                    Database.SaveResult[] MySaveResult = Database.Update(lstEngagement);
                    System.debug('\n\nResults: ' + MySaveResult);
                }
                
                
                if (!lstTeamUpdate.isEmpty()) {
                    if (System.isBatch()) {
                        //Do not handle errors, need the complete batch to fail in case of an error of any records.
                        //and let the reords be recalculated in the next run
                        update lstTeamUpdate;
                    } else {
                        //Do not do a partial update, let the user get an error for all the records being processed.
                        try {
                            update lstTeamUpdate;
                        } catch (Exception dmle) {
                            for (Engagement_Internal_Team__c team : lstTeamUpdate) {
                                if (Trigger.newMap != null && Trigger.newMap.containsKey(team.Id))
                                    Trigger.newMap.get(team.Id).addError('\n\nError Calculating Split: ' + dmle.getMessage());
                            } //for
                        }//catch
                    }//else
                }//if
                
            }
        }

        //    AggregateOfficeSplits(engagementIds);            
    
            AggregateLOBSplits(engagementIds);        
        
        //}
    }
    //Called from Engagement Trigger
    public void Recalculate(Map<Id, Engagement__c> oldMap, Map<Id, Engagement__c> newMap) {
        Set<Id> engagementIds = new Set<Id>();
        if (oldMap != null && newMap != null) {
            for (Engagement__c e : newMap.values()) {
                //Process those engagaments where the recalculate checkbox is checked OR the LOB is updated to a new value.
                if (e.Recalculate_Deal_Percentages__c || (e.Line_of_Business__c != oldMap.get(e.Id).Line_of_Business__c)) {
                    engagementIds.add(e.Id);
                }
            }
        }
        if (!engagementIds.isEmpty())
            recalculate(engagementIds);
    }


    /*
* Method is called from a trigger to handle any DMLs on Engagement Internal Team, any DML should recalculate the splits of the Engagement in total.
*/
    
    public void Recalculate(Map<Id, Engagement_Internal_Team__c> oldMap, Map<Id, Engagement_Internal_Team__c> newMap) {
        Set<Id> engagementIds = new Set<Id>();
        Map<Id, Engagement_Internal_Team__c> teamMap;
        //in case of delete
        if (oldMap != null && newMap == null)
            teamMap = oldMap;
        //in case of insert
        else if (oldMap == null && newMap != null)
            teamMap = newMap;
        if (teamMap != null) {
            for (Engagement_Internal_Team__c t : teamMap.values()) {
                if (t.Role__c != null && t.Active_On_Engagement__c && t.Engagement__c != null)
                    engagementIds.add(t.Engagement__c);
            }
        }
        //in case of update
        if (oldMap != null && newMap != null) {
            for (Engagement_Internal_Team__c t : newMap.values()) {
                if ( t.Engagement__c != null && (t.Start_Date__c != oldMap.get(t.Id).Start_Date__c ||
                                                 t.End_Date__c != oldMap.get(t.Id).End_Date__c ||
                                                 t.Office__c != oldMap.get(t.Id).Office__c ||
                                                 t.Role__c != oldMap.get(t.Id).Role__c
                                                ))   {
                                                    engagementIds.add(t.Engagement__c);
                                                }
            }
        }
        
        if(!engagementIds.isEmpty())
            recalculate(engagementIds);
    }
    
    
    private static void UpdateEITStaffSplitValues(Set<Id> engagementIds){
        List<Engagement_Internal_Team__c> eitToUpdate = new List<Engagement_Internal_Team__c>();
        Map<Id,Decimal> percentMap = new Map<Id,Decimal>();
        Map<Id,Decimal> remainderMap = new Map<Id, Decimal>();
        AggregateResult[] groupedResults = [SELECT Engagement__c eId, SUM(Staff_Revenue_Split__c) total
                                            FROM Engagement_Internal_Team__c
                                            WHERE Engagement__c IN: engagementIds
                                            GROUP BY Engagement__c];
        //Determine which do not have full percentages
        for(AggregateResult ar : groupedResults)
        {
            Decimal percent = (Decimal)percentMap.get((Id)ar.get('eId'));
            Decimal total = (Decimal)ar.get('total');
            if(total != null){
                if(percent == null)
                    percentMap.put((Id)ar.get('eId'), (Decimal)ar.get('total'));
                else
                    percentMap.put((Id)ar.get('eId'), percent + (Decimal)ar.get('total'));
            }
        }
        
        for(Id engagementId : percentMap.keySet())
        {
            Decimal value = (Decimal)percentMap.get(engagementId);
            Decimal remainder = 1 - value;
            if(remainder > 0){
                remainderMap.put(engagementId, remainder);
            }
        }
        
        for(Engagement_Internal_Team__c eit : [SELECT Engagement__c, Staff_Revenue_Split__c FROM Engagement_Internal_Team__c WHERE Engagement__c IN: engagementIds AND Staff_Revenue_Split__c != null])
        {
            if(remainderMap.get(eit.Engagement__c) <> null){
                eit.Staff_Revenue_Split__c = (eit.Staff_Revenue_Split__c / (1 - (Decimal)remainderMap.get(eit.Engagement__c)));
                eitToUpdate.add(eit);
            }
        }
        
        if(eitToUpdate.size() > 0)
            update eitToUpdate;
    }
    
    //Calculate the Office Splits both at the Internal Team level and then at the Engagement Office Split Object level
    @future
    private static void AggregateOfficeSplitsFuture(Set<Id> engagementIds){
        AggregateOfficeSplits(engagementIds);
    }
    
    private static void AggregateOfficeSplits(Set<Id> engagementIds) {
        if (!engagementIds.isEmpty()) {
            String allocation;
            AggregateResult[] officeAggregate = [SELECT
                                                 Contact__r.Revenue_Allocation__c acquired,
                                                 Office__c office,
                                                 Engagement__r.Primary_Office__c primaryOffice,
                                                 Engagement__r.Line_Of_Business__c primaryLOB,
                                                 Engagement__c engagementId,
                                                 SUM(Staff_Revenue_Split__c) sum
                                                 FROM Engagement_Internal_Team__c
                                                 WHERE Engagement__c IN: engagementIds AND Allocation_Office__c != null
                                                 GROUP BY Office__c, Engagement__r.Line_Of_Business__c, Engagement__r.Primary_Office__c, Contact__r.Revenue_Allocation__c, Engagement__c];
            
            //Map of Engagement Id with Primary Office
            Map<Id, String> primaryOfficeMap = GetPrimaryMap(officeAggregate, 'primaryOffice');
            //Map of Engagement Id with Primary LOB (Used for Record Sharing)
            Map<Id, String> primaryLOBMap = GetPrimaryMap(officeAggregate, 'primaryLOB');
            //Map of Engagement Id with Map of Office and Split Value
            Map<Id, Map<String, Decimal>> engagementOfficeSplitMap = GetSplitMap(officeAggregate, 'office', 'acquired');
            //Fix/Adjust for Remainders
            engagementOfficeSplitMap = FixRemainders(engagementOfficeSplitMap, primaryOfficeMap);
            //Upsert the Engagement Office Split Records
            UpsertEngagementOfficeRecords(engagementOfficeSplitMap, primaryLOBMap);
        }
    }
    
    @future
    private static void AggregateLOBSplitsFuture(Set<Id> engagementIds){
        AggregateLOBSplits(engagementIds);
    }
    // 11/11/2020: Updated the Aggregate Query to fetch the results from Staffing Details
    private static void AggregateLOBSplits(Set<Id> engagementIdSet){
        Date previousMonthDate = System.Today().toStartOfMonth().addDays(-1);
     //   Date previousMonthDate =  Date.newInstance(2020, 12, 31);
        if(!engagementIdSet.isEmpty()){            
            AggregateResult[] lobAggregate = [SELECT 
                                              Staff_LOB__c lob, 
                                              Engagement__c engagementId, 
                                              Engagement__r.Line_Of_Business__c primaryLOB, 
                                              SUM(Allocation__c) sum 
                                              FROM Staffing_Details__c 
                                              WHERE Engagement__c IN: engagementIdSet AND Revenue_Date__c =: previousMonthDate
                                              and Staff_LOB__c !=null
                                              And Is_Bad_Debt__c = false
                                              GROUP BY Staff_LOB__c, Engagement__c, Engagement__r.Line_Of_Business__c];
            
            System.debug('***********This is executed #319:: ' + lobAggregate);
            
            //Map of Engagement Id with Primary LOB
            Map<Id, String> primaryLOBMap = GetPrimaryMap(lobAggregate, 'primaryLOB');
            //Map of Engagement Id with Map of LOB and Split Value
            Map<Id, Map<String, Decimal>> engagementLOBSplitMap = GetSplitMap(lobAggregate, 'lob', null);
            System.debug('This Check#3::: ' + engagementLOBSplitMap);
            //Fix/Adjust for Remainders *Updated: 11/10/2020 --> This is handled in the "UpsertEngagementLOBRecords"
        //    engagementLOBSplitMap = FixRemainders(engagementLOBSplitMap, primaryLOBMap);
        //    System.debug('This Check#7::: ' + engagementLOBSplitMap);
            //Upsert the Engagement LOB Split Records
            UpsertEngagementLOBRecords(engagementLOBSplitMap, primaryLOBMap);
        }
    }
    
    private static List<Engagement_LOB_Split__c> UpsertEngagementLOBRecords(Map<Id, Map<String, Decimal>> engagementLOBSplitMap, Map<Id, String> primaryLOBMap){

        Map<Id, Map<String, Decimal>> existingRecords = GetExistingLOBSplitsToRemoveDupes(engagementLOBSplitMap.keySet());
        Map<Id, Map<Id, String>> existingLOBsToDeleteRecords = GetExistingLOBSplitstoDelete(engagementLOBSplitMap.keySet());
        Map<Id, Map<String, Id>> identifyExistingLOBSplitsToDelete = GetExistingLOBSplits(engagementLOBSplitMap.keySet());
        List<Engagement_LOB_Split__c> osToUpsert = new List<Engagement_LOB_Split__c>();
        List<Engagement_LOB_Split__c> osToDelete = new List<Engagement_LOB_Split__c>();
        List<Engagement_LOB_Split__c> osToInsert = new List<Engagement_LOB_Split__c>();
        List<Engagement_LOB_Split__c> osToInsert2 = new List<Engagement_LOB_Split__c>();
        List<Engagement_LOB_Split__c> osToDelete2 = new List<Engagement_LOB_Split__c>();

        Map<String, Decimal> extMap = new Map<String, Decimal>();
        List<Engagement_LOB_Split__c> deleteLOBs = new List<Engagement_LOB_Split__c>();

        for(Id id : engagementLOBSplitMap.keySet()){
            String engagementLOB = primaryLOBMap.get(id);
            Map<String, Decimal> newLobSplits = engagementLOBSplitMap.get(id); //new LOB Splits
            Map<String, Decimal> existingLOBSplits = existingRecords.get(id);
            Map<String, Id> oldLOBSplits = identifyExistingLOBSplitsToDelete.get(id);
            if(!newLobSplits.isEmpty()){
                for(String lob : newLobSplits.keySet()){
                    Decimal newSplit = newLobSplits.get(lob);// + existingLOBSplits.get(lob);
                    if(existingRecords.containsKey(id)){ 
                        if(existingLOBSplits.containsKey(lob)){
                            Id osId = oldLOBSplits.get(lob); //existing Record Id
                    if(osId !=null){
                        osToUpsert.add(new Engagement_LOB_Split__c(Id = osId, LOB__c = lob, LOB_Split__c = newSplit));    
                    } else {
                        osToUpsert.add(new Engagement_LOB_Split__c(Engagement__c = id, Engagement_LOB__c = engagementLOB, LOB__c = lob, LOB_Split__c = newSplit));
                    }
                } else {
                    osToUpsert.add(new Engagement_LOB_Split__c(Engagement__c = id, Engagement_LOB__c = engagementLOB, LOB__c = lob, LOB_Split__c = newSplit));
                    } 
                    } else {
                        osToUpsert.add(new Engagement_LOB_Split__c(Engagement__c = id, Engagement_LOB__c = engagementLOB, LOB__c = lob, LOB_Split__c = newSplit));
                        }  
                }
                    }  
                }       
            if(!deleteLOBs.isEmpty()){
         //       delete deleteLOBs;
            }
        if(osToUpsert.size() > 0){
            upsert osToUpsert;
        }
        Map<Id, Map<String, Decimal>> existingRecordsWithDupe = GetExistingLOBSplitsToRemoveDupes(engagementLOBSplitMap.keySet());
        for(Id id : existingRecordsWithDupe.keySet()){
            String engagementLOB = primaryLOBMap.get(id);
            Map<String, Decimal> existingLOBSplits = existingRecordsWithDupe.get(id);
            Map<String, Decimal> allLOBs = new Map<String,Decimal>();
            for(Line_of_Business__mdt l : [SELECT LOB__c, LOB_Split_Value__c FROM Line_of_Business__mdt]){
                allLOBs.put(l.LOB__c, l.LOB_Split_Value__c);
            }
            Map<String, Decimal> exLobSplits = new Map<String, Decimal>();
            Map<Id, String> existingLOBSplitsToDelete = existingLOBsToDeleteRecords.get(id);

                for(String s : existingLOBSplits.KeySet()){
                    if(allLOBs.containsKey(s)){
                        allLOBs.remove(s);
                    }
                }

                for(String s : allLOBs.KeySet()){
                    osToInsert2.add(new Engagement_LOB_Split__c(Engagement__c = id, Engagement_LOB__c = engagementLOB, LOB__c = s, LOB_Split__c = allLOBs.get(s)));
                 }    
                 exLobSplits.clear();
        }        
        if(!osToInsert2.isEmpty()){
            insert osToInsert2;
        }
        AggregateResult[] ar = [SELECT 
        LOB__c lob, 
        Engagement__c engagementId, 
        Engagement__r.Line_Of_Business__c primaryLOB, 
        SUM(LOB_Split__c) sum 
        FROM Engagement_LOB_Split__c
        WHERE Engagement__c IN: engagementLOBSplitMap.keySet()
        GROUP BY LOB__c, Engagement__c, Engagement__r.Line_Of_Business__c];

        List<Engagement_LOB_Split__c> adjustedUpsert = new List<Engagement_LOB_Split__c>();
        Map<Id, String> primaryLOBMap2 = GetPrimaryMap(ar, 'primaryLOB');
                    //Map of Engagement Id with Map of LOB and Split Value
                    Map<Id, Map<String, Decimal>> engagementLOBSplitMap3 = GetSplitMap(ar, 'lob', null);
                    //Fix/Adjust for Remainders
                    Map<Id, Map<String, Decimal>> engagementLOBSplitMap2 = FixRemainders(engagementLOBSplitMap3, primaryLOBMap2);
                Map<Id, Map<String, Id>> identifyExistingLOBSplitsToDeleteNew = GetExistingLOBSplits(engagementLOBSplitMap.keySet());

                for(Id id : engagementLOBSplitMap2.keySet()){
                    Map<String, Id> existingLOBSplits = identifyExistingLOBSplitsToDeleteNew.get(id);
                    Map<String, Decimal> adjustedLOBSplits = engagementLOBSplitMap2.get(id);
                    if(engagementLOBSplitMap2.containsKey(id) && identifyExistingLOBSplitsToDeleteNew.containsKey(id)){
                        for(String s : existingLOBSplits.KeySet()){
                            Id osId = existingLOBSplits.get(s);
                            Decimal lobSplit = adjustedLOBSplits.get(s);
                            if(adjustedLOBSplits.containsKey(s)){
                                adjustedUpsert.add(new Engagement_LOB_Split__c(Id = osId, LOB_Split__c = lobSplit));  
                            }
                        }
                    }
                }
                if(!adjustedUpsert.isEmpty()){
                    upsert adjustedUpsert;
                }
        return adjustedUpsert; 
    }



    private static List<Engagement_Office_Split__c> UpsertEngagementOfficeRecords(Map<Id, Map<String, Decimal>> engagementOfficeSplitMap, Map<Id, String> primaryLOBMap){
        Map<Id, Map<String, Id>> existingRecords = GetExistingOfficeSplits(engagementOfficeSplitMap.keySet());
        List<Engagement_Office_Split__c> osToUpsert = new List<Engagement_Office_Split__c>();
        List<Engagement_Office_Split__c> osToDelete = new List<Engagement_Office_Split__c>();
        
        for(Id id : engagementOfficeSplitMap.keySet()){
            //Get the Engagement LOB to Assign for Record Sharing
            String engagementLOB = primaryLOBMap.get(id);
            Map<String, Decimal> officeSplits = engagementOfficeSplitMap.get(id);
            for(String office : officeSplits.keySet()){
                Map<String, Id> existingOfficeSplits = existingRecords.get(id);
                Decimal officeSplit = officeSplits.get(office);
                if(existingOfficeSplits != null && existingOfficeSplits.containsKey(office)){
                    Id osId = existingOfficeSplits.get(office);
                    if(officeSplit > 0)
                        osToUpsert.add(new Engagement_Office_Split__c(Id = osId, Office_Split__c = officeSplit));
                    else
                        osToDelete.add(new Engagement_Office_Split__c(Id = osId));
                }
                else if (officeSplit > 0)
                    osToUpsert.add(new Engagement_Office_Split__c(Engagement__c = id, Engagement_LOB__c = engagementLOB, Office__c = office, Office_Split__c = officeSplits.get(office)));
            }
        }
        
        if(osToDelete.size() > 0)
            delete osToDelete;
        
        if(osToUpsert.size() > 0)
            upsert osToUpsert;
        
        return osToUpsert;
    }

     
    private static Map<Id, Map<String, Decimal>> GetExistingLOBSplitsToRemoveDupes(Set<Id> engagementIdSet){
        Map<Id, Map<String, Decimal>> existingRecords = new Map<Id, Map<String, Decimal>>();
        List<Engagement_LOB_Split__c> newList = new List<Engagement_LOB_Split__c>();

        for(AggregateResult a : [SELECT LOB__c lob, Engagement__c engagementId,Engagement__r.Line_Of_Business__c primaryLOB, SUM(LOB_Split__c) sum FROM Engagement_LOB_Split__c WHERE Engagement__c IN: engagementIdSet GROUP BY LOB__c, Engagement__c, Engagement__r.Line_Of_Business__c]){
            for(Id i :engagementIdSet ){
                if(i == (Id)a.get('engagementId')){
                    Id thisEngagementId = (Id)a.get('engagementId');
                    String thisprimaryLOB = (String)a.get('primaryLOB');
                    String thisLOB = (String)a.get('lob');
                    Decimal thisLOBSplit = (Decimal)a.get('sum');            
                    newList.add(new Engagement_LOB_Split__c(Engagement__c = thisEngagementId, Engagement_LOB__c = thisprimaryLOB, LOB__c = thisLOB, LOB_Split__c = thisLOBSplit));
                }
        }
    }
        //Get Existing Records
        for(Engagement_LOB_Split__c eLOB : newList){
            if(existingRecords.containsKey(eLOB.Engagement__c)){
                Map<String, Decimal> lobSplitMap = existingRecords.get(eLOB.Engagement__c);
                lobSplitMap.put(eLOB.LOB__c, eLOB.LOB_Split__c);
            }
            else
                existingRecords.put(eLOB.Engagement__c, new Map<String, Decimal> {eLOB.LOB__c => eLOB.LOB_Split__c});
        }
        
        return existingRecords;
    }
    private static Map<Id, Map<Id, String>> GetExistingLOBSplitstoDelete(Set<Id> engagementIdSet){
        Map<Id, Map<Id, String>> existingRecords = new Map<Id, Map<Id, String>>();
        
        //Get Existing Records
        for(Engagement_LOB_Split__c eLOB : [SELECT Engagement__c, LOB__c, LOB_Split__c FROM Engagement_LOB_Split__c WHERE Engagement__c IN: engagementIdSet]){
            if(existingRecords.containsKey(eLOB.Engagement__c)){
                Map<Id, String> lobSplitMap = existingRecords.get(eLOB.Engagement__c);
                lobSplitMap.put(eLOB.Id, eLOB.LOB__c);
            }
            else
                existingRecords.put(eLOB.Engagement__c, new Map<Id, String>{eLOB.Id => eLOB.LOB__c});
        }
        
        return existingRecords;
    }

    private static Map<Id, Map<String, Id>> GetExistingLOBSplits(Set<Id> engagementIdSet){
        Map<Id, Map<String, Id>> existingRecords = new Map<Id, Map<String, Id>>();
        
        //Get Existing Records
        for(Engagement_LOB_Split__c eLOB : [SELECT Engagement__c, LOB__c, LOB_Split__c FROM Engagement_LOB_Split__c WHERE Engagement__c IN: engagementIdSet]){
            if(existingRecords.containsKey(eLOB.Engagement__c)){
                Map<String, Id> lobSplitMap = existingRecords.get(eLOB.Engagement__c);
                lobSplitMap.put(eLOB.LOB__c, eLOB.Id);
            }
            else
                existingRecords.put(eLOB.Engagement__c, new Map<String, Id> {eLOB.LOB__c => eLOB.Id});
        }
        
        return existingRecords;
    }
    
    private static Map<Id, Map<String, Id>> GetExistingOfficeSplits(Set<Id> engagementIdSet){
        Map<Id, Map<String, Id>> existingRecords = new Map<Id, Map<String, Id>>();
        
        //Get Existing Records
        for(Engagement_Office_Split__c eOffice : [SELECT Engagement__c, Office__c, Office_Split__c FROM Engagement_Office_Split__c WHERE Engagement__c IN: engagementIdSet]){
            if(existingRecords.containsKey(eOffice.Engagement__c)){
                Map<String, Id> officeSplitMap = existingRecords.get(eOffice.Engagement__c);
                officeSplitMap.put(eOffice.Office__c, eOffice.Id);
            }
            else
                existingRecords.put(eOffice.Engagement__c, new Map<String, Id> {eOffice.Office__c => eOffice.Id});
        }
        
        return existingRecords;
    }
    
    
    private static Map<Id, Map<String, Decimal>> GetSplitMap(AggregateResult[] recordAggregate, String groupField, string allocationField){
        
        //Convert the aggregate records into a Map for rounding evaluation    
        Map<Id, Map<String, Decimal>> aggSplitMap = new Map<Id, Map<String, Decimal>>();
        for(AggregateResult ar : recordAggregate){
            String engagementId = (String)ar.get('engagementId');
            
            String splitGroup = (String)ar.get(groupField);
            
            
            if (allocationField != null) {
                String splitAllocation = (String)ar.get(allocationField);
                if (splitAllocation != null && !String.isBlank(splitAllocation)) {
                    splitGroup = splitAllocation;
                }
            }
            
            
            Decimal sum = (Decimal)ar.get('sum');
            
            
            
            if(sum == null)
                sum = 0;
            
            if(aggSplitMap.containsKey(engagementId)){
                Map<String, Decimal> groupSplitMap = aggSplitMap.get(engagementId);
                
                if(groupSplitMap.get(splitGroup) != null)
                    groupSplitMap.put(splitGroup, groupSplitMap.get(splitGroup) + sum);
                else
                    groupSplitMap.put(splitGroup, sum);
                
                aggSplitMap.put(engagementId, groupSplitMap);
            }
            else{
                Map<String, Decimal> groupSplitMap = new Map<String, Decimal> {splitGroup => sum};
                    aggSplitMap.put(engagementId, groupSplitMap);
            }
        }
        
        return aggSplitMap;
        
    }
    
    private static Map<Id,String> GetPrimaryMap(AggregateResult[] recordAggregate, String primaryField){
        Map<Id,String> primaryMap = new Map<Id, String>();
        
        for(AggregateResult ar : recordAggregate){
            String engagementId = (String)ar.get('engagementId');
            if(!primaryMap.containsKey(engagementId))
                primaryMap.put(engagementId, (String)ar.get(primaryField));
        }
        
        return primaryMap;
    }
    
    //Used to fix/adjust the values so that the percents are equal to 100
    //Expects parameters of the Map of the Splits and the Map of the Engagement Id with the Respective Primary Value (Office or LOB)
    private static Map<Id, Map<String, Decimal>> FixRemainders(Map<Id, Map<String, Decimal>> engagementSplitMap, Map<Id, String> primaryMap){
        for(Id id : engagementSplitMap.keySet()){
            Decimal totalValue = 0;
            Map<String, Decimal> splitValues = engagementSplitMap.get(id);
            for(Decimal value : splitValues.values()){
                if(value != null)
                    totalValue += value;

            }
            //Check if the total is 1
            Decimal remainder = 1 - totalValue;
            if(remainder > 0){
                //Get the Primary Value
                String primary = primaryMap.get(Id);
                if(!String.isBlank(primary) && splitValues.containsKey(primary))
                    splitValues.put(primary, splitValues.get(primary) + remainder);
                else
                    splitValues.put(new List<String>(splitValues.keySet()).get(0), splitValues.values().get(0) + remainder);
                
                engagementSplitMap.put(id, splitValues);
            } else if(remainder < 0){
                //Get the Primary Value
                String primary = primaryMap.get(Id);
                if(!String.isBlank(primary) && splitValues.containsKey(primary))
                    splitValues.put(primary, splitValues.get(primary) + remainder);
                else
                    splitValues.put(new List<String>(splitValues.keySet()).get(0), splitValues.values().get(0) + remainder);
                
                engagementSplitMap.put(id, splitValues);
            } 
        }
        
        return engagementSplitMap;
        
    }
    
    //Method would take Engagement Internal Team and Opportunity internal team records and process them accordingly.
    public static void StampContactValuesOnITeam(List<SObject> itRecords) {
        if (itRecords != null && !itRecords.isEmpty()) {
            Set<Id> contactIds = new Set<Id>();
            //Collect all the related contacts Ids
            for (SObject obj : itRecords) {
                contactIds.add((Id)obj.get('Contact__c'));
            }
            
            if (!contactIds.isEmpty()) {
                Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT
                                                                    Id, Line_of_Business__c, Office__c
                                                                    FROM Contact
                                                                    WHERE Id IN: contactIds]);
                
                List<SObject> updtObjLst = new List<SObject>();
                List<SObject> insrtObjLst = new List<SObject>();
                // If a contact has their LOB or Office changed on 1/15 all active internal team members related to that contact
                //on open opportunities/engagements should have their end date set to 1/15 and new internal team members should
                //be created with all the same values as the old ones except start date = 1/16 and LOB/Office = contact.LOB/Office.
                for (SObject obj : itRecords) {
                    String itOffice = (String)obj.get('Office__c');
                    String itLOB = (String)obj.get('LOB__c');
                    Contact  c = contactMap.get((Id)obj.get('Contact__c'));
                    
                    if ((c.Office__c!=null && !c.Office__c.equals(itOffice))
                        || (c.Line_of_Business__c!=null && !c.Line_of_Business__c.equals(itLOB))) {
                            
                            SObject newObjUpdt = obj.clone(true, true, true, true);
                            newObjUpdt.put('End_Date__c', System.Today());
                            updtObjLst.add(newObjUpdt);
                            
                            SObject newObj = obj.clone(false, false, false, false);
                            newObj.put('Start_Date__c', (System.Today().addDays(1)));
                            System.debug('\n\nNEW OBJ: ' + newObj);
                            newObj.put('Office__c', null); //Let this be populated by Workflow
                            newObj.put('LOB__c', null); //Let this be populated by Workflow
                            newObj.put('End_Date__c', null);
                            insrtObjLst.add(newObj);
                        }
                }
                if(!updtObjLst.isEmpty())
                {
                    Database.SaveResult[] MySaveResult = Database.Update(updtObjLst);
                }
                if(!insrtObjLst.isEmpty())
                {
                    Database.SaveResult[] MySaveResult = Database.insert(insrtObjLst);
                }
            }
            
        }
    }
    
    public static void SendEmail(String to, String subject, String body) {
        try {
            HL_Email.SendEmail(new List<String> {to}, null, null, subject, body, false);
        }catch (Exception e) {
            System.debug('\n\nError Sending Email');
        }
    }
    
    public static string GetCreatableFieldsSOQL(String objectName) {
        String selects = '';
        
        //get a map of field names and field tokens
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<String> selectFields = new List<String>();
        
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()) { //loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); //describe each field (fd)
                if (fd.isCreateable()) { //field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()) {
            for (string s : selectFields) {
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0, selects.lastIndexOf(','));
            }
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName;
    }
}