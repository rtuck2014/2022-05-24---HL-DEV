public with sharing class HL_MyObjectComponentController {
    public enum SearchObjectType {Contact, Company, Opportunity, Engagement}
    
    private static SearchObjectType ParseSearchObjectTypeEnum(string enumValue){
        SearchObjectType result;
        for(SearchObjectType sot : SearchObjectType.values()){
            if(sot.name() == enumValue){
                result = sot;
                break;
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static Integer GetMobileSearchResultDefault(){
        return (Integer)HL_General__c.getOrgDefaults().Mobile_Search_Result_Default__c;
    }
    
    @AuraEnabled
    public static Integer GetMobileSearchResultLimit(){
        return (Integer)HL_General__c.getOrgDefaults().Mobile_Search_Result_Limit__c;
    }
    
    @AuraEnabled
    public static List<sObject> FindByName(string objectType, string searchTerm, boolean myOnly, integer resultLimit){
        SearchObjectType searchObject = ParseSearchObjectTypeEnum(objectType);
        
        if(searchObject != null)
            return FindByName(searchObject,searchTerm,myOnly, resultLimit);
        
        return new List<sObject>();
    }
    
    public static List<sObject> FindByName(SearchObjectType searchObject, string searchTerm, boolean myOnly, integer resultLimit){
        string selectionFields = GetSelectionFields(searchObject);
        string objectName = searchObject == SearchObjectType.Contact ? 'Contact' :
        					searchObject == SearchObjectType.Company ? 'Account' :
        					searchObject.name() + '__c';
        
        Set<Id> relatedIdSet;
        
        if(myOnly){
            string additionalWhere = searchObject == SearchObjectType.Opportunity || 
                searchObject == SearchObjectType.Engagement ? 'AND Status__c = \'Active\' ' : '';
            
            relatedIdSet = GetRelatedIdSet(searchObject);
            return Database.query('SELECT ' + selectionFields + ' ' +
                                  'FROM ' + objectName + ' ' +
                                  'WHERE Id IN:relatedIdSet ' +
                                  + additionalWhere +
                                  'ORDER BY Name LIMIT ' + resultLimit);
        }
        else
            return search.query(GetSearchClause(objectName, searchTerm, selectionFields, resultLimit))[0]; 
    }
    
    private static Set<Id> GetRelatedIdSet(SearchObjectType searchObject){
        Set<Id> relatedIdSet = new Set<Id>();
        
        if(searchObject == SearchObjectType.Contact){
            for(Relationship__c relationshipRecord : [SELECT External_Contact__c
                                                      FROM Relationship__c 
                                                      WHERE HL_Contact__r.User__c =:UserInfo.getUserId()])
                relatedIdSet.add(relationshipRecord.External_Contact__c);
        }
        else if(searchObject == SearchObjectType.Company){
            for(Relationship__c relationshipRecord : [SELECT External_Contact__r.Account.Id
                                                      FROM Relationship__c 
                                                      WHERE HL_Contact__r.User__c =:UserInfo.getUserId()])
                relatedIdSet.add(relationshipRecord.External_Contact__r.Account.Id);
        }
        else if(searchObject == SearchObjectType.Opportunity){
            for(Opportunity_Internal_Team__c teamRecord : [SELECT Opportunity__c 
                                                           FROM Opportunity_Internal_Team__c 
                                                           WHERE Contact__r.User__c =: UserInfo.getUserId() AND End_Date__c = null])
                relatedIdSet.add(teamRecord.Opportunity__c);         
        }
        else{
            for(Engagement_Internal_Team__c teamRecord : [SELECT Engagement__c 
                                                          FROM Engagement_Internal_Team__c 
                                                          WHERE Contact__r.User__c =: UserInfo.getUserId() AND End_Date__c = null])
                relatedIdSet.add(teamRecord.Engagement__c);
        }
        
        return relatedIdSet;
    }
    
    private static string GetSelectionFields(SearchObjectType searchObject){
        string selectionFields = '';
        
        if(searchObject == SearchObjectType.Contact)
            selectionFields = 'Name, Title, Account.Name';
        else if(searchObject == SearchObjectType.Company)
            selectionFields = 'Name, BillingCity, BillingState';
        else
            selectionFields = 'Name, Client__r.Name, Subject__r.Name';
        
        return selectionFields;
    }
    
    private static List<String> ParseSearchTerms(string searchTerm){
        List<string> searchTermList = new List<string>();
        string baseSearchTerm = String.escapeSingleQuotes(searchTerm.remove('*').remove('%')).trim();
        List<string> searchTermSplitList = baseSearchTerm.split(' ');
        
        searchTermList.add(baseSearchTerm);
        
        //If more than one term, add them all as additional or clauses
        if(searchTermSplitList.size() > 1){
            for(string split : searchTermSplitList)
                searchTermList.add(split);
        }
        
        return searchTermList;
    }
    
    private static String GetSearchClause(string searchObject, string searchTerm, string selectionFields, integer resultLimit){
        List<string> searchTermList = ParseSearchTerms(searchTerm);
        string searchClause =  'FIND \'' + searchTermList[0] + '*';
        
        if(searchTermList.size() > 1){
            searchClause += ' OR (';
            for(integer index = 1; index < searchTermList.size(); index++)
                searchClause += searchTermList[index] + '* AND ';
            searchClause = searchClause.removeEnd('AND ') + ')';
        }
        
        searchClause += '\' IN NAME FIELDS RETURNING ' + searchObject + '(' + selectionFields + ' ORDER BY Name) LIMIT ' + resultLimit;
        
        return searchClause;
    }
}