trigger HL_FundTrigger on Fund__c (before insert, before update) {
	If(Trigger.isBefore)
        HL_FundHandler.HandleLatestFlag(Trigger.New);
}