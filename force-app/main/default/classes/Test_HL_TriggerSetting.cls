@isTest
private class Test_HL_TriggerSetting {
    @isTest
    static void testIsEnabled() {
        Boolean result = HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Account);

        System.assert(result, 'Expected Account Trigger_Setting__mdt to be true.');
    }
}