public with sharing class HL_ContactRelatedOppsController {
    public Contact Contact {get; set;}
    public ApexPages.StandardSetController setCon {
         get{
             if(setCon == null){
                setCon = new ApexPages.StandardSetController([SELECT Name, Client__r.Name, Subject__r.Name, Line_of_Business__c, Job_Type__c, Industry_Group__c, Stage__c, Opportunity_Number__c, LastModifiedDate FROM Opportunity__c 
                                                              WHERE ID IN (SELECT Opportunity__c FROM Opportunity_External_Team__c WHERE Contact__c =: Contact.Id)
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
    public HL_ContactRelatedOppsController(ApexPages.StandardController controller){
        Contact = (Contact)controller.getRecord();
    }
}