public without sharing class HL_PicklistFilterController {
    public Sobject ObjectRecord {get;set;}
    public String PickListFieldName {get;set;}        

    public HL_PicklistFilterController() {
        Map<String, String> pageParameterMap = ApexPages.currentPage().getParameters();
        
        String recordTypeId = pageParameterMap.get('recordTypeId');
        String sobjectTypeName = pageParameterMap.get('sobjectType'); 
        PickListFieldName = pageParameterMap.get('picklistFieldName'); 
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectTypeName);
        ObjectRecord = targetType.newSObject();
        ObjectRecord.put('RecordTypeId', recordTypeId); 
    }  
}