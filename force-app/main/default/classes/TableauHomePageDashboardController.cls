/*
2020-04-22 - Publicis Sapient - Created Class - Controller Class for hlHomePageDashboard lightning web component 
2020-07-23 - Publicis Sapient - Added getMyDashboardList method to display 'My Dashboards' on home page - controller class for hlHomePageMyDashboards lwc
*/
public class TableauHomePageDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<DashboardWrapper> getDashboardList() {
        //get the current logged in user and query the thumbnail images to be displayed on the home page
        List<DashboardWrapper> dashboardWrapperList = new List<DashboardWrapper>();
        String currentLoggedInUser = UserInfo.getUserId();
        List<HL_Subscription__c> subscriptionList = [SELECT Id, HL_Report_Link__c, HL_Report_Link__r.Report_Link_URL__c, HL_Report_Link__r.Display_Name__c,
                                                     HL_Report_Link__r.Thumbnail_Image_Url__c, Subscriber__c, Subscriber__r.Name, Subscriber__r.User__c
                                                     FROM HL_Subscription__c
                                                     WHERE Subscriber__r.User__c = :currentLoggedInUser 
                                                     AND Active__c = TRUE
                                                     AND Is_Tableau__c = TRUE
                                                     AND Home_Page_Access__c = TRUE
                                                     AND HL_Report_Link__r.Report_Type__c != 'My Dashboards'
                                                     ORDER BY Sort_Order__c NULLS LAST];
        String tabId = getTabId();
        for(HL_Subscription__c subscription : subscriptionList){
            if(subscription.HL_Report_Link__r.Report_Link_URL__c != null){
                DashboardWrapper dashWrapper = new DashboardWrapper();
                dashWrapper.name = subscription.HL_Report_Link__r.Display_Name__c;
                dashWrapper.imageUrl = subscription.HL_Report_Link__r.Thumbnail_Image_Url__c;
                dashWrapper.url = subscription.HL_Report_Link__r.Report_Link_URL__c;
                dashboardWrapperList.add(dashWrapper);
            }
        }
        return dashboardWrapperList;
    }
    
    @auraEnabled(cacheable=true)
    public static List<DashboardWrapper> getMyDashboardList() {
        List<DashboardWrapper> dashboardWrapperList = new List<DashboardWrapper>();
        List<HL_Report_Link__c> hlReportLinkList = [SELECT Id, Report_Link_URL__c, Display_Name__c, Thumbnail_Image_Url__c, Report_Type__c
                                                    FROM HL_Report_Link__c
                                                    WHERE Report_Type__c = 'My Dashboards'
                                                    AND Home_Page_Access__c  = TRUE
                                                    AND IsTableau__c = TRUE];
        String tabId = getTabId();
        for(HL_Report_Link__c reportLink : hlReportLinkList){
            if(reportLink.Report_Link_URL__c != null){
                DashboardWrapper dashWrapper = new DashboardWrapper();
                dashWrapper.name = reportLink.Display_Name__c;
                dashWrapper.imageUrl = reportLink.Thumbnail_Image_Url__c;
                dashWrapper.url = reportLink.Report_Link_URL__c;
                dashWrapper.tabId = tabId;
                dashboardWrapperList.add(dashWrapper);
            }
        }
        return dashboardWrapperList;
    }
    
    public static String getTabId(){
        String tabId = '';
        List<TabDefinition> tabDefinitionList = [SELECT Id, Name, MobileUrl FROM TabDefinition WHERE Name = 'Tableau_Reports' LIMIT 1];
        system.debug('tabDefinitionList>>>'+tabDefinitionList);
        if(!tabDefinitionList.isEmpty()){
            tabId = tabDefinitionList[0].MobileUrl.substringAfter('sfdc.tabName=').left(15);
            system.debug('tabId>>>'+tabId);
        }
        return tabId;
    }
    
    public class DashboardWrapper{
        @auraEnabled
        public String name {get;set;}
        @auraEnabled
        public String imageUrl {get;set;}
        @auraEnabled 
        public String url {get;set;}
        @auraEnabled 
        public String tabId {get;set;}
    }
}