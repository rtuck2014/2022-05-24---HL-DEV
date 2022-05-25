/**
* \arg ClassName      : SL_Test_Relationship_Rollups
* \arg JIRATicket     : HL-15
* \arg CreatedOn      : 30/MAY/2014
* \arg LastModifiedOn : 20/JAN/2015
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Test class for batch and schedular
*/
@isTest
public with sharing class SL_TestSetupUtils
{
	private static Map<String, object> mapJsonObjects;
	private static map<string,ID> recordTypeIds;

	static
	{
		String strJson = SL_TestSetupUtils.getTestJSONFromStaticResources('HL_TestCoverageJsonData');
		mapJsonObjects = (Map<String, SObject>) JSON.deserialize(strJson, Map<String, SObject>.class);
		recordTypeIds = new map<string,ID>();
		for(RecordType rt : [select ID, DeveloperName, sObjectType from RecordType where sObjectType in :mapJsonObjects.keyset()])
		{
			recordTypeIds.put(rt.sObjectType + '-' + rt.DeveloperName,rt.ID);
		}
	}

	public static List<Account> CreateAccount(String basename, Integer count)
    {
    	List<Account> results = new List<Account>();
		Account objAccount = (Account) mapJsonObjects.get('Account');

		for(Integer x = 0; x< count; x++)
		{
			Account objTempAcc = objAccount.clone();
			objTempAcc.Name = basename + String.valueOf(x);
			results.add(objTempAcc);
		}
    	return results;
	}

	public static List<Bid__c> CreateBid(String basename, Integer count)
    {
    	List<Bid__c> results = new List<Bid__c>();
			Bid__c objBid = (Bid__c)mapJsonObjects.get('Bid__c');

			for(Integer x = 0; x< count; x++)
			{
				Bid__c objTempBid = objBid.clone();
				results.add(objTempBid);
			}

    	return results;
	}

	public static List<CapIQ_Company__c> CreateCapIQCompany(String basename, Integer count)
	{
		List<CapIQ_Company__c> results = new List<CapIQ_Company__c>();
		CapIQ_Company__c objCC = (CapIQ_Company__c)mapJsonObjects.get('CapIQ_Company__c');

		for(Integer x = 0; x< count; x++)
		{
			CapIQ_Company__c objCCTemp = objCC.clone();
			results.add(objCCTemp);
		}
		return results;
	}

	public static List<Contact> CreateContact(String basename, Integer count, ContactType recordType)
    {
		List<Contact> results = new List<Contact>();
		Contact objContact = (Contact) mapJsonObjects.get('Contact');
		objContact.RecordTypeID = getContactRecordTypeID(recordType);

		for(Integer x = 0; x< count; x++)
		{
			Contact objContactTemp = objContact.clone();
			results.add(objContactTemp);
		}
    	return results;
	}

	public static List<Coverage_Team__c> CreateCoverageTeam(String basename, Integer count)
	{
		List<Coverage_Team__c> results = new List<Coverage_Team__c>();
		Coverage_Team__c objCT = (Coverage_Team__c)mapJsonObjects.get('Coverage_Team__c');

		for(Integer x = 0; x< count; x++)
		{
			Coverage_Team__c objCTTemp = objCT.clone();
			results.add(objCTTemp);
		}
		return results;
	}

	public Enum ContactType{
		HOULIHAN_EMPLOYEE, EXTERNAL_CONTACT
	}

	private static ID getContactRecordTypeID(ContactType recordType){
		if (recordType == ContactType.HOULIHAN_EMPLOYEE){
			return [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
		}
		else if (recordType == ContactType.EXTERNAL_CONTACT){
			return [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'External_Contact'].Id;
		}
		else
			return null;
	}

	public static List<Task> CreateTask(String basename, Integer count)
	{
		List<Task> results = new List<Task>();
		Task objTask = (Task) mapJsonObjects.get('Task');

		for(Integer x = 0; x< count; x++)
		{
			Task objTaskTemp = objTask.clone();
			results.add(objTaskTemp);
		}
		return results;
	}

	public static List<Email_Template__c> CreateEmailTemplate(String basename, Integer count)
	{
		List<Email_Template__c> results = new List<Email_Template__c>();
		Email_Template__c objEmailTemplate = (Email_Template__c)mapJsonObjects.get('Email_Template__c');

		for(Integer x = 0; x< count; x++)
		{
			Email_Template__c objEmailTemplateTemp = objEmailTemplate.clone();
			results.add(objEmailTemplateTemp);
		}
		return results;
	}

	public static List<Event> CreateEvent(String basename, Integer count)
	{
		List<Event> results = new List<Event>();
		Event objEvent = (Event) mapJsonObjects.get('Event');

		for(Integer x = 0; x< count; x++)
		{
			Event objEventTemp = objEvent.clone();
			results.add(objEventTemp);
		}
		return results;
	}

	public static List<Engagement__c> CreateEngagement(String basename, Integer count)
	{
		List<Engagement__c> results = new List<Engagement__c>();
		Engagement__c objEngagement = (Engagement__c) mapJsonObjects.get('Engagement__c');

		for(Integer x = 0; x< count; x++)
		{
			Engagement__c objEngagementTemp = objEngagement.clone();
			objEngagementTemp.Name = basename + String.valueOf(x);
			objEngagementTemp.Engagement_Number__c = String.valueOf(x+1);
			results.add(objEngagementTemp);
		}
		return results;
	}

	public static List<Engagement_Internal_Team__c> CreateEIT(String basename, Integer count)
	{
		List<Engagement_Internal_Team__c> results = new List<Engagement_Internal_Team__c>();
		Engagement_Internal_Team__c objEIT = (Engagement_Internal_Team__c) mapJsonObjects.get('Engagement_Internal_Team__c');

		for(Integer x = 0; x< count; x++)
		{
			Engagement_Internal_Team__c objEITTemp = objEIT.clone();
			results.add(objEITTemp);
		}
		return results;
	}

	public static List<Engagement_External_Team__c> CreateEET(String basename, Integer count)
	{
		List<Engagement_External_Team__c> results = new List<Engagement_External_Team__c>();
		Engagement_External_Team__c objEET = (Engagement_External_Team__c) mapJsonObjects.get('Engagement_External_Team__c');

		for(Integer x = 0; x< count; x++)
		{
			Engagement_External_Team__c objEETTemp = objEET.clone();
			results.add(objEETTemp);
		}
		return results;
	}

	public static List<Engagement_Counterparty__c> CreateEC(String basename, Integer count)
	{
		List<Engagement_Counterparty__c> results = new List<Engagement_Counterparty__c>();
		Engagement_Counterparty__c objEC = (Engagement_Counterparty__c) mapJsonObjects.get('Engagement_Counterparty__c');

		for(Integer x = 0; x< count; x++)
		{
			Engagement_Counterparty__c objECTemp = objEC.clone();
			results.add(objECTemp);
		}
		return results;
	}

	public static List<Engagement_Counterparty_Contact__c> CreateECC(String basename, Integer count)
	{
		List<Engagement_Counterparty_Contact__c> results = new List<Engagement_Counterparty_Contact__c>();
		Engagement_Counterparty_Contact__c objECC = (Engagement_Counterparty_Contact__c) mapJsonObjects.get('Engagement_Counterparty_Contact__c');

		for(Integer x = 0; x< count; x++)
		{
			Engagement_Counterparty_Contact__c objECCTemp = objECC.clone();
			results.add(objECCTemp);
		}
		return results;
	}

	public static List<Engagement_Title_Rate_Sheet__c> CreateEngagementTitleRateSheet(String basename, Integer count){
		List<Engagement_Title_Rate_Sheet__c> results = new List<Engagement_Title_Rate_Sheet__c>();
		Engagement_Title_Rate_Sheet__c engagementTitleRateSheet = (Engagement_Title_Rate_Sheet__c)mapJsonObjects.get('Engagement_Title_Rate_Sheet__c');

		for(Integer x = 0; x < count; x++){
			Engagement_Title_Rate_Sheet__c engagementTitleRateSheetTemp = engagementTitleRateSheet.clone();
			results.add(engagementTitleRateSheetTemp);
		}

		return results;
	}

	public static List<FS_Engagement__c> CreateFSEngagement(String basename, Integer count)
	{
		List<FS_Engagement__c> results = new List<FS_Engagement__c>();
		FS_Engagement__c fsEngagement = (FS_Engagement__c)mapJsonObjects.get('FS_Engagement__c');

		for(Integer x = 0; x< count; x++)
		{
			FS_Engagement__c fsEngagementTemp = fsEngagement.clone();
			results.add(fsEngagementTemp);
		}
		return results;
	}

	public static List<FS_Opp__c> CreateFSOpportunity(String basename, Integer count)
	{
		List<FS_Opp__c> results = new List<FS_Opp__c>();
		FS_Opp__c fsOpp = (FS_Opp__c)mapJsonObjects.get('FS_Opp__c');

		for(Integer x = 0; x< count; x++)
		{
			FS_Opp__c fsOppTemp = fsOpp.clone();
			results.add(fsOppTemp);
		}
		return results;
	}

	public static List<Gift__c> CreateGift(String basename, Integer count)
	{
		List<Gift__c> results = new List<Gift__c>();
		Gift__c objGift = (Gift__c)mapJsonObjects.get('Gift__c');

		for(Integer x = 0; x< count; x++)
		{
			Gift__c objGiftTemp = objGift.clone();
			results.add(objGiftTemp);
		}
		return results;
	}

    public static List<Opportunity_Approval__c> CreateOA(String basename, Integer count)
	{
		List<Opportunity_Approval__c> results = new List<Opportunity_Approval__c>();
		Opportunity_Approval__c objOA = (Opportunity_Approval__c) mapJsonObjects.get('Opportunity_Approval__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity_Approval__c objOATemp = objOA.clone();
			results.add(objOATemp);
		}
		return results;
	}

	public static List<Opportunity__c> CreateOpp(String basename, Integer count)
	{
		List<Opportunity__c> results = new List<Opportunity__c>();
		Opportunity__c objOpp = (Opportunity__c) mapJsonObjects.get('Opportunity__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity__c objOppTemp = objOpp.clone();
			objOppTemp.Name = basename + String.valueOf(x);
			results.add(objOppTemp);
		}
		return results;
	}

	public static List<Opportunity_Internal_Team__c> CreateOIT(String basename, Integer count)
	{
		List<Opportunity_Internal_Team__c> results = new List<Opportunity_Internal_Team__c>();
		Opportunity_Internal_Team__c objOIT = (Opportunity_Internal_Team__c) mapJsonObjects.get('Opportunity_Internal_Team__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity_Internal_Team__c objOITTemp = objOIT.clone();
			results.add(objOITTemp);
		}
		return results;
	}

	public static List<Opportunity_External_Team__c> CreateOET(String basename, Integer count)
	{
		List<Opportunity_External_Team__c> results = new List<Opportunity_External_Team__c>();
		Opportunity_External_Team__c objOET = (Opportunity_External_Team__c) mapJsonObjects.get('Opportunity_External_Team__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity_External_Team__c objOETTemp = objOET.clone();
			results.add(objOETTemp);
		}
		return results;
	}


	public static List<Opportunity_Counterparty__c> CreateOC(String basename, Integer count)
	{
		List<Opportunity_Counterparty__c> results = new List<Opportunity_Counterparty__c>();
		Opportunity_Counterparty__c objOC = (Opportunity_Counterparty__c) mapJsonObjects.get('Opportunity_Counterparty__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity_Counterparty__c objOCTemp = objOC.clone();
			results.add(objOCTemp);
		}
		return results;
	}

	public static List<Opportunity_Counterparty_Contact__c> CreateOCC(String basename, Integer count)
	{
		List<Opportunity_Counterparty_Contact__c> results = new List<Opportunity_Counterparty_Contact__c>();
		Opportunity_Counterparty_Contact__c objOCC = (Opportunity_Counterparty_Contact__c) mapJsonObjects.get('Opportunity_Counterparty_Contact__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity_Counterparty_Contact__c objOCCTemp = objOCC.clone();
			results.add(objOCCTemp);
		}
		return results;
	}
	
	public static List<Opportunity_Counterparty_Comment__c> CreateOCCm(String basename, Integer count)
	{
		List<Opportunity_Counterparty_Comment__c> results = new List<Opportunity_Counterparty_Comment__c>();
		Opportunity_Counterparty_Comment__c objOCCm = (Opportunity_Counterparty_Comment__c) mapJsonObjects.get('Opportunity_Counterparty_Comment__c');

		for(Integer x = 0; x< count; x++)
		{
			Opportunity_Counterparty_Comment__c objOCCmTemp = objOCCm.clone();
			results.add(objOCCmTemp);
		}
		return results;
	}

	public static List<Relationship__c> CreateRelationship(String basename, Integer count)
	{
		List<Relationship__c> results = new List<Relationship__c>();
		Relationship__c objRelationship = (Relationship__c) mapJsonObjects.get('Relationship__c');

		for(Integer x = 0; x< count; x++)
		{
			Relationship__c objRelationshipTemp = objRelationship.clone();
			results.add(objRelationshipTemp);
		}
		return results;
	}

	public static List<Affiliation__c> CreateAffiliation(String basename, Integer count)
	{
		List<Affiliation__c> results = new List<Affiliation__c>();
		Affiliation__c objAffiliation = (Affiliation__c) mapJsonObjects.get('Affiliation__c');

		for(Integer x = 0; x< count; x++)
		{
			Affiliation__c objAffiliationTemp = objAffiliation.clone();
			results.add(objAffiliationTemp);
		}
		return results;
	}

	public static List<Delegate_Public_Group__c> CreateDPG(String basename, Integer count)
	{
		List<Delegate_Public_Group__c> results = new List<Delegate_Public_Group__c>();
		Delegate_Public_Group__c objDPG = (Delegate_Public_Group__c) mapJsonObjects.get('Delegate_Public_Group__c');

		for(Integer x = 0; x< count; x++)
		{
			Delegate_Public_Group__c objDPGTemp = objDPG.clone();
			results.add(objDPGTemp);
		}
		return results;
	}

	public static List<Delegate_Public_Group_Member__c> CreateDPGM(String basename, Integer count)
	{
		List<Delegate_Public_Group_Member__c> results = new List<Delegate_Public_Group_Member__c>();
		Delegate_Public_Group_Member__c objDPGM = (Delegate_Public_Group_Member__c) mapJsonObjects.get('Delegate_Public_Group_Member__c');

		for(Integer x = 0; x< count; x++)
		{
			Delegate_Public_Group_Member__c objDPGMTemp = objDPGM.clone();
			results.add(objDPGMTemp);
		}
		return results;
	}

	public static List<User> CreateUser(String basename, Integer count)
	{
		List<User> results = new List<User>();
		User objUser = (User) mapJsonObjects.get('User');

		for(Integer x = 0; x< count; x++)
		{
			User objUserTemp = objUser.clone();
			results.add(objUserTemp);
		}
		return results;
	}

	public static List<Campaign> CreateCampaign(String basename, Integer count)
	{
		List<Campaign> results = new List<Campaign>();
		Campaign objCampaign = (Campaign) mapJsonObjects.get('Campaign');

		for(Integer x = 0; x< count; x++)
		{
			Campaign objCampaignTemp = objCampaign.clone();
			results.add(objCampaignTemp);
		}
		return results;
	}

	public static List<CampaignMember> CreateCampaignMember(String basename, Integer count)
	{
		List<CampaignMember> results = new List<CampaignMember>();
		CampaignMember objCampaignMember = (CampaignMember) mapJsonObjects.get('CampaignMember');

		for(Integer x = 0; x< count; x++)
		{
			CampaignMember objCampaignMemberTemp = objCampaignMember.clone();
			results.add(objCampaignMemberTemp);
		}
		return results;
	}

	public static List<Coverage_Contact__c> CreateCoverageContact(String basename, Integer count)
	{
		List<Coverage_Contact__c> results = new List<Coverage_Contact__c>();
		Coverage_Contact__c objCC = (Coverage_Contact__c)mapJsonObjects.get('Coverage_Contact__c');

		for(Integer x = 0; x< count; x++)
		{
			Coverage_Contact__c objCCTemp = objCC.clone();
			results.add(objCCTemp);
		}
		return results;
	}

    public static List<HL_Report_Link__c> CreateHLReportLink(String basename, Integer count)
	{
		List<HL_Report_Link__c> results = new List<HL_Report_Link__c>();
		HL_Report_Link__c objHLReportLink = (HL_Report_Link__c) mapJsonObjects.get('HL_Report_Link__c');

		for(Integer x = 0; x< count; x++)
		{
			HL_Report_Link__c objHLReportLinkTemp = objHLReportLink.clone();
			results.add(objHLReportLinkTemp);
		}
		return results;
	}

	public static List<Industry__c> CreateIndustry(String basename, Integer count)
	{
		List<Industry__c> results = new List<Industry__c>();
		Industry__c objIndustry = (Industry__c) mapJsonObjects.get('Industry__c');

		for(Integer x = 0; x< count; x++)
		{
			Industry__c objIndustryTemp = objIndustry.clone();
			results.add(objIndustryTemp );
		}
		return results;
	}

	public static List<Investment__c> CreateInvestment(String basename, Integer count)
	{
		List<Investment__c> results = new List<Investment__c>();
		Investment__c objInvestment = (Investment__c)mapJsonObjects.get('Investment__c');

		for(Integer x = 0; x< count; x++)
		{
			Investment__c objInvestmentTemp = objInvestment.clone();
			results.add(objInvestmentTemp );
		}
		return results;
	}

	public static List<Offsite_Template__c> CreateOffsiteTemplate(String basename, Integer count)
	{
		List<Offsite_Template__c> results = new List<Offsite_Template__c>();
		Offsite_Template__c objOT = (Offsite_Template__c)mapJsonObjects.get('Offsite_Template__c');

		for(Integer x = 0; x< count; x++)
		{
			Offsite_Template__c objOTTemp = objOT.clone();
			results.add(objOTTemp);
		}
		return results;
	}

	public static List<Offsite_Template_Industry__c> CreateOffsiteTemplateIndustry(String basename, Integer count)
	{
		List<Offsite_Template_Industry__c> results = new List<Offsite_Template_Industry__c>();
		Offsite_Template_Industry__c objOTI = (Offsite_Template_Industry__c)mapJsonObjects.get('Offsite_Template_Industry__c');

		for(Integer x = 0; x< count; x++)
		{
			Offsite_Template_Industry__c objOTITemp = objOTI.clone();
			results.add(objOTITemp);
		}
		return results;
	}

	public static List<Offsite_Template_Investment_Company__c> CreateOffsiteTemplateInvestment(String basename, Integer count)
	{
		List<Offsite_Template_Investment_Company__c> results = new List<Offsite_Template_Investment_Company__c>();
		Offsite_Template_Investment_Company__c objOTIC = (Offsite_Template_Investment_Company__c)mapJsonObjects.get('Offsite_Template_Investment_Company__c');

		for(Integer x = 0; x< count; x++)
		{
			Offsite_Template_Investment_Company__c objOTICTemp = objOTIC.clone();
			results.add(objOTICTemp);
		}

		return results;
	}

	public static List<Offsite_Template_Coverage_Contact__c> CreateOffsiteTemplateCoverageContact(String basename, Integer count)
	{
		List<Offsite_Template_Coverage_Contact__c> results = new List<Offsite_Template_Coverage_Contact__c>();
		Offsite_Template_Coverage_Contact__c objOTCC = (Offsite_Template_Coverage_Contact__c)mapJsonObjects.get('Offsite_Template_Coverage_Contact__c');

		for(Integer x = 0; x< count; x++)
		{
			Offsite_Template_Coverage_Contact__c objOTCCTemp = objOTCC.clone();
			results.add(objOTCCTemp);
		}

		return results;
	}

	public static List<Revenue_Accrual__c> CreateRevenueAccrual(String basename, Integer count){
		List<Revenue_Accrual__c> results = new List<Revenue_Accrual__c>();
		Revenue_Accrual__c ra = (Revenue_Accrual__c)mapJsonObjects.get('Revenue_Accrual__c');

		for(Integer x = 0; x < count; x++){
			Revenue_Accrual__c raTemp = ra.clone();
			results.add(raTemp);
		}

		return results;
	}

	public static List<Role_Split__c> CreateRoleSplit(String basename, Integer count)
	{
		List<Role_Split__c> results = new List<Role_Split__c>();
		Role_Split__c objRS = (Role_Split__c) mapJsonObjects.get('Role_Split__c');

		for(Integer x = 0; x< count; x++)
		{
			Role_Split__c objRSTemp = objRS.clone();
			results.add(objRSTemp);
		}

		return results;
	}

	public static List<Special_Project__c> CreateSpecialProject(String basename, Integer count)
	{
		List<Special_Project__c> results = new List<Special_Project__c>();
		Special_Project__c objSpecialProject = (Special_Project__c)mapJsonObjects.get('Special_Project__c');

		for(Integer x = 0; x< count; x++)
		{
			Special_Project__c objSpecialProjectTemp = objSpecialProject.clone();
			results.add(objSpecialProjectTemp);
		}
		return results;
	}

    public static List<Time_Record__c> CreateTimeRecord(String basename, Integer count)
	{
		List<Time_Record__c> results = new List<Time_Record__c>();
		Time_Record__c obj = (Time_Record__c)mapJsonObjects.get('Time_Record__c');

		for(Integer x = 0; x< count; x++)
		{
			Time_Record__c objTemp = obj.clone();
			objTemp.Hours_Worked__c = 1.0;
            objTemp.Recording_Status__c = 'Complete';
			results.add(objTemp);
		}

		return results;
	}

    public static List<Time_Record_Period__c> CreateTimeRecordPeriod(String basename, Integer count)
	{
		List<Time_Record_Period__c> results = new List<Time_Record_Period__c>();
		Time_Record_Period__c obj = (Time_Record_Period__c)mapJsonObjects.get('Time_Record_Period__c');

		for(Integer x = 0; x< count; x++)
		{
			Time_Record_Period__c objTemp = obj.clone();
			results.add(objTemp);
		}

		return results;
	}

    public static List<Time_Record_Period_Staff_Member__c> CreateTimeRecordPeriodStaffMember(String basename, Integer count)
	{
		List<Time_Record_Period_Staff_Member__c> results = new List<Time_Record_Period_Staff_Member__c>();
		Time_Record_Period_Staff_Member__c obj = (Time_Record_Period_Staff_Member__c)mapJsonObjects.get('Time_Record_Period_Staff_Member__c');

		for(Integer x = 0; x< count; x++)
		{
			Time_Record_Period_Staff_Member__c objTemp = obj.clone();
			results.add(objTemp);
		}

		return results;
	}

    public static List<Time_Record_Rollup_Day__c> CreateTimeRecordRollupDay(String basename, Integer count)
	{
		List<Time_Record_Rollup_Day__c> results = new List<Time_Record_Rollup_Day__c>();
		Time_Record_Rollup_Day__c obj = (Time_Record_Rollup_Day__c)mapJsonObjects.get('Time_Record_Rollup_Day__c');

		for(Integer x = 0; x< count; x++)
		{
			Time_Record_Rollup_Day__c objTemp = obj.clone();
			results.add(objTemp);
		}

		return results;
	}

    public static List<Time_Record_Rollup_Week__c> CreateTimeRecordRollupWeek(String basename, Integer count)
	{
		List<Time_Record_Rollup_Week__c> results = new List<Time_Record_Rollup_Week__c>();
		Time_Record_Rollup_Week__c obj = (Time_Record_Rollup_Week__c)mapJsonObjects.get('Time_Record_Rollup_Week__c');

		for(Integer x = 0; x< count; x++)
		{
			Time_Record_Rollup_Week__c objTemp = obj.clone();
			results.add(objTemp);
		}

		return results;
	}

   public static List<Time_Record_Time_Record_Rollup_Day__c> CreateTimeRecordTimeRecordRollupDay(String basename, Integer count)
	{
		List<Time_Record_Time_Record_Rollup_Day__c> results = new List<Time_Record_Time_Record_Rollup_Day__c>();
		Time_Record_Time_Record_Rollup_Day__c obj = (Time_Record_Time_Record_Rollup_Day__c)mapJsonObjects.get('Time_Record_Time_Record_Rollup_Day__c');

		for(Integer x = 0; x< count; x++)
		{
			Time_Record_Time_Record_Rollup_Day__c objTemp = obj.clone();
			results.add(objTemp);
		}

		return results;
	}

	public static List<Title_Rate_Sheet__c> CreateTitleRateSheet(String basename, Integer count)
	{
		List<Title_Rate_Sheet__c> results = new List<Title_Rate_Sheet__c>();
		Title_Rate_Sheet__c titleRateSheet = (Title_Rate_Sheet__c) mapJsonObjects.get('Title_Rate_Sheet__c');

		for(Integer x = 0; x< count; x++)
		{
			Title_Rate_Sheet__c titleRateSheetTemp = titleRateSheet.clone();
			results.add(titleRateSheetTemp);
		}

		return results;
	}

   public static User CreateTestUser(string profile){
        List<User> userList = SL_TestSetupUtils.CreateUser(null,1);
        Profile standardUser = [Select Id FROM Profile WHERE Name =: profile];
        userList[0].ProfileId = standardUser.Id;
        userList[0].Lastname = 'User';
        userList[0].Email = 'tusertusertusertusertusertuser@yahoo.in';
        userList[0].Username = 'test@hl2.com';
        userList[0].Alias = 'tuser';
        userList[0].TimeZoneSidKey = 'GMT';
        userList[0].LocaleSidKey = 'en_US';
        userList[0].EmailEncodingKey = 'ISO-8859-1';
        userList[0].LanguageLocaleKey = 'en_US';
        userList[0].Has_Delegates__c = false;
        return userList[0];
    }

    //Creates reusable test data to pass into methods and functions for the offsite template
    public static List<Offsite_Template__c> CreateOffsiteTemplateData(Integer numOffsites, Integer numRelated){
    	//Setup the Test Data
		 List<CapIQ_Company__c> ccList = SL_TestSetupUtils.CreateCapIQCompany('', numRelated);
		 for(Integer i=0; i<numRelated; i++)
	         ccList[i].Company_ID__c = String.valueOf(i);
		 insert ccList;
         List<Account> aList = CreateAccount('', numRelated);
         for(Integer i=0; i<numRelated; i++)
             aList[i].CapIQ_Company__c = ccList[i].Id;
		 insert aList;
         List<Contact> cExtList = SL_TestSetupUtils.CreateContact('', numRelated, ContactType.EXTERNAL_CONTACT);
         insert cExtList;
		 Contact c = SL_TestSetupUtils.CreateContact('', 1, ContactType.HOULIHAN_EMPLOYEE)[0];
         insert c;
         List<Industry__c> industryList = SL_TestSetupUtils.CreateIndustry('', numRelated);
         for(Integer i =0; i<numRelated; i++)
         {
             industryList[i].Active__c = true;
             industryList[i].FSC__c = true;
         }
         insert industryList;
         List<Investment__c> investmentList = SL_TestSetupUtils.CreateInvestment('',numRelated);
         for(Integer i = 0; i<numRelated; i++){
             investmentList[i].Portfolio_CapIQ_Company__c= ccList[1].Id;
             investmentList[i].Sponsor_CapIQ_Company__c = ccList[0].Id;
             investmentList[i].HL_Industry_LK__c = industryList[0].Id;
             investmentList[i].HL_Industry_LK__r = industryList[0];
         }
         insert investmentList;
         investmentList = [SELECT HL_Industry_Sector__c FROM Investment__c WHERE Id IN: investmentList];
         Coverage_Team__c ct = CreateCoverageTeam('', 1)[0];
         ct.Company__c = aList[0].Id;
         ct.Officer__c = c.Id;
         insert ct;
         List<Coverage_Contact__c> cConList = CreateCoverageContact('',numRelated);
         for(Integer i = 0; i<numRelated; i++){
             cConList[i].Coverage_Contact__c = cExtList[i].Id;
             cConList[i].Coverage_Team_Member__c= ct.Id;
         }
         insert cConList;
		 List<Offsite_Template__c> otList = CreateOffsiteTemplate('', numOffsites);
		 for(Integer i = 0; i<numOffsites; i++){
             otList[i].Coverage_Team__c = ct.Id;
             otList[i].Sponsor__c = ccList[0].Id;
             otList[i].Year__c = String.valueOf(Date.Today().year());
         }
		 insert otList;
         return otList;
    }

    //Creates reusable test data to pass into methods and functions for the offsite template
    public static List<Offsite_Template__c> CreateOffsiteTemplateDataWithRelated(Integer numOffsites, Integer numRelated){
    	//Setup the Test Data
    	 Id liveRecordTypeId = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'Live' AND sObjectType = 'Offsite_Template__c'].Id;
		 List<CapIQ_Company__c> ccList = SL_TestSetupUtils.CreateCapIQCompany('', numRelated);
		 for(Integer i=0; i<numRelated; i++)
	         ccList[i].Company_ID__c = String.valueOf(i);
		 insert ccList;
         List<Account> aList = CreateAccount('', numRelated);
         for(Integer i=0; i<numRelated; i++)
             aList[i].CapIQ_Company__c = ccList[i].Id;
		 insert aList;
         List<Contact> cExtList = SL_TestSetupUtils.CreateContact('', numRelated, ContactType.EXTERNAL_CONTACT);
         insert cExtList;
		 Contact c = SL_TestSetupUtils.CreateContact('', 1, ContactType.HOULIHAN_EMPLOYEE)[0];
         insert c;
         List<Industry__c> industryList = SL_TestSetupUtils.CreateIndustry('', numRelated);
         for(Integer i =0; i<numRelated; i++)
         {
             industryList[i].Active__c = true;
             industryList[i].FSC__c = true;
         }
         insert industryList;
         List<Investment__c> investmentList = SL_TestSetupUtils.CreateInvestment('',numRelated);
         for(Integer i = 0; i<numRelated; i++){
             investmentList[i].Portfolio_CapIQ_Company__c= ccList[0].Id;
             investmentList[i].Sponsor_CapIQ_Company__c = ccList[1].Id;
             investmentList[i].HL_Industry_LK__c = industryList[0].Id;
         }
         insert investmentList;
         Coverage_Team__c ct = CreateCoverageTeam('', 1)[0];
         ct.Company__c = aList[0].Id;
         ct.Officer__c = c.Id;
         insert ct;
         List<Coverage_Contact__c> cConList = CreateCoverageContact('',numRelated);
         for(Integer i = 0; i<numRelated; i++){
             cConList[i].Coverage_Contact__c = cExtList[i].Id;
             cConList[i].Coverage_Team_Member__c= ct.Id;
         }
         insert cConList;
		 List<Offsite_Template__c> otList = CreateOffsiteTemplate('', numOffsites);
         for(Integer i = 0; i<numOffsites; i++){
             otList[i].Coverage_Team__c = ct.Id;
             otList[i].Sponsor__c = ccList[0].Id;
             otList[i].Year__c = String.valueOf(Date.Today().year());
             otList[i].RecordTypeId = liveRecordTypeId;
         }
		 insert otList;
		 List<Offsite_Template_Investment_Company__c> oticList = CreateOffsiteTemplateInvestment('', numRelated);
		 for(Offsite_Template_Investment_Company__c otic : oticList)
		 	otic.Offsite_Template__c = otList[0].Id;
		 insert oticList;
         List<Offsite_Template_Industry__c> otiList = CreateOffsiteTemplateIndustry('', numRelated);
		 for(Offsite_Template_Industry__c oti : otiList)
		 	oti.Offsite_Template__c = otList[0].Id;
		 insert otiList;
         List<Offsite_Template_Coverage_Contact__c> otccList = CreateOffsiteTemplateCoverageContact('', numRelated);
         for(Offsite_Template_Coverage_Contact__c otcc : otccList)
             otcc.Offsite_Template__c = otList[0].Id;
         insert otccList;

         return otList;
    }

    //Creates reusable test data to pass into methods and functions for the time record modules
    public static List<Time_Record__c> CreateTimeRecordsWithRelated(Integer numTimeRecords, string category){
        //Setup Test Data
        Time_Record_Period__c tp = SL_TestSetupUtils.CreateTimeRecordPeriod('', 1)[0];
        Time_Record_Period_Staff_Member__c trpsm = SL_TestSetupUtils.CreateTimeRecordPeriodStaffMember('', 1)[0];
        List<Time_Record__c> timeRecords = SL_TestSetupUtils.CreateTimeRecord('',numTimeRecords);
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        //User u = SL_TestSetupUtils.CreateTestUser('System Administrator');
        insert e;
        tp.Start_Date__c = Date.today();
        tp.End_Date__c = Date.today().addDays(7);
        tp.Period_Category__c = category;
        trpsm.Title__c = 'Financial Analyst';
        trpsm.Office__c = 'LA';
        c.Office__c = 'LA';
        c.Title = 'Financial Analyst';
        c.User__c = UserInfo.getUserId();
        insert tp;
        insert c;
        //insert u;
        trpsm.Contact__c = c.Id;
        trpsm.Contact__r = c;
        trpsm.Time_Record_Period__c = tp.Id;
        trpsm.Time_Record_Period__r = tp;
        trpsm.User__c = UserInfo.getuserId();
        //trpsm.User__r = u;
        insert trpsm;
        for(Time_Record__c tr : timeRecords){
            tr.Activity_Type__c = 'Consult';
            tr.Time_Record_Period_Staff_Member__c = trpsm.Id;
            tr.Time_Record_Period_Staff_Member__r = trpsm;
            tr.Hourly_Rate__c = 0;
            tr.Hours_Worked__c = 1.0;
            tr.Seconds_Worked_Actual__c = 0;
            tr.Engagement__c = e.Id;
            tr.Recording_Status__c = 'Complete';
        }
        insert timeRecords;
        return timeRecords;
    }

    //Creates reusable test data to pass into methods and functions for the time record modules
    public static List<Time_Record_Rollup_Week__c> CreateTimeRecordRollupWeeksWithRelated(Integer numTimeRecords, string category){
        //Setup Test Data
        Time_Record_Period__c tp = SL_TestSetupUtils.CreateTimeRecordPeriod('', 1)[0];
        Time_Record_Period_Staff_Member__c trpsm = SL_TestSetupUtils.CreateTimeRecordPeriodStaffMember('', 1)[0];
        List<Time_Record_Rollup_Week__c> timeRecords = SL_TestSetupUtils.CreateTimeRecordRollupWeek('',numTimeRecords);
        Contact c = SL_TestSetupUtils.CreateContact('', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('', 1)[0];
        //User u = SL_TestSetupUtils.CreateTestUser('System Administrator');

        tp.Start_Date__c = Date.today();
        tp.End_Date__c = Date.today().addDays(7);
        tp.Period_Category__c = category;
        trpsm.Title__c = 'Financial Analyst';
        trpsm.Office__c = 'LA';
        c.Office__c = 'LA';
        c.Title = 'Financial Analyst';
        c.User__c = UserInfo.getUserId();
        insert tp;
        insert c;
        //insert u;
        trpsm.Contact__c = c.Id;
        trpsm.Contact__r = c;
        trpsm.Time_Record_Period__c = tp.Id;
        trpsm.Time_Record_Period__r = tp;
        trpsm.User__c = UserInfo.getuserId();
        //trpsm.User__r = u;
        insert trpsm;
        for(Time_Record_Rollup_Week__c tr : timeRecords){
            tr.Time_Record_Period_Staff_Member__c = trpsm.Id;
            tr.Time_Record_Period_Staff_Member__r = trpsm;
            tr.Hours_Worked_Weekday__c = 0;
            tr.Hours_Worked_Weekend__c = 0;
            tr.Engagement__c = e.Id;
        }
        insert timeRecords;
        return timeRecords;
    }

	private static String getTestJSONFromStaticResources(String resource)
    {
     	return [SELECT body, name from StaticResource where Name =:resource].body.toString();
    }
}