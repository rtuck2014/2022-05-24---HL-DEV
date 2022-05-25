public with sharing class HLSectorDependentPicklist {
    
    @AuraEnabled(cacheable=true)
    public static List<wrapper> getCoverageType(){
        List<wrapper> wList = new List<wrapper>();
        for(AggregateResult ar : [SELECT CoverageType__c,CoverageType__r.Name ctName FROM Coverage_Sector_Dependency__c group by CoverageType__c,CoverageType__r.Name order by CoverageType__r.Name]){
            wList.add(new wrapper((String)ar.get('CoverageType__c'),(String)ar.get('ctName')));
        }        
        return wList;        
    }

    @AuraEnabled(cacheable=true)
    public static List<wrapper> getPrimaryCoverage(Id coverageTypeId){
        List<wrapper> wList = new List<wrapper>();
        for(AggregateResult ar : [SELECT PrimarySector__c,PrimarySector__r.Name psName FROM Coverage_Sector_Dependency__c WHERE CoverageType__c=:coverageTypeId AND PrimarySector__c!='' group by PrimarySector__c,PrimarySector__r.Name order by PrimarySector__r.Name]){
            wList.add(new wrapper((String)ar.get('PrimarySector__c'),(String)ar.get('psName')));
        }        
        return wList;        
    }

    @AuraEnabled(cacheable=true)
    public static List<wrapper> getSecondaryCoverage(Id coverageTypeId, Id primarySectorId){
        List<wrapper> wList = new List<wrapper>();
        for(AggregateResult ar : [SELECT SecondarySector__c,SecondarySector__r.Name ssName FROM Coverage_Sector_Dependency__c WHERE CoverageType__c=:coverageTypeId AND PrimarySector__c=:primarySectorId AND SecondarySector__c!='' group by SecondarySector__c,SecondarySector__r.Name order by SecondarySector__r.Name]){
            wList.add(new wrapper((String)ar.get('SecondarySector__c'),(String)ar.get('ssName')));
        }        
        return wList;
    }

    @AuraEnabled(cacheable=true)
    public static List<wrapper> getTertiaryCoverage(Id coverageTypeId, Id primarySectorId,Id secondarySectorId){
        List<wrapper> wList = new List<wrapper>();
        for(AggregateResult ar : [SELECT TertiarySector__c,TertiarySector__r.Name tsName FROM Coverage_Sector_Dependency__c WHERE CoverageType__c=:coverageTypeId AND PrimarySector__c=:primarySectorId AND SecondarySector__c=:secondarySectorId AND TertiarySector__c!='' group by TertiarySector__c,TertiarySector__r.Name order by TertiarySector__r.Name]){            
            wList.add(new wrapper((String)ar.get('TertiarySector__c'),(String)ar.get('tsName')));            
        }
        return wList;   
    }

    public class wrapper{
        public wrapper(String value,String label){
            this.label=label;
            this.value=value;
        }
        @AuraEnabled        
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }
}