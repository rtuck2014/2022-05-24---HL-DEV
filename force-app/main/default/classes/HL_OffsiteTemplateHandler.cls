public class HL_OffsiteTemplateHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isBeforeInsertFlag = false;

    public HL_OffsiteTemplateHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
     public void OnBeforeInsert(List<Offsite_Template__c> newRecords){
        if(!isBeforeInsertFlag){            
            isBeforeInsertFlag = true;
            HL_OffsiteTemplate.PopulateSnapshotData(newRecords);
        }
    }

    public void OnAfterInsert(List<Offsite_Template__c> newRecords){
        if(!isAfterInsertFlag){            
            isAfterInsertFlag = true;
            HL_OffsiteTemplate.CreateRelatedRecords(newRecords);
        }
    }
}