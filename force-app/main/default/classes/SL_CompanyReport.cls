/**
* \arg ClassName      : SL_CompanyReport
* \arg JIRATicket     : HL-25
* \arg CreatedOn      : 18/Aug/2014
* \arg LastModifiedOn : 3/Dec/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Controller class for SL_CompanyReport page.
*/
public with sharing class SL_CompanyReport 
{
    /*Start - Variables*/
    public String strCompanyDesc        {   get;set;    }//to store the truncated company description.
    private Set<Id> setAccountId;//set of related company ids.  
    public String totalFeeCurrencySymbol{   get;set;    } 
    public String strRecordType			{	get;set;	}
    public string strDealsShownTag		{	get;set;	}
    public string strTotalDealsShown	{	get;set;	}
    public string DealsShownStyle		{	get;set;	}
    public static final integer MaxDealsShownDisplay = 20;
    /*End - Variables*/
    
    /*Start - Constructor*/
    public SL_CompanyReport()
    {
        setAccountId = getAccountIds(ApexPages.currentPage().getParameters().get('Id'));//Set of related Company id
        totalFeeCurrencySymbol = UserInfo.getDefaultCurrency();
    }
    public SL_CompanyReport(ApexPages.StandardController controller){
        this();
    }
    /*End - Constructor*/
    
    
    /* Start - Wrapper class for contact wrapper */
    public class ContactWrapper implements Comparable
    {
        public String strName           {   get;set;    }// Variable used for contact name.
        public String strTitle          {   get;set;    }// Variable used for contact title.
        public String strLastActivity   {   get;set;    }// Variable used for latest activity date of the contact
        public Integer intTotalActivity {   get;set;    }// Variable used for getting total no of activity on contact
        public DateTime dtLastActivity  {   get;set;    }// Variable used for getting subject of latest activity.
        
        public ContactWrapper(String strName, String strTitle, String strLastActivity, Integer intTotalActivity, DateTime dtLastActivity)
        {
            this.strName = strName;
            this.strTitle = strTitle;
            this.strLastActivity = strLastActivity;
            this.intTotalActivity = intTotalActivity;
            this.dtLastActivity = dtLastActivity;
        }

        public Integer compareTo(Object compareTo) {
            // Cast argument to Contact Wrapper
            ContactWrapper compareToContact= (ContactWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (intTotalActivity < compareToContact.intTotalActivity) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (intTotalActivity > compareToContact.intTotalActivity) {
                // Set return value to a negative value.
                returnValue = -1;
            }
        
        return returnValue;       
        }
        
    }
    /* End - Wrapper class for contact wrapper */
    
    /*Start - Wrapper class for recent activity of company*/
    public class RecentActivityWrapper implements Comparable
    {
        public DateTime dtActivityDate          {   get;set;    }// Variable used for getting recent activity date of company
        public String strActivity               {   get;set;    }// Variable used for getting recent activity subject
        public String strHlEmployee             {   get;set;    }// Variable used for getting name of activity owner
        public String strTitle                  {   get;set;    }// Variable used for getting title of activity owner
        public String strExternalContact        {   get;set;    }// Variable used for getting name of activity external contact

        public RecentActivityWrapper(DateTime dtActivityDate, String strActivity, String strHlEmployee, String strTitle, String strExternalContact)
        {
            this.dtActivityDate = dtActivityDate;
            this.strActivity = strActivity;
            this.strHlEmployee = strHlEmployee;
            this.strTitle = strTitle;
            this.strExternalContact=strExternalContact;
        }
        public Integer compareTo(Object compareTo) {
            // Cast argument to RecentActivityWrapper
            RecentActivityWrapper compareToActivity= (RecentActivityWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (dtActivityDate < compareToActivity.dtActivityDate) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (dtActivityDate > compareToActivity.dtActivityDate) {
                // Set return value to a negative value.
                returnValue = -1;
            }
        
        return returnValue;       
        }
    }
    /*End - Wrapper class for recent activity of company*/
    
    /* Start - Wrapper class for Opportunity wrapper */
    public class OpportunityWrapper
    {   
        public Opportunity__c objOpportunity    {   get;set;    }
        public String strPrincipal              {   get;set;    }// Variable used for getting Opportunity internal team name  
        
        public OpportunityWrapper(Opportunity__c objOpportunity, String strPrincipal)
        {
            this.objOpportunity = objOpportunity;
            this.strPrincipal = strPrincipal;
        }
                
    }
    /*End - Wrapper class for Opportunity wrapper*/
    
    /* Start - Wrapper class for hl transaction wrapper */
    public class HlTransactionWrapper
    {
        public Engagement__c objEngagement          {   get;set;    }//To store engagement details
        public String strTransPrincipal             {   get;set;    }//To store the contact name related to engagement internal teams 

        public HlTransactionWrapper(Engagement__c objEngagement, String strTransPrincipal)
        {
            this.objEngagement = objEngagement;
            this.strTransPrincipal = strTransPrincipal;
        }
    }
    /* End - Wrapper class for deal wrapper*/
    
    /* Start - Wrapper class for hl transaction wrapper */
    public class DealWrapper
    {   
        public Date dtDlDate                        {   get;set;    }// Variable used for getting Engagement start date.
        public String strDlProjectName              {   get;set;    }// Variable used for getting Engagement name
        public String strDlProjectClient            {   get;set;    }// Variable used for getting Engagement client
        public String strDlProjectSubject           {   get;set;    }// Variable used for getting Engagement subject
        public String strDlCompanyName              {   get;set;    }// Variable used for getting Company name
        public String strDlTransType                {   get;set;    }// Variable used for getting Engagement transaction type.
        public String strDlCompanyContact           {   get;set;    }// Variable used for getting Engagement_counterparty_contact name
        public String strDlStatus                   {   get;set;    }// Variable used for getting Engagement status 
        
        public DealWrapper(Date dtDlDate, String strDlProjectName, String strDlProjectClient, String strDlProjectSubject, String strDlCompanyName, String strDlTransType, String strDlCompanyContact, String strDlStatus)
        {
            this.dtDlDate = dtDlDate;
            this.strDlProjectName = strDlProjectName;
            this.strDlProjectClient = strDlProjectClient;
            this.strDlProjectSubject = strDlProjectSubject;
            this.strDlCompanyName = strDlCompanyName;
            this.strDlTransType = strDlTransType;
            this.strDlCompanyContact = strDlCompanyContact;
            this.strDlStatus = strDlStatus;
        }
                
    }
    /*End - Wrapper class for hl transaction wrapper*/
    
    /*
        @MethodName : getCompany 
        @param      : NA
        @Description: method for getting company data. 
    */
    public Account getCompany()
    {
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
        
        if(!String.isBlank(strAccountId))
        {
            // getting the company data
            List<Account> lstAccount = [SELECT Id,
                                               Name,
                                               Phone,
                                               Website,
                                               EBITDA_MM__c, 
                                               Revenue_MM__c,
                                               BillingStreet,
                                               BillingState, 
                                               BillingPostalCode, 
                                               BillingCountry, 
                                               BillingCity, 
                                               Ownership,
                                               Total_Debt_MM__c,
                                               Total_Debt_EBITDA__c,
                                               Industry,
                                               Description
                                          FROM Account
                                         WHERE Id =: strAccountId LIMIT 1];
        
            if(!lstAccount.isEmpty())
            {
                strCompanyDesc = (lstAccount[0].Description!= null && lstAccount[0].Description.length() > 745)
                             ? lstAccount[0].Description.substring(0, 735) + '....'
                             : lstAccount[0].Description; 
                
                List<RecordType> rList = [SELECT Name FROM RecordType WHERE id =:lstAccount[0].RecordTypeId];
                if(!rList.isEmpty())
                	strRecordType = '(' + rList[0].Name + ')';
                else
                    strRecordType = '';
                             
                return lstAccount[0];   
            }
            else
                return new Account();
        }
        else
            return new Account();
    }
    /*End */

    public String getCoverageOfficer(){
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
        List<Coverage_Team__c> coverageTeam = [SELECT Officer__r.Name FROM Coverage_Team__c WHERE Company__c =: strAccountID AND Coverage_Level__c='Coverage Officer' LIMIT 1];
        return coverageTeam.isEmpty() ? '' : coverageTeam[0].Officer__r.Name;
    }
    /*
        @MethodName : getCompanyRelationship 
        @param      : NA
        @Description: method for getting external relatioship . 
    */
    public List<ContactWrapper> getCompanyRelationship()
    {
        String recordTypeId = [SELECT Id  FROM RecordType  WHERE RecordType.DeveloperName = 'External_Contact'].Id;
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
        List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();// List of ContactWrapper  
        
       
        Map<Id, Event> mapIdToLastEvent = new Map<Id, Event>();

        Map<Id, Integer> mapIdToTotalActivity = new Map<Id, Integer>();// Map of contact id to total no of activities

        if(String.isBlank(strAccountId) && String.isBlank(recordTypeId))
            return lstContactWrapper;

       

        for (AggregateResult ar : [ SELECT  COUNT(Id) total,
                                            WhoId
                                    FROM    Event
                                    WHERE   (WhatId =: strAccountId
                                    OR      AccountId =: strAccountId)
                                    AND     (ActivityDate < TODAY OR (IsAllDayEvent=False AND ActivityDateTime < :DateTime.Now()))
                                    GROUP BY WhoId
                        ]){
            if (ar.get('WhoId')!=null){
                if (!mapIdToTotalActivity.keySet().contains((Id)ar.get('WhoId'))) {
                    mapIdToTotalActivity.put((Id)ar.get('WhoId'), (Integer)ar.get('total'));
                }
                else {
                    mapIdToTotalActivity.put((Id)ar.get('WhoId'), mapIdToTotalActivity.get((Id)ar.get('WhoId'))+(Integer)ar.get('total'));  
                }
            }
        }
        Map <Integer, List<Id>> mapTotalActivityToUsers = new Map<Integer, List<Id>>();
        for (Id whoId: mapIdToTotalActivity.keySet()){
            if (!mapTotalActivityToUsers.keySet().contains(mapIdToTotalActivity.get(whoId))){
                mapTotalActivityToUsers.put(mapIdToTotalActivity.get(whoId), new List<Id>{whoId});
            }
            else {
                mapTotalActivityToUsers.get(mapIdToTotalActivity.get(whoId)).add(whoId);
            }
        }
        List<Integer> topTenGenerator = new List<Integer>();
        topTenGenerator.addAll(mapTotalActivityToUsers.keyset());
        topTenGenerator.sort();
        Set<Id> topTen = new Set<Id>();
        for (Integer ii = topTenGenerator.size()-1; ii >= 0 && topTen.size()<10; ii--){
            if (topTen.size()+mapTotalActivityToUsers.get(topTenGenerator[ii]).size()<=10){
                topTen.addAll(mapTotalActivityToUsers.get(topTenGenerator[ii]));
            }
            else {
                for (Integer jj = 0; jj < mapTotalActivityToUsers.get(topTenGenerator[ii]).size() && topTen.size()<10; jj++ ){
                    topTen.add(mapTotalActivityToUsers.get(topTenGenerator[ii])[jj]);
                }
            }
        }

       

        for (Event e: [ SELECT  Id,
                                Subject,
                                ActivityDate,
                                WhoId,
                                Who.Name
                        FROM    Event
                        WHERE   (WhatId =: strAccountId
                        OR      AccountId =: strAccountId)
                        AND     (ActivityDate < TODAY OR (IsAllDayEvent=False AND ActivityDateTime < :DateTime.Now()))
                        AND     WhoId IN :topTen
                        ORDER BY ActivityDate DESC]){
            if (!mapIdToLastEvent.keyset().contains(e.WhoId)) {
                mapIdToLastEvent.put(e.WhoId, e);
            }
        }

        Set <Id> AllIdsWithPastActivity = new Set<Id>();
        AllIdsWithPastActivity.addAll(mapIdToLastEvent.keyset());
        Map <Id, Contact> idToContact = new Map <Id, Contact>();
        for (Contact c: [SELECT Id, Title FROM Contact WHERE Id in :AllIdsWithPastActivity]){
            idToContact.put(c.Id, c);
        }


        for (Id whoId: allIdsWithPastActivity){
                lstContactWrapper.add(new ContactWrapper(mapIdToLastEvent.get(whoId).Who.Name, idToContact.containsKey(whoId) ? idToContact.get(whoId).Title : '', mapIdToLastEvent.get(whoId).Subject, mapIdToTotalActivity.get(whoId), mapIdToLastEvent.get(whoId).ActivityDate));    
        }     
        lstContactWrapper.sort();
        return  lstContactWrapper;
    }
    /*End */
    
    /*
        @MethodName : getHLExternalRelationship 
        @param      : CompanyId and RecordTypeName
        @Description: method for getting active relatioship records. 
    */
    public List<ContactWrapper> getHLRelationship(){
        String recordTypeId = [SELECT Id  FROM RecordType  WHERE RecordType.DeveloperName = 'Houlihan_Employee'].Id;
        String strAccountId = ApexPages.currentPage().getParameters().get('Id');
        List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();// List of ContactWrapper  

        Map<Id, Task> mapIdToLastTask = new Map<Id, Task>();
        Map<Id, Event> mapIdToLastEvent = new Map<Id, Event>();

        Map<Id, Integer> mapIdToTotalActivity = new Map<Id, Integer>();// Map of contact id to total no of activities

        if(String.isBlank(strAccountId) && String.isBlank(recordTypeId))
            return lstContactWrapper;

        for (AggregateResult ar : [ SELECT  COUNT(Id) total,
                                            Primary_Attendee_Id__c OwnerId
                                    FROM    Event
                                    WHERE   (Contact__r.AccountId =: strAccountId
                                    OR      WhatId =: strAccountId)
                                    AND     (ActivityDate < TODAY OR (IsAllDayEvent=False AND ActivityDateTime < :DateTime.Now()))
                                    GROUP BY Primary_Attendee_Id__c
                        ]){
            if (ar.get('OwnerId')!=null){
                if (!mapIdToTotalActivity.keySet().contains((Id)ar.get('OwnerId'))) {
                    mapIdToTotalActivity.put((Id)ar.get('OwnerId'), (Integer)ar.get('total'));
                }
                else {
                    mapIdToTotalActivity.put((Id)ar.get('OwnerId'), mapIdToTotalActivity.get((Id)ar.get('OwnerId'))+(Integer)ar.get('total'));  
                }
            }
        }
        Map <Integer, List<Id>> mapTotalActivityToUsers = new Map<Integer, List<Id>>();
        for (Id ownerId: mapIdToTotalActivity.keySet()){
            if (!mapTotalActivityToUsers.keySet().contains(mapIdToTotalActivity.get(ownerId))){
                mapTotalActivityToUsers.put(mapIdToTotalActivity.get(ownerId), new List<Id>{ownerId});
            }
            else {
                mapTotalActivityToUsers.get(mapIdToTotalActivity.get(ownerId)).add(ownerId);
            }
        }
        List<Integer> topTenGenerator = new List<Integer>();
        topTenGenerator.addAll(mapTotalActivityToUsers.keyset());
        topTenGenerator.sort();
        Set<Id> topTen = new Set<Id>();
        for (Integer ii = topTenGenerator.size()-1; ii >= 0 && topTen.size()<10; ii--){
            if (topTen.size()+mapTotalActivityToUsers.get(topTenGenerator[ii]).size()<=10){
                topTen.addAll(mapTotalActivityToUsers.get(topTenGenerator[ii]));
            }
            else {
                for (Integer jj = 0; jj < mapTotalActivityToUsers.get(topTenGenerator[ii]).size() && topTen.size()<10; jj++ ){
                    topTen.add(mapTotalActivityToUsers.get(topTenGenerator[ii])[jj]);
                }
            }
        }


        for (Event e: [ SELECT  Id,
                                Subject,
                                ActivityDate,
                                Primary_Attendee_Id__c,
                                Primary_Attendee__c,
                                Contact__r.Title
                        FROM    Event
                        WHERE   (Contact__r.AccountId =: strAccountId
                        OR      WhatId =: strAccountId)
                        AND     (ActivityDate < TODAY OR (IsAllDayEvent=False AND ActivityDateTime < :DateTime.Now()))
                        AND     Primary_Attendee_Id__c IN :topTen
                        ORDER BY ActivityDate DESC]){
            if (!mapIdToLastEvent.keyset().contains(e.Primary_Attendee_Id__c)) {
                mapIdToLastEvent.put(e.Primary_Attendee_Id__c, e);
            }
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Title FROM Contact WHERE Id In:topTen]);

        Set <Id> AllIdsWithPastActivity = new Set<Id>();
        AllIdsWithPastActivity.addAll(mapIdToLastTask.keyset());
        AllIdsWithPastActivity.addAll(mapIdToLastEvent.keyset());
        for (Id ownerId: allIdsWithPastActivity){
            if (mapIdToLastEvent.keySet().contains(ownerId)){
                 lstContactWrapper.add(new ContactWrapper(mapIdToLastEvent.get(ownerId).Primary_Attendee__c, contactMap.get(ownerId).Title, mapIdToLastEvent.get(ownerId).Subject, mapIdToTotalActivity.get(ownerId), mapIdToLastEvent.get(ownerId).ActivityDate));    
            }
        }     
        lstContactWrapper.sort();
        return  lstContactWrapper;
    }
    /*End */
    
    /*
        @MethodName : getRecentActivities 
        @param      : NA
        @Description: method for getting activities of company. 
    */
    public List<RecentActivityWrapper> getRecentActivities()
    {
        Id strAccountId = ApexPages.currentPage().getParameters().get('Id');//Set of related Company ids
        List<RecentActivityWrapper> lstRecentActivityWrapper = new List<RecentActivityWrapper>();// List of RecentActivityWrapper
        Set<Id> setOwnerId = new Set<Id>();//Set of activities owner id
        Map<Id, Contact> mapOwnerIdToContact = new Map<Id, Contact>();//Map ownerid to contact
        Map<Id, Event> mapIdToEvent = new Map<Id, Event>();
        List<String> parentIds = new List<String>();

        if(String.isBlank(strAccountId))
            return lstRecentActivityWrapper;
        
        for(Event e : [SELECT ParentId__c 
                                     FROM Event 
                                     WHERE Contact__r.AccountId =: strAccountId
                                           AND ActivityDate = LAST_N_MONTHS:12
                                           And ParentId__c <> null
                                     ])
            parentIds.add(e.ParentId__c);

        //Getting last 12 months event
        for (Event e:[SELECT Id,           
                              ActivityDate,
                              Subject,
                              WhoId,
                              Private__c,
                              Contact_Name__c,
                              Contact__r.Title,
                              ParentId__c,
                              Primary_Attendee_Id__c,
                              Primary_External_Contact__c
                       FROM   Event
                       WHERE  ParentId__c IN : parentIds
                              AND ActivityDate = LAST_N_MONTHS:12 
                       ORDER BY Event.ActivityDate DESC])
        {
            if(e.WhoId == e.Primary_Attendee_Id__c)
                lstRecentActivityWrapper.add(new RecentActivityWrapper(e.ActivityDate, 
                                                           UserInfo.getUserId() != e.Primary_Attendee_Id__c && e.Private__c ? 'Private' : e.Subject, 
                                                           e.Contact_Name__c, 
                                                           e.Contact__r.Title, 
                                                           e.Primary_External_Contact__c));
        }

        lstRecentActivityWrapper.sort();
        return lstRecentActivityWrapper;                                        
    }
    /*End */

    /*
        @MethodName : getCompany 
        @param      : NA
        @Description: method for getting company data. 
    */
    public List<OpportunityWrapper> getOpenOpportunities()
    {
        List<OpportunityWrapper> lstOpportunityWrapper = new List<OpportunityWrapper>();// List of OpportunityWrapper
        
        if(setAccountId.isEmpty())  
            return lstOpportunityWrapper;
        //fetching all the transaction record related to the operating company

        Set<Id> relatedOpportunities = new Set<Id>();
        for (Opportunity_Client_Subject__c relOp:     [SELECT Opportunity__c
                                                FROM Opportunity_Client_Subject__c
                                                WHERE Client_Subject__c IN : setAccountId
                                                ]){
            relatedOpportunities.add(relOp.Opportunity__c);
        }

        for(Opportunity__c objOpportunity : [   SELECT Id,
                                                    Pitch_Date__c,
                                                    Job_Type__c,
                                                    Client__r.Name,
                                                    Subject__r.Name,
                                                    Stage__c,
                                                    Total_Fee__c,
                                                    Estimated_Engagement_Date__c,
                                                    (SELECT Id,
                                                            Contact__r.Name
                                                    FROM Opportunity_Internal_Teams__r
                                                    WHERE Role__c='Principal'
                                                     AND (Start_Date__c <= TODAY OR Start_Date__c=null)
                                                     AND (End_Date__c >= TODAY OR End_Date__c=null)
                                                    ORDER BY Contact__r.Name)  
                                                FROM Opportunity__c   
                                                WHERE Id IN :relatedOpportunities
                                                AND Closed__c=False
                                                ORDER BY Estimated_Engagement_Date__c DESC])
        {
            String strPricipals = '';      
            for(Opportunity_Internal_Team__c objOIT : objOpportunity.Opportunity_Internal_Teams__r)
            {
                strPricipals += ', ' + objOIT.Contact__r.Name;
            }
            strPricipals = strPricipals.replaceFirst(',', '');
            lstOpportunityWrapper.add(new OpportunityWrapper(objOpportunity, strPricipals));
        }
        
        return lstOpportunityWrapper;
    } 
    /*End*/

    /*
        @MethodName : getTransInvolvement 
        @param      : NA
        @Description: method for getting transaction data related to the company. 
    */
    public List<HlTransactionWrapper> getTransInvolvement()
    {
        List<HlTransactionWrapper> lstHlTransactionWrapper = new List<HlTransactionWrapper>();//List of HlTransactionWrapper
        
        if(setAccountId.isEmpty())
            return lstHlTransactionWrapper;
        
        //getting engagement records related to operating company   
        for(Engagement__c objEngagement : [SELECT Id,
                                                  Latest_Stage_Change__c,
                                                  Name,
                                                  Client__r.Name,
                                                  Subject__r.Name,
                                                  Job_Type__c,
                                                  Status__c,
                                                  Active__c,
                                                  (SELECT Id,
                                                          Contact__r.Name
                                                     FROM Engagement_Teams__r
                                                    WHERE Role__c='Principal'
                                                    AND (Start_Date__c <= TODAY OR Start_Date__c=null)
                                                    AND (End_Date__c >= TODAY OR End_Date__c=null)
                                                 ORDER BY Contact__r.Name)
                                             FROM Engagement__c
                                            WHERE Client__c IN : setAccountId
                                               OR Subject__c IN : setAccountId])
        {
            String strPrincipal = '';    
            //Iterating on Engagement_Internal_Team__c to get all the contact name 
            for(Engagement_Internal_Team__c objEIT : objEngagement.Engagement_Teams__r)
            {
                strPrincipal += ', ' + objEIT.Contact__r.Name;
            }
            strPrincipal = strPrincipal.replaceFirst(',', '');
            
            lstHlTransactionWrapper.add(new HlTransactionWrapper(objEngagement, strPrincipal));
        }                                                   
        return lstHlTransactionWrapper;
    } 
    /*End */
    /*
        @MethodName : getFeeTotalLastThreeYears
        @param      : NA
        @Description: method for getting transaction data related to the company. 
    */
    public Decimal getFeeTotalLastThreeYears()
    {

        Decimal sum = 0;
        for(AggregateResult ar : [  SELECT Sum (Total_Estimated_Fee__c) total 
                                    FROM Engagement__c
                                    WHERE (Client__c IN : setAccountId
                                    OR Subject__c IN : setAccountId)
                                    AND Start_Date__c >= LAST_N_YEARS:3
                                    AND Start_Date__c < TODAY
                                     ]){
            sum+= ar.get('total')!=null ? (Decimal) ar.get('total'): 0;
        } 
        return sum;
    }
    /*End */
    /*
        @MethodName : getDealsData 
        @param      : NA
        @Description: method for getting deal data related to the company. 
    */
    public List<DealWrapper> getDealsData()
    {
        List<DealWrapper> lstDealWrapper = new List<DealWrapper>();// List of lstDealWrapper
        
        if(setAccountId.isEmpty())
            return lstDealWrapper;  
        
        List<Engagement_Counterparty__c> ecList = [SELECT Id,
                                                       Role__c,
                                                       Engagement__r.Date_Engaged__c,
                                                       Engagement__r.Name,
                                                       Engagement__r.Job_Type__c,
                                                       Engagement__r.Client__r.Name,
                                                       Engagement__r.Subject__r.Name,
                                                       Company__r.Name,
                                                       Status__c,
                                                       (SELECT Id,
                                                               Contact__r.Name
                                                          FROM Engagement_Counterparty_Contacts__r
                                                         WHERE Type__c = 'Primary' 
                                                      ORDER BY CreatedDate DESC LIMIT 1)
                                                  FROM Engagement_Counterparty__c
                                                 WHERE Company__c IN : setAccountId
                                                 ORDER BY Engagement__r.Date_Engaged__c DESC LIMIT :MaxDealsShownDisplay ];  //Order deals shown by the start date and only show the 20 most recent deals
        
        integer ecNumItems = [SELECT COUNT() FROM Engagement_Counterparty__c WHERE Company__c IN : setAccountId];
        
        if(ecNumItems > MaxDealsShownDisplay)
            strDealsShownTag = ' (20 Most Recent)';
        else
            strDealsShownTag = '';
        
        DealsShownStyle = 'display:initial; height: 40px;';
        strTotalDealsShown = string.valueOf(ecNumItems);
        
        //Iterating on Engagement_Counterparty__c for getting role
        for(Engagement_Counterparty__c objEC : ecList)
        {
            lstDealWrapper.add(new DealWrapper(objEC.Engagement__r.Date_Engaged__c, 
                                               objEC.Engagement__r.Name,
                                               objEC.Engagement__r.Client__r.Name,
                                               objEC.Engagement__r.Subject__r.Name,
                                               objEc.Company__r.Name,
                                               objEC.Engagement__r.Job_Type__c,
                                               (objEC.Engagement_Counterparty_Contacts__r.size() > 0) 
                                                ? objEC.Engagement_Counterparty_Contacts__r[0].Contact__r.Name : '',
                                                objEC.Status__c));
        }
            
        return lstDealWrapper;
    }
    /*End */
    
    /*
        @MethodName : getAccountIds 
        @param      : NA
        @Description: method for getting company ids related to the operating company. 
    */
    private Set<Id> getAccountIds(String strAccountId)
    {
        Set<Id> setAccountId = new Set<Id>{strAccountId};// Set of all child and parent company id related to operating company 
        if(String.isBlank(strAccountId) || strAccountId == null)
            return setAccountId;
            
        Account objAccount = [SELECT Id, 
                                     Ultimate_Parent__c 
                                FROM Account 
                               WHERE Id =: strAccountId];
        
        if(objAccount.Ultimate_Parent__c !=null)
        {
            setAccountId.add(objAccount.Ultimate_Parent__c);
            for(Account objAcc : [SELECT Id,
                                         Ultimate_Parent__c
                                    FROM Account
                                   WHERE Ultimate_Parent__c =: objAccount.Ultimate_Parent__c])
            {
                setAccountId.add(objAcc.Id);
            }
        }   
        else
        {
            for(Account objAcc : [SELECT Id,
                                         Ultimate_Parent__c
                                    FROM Account
                                   WHERE Ultimate_Parent__c =: strAccountId])
            {
                setAccountId.add(objAcc.Id);
            }
        }
        return setAccountId;
    }
    /*End */
}