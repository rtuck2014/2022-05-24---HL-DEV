public class HLEngContactCounterPartyController {

    @AuraEnabled
    public static List<Contact> searchContacts(String recordId,String searchTerm ,String selectedRadioButton) {
        
        
        System.debug(recordId);
        System.debug(searchTerm);
        System.debug(selectedRadioButton);
        Id externalContactRT = HL_Utility.GetRecordTypeId('External Contact');
        Set<id> existingContactIdSet = new Set<Id>();
        String engCPCompany = '';
        for(Engagement_Counterparty__c engCounterparty: [Select Id, Company__c,Company__r.Name,(Select Id, Contact__c, Counterparty__c
                                                                                                FROM Engagement_Counterparty_Contacts__r) 
                                                         FROM Engagement_Counterparty__c 
                                                         WHERE ID =: recordId])
        {
            for(Engagement_Counterparty_Contact__c ecc: engCounterparty.Engagement_Counterparty_Contacts__r){
                existingContactIdSet.add(ecc.Contact__c);
            }
            engCPCompany = engCounterparty.Company__r.Name;
        }  
        String query = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Name,(Select Industry__r.Name From Contact_Industries__r ) from Contact ';
        String whereClause = '';
        String orderby = ' order by Name ';
        String limitClause = ' LIMIT 1000';
        searchTerm = '%'+searchTerm+'%';
        
        if(selectedRadioButton == 'Name'){
            whereClause = ' Where RecordTypeId =: externalContactRT AND ID NOT IN:existingContactIdSet AND (FirstName LIKE :searchTerm OR MiddleName LIKE :searchTerm OR LastName LIKE :searchTerm OR Name LIKE :searchTerm) ';
        }else if(selectedRadioButton == 'Company'){
            whereClause = ' Where RecordTypeId =: externalContactRT AND ID NOT IN:existingContactIdSet AND Account.Name LIKE:searchTerm '; 
        }else if(selectedRadioButton == 'Industry/Product Focus'){
            set<Id> IndstrycontactIdSet = new set<Id>();   
            System.debug('existingContactIdSet'+existingContactIdSet);
            System.debug('searchTerm'+searchTerm);
            for(Industry_Focus__c iFocus : [SELECT Id,Contact__c,Industry_Group__c,Industry__r.Name,Industry__c
                                            FROM Industry_Focus__c 
                                            WHERE Contact__c NOT IN : existingContactIdSet AND Industry__r.Name LIKE : searchTerm ORDER BY  Contact__r.CREATEDDATE DESC ])
            {            
                IndstrycontactIdSet.add(iFocus.Contact__c);
            }
            System.debug('IndstrycontactIdSet'+IndstrycontactIdSet.size());
            
            whereClause = '  Where RecordTypeId =: externalContactRT AND Id IN : IndstrycontactIdSet ';  
        }else{
            whereClause = ' Where RecordTypeId =: externalContactRT AND ID NOT IN:existingContactIdSet and  Account.Name =:engCPCompany';
        }
        query = query+whereClause+orderby+limitClause;
        
        
        System.debug('externalContactRT : '+externalContactRT);
        System.debug('searchTerm'+searchTerm);
        System.debug('query : '+query);
   
        
        
        return Database.query(query);
    }
    
    
   
    
    @AuraEnabled
    public static List<Contact> filterData(String recordId,String filters,String searchTerm,String selectedRadioButton,List<Contact> contactList){
        //List<Contact> contactList = new List<Contact>();
        //contactList = searchContacts(recordId,searchTerm,selectedRadioButton);
        filterclass filterObject = (filterclass)JSON.deserialize(filters,filterclass.class);
        
        set<Id> IndstrycontactIdSet = new set<Id>();
        
        String LastNameString ;
        String FirstNameString;
        String titleString;
        String accountNameString;
        String departmentString;
        String conIndustryNameString;
        String Name;
        String companyName;
        System.debug('contactList'+contactList);
        system.debug('contactList Size'+contactList.size());
        System.debug(filterObject == null);
        Id externalContactRT = HL_Utility.GetRecordTypeId('External Contact');
        Set<id> existingContactIdSet = new Set<Id>();
        for(Engagement_Counterparty__c engCounterparty: [Select Id, Company__c,Company__r.Name,(Select Id, Contact__c, Counterparty__c
                                                                                                FROM Engagement_Counterparty_Contacts__r) 
                                                         FROM Engagement_Counterparty__c 
                                                         WHERE ID =: recordId])
        {
            for(Engagement_Counterparty_Contact__c ecc: engCounterparty.Engagement_Counterparty_Contacts__r){
                existingContactIdSet.add(ecc.Contact__c);
            }
        }  
        
        String filterDataWhereClause = ' ID NOT in:existingContactIdSet AND RecordTypeId =: externalContactRT AND';
        
        if(filterObject!=null){
            if(String.isNotBlank(filterObject.lastName)){
                String trimmedSearchString = filterObject.lastName.trim();
                LastNameString = '%'+ trimmedSearchString + '%';
                filterDataWhereClause = filterDataWhereClause +  ' LastName LIKE :LastNameString AND';
            }
            if(String.isNotBlank(filterObject.firstName)){
                String trimmedSearchString = filterObject.firstName.trim();
                FirstNameString = '%'+ trimmedSearchString + '%';
                filterDataWhereClause = filterDataWhereClause +  ' FirstName LIKE :FirstNameString AND';
                //filterString = filterString + 'Last Name ('+trimmedSearchString+'), '; 
            }
            if(String.isNotBlank(filterObject.Title)){
                String trimmedSearchString = filterObject.Title.trim();
                titleString = '%'+ trimmedSearchString + '%';
                filterDataWhereClause = filterDataWhereClause +  ' Title LIKE :titleString AND';
                //filterString = filterString + 'Last Name ('+trimmedSearchString+'), '; 
            }
            if(String.isNotBlank(filterObject.accountName)){
                String trimmedSearchString = filterObject.accountName.trim();
                accountNameString = '%'+ trimmedSearchString + '%';
                filterDataWhereClause = filterDataWhereClause +  ' Account.Name LIKE :accountNameString AND';
            }
            if(String.isNotBlank(filterObject.department)){
                String trimmedSearchString = filterObject.department.trim();
                departmentString = '%'+ trimmedSearchString + '%';
                filterDataWhereClause = filterDataWhereClause +  ' department LIKE :departmentString AND';
                //filterString = filterString + 'Last Name ('+trimmedSearchString+'), '; 
            }
            if(String.isNotBlank(filterObject.industryFocus)){
                String trimmedSearchString = filterObject.industryFocus.trim();
                conIndustryNameString = '%'+ trimmedSearchString + '%';
                
                for(Industry_Focus__c iFocus : [Select id, Contact__c from Industry_Focus__c WHERE Industry__r.Name LIKE : conIndustryNameString AND Contact__c IN :ContactList]){
                    IndstrycontactIdSet.add(iFocus.Contact__c);
                }
                filterDataWhereClause = filterDataWhereClause +  ' ID IN : IndstrycontactIdSet AND';
            }
            
            if(string.isNotBlank(searchTerm)){
                if(selectedRadioButton == 'Name'){
                    String trimmedSearchString = searchTerm.trim();
                    Name = '%'+ trimmedSearchString + '%';
                    filterDataWhereClause = filterDataWhereClause +  ' Name LIKE :Name AND';
                } 
                if(selectedRadioButton == 'Company'){
                    String trimmedSearchString = searchTerm.trim();
                    companyName = '%'+ trimmedSearchString + '%';
                    if(!filterDataWhereClause.contains('Account.Name')){
                        filterDataWhereClause = filterDataWhereClause +  ' Account.Name LIKE:companyName AND';
                    }
                } 
                if(selectedRadioButton == 'Industry/Product Focus'){
                
                String trimmedSearchString = searchTerm.trim();
                trimmedSearchString = '%'+ trimmedSearchString + '%';
                for(Industry_Focus__c iFocus : [SELECT Id,Contact__c,Industry_Group__c,Industry__r.Name,Industry__c
                                                FROM Industry_Focus__c 
                                                WHERE Contact__c NOT IN : existingContactIdSet AND Industry__r.Name LIKE : searchTerm ORDER BY  Contact__r.CREATEDDATE DESC ])
                {            
                    IndstrycontactIdSet.add(iFocus.Contact__c);
                }
                if(IndstrycontactIdSet.size() > 0)
                {
                    if(!filterDataWhereClause.contains('ID IN : IndstrycontactIdSet')){
                        filterDataWhereClause = filterDataWhereClause +' Id IN : IndstrycontactIdSet AND';
                    }
                }
            }
            }
            filterDataWhereClause = filterDataWhereClause.removeEndIgnoreCase('AND');
            String query = 'select id,Lastname,Firstname,Department,Title,AccountId,Account.Name,Status__c,Name,(Select Industry__r.Name From Contact_Industries__r ) from Contact '+(filterDataWhereClause!=''?' WHERE ':'')+filterDataWhereClause +' ORDER BY Name LIMIT 1000';
            System.debug('query: '+query);
            return Database.query(query);
        }else{
            return searchContacts(recordId,searchTerm,selectedRadioButton);
        }
        
    }
    
    @AuraEnabled
    public static void saveEngagementContacts(List<String> contactIds,Id recordId){
        List<Engagement_Counterparty_Contact__c> insertList = new List<Engagement_Counterparty_Contact__c>();
        for(String contactId : contactIds){
            Engagement_Counterparty_Contact__c record = new Engagement_Counterparty_Contact__c();
            record.Contact__c  = contactId;
            record.Counterparty__c   = recordId;
            record.Type__c = 'Primary';
            insertList.add(record);
        }
        
        if(!insertList.isEmpty()){
            insert insertList;
        }
        system.debug(insertList);
        system.debug('insertList Isze : '+insertList.size());
        
    }
    
    public class filterclass{
        public String lastName;
        public String firstName;
        public String title;
        public String accountName;
        public String department;
        public String industryFocus;
        
    }
    
}