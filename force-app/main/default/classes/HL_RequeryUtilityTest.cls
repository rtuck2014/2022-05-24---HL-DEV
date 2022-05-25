@isTest
private class HL_RequeryUtilityTest {
    @testSetup
    static void setup() {
        Account a = new Account(
            Name = 'Test Account 1'
        );

        insert a;

        List<Contact> contactsToInsert = new List<Contact>();

        contactsToInsert.add(new Contact(
            AccountId = a.Id,
            FirstName = 'John',
            LastName = 'Smith'
        ));

        contactsToInsert.add(new Contact(
            AccountId = a.Id,
            FirstName = 'Jane',
            LastName = 'Doe'
        ));

        insert contactsToInsert;
    }

    @isTest
    static void testSuccess() {
        List<Contact> contacts = [
            SELECT Id, LastName, Account.Name
            FROM Contact
        ];

        Test.startTest();

        HL_RequeryUtility.SObjectsMetadata meta = HL_RequeryUtility.getMetadata(contacts);

        List<SObject> requeriedContacts = HL_RequeryUtility.requery(meta.objIds, meta.sobjType, meta.fields);

        Test.stopTest();

        for (Integer i = 0; i < contacts.size(); i++) {
            Contact originalContact = contacts.get(i);
            Contact requeriedContact = (Contact) requeriedContacts.get(i);

            System.assertEquals(originalContact.Id, requeriedContact.Id);
            System.assertEquals(null, requeriedContact.FirstName);
            System.assertEquals(originalContact.LastName, requeriedContact.LastName);
            System.assertEquals(originalContact.Account.Name, requeriedContact.Account.Name);
        }
    }
}