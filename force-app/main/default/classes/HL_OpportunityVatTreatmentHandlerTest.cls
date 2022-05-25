@isTest
public class HL_OpportunityVatTreatmentHandlerTest {
    
    @isTest
    static void updateTaxClassificationCodeTest(){
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
        contact.Email = 'account@test.com';
        contact.FirstName = 'Contact';
        contact.LastName = 'Test';
        contact.AccountId= account.id;
        contact.Title = 'CFO';
        insert contact;
        
        Opportunity__c opportunity = new Opportunity__c();
        opportunity.Name = 'Opp Test 1';
        opportunity.Client__c = account.Id;
        opportunity.Legal_Entity__c = legalEntityList[0].Id;
        opportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        insert  opportunity;
        
        Opportunity_External_Team__c oppExternal = new Opportunity_External_Team__c();
        oppExternal.Contact__c = contact.id;
        oppExternal.Opportunity__c = opportunity.id;
        oppExternal.Billing_Contact__c = True;
        oppExternal.Acknowledge_Billing_Contact__c = True;
        insert oppExternal;
        
        Contract__c oppContract = new Contract__c();
        oppContract.Name = 'Contract Test 1';
        oppContract.Bill_To__c = account.Id;
        oppContract.Client__c = account.Id;
        oppContract.Ship_To__c = account.Id;
        oppContract.Opportunity__c = opportunity.Id;
        oppContract.ERP_Contract_Type__c = 'Engagement';
        oppContract.HL_Entity__c = '030';
        oppContract.Billing_Contact__c = contact.id;
        insert oppContract;
        
        Opportunity_VAT_Treatment__c oppVATTreatment = new Opportunity_VAT_Treatment__c();
        oppVATTreatment.Opportunity__c = opportunity.Id;
        oppVATTreatment.Treatment__c = 'Standard Rated';
        oppVATTreatment.Effective_Date__c = system.today();
        insert oppVATTreatment;
        
        opportunity.Legal_Entity__c = legalEntityList[1].Id;
        update opportunity;
        
        oppVATTreatment.Treatment__c = 'Zero Rated';
        update oppVATTreatment;
        
        Opportunity_VAT_Treatment__c oppVATTreatment1 = new Opportunity_VAT_Treatment__c();
        oppVATTreatment1.Opportunity__c = opportunity.Id;
        oppVATTreatment1.Treatment__c = 'Standard Rated';
        oppVATTreatment1.Effective_Date__c = system.today();
        try{
        insert oppVATTreatment1;
        }catch(exception ex){
            
        }
        
        delete oppVATTreatment;
    }
}