/*handles preventing delete of a main record
 handles removing main when another record is inserted with the IsMain__c flag set to true
 update the coverage team lookup fields*/

public without sharing class HL_CoverageSectorTrgHandler {
    private static boolean hasExecuted = false;    
    public static void onBeforeInsert(List<CoverageSector__c> trgNew){
        if(!hasExecuted){
            Set<Id> coverageTeamIdSet = new Set<Id>();
            List<Coverage_Team__c> ctUpdateList = new List<Coverage_Team__c>();
            for(CoverageSector__c cs : trgNew){
                if(cs.IsMain__c && cs.CoverageTeam__c!=null){
                    coverageTeamIdSet.add(cs.CoverageTeam__c);
                    ctUpdateList.add(new Coverage_Team__c(Id=cs.CoverageTeam__c,CoverageTypeLookup__c=cs.CoverageType__c,PrimarySectorLookup__c=cs.PrimarySector__c,
                                                          SecondarySectorLookup__c=cs.SecondarySector__c,TertiarySectorLookup__c=cs.TertiarySector__c));
                }
            }
            hasExecuted=true;
            if(!coverageTeamIdSet.isEmpty()){
                for(List<CoverageSector__c> csList : [SELECT Id FROM CoverageSector__c WHERE CoverageTeam__c IN :coverageTeamIdSet AND IsMain__c=true]){
                    for(CoverageSector__c cs : csList){
                        cs.IsMain__c=false;
                    }
                    update csList;
                }
                if(!ctUpdateList.isEmpty()){
                    update ctUpdateList;
                }
            }
            
        }
    }
    public static void onBeforeUpdate(Map<Id,CoverageSector__c> trgOldMap,Map<Id,CoverageSector__c> trgNewMap){
        if(!hasExecuted){
            CoverageSector__c oldCs;
            Set<Id> isMainAddSet = new Set<Id>();
            Set<Id> isMainRemoveSet = new Set<Id>();
            List<Coverage_Team__c> ctUpdateList = new List<Coverage_Team__c>();
            for(CoverageSector__c cs : trgNewMap.values()){
                oldCs = trgOldMap.get(cs.Id);
                if(cs.IsMain__c && !oldCs.IsMain__c && cs.CoverageTeam__c!=null){
                    isMainAddSet.add(cs.CoverageTeam__c);
                    ctUpdateList.add(new Coverage_Team__c(Id=cs.CoverageTeam__c,CoverageTypeLookup__c=cs.CoverageType__c,PrimarySectorLookup__c=cs.PrimarySector__c,
                                                          SecondarySectorLookup__c=cs.SecondarySector__c,TertiarySectorLookup__c=cs.TertiarySector__c));
                }else if(cs.IsMain__c && cs.CoverageTeam__c!=null &&(cs.CoverageType__c!=oldCs.CoverageType__c || cs.PrimarySector__c!=oldCs.PrimarySector__c||
                                                                     cs.SecondarySector__c!=oldCs.SecondarySector__c||cs.TertiarySector__c!=oldCs.TertiarySector__c)){
                    ctUpdateList.add(new Coverage_Team__c(Id=cs.CoverageTeam__c,CoverageTypeLookup__c=cs.CoverageType__c,PrimarySectorLookup__c=cs.PrimarySector__c,
                                                          SecondarySectorLookup__c=cs.SecondarySector__c,TertiarySectorLookup__c=cs.TertiarySector__c));                    
                }
                if(!cs.IsMain__c && oldCs.IsMain__c && cs.CoverageTeam__c!=null){
                    cs.addError(System.Label.Single_Main_Sector);
                }
            }
            hasExecuted=true;
            if(!isMainAddSet.isEmpty()){
                for(List<CoverageSector__c> csList : [SELECT Id FROM CoverageSector__c WHERE CoverageTeam__c IN :isMainAddSet AND IsMain__c=true]){
                    for(CoverageSector__c cs : csList){
                        cs.IsMain__c=false;
                    }
                    update csList;
                }                
            }
            if(!ctUpdateList.isEmpty()){
                update ctUpdateList;
            }
        }
    }
    
    public static void onBeforeDelete(List<CoverageSector__c> trgOld){
        boolean hasPermission = FeatureManagement.checkPermission('CoverageSectorAllowDelete');
        for(CoverageSector__c cs : trgOld){
            if(cs.IsMain__c ){
                if(!hasPermission){
                    cs.addError(Label.CoverageSectorMainDelete);
                }
            }
        }
    }
}