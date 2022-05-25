public with sharing class HL_CompaniesClosedWithController {
	public Engagement__c Eng {get; set;}
    
	public ApexPages.StandardSetController setcon {
		get {
			if(setcon == null){
				setcon = new ApexPages.StandardSetController ([SELECT Id, Company__c, Company__r.Name, Type__c, Status__c, Date_of_Last_Status_Change__c 
														FROM Engagement_Counterparty__c WHERE Engagement__c =: Eng.Id 
														AND Id IN (SELECT Engagement_Counterparty__c FROM Bid__c WHERE Round__c = 'Closing')
                                                        ORDER BY Company__r.NAME ASC]);
			}
			return setcon;
		}set;
	}
    
    public List<Engagement_Counterparty__c> GetCPList(){
        return setCon.getRecords();
    }
    
    public HL_CompaniesClosedWithController(ApexPages.StandardController controller){
        Eng = (Engagement__c)controller.getRecord();
    }

}