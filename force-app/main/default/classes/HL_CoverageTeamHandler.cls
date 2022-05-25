public class HL_CoverageTeamHandler {
    
    public static Boolean isCovergeTriggerExecuted = false;
        
    public static void UpdateCoverageTeamAggregateFuture(List<Coverage_Team__c> ctList){
        Set<Id> setToUpdate = new Set<Id>();
        for(Coverage_Team__c ct : ctList){
            setToUpdate.add(ct.Id);
        }
        if(!setToUpdate.isEmpty()){
            UpdateCoverageTeamAggregate(setToUpdate);
        }
    }
    
    
    
    //public static void UpdateCoverageTeamAggregate(List<Coverage_Team__c> ctList){
    @future
    public static void UpdateCoverageTeamAggregate(Set<Id> ctList){
        
        
        //Create Set of Company Ids
        Set<Id> cs = new Set<Id>();
        for(Coverage_Team__c c : [SELECT Id,Company__c FROM Coverage_Team__c WHERE Id IN: ctList]){
            cs.add(c.Company__c);
        }
        //Get companies that may need to be updated
        List<Account> acctsToUpdate = [SELECT Id, Coverage_Team_Aggregate__c, Primary_Coverage_Officer__c, Primary_FS_Coverage_Officer__c FROM Account WHERE Id IN : cs];
        
        //Create a map of company with team member ids and a map with a list of coverage ordered
        Map<Id,Set<String>> acctTeamMap = new Map<Id,Set<String>>();
        Map<Id,Id> coMap = new Map<Id,Id>();
        Map<Id,Id> coMapFS = new Map<Id,Id>();
        //Loop through the FSCG Coverage (These are ranked ahead of Standard Coverage to store primary at Company (Account) Level)
        //Also need to include in aggregate field result
        for(Coverage_Team__c ct : [SELECT Company__c, Officer__c, Officer__r.User__c FROM Coverage_Team__c WHERE Company__c IN : cs AND RecordType.DeveloperName =: 'FS_Coverage_Team_Member' AND Coverage_Team_Status__c = 'Active' ORDER BY Coverage_Level__c ASC, Tier__c ASC]){
            if(acctTeamMap.get(ct.Company__c) == null){
                acctTeamMap.put(ct.Company__c, new Set<String>{ct.Officer__r.User__c});
                coMap.put(ct.Company__c, ct.Officer__c); //We want to only put first one here so we don't have to check in else
                coMapFS.put(ct.Company__c, ct.Officer__c); //put first FS officer into separate map
            }
            else
            {
                Set<String> existingIds = (Set<String>)acctTeamMap.get(ct.Company__c);
                existingIds.add(ct.Officer__r.User__c);
                acctTeamMap.put(ct.Company__c, existingIds);
            }
        }
        
        //Loop through the Standard Coverage (similar to above)
        for(Coverage_Team__c ct : [SELECT Company__c, Officer__c, Officer__r.User__c FROM Coverage_Team__c WHERE Company__c IN : cs AND RecordType.DeveloperName =: 'Standard_Coverage_Team_Member' AND Coverage_Team_Status__c = 'Active' ORDER BY Coverage_Level__c DESC, Tier__c ASC])
        {
            if(acctTeamMap.get(ct.Company__c) == null){
                acctTeamMap.put(ct.Company__c, new Set<String>{ct.Officer__r.User__c});
                coMap.put(ct.Company__c, ct.Officer__c); //We want to only put first one here so we don't have to check in else
            }
            else
            {
                Set<String> existingIds = (Set<String>)acctTeamMap.get(ct.Company__c);
                existingIds.add(ct.Officer__r.User__c);
                acctTeamMap.put(ct.Company__c, existingIds);
            }
        }
        
        
        for(Account a: acctsToUpdate){
            a.Coverage_Team_Aggregate__c = null;
            if(acctTeamMap.get(a.Id) <> null)
            {
                for(String id : (Set<String>)acctTeamMap.get(a.Id)){
                    if(String.isBlank(a.Coverage_Team_Aggregate__c) || a.Coverage_Team_Aggregate__c.length() < 230)
                        a.Coverage_Team_Aggregate__c = (String.isBlank(a.Coverage_Team_Aggregate__c) ? id : (a.Coverage_Team_Aggregate__c.contains(id) ? a.Coverage_Team_Aggregate__c : a.Coverage_Team_Aggregate__c + '|' + id));
                }
                if(coMap.get(a.Id) <> null)
                    a.Primary_Coverage_Officer__c = (Id)coMap.get(a.Id);
                if(coMapFS.get(a.Id) <> null){
                    a.Primary_FS_Coverage_Officer__c = (Id)coMapFS.get(a.Id);
                }
                else{
                    a.Primary_FS_Coverage_Officer__c = null;
                }
            }
            else{
                a.Coverage_Team_Aggregate__c = null;
                a.Primary_Coverage_Officer__c = null;
                a.Primary_FS_Coverage_Officer__c = null;
            }
        }
        
        if(acctsToUpdate.size() > 0){
            update acctsToUpdate;
        }
    }
    /*
    public static void InsertCoverageTagging(List<Coverage_Team__c> ctList, Map<Id, Coverage_Team__c> oldMap, Boolean isInsert) {
        isCovergeTriggerExecuted = true;
        List<Coverage_Tagging__c> ccList = new List<Coverage_Tagging__c>();
        List<Coverage_Tagging__c> ccListUpdate = new List<Coverage_Tagging__c>();
        Set<Id> ids = new Set<id>();
        for(Coverage_Team__c ct : ctList)
        {
            if(isInsert || (!isInsert && ct.Primary_Sector__c != oldMap.get(ct.Id).Primary_Sector__c || ct.Secondary_Sector__c != oldMap.get(ct.Id).Secondary_Sector__c
                     || ct.Tertiary_Sector__c != oldMap.get(ct.Id).Tertiary_Sector__c || ct.Coverage_Type__c != oldMap.get(ct.Id).Coverage_Type__c))
            {
                ids.add(ct.id);
            }
        }
        
        if(ids != null && ids.size() > 0){
            List<Coverage_Tagging__c> cTaggingList = [SELECT Id,Primary_Sector__c,Coverage_Team__c,CoverageTaggingStatus__c
                FROM Coverage_Tagging__c WHERE Coverage_Team__c =: ids and CoverageTaggingStatus__c = TRUE];
            Map<Id,String> ctMap = new Map<Id,String>();
            Map<Id, Coverage_Tagging__c> ctMapExisting = new Map<Id, Coverage_Tagging__c>();
            if(cTaggingList != null && cTaggingList.size()>0)
            {
                for(Coverage_Tagging__c ct : cTaggingList) {  
                    ctMapExisting.put(ct.Coverage_Team__c, ct);
                }
                for(Coverage_Team__c ct : ctList)
                {
                    if(ctMapExisting.get(ct.Id) != null && ct.Coverage_Type__c != null ){//&& ct.Coverage_Type__c != oldMap.get(ct.Id).Coverage_Type__c
                        //ctMapExisting.get(ct.Id).CoverageTaggingStatus__c = false;
                        Coverage_Tagging__c tag = ctMapExisting.get(ct.Id);
                        tag.Type__c = ct.Coverage_Type__c;
                        tag.Primary_Sector__c = ct.Primary_Sector__c;
                        tag.Secondary_Sector__c = ct.Secondary_Sector__c;
                        tag.Tertiary_Sector__c = ct.Tertiary_Sector__c;
                        tag.CoverageTaggingStatus__c = true;
                        ccListUpdate.add(tag);
                    }
                    else{
                        ctMapExisting.get(ct.Id).CoverageTaggingStatus__c = false;
                        ccListUpdate.add(ctMapExisting.get(ct.Id));
                        Coverage_Tagging__c c = new Coverage_Tagging__c();
                        c.Coverage_Team__c = ct.Id;
                        c.Type__c = ct.Coverage_Type__c;
                        c.Primary_Sector__c= ct.Primary_Sector__c;
                        c.Secondary_Sector__c= ct.Secondary_Sector__c;
                        c.Tertiary_Sector__c=ct.Tertiary_Sector__c;
                        c.CoverageTaggingStatus__c= true;
                        ccList.add(c);
                    }
                    
                    
                }
                
                System.debug('line 144 ccList ### ' + ccList);
                if(ccList!= null && ccList.size()>0){
                    insert ccList;
                }
                System.debug('line 147 ccListUpdate ### ' + ccListUpdate);
                if(ccListUpdate != null && ccListUpdate.size() > 0){
                    update ccListUpdate;
                }
            }
            else
            {
                for(Coverage_Team__c ct : ctList)
                {
                    if(ct.Coverage_Type__c != null || Test.isRunningTest())
                    {
                        Coverage_Tagging__c c = new Coverage_Tagging__c();
                        c.Coverage_Team__c = ct.Id;
                        c.Type__c = ct.Coverage_Type__c;
                        c.Primary_Sector__c= ct.Primary_Sector__c;
                        c.Secondary_Sector__c= ct.Secondary_Sector__c;
                        c.Tertiary_Sector__c=ct.Tertiary_Sector__c;
                        c.CoverageTaggingStatus__c= true;
                        ccList.add(c); 
                    }
                }
                if(ccList!= null && ccList.size()>0)
                    insert ccList;
                
            }
        }
        
    }
    
    public static void validateCoverageTagging(List<Coverage_Team__c> newList, Map<Id,Coverage_Team__c> newap, Map<Id, Coverage_Team__c> oldMap){
        if(HL_CoverageSectorTriggerRecursion.runOnce() || Test.isRunningTest()){
            Map<String, List<Coverage_Tagging__c>> coverageTeamvsTaggingMap = new Map<String, List<Coverage_Tagging__c>>();
            set<Id> mappingIds = new set<Id>();
            for(Coverage_Team__c cteam : newList){
                if(cteam.Primary_Sector__c != oldMap.get(cteam.Id).Primary_Sector__c || cteam.Secondary_Sector__c != oldMap.get(cteam.Id).Secondary_Sector__c
                  || cteam.Tertiary_Sector__c != oldMap.get(cteam.Id).Tertiary_Sector__c || cteam.Coverage_Type__c != oldMap.get(cteam.Id).Coverage_Type__c)
                {
                    mappingIds.add(cteam.Id);
                }
            }
            
            if(mappingIds != null && mappingIds.size() > 0){
                List<Coverage_Tagging__c> taggingList = [select Id,Type__c,Primary_Sector__c,Secondary_Sector__c,Tertiary_Sector__c,Coverage_Team__c from Coverage_Tagging__c where Coverage_Team__c in :mappingIds];
                for(Coverage_Tagging__c ct : taggingList){
                    if(!coverageTeamvsTaggingMap.containsKey(ct.Coverage_Team__c)){
                        coverageTeamvsTaggingMap.put(ct.Coverage_Team__c, new List<Coverage_Tagging__c>{ct});
                    }else{
                        List<Coverage_Tagging__c> tagging = coverageTeamvsTaggingMap.get(ct.Coverage_Team__c);
                        tagging.add(ct);
                        coverageTeamvsTaggingMap.put(ct.Coverage_Team__c, tagging);
                    }
                }
                
                if(!coverageTeamvsTaggingMap.isEmpty()){
                    for(Coverage_Team__c ct : newList){
                        if(coverageTeamvsTaggingMap.get(ct.Id) != null){
                            List<Coverage_Tagging__c> ctList = coverageTeamvsTaggingMap.get(ct.Id);
                            for(Coverage_Tagging__c ctagging : ctList){
                                if(!Test.isRunningTest() && ctagging.Type__c == ct.Coverage_Type__c && ctagging.Primary_Sector__c == ct.Primary_Sector__c && ctagging.Secondary_Sector__c == ct.Secondary_Sector__c && ctagging.Tertiary_Sector__c == ct.Tertiary_Sector__c){
                                    ct.addError('There is an existing record with selected values');
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }*/
}