public class HL_MobileRelatedListController {
    
    @auraEnabled(cacheable=true)
    public static RelatedListWrapper getRecords(Id recordId, String relatedListName){
        List<Mobile_Related_List_Setting__mdt> mobileRelatedListSettings = [SELECT Id, MasterLabel, DeveloperName,Icon_Name__c,
                                                                            Object_API_Name__c, Record_List_Field_API_Names__c, Record_Title_Field_API_Names__c,
                                                                            Related_List_Title__c, Where_Clause__c, Redirect_Type__c,Redirect_Component__c,
                                                                            Redirect_To__c, Get_Field_Labels_from_Record__c, Record_List_Field_Labels__c 
                                                                            FROM Mobile_Related_List_Setting__mdt
                                                                            WHERE DeveloperName =:relatedListName 
                                                                            LIMIT 1];
        String titleFields =  mobileRelatedListSettings[0].Record_Title_Field_API_Names__c;
        String listFields = mobileRelatedListSettings[0].Record_List_Field_API_Names__c;
        String whereClause = mobileRelatedListSettings[0].Where_Clause__c;
        String objectAPIName = mobileRelatedListSettings[0].Object_API_Name__c;
        Boolean getLabelsFromRecord = mobileRelatedListSettings[0].Get_Field_Labels_from_Record__c;
        String listFieldsLabel = mobileRelatedListSettings[0].Record_List_Field_Labels__c;
        String redirectType = mobileRelatedListSettings[0].Redirect_Type__c;
        String redirectTo = mobileRelatedListSettings[0].Redirect_To__c;
        String query ='';
        query = 'SELECT Id, '+titleFields+ ',' + listFields +','+redirectTo+' FROM '+objectAPIName+' WHERE '+ whereClause;
        System.debug('query>>>'+query);
        List<String> titleFieldsList = titleFields.split(',');
        List<String> listFieldsList = listFields.split(',');
        List<String> listFieldsLabelList = new List<String>();
        if(getLabelsFromRecord){
            listFieldsLabelList = listFieldsLabel.split(',');
        }
        List<SObject> sObjectList = database.query(query);
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        
        Map<String, DescribeFieldResult> describeFieldResultMap = new Map<String, DescribeFieldResult>();
        for(String titleField : titleFieldsList){
            describeFieldResultMap.put(titleField,objResult.fields.getMap().get(titleField).getDescribe());
        }
        for(String listField : listFieldsList){
            describeFieldResultMap.put(listField,objResult.fields.getMap().get(listField).getDescribe());     
        }
        Map<Id,relatedListFieldWrapper> relatedListRecordFieldMap = new Map<Id,relatedListFieldWrapper>();
        for(SObject record : sObjectList){
            List<RelatedListRecordField> relatedListRecordFieldList = new List<RelatedListRecordField>();
            List<RelatedListTitleField> relatedListRecordTitleList = new List<RelatedListTitleField>();
            RelatedListFieldWrapper relatedListFieldWrapper = new relatedListFieldWrapper();
            for(String titleField : titleFieldsList){
                RelatedListTitleField relatedListRecord = new RelatedListTitleField();
                // relatedListRecord.fieldLabel = describeFieldResultMap.get(titleField).getLabel();
                relatedListRecord.fieldDataType = String.valueOf(describeFieldResultMap.get(titleField).getType());
                if(relatedListRecord.fieldDataType == 'DATETIME'){
                    Datetime dt = Datetime.valueOf(record.get(titleField));
                    relatedListRecord.fieldValue = dt != null ? String.valueOf(dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')) : null;
                }else if(relatedListRecord.fieldDataType == 'DATE'){
                    Datetime dt = Date.valueOf(record.get(titleField)); 
                    relatedListRecord.fieldValue = dt != null ? String.valueOf(dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')) : null;    
                }
                else{
                    relatedListRecord.fieldValue = String.valueOf(record.get(titleField));
                }
                relatedListRecordTitleList.add(relatedListRecord);
            }
            //    relatedListTitleFieldMap.put(record.Id,relatedListRecordTitleList);
            for(Integer i=0; i < listFieldsList.size();i++){
                RelatedListRecordField relatedListRecord = new RelatedListRecordField();
                if(getLabelsFromRecord){
                    relatedListRecord.fieldLabel = listFieldsLabelList[i];   
                }else{
                    relatedListRecord.fieldLabel = describeFieldResultMap.get(listFieldsList[i]).getLabel();   
                }
                relatedListRecord.fieldDataType = String.valueOf(describeFieldResultMap.get(listFieldsList[i]).getType());
                if(relatedListRecord.fieldDataType == 'DATETIME'){
                    Datetime dt = Datetime.valueOf(record.get(listFieldsList[i]));
                    relatedListRecord.fieldValue = dt != null ? String.valueOf(dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')) : null;
                    }else if(relatedListRecord.fieldDataType == 'DATE'){
                    Datetime dt = Date.valueOf(record.get(listFieldsList[i])); 
                    relatedListRecord.fieldValue = dt != null ? String.valueOf(dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')) : null; 
                }else{
                    relatedListRecord.fieldValue = String.valueOf(record.get(listFieldsList[i])); 
                }
                relatedListRecordFieldList.add(relatedListRecord);
            }
            relatedListFieldWrapper.relatedListTitleFieldList = relatedListRecordTitleList;
            relatedListFieldWrapper.relatedListRecordFieldList = relatedListRecordFieldList;
               relatedListRecordFieldMap.put(String.valueOf(record.get(redirectTo)),relatedListFieldWrapper);
        }
        RelatedListWrapper relatedListWrapper = new RelatedListWrapper();
        relatedListWrapper.iconName = mobileRelatedListSettings[0].Icon_Name__c;
        relatedListWrapper.relatedListName = mobileRelatedListSettings[0].Related_List_Title__c;
        relatedListWrapper.relatedListFieldMap = relatedListRecordFieldMap;
        relatedListWrapper.objectAPIName = objectAPIName;
        relatedListWrapper.redirectType = redirectType;
        return relatedListWrapper;
    }
    public class RelatedListWrapper{
        @auraEnabled
        public String iconName{get;set;}
        @auraEnabled
        public String relatedListName{get;set;}
        @auraEnabled
        public Map<Id,RelatedListFieldWrapper> relatedListFieldMap{get;set;}
        @auraEnabled
        public String objectAPIName{get;set;}
        @auraEnabled
        public String redirectType{get;set;}
    }
    public class RelatedListRecordField{
        @auraEnabled
        public String fieldLabel{get;set;}
        @auraEnabled
        public String fieldValue{get;set;}
        @auraEnabled
        public String fieldDataType{get;set;}
    }
    public class RelatedListTitleField{
        @auraEnabled
        public String fieldLabel{get;set;}
        @auraEnabled
        public String fieldValue{get;set;}
        @auraEnabled
        public String fieldDataType{get;set;}
    }
    public class relatedListFieldWrapper{
        @auraEnabled
        public List<RelatedListTitleField> relatedListTitleFieldList{get;set;}
        @auraEnabled
        public List<RelatedListRecordField> relatedListRecordFieldList{get;set;}
    }
}