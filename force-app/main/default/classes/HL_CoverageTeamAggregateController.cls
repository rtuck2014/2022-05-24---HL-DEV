public with sharing class HL_CoverageTeamAggregateController {
    public Id EntityId {get; set;}
    public List<Coverage_Team__c> CoverageTeam {get{
        if(coverageTeam == null)
            coverageTeam = HL_Company.GetCoverageTeamAggregate(EntityId);
        return coverageTeam;
    }set;}
    public HL_CoverageTeamAggregateController(ApexPages.StandardController controller){
        EntityId = controller.getId();
    }
}