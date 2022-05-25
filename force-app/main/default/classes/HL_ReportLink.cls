public with sharing class HL_ReportLink {
    
    public static List<HL_Report_Link__c> GetByType(string reportType){
        return GetByType(null, reportType);
    }
    
    public static List<HL_Report_Link__c> GetByType(Id objId, string reportType){        
        return GetByType(objId,new List<string>{reportType});
    }
    
    public static List<HL_Report_Link__c> GetByType(Id objId, List<string> reportTypeList){
        List<HL_Report_Link__c> reportLinks = [SELECT Display_Name__c, Report_Description__c, Report_Link_URL__c, Report_Link_Ancillary_URL__c, Security_Assignment_Aggregate__c, Sort_Order__c,Report_Type__c FROM HL_Report_Link__c WHERE Report_Type__c IN : reportTypeList ORDER BY Report_Type__c ASC,Display_Name__c,Sort_Order__c];
        if(!String.isBlank(objId) && !HL_SecurityUtility.IsCAO() && !HL_SecurityUtility.IsSysAdmin())
            reportLinks = HandleTeamSharing(objId, reportLinks);
        //Always append the user's contact id to the link
        return AppendContactId(reportLinks);
    }
    
    
    //Team-shared links are shared with all and then filtered out here where appropriate
    private static List<HL_Report_Link__c> HandleTeamSharing(Id objId, List<HL_Report_Link__c> reportLinks)
    {
        List<HL_Report_Link__c> accessibleLinks = new List<HL_Report_Link__c>();
        string oType = HL_Utility.GetObjectTypeById(objId);
        boolean isOnTeam = oType == 'Opportunity__c' ? HL_OIT.IsActiveOnTeam(objId, UserInfo.getUserId()) : HL_EIT.IsActiveOnTeam(objId, UserInfo.getUserId());
        if(!isOnTeam)
        {
            for(Integer i = 0; i < reportLinks.size(); i++){
  				if(!reportLinks[i].Security_Assignment_Aggregate__c.contains('Team'))
                  	accessibleLinks.add(reportLinks[i]);
			}
        }
        else
            accessibleLinks = reportLinks.clone();
        return accessibleLinks;
    }

    //Appends the current user's contact id to the link
    private static List<HL_Report_Link__c> AppendContactId(List<HL_Report_Link__c> reportLinkList){
        //Query String Contact Id
        string qContactId = 'p_p_ContactId=' + HL_Contact.GetByUserId().Id;
        for(HL_Report_Link__c lnk : reportLinkList){
            if(!String.isBlank(lnk.Report_Link_URL__c)){
                if(String.isBlank(lnk.Report_Link_Ancillary_URL__c))
                    lnk.Report_Link_URL__c += (lnk.Report_Link_URL__c.contains('?') ? '&' : '?') + qContactId;
                else
                    lnk.Report_Link_Ancillary_URL__c += (lnk.Report_Link_Ancillary_URL__c.contains('?') ? '&' : '?') + qContactId; 
            }
        }
        return reportLinkList;
    }
}