public with sharing class HL_Investment {
    public HL_Investment() {}

    public static List<Investment__c> GetBySponsors(Set<Id> sponsors){
        return [SELECT Name, Amount_of_Investment__c, Date_Sold__c, Description__c, EBITDA_CapIQ__c, EBITDA_HL__c,  HL_Industry_Sector__c,
                       HL_Industry_LK__c, HL_Industry_LK__r.Industry_Group__c, HL_Industry_LK__r.Industry_Sector__c, Industry__c, Investment_Date__c, Portfolio_CapIQ_Company__r.Name, 
                       Expected_Exit_Date__c, Related_Fund__r.Name, Revenue_CapIQ__c, Revenue_HL__c, Status__c, Sponsor_CapIQ_Company__c, Sponsor_CapIQ_Company__r.Name, Actual_Relationship_Type__c 
                FROM Investment__c 
                WHERE Sponsor_CapIQ_Company__c <> null AND Sponsor_CapIQ_Company__c IN:sponsors];
    }
}