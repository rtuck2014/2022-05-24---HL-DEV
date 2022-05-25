public with sharing class HL_CoverageTeamController {
    public List<Coverage_Team__c> CoverageTeamList;
    public boolean IsCapIQCompanyRelated{get; set;}
    private Id RecordId{get;set;}    
    
    public HL_CoverageTeamController(ApexPages.StandardController stdController){
        IsCapIQCompanyRelated = false;
        RecordId = ApexPages.currentPage().getParameters().get('Id');                
        CoverageTeamList = [SELECT Name, Company__c, Company__r.CapIQ_Company__c 
                            FROM Coverage_Team__c 
                            WHERE Id =: recordId
                            AND ((Coverage_Team__c.Company__r.CapIQ_Company__c != null))];     
        
        if(CoverageTeamList.size() > 0){
            IsCapIQCompanyRelated = true;            
        }
        else{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info,'"Offsite Template" cannot be created unless CapIQ Company has been linked on the Company Page.');
            ApexPages.addMessage(msg);
        }
    }
    
    public PageReference  CheckRecordType(){
        Coverage_Team__c coverageTeam = [SELECT RecordType.DeveloperName, Company__r.RecordType.DeveloperName
                                         FROM Coverage_Team__c 
                                         WHERE Id=: recordId LIMIT 1];   
        
        if(coverageTeam != null && ((coverageTeam.Company__r.RecordType.DeveloperName == 'Houlihan_Company') || 
                                    (coverageTeam.RecordType.DeveloperName != 'FS_Coverage_Team_Member'))) {            
            PageReference pageRef = new PageReference('/'+RecordId+'?nooverride=1');
            return pageRef;             
        }
        else        
            return null;       
    }
    
}