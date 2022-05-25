@isTest
private class Test_HL_OffsiteTemplate {
    @testSetup
    private static void SetupData(){
        final integer offsiteTemplateRecords = 1;
        final integer relatedRecords = 5;
        List<CapIQ_Company__c> capIQCompanyList = (List<CapIQ_Company__c>)HL_TestFactory.CreateSObjectList('CapIQ_Company__c', false, relatedRecords);
        for(Integer i=0; i<relatedRecords; i++)
            capIQCompanyList[i].Company_ID__c = String.valueOf(i);
        insert capIQCompanyList;
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, relatedRecords);
        for(Integer i=0; i < relatedRecords; i++)
            accountList[i].CapIQ_Company__c = capIQCompanyList[i].Id;
        insert accountList;
        List<Contact> externalContactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, relatedRecords);
        insert externalContactList;
        Contact contactRecord = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        insert contactRecord;
        List<Industry__c> industryList = (List<Industry__c>)HL_TestFactory.CreateSObjectList('Industry__c', false, relatedRecords);
        for(Integer i =0; i < relatedRecords; i++)
        {
            industryList[i].Active__c = true;
            industryList[i].FSC__c = true;
        }
        insert industryList;
        List<Investment__c> investmentList = (List<Investment__c>)HL_TestFactory.CreateSObjectList('Investment__c', false, relatedRecords);
        for(Integer i = 0; i < relatedRecords; i++){
            investmentList[i].Portfolio_CapIQ_Company__c= capIQCompanyList[1].Id;
            investmentList[i].Sponsor_CapIQ_Company__c = capIQCompanyList[0].Id;
            investmentList[i].HL_Industry_LK__c = industryList[0].Id;
            investmentList[i].HL_Industry_LK__r = industryList[0];
        }
        insert investmentList;
        investmentList = [SELECT HL_Industry_Sector__c FROM Investment__c WHERE Id IN: investmentList];
        Coverage_Team__c coverageTeamRecord = (Coverage_Team__c)HL_TestFactory.CreateSObject('Coverage_Team__c', false);
        coverageTeamRecord.Company__c = accountList[0].Id;
        coverageTeamRecord.Officer__c = contactRecord.Id;
        insert coverageTeamRecord;
        List<Coverage_Contact__c> coverageContactList = (List<Coverage_Contact__c>)HL_TestFactory.CreateSObjectList('Coverage_Contact__c', false, relatedRecords);
        for(Integer i = 0; i < relatedRecords; i++){
            coverageContactList[i].Coverage_Contact__c = externalContactList[i].Id;
            coverageContactList[i].Coverage_Team_Member__c= coverageTeamRecord.Id;
        }
        insert coverageContactList;
        List<Offsite_Template__c> offsiteTemplateList = (List<Offsite_Template__c>)HL_TestFactory.CreateSObjectList('Offsite_Template__c', false, offsiteTemplateRecords);
        for(Integer i = 0; i < offsiteTemplateRecords; i++){
            offsiteTemplateList[i].Coverage_Team__c = coverageTeamRecord.Id;
            offsiteTemplateList[i].Sponsor__c = capIQCompanyList[0].Id;
            offsiteTemplateList[i].Year__c = String.valueOf(Date.Today().year());
        }
        insert offsiteTemplateList;
    }

    @isTest
    private static void TestCreateFunctionality() {
        List<Offsite_Template__c> offsiteTemplateList = [SELECT Coverage_Team__c, Legacy_SLX_ID__c, Coverage_Team__r.Officer__c, Coverage_Team__r.Officer__r.Name,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_From__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_To__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Most_Recent_Fund_Size_MM__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Name,
                                                                Coverage_Team__r.Company__r.BillingCity,
                                                                Coverage_Team__r.Company__r.BillingState,
                                                                Coverage_Team__r.Company__r.BillingCountry,
                                                         		Year__c
                                                         FROM Offsite_Template__c];
       
        Test.startTest();

        HL_OffsiteTemplate.PopulateSnapshotData(offsiteTemplateList);

        Test.stopTest();

        //Verify that the offsite template industry records are equivalent to the FS, Active Industry records
        System.assertEquals([SELECT Id FROM Offsite_Template_Industry__c WHERE Offsite_Template__c =: offsiteTemplateList[0].Id].size(), [SELECT Id FROM Industry__c WHERE FSC__c = true AND Active__c = true].size());
        //Verify that the offsite template investment company records are equivalent to our related records size
        System.assertEquals(5, [SELECT Id FROM Offsite_Template_Investment_Company__c].size());
    }

    @isTest
    private static void TestCreateCloneFunctionality() {
        List<Offsite_Template__c> offsiteTemplateList = [SELECT Coverage_Team__c,
                                                                Coverage_Team__r.Officer__c,
                                                                Coverage_Team__r.Officer__r.Name,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_From__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_To__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Most_Recent_Fund_Size_MM__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Name,
                                                                Coverage_Team__r.Company__r.BillingCity,
                                                                Coverage_Team__r.Company__r.BillingState,
                                                                Coverage_Team__r.Company__r.BillingCountry,
                                                                Legacy_SLX_ID__c,
                                                                Sponsor__c
                                                         FROM Offsite_Template__c];
		Integer month = Date.Today().month();
        Integer year = Date.Today().year() + (month > 3 ? 1 : 0);
        
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList)
            offsiteTemplateRecord.Year__c = String.valueOf(year - 1);
		update offsiteTemplateList;
        
        Test.startTest();

        Offsite_Template__c offsiteTemplateRecord = offsiteTemplateList[0].clone();
        insert offsiteTemplateRecord;

        Test.stopTest();

        //Verify the Industry Record Count is Equivalent to the Original Offsite Industry Record Count
        System.assertEquals([SELECT Id FROM Offsite_Template_Industry__c WHERE Offsite_Template__c =: offsiteTemplateList[0].Id].size(), [SELECT Id FROM Offsite_Template_Industry__c WHERE Offsite_Template__c !=: offsiteTemplateList[0].Id].size());
    }

    @isTest
    private static void TestInsertedInvestmentRecordsFunctionality() {
        List<Offsite_Template__c> offsiteTemplateList = [SELECT Coverage_Team__c,
                                                                Coverage_Team__r.Officer__c,
                                                                Coverage_Team__r.Officer__r.Name,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_From__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_To__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Most_Recent_Fund_Size_MM__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Name,
                                                                Coverage_Team__r.Company__r.BillingCity,
                                                                Coverage_Team__r.Company__r.BillingState,
                                                                Coverage_Team__r.Company__r.BillingCountry,
                                                                Legacy_SLX_ID__c,
                                                                Sponsor__c
                                                         FROM Offsite_Template__c];
        Map<Id, Investment__c> investmentMap = new Map<Id, Investment__c>();
        Investment__c investmentRecord = (Investment__c)HL_TestFactory.CreateSObject('Investment__c', false);
        investmentRecord.Sponsor_CapIQ_Company__c = offsiteTemplateList[0].Sponsor__c;
        investmentMap.put(investmentRecord.Id, investmentRecord);

        Test.startTest();

        HL_OffsiteTemplate.HandleInsertedInvestmentRecords(investmentMap);

        Test.stopTest();
        //Verify the new investment has been added
        System.assertEquals(5 + 1, [SELECT Id FROM Offsite_Template_Investment_Company__c].size());
    }

    @isTest
    private static void TestInsertedContactRecordsFunctionality() {
        List<Offsite_Template__c> offsiteTemplateList = [SELECT Coverage_Team__c, Legacy_SLX_ID__c, Coverage_Team__r.Officer__c, Coverage_Team__r.Officer__r.Name,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_From__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Equity_Investment_To__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Most_Recent_Fund_Size_MM__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__c,
                                                                Coverage_Team__r.Company__r.CapIQ_Company__r.Name,
                                                                Coverage_Team__r.Company__r.BillingCity,
                                                                Coverage_Team__r.Company__r.BillingState,
                                                                Coverage_Team__r.Company__r.BillingCountry
                                                         FROM Offsite_Template__c];
        Map<Id, Coverage_Contact__c> coverageContactMap = new Map<Id, Coverage_Contact__c>();
        Coverage_Contact__c coverageContactRecord = (Coverage_Contact__c)HL_TestFactory.CreateSObject('Coverage_Contact__c', false);
        coverageContactRecord.Coverage_Team_Member__c = offsiteTemplateList[0].Coverage_Team__c;
        coverageContactMap.put(coverageContactRecord.Id, coverageContactRecord);

        Test.startTest();

        HL_OffsiteTemplate.HandleInsertedContactRecords(coverageContactMap);

        Test.stopTest();

        //Verify the new coverage Contact has been added
        System.assertEquals(5 + 1, [SELECT Id FROM Offsite_Template_Coverage_Contact__c].size());
    }
}