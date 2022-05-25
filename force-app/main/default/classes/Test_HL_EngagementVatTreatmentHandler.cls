@isTest
private class Test_HL_EngagementVatTreatmentHandler{
    
    private static Account clientAccount;
    private static Account subjectAccount;
    private static Engagement__c engagementCF;
    private static Engagement_VAT_Treatment__c engagementVat;
    
    @testSetup static void loadTestData() {
        // Generate Test Data
        string engagementNameCF = 'Test CF Engagement';
        string engagementNumberCF = '80001';
        string engagementStageCF = 'Signed LOI/Due Diligence';
        string jobTypeCF = 'Sellside';
        string engagementRecordTypeIdCF = '012i0000000tIWwAAM';
        string primaryOfficeCF = 'NY';
        
        
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
        
        engagementVat = new Engagement_VAT_Treatment__c (Effective_Date__c = System.Today(),
                                                         Treatment__c = 'Zero Rated'
                                                        );
        
        insert clientAccount;
        insert subjectAccount;
        insert engagementCF;
        
        engagementVat.Engagement__c = engagementCF.Id;
        
        
        insert engagementVat;
        
        Delete engagementVat; 
    }
    
    @isTest
    static void testEngagementVATTreatment(){
        HL_Auto_Number_Settings__c autoNumber = new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        List<Legal_Entity__c> legalEntityList = new List<Legal_Entity__c>();
        Legal_Entity__c legalEntity = new Legal_Entity__c();
        legalEntity.name = 'HL Inc.';
        legalEntity.Available_for_Project__c = true;
        legalEntity.ERP_VAT_Legal_Entity__c = true;
        legalEntity.ERP_Entity_Code__c = '030';
        legalEntityList.add(legalEntity);
        
        Legal_Entity__c legalEntityChina = new Legal_Entity__c();
        legalEntityChina.name = 'HL (China) Ltd';
        legalEntityChina.Available_for_Project__c = true;
        legalEntityChina.ERP_VAT_Legal_Entity__c = true;
        legalEntityChina.ERP_Entity_Code__c = '330';
        legalEntityList.add(legalEntityChina);
        insert legalEntityList;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        account.BillingCountry = 'United States';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Contact';
        contact.LastName = 'Test145';
        contact.Email = 'contacttest145@test145.com';
        contact.Phone = '9999999999';
        contact.AccountId = account.Id;
        insert contact;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Engagement 125';
        opportunity.Client__c = account.Id;
        opportunity.Subject__c = account.Id;
        opportunity.Legal_Entity__c = legalEntity.Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opportunity;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        engagement.Legal_Entity__c = legalEntity.Id;
        engagement.Opportunity__c = opportunity.Id;
        insert engagement;
        
        Engagement_External_Team__c engExternal = new Engagement_External_Team__c();
        engExternal.Contact__c = contact.id;
        engExternal.Engagement__c = engagement.id;
        engExternal.Billing_Contact__c = True;
        engExternal.Acknowledge_Billing_Contact__c = True;
        insert engExternal;
        
        test.startTest();
        
        Contract__c contract = new Contract__c();
        contract.Name = 'Contract Test 1';
        contract.Bill_To__c = account.Id;
        contract.Client__c = account.Id;
        contract.Ship_To__c = account.Id;
        contract.Billing_Contact__c = contact.Id;
        contract.Engagement__c = engagement.Id;
        contract.ERP_Contract_Type__c = 'Engagement';
        contract.HL_Entity__c = '030';
        insert contract;
        
        Engagement_VAT_Treatment__c engVATTreatment = new Engagement_VAT_Treatment__c();
        engVATTreatment.Engagement__c = engagement.Id;
        engVATTreatment.Effective_Date__c = system.today();
        engVATTreatment.Treatment__c = 'Standard Rated';
        insert engVATTreatment;
       
        
        engVATTreatment.Treatment__c = 'Zero Rated';
        update engVATTreatment;  
        
        
        List<Engagement_VAT_Treatment__c> engVatList = new List<Engagement_VAT_Treatment__c>();
        engVatList.add(engVATTreatment);
        
        List<Engagement_VAT_Treatment__c> engVatList1 = new List<Engagement_VAT_Treatment__c>();        
        Engagement_VAT_Treatment__c engVATTreatment2 = new Engagement_VAT_Treatment__c();
        engVATTreatment2.Engagement__c = engagement.Id;
        engVATTreatment2.Effective_Date__c = Date.newInstance(2019, 12, 20);
        engVATTreatment2.Treatment__c = 'Standard Test';
        engVatList1.add(engVATTreatment2);
        
        try{
            insert engVatList;
        }
        catch(exception ex){
            system.debug(ex.getMessage());
        }
        
        engagement.Legal_Entity__c = legalEntityChina.id;
        update engagement;
                
        HL_EngagementVatTreatmentHandler hlHandler = new HL_EngagementVatTreatmentHandler(true,1);
        test.stopTest(); 
    }
    
    
}