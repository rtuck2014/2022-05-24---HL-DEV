trigger HL_CapIQ_Company_Trigger on CapIQ_Company__c (after update) {
    //Enable/Disable trigger setting
    if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.CapIQ_Company)){
        //Creating instance of handler class.
        HL_CapIQ_Company_Handler handler = new HL_CapIQ_Company_Handler(Trigger.isExecuting, Trigger.size);

        if(Trigger.isAfter)
        {
            if(Trigger.isUpdate)
            {
                //after update Event
                handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);                 
            }
        }
    }
}