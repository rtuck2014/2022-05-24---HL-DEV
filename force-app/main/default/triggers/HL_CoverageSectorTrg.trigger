trigger HL_CoverageSectorTrg on CoverageSector__c  (before insert, before update, before delete) {
    if(trigger.isBefore) {
        if(trigger.isInsert ) {            
            HL_CoverageSectorTrgHandler.onBeforeInsert(trigger.new);
        }else if(trigger.isUpdate){            
           HL_CoverageSectorTrgHandler.onBeforeUpdate(trigger.oldMap,trigger.newMap);
        }else if(trigger.isDelete){
            HL_CoverageSectorTrgHandler.onBeforeDelete(trigger.old);
        }
    }
}