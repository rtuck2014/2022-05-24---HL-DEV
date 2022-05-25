public class HL_ActivitySearchController extends HL_ActivityControllerBase{
    public static final integer PageSize =10;
    public String typesearchKey {get;set;}
    public date datesearchKey {get;set;}
    transient public List<HL_Activity>Activities{get;set;}
    public Static List<HL_Activity > aListRecords= new List<HL_Activity > ();
    // PS - All activity will be shown as default on all place where this controller used .
    public String FilterText {
        get {
            return String.isBlank(filterText) ? (EntityType == 'User' ? 'All' : 'All') : filterText;
        }
        set;
    }
    public String SortDirection {
        get {
            return sortDirection == null ? 'ASC' : sortDirection;
        }
        set;
    }
    public Boolean isValidToAccessContactComment {
        get;
        set;
    }
    public Static List<HL_Activity > aList {
        get;
        set;
    }
    
    public Integer StartIndex {
        get {
            if (startIndex == null)
                startIndex = 0;
            return startIndex;
        }
        set;
    }
    public Integer EndIndex {
        get {
            if (endIndex == null)
                endIndex = pagesize;
            return endIndex;
        }
        set;
    }
    public Integer TotalRecords {
        get;
        set;
    }
    public Integer TotalPages {
        get {
            if (totalPages == null)
                totalPages = 0;
            return totalPages;
        }
        set;
    }
    public Integer Page {
        get {
            if (page == null)
                page = 1;
            return page;
        }
        set;
    }
    public Boolean HasPrevious {
        get {
            return Page > 1;
        }
    }
    public Boolean HasNext {
        get {
            return Page<TotalPages;
        }
    }
    public String NewSort {
        get;
        set;
    }
    
    public String SortField {
        get {
            return sortField == null ? 'StartDateTime DESC, CreatedDate' : sortField;
        }
        set {
            ToggleDirection(value);
            SortField = value;
        }
    }
    private static boolean avoidsql=false;
    private Set<Id> EntityContacts {
        get {
            if (entityContacts == null) {
                entityContacts = new Set<Id> ();
                //For Accounts, We Need to Get the Account Contacts
                if (EntityType == 'Account') {
                    for (Contact c: HL_Contact.GetByCompany(EntityId))
                        entityContacts.add(c.Id);
                }
                //For User, We Need to Get The User's Contact Record
                else if (EntityType == 'User')
                    entityContacts.addAll(HL_Contact.GetByUserIdset(EntityId));
            }
            return entityContacts;
        }
        set;
    }
    public HL_ActivitySearchController() {
        if (ApexPages.currentPage() != null)
            EntityId = HL_PageUtility.GetParameter('id');
        TotalRecords = 0;
        
        aListRecords= new List<HL_Activity > ();
        Activities= new List<HL_Activity >();
        TotalRecords = 0;
        isValidToAccessContactComment = HL_ContactCommentHandler.isValidToCreateContactComment();
        getActivityList(null,null);
    }
    public HL_ActivitySearchController(ApexPages.StandardController controller) {
        EntityId = HL_PageUtility.GetParameter('id');
        /*string cuser= HL_PageUtility.GetParameter('id');
        system.debug('==EntityId==='+EntityId);
        if(cuser.LEFT(3)=='005'){
            system.debug('==EntityId==='+EntityId);
        }  */
        /*aListRecords= new List<HL_Activity > ();
        Activities= new List<HL_Activity >();
        TotalRecords = 0;
        isValidToAccessContactComment = HL_ContactCommentHandler.isValidToCreateContactComment();
        getActivityList(null,null);*/
        
    }
    
    public void PreviousPage() {
        Page = Page - 1;
        //======
        List<HL_Activity>aList=new List<HL_Activity>();
       
        StartIndex = (Page - 1) * PageSize;
        EndIndex = Page * PageSize;
        TotalRecords = 0;
        getActivityList(selectedTypevalue,datesearchKey);
        Activities.clear();
        system.debug(EndIndex+'===StartIndex===' + StartIndex);
        system.debug('===selectedTypevalue==='+selectedTypevalue);
        system.debug('===datesearchKey==='+datesearchKey);
        
        for(HL_Activity aa:aListRecords){
            system.debug('===aa.Activity==='+aa.Activity);
            system.debug('===aa.Activity.type==='+aa.Activity.type);
            
            if(selectedTypevalue<>null && datesearchKey<>null){
                if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) && aa.Activity.type==selectedTypevalue && aa.ActivityDate.date()==datesearchKey) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) && aa.ActivityDate.date()==datesearchKey) aList.add(aa);
            }
            else if(selectedTypevalue<>null){
                if(aa.Activity<>null && aa.Activity.type==selectedTypevalue) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) || (aa.ActivityDate<>null && aa.ActivityDate.date()==datesearchKey)) aList.add(aa);
            }else if(datesearchKey<>null){
                if(aa.Activity<>null && aa.Activity.type==selectedTypevalue) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) || (aa.ActivityDate<>null && aa.ActivityDate.date()==datesearchKey)) aList.add(aa);
            }   
            else if(selectedTypevalue==null && datesearchKey==null)aList.add(aa);
        }
        
        if (aList != null && aList.size() > 0) {
            TotalRecords = aList.size();
            if (EndIndex > aList.size())
                EndIndex = aList.size();
            
            for (Integer i = StartIndex; i<EndIndex; i++) {
                
                Activities.add(aList[i]);
            }
            Activities.sort();
        }
        
        system.debug('===Activities==='+Activities);
        //Calculate total pages
        Decimal pages = Decimal.valueOf(TotalRecords);
        pages = pages.divide(Decimal.valueOf(pageSize), 2);
        TotalPages = (Integer) pages.round(System.RoundingMode.CEILING);
        system.debug(pages + 'pages ............491' + TotalPages);
        //Adjust the Start Index
        StartIndex++;
        
        //Adjust End Index
        if (EndIndex > TotalRecords)
            EndIndex = TotalRecords;
    }
    
    public void gonextPage() {
        Page = Page + 1;
        //======
        List<HL_Activity>aList=new List<HL_Activity>();
        system.debug('selectedTypevalue======' + selectedTypevalue);
        offSetSize += queryLimit ;
        getActivityList(selectedTypevalue,datesearchKey);
        Activities.clear();
        //Determine the Range of Records to Return
        system.debug('Page==Next====' + Page);
        system.debug('PageSize===next===' + PageSize);
        StartIndex = (Page - 1) * PageSize;
        EndIndex = Page * PageSize;
        TotalRecords = 0;
        
        
        system.debug('===selectedTypevalue==='+selectedTypevalue);
        system.debug('===datesearchKey==='+datesearchKey);
        
        for(HL_Activity aa:aListRecords){
            //system.debug('===aa.Activity==='+aa.Activity);
            system.debug('===aa.Activity.type==='+aa.Activity.type);
            
            if(selectedTypevalue<>null && datesearchKey<>null){
                if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) && aa.Activity.type==selectedTypevalue && aa.ActivityDate.date()==datesearchKey) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) && aa.ActivityDate.date()==datesearchKey) aList.add(aa);
            }
            else if(selectedTypevalue<>null){
                if(aa.Activity<>null && aa.Activity.type==selectedTypevalue) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) || (aa.ActivityDate<>null && aa.ActivityDate.date()==datesearchKey)) aList.add(aa);
            }else if(datesearchKey<>null){
                if(aa.Activity<>null && aa.Activity.type==selectedTypevalue) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) || (aa.ActivityDate<>null && aa.ActivityDate.date()==datesearchKey)) aList.add(aa);
            }   
            else if(selectedTypevalue==null && datesearchKey==null) aList.add(aa);
        }
        
        if (aList != null && aList.size() > 0) {
            TotalRecords = aList.size();
            if (EndIndex > aList.size()) EndIndex = aList.size();
            
            for (Integer i = StartIndex; i<EndIndex; i++) {
                
                Activities.add(aList[i]);
            }
            Activities.sort();
        }
        
        system.debug('===Activities==='+Activities);
        //Calculate total pages
        Decimal pages = Decimal.valueOf(TotalRecords);
        pages = pages.divide(Decimal.valueOf(pageSize), 2);
        TotalPages = (Integer) pages.round(System.RoundingMode.CEILING);
        system.debug(pages + 'pages ............491' + TotalPages);
        //Adjust the Start Index
        StartIndex++;
        
        //Adjust End Index
        if (EndIndex > TotalRecords)
            EndIndex = TotalRecords;
        
    }
    
    public void FilterAll() {
        FilterText = 'All';
    }
    public void FilterToday() {
        FilterText = 'Today\'s';
    }
    public void FilterUpcoming() {
        FilterText = 'Upcoming';
    }
    
    private String GetWhereClause() {
        string whereClause = '(WhatId=:EntityId OR WhoId=:EntityId) ';
        if (EntityType == 'Account')
            whereClause = '(WhatId=:EntityId OR WhoId IN : contactIds) ';
        else if (EntityType == 'User')
            whereClause = 'WhoId IN : contactIds AND Mask_As_External__c = false ';
        else {
            HL_ActivityListController con = new HL_ActivityListController();
            BuildMenteeMentorSets();
            //if (!con.HasInternalAccess && !menteeIdSet.contains(UserContactRecord.id) && !mentorIdSet.contains(UserContactRecord.id) && !hasMentorActivityAccess)
            if (!con.HasInternalAccess)
                whereClause += 'AND Mask_As_External__c = false ';
        }
        whereClause += FilterText == 'Today\'s' ? 'AND StartDateTime = TODAY ' : FilterText == 'Upcoming' ? 'AND StartDateTime > TODAY ' : '';
        system.debug('==whereClause=='+whereClause);
        return whereClause;
    }
    Set<Id> menteeIdSet = new Set<Id> ();
    Set<Id> mentorIdSet = new Set<Id> ();
    private void BuildMenteeMentorSets() {
        
        for (Event e: [SELECT ParentId__c, Id, Mask_As_External__c, WhoId FROM Event WHERE(WhatId =: EntityId OR WhoId =: EntityId)]) {
            if (e.Mask_As_External__c)
                menteeIdSet.add(e.WhoId);
            else
                mentorIdSet.add(e.whoId);
        }
    }
    public void ToggleDirection(string newSort) {
        SortDirection = (SortField == newSort) ? (SortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }  
    
    /*private static List<Event> GetActivityList(string query) {
        Set<Id> activityIdSet = new Set<Id> ();
        List<Event> activityList = new List<Event> ();
        
        for (Event e: Database.query(query)) {
            if (!activityIdSet.contains(e.Id) && (e.ParentId__c == null || !activityIdSet.contains(e.ParentId__c))) {
                activityList.add(e);
                activityIdSet.Add(e.Id);
                activityIdSet.Add(e.ParentId__c);
            }
        }
        
        return activityList;
    }
    
    public string GetInternalFilterClause() {
        HL_ActivityListController con = new HL_ActivityListController();
        string filterClause = '';
        
        if (!con.HasInternalAccess)
            filterClause = ' AND Type != \'Internal\' ';
        
        if (!con.HasInternalSupervisorAccess)
            filterClause += ' AND Mask_As_External__c = false ';
        //Added By Harsh for Internal Mentor Meeting         
        if (!con.hasMentorActivityAccess)
            filterClause = ' AND Type != \'Internal Mentor Meeting\' ';
        
        return filterClause;
    }*/
    public void fetchActivities(){
        List<HL_Activity>aList=new List<HL_Activity>();
        system.debug('selectedTypevalue======' + selectedTypevalue);
        getActivityList(selectedTypevalue,datesearchKey);
        Activities.clear();
        //aListRecords=new List<HL_Activity>();
        //Determine the Range of Records to Return
        Page=1;
        StartIndex = (Page - 1) * PageSize;
        EndIndex = Page * PageSize;
        TotalRecords = 0;
        
        system.debug(EndIndex+'===StartIndex===' + StartIndex);
        system.debug('===selectedTypevalue==='+selectedTypevalue);
        system.debug('===datesearchKey==='+datesearchKey);
        for(HL_Activity aa:aListRecords){
            //system.debug('===aa.Activity==='+aa.Activity);
            system.debug('===aa.Activity.type==='+aa.Activity.type);
            
            if(selectedTypevalue<>null && datesearchKey<>null){
                if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) && aa.Activity.type==selectedTypevalue && aa.ActivityDate.date()==datesearchKey) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) && aa.ActivityDate.date()==datesearchKey) aList.add(aa);
            }
            else if(selectedTypevalue<>null){
                if(aa.Activity<>null && aa.Activity.type==selectedTypevalue) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) || (aa.ActivityDate<>null && aa.ActivityDate.date()==datesearchKey)) aList.add(aa);
            }else if(datesearchKey<>null){
                if(aa.Activity<>null && aa.Activity.type==selectedTypevalue) aList.add(aa);
                else if((aa.Activity<>null && aa.Activity.type==selectedTypevalue) || (aa.ActivityDate<>null && aa.ActivityDate.date()==datesearchKey)) aList.add(aa);
            }   
            else if(selectedTypevalue==null && datesearchKey==null) aList.add(aa);
        }
        
        if (aList != null && aList.size() > 0) {
            TotalRecords = aList.size();
            if (EndIndex > aList.size())
                EndIndex = aList.size();
            
            for (Integer i = StartIndex; i<EndIndex; i++) {
                
                Activities.add(aList[i]);
            }
            Activities.sort();
        }
        
        //system.debug('===Activities==='+Activities);
        //Calculate total pages
        Decimal pages = Decimal.valueOf(TotalRecords);
        pages = pages.divide(Decimal.valueOf(pageSize), 2);
        TotalPages = (Integer) pages.round(System.RoundingMode.CEILING);
        system.debug(pages + 'pages ............491' + TotalPages);
        //Adjust the Start Index
        StartIndex++;
        
        //Adjust End Index
        if (EndIndex > TotalRecords)
            EndIndex = TotalRecords;
    }
    
    public void ApplySort() {
        SortField = NewSort;
    }
    
    public Integer offSetSize = 0;
    public Integer QueryLimit = 10;
    
    public void getActivityList(string selectedTypevalue,date datesearchKey) {
        
        List<HL_Activity > aList = new List<HL_Activity > ();
        List<HL_Activity > sortedList = new List<HL_Activity > ();
        Activities= new List<HL_Activity >();
        Set<Id> activityIds = new Set<Id> ();
        Set<Id> emailRelIds = new Set<Id> ();
        Set<Id> processedIds = new Set<Id> ();
        Set<string> contactEmails = new Set<string> ();
        Map<Id, Task> mapTask = new Map<Id, Task> ();
        Set<Id> contactIds = this.EntityContacts;
        List<Contact> primaryAttendees = new List<Contact> (); //Store the Primary Attendees so that we can create a User Map for Permissions
        List<Event> eventList = new List<Event> (); //Store the final event list to convert to HL_Activity Records
        List<Task> taskList = new List<Task> (); //Store the final event list to convert to HL_Activity Records
        Id userId = UserInfo.getUserId();
        Contact c = HL_Contact.GetByUserId(UserId);
        aListRecords.clear();
        Integer i=0;
        String modifiedWhereClause ;
        system.debug('typesearchKey======' + typesearchKey);
        Map<Id, Id> mapActivityWithEmail = new Map<Id, Id> ();
        Map<Id, String> mapActivityWithEmailDesc = new Map<Id, String> ();
        
        if(selectedTypevalue==null && datesearchKey==null)
            modifiedWhereClause = '(Type != \'Internal Mentor Meeting\' AND ' + GetWhereClause() + ') OR ((WhatId=:EntityId OR WhoId=:EntityId) AND Type = \'Internal Mentor Meeting\') ';
        else if(selectedTypevalue==null && datesearchKey <>Null)
            modifiedWhereClause = '(ActivityDate =:datesearchKey AND '+ GetWhereClause() + ') OR ((WhatId=:EntityId OR WhoId=:EntityId) AND Type = \'Internal Mentor Meeting\') ';
        else if(selectedTypevalue<>null && datesearchKey <>Null)
            modifiedWhereClause = '(Type =:selectedTypevalue AND ActivityDate =:datesearchKey AND ' + GetWhereClause() + ') OR ((WhatId=:EntityId OR WhoId=:EntityId) AND Type =:selectedTypevalue) ';
        else if(selectedTypevalue<>null && datesearchKey==Null)
            modifiedWhereClause = '(Type =:selectedTypevalue AND ' + GetWhereClause() + ') OR ((WhatId=:EntityId OR WhoId=:EntityId) AND Type =:selectedTypevalue) ';
        
        // modifiedWhereClause = '(Type =:selectedTypevalue AND ' + GetWhereClause() + ') OR ((WhatId=:EntityId OR WhoId=:EntityId) AND Type =:selectedTypevalue) ';
        
        string STANDARD_SELECT = 'SELECT WhatId,CreatedDate, ActivityDate,WhoId, StartDateTime, PFG_Notification__c, Client_Participation__c, No_External_Contact__c, PFG__c, EndDateTime, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Sync_To_Outlook__c, Notify_Coverage_Team__c, Followup_Start_Date__c, Followup_Start_Time__c, Followup_End_Date__c, Followup_End_Time__c, Subject, Type, ParentId__c, Private__c, Primary_Attendee_Id__c, Primary_Attendee__c, Primary_External_Contact_Id__c, Primary_External_Contact__c, Primary_External_Contact_Company_Id__c, Primary_External_Contact_Company__c, Is_Complete__c, Mask_As_External__c, Activity_Detail_Report__c, Riva_Activity_Id__c, Riva_Activity_Link_Id__c,  Contact__c, CreatedById, CreatedBy.Name ';
        //string query = STANDARD_SELECT + 'FROM Event WHERE ' + modifiedWhereClause + ' ORDER BY ' + SortField + ' ' + SortDirection + ', ParentId__c LIMIT 2000';
        string whereClause = FilterText == 'Today\'s' ? ' AND ActivityDate = TODAY ' : FilterText == 'Upcoming' ? ' AND ActivityDate > TODAY ' : '';
        system.debug('GetWhereClause....................' + GetWhereClause());
        //system.debug('GetWhereClause........query............' + query);
        system.debug('GetWhereClause....................' + modifiedWhereClause);
        system.debug('===selectedTypevalue===' + selectedTypevalue);
        // LIMIT 10 OFFSET '+ offSetSize
        for (Event e: Database.Query(STANDARD_SELECT + 'FROM Event WHERE ' + modifiedWhereClause + ' ORDER BY ' + SortField + ' ' + SortDirection + ', ParentId__c')) {
            //Prevent Duplicates when Parent and Child Records from Same Place are Assigned (i.e. Contact at Company Discussed)
            if (e.ParentId__c<>null && !activityIds.contains(e.ParentId__c) ) {
                eventList.Add(e);
                if (!String.isBlank(e.Primary_Attendee_Id__c))
                    primaryAttendees.add(new Contact(Id = e.Primary_Attendee_Id__c));
                activityIds.Add(e.Id);
                activityIds.Add(e.ParentId__c);
                // }
                //Count the Total Number of Records
                TotalRecords++;
            }
        }
        //Get a Map of Event Id with HL Attendees
        Map<Id, Set<Id>> eventToHLAttendeeMap = new Map<Id, Set<Id>> ();
        Map<Id, Set<Id>> eventToHLMenteeMap = new Map<Id, Set<Id>> ();
        system.debug('--activityIds---' + activityIds.size());
        List<Event>eList=new List<Event>();
        if(selectedTypevalue<>null && datesearchKey<>null)
            eList=[SELECT ParentId__c, WhoId, Mask_As_External__c FROM Event WHERE Type =:selectedTypevalue AND ActivityDate =:datesearchKey AND ParentId__c IN: activityIds AND WhoID<>null ORDER BY CreatedDate DESC];
        else if(selectedTypevalue<>null && datesearchKey==null)
            eList=[SELECT ParentId__c, WhoId, Mask_As_External__c FROM Event WHERE Type =:selectedTypevalue AND ParentId__c IN: activityIds AND WhoID<>null ORDER BY CreatedDate DESC];
        else if(selectedTypevalue==null && datesearchKey<>null)
            eList=[SELECT ParentId__c, WhoId, Mask_As_External__c FROM Event WHERE ActivityDate =:datesearchKey AND ParentId__c IN: activityIds AND WhoID<>null ORDER BY CreatedDate DESC];
        else
            eList=[SELECT ParentId__c, WhoId, Mask_As_External__c FROM Event WHERE ParentId__c IN: activityIds AND WhoID<>null ORDER BY CreatedDate DESC];
        
        for (Event e: eList){//[SELECT ParentId__c, WhoId, Mask_As_External__c FROM Event WHERE Type =:selectedTypevalue AND ParentId__c IN: activityIds AND WhoID<>null]) {
            if (!e.Mask_As_External__c) {
                if (eventToHLAttendeeMap.get(e.ParentId__c) == null)
                    eventToHLAttendeeMap.put(e.ParentId__c, new Set<Id> {
                        e.WhoId
                            });
                else {
                    Set<Id> attendeeSet = eventToHLAttendeeMap.get(e.ParentId__c);
                    attendeeSet.add(e.WhoId); eventToHLAttendeeMap.put(e.ParentId__c, attendeeSet);
                }
            } else {
                if (eventToHLMenteeMap.get(e.ParentId__c) == null) {
                    eventToHLMenteeMap.put(e.ParentId__c, new Set<Id> {
                        e.WhoId
                            });
                } else {
                    Set<Id> menteeSet = eventToHLMenteeMap.get(e.ParentId__c);
                    menteeSet.add(e.WhoId); eventToHLMenteeMap.put(e.ParentId__c, menteeSet);
                }
            }
        }
        Map<Id, Contact> primaryAttendeeMap = HL_Contact.GetMap(primaryAttendees);
        Map<Id, ActivityHistory> mapActivityHistory = new Map<Id, ActivityHistory> ();
        Map<Id, OpenActivity> mapOpenActivity = new Map<Id, OpenActivity> ();
        if (EntityType == 'Contact') {
            userId =HL_Contact.GetByContactUserId(EntityId);
            For(Contact eachCon: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivitySubtype, ActivityDate, createdby.name FROM ActivityHistories where IsTask = true ORDER BY createddate Desc limit 199) FROM contact where id =: EntityId]) {
                list<ActivityHistory> lstAct = eachCon.ActivityHistories;
                for (ActivityHistory eachAct: lstAct) {
                    if (eachAct.ActivitySubtype == 'Email') {
                        mapActivityHistory.put(eachAct.Id, eachAct);
                    } else {
                        
                    }
                }
                
            }
        }
        
        if (EntityType == 'Account') {
            For(Account eachAcc: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivitySubtype, ActivityDate, createdby.name FROM ActivityHistories where IsTask = true ORDER BY createddate Desc limit 199) FROM Account where id =: EntityId]) {
                list<ActivityHistory> lstAct = eachAcc.ActivityHistories;
                for (ActivityHistory eachAct: lstAct) { mapActivityHistory.put(eachAct.Id, eachAct);
                }
                
            }
        }
        
        if (EntityType == 'User') {
            For(Contact eachCon: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivityDate, ActivitySubtype, createdby.name FROM ActivityHistories where IsTask = true ORDER BY createddate Desc limit 199) FROM contact where Id IN: contactIds]) {
                list<ActivityHistory> lstAct = eachCon.ActivityHistories;
                for (ActivityHistory eachAct: lstAct) {
                    mapActivityHistory.put(eachAct.Id, eachAct);
                }
                
            }
        }
        if (EntityType == 'Opportunity__c') {
            For(Opportunity__c eachCon: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivityDate, ActivitySubtype, createdby.name FROM ActivityHistories where IsTask = true ORDER BY createddate Desc limit 199) FROM Opportunity__c where Id =: EntityId]) {
                list<ActivityHistory> lstAct = eachCon.ActivityHistories;
                for (ActivityHistory eachAct: lstAct) {
                    mapActivityHistory.put(eachAct.Id, eachAct);
                }
                
            }
        }
        
        if (EntityType == 'Contact') {
            For(Contact eachCon: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivitySubtype, ActivityDate, createdby.name FROM OpenActivities where IsTask = true ORDER BY createddate Desc limit 199) FROM contact where id =: EntityId]) {
                list<OpenActivity> lstAct = eachCon.OpenActivities;
                for (OpenActivity eachAct: lstAct) {
                    if (eachAct.ActivitySubtype == 'Email') {  mapOpenActivity.put(eachAct.Id, eachAct);
                    }
                }
                
            }
        }
        
        if (EntityType == 'Account') {
            For(Account eachAcc: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivitySubtype, ActivityDate, createdby.name FROM OpenActivities where IsTask = true ORDER BY createddate Desc limit 199) FROM Account where id =: EntityId]) {
                list<OpenActivity> lstAct = eachAcc.OpenActivities;
                for (OpenActivity eachAct: lstAct) {mapOpenActivity.put(eachAct.Id, eachAct);
                }
            }
        }
        
        if (EntityType == 'User') {
            For(Contact eachCon: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivityDate, ActivitySubtype, createdby.name FROM OpenActivities where IsTask = true ORDER BY createddate Desc limit 199) FROM contact where Id IN: contactIds]) {
                list<OpenActivity> lstAct = eachCon.OpenActivities;
                for (OpenActivity eachAct: lstAct) {
                    mapOpenActivity.put(eachAct.Id, eachAct);
                }
                
            }
        }
        if (EntityType == 'Opportunity__c') {
            For(Opportunity__c eachCon: [SELECT Id, (SELECT Id, Subject, CreatedDate, ActivityDate, ActivitySubtype, createdby.name FROM OpenActivities where IsTask = true ORDER BY createddate Desc limit 199) FROM Opportunity__c where Id =: EntityId]) {
                list<OpenActivity> lstAct = eachCon.OpenActivities;
                for (OpenActivity eachAct: lstAct) {
                    mapOpenActivity.put(eachAct.Id, eachAct);
                }
                
            }
        }
        
        set<Id> setActivityIds = new set<Id> ();
        set<Id> settaskIds = new set<Id> ();
        set<Id> setEmailMsgIds = new set<Id> ();
        if (mapOpenActivity != null && mapOpenActivity.size() > 0) {
            setActivityIds.addAll(mapOpenActivity.keySet());
        }
        if (mapActivityHistory != null && mapActivityHistory.size() > 0) {
            setActivityIds.addAll(mapActivityHistory.keySet());
        }
        if (contactIds!=null && !contactIds.isEmpty()) {
            for(TaskRelation  taskRel  : [SELECT RelationId,TaskId FROM TaskRelation where task.Exclude_From_Activity_List__c=false and (RelationId In :contactIds  or RelationId=:userId)]){
                settaskIds.add(taskRel.TaskId);
            }
        }
        system.debug('contactIds ....' + contactIds);
        system.debug('EntityId ....' + EntityId);
        system.debug('EntityType  ....' + EntityType);
        system.debug('settaskIds....' + settaskIds);
        string modifiedTaskwhereClause='';
        if (EntityType == 'User') {
            modifiedTaskwhereClause=' and (WhatId=:EntityId OR WhoId=:EntityId or Id IN : setActivityIds or WhoId In :contactIds or WhatId In :contactIds or Id In :settaskIds)';
        }
        else{
            modifiedTaskwhereClause=' and (WhatId=:EntityId OR WhoId=:EntityId)';
        } 
        
        if (!String.isBlank(whereClause)) {
            modifiedTaskwhereClause = modifiedTaskwhereClause + whereClause;
        }
        
        system.debug('whereClause.......' + whereClause);
        //  modifiedTaskwhereClause =' order by createddate limit 2000';
        String Taskquery = 'SELECT AccountId,Id,Createddate,TaskSubtype,Start_Date__c ,who.name,Subject,ActivityDate,Contact__c,Type,WhatId,Description,CreatedBy.Name,Primary_External_Contact__c,Primary_External_Contact_Id__c,Primary_Attendee__c,WhoId FROM Task where Exclude_From_Activity_List__c=false' + modifiedTaskwhereClause + ' limit 2000';
        
        system.debug('Taskquery....' + Taskquery);
        system.debug('userId....' + userId);
        for (task eachtask: Database.Query(Taskquery)) {
            mapTask.put(eachtask.id, eachtask);
        }
        system.debug('mapTask....' + mapTask.size());
        system.debug(userId + 'EntityType .....' + EntityType);
        String EntityClause ='';
        if (EntityType == 'User') {
            EntityClause ='or RelationId In :contactIds or RelationId =: userId)';
        }
        else if (EntityType == 'Contact' && userId !=null) {
            EntityClause ='or RelationId =: userId)';
        }
        else{
            EntityClause =')';
        } 
        system.debug('EntityClause ....' + EntityClause);
        //if (EntityType == 'User') {
        string emailQuery = 'SELECT EmailMessageId,EmailMessage.ActivityId, EmailMessage.Exclude_From_Activity_List__c,EmailMessage.subject,EmailMessage.MessageDate,RelationId FROM EmailMessageRelation WHERE EmailMessage.Exclude_From_Activity_List__c=false and (RelationId =: EntityId '+EntityClause;
        string whereClauseRel = FilterText == 'Today\'s' ? ' AND EmailMessage.MessageDate= TODAY ' : FilterText == 'Upcoming' ? ' AND EmailMessage.MessageDate > TODAY ' : '';
        
        if (!String.isBlank(whereClause)) {
            emailQuery = emailQuery + whereClauseRel;
        }
        
        system.debug('emailQuery...'+emailQuery);
        for (EmailMessageRelation emrel: Database.Query(emailQuery)) {
            
            emailRelIds.add(emrel.EmailMessageId);
        }
        system.debug('emailRelIds...'+emailRelIds.size());
        // }
        
        
        if (mapOpenActivity != null && mapOpenActivity.size() > 0) {
            setActivityIds.addAll(mapOpenActivity.keySet());
        }
        if (mapActivityHistory != null && mapActivityHistory.size() > 0) {
            setActivityIds.addAll(mapActivityHistory.keySet());
        }
        if (contactIds!=null && !contactIds.isEmpty()) {
            for(TaskRelation  taskRel  : [SELECT RelationId,TaskId FROM TaskRelation where task.Exclude_From_Activity_List__c=false and (RelationId In :contactIds  or RelationId=:userId)]){
                settaskIds.add(taskRel.TaskId);
            }
        }
        system.debug('contactIds ....' + contactIds);
        system.debug('EntityId ....' + EntityId);
        system.debug('EntityType  ....' + EntityType);
        system.debug('settaskIds....' + settaskIds);
        //string modifiedTaskwhereClause='';
        if (EntityType == 'User') {
            modifiedTaskwhereClause=' and (WhatId=:EntityId OR WhoId=:EntityId or Id IN : setActivityIds or WhoId In :contactIds or WhatId In :contactIds or Id In :settaskIds)';
        }
        else{
            modifiedTaskwhereClause=' and (WhatId=:EntityId OR WhoId=:EntityId)';
        } 
        
        if (!String.isBlank(whereClause)) {
            modifiedTaskwhereClause = modifiedTaskwhereClause + whereClause;
        }
        
        system.debug('whereClause.......' + whereClause);
        //  modifiedTaskwhereClause =' order by createddate limit 2000';
        Taskquery = 'SELECT AccountId,Id,Createddate,TaskSubtype,Start_Date__c ,who.name,Subject,ActivityDate,Contact__c,Type,WhatId,Description,CreatedBy.Name,Primary_External_Contact__c,Primary_External_Contact_Id__c,Primary_Attendee__c,WhoId FROM Task where Exclude_From_Activity_List__c=false' + modifiedTaskwhereClause + ' limit 2000';
        
        system.debug('Taskquery....' + Taskquery);
        system.debug('userId....' + userId);
        for (task eachtask: Database.Query(Taskquery)) {
            mapTask.put(eachtask.id, eachtask);
        }
        system.debug('mapTask....' + mapTask.size());
        system.debug(userId + 'EntityType .....' + EntityType);
        EntityClause ='';
        if (EntityType == 'User') {
            EntityClause ='or RelationId In :contactIds or RelationId =: userId)';
        }
        else if (EntityType == 'Contact' && userId !=null) {
            EntityClause ='or RelationId =: userId)';
        }
        else{
            EntityClause =')';
        } 
        system.debug('EntityClause ....' + EntityClause);
        //if (EntityType == 'User') {
        emailQuery = 'SELECT EmailMessageId,EmailMessage.ActivityId, EmailMessage.Exclude_From_Activity_List__c,EmailMessage.subject,EmailMessage.MessageDate,RelationId FROM EmailMessageRelation WHERE EmailMessage.Exclude_From_Activity_List__c=false and (RelationId =: EntityId '+EntityClause;
        whereClauseRel = FilterText == 'Today\'s' ? ' AND EmailMessage.MessageDate= TODAY ' : FilterText == 'Upcoming' ? ' AND EmailMessage.MessageDate > TODAY ' : '';
        
        if (!String.isBlank(whereClause)) {
            emailQuery = emailQuery + whereClauseRel;
        }
        
        system.debug('emailQuery...'+emailQuery);
        for (EmailMessageRelation emrel: Database.Query(emailQuery)) {
            
            emailRelIds.add(emrel.EmailMessageId);
        }
        system.debug('emailRelIds...'+emailRelIds.size());
        // }
        // HtmlBody, TextBody
        for (EmailMessage emailMsg: [SELECT ActivityId,ToAddress,CcAddress,BccAddress, FromAddress, Id, MessageDate FROM EmailMessage WHERE (ActivityId =: mapTask.keySet() OR Id =: emailRelIds) and Exclude_From_Activity_List__c=false ORDER BY createddate Desc limit 2000]) {
            String[] contactEmail = new List<String>();
            if(emailMsg != null && emailMsg.toAddress!= null) contactEmail = emailMsg.toAddress.split(';');
            if(emailMsg != null && emailMsg.CcAddress!= null) contactEmail.addAll(emailMsg.CcAddress.split(';'));
            if(emailMsg != null && emailMsg.BccAddress!= null) contactEmail.addAll(emailMsg.BccAddress.split(';'));
            if (emailMsg != null && emailMsg.FromAddress != null) contactEmails.add(emailMsg.FromAddress.toLowerCase());
            for (String email: contactEmail) {
                contactEmails.add(email.toLowerCase().trim());
            }
        }
        Map<string, Contact> mapPrimaryContact = new Map<string, Contact> ();
        system.debug('contactEmails....'+contactEmails);
        if (contactEmails != null && contactEmails.size() > 0) {
            for (Contact cont: [select id, Email, name from contact where email in: contactEmails]) {
                
                system.debug(cont.Email.toLowerCase()+'cont....'+cont);
                
                mapPrimaryContact.put(cont.Email.toLowerCase(), cont);
            }
        }
        
        for (EmailMessage emailMsg: [SELECT ActivityId, HtmlBody, subject, TextBody, ToAddress,CcAddress,BccAddress, FromAddress, Id, MessageDate FROM EmailMessage WHERE (ActivityId =: mapTask.keySet() OR Id =: emailRelIds) and Exclude_From_Activity_List__c=false ORDER BY createddate Desc]) {
            system.debug('CreateActivityFromActivityHistory....');
            if (processedIds == null || !processedIds.contains(emailMsg.Id)) {
                processedIds.add(emailMsg.Id);
                mapActivityWithEmail.put(emailMsg.ActivityId, emailMsg.Id);
                if (emailMsg.TextBody != '' && mapActivityHistory != null && mapActivityHistory.get(emailMsg.ActivityId) != null && !processedIds.contains(emailMsg.ActivityId)) {
                    
                    HL_Activity a;  mapActivityWithEmailDesc.put(emailMsg.ActivityId, emailMsg.TextBody);
                    Task t = mapTask.get(emailMsg.ActivityId);
                    system.debug('CreateActivityFromActivityHistory....');
                    a = this.CreateActivityFromActivityHistory(emailMsg, t, mapActivityHistory, mapActivityWithEmailDesc, mapPrimaryContact);
                    if(a.Activity.Type<>null && a.Activity.Type==selectedTypevalue) aList.Add(a);
                    else
                        aList.Add(a);
                    
                    TotalRecords++;
                    system.debug('CreateActivityFromActivityHistoryeee ....');
                    processedIds.add(emailMsg.ActivityId);
                }
                if (emailMsg.TextBody != '' && mapOpenActivity != null && mapOpenActivity.get(emailMsg.ActivityId) != null && !processedIds.contains(emailMsg.ActivityId)) {
                    
                    HL_Activity a;  mapActivityWithEmailDesc.put(emailMsg.ActivityId, emailMsg.TextBody);
                    Task t = mapTask.get(emailMsg.ActivityId);
                    system.debug('CreateActivityFromActivityHistory....');
                    a = this.CreateActivityFromOpenActivity(emailMsg, t, mapOpenActivity, mapActivityWithEmailDesc, mapPrimaryContact);
                    
                    if(a.Activity.Type<>null && a.Activity.Type==selectedTypevalue) aList.Add(a);
                    else
                        aList.Add(a);  TotalRecords++;
                    system.debug('CreateActivityFromActivityHistoryeee ....');
                    processedIds.add(emailMsg.ActivityId);
                }
                if (emailMsg.ActivityId == null || (emailMsg.ActivityId != null && mapActivityHistory != null && mapActivityHistory.get(emailMsg.ActivityId) == null && !processedIds.contains(emailMsg.ActivityId)) || (emailMsg.ActivityId != null && mapOpenActivity != null && mapOpenActivity.get(emailMsg.ActivityId) == null && !processedIds.contains(emailMsg.ActivityId))) {
                    
                    HL_Activity a; a = this.CreateActivityFromEmailMessage(emailMsg, mapPrimaryContact);
                    if(a.Activity.Type<>null && a.Activity.Type==selectedTypevalue) aList.Add(a);
                    else
                        aList.Add(a);
                    
                    //aList.Add(a);
                    if (emailMsg.ActivityId != null) processedIds.add(emailMsg.ActivityId);
                    TotalRecords++;
                }
            }
        }
        system.debug('aList....uuuu' + aList.size());
        for (task eachtask: mapTask.values()) {
            
            if (processedIds == null || !processedIds.contains(eachtask.Id)) {
                HL_Activity a;
                a = this.CreateActivityFromTask(eachtask);
                if(a.Activity.Type<>null && a.Activity.Type==selectedTypevalue)
                    aList.Add(a);
                else
                    aList.Add(a);
                
                TotalRecords++;
            }
            
        }
        if(aList.size()>0){
            aListRecords.AddAll(aList);
        }
        system.debug('task.............' + aList.size());
        system.debug('eventList.............' + eventList.size());
        for (Event e: eventList) {
            HL_Activity a;
            a = this.CreateActivityFromEvent(UserContactRecord.Id,c,userId , e, primaryAttendeeMap, eventToHLAttendeeMap.get(e.ParentId__c), null);
            if(a.Activity.Type<>null && a.Activity.Type==selectedTypevalue)
                aListRecords.Add(a);
            else
                aListRecords.Add(a);
        }
        system.debug('===aList===' + aListRecords.size());
        if (aListRecords != null && aListRecords.size() > 0) {
            TotalRecords = aListRecords.size();
            if (EndIndex > aListRecords.size())
                EndIndex = aListRecords.size();
            
            system.debug('===StartIndex===' + StartIndex);
            system.debug('===EndIndex===' + EndIndex);
            for (Integer ii = StartIndex; ii<EndIndex; ii++) {
                Activities.add(aListRecords[ii]);
            }
            Activities.sort();
        }
        
        system.debug('===Activities===' + Activities.size());
        //Calculate total pages
        Decimal pages = Decimal.valueOf(TotalRecords);
        pages = pages.divide(Decimal.valueOf(pageSize), 2);
        TotalPages = (Integer) pages.round(System.RoundingMode.CEILING);
        system.debug(pages + 'pages ............491' + TotalPages);
        //Adjust the Start Index
        StartIndex++;
        
        //Adjust End Index
        if (EndIndex > TotalRecords)
            EndIndex = TotalRecords;
        //return null;
    }
    public string selectedTypevalue {get;set;}
    public List<SelectOption> getTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('-None-','-None-'));
        options.add(new SelectOption('','All'));
        options.add(new SelectOption('Email','Email'));
        options.add(new SelectOption('Call','Call'));
        options.add(new SelectOption('Meeting','Meeting'));
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Internal','Internal'));
        options.add(new SelectOption('Platinum','Platinum'));
        return options;
    }
    
    public PageReference redirectToContact() {  
        string cuser= HL_PageUtility.GetParameter('id');
        system.debug('==EntityId==='+EntityId);
        if(cuser.LEFT(3)=='005'){
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            PageReference myVFPage = new PageReference(baseUrl+'/home/home.jsp');
            myVFPage.setRedirect(true);
            return myVFPage;
        } else{
            PageReference myVFPage = new PageReference('/apex/HL_ContactView');
            myVFPage.setRedirect(true);
            myVFPage.getParameters().put('id', EntityId);
            return myVFPage;
        }
    }
    
    public List<SelectOption> getTypedropdownList() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('-None-','-None-'));
        options.add(new SelectOption('','All'));
        options.add(new SelectOption('Email','Email'));
        options.add(new SelectOption('Call','Call'));
        options.add(new SelectOption('Meeting','Meeting'));
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Internal','Internal'));
        options.add(new SelectOption('Platinum','Platinum'));
        return options;
    }
}