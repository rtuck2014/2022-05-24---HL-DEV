public with sharing class HL_Company {
    public static final string STANDARD_SELECT = 'SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Client_Number__c, Phone, Industry_Group__c ';

    @AuraEnabled
    public static Account GetById(Id acctId){
        //Modified as part of State/Country Picklist
        List<Account> a = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingCountryCode, BillingStateCode FROM Account WHERE Id=:acctId];
        return a.size() > 0 ? a[0] : new Account();
    }

    public static List<Coverage_Team__c> GetCoverageTeamAggregate(Id acctId){
        Account a = [SELECT Id, CapIQ_Company__c, Ultimate_Parent__c FROM Account WHERE Id =: acctId];
        Set<Id> sponsorAccts = new Set<Id>();

        if(a.CapIQ_Company__c <> null){
            for(List<Investment__c> iList : [SELECT Sponsor_CapIQ_Company__c FROM Investment__c WHERE Portfolio_CapIQ_Company__c =: a.CapIQ_Company__c AND Status__c = 'Current'])
            {
                for(Investment__c i : iList){
                    if(i.Sponsor_CapIQ_Company__c <> null)
                        sponsorAccts.Add(i.Sponsor_CapIQ_Company__c);
                }
            }
        }

        List<Coverage_Team__c> ct = [SELECT Officer__r.Name, Company__r.Name, RecordType.Name, Coverage_Level__c, Coverage_Type__c, Tier__c, Line_of_Business__c, Product_Specialty__c, Sector__c, Industry_Group__c, Company__r.BillingCity, Company__r.BillingState, Company__r.BillingCountry
                                     FROM Coverage_Team__c
                                     WHERE (Company__c =: a.Id
                                             OR Company__c =: a.Ultimate_Parent__c
                                             OR (Company__r.Ultimate_Parent__c <> null AND (Company__r.Ultimate_Parent__c =: a.Ultimate_Parent__c OR Company__r.Ultimate_Parent__c =: a.Id))
                                             OR Company__r.CapIQ_Company__c IN : sponsorAccts
                                           )
                                     AND RecordType.DeveloperName = 'FS_Coverage_Team_Member'
                                     AND Coverage_Team_Status__c = 'Active'
                                     AND Officer__r.Status__c = 'Active'
                                     ORDER BY Officer__r.Name, Company__r.Name];
        return ct;
    }
}