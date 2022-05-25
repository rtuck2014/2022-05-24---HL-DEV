public with sharing class HL_CompanyRelatedOppsController {
    public Account Account {get; set;}
    public ApexPages.StandardSetController setCon {
		 get{
             if(setCon == null){
                setCon = new ApexPages.StandardSetController([SELECT Name, Client__r.Name, Subject__r.Name, Line_of_Business__c, Job_Type__c, Industry_Group__c, Stage__c, Opportunity_Number__c, LastModifiedDate FROM Opportunity__c 
                                                              WHERE ID IN (SELECT Opportunity__c FROM Opportunity_Client_Subject__c WHERE Client_Subject__c =: Account.Id)
                                                              AND Stage__c != 'Engaged'
                                                              ORDER BY LastModifiedDate DESC]);
                setCon.setPageSize(5);
             }
            
             return setCon;
        }set;         
    }
    
    public List<Opportunity__c> GetOppList(){
        return setCon.getRecords();
    }
    public HL_CompanyRelatedOppsController(ApexPages.StandardController controller){
        Account = (Account)controller.getRecord();
    }
}