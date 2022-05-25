global with sharing class HL_AutoCompleteController {
    @AuraEnabled
    @RemoteAction
    global static List<sObject> GetSuggestions(String sObjectType, String subType, String term, String fieldsToGet, String additionalFilter, Integer limitSize) {
        String fields = fieldsToGet.length() > 0 ? ',' + fieldsToGet : ''; 
        String soql = 
            ' SELECT Name, Id ' + String.escapeSingleQuotes(fields) +
            ' FROM '   + String.escapeSingleQuotes(sObjectType) +
            GetWhereClause(sObjectType, subType, term) + additionalFilter + 
            ' ORDER BY NAME ' + 
            ' LIMIT ' + limitSize;
        return Database.query(soql);
    }
    
    
    @AuraEnabled
    global static String GetWhereClause(String sObjectType, String subType, String term){
        HL_Search s = new HL_Search(term, sObjectType == 'Opportunity__c');
        String whereClause = ' WHERE (Name Like \'' + s.SearchTerm + '%\' ';
        String t1, t2;  //Parsed Search Terms
        if(sObjectType == 'Contact')
        {
            if(s.HasMultiple)
            {
                s= new HL_Search(term,false);
                t1 = s.Term01;
                t2 = s.Term02;
                whereClause += ' OR (FirstName LIKE \'' + t1 + '\' AND LastName LIKE \'' + t2 + '\') OR (FirstName LIKE \'' + t2 + '\' AND LastName LIKE \'' + t1 + '\') OR (FirstName LIKE \'' + s.SearchTerm + '\' OR LastName LIKE \'' + s.SearchTerm + '\') ';
            }
            else{
                whereClause += ' OR LastName LIKE \'' + s.SearchTerm + '%\' ';    
            }
        }
        
        whereClause += ') ';
        if(subType == 'Employee')
            whereClause += ' AND RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\' ';
        if(subType == 'External')
            whereClause += ' AND RecordType.Name = \'External Contact\' ';
        if(subType == 'DistributionList')
            whereClause += ' AND (RecordType.Name = \'Distribution Lists\' OR (RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\')) ';
        if(subType == 'CampaignList')
            whereClause += ' AND (RecordType.Name = \'Conference / Event\' OR RecordType.Name = \'Insights / Content\') ';
        
        return  whereClause;
    }
}