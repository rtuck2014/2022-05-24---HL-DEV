public with sharing class HL_AuditRecordHandler {
    private SObjectType AuditSObjectType {get; set;}
    private FieldSet AuditFieldSet {get; set;}
    //Used to determine if any duplicate keys are added as workflows/processes might refire update
    private static Set<String> DuplicateKeyCheckList {get{if(duplicateKeyCheckList == null)duplicateKeyCheckList = new Set<String>();return duplicateKeyCheckList;} set;}
    
    public HL_AuditRecordHandler(SObjectType sObjectType) {
        //Get Field Set Map
        system.debug('sObjectType='+sObjectType);
        Map<String, Schema.FieldSet> fieldSetMap = sObjectType.getDescribe().fieldSets.getMap();
        system.debug('fieldSetMap='+fieldSetMap);
        system.debug('sObjectType.getDescribe().fieldSets.getMap()='+sObjectType.getDescribe().fieldSets.getMap());
        //Find the Audit Field Set
        for(FieldSet fs : fieldSetMap.values())
        {
            system.debug('fs='+fs);
            if(fs.Name == 'Audit_Record_Fields')
                AuditFieldSet = fs;
        }
        
        //Check that the Audit Field Set has been Defined
        if(AuditFieldSet == null)
            throw new AuditException('Audit Field Set Expected, But Not Defined');
        
        AuditSObjectType = sObjectType;
    }
    
    //For Deletions, newValues should be null
    public List<Audit_Record__c> RecordAudit(Map<Id, sObject> oldValues, Map<Id, sObject> newValues){
        List<Audit_Record__c> auditInsertList = new List<Audit_Record__c>();
        system.debug('oldValues='+ oldValues);
        //Iterate over each record
        for(sObject oldRecord : oldValues.values()){
            system.debug('oldValues='+ oldValues);
            if(newValues != null){
                system.debug('oldValues='+ oldValues);
                //Iterate over field set members for the fields we want to track to determine if they are present in the object values (they will be if changed)
                for(FieldSetMember fsm : this.AuditFieldSet.getFields()){
                    try{
                        //Determine if the Field is Present - this should throw exception if not
                        object oldValue = oldRecord.get(fsm.getFieldPath());
                        //Check for value change and Add to our Insert List
                        auditInsertList = CreateAuditRecord(auditInsertList, fsm, oldRecord, newValues.get((Id)oldRecord.get('Id')));
                    }
                    catch(System.SObjectException ex){}//Expected for Fields not Changed as they won't be part of the SObject Result
                }
            }
            else
                auditInsertList.add(new Audit_Record__c(Object__c = AuditSObjectType.getDescribe().getName()
                                                        ,Record_ID__c = (Id)oldRecord.get('Id')
                                                        ,Field__c = 'IsDeleted'
                                                        ,Old_Value__c = 'False'
                                                        ,New_Value__c = 'True'));
        }
        
        if(auditInsertList.size() > 0)
            insert auditInsertList;
        
        return auditInsertList;
    }
    
    private List<Audit_Record__c> CreateAuditRecord(List<Audit_Record__c> auditRecordList, FieldSetMember fsm, sObject oldRecord, sObject newRecord){
        object oldValue = oldRecord.get(fsm.getFieldPath());
        object newValue = newRecord.get(fsm.getFieldPath());
        
        if(oldValue == null && newValue != null ||
           newValue == null && oldValue != null ||
           oldValue != newValue){
               Audit_Record__c newAuditRecord = new Audit_Record__c(Object__c = AuditSObjectType.getDescribe().getName()
                                                                    ,Record_ID__c = (Id)oldRecord.get('Id')
                                                                    ,Field__c = fsm.getFieldPath()
                                                                    ,Old_Value__c = String.valueOf(oldValue)
                                                                    ,New_Value__c = String.valueOf(newValue));
               String recordKey = String.format('{0}_{1}_{2}_{3}_{4}'
                                                ,new List<String> {newAuditRecord.Object__c
                                                    ,newAuditRecord.Record_ID__c
                                                    ,newAuditRecord.Field__c
                                                    ,(!String.isBlank(newAuditRecord.Old_Value__c) ? newAuditRecord.Old_Value__c : '')
                                                    ,(!String.isBlank(newAuditRecord.Old_Value__c) ? newAuditRecord.New_Value__c : '')});
               
               if(!DuplicateKeyCheckList.contains(recordKey)){
                   DuplicateKeyCheckList.add(recordKey);
                   auditRecordList.add(newAuditRecord);
               }
           }
        
        return auditRecordList;
    }
    
    public class AuditException extends Exception {}
}