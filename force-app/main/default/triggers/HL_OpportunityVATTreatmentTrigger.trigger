trigger HL_OpportunityVATTreatmentTrigger on Opportunity_VAT_Treatment__c (before insert, before update, before delete, after insert, after update, after delete){

    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_VatTreatment)){
        if(trigger.isBefore){
            if(trigger.isInsert){
                HL_OpportunityVATTreatmentHandler.checkForDuplicateVATTreatments(trigger.new);
                HL_OpportunityVATTreatmentHandler.getVATTaxClassificationCode(trigger.new, null);
            }
            else if(trigger.isUpdate){
                HL_OpportunityVATTreatmentHandler.checkForDuplicateVATTreatments(trigger.new);  
                HL_OpportunityVATTreatmentHandler.getVATTaxClassificationCode(trigger.new, Trigger.oldMap); 
            }
            else if(trigger.isDelete){
            }
        }
        else{
            if(trigger.isInsert){
                HL_OpportunityVATTreatmentHandler.checkForUpdatedVATTreatments(trigger.new, null);
            }
            else if(trigger.isUpdate){
                HL_OpportunityVATTreatmentHandler.checkForUpdatedVATTreatments(trigger.new, Trigger.oldMap);
            }
            else if(trigger.isDelete){
                HL_OpportunityVATTreatmentHandler.checkForUpdatedVATTreatments(null, Trigger.oldMap);
            }
       }
    }
}