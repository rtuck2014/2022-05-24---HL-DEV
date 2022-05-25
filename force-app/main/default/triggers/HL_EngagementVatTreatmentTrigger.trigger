trigger HL_EngagementVatTreatmentTrigger on Engagement_VAT_Treatment__c (before insert, before update, before delete, after insert, after update, after delete) {

    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Engagement_VatTreatment)
       && !SL_CheckRecursive.skipOnConvert){
        if(Trigger.IsBefore){
            if(Trigger.IsInsert){
                HL_EngagementVatTreatmentHandler.checkForDuplicateVATTreatments(trigger.new);
                HL_EngagementVatTreatmentHandler.getVATTaxClassificationCode(trigger.new, null);
            }
            else if(Trigger.IsUpdate){
                HL_EngagementVatTreatmentHandler.checkForDuplicateVATTreatments(trigger.new);  
                HL_EngagementVatTreatmentHandler.getVATTaxClassificationCode(trigger.new, Trigger.oldMap); 
            }
        }
        else if(Trigger.isAfter){
            if(Trigger.isInsert){
                HL_EngagementVatTreatmentHandler.checkForUpdatedVATTreatments(trigger.new, null);
            }
            else if(trigger.isUpdate){
                HL_EngagementVatTreatmentHandler.checkForUpdatedVATTreatments(trigger.new, Trigger.oldMap);
            }
            else if(trigger.isDelete){
                HL_EngagementVatTreatmentHandler.checkForUpdatedVATTreatments(null, Trigger.oldMap);
            }
        }
    }
}