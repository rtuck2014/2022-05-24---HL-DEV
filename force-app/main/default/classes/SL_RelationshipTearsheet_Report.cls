public with sharing class SL_RelationshipTearsheet_Report 
{    
    public Contact contactRecord                        {get;set;} 
    public Decimal totalReferralFees                    {get;set;}
    public Boolean isReferral                           {get;set;}
    public String companyDescription                    {get;set;}          
    public String contactDescription                    {get;set;}
    public String totalReferralFeesSymbol               {get;set;}
    private Map<Id, String> validCampaignMap;
    private List<DealsShownWrapper> dealsShownList;
    
    public SL_RelationshipTearsheet_Report()
    {
        Initialize();
        GetReportData();
    }
    
    public SL_RelationshipTearsheet_Report(ApexPages.StandardController con){
        this();
    }    
    
    private void Initialize()  
    {
        contactRecord = new Contact();
        totalReferralFees = 0;
    }
    
    public void GetReportData()
    {
        String contactId = ApexPages.currentPage().getParameters().get('Id');
        
        List<Contact> contactList = [SELECT Name, 
                                     Title, Phone, 
                                     Email, MobilePhone, 
                                     AssistantName, AssistantPhone, 
                                     MailingStreet, MailingState, 
                                     MailingPostalCode, MailingCountry, 
                                     MailingCity, Account.Name, 
                                     Account.Description, Account.Revenue_MM__c, 
                                     Account.EBITDA_MM__c, Account.Total_Debt_MM__c, 
                                     Account.Total_Debt_EBITDA__c, AccountId,
                                     Description
                                     FROM Contact
                                     WHERE Id =:contactId];
        
        if(!contactList.isEmpty())
        {
            contactRecord = contactList[0];
            companyDescription = (contactRecord.Account.Description != null && contactRecord.Account.Description.length() > 445)
                ? contactRecord.Account.Description.substring(0, 440) + '....'
                : contactRecord.Account.Description;
            contactDescription =  (contactRecord.Description != null && contactRecord.Description.length() > 355)
                ? contactRecord.Description.substring(0, 350) + '....'
                : contactRecord.Description!= null ? contactRecord.Description : '';
        }                               
    }
    
    
    public String GetCoverageOfficer(){
        String accountId = contactRecord.AccountId;
        List<Account> coverageTeam = [SELECT Primary_Coverage_Officer__r.Name FROM Account WHERE Id =: accountId LIMIT 1];
        return coverageTeam.isEmpty() ? '' : coverageTeam[0].Primary_Coverage_Officer__r.Name;
    }
    
    public List<Relationship__c> GetMostActiveHLRelationship()
    {
        List<Relationship__c> relationshipList = [SELECT 
                                                  HL_Contact__r.Title, 
                                                  HL_Contact__r.Name,  
                                                  Strength_Rating__c, 
                                                  Number_of_Activities_LTM__c, 
                                                  Last_Activity_Date__c 
                                                  FROM Relationship__c  
                                                  WHERE External_Contact__c =: contactRecord.Id 
                                                  AND HL_Contact__r.Status__c = 'Active'
                                                  ORDER BY Number_of_Activities_LTM__c DESC, HL_Contact__r.Name];
        
        if(relationshipList.size() > 0 && contactRecord.Id != null)
            return relationshipList;
        else 
            return new List<Relationship__c>();
    }
    
    public class ActivityWrapper implements Comparable
    {   
        public Date dtDlDate                        {   get;set;    }
        public String strSub                        {   get;set;    }
        public String strWhoName                    {   get;set;    }
        public String strWhoTitle                   {   get;set;    }
        public String strWhoId                      {   get;set;    }
        
        public ActivityWrapper(Date dtDlDate, String strSub, String strWhoName, String strWhoTitle, String strWhoId)
        {
            this.dtDlDate = dtDlDate;
            this.strSub = strSub;
            this.strWhoName = strWhoName;
            this.strWhoTitle = strWhoTitle;
            this.strWhoId = strWhoId;
        }
        
        public Integer CompareTo(Object compareTo) {
            
            ActivityWrapper compareToActivity= (ActivityWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (dtDlDate > compareToActivity.dtDlDate) 
                returnValue = 1;
            else if (dtDlDate < compareToActivity.dtDlDate) 
                returnValue = -1;
            
            return returnValue;       
        }
        
    }
    
    public class EngagmentHistoryWrapper
    {
        public Date strEnggCloseDate                {   get;set;    } 
        public String strEnggName                   {   get;set;    }
        public String strEnggNumber                 {   get;set;    }
        public String strClientName                 {   get;set;    }
        public String strSubjectName                {   get;set;    }
        public String strEnggJobType                {   get;set;    }
        public String strEnggBusinessUnit           {   get;set;    }
        public String strEnggStatus                 {   get;set;    } 
        public String strHLTeammember               {   get;set;    }
        public Boolean isActive                     {   get;set;    }
        
        public EngagmentHistoryWrapper(Date strEnggCloseDate, String strEnggName, String strEnggNumber, String strClientName, String strSubjectName, String strEnggJobType, String strEnggBusinessUnit, 
                                       String strEnggStatus, String strHLTeammember,Boolean isActive)
        {
            this.strEnggCloseDate = strEnggCloseDate;
            this.strEnggName = strEnggName;
            this.strEnggNumber = strEnggNumber;
            this.strClientName = strClientName;
            this.strSubjectName = strSubjectName;
            this.strEnggJobType = strEnggJobType;
            this.strEnggBusinessUnit = strEnggBusinessUnit;
            this.strEnggStatus = strEnggStatus;
            this.strHLTeammember = strHLTeammember;
            this.isActive = isActive;
        }
    }
    
    public class ReferralFeesHistory
    {
        public Engagement__c engagementRecord      {   get;set;    }
        public String strHLTeammember           {   get;set;    }
        
        public ReferralFeesHistory(Engagement__c engagementRecord, String strHLTeammember)
        {
            this.engagementRecord = engagementRecord;
            this.strHLTeammember = strHLTeammember;
        }
    }
    
    public class OpenOpportunityWrapper
    {
        public Opportunity__c opportunityRecord        {   get;set;    }
        public String strHLTeamMember               {   get;set;    }
        
        public OpenOpportunityWrapper(Opportunity__c opportunityRecord, String strHLTeamMember)
        {
            this.opportunityRecord = opportunityRecord;
            this.strHLTeamMember = strHLTeamMember;
        }
    }
    
    public class ConferenceAttendanceWrapper
    {
        public Date dtStartDate                     {   get;set;    }
        public String strCampaignName               {   get;set;    }
        public String strCampaignMemberStatus       {   get;set;    }
        
        public ConferenceAttendanceWrapper(Date dtStartDate, String strCampaignName, String strCampaignMemberStatus)
        {
            this.dtStartDate = dtStartDate;
            this.strCampaignName = strCampaignName;
            this.strCampaignMemberStatus = strCampaignMemberStatus;
        }
    }
    
    public class DealsShownWrapper
    {
        public Engagement__c egmt                   {   get;set;   }
        public Engagement_Counterparty__c egmtCP    {   get;set;   }
        public String strPrincipals                 {   get;set;   }
        
        public DealsShownWrapper(Engagement__c egmt, Engagement_Counterparty__c egmtCP, String strPrincipals){
            this.egmt = egmt;
            this.egmtCP = egmtCP;
            this.strPrincipals = strPrincipals;
        }
    }
    
    
    public List<ActivityWrapper> GetMostRecentActivities() 
    {
        List<ActivityWrapper> activityWrapperList = new List<ActivityWrapper>();
        
        if(contactRecord.Id != null){
            for (Event e : [SELECT ActivityDate,
                            Subject,
                            WhoId,
                            Private__c,
                            Contact_Name__c,
                            PRIMARY_ATTENDEE__C,
                            Contact__r.Title,
                            ParentId__c,
                            Primary_Attendee_Id__c
                            FROM   Event
                            WHERE  WhoId =: contactRecord.Id
                            AND ParentId__c <> null
                            AND IsDeleted = false
                            ORDER BY ActivityDate DESC, StartDateTime DESC
                            LIMIT 10
                            ALL ROWS])
            {
                string title = '';
                string name = '';
                List<Contact> primaryAttendeeTitle = [SELECT Name, Title FROM Contact WHERE ID =: e.Primary_Attendee_Id__c];
                
                if (primaryAttendeeTitle.size() > 0) {
                    name = primaryAttendeeTitle[0].Name;
                    title = primaryAttendeeTitle[0].Title;
				}

                activityWrapperList.add(new ActivityWrapper(e.ActivityDate, 
                                                            UserInfo.getUserId() != e.Primary_Attendee_Id__c && e.Private__c ? 'Private' : e.Subject, 
                                                            name, 
                                                            title, 
                                                            e.ParentId__c));
            }
        }
        
        return activityWrapperList;  
    }
    
    public List<EngagmentHistoryWrapper> GetEngagementHistory()
    {
        Date fiveYearDate = Date.today().addYears(-5); 
        List<Engagement__c> engagementList = new List<Engagement__c>(); 
        List<EngagmentHistoryWrapper> engagementHistoryWrapperList = new List<EngagmentHistoryWrapper>();
        Set<Id> engagementIdSet = new Set<Id>();
        
        for(Engagement__c engagementRecord : [SELECT Status__c, 
                                              Name, 
                                              Engagement_Number__c,
                                              Latest_Stage_Change__c, 
                                              Client__r.Name,
                                              Subject__r.Name,
                                              Job_Type__c, 
                                              Line_of_Business__c, 
                                              RecordTypeId,
                                              Active__c, 
                                              (SELECT Id,  
                                               Contact__r.Name
                                               FROM Engagement_Teams__r
                                               WHERE Role__c='Principal'
                                               AND (Start_Date__c <= TODAY OR Start_Date__c=null)
                                               AND (End_Date__c >= TODAY OR End_Date__c=null)
                                               ORDER BY CreatedDate DESC LIMIT 1)
                                              FROM Engagement__c 
                                              WHERE (Client__c =: contactRecord.AccountId
                                                     OR Subject__c =: contactRecord.AccountId)
                                              AND ((Latest_Stage_Change__c != NULL AND Latest_Stage_Change__c >=: fiveYearDate) OR Active__c = true)
                                              ORDER BY Latest_Stage_Change__c DESC
                                              LIMIT 10])
        {
            engagementHistoryWrapperList.add(new EngagmentHistoryWrapper(engagementRecord.Latest_Stage_Change__c,
                                                                         engagementRecord.Name, 
                                                                         engagementRecord.Engagement_Number__c,
                                                                         engagementRecord.Client__r.Name,
                                                                         engagementRecord.Subject__r.Name,
                                                                         engagementRecord.Job_Type__c,
                                                                         engagementRecord.Line_of_Business__c, 
                                                                         engagementRecord.Status__c,
                                                                         (engagementRecord.Engagement_Teams__r.size() > 0) 
                                                                         ? engagementRecord.Engagement_Teams__r[0].Contact__r.Name : '',
                                                                         engagementRecord.Active__c));
        }
        
        if(engagementHistoryWrapperList.size() > 0 && contactRecord.Id != null)    
            return engagementHistoryWrapperList;
        else
            return new List<EngagmentHistoryWrapper>();
    }
    
    private Map<Id, String> GetValidCampaignMap(){
        if (validCampaignMap != null)
            return validCampaignMap;
        
        Map<Id, String> validCampaignMap = new Map<Id, String>();
        
        for(CampaignMember objCM : [SELECT CampaignId, 
                                    Status 
                                    FROM CampaignMember 
                                    WHERE ContactId =: contactRecord.Id 
                                    AND CampaignId != null])
            validCampaignMap.put(objCM.CampaignId, objCM.Status);
        
        return validCampaignMap;
    }
    
    public List<ConferenceAttendanceWrapper> GetConferenceAttendance()
    {
        List<ConferenceAttendanceWrapper> conferenceAttendanceWrapperList = new List<ConferenceAttendanceWrapper>();
        Map<Id, String> campaignIdToMemberStatusMap = GetValidCampaignMap();
        
        //Getting all the campaign where start date is in past 
        for(Campaign campaignRecord : [SELECT Id, 
                                       StartDate, 
                                       Name 
                                       FROM Campaign 
                                       WHERE Id IN : campaignIdToMemberStatusMap.keySet() 
                                       AND Type IN ('Conference', 'Event', 'Seminar / Conference')
                                       AND StartDate <: Date.today()
                                       ORDER BY StartDate DESC LIMIT 5])
        {
            conferenceAttendanceWrapperList.add(new ConferenceAttendanceWrapper(campaignRecord.StartDate, campaignRecord.Name, 
                                                                                campaignIdToMemberStatusMap.get(campaignRecord.Id) != null 
                                                                                ? campaignIdToMemberStatusMap.get(campaignRecord.Id) : ''));
        }
        
        //Getting all the campaign where start date is in future
        for(Campaign campaignRecord : [SELECT Id, 
                                       StartDate, 
                                       Name 
                                       FROM Campaign 
                                       WHERE StartDate >=: Date.today()
                                       ORDER BY StartDate DESC])
        {
            conferenceAttendanceWrapperList.add(new ConferenceAttendanceWrapper(campaignRecord.StartDate, campaignRecord.Name, 
                                                                                (campaignIdToMemberStatusMap.containsKey(campaignRecord.Id) 
                                                                                 && campaignIdToMemberStatusMap.get(campaignRecord.Id) != null)
                                                                                ? campaignIdToMemberStatusMap.get(campaignRecord.Id) : ''));
        }
        
        if(!conferenceAttendanceWrapperList.isEmpty() && contactRecord.Id != null)
            return conferenceAttendanceWrapperList;
        else
            return new List<ConferenceAttendanceWrapper>();
    }
    
    public Integer GetNoMailingsLTM()
    {
        Map<Id, String> campaignIdToMemberStatusMap = GetValidCampaignMap();
        Date dateTMA = Date.today().addMonths(-12);
        Integer sum = 0;
        for(AggregateResult ar : [ SELECT Count (Id) total 
                                  FROM Campaign 
                                  WHERE Id IN : campaignIdToMemberStatusMap.keySet() 
                                  AND Type IN ('Newsletter', 'Whitepaper', 'Holiday Card', 'Year End Brochure')
                                  AND Launch_Date__c >: dateTMA
                                  AND Launch_Date__c < TODAY
                                 ]){
                                     sum+= (Integer) ar.get('total');
                                 }
        return sum;
    }
    
    public List<ReferralFeesHistory> GetReferralFeesHistory()
    {
        list<ReferralFeesHistory> referralFeeHistoryList = new list<ReferralFeesHistory>();
        totalReferralFees = 0;
        
        for(Engagement__c engagementRecord : [SELECT Status__c, 
                                              Job_Type__c, 
                                              Subject__r.Name, 
                                              Stage__c, 
                                              Name, 
                                              Close_Date__c, 
                                              Total_Estimated_Fee__c, 
                                              Transaction_Type__c, 
                                              Start_Date__c, 
                                              RecordType.Name, 
                                              RecordTypeId, 
                                              (SELECT Id,  
                                               Contact__r.Name
                                               FROM Engagement_Teams__r
                                               WHERE Role__c='Principal'
                                               AND (Start_Date__c <= TODAY OR Start_Date__c=null)
                                               AND (End_Date__c >= TODAY OR End_Date__c=null)
                                               ORDER BY CreatedDate DESC LIMIT 1)
                                              FROM Engagement__c 
                                              WHERE Referral_Contact__c =: contactRecord.Id 
                                              ORDER BY Start_Date__c DESC])
        {
            referralFeeHistoryList.add(new ReferralFeesHistory(engagementRecord, 
                                                               (engagementRecord.Engagement_Teams__r.size() > 0) 
                                                               ? engagementRecord.Engagement_Teams__r[0].Contact__r.Name : ''));
        }
        
        for(Engagement__c engagementRecord : [SELECT Id,
                                              ConvertCurrency(Total_Estimated_Fee__c)
                                              FROM Engagement__c
                                              WHERE Referral_Contact__c =: contactRecord.Id])
        {
            totalReferralFees += engagementRecord.Total_Estimated_Fee__c == null ? 0 : engagementRecord.Total_Estimated_Fee__c;
        }                                            
        totalReferralFeesSymbol = UserInfo.getDefaultCurrency();
        
        if(!referralFeeHistoryList.isEmpty() && contactRecord.Id != null)
            return referralFeeHistoryList;
        else
            return new List<ReferralFeesHistory>();
    }
    
    public List<DealsShownWrapper> GetDealsShown()
    {
        if (dealsShownList!=null)
            return dealsShownList;
        
        Date fiveYearDate = Date.today().addYears(-5);
        
        dealsShownList = new List<DealsShownWrapper>();
        
        for (Engagement__c egmt: [SELECT Start_Date__c,
                                  Date_Engaged__c,
                                  Name,
                                  Client__r.Name,
                                  Subject__r.Name,
                                  Job_Type__c,
                                  (SELECT 
                                   Role__c,
                                   Status__c,  
                                   Company__r.Name
                                   FROM Engagement_Counterparties__r
                                   WHERE Company__c =: contactRecord.AccountId
                                   LIMIT 1
                                  ),
                                  (SELECT 
                                   Contact__r.Name
                                   FROM Engagement_Teams__r
                                   WHERE Role__c='Principal'
                                  )
                                  FROM Engagement__c
                                  WHERE Id IN (SELECT Engagement__c FROM Engagement_Counterparty__c WHERE Company__c =: contactRecord.AccountId) 
                                  AND
                                  (Close_date__c >: fiveYearDate 
                                   OR  Close_date__c = null
                                  )
                                  ORDER BY Engagement__r.Close_date__c DESC NULLS FIRST
                                  LIMIT 10]){
                                      List<String> principalNames = new List <String>();
                                      for (Engagement_Internal_Team__c eit: egmt.Engagement_Teams__r){
                                          principalNames.add(eit.Contact__r.Name);
                                      }
                                      String principals = principalNames.isEmpty() ? '' : String.join(principalNames, ', ');
                                      dealsShownList.add(new DealsShownWrapper(egmt, egmt.Engagement_Counterparties__r[0], principals));
                                  }
        
        if(!dealsShownList.isEmpty() && contactRecord.Id != null)
            return dealsShownList;
        else
            return new List<DealsShownWrapper>();
    }
    
    public Integer GetNumDealsShown()
    {
        return GetDealsShown().size();
    }
    
    public List<OpenOpportunityWrapper> GetOpenOpportunities()
    {
        String contactId = ApexPages.currentPage().getParameters().get('Id');
        List<OpenOpportunityWrapper> openOpportunityWrapperList = new List<OpenOpportunityWrapper>();
        
        if(!String.isEmpty(contactId))
            isReferral = [SELECT Id 
                          FROM Opportunity__c 
                          WHERE referral_contact__c =: contactId LIMIT 1].size()>0 ? true : false;  
        for(Opportunity__c opportunityRecord  : [SELECT Stage__c, 
                                                 Client__r.Name, 
                                                 Client__c, 
                                                 Subject__r.Name,
                                                 Estimated_Fee__c, 
                                                 Job_Type__c, 
                                                 Estimated_Engagement_Date__c,
                                                 (SELECT Id,  
                                                  Contact__r.Name
                                                  FROM Opportunity_Internal_Teams__r
                                                  WHERE Role__c='Principal'
                                                  AND (Start_Date__c <= TODAY OR Start_Date__c=null)
                                                  AND (End_Date__c >= TODAY OR End_Date__c=null)
                                                  ORDER BY CreatedDate DESC LIMIT 1)
                                                 FROM Opportunity__c 
                                                 WHERE Stage__c NOT IN ('Dead','Lost','Dead / Lost','Closed / Won / Engaged','Closed','Engaged')
                                                 AND (Client__c =: contactRecord.AccountId
                                                      OR Subject__c =: contactRecord.AccountId)
                                                 ORDER BY Estimated_Engagement_Date__c DESC
                                                 LIMIT 10]){
                                                     openOpportunityWrapperList.add(new OpenOpportunityWrapper(opportunityRecord,
                                                                                                               (opportunityRecord.Opportunity_Internal_Teams__r.size() > 0) 
                                                                                                               ? opportunityRecord.Opportunity_Internal_Teams__r[0].Contact__r.Name : '')); 
                                                 }
        if(!openOpportunityWrapperList.isEmpty() && contactRecord.Id != null)
            return openOpportunityWrapperList ;
        else
            return new List<OpenOpportunityWrapper>();
    }
    
    public List<String> GetCareerInformation()
    {
        return GetCareerBoardInformation('Career');
    }
    
    public List<String> GetBoardInformation()
    {
        return GetCareerBoardInformation('Board');
    }
    
    public List<String> GetCareerBoardInformation(String affiliationType)
    {
        List<String> careerBoardInformationList = new List<String>();
        
        if(affiliationType == 'Career')
        {
            careerBoardInformationList.add(contactRecord.Account.Name);
            
            for(Affiliation__c objAff : [SELECT Account__r.Name, 
                                         Contact__c, End_Date__c 
                                         FROM Affiliation__c 
                                         WHERE Contact__c =: contactRecord.Id 
                                         AND Status__c IN('Former') 
                                         ORDER BY Account__r.Name LIMIT 4])
                careerBoardInformationList.add(objAff.Account__r.Name);
        }   
        
        if(affiliationType == 'Board')
        {
            String affiliationClause = '%Board Member%';
            
            for(Affiliation__c objAff : [SELECT Account__r.Name, 
                                         CreatedDate, Contact__c, End_Date__c 
                                         FROM Affiliation__c 
                                         WHERE Contact__c =: contactRecord.Id 
                                         AND Type__c LIKE: affiliationClause
                                         ORDER BY Status__c, Account__r.Name LIMIT 5])
            {
                careerBoardInformationList.add(objAff.Account__r.Name);
            }
        }
        
        return careerBoardInformationList;
    }
}