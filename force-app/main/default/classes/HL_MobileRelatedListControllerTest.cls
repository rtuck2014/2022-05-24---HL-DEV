@isTest
public class HL_MobileRelatedListControllerTest {

    @isTest 
    static void getrelatedListRecordsTest(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Operating Company').getRecordTypeId();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity__c.getRecordTypeInfosByName().get('FVA').getRecordTypeId();
        Account acc = new account();
        acc.Name = 'Houlihan Lokey Test1';
        acc.RecordTypeId = accRecordTypeId;
        insert acc;
        
        Opportunity__c opp = new Opportunity__c();
        opp.Name = 'Opp 1';
        opp.Client__c = acc.Id;
        opp.Subject__c = acc.Id;
        opp.Line_of_Business__c = 'FVA';
        opp.Job_Type__c ='Consulting';
        opp.Industry_Group__c = 'BUS - Business Services';
        opp.Stage__c ='Evaluating Priority';
        opp.RecordTypeId = oppRecordTypeId;
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        
        HL_MobileRelatedListController.getRecords(acc.Id, 'CompanyOpportunityList'); 
    }
}