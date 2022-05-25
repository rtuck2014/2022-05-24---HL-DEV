@isTest
private class Test_HL_AccConAddress {
    @isTest private static void TestAccConAddressUpdate(){
        //Modified as part of State/Country Picklist - Assigned correct Country and State values
        Account a = new Account(
                                name ='test', 
                                BillingStreet='123 street', 
                                BillingCity='city1',
                                BillingState='California',
                                BillingPostalCode='12345',
                                BillingCountry='United States'
                                );
        insert a;
        List<Contact> clist = SL_TestSetupUtils.CreateContact('',200,SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT);
            for(contact c : clist){
                c.AccountId = a.Id;
                c.MailingStreet = 'a';
                c.MailingCity = 'b';
                c.MailingState = 'California';
                c.MailingPostalCode = '99999';
                c.MailingCountry = 'United States';
                c.Inherit_Company_Address__c = true;
            }
        insert clist;

        Test.startTest();
        HL_AccConAddress.updateContactAddress(a.Id);
        Test.stopTest();

        List<Contact> checkList = [SELECT 
                                        Id, 
                                        MailingStreet, 
                                        MailingCity, 
                                        MailingState, 
                                        MailingCountry, 
                                        MailingPostalCode 
                                    FROM Contact WHERE AccountId=:a.Id];

        for (Integer i = 0; i<checkList.size(); i++ ){
            system.assertEquals(a.BillingStreet,checkList[i].MailingStreet);
            system.assertEquals(a.BillingCity,checkList[i].MailingCity);            
            system.assertEquals(a.BillingState,checkList[i].MailingState);
            system.assertEquals(a.BillingPostalCode,checkList[i].MailingPostalCode);
            system.assertEquals(a.BillingCountry,checkList[i].MailingCountry);      
        }
    }

}