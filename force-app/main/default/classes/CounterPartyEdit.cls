public with sharing class CounterPartyEdit {
    @AuraEnabled
    public static EngagementWrapper getCounterpartyList(String recordId,Integer pageSize,Integer pageNumber,String viewFilter){
        try {
            //System.debug('pageSize:'+pageSize+' pageNumber:'+pageNumber+' recordId:'+recordId);
            integer offSet = (pageNumber-1)*pageSize;  
            String soql = 'SELECT COUNT() FROM Engagement_Counterparty__c WHERE Engagement__c=:recordId';
            if(String.isNotBlank(viewFilter)){
                soql+=' AND '+viewFilter;
            }
            integer totalRecords=Database.countQuery(soql);
            integer recordEnd = pageSize*pageNumber;

            EngagementWrapper ew = new EngagementWrapper();
            ew.pageSize=pageSize;
            ew.pageNumber=pageNumber;
            ew.recordStart=offset+1;
            ew.recordEnd=totalRecords>=recordEnd?recordEnd:totalRecords;
            ew.totalRecords=totalRecords;
            soql = 'SELECT Id,View_Record__c,Company__r.Name,Status__c,(SELECT Id,Contact__c,ContactEmail__c,Contact__r.FirstName,Contact__r.LastName FROM Engagement_Counterparty_Contacts__r WHERE ContactEmail__c!=\'\') FROM Engagement_Counterparty__c WHERE Engagement__c=:recordId';
            if(String.isNotBlank(viewFilter)){
                soql+=' AND '+viewFilter;
            }
            soql+=' ORDER BY Company_Name__c LIMIT :pageSize OFFSET :offset';
            ew.eCpList=(List<Engagement_Counterparty__c>)Database.query(soql);
            
            return ew;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Engagement__c getEngagement(String engId){
        try {
            return [SELECT Id,Job_Type_Category__c FROM Engagement__c WHERE Id=:engId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Engagement_Counterparty_List_View__mdt> getListViewMeta(){
        try {
            Map<String,Engagement_Counterparty_List_View__mdt> metaMap = new Map<String,Engagement_Counterparty_List_View__mdt>();
            for(Engagement_Counterparty_List_View__mdt meta : [SELECT Id,DeveloperName,Label,MasterLabel,Column_API_Names__c,Filter__c FROM Engagement_Counterparty_List_View__mdt]){
                metaMap.put(meta.DeveloperName,meta);
            }
            return metaMap;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteCounterparties(List<String> counterPartyIdList){
        try {
            for(List<Engagement_Counterparty__c> ecList : [SELECT Id FROM Engagement_Counterparty__c WHERE Id in :counterPartyIdList]){
                delete ecList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CounterpartyContactWrapper> getCounterpartyContacts(List<String> counterPartyIdList){        
        Map<Id,CounterpartyContactWrapper> accountWrapperMap = new Map<Id,CounterpartyContactWrapper>();
        try {
            for(Engagement_Counterparty_Contact__c ecc : [SELECT Id,Counterparty__c,Counterparty__r.Company__r.Name,Counterparty__r.Company__c,Contact__c,ContactEmail__c,Contact__r.FirstName,Contact__r.LastName FROM Engagement_Counterparty_Contact__c WHERE ContactEmail__c!='' AND Counterparty__c in :counterPartyIdList ORDER BY Counterparty__r.Company__r.Name]){
                if(!accountWrapperMap.containsKey(ecc.Counterparty__r.Company__c)){
                    accountWrapperMap.put(ecc.Counterparty__r.Company__c,new CounterpartyContactWrapper(ecc.Id,ecc.Counterparty__r.Company__c,ecc.Counterparty__r.Company__r.Name,ecc.Counterparty__c));
                }
                accountWrapperMap.get(ecc.Counterparty__r.Company__c).contactList.add(new Contact(Id=ecc.Contact__c,FirstName=ecc.Contact__r.FirstName,LastName=ecc.Contact__r.LastName,Email=ecc.ContactEmail__c));
                accountWrapperMap.get(ecc.Counterparty__r.Company__c).emailList.add(ecc.ContactEmail__c);
            }
            return accountWrapperMap.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static EmailTemplate getEmailTemplate(String templateId){                
        try {
            return [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id=:templateId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<EmailTemplate> getAvailableTemplates(){
        try {
            return new List<EmailTemplate>([SELECT Id,Name FROM EmailTemplate WHERE Folder.Name='CF Templates' AND IsActive=true AND RelatedEntityType='Engagement_Counterparty_Contact__c']);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,String> getMilestonePickListValues(){
        Map<String,String> pickListValuesMap= new Map<String,String>();
         Schema.DescribeFieldResult fieldResult = Engagement_Counterparty__c.Milestone__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
         }     
         return pickListValuesMap;
     }

    public class EngagementWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<Engagement_Counterparty__c> eCpList {get;set;}        
    }

    public class CounterpartyContactWrapper{
        @AuraEnabled
        public String eccId {get;set;}
        @AuraEnabled
        public String companyName {get;set;}
        @AuraEnabled
        public String companyId {get;set;}
        @AuraEnabled
        public String counterPartyId {get;set;}
        @AuraEnabled
        public List<Contact> contactList {get;set;}
        @AuraEnabled
        public List<String> emailList {get;set;}

        public CounterpartyContactWrapper(String engagementCounterpartyContactId,String companyId,String companyName,String cpId){
            this.eccId=engagementCounterpartyContactId;
            this.companyId=companyId;
            this.companyName=companyName;
            this.contactList = new List<Contact>();
            this.emailList = new List<String>();
            this.counterPartyId=cpId;
        }
    }
}