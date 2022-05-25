@isTest
public class Test_HL_ContractHandler {
    
    @isTest
    static void updateContractTest(){
        
        HL_Auto_Number_Settings__c autoNumber= new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        Legal_Entity__c legalEntity = new Legal_Entity__c();
        legalEntity.name = 'HL Inc.';
        legalEntity.Available_for_Project__c = true;
        legalEntity.ERP_VAT_Legal_Entity__c = true;
        legalEntity.ERP_Entity_Code__c = '030';
        insert legalEntity;
        
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
        contact.Title = 'CFO';
        insert contact;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Engagement 125';
        opportunity.Client__c = account.Id;
        opportunity.Subject__c = account.Id;
        opportunity.Legal_Entity__c = legalEntity.Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opportunity;
        
        
        Opportunity_External_Team__c oppExternal = new Opportunity_External_Team__c();
        oppExternal.Contact__c = contact.id;
        oppExternal.Opportunity__c = opportunity.id;
        oppExternal.Billing_Contact__c = True;
        oppExternal.Acknowledge_Billing_Contact__c = True;
        insert oppExternal;
        
        Engagement__c engagement = new Engagement__c();
        engagement.Name = 'Engagement 125';
        engagement.Client__c = account.Id;
        engagement.Subject__c = account.Id;
        engagement.Legal_Entity__c = legalEntity.Id;
        insert engagement;
        
        Engagement_External_Team__c engExternal = new Engagement_External_Team__c();
        engExternal.Contact__c = contact.id;
        engExternal.Engagement__c = engagement.id;
        engExternal.Billing_Contact__c = True;
        engExternal.Acknowledge_Billing_Contact__c = True;
        insert engExternal;
        
        Engagement_VAT_Treatment__c engVATTreatment = new Engagement_VAT_Treatment__c();
        engVATTreatment.Engagement__c = engagement.Id;
        engVATTreatment.Effective_Date__c = system.today();
        engVATTreatment.Treatment__c = 'Standard Rated';
        insert engVATTreatment;
        
       /* Opportunity_VAT_Treatment__c oppVATTreatment = new Opportunity_VAT_Treatment__c();
        oppVATTreatment.Opportunity__c = opportunity.Id;
        oppVATTreatment.Effective_Date__c = system.today();
        oppVATTreatment.Treatment__c = 'Standard Rated';
        insert oppVATTreatment; */
        
        test.startTest();
        List<Contract__c> contractList = new List<Contract__c>();
        Contract__c contract = new Contract__c();
        contract.Name = 'Contract Test 1';
        contract.Bill_To__c = account.Id;
        contract.Client__c = account.Id;
        contract.Ship_To__c = account.Id;
        contract.Billing_Contact__c = contact.Id;
        contract.Engagement__c = engagement.Id;
        contract.ERP_Contract_Type__c = 'Engagement';
        contract.HL_Entity__c = '030';
        contractList.add(contract);
        
        Contract__c icoContract = new Contract__c();
        icoContract.Name = 'Contract Test 1';
        icoContract.Bill_To__c = account.Id;
        icoContract.Client__c = account.Id;
        icoContract.Ship_To__c = account.Id;
        icoContract.Billing_Contact__c = contact.Id;
        icoContract.Engagement__c = engagement.Id;
        icoContract.ERP_Contract_Type__c = 'ICO';
        icoContract.HL_Entity__c = '030';
        contractList.add(icoContract);
        
        Contract__c oppContract = new Contract__c();
        oppContract.Name = 'Contract Test 1';
        oppContract.Bill_To__c = account.Id;
        oppContract.Client__c = account.Id;
        oppContract.Ship_To__c = account.Id;
        oppContract.Billing_Contact__c = contact.Id;
        oppContract.Opportunity__c = opportunity.Id;
        oppContract.ERP_Contract_Type__c = 'Engagement';
        oppContract.HL_Entity__c = '030';
        contractList.add(oppContract);
        
        Contract__c oppIPOContract = new Contract__c();
        oppIPOContract.Name = 'Contract Test 1';
        oppIPOContract.Bill_To__c = account.Id;
        oppIPOContract.Client__c = account.Id;
        oppIPOContract.Ship_To__c = account.Id;
        oppIPOContract.Billing_Contact__c = contact.Id;
        oppIPOContract.Opportunity__c = opportunity.Id;
        oppIPOContract.ERP_Contract_Type__c = 'ICO';
        oppIPOContract.HL_Entity__c = '030';
        contractList.add(oppIPOContract);
        
        insert contractList;
        test.stopTest();
    }
}