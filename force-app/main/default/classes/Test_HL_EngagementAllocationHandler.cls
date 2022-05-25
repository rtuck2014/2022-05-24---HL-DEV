@isTest
private class Test_HL_EngagementAllocationHandler {

    private static Account clientAccount;
    private static Account subjectAccount;
    private static Engagement__c engagementCF;
    private static Engagement_Allocation__c engagementAllocation;

    @testSetup static void loadTestData() {
        // Generate Test Data
        string engagementNameCF = 'Test CF Engagement';
        string engagementNumberCF = '80001';
        string engagementStageCF = 'Signed LOI/Due Diligence';
        string jobTypeCF = 'Sellside';
        string engagementRecordTypeIdCF = '012i0000000tIWwAAM';
        string primaryOfficeCF = 'NY';
        
        string engagementAllocationName = 'Test Engagement Allocation Name';
        string engagementAllocationInustryGrp = 'HC - Healthcare';
        Decimal engagementAllocationInustryGrpFee = 12.22;
        string engagementAllocationProdSpecial = 'TAS- TAX';//'Generalist/REVS';
        Decimal engagementAllocationProdSpecialFee = 200.11;

        
        clientAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        subjectAccount = (Account)HL_TestFactory.CreateSObject('Account', false);
        engagementCF = New Engagement__c(Name = engagementNameCF
                                        ,Engagement_Number__c = engagementNumberCF
                                        ,Client__c = clientAccount.Id
                                        ,Subject__c = subjectAccount.Id
                                        ,Stage__c = engagementStageCF
                                        ,Line_of_Business__c = 'CF'
                                        ,Job_Type__c = jobTypeCF
                                        ,RecordTypeId = engagementRecordTypeIdCF
                                        ,Primary_Office__c = primaryOfficeCF
                                        ,Total_Estimated_Fee__c = 0
                                        ,Percentage_of_Completion__c = 1
                                        ,Exclude_From_Reversal__c = true
                                        ,Exclusion_Comment__c = 'Excluded for testing');
        
        engagementAllocation = new Engagement_Allocation__c(Name = engagementAllocationName,
                                                            Industry_Group__c = engagementAllocationInustryGrp,
                                                            Industry_Group_Fee__c = engagementAllocationInustryGrpFee,
                                                            Product_Specialty__c = engagementAllocationProdSpecial,
                                                            Product_Specialty_Fee__c = engagementAllocationProdSpecialFee
                                        
                                        );
        
        
        insert clientAccount;
        insert subjectAccount;
        insert engagementCF;
        
        engagementAllocation.Engagement__c = engagementCF.Id;
        
        insert engagementAllocation;
        
        
        
        
    }
    
    @isTest
    private static void TestInsertEngagementAllocationRecord()
    {
        // Confirm that Engagement Allocation record was created successfully
        System.assertEquals([Select Id From Engagement_Allocation__c].Size(), 1);
        
        Engagement_Allocation__c engagementAllocation = [Select Id,Line_of_Business__c From Engagement_Allocation__c];

        System.assertEquals(engagementAllocation.Line_of_Business__c,'CF');
    }        
}