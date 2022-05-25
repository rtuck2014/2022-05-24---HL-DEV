public with sharing class HL_Contact {
    public static final string STANDARD_SELECT = 'SELECT Name, Contact_Full_Name__c, User__c, Account.Name, Department, Title, Email, Hourly_Rate__c, Is_Foreign_Office__c, Office__c, Line_Of_Business__c, Industry_Group__C, Phone, MobilePhone, Registered__c, Staff_Type__c, RecordType.DeveloperName ';
    @AuraEnabled
    public static Contact GetById(string Id){
        List<Contact> c = Database.query(STANDARD_SELECT + 'FROM Contact WHERE Id =: Id');
        return c.size() > 0 ? c[0] : null;
    }

    public static List<Contact> GetList(List<Contact> contacts){
        return Database.query(STANDARD_SELECT + 'FROM Contact WHERE Id IN: contacts');
    }

    public static List<Contact> GetListByUsers(List<User> users){
        return Database.query(STANDARD_SELECT + 'FROM Contact WHERE User__c IN: users');
    }

    public static Map<Id, Contact> GetMap(List<Contact> contacts){
        List<Contact> contactList = GetList(contacts);
        return new Map<Id, Contact>(contactList);
    }

    public static Map<Id, Contact> GetMapByUsers(List<User> users){
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact c : GetListByUsers(users))
            contactMap.put(c.User__c, c);
        return contactMap;
    }

    @AuraEnabled
    public static Contact GetByUserId(){
        return GetByUserId(UserInfo.getUserId());
    }
    @AuraEnabled
    public static Contact GetByUserId(id userId){
        List<Contact> c = [SELECT Name, User__c, Account.Name, Department, Title, Email, Hourly_Rate__c, Is_Foreign_Office__c, Office__c, Line_Of_Business__c, Phone, MobilePhone, Registered__c, Staff_Type__c, Industry_Group__c FROM Contact WHERE User__c =: userId];
        return c.size() > 0 ? c[0] : new Contact();
    }
     @AuraEnabled
    public static list<Id> GetByUserIdset(id userId){
    list<Id> conSet = new list<Id>();
        for(contact con : [SELECT Id,Name, User__c, Account.Name, Department, Title, Email, Hourly_Rate__c, Is_Foreign_Office__c, Office__c, Line_Of_Business__c, Phone, MobilePhone, Registered__c, Staff_Type__c, Industry_Group__c FROM Contact WHERE User__c =: userId]){
       conSet.add(con.Id);
        }
        
        return conSet;
    }
    public static List<Contact> GetByCompany(id companyId)
    {
        return [SELECT Name FROM Contact WHERE Account.Id =: companyId];
    }
    
       public static Id GetByContactUserId(id contactId){
        return [SELECT User__c FROM Contact WHERE Id =: contactId limit 1].User__c;
    }
}