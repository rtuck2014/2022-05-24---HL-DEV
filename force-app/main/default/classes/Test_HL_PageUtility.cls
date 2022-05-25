@isTest
private class Test_HL_PageUtility {
    @isTest private static void TestBasicFunctionality(){
        HL_PageUtility.ShowConfirm('Test Confirm');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.CONFIRM));
        HL_PageUtility.ShowInfo('Test Info');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.INFO));
        HL_PageUtility.ShowWarning('Test Warning');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.WARNING));
        HL_PageUtility.ShowError('Test Error');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
        HL_PageUtility.GetParameter('id');
    }
}