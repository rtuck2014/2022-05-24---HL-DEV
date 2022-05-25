trigger HL_TimeRecordPeriodTrigger on Time_Record_Period__c (after insert) {
  if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Time_Record_Period))
	{
        HL_TimeRecordPeriodHandler handler = new HL_TimeRecordPeriodHandler(Trigger.isExecuting, Trigger.size);

        if(Trigger.IsAfter){
            if(Trigger.IsInsert){
                handler.OnAfterInsert(Trigger.New);
            }
        }
    }
}