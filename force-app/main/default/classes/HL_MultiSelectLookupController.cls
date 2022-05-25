public class HL_MultiSelectLookupController {
    
    
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String values) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            List<String> selectedvalues = (List<String>) JSON.deserialize(values, List<String>.class);
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(selectedvalues != null && selectedvalues.size() > 0) {
                query += ' WHERE Id IN: selectedvalues LIMIT 50';
            } else {
                query += ' WHERE '+filterField+
                    ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 50';
            }
            for(SObject s : Database.query(query)) {
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static void insertEventRecords(String eventId,String eventFieldApi,String junctionObjectName,String lookupFieldApi,List<String> lookupRecords){
        List<sObject> insertEventRecords = new List<sObject>();
        System.debug('eventId'+eventId);
        for(String lookupRecord : lookupRecords){
            sObject record = Schema.getGlobalDescribe().get(junctionObjectName).newSobject();
            record.put(eventFieldApi,eventId);
            record.put(lookupFieldApi,lookupRecord);
            insertEventRecords.add(record);//
        }
        system.debug('insertEventRecords'+insertEventRecords);
        system.debug('Size'+insertEventRecords.size());
        insert insertEventRecords;
        
    }
    
    @AuraEnabled
    public static List<SObject> fetchChildRecords(String recordId,String fieldApiName,String objectApiName,String lookupFieldApiName,String additionalField){
        System.debug('recordId'+recordId);
        if(String.isNotBlank(additionalField)){
            additionalField = ','+additionalField;
        }else{
            additionalField = '';
        }
        String query = 'Select id,name,'+fieldApiName+','+lookupFieldApiName+additionalField+' from '+objectApiName +' where '+fieldApiName+' =: recordId';
        System.debug('query'+query);
        return Database.query(query);
    }
    
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, List<String> selectedRecId) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        system.debug(fieldName+'-------------'+ObjectName+'---++----------'+value+'====='+selectedRecId);
        if(selectedRecId == null)
            selectedRecId = new List<String>();
        
        if(String.isNotEmpty(value)) {
            String query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value.trim() + '%\' and ID NOT IN: selectedRecId LIMIT 100';
            system.debug(query);
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }
        }
        return sObjectResultList;
    }
    
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        public SObJectResult() {
            
        }
    }
}