public with sharing class HL_Campaign {
    public static final string STANDARD_SELECT = 'SELECT Name,RecordType.name,Type';

    @AuraEnabled
    public static Campaign GetById(string Id){
    Campaign sds= [SELECT name,RecordType.name,type FROM Campaign WHERE Id =: Id];
    return sds;
    }
}