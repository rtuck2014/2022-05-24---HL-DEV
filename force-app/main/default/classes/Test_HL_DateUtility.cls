@isTest
private class Test_HL_DateUtility {
    @isTest private static void TestGetDateFromJavascript(){
        Test.startTest();
        	Date originalValue = Date.newinstance(2010, 1, 1);
        	Date returnValue = HL_DateUtility.GetDateFromJavascript(HL_DateUtility.FormatJSDate(originalValue.Year() + '-' + originalValue.month() + '-' + originalValue.day()));
        	Date invalidParameterReturnValue = HL_DateUtility.GetDateFromJavascript(originalValue.Year() + '-' + originalValue.month() + '-' + originalValue.day() + '-' + '12:00AM');
        Test.stopTest();
        
        //Validate the returned date matches the original
        System.assertEquals(originalValue, returnValue);
    }
    
    @isTest private static void TestDateTimeFormats(){
        Test.startTest();
        	String dateTimeFormat = HL_DateUtility.GetDateTimeFormat(UserInfo.getLocale());
        	DateTime formattedDateTime = HL_DateUtility.FormatDateTime(Date.today(), '12:00AM');
        Test.stopTest();
        
        //Validate the DateTime Format was returned
        System.assert(!String.isBlank(dateTimeFormat));
        //Validate the DateTime was returned and matches the current date
        System.assert(formattedDateTime != null);
        System.assertEquals(Date.today().Year(), formattedDateTime.Year());
        System.assertEquals(Date.today().Month(), formattedDateTime.Month());
        System.assertEquals(Date.today().Day(), formattedDateTime.Day());
    }
    
	@isTest private static void TestGetFormatValues(){
        Test.startTest();
        	Map<String,String> formatDateMap = HL_DateUtility.GetDateFormatMap();
        	Map<String,String> formatDateTimeMap  = HL_DateUtility.GetDateTimeFormatMap();
        Test.stopTest();
         
        //Validate the Maps are Returned
        System.assert(formatDateMap.size() > 0);
        System.assert(formatDateTimeMap.size() > 0);
    }
}