@isTest
private class Test_HL_AlphabetFilterController {
    @isTest private static void TestBasicFunctionality(){
        Test.startTest();
        	HL_AlphabetFilterController con = new HL_AlphabetFilterController();
        Test.stopTest();
        System.assertNotEquals(con.Alphabet,null);
    }
}