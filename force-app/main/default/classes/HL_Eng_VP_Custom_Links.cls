public class HL_Eng_VP_Custom_Links {
    Public String ReportLink1{get;set;}
    Public String ReportLink2{get;set;}
    Public String ReportLink3{get;set;}
    Public boolean isValidUser{get;set;}
    
    public HL_Eng_VP_Custom_Links(ApexPages.StandardController controller) {
        isValidUser = false;
        String RecordID = controller.getRecord().id;
        if(RecordID != null && RecordID.length() == 18) {
            RecordID = RecordID.subString(0,15);
        for(Report Rpt : [Select id,DeveloperName  from Report Where DeveloperName  = 'All_Positions_and_Team_Members_Eng' OR DeveloperName  = 'All_Positions_by_Team_Member_Eng' OR DeveloperName  = 'Valuation_Portfolio_Report_Fees_Eng']){
            if(Rpt.DeveloperName  == 'All_Positions_and_Team_Members_Eng')
                ReportLink1 = Rpt.Id+'?pv0='+RecordID ;
            if(Rpt.DeveloperName  == 'All_Positions_by_Team_Member_Eng')
                ReportLink2 = Rpt.Id+'?pv0='+RecordID ;
            if(Rpt.DeveloperName  == 'Valuation_Portfolio_Report_Fees_Eng')
                ReportLink3 = Rpt.Id+'?pv0='+RecordID;
        }
        isValidUser  = HL_OpportunityViewController.IsUserMemberofPVSuperVisorOrItschildGroup();
        if(!isValidUser)
        for(Profile prf : [SELECT Id,Name from Profile WHERE Name = 'System Administrator' OR Name = 'System Administrator (Read Only)'])       
            {       
                if(userinfo.getProfileId() == prf.id)     
                {       
                    isValidUser = true;        
                }
            }  
        }
    }

}