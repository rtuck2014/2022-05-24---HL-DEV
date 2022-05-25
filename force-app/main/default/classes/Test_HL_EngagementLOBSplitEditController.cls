@isTest
private class Test_HL_EngagementLOBSplitEditController {
	@testSetup
	private static void CreateData() {
		Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
		insert e;

		List<Engagement_LOB_Split__c> elsList = new List<Engagement_LOB_Split__c> {new Engagement_LOB_Split__c(Engagement__c = e.Id, LOB__c = 'CF', LOB_Split__c = 80.0),
			     new Engagement_LOB_Split__c(Engagement__c = e.Id, LOB__c = 'FVA', LOB_Split__c = 20.0)
		};
		insert elsList;
	}

	@isTest
	private static void TestLOBSplitOverrideSave() {
		Engagement_LOB_Split__c els = [SELECT Engagement__c FROM Engagement_LOB_Split__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(els);
		Test.setCurrentPage(new PageReference('/apex/HL_EngagementLOBSplitEdit?Id=' + els.id));

		HL_EngagementLOBSplitEditController con = new HL_EngagementLOBSplitEditController(sc);

		List<String> SplitTypeList = con.SplitTypeList;

		//Override both to 50%
		con.OverrideLOBSplitList[0].Percent = 50.0;
		con.OverrideLOBSplitList[1].Percent = 50.0;

		con.SaveRecords();

		Test.stopTest();

		//Verify the Properties were Updated
		System.assertEquals(els.Engagement__c, con.EngagementId);
		System.assertEquals(2, con.EngagementLOBSplitList.size());
		System.assertEquals(2, con.LOBSplitList.size());
		System.assertEquals(2, con.OverrideLOBSplitList.size());

		//Verify the Save was Successful
		for (Engagement_LOB_Split__c split : [SELECT LOB_Split_Override_Percent__c
		                                      FROM Engagement_LOB_Split__c]) {
			System.assertEquals(50.0, split.LOB_Split_Override_Percent__c);
		}
	}

	@isTest
	private static void TestLOBSplitOverrideSaveBackToNull() {
		Engagement_LOB_Split__c els = [SELECT Engagement__c FROM Engagement_LOB_Split__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(els);
		Test.setCurrentPage(new PageReference('/apex/HL_EngagementLOBSplitEdit?Id=' + els.id));

		HL_EngagementLOBSplitEditController con = new HL_EngagementLOBSplitEditController(sc);

		List<String> SplitTypeList = con.SplitTypeList;

		//Override both to 50%
		con.OverrideLOBSplitList[0].Percent = 50.0;
		con.OverrideLOBSplitList[1].Percent = 50.0;

		con.SaveRecords();

		con.OverrideLOBSplitList[0].Percent = null;
		con.OverrideLOBSplitList[1].Percent = null;

		con.SaveRecords();

		Test.stopTest();

		//Verify the Save was Successful and Override Results are Back to 0
		for (Engagement_LOB_Split__c split : [SELECT LOB_Split_Override_Percent__c
		                                      FROM Engagement_LOB_Split__c]) {
			System.assertEquals(0, split.LOB_Split_Override_Percent__c);
		}
	}

	@isTest
	private static void TestLOBSplitOverrideSaveErrorDMLException() {
		Engagement_LOB_Split__c els = [SELECT Engagement__c FROM Engagement_LOB_Split__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(els);
		Test.setCurrentPage(new PageReference('/apex/HL_EngagementLOBSplitEdit?Id=' + els.id));

		HL_EngagementLOBSplitEditController con = new HL_EngagementLOBSplitEditController(sc);

		//Override both to 50%
		con.OverrideLOBSplitList[0].Percent = 50.0;
		con.OverrideLOBSplitList[1].Percent = 50.0;

		//Delete the Records Before Save
		delete [SELECT Id FROM Engagement_LOB_Split__c];

		con.SaveRecords();

		Test.stopTest();

		//Verify an Error is Displayed
		System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));
	}

	@isTest
	private static void TestLOBSplitOverrideSaveErrorAbove100() {
		Engagement_LOB_Split__c els = [SELECT Engagement__c FROM Engagement_LOB_Split__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(els);
		Test.setCurrentPage(new PageReference('/apex/HL_EngagementLOBSplitEdit?Id=' + els.id));

		HL_EngagementLOBSplitEditController con = new HL_EngagementLOBSplitEditController(sc);

		//Override both to 75%
		con.OverrideLOBSplitList[0].Percent = 75.0;
		con.OverrideLOBSplitList[1].Percent = 75.0;

		con.SaveRecords();

		Test.stopTest();

		//Verify an Error is Displayed
		System.assert(ApexPages.hasMessages(ApexPages.severity.ERROR));

		//Verify the Save was not Successful
		for (Engagement_LOB_Split__c split : [SELECT LOB_Split_Override_Percent__c
		                                      FROM Engagement_LOB_Split__c]) {
			System.assertNotEquals(75.0, split.LOB_Split_Override_Percent__c);
		}
	}

	@isTest
	private static void TestLOBSplitOverrideCancel() {
		Engagement_LOB_Split__c els = [SELECT Engagement__c FROM Engagement_LOB_Split__c LIMIT 1];

		Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(els);
		Test.setCurrentPage(new PageReference('/apex/HL_EngagementLOBSplitEdit?Id=' + els.id));

		HL_EngagementLOBSplitEditController con = new HL_EngagementLOBSplitEditController(sc);

		//Override both to 50%
		con.OverrideLOBSplitList[0].Percent = 50.0;
		con.OverrideLOBSplitList[1].Percent = 50.0;

		con.CancelAndReturn();

		Test.stopTest();

		//Verify the Properties were Updated
		System.assertEquals(els.Engagement__c, con.EngagementId);
		System.assertEquals(2, con.EngagementLOBSplitList.size());
		System.assertEquals(2, con.LOBSplitList.size());
		System.assertEquals(2, con.OverrideLOBSplitList.size());

		//Verify the Save did not happen
		for (Engagement_LOB_Split__c split : [SELECT LOB_Split_Override_Percent__c
		                                      FROM Engagement_LOB_Split__c]) {
			System.assertNotEquals(50.0, split.LOB_Split_Override_Percent__c);
		}

	}
}