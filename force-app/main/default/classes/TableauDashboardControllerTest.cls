@isTest
public class TableauDashboardControllerTest {
    
    @isTest
    static void testTableauDashboardController(){
        Id hlAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Houlihan Company').getRecordTypeId();
        Id hlContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'HL';
        acc.RecordTypeId = hlAccountRecordTypeId;
        insert acc;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName='ContactHL';
        contact.AccountId = acc.Id;
        contact.User__c = userInfo.getUserId();
        contact.recordTypeId = hlContactTypeId;
        insert contact;
        
        List<HL_Report_Link__c> reportLinkList = new List<HL_Report_Link__c>();
        HL_Report_Link__c hlReportLink = new HL_Report_Link__c();
        hlReportLink.Name = 'TableauDashboardView';
        hlReportLink.Display_Name__c = 'TableauDashboardView';
        hlReportLink.Report_Link_URL__c = 'https://tableau.hl.com/t/DEV/views/Dev-FVAStaffingAllocationReport/Dashboard1';
        hlReportLink.Thumbnail_Image_Url__c ='https://tableau.hl.com/vizportal/api/rest/v1/views/2496/thumbnail';
        hlReportLink.Sort_Order__c = 1;
        reportLinkList.add(hlReportLink);
        
        HL_Report_Link__c hlReportLink1 = new HL_Report_Link__c();
        hlReportLink1.Name = 'TableauMyDashboardView';
        hlReportLink1.Display_Name__c = 'TableauMyDashboardView';
        hlReportLink1.Report_Link_URL__c = 'https://tableau.hl.com/t/DEV/views/Dev-FVAStaffingAllocationReport/Dashboard1';
        hlReportLink1.Thumbnail_Image_Url__c ='https://tableau.hl.com/vizportal/api/rest/v1/views/2496/thumbnail';
        hlReportLink1.Sort_Order__c = 1;
        hlReportLink1.Home_Page_Access__c =true;
        hlReportLink1.Report_Type__c = 'My Dashboards';
        hlReportLink1.IsTableau__c =true;
        reportLinkList.add(hlReportLink1);
        
        insert reportLinkList;
        
        HL_Subscription__c subscription = new HL_Subscription__c();
        subscription.Active__c = true;
        subscription.Subscription_Type__c = 'Individual Subscriber';
        subscription.Home_Page_Access__c = true;
        subscription.Subscriber__c = contact.Id;
        subscription.HL_Report_Link__c = hlReportLink.Id;
        subscription.Is_Tableau__c = true;
        insert subscription;
        
        List<HL_Subscription__c> sub = [SELECT Id, Subscriber__c, Subscriber__r.User__c FROM HL_Subscription__c];
        Test.startTest();
        PageReference pageRef = Page.TableauDashboardPage; // Add your VF page Name here
        pageRef.getParameters().put('displayName', 'TableauDashboardView');
        Test.setCurrentPage(pageRef);
        TableauDashboardController controller = new TableauDashboardController();
        controller.getDashboards();
        TableauHomePageDashboardController.getDashboardList();
        TableauHomePageDashboardController.getMyDashboardList();
        Test.stopTest();
    }
}