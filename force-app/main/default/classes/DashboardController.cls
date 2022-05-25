public class DashboardController {
    public String landingUrl{get;set;} 
    public List<SelectOption> dashboardOptions{get;set;}
    public String displayName {get;set;}
    public String reportTypeName {get;set;}
    public Map<String,String> urlDisplayNameMap{get;set;}
    
    public DashboardController(){
        getDashboards();
    }
    
    public List<SelectOption> getDashboards(){
        List<String> reportLinkUrlSet = new List<String>();
        String selectClause = 'SELECT Id, Report_Link_URL__c, Display_Name__c, Security_Assignment__c FROM HL_Report_Link__c';
        String basicWhereClauseCondition = ' WHERE IsTableau__c = TRUE  AND Report_Type__c = \''+ reportTypeName +'\'';
        String orderByClause = ' ORDER BY Sort_Order__c';
        String query = selectClause + basicWhereClauseCondition  + orderByClause;
        List<HL_Report_Link__c> reportLinkList = Database.query(query);
        urlDisplayNameMap = new Map<String,String>();
        
        List<String> allGroupNames = new List<String>();
        for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where (UserOrGroupId = :UserInfo.getUserId() AND group.type='Regular')]){
            allGroupNames.add(gm.group.name);
        }
        
        dashboardOptions = new List<SelectOption>();
        dashboardOptions.add(new SelectOption( '', '--None--'));
        
        for(HL_Report_Link__c  reportLink : reportLinkList)
        {  
            List<String> secAssign = new List<string>();
            
            if(reportLink.Security_Assignment__c != null){
                secAssign = reportLink.Security_Assignment__c.split(';');
                for(String str : allGroupNames){
                    for(String str1 : secAssign){          
                        if(reportLink.Report_Link_URL__c != null && str.contains(str1) ){
                            reportLinkUrlSet.add(reportLink.Report_Link_URL__c);
                            dashboardOptions.add(new SelectOption(reportLink.Report_Link_URL__c, reportLink.Display_Name__c)); 
                            urlDisplayNameMap.put(reportLink.Report_Link_URL__c, reportLink.Display_Name__c);
                        }
                    }
                }
            }
            else {          
                if(reportLink.Report_Link_URL__c != null && reportLink.Security_Assignment__c == null ){
                    reportLinkUrlSet.add(reportLink.Report_Link_URL__c);
                    dashboardOptions.add(new SelectOption(reportLink.Report_Link_URL__c, reportLink.Display_Name__c));
                    urlDisplayNameMap.put(reportLink.Report_Link_URL__c, reportLink.Display_Name__c);
                }
            }
        }
        if(reportLinkUrlSet.size() == 1){
            landingUrl = reportLinkUrlSet[0];
            displayName = urlDisplayNameMap.get(reportLinkUrlSet[0]);
        }
        return dashboardOptions;
    }
    
    public pageReference getDisplayName(){
        String url  = apexpages.currentPage().getParameters().get('baseUrl');
        if(url != null){
            displayName = urlDisplayNameMap.get(url);
        }
        return null; 
    }
}