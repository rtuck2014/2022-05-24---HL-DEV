public with sharing class HL_ContactController {
@AuraEnabled
    public static List<Contact> FindAll() {
        List<Contact> contactList = new List<Contact>(); 
		for (Relationship__c r : [SELECT External_Contact__r.Id, External_Contact__r.Name,External_Contact__r.Title, External_Contact__r.Company_Name__c, External_Contact__r.MAILINGLATITUDE, External_Contact__r.MAILINGLONGITUDE FROM Relationship__c WHERE HL_Contact__r.User__c =: UserInfo.GetUserId()])
             contactList.add(r.External_Contact__r); 
		return contactList;
    }    
    @AuraEnabled
    public static List<Contact> FindAllByLocation(Decimal NElng,Decimal NElat,Decimal SWlng, Decimal SWlat) {     
        List<Contact> contactList = new List<Contact>(); 
		for (Relationship__c r : [SELECT External_Contact__r.Id, External_Contact__r.Name,External_Contact__r.Title, External_Contact__r.Company_Name__c, External_Contact__r.MAILINGLATITUDE, External_Contact__r.MAILINGLONGITUDE FROM Relationship__c 
                                  WHERE HL_Contact__r.User__c =: UserInfo.GetUserId()
                                 AND (External_Contact__r.MAILINGLATITUDE >: SWlat AND External_Contact__r.MAILINGLATITUDE <: NElat)
                                 AND (External_Contact__r.MAILINGLONGITUDE >: SWlng AND External_Contact__r.MAILINGLONGITUDE <: NElng)])
             contactList.add(r.External_Contact__r); 
		return contactList;

    }
    

}