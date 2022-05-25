@isTest
public class Test_HL_OTIListController {
	@isTest private static void TestBasicFunctionality() {
		 //Setup the Test Data
		 List<Offsite_Template__c> otList = SL_TestSetupUtils.CreateOffsiteTemplateDataWithRelated(1,5);
		 List<Offsite_Template_Industry__c> otiList = [SELECT Focus__c, Industry__c, Meeting__c, Offsite_Template__c FROM Offsite_Template_Industry__c WHERE Offsite_Template__c =: otList[0].Id];		 
		 ApexPages.StandardSetController sc = new ApexPages.StandardSetController(otiList);
		 sc.setSelected(otiList);
        //Test the controller functionality
		 Test.startTest();
		 	HL_OTIListController con = new HL_OTIListController(sc);
        	con.updateFocus();
        	con.updateMeeting();
        	con.updateIndustries();
        	con.cancel();
		 Test.stopTest();
         //Validate no page errors
		 System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
	}
}