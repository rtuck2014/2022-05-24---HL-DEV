@isTest
public class HL_EngagementTitleRateSheetHandlerTest {
    
    @isTest
    public static void testHL_EngagementTitleRateSheetHandler() {
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
        cntct.Title='Financial Analyst';
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
        
        insert engment;
        
        Title_Rate_Sheet__c trs = new Title_Rate_Sheet__c();
        trs.name = 'Test';
        insert trs;
        
        Time_Record_Period__c TRP = new Time_Record_Period__c();
        TRP.Start_Date__c  = system.today();
        TRP.End_Date__c = system.today();
        insert TRP;
        
        Time_Record_Period_Staff_Member__c TRPSM = new Time_Record_Period_Staff_Member__c();
        TRPSM.Time_Record_Period__c = TRP.Id;
        TRPSM.Contact__c  = cntct.Id;
        TRPSM.Office__c  = 'Office';
        TRPSM.Title__c ='Title';
        insert TRPSM;
        
        Id timeRecordLitigationRT = Schema.SObjectType.Time_Record__c.getRecordTypeInfosByName().get('Litigation').getRecordTypeId();
        
        Time_Record__c Trrc = new Time_Record__c();
        trrc.recordTypeId = timeRecordLitigationRT;
        trrc.Hourly_Rate__c = 100;
        trrc.Time_Record_Period_Staff_Member__c  = TRPSM.Id;
        trrc.Engagement__c  =engment.Id;
        trrc.Recording_Status__c = 'Complete';
        insert trrc;
        
        trrc.Hourly_Rate__c = 200;
		update trrc;
       // List<Engagement_Title_Rate_Sheet__c> englst = new List<Engagement_Title_Rate_Sheet__c> ();
        
        Engagement_Title_Rate_Sheet__c md = new Engagement_Title_Rate_Sheet__c();
        md.Engagement__c  = engMent.Id;
        md.Title_Rate_Sheet__c = trs.Id;
        md.End_Date__c  = system.today();
        insert md;
       // englst.add(md);
          // HL_EngagementTitleRateSheetHandler.onBeforeUpdate(englst);

        try{       
         Engagement_Title_Rate_Sheet__c md1 = new Engagement_Title_Rate_Sheet__c();
        md1.Engagement__c  = engMent.Id;
        md1.Title_Rate_Sheet__c = trs.Id;
        md1.End_Date__c  = system.today();
        insert md1;
        }catch(Exception E){
            
        }
    }
    
}