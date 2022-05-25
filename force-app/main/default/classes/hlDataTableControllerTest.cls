@isTest
public class hlDataTableControllerTest {
    public static string objName = 'Engagement_Client_Subject__c';
    public static string objNameOpp = 'Opportunity_Client_Subject__c';
    public static string pickValue = 'Subject';
    public static string whereClause = '';
    public static String field_set_name = 'EngagementClientFiedset';
    public static String field_set_name_Opp = 'OpportunityClientSubjectFieldSet';
    @isTest
    public static void testMethodForClientSub(){
        //Setup Test Data
        Engagement__c eng = SL_TestSetupUtils.CreateEngagement('',1)[0];
        insert eng;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
        //Test Public or Private Field Trigger Updates
        //Insert a Private Company ECS record
        Engagement_Client_Subject__c ecs1 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Client', Client_Subject__c = aList[0].Id, Loan_Amount__c = 0);
        Engagement_Client_Subject__c ecs2 = new Engagement_Client_Subject__c(Engagement__c = eng.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id, Loan_Amount__c = 0);
        List<Engagement_Client_Subject__c > OCSList = new List<Engagement_Client_Subject__c>();
        OCSList.add(ecs1);
        OCSList.add(ecs2); 
        insert OCSList;
        whereClause = 'Engagement__c = \''+ eng.Id+'\' LIMIT 1000';
        Test.startTest();
        hlDataTableController.DataTableResult dataTableResult = hlDataTableController.getRecordsToDisplayInTable(objName,field_set_name,whereClause,eng.Id);
        List<hlDataTableController.TableRow> tRow = hlDataTableController.updateRecordsToDisplayInTable(dataTableResult.tableRows,OCSList[0].Id,'type__c','Subject',false);
        hlDataTableController.saveRecordsToDisplayInTable(tRow,objName);
        hlDataTableController.getTotalAllocationValue(objName,field_set_name,whereClause,eng.Id);
        hlDataTableController.updatelookupToDisplayInTable(tRow,OCSList[0].Id,'Client_Subject__c',aList[1].Id);
        hlDataTableController.pickListValueDynamically(new Engagement_Client_Subject__c(),'type__c');
        Test.stopTest();
    }
    @isTest private static void testMethodForOppClientSub(){
        //Setup Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        //Create a Public Ownership and Private Ownership Account
        List<Account> aList = SL_TestSetupUtils.CreateAccount('', 2);
        aList[0].Ownership = 'Private Equity';
        aList[1].Ownership = 'Public Debt';
        insert aList;
        
        //Test Public or Private Field Trigger Updates
        //Insert a Private Company OCS record
        Opportunity_Client_Subject__c ocs1 = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id,type__c = 'Client', Client_Subject__c = aList[0].Id);
        Opportunity_Client_Subject__c ocs2 = new Opportunity_Client_Subject__c(Opportunity__c = opp.Id,type__c = 'Subject', Client_Subject__c = aList[1].Id);
        List<Opportunity_Client_Subject__c > OCSList = new List<Opportunity_Client_Subject__c >();
        OCSList.add(ocs1);
        OCSList.add(ocs2);        
        insert OCSList ;
        whereClause = 'Opportunity__c = \''+ opp.Id+'\' LIMIT 1000';
        Test.startTest();
        hlDataTableController.DataTableResult dataTableResult = hlDataTableController.getRecordsToDisplayInTable(objNameOpp,field_set_name_Opp,whereClause,opp.Id);
        List<hlDataTableController.TableRow> tRow = hlDataTableController.updateRecordsToDisplayInTable(dataTableResult.tableRows,OCSList[0].Id,'type__c','Subject',false);
        //hlDataTableController.saveRecordsToDisplayInTable(tRow,objName);
        hlDataTableController.getTotalAllocationValue(objNameOpp,field_set_name_Opp,whereClause,opp.Id);
        hlDataTableController.updatelookupToDisplayInTable(tRow,OCSList[0].Id,'Client_Subject__c',aList[1].Id);
        hlDataTableController.pickListValueDynamically(new Opportunity_Client_Subject__c(),'type__c');
        Test.stopTest();
    }
}