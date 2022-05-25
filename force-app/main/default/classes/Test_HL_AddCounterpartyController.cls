@isTest
public class Test_HL_AddCounterpartyController {
// no he is getting this error when he was validating not sure which org i can ask
    @testSetup
    private static  void TestFVA_StageUpdates(){
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
        List<Engagement__c> eFVA_List = SL_TestSetupUtils.CreateEngagement('', 1);
        for(Engagement__c e : eFVA_List){
            e.Name='Test FVA Engagement';
            e.Client__c = clientAccount.Id;
            e.Subject__c = subjectAccount.Id;
            e.Line_of_Business__c = 'FVA';
            e.Job_Type__c = 'FMV Transaction Based Opinion';
            e.Primary_Office__c = 'NY';
            e.Total_Estimated_Fee__c = 100000;
            e.RecordTypeId = '012i0000001NDwh';
        }
        
        insert eFVA_List;
        
        Engagement_Counterparty__c inx = new Engagement_Counterparty__c();
        inx.Engagement__c = eFVA_List[0].Id;
        insert inx;
        
        Engagement_Counterparty_Contact__c counterpartyContact = new Engagement_Counterparty_Contact__c();
        counterpartyContact.Contact__c = hlContactList[0].Id;
        //clonedRec.Type__c = rec.Type__c;
        counterpartyContact.CounterParty__c = inx.Id;
        insert counterpartyContact;
    }
    testmethod static void getFieldsAndRecords(){
        HL_AddCounterpartyController.getFieldsAndRecords('Company_List_Member__c','CompanyList_Columns_Lightning','Company_List__c','','');
        HL_AddCounterpartyController.getFieldsAndRecordsEngagement('Engagement_Counterparty__c','Counterparties_Columns_Lightning','Engagement__c','','');
        HL_AddCounterpartyController.getCompanyList();
    }
    
    testmethod static void cloneCounterparties(){
        List<Id> engagementCounterparty = new List<Id>();
        for(Engagement_Counterparty__c ind : [Select id from Engagement_Counterparty__c]){
            engagementCounterparty.add(ind.Id);
        }
        List<Engagement__c> eFVA_List = new List<Engagement__c>();
        eFVA_List = [Select id from Engagement__c];
        
        Company_List__c ink =new Company_List__c();
        ink.Name = 'Test';
        insert ink;
        
        Company_List_Member__c inm = new Company_List_Member__c();
        inm.Company_List__c = ink.Id;
        insert inm;
        //inm.Company__c = 
        //
        
        System.debug('engagementCounterparty : '+engagementCounterparty.size());
        HL_AddCounterpartyController.cloneCounterParties(engagementCounterparty,eFVA_List[0].Id);
        HL_AddCounterpartyController.insertCompanyMemberList(new list<Id>{inm.Id},eFVA_List[0].Id);
    }
    
    
}