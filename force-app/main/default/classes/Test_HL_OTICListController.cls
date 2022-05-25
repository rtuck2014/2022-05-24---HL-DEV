@isTest
private class Test_HL_OTICListController {
	@isTest private static void TestBasicFunctionality() {
		 //Setup the Test Data
		 List<Offsite_Template__c> otList = SL_TestSetupUtils.CreateOffsiteTemplateDataWithRelated(1,5);
		 List<Offsite_Template_Investment_Company__c> otiList = [SELECT Industry__c, Description__c, HL_Industry__c, Include__c, Investment_Company__c, Investment_Date__c, LTM_MM_EBITDA__c, LTM_MM_Revenue__c, Offsite_Template__c, Portfolio_Company__c, Prospect__c, Service__c, Status__c FROM Offsite_Template_Investment_Company__c WHERE Offsite_Template__c =: otList[0].Id];		 
		 ApexPages.StandardSetController sc = new ApexPages.StandardSetController(otiList);
		 sc.setSelected(otiList);
         //Test the controller functionality
		 Test.startTest();
		 	HL_OTICListController con = new HL_OTICListController(sc);
        	con.updateInclude();
        	con.updateInvestments();
        	con.cancel();
        	con.getInvestments();
            con.SortField = 'Investment_Company__c';
            con.Filter();
            con.Next();
            con.Previous();
		 Test.stopTest();
         //Validate no page errors
		 System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
	}
}