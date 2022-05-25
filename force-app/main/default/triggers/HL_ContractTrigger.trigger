trigger HL_ContractTrigger on Contract__c (before insert, before update, before delete, after insert, after update, after delete){
    
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Contract)){
        if(trigger.isBefore){
            if(trigger.isInsert){
               HL_ContractHandler.setNewContractTaxClassificationCode();
               HL_ContractHandler.setBillToShipToBasedOnBillingContact(Trigger.New,Null,True);
               HL_ContractHandler.validateContractBillingContact(Trigger.New,Null,True);
               HL_ContractHandler.setContractStatus(trigger.new,null);
            }
            else if(trigger.isUpdate){
              HL_ContractHandler.setBillToShipToBasedOnBillingContact(Trigger.New,Trigger.OldMap,False);
              HL_ContractHandler.validateContractBillingContact(Trigger.New,Trigger.OldMap,False);
              HL_ContractHandler.setContractStatus(trigger.new,trigger.oldMap);
            }
            else if(trigger.isDelete){
            }
        }
        else{
            if(trigger.isInsert){
                HL_ContractHandler.setContractInitialValues();
                HL_ContractHandler.updateAccountClientNumbers();
                if(!HL_ConstantsUtil.automatedContractCreation)
                HL_ContractHandler.checkMainContract(Trigger.New,Null,Trigger.Newmap);
            }
            else if(trigger.isUpdate){
                HL_ContractHandler.updateAccountClientNumbers();
                if(!HL_ConstantsUtil.automatedContractCreation)
                HL_ContractHandler.checkMainContract(Trigger.New,Trigger.Oldmap,Trigger.Newmap);
            }
            else if(trigger.isDelete){
            }
        }
    }
}