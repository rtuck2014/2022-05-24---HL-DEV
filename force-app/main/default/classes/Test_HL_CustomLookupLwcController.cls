@isTest
public class Test_HL_CustomLookupLwcController {

    testmethod static void fetchLookupData(){
        Account clientAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert clientAccount;
        
        Account subjectAccount = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subjectAccount;
        
        List<Contact> hlContactList = new List<Contact>();
        for (Contact c : SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)) {
            c.AccountId = clientAccount.Id;
            hlContactList.add(c);
        }
        insert hlContactList;

        
        //FVA Engagements
        Id recordTypeId =Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Transaction_Opinion').getRecordTypeId();
        List<Engagement__c> eFVA_List = SL_TestSetupUtils.CreateEngagement('', 1);
        for(Engagement__c e : eFVA_List){
            e.Name='Test FVA Engagement';
            e.Client__c = clientAccount.Id;
            e.Subject__c = subjectAccount.Id;
            e.Line_of_Business__c = 'FVA';
            e.Job_Type__c = 'FMV Transaction Based Opinion';
            e.Primary_Office__c = 'NY';
            e.Total_Estimated_Fee__c = 100000;
            e.RecordTypeId = recordTypeId;
        }
        
        insert eFVA_List;
        
        HL_CustomLookupLwcController.fetchLookupData('Test','Engagement__c','Engagement_Number__c');
        HL_CustomLookupLwcController.fetchLookupData('Test','Engagement__c',null);
        HL_CustomLookupLwcController.fetchDefaultRecord(null,'Engagement__c','Engagement_Number__c');
        HL_CustomLookupLwcController.fetchDefaultRecord(null,'Engagement__c',null);
    }
}