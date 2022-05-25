/*
2020-04-22 - Publicis Sapient - Created Class - Controller Class for TableauDashboardPage 
2020-07-23 - Publicis Sapient - Added logic to display My Dashboards picklist values in the dropdown
*/
public class TableauDashboardController {
    public List<SelectOption> dashboardOptions{get;set;}
    public String landingUrl{get;set;} 
    
    public TableauDashboardController() {
        // read the url parameter 'displayName' passed from the home page components and query for the dashboard to be displayed
        String displayName = Apexpages.currentPage().getParameters().get('displayName');
        List<HL_Report_Link__c> reportLinkList = [SELECT Id, Report_Link_URL__c, Report_Type__c 
                                                  FROM HL_Report_Link__c
                                                  WHERE Display_Name__c =: displayName
                                                  LIMIT 1];
        if(reportLinkList.size() > 0){
            landingUrl =  reportLinkList[0].Report_Link_URL__c;
            getDashboards();
        }
    }
    
    public List<SelectOption> getDashboards(){   
        /* update the  'Dashboard' picklist values that is accessible to the current logged in user 
           and filter the 'Dashboard' picklist based on the Report Type selected */
        String currentLoggedInUser = UserInfo.getUserId();
        List<String> reportLinkUrlSet = new List<String>();
        String selectClause = 'SELECT Id, HL_Report_Link__c, HL_Report_Link__r.Report_Link_URL__c, HL_Report_Link__r.Display_Name__c,'+
            +'Subscriber__c, Subscriber__r.Name, Subscriber__r.User__c'+ 
            + ' FROM HL_Subscription__c';
        String basicWhereClauseCondition = ' WHERE Subscriber__r.User__c = :currentLoggedInUser AND Active__c = TRUE AND Is_Tableau__c = TRUE  AND HL_Report_Link__r.Report_Type__c != \'My Dashboards\'';
        String orderByClause = ' ORDER BY Sort_Order__c';
        String query = selectClause + basicWhereClauseCondition + orderByClause;
        List<HL_Subscription__c> subscriptionList = Database.query(query);
        dashboardOptions = new List<SelectOption>();
        dashboardOptions.add(new SelectOption( '', '--None--'));
        for(HL_Subscription__c  subscription : subscriptionList)
        {
            if(subscription.HL_Report_Link__r.Report_Link_URL__c != null){
                reportLinkUrlSet.add(subscription.HL_Report_Link__r.Report_Link_URL__c);
                dashboardOptions.add(new SelectOption( subscription.HL_Report_Link__r.Report_Link_URL__c, subscription.HL_Report_Link__r.Display_Name__c));
            }
        }
        List<HL_Report_Link__c> reportLinkList = [SELECT Id, Name, Display_Name__c, Report_Link_URL__c
                                                  FROM HL_Report_Link__c
                                                  WHERE Report_Type__c = 'My Dashboards'
                                                  AND IsTableau__c = TRUE
                                                  ORDER BY Display_Name__c];
        for(HL_Report_Link__c reportLink : reportLinkList)
        {
            if(reportLink.Report_Link_URL__c != null){
                reportLinkUrlSet.add(reportLink.Report_Link_URL__c);
                dashboardOptions.add(new SelectOption(reportLink.Report_Link_URL__c, reportLink.Display_Name__c));
            }
        }
        dashboardOptions.sort();
        String displayName = Apexpages.currentPage().getParameters().get('displayName');
        if(displayName == null && reportLinkUrlSet.size() == 1){
            landingUrl = reportLinkUrlSet[0];
        }
        return dashboardOptions;
    }
}