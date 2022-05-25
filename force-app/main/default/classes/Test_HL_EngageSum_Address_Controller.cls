@isTest
private class Test_HL_EngageSum_Address_Controller{
    @isTest static void testPicklistValues() {
        String countryStateMap = HL_EngageSum_UniversalAddress_Controller.getCountryStateMap();
        System.assertNotEquals(null, countryStateMap);
    }
}