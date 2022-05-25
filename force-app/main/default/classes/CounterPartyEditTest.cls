@IsTest
private class CounterPartyEditTest {
    @IsTest
    static void myUnitTest(){
        Map<String,Engagement_Counterparty_List_View__mdt> metaMap = CounterPartyEdit.getListViewMeta();
        Account client = new Account();
        client.name = 'Client test';
        insert client;
        
        Account subject = new Account();
        subject.name = 'subject test';
        insert subject;
        
        Contact cntct = new contact();
        cntct.Accountid = client.id;
        cntct.lastname = 'TEST';
        cntct.Firstname = 'TEST';
        cntct.Email='testasdf234@xyz.com';
        insert cntct;
        
        Legal_Entity__c lgE = new Legal_Entity__c ();
        lge.name ='test LGE';
        
        insert lgE;
        
        Engagement__c engMent = new Engagement__c ();
        engMent.name = 'Test';
        engMent.Subject__c  = subject.Id;
        engMent.Client__c   = Client.Id;
        engMent.Line_of_Business__c  = 'CF';
        engMent.Job_Type__c ='Activism Advisory';
        engMent.Industry_Group__c  = 'BUS - Business Services';
        engMent.Sector__c  ='Education & Training';
        engMent.Stage__c  = 'Retained';
        engMent.Primary_Office__c  = 'AM';
        engMent.Legal_Entity__c  = lgE.Id;        
        insert engMent;
        
        Engagement_Counterparty__c ec = new Engagement_Counterparty__c(Name='Test',Engagement__c=engment.Id);
        insert ec;
        
        Engagement_Counterparty_Contact__c ecc = new Engagement_Counterparty_Contact__c(Counterparty__c=ec.Id,Contact__c=cntct.Id);
        insert ecc;

        CounterPartyEdit.getEngagement(engMent.Id);

        Engagement_Counterparty_List_View__mdt meta = metaMap.values().get(0);
        CounterPartyEdit.getCounterpartyList(engment.Id, 20, 1, meta.Filter__c);
        
        List<CounterPartyEdit.CounterpartyContactWrapper> eccList = CounterpartyEdit.getCounterpartyContacts(new List<String> {ec.Id});
        
        CounterpartyEdit.deleteCounterparties(new List<Id>{ec.Id});
        
        List<EmailTemplate> etList = CounterpartyEdit.getAvailableTemplates();
        
        try{
        	CounterpartyEdit.getEmailTemplate(null);
        }catch(Exception e){
            
        }
    }
}