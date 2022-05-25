public with sharing class HL_AddCounterpartyController {
     
    //Used to fetch data and construct the Enagegemnt Company List table by passing FieldSet name as one of the parameter
    @AuraEnabled 
    public static String getFieldsAndRecords(String strObjectApiName, String strfieldSetName,
                                             String criteriaField, String criteriaFieldValue, String existingEngagementId){
                                                 Map<String, String> returnMap = new Map<String,String>();
                                                 if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){
                                                     //get fields from FieldSet
                                                     SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
                                                     List<Schema.FieldSetMember> lstFSMember = 
                                                         sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();
                                                     
                                                     //prepare SOQL query based on fieldAPIs 
                                                     String query = 'SELECT ';
                                                     for(Schema.FieldSetMember f : lstFSMember) {
                                                         query += f.getFieldPath() + ', ';
                                                     }
                                                     query += 'Id,Company__r.Name FROM ' + strObjectApiName ;
                                                     
                                                     //Just in case criteria field not specified then it will return all records
                                                     if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                                                         query += ' WHERE ' + criteriaField + '=\'' + criteriaFieldValue + '\'';
                                                     }
                                                     
                                                     //execute query
                                                     //List<SObject> lstRecords = Database.query(query);
                                                     
                                                     List<Company_List_Member__c> lstRecords = (List<Company_List_Member__c>)Database.query(query);
                                                     Map<String,Engagement_CounterParty__c> existingCPmapping = new Map<String,Engagement_CounterParty__c>();
                                                     for(Engagement_CounterParty__c inx:[Select id,Company__c 
                                                                                         from Engagement_CounterParty__c where Engagement__c =:existingEngagementId 
                                                                                         and Company__c!=null]){
                                                                                             
                                                         existingCPmapping.put(inx.Company__c,inx);
                                                     }
                                                     
                                                     List<Company_List_Member__c> newRecords = new List<Company_List_Member__c>();
                                                     List<Company_List_Member__c> existingClonedRecords = new List<Company_List_Member__c>();
                                                     for(Company_List_Member__c inx : lstRecords){
                                                         if(!existingCPmapping.containsKey(inx.Company__c)){
                                                             newRecords.add(inx);
                                                         }else{
                                                             existingClonedRecords.add(inx);
                                                         }
                                                     }
                                                     
                                                     returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
                                                     returnMap.put('NEW_RECORD_LIST', JSON.serialize(newRecords));
                                                     returnMap.put('CLONED_RECORD_LIST', JSON.serialize(existingClonedRecords));
                                                     return JSON.serialize(returnMap);
                                                 }
                                                 return null;
                                             }
    
    //Used to fetch data and construct the Engagement Counterparty tables by passing FieldSet name as one of the parameter
    @AuraEnabled 
    public static String getFieldsAndRecordsEngagement(String strObjectApiName, String strfieldSetName,
                                             String criteriaField, String criteriaFieldValue, String existingEngagementId){
                                                 Map<String, String> returnMap = new Map<String,String>();
                                                 if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){
                                                     //get fields from FieldSet
                                                     SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
                                                     List<Schema.FieldSetMember> lstFSMember = 
                                                         sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();
                                                     
                                                     //prepare SOQL query based on fieldAPIs 
                                                     String query = 'SELECT ';
                                                     for(Schema.FieldSetMember f : lstFSMember) {
                                                         query += f.getFieldPath() + ', ';
                                                     }
                                                     query += 'Id,Company__r.Name   FROM ' + strObjectApiName ;
                                                     
                                                     //Just in case criteria field not specified then it will return all records
                                                     if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                                                         query += ' WHERE ' + criteriaField + '=\'' + criteriaFieldValue + '\'';
                                                     }
                                                     
                                                     //execute query
                                                     List<Engagement_CounterParty__c> lstRecords = (List<Engagement_CounterParty__c>)Database.query(query);
                                                     Map<String,Engagement_CounterParty__c> existingCPmapping = new Map<String,Engagement_CounterParty__c>();
                                                     for(Engagement_CounterParty__c inx:[Select id,Company__c 
                                                                                         from Engagement_CounterParty__c where Engagement__c =:existingEngagementId 
                                                                                         and Company__c!=null]){
                                                                                             
                                                         existingCPmapping.put(inx.Company__c,inx);
                                                     }
                                                     
                                                     List<Engagement_CounterParty__c> newRecords = new List<Engagement_CounterParty__c>();
                                                     List<Engagement_CounterParty__c> existingClonedRecords = new List<Engagement_CounterParty__c>();
                                                     for(Engagement_CounterParty__c inx : lstRecords){
                                                         if(!existingCPmapping.containsKey(inx.Company__c)){
                                                             newRecords.add(inx);
                                                         }else{
                                                             existingClonedRecords.add(inx);
                                                         }
                                                     }
                                                     
                                                     
                                                     //prepare a map which will hold fieldList and recordList and return it
                                                     returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
                                                     returnMap.put('NEW_RECORD_LIST', JSON.serialize(newRecords));
                                                     returnMap.put('CLONED_RECORD_LIST', JSON.serialize(existingClonedRecords));
                                                     return JSON.serialize(returnMap);
                                                 }
                                                 return null;
                                             }
    
    //clones the counterparties and saves the cloned counterparties on an enagegement record,
    //Parameters : accepts the list of counterparties that needs to be cloned and engagement Id on which records needs to be cloned
    @AuraEnabled
    public static void cloneCounterParties(List<Id> engagementCounterParties, String engagementId){
        System.debug('engagementCounterParties : '+engagementCounterParties);
        System.debug('engagementId : '+engagementId);
        
        list<Engagement_Counterparty_Contact__c> clonedEngagementCounterpartiesContacts = new List<Engagement_Counterparty_Contact__c>();
        list<Engagement_Counterparty__c> clonedEngagementCounterparties = new List<Engagement_Counterparty__c>();
        List<Engagement_Counterparty__c> counterParties = new List<Engagement_Counterparty__c>();
        counterParties = [SELECT Id,Name, Company__c, Type__c, Engagement__c, 
                          (SELECT Id, Name, CurrencyIsoCode,Counterparty__c, Contact__c, Type__c, View_Details__c, Legacy_CS_ID__c, 
                           Report_Counterparty_Contact_Fields__c,
                           Engagement__c, DEMO_RECORD__c, Email__c, ContactEmail__c, EngagementFullID__c, ExternalId__c 
                           FROM Engagement_Counterparty_Contacts__r)
                          FROM Engagement_Counterparty__c
                          where id in :engagementCounterParties];
        
        Map<Engagement_Counterparty__c,List<Engagement_Counterparty_Contact__c>> CounterpartiesContactMapping = new Map<Engagement_Counterparty__c,List<Engagement_Counterparty_Contact__c>>();
        for(Engagement_Counterparty__c inx : counterParties){
            Engagement_Counterparty__c ind = inx.clone(false,true);
            ind.Engagement__c = engagementId;
            ind.ExternalId__c= String.valueOf(inx.Id);
            //ind.Cloned_Counteparty_Id__c = inx.Company__c;
            clonedEngagementCounterparties.add(ind);
            
            for(Engagement_Counterparty_Contact__c rec : inx.Engagement_Counterparty_Contacts__r){
                Engagement_Counterparty_Contact__c clonedRec = new Engagement_Counterparty_Contact__c();
                clonedRec.Contact__c = rec.Contact__c;
                clonedRec.Type__c = rec.Type__c;
                clonedRec.CounterParty__r = new Engagement_Counterparty__c(ExternalId__c = String.valueof(inx.Id ));
                clonedEngagementCounterpartiesContacts.add(clonedRec);
            }
          
        }
        
        insert clonedEngagementCounterparties;
        insert clonedEngagementCounterpartiesContacts;
        
        for(Engagement_Counterparty__c inx : clonedEngagementCounterparties){
            inx.ExternalId__c = null;
        }
        
        update clonedEngagementCounterparties;
       
        System.debug('CounterpartiesContactMapping values : '+CounterpartiesContactMapping.values());
        System.debug('CounterpartiesContactMapping Set : '+CounterpartiesContactMapping.keySet());
    
    }
    
    //Used for View all company List
    @AuraEnabled(cacheable=true)
    public static List<Company_List__c> getCompanyList(){
        return [Select id,name,TotalCompanies__c from Company_List__c order by name ASC];
    }
    

	//Used to insert enagegement counterparties.
	//Parameters : List of company members that needs to be cloned and enagegement Id on which counterparties needs to be inserted 
    @AuraEnabled
    public static void insertCompanyMemberList(List<Id> companyMembers , String engagementId){
        
        System.debug('companyMembers : '+companyMembers);
        System.debug('engagementId : '+engagementId);
        system.debug('companyMembers size : '+companyMembers.size());
        List<Engagement_counterparty__c> insertEngagementCP = new List<Engagement_counterparty__c>();
        for(Company_List_Member__c inx : [SELECT Company_List__c, Company__c,Company__r.Name, Record_Type__c, Type__c, Name, Id 
                                          FROM Company_List_Member__c where id in:companyMembers]){
                                              Engagement_counterparty__c ind = new Engagement_counterparty__c();
                                              ind.Engagement__c = engagementId;
                                              ind.Company__c = inx.Company__c;
                                              String name = inx.Company__r.Name;
                                              if(name!=null&&name.length()>80)
                                                  name = name.substring(0,80);
                                              ind.Name = name;
                                              insertEngagementCP.add(ind);
                                          }
        
        insert insertEngagementCP;
        system.debug('insertEngagementCP  : '+insertEngagementCP);
        system.debug('insertEngagementCP Size : '+insertEngagementCP.size());
        
   
    }
}