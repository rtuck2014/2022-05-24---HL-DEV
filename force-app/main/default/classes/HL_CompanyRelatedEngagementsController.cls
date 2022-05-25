public with sharing class HL_CompanyRelatedEngagementsController {
    public Account Account {get; set;}
    public ApexPages.StandardSetController setCon {
		 get{
             if(setCon == null){
                setCon = new ApexPages.StandardSetController([SELECT Name, Client__r.Name, Subject__r.Name, Line_of_Business__c, Job_Type__c, Industry_Group__c, Stage__c, LastModifiedDate, Date_Engaged__c, Close_Date__c, Engagement_Number__c, Opportunity_Number__c FROM Engagement__c WHERE ID IN (SELECT Engagement__c FROM Engagement_Client_Subject__c WHERE Client_Subject__c =: Account.ID)
                                                              ORDER BY Date_Engaged__c DESC]);
                setCon.setPageSize(5);
             }
            
             return setCon;
        }set;         
    }
    
    public List<Engagement__c> GetEngList(){
        return setCon.getRecords();
    }
    public HL_CompanyRelatedEngagementsController(ApexPages.StandardController controller){
        Account = (Account)controller.getRecord();
    }
}