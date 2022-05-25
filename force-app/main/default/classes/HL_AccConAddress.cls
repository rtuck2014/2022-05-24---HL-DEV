global class HL_AccConAddress
{
    @AuraEnabled 
    webservice static void updateContactAddress(String AccID)
    {
        Account company = [SELECT Id,
                                    BillingStreet,
                                    BillingCity,
                                    BillingState,
                                    BillingPostalCode,
                                    BillingCountry
                                FROM Account WHERE Id =: AccID LIMIT 1];
        List<Contact> contactsToUpdate = [SELECT Id,
                                                AccountId,
                                                MailingStreet,
                                                MailingCity,
                                                MailingState,
                                                MailingPostalCode,
                                                MailingCountry,
                                                Inherit_Company_Address__c
                                            FROM Contact WHERE AccountId =: AccID AND Inherit_Company_Address__c = true];
        for(Contact c : contactsToUpdate){
            c.MailingStreet = company.BillingStreet;
            c.MailingCity = company.BillingCity;
            c.MailingState = company.BillingState;
            c.MailingPostalCode = company.BillingPostalCode;
            c.MailingCountry = company.BillingCountry;
        }
        if(contactsToUpdate.size() > 0)
            update contactsToUpdate;
    }
}