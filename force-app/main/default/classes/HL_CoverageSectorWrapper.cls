public inherited sharing class HL_CoverageSectorWrapper {
    public String newCoverageTeamId {get;set;}
    public String coverageTeamType {get;set;}
    public boolean isMain {get;set;}
    public HL_CoverageSectorWrapper(ApexPages.StandardController con){
        CoverageSector__c sector = (CoverageSector__c)con.getRecord();
        System.debug('isMain:'+sector.IsMain__c);
        isMain=sector.IsMain__c;
        if(sector.Id==null && sector.CoverageTeam__c!=null){
            Coverage_Team__c ct = [SELECT Id,CoverageTypeLookup__c,(SELECT Id FROM CoverageSectors__r) FROM Coverage_Team__c WHERE Id=:sector.CoverageTeam__c];
            System.debug('ct:'+ct.CoverageSectors__r.isEmpty());
            isMain = ct.CoverageSectors__r.isEmpty();
            coverageTeamType = ct.CoverageTypeLookup__c;
        }
    }
    public PageReference handleRedirect(){
        PageReference pr = new PageReference('/'+newCoverageTeamId);
        return pr;
    }
}