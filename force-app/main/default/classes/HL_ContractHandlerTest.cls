@isTest
public class HL_ContractHandlerTest {

    @isTest
    static void updateAccountClientNumberTest(){
        
        HL_Auto_Number_Settings__c autoNumber = new HL_Auto_Number_Settings__c();
        autoNumber.Name = 'Account';
        autoNumber.Auto_Number__c = 100;
        insert autoNumber;
        
        Account account = new Account();
        account.Name = 'Account Test 1';
        insert account;
        
        Contract__c contract = new Contract__c();
        contract.Name = 'Contract Test 1';
        contract.Bill_To__c = account.Id;
        insert contract;
    }
}