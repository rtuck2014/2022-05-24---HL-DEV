/*
* Name: CustomLookupController 
* Created Date: 09/20/2019
* Created By: Kishan J
* Functionality : controller class for lookupComponent lwc
*/
public with sharing class CustomLookupController {
    
    @AuraEnabled
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField, String subField, String whereClauseFilters, String additionalFields){
        List<SObject> sObjectList = new List<SObject>();
        if(String.isNotBlank(searchKey)){
            String key = '%' + searchKey + '%';
            String query;
            String fields;
            if(!String.isBlank(subField)){
                fields = subField;   
            }
            if(!String.isBlank(additionalFields)){
                fields = fields +','+additionalFields;
            }
            String selectClause = 'SELECT Id, '+searchField +','+fields;
            query = selectClause + ' FROM '+objectName +' WHERE '+searchField +' LIKE :key '+ whereClauseFilters +' LIMIT 50';
            System.debug('query>>>'+query);
            sObjectList = Database.query(query);
        }
        return sObjectList;
    }
}