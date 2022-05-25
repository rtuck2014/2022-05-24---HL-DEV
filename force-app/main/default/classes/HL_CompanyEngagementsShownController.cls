public with sharing class HL_CompanyEngagementsShownController {
    public Account Account {get; set;}
    public ApexPages.StandardSetController setCon {
         get{
             if(setCon == null){
                setCon = new ApexPages.StandardSetController([SELECT Initial_Contact__c, Status__c, Engagement__c, Engagement__r.Name, Engagement__r.Client__c, Engagement__r.Client__r.Name, Engagement__r.Subject__c, Engagement__r.Subject__r.Name, Engagement__r.Line_of_Business__c, Engagement__r.Job_Type__c, Engagement__r.Industry_Group__c, Engagement__r.Stage__c, Engagement__r.Engagement_Number__c
                                                              FROM Engagement_Counterparty__c WHERE Company__c =: Account.ID
                                                              ORDER BY Initial_Contact__c DESC]);
                setCon.setPageSize(5);
             }
            
             return setCon;
        }set;         
    }
    
    public List<Engagement_Counterparty__c> GetEngList(){
        return setCon.getRecords();
    }
    public HL_CompanyEngagementsShownController(ApexPages.StandardController controller){
        Account = (Account)controller.getRecord();
    }
}