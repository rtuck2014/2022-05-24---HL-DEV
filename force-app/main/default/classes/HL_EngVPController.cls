/***********************************************
*  Name : HL_EngVPController 
*  Purpose: To override fucntionality of Eng VP object
*  Test Class : Test_HL_EngVPController
*********************************************/
public class HL_EngVPController {
    public id EngId{get;set;}
    public String Engname {get; set;}
    private Id vpId;
    public boolean IshavingValidRoleForRevAccrual {get; set;}      
    Public Eng_VP__c  EngVP {get;set;}
    Public Eng_VP__c  EngVPView {get;set;}
    Public Integer NoOfPosition{get;set;}  
    Public Boolean IsSuperVisorOrAdmin{get;set;} 
    Public Boolean IsHavingPVPermissionSetOrIsSysAdmin{get;set;} 
    public List<RelatedPositionClass> RelatedPositionList {get; set;}
    private Valuation_Period__mdt EngVPCustomMetaData;
    public Integer CurPageSize {get; set;}
    private ApexPages.StandardSetController Std_Set_controller;
    public Set<ID> CurSelIDsSet = new Set<Id>();
    Public  boolean isError{get;set;}
    private list<Eng_VP_Position__c> filteredPositionList;
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    public  String SelectedRecId {get; set;}
    public  Boolean IsCheckAll {get; set;}
    Public Integer SelectedInProgressItem{get;set;}
    Public List<String> SelectedInPgItemList {get;set;}
    Public Eng_VP__c  OriginalEngVPView;
    public String fieldAPI{get;set;}  
    private string tempName;
    public String reportFeeSelected {get; set;} 
    public List<Eng_VP_Position__c> posList{get;set;}
    public List<Eng_VP_Position__c> positionToDisplayInPopup{get;set;}
    public Boolean IsMemberofAPTeam{get;set;}
    public boolean showPopup {get;set;}
    public Integer NoOfInProgressItems{get;set;}
    
    public String userProfileName {
        get {
            return [
                select Profile.Name
                from User
                where Id = :Userinfo.getUserId() 
            ].Profile.Name;
        }
    }
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    } 
    
    public HL_EngVPController(ApexPages.StandardController controller) {
        positionToDisplayInPopup = new list<Eng_VP_Position__c>();
        vpId = ApexPages.currentPage().getParameters().get('id');
        EngId= ApexPages.currentPage().getParameters().get('EngId'); 
        SelectedInProgressItem = 0;
        //SelectedInPgItemList = new list<String>();
        // Case of opening New VP from VP List
        tempName = '';
        showPopup = false;
        if(engId != null){
            for(Engagement__c Eng : [select Name From Engagement__c WHERE id =: EngId]){
                Engname = Eng.Name ;          
            }
            Eng_VP__c  EngVP = new Eng_VP__c ();
            EngVP = (Eng_VP__c)controller.getRecord();
            EngVP.Engagement__c  = EngId;  
            EngVP.Overall_VP_Status__c= 'New';  
        }                      
        NoOfPosition  = 0;
        filteredPositionList = new list<Eng_VP_Position__c>(); 
        OriginalEngVPView = new Eng_VP__c();       
        // Case to view existing VP       
        if(vpId != null){
            /*for(Eng_VP__c EngVP1 : [select id,Name,Frequency__c,Summary__c,ClientStartDate__c,Invoices__c,Month_Quarter__c,Valuation_Date__c,Engagement__c, currencyIsoCode,Fee_Total__c,Total_Fee_Completed__c,Engagement__r.Client__c, Fee_Notes_Description__c, 
                                    (Select id, Name, Company__r.Name ,Completed_Date__c,Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c,Fee_Approval_Date__c  
                                     from Eng_VP_Positions__r order by Completed_Date__c DESC NULLS LAST) From Eng_VP__c WHERE id =: vpId]){
                                         OriginalEngVPView = EngVP1;
                                         EngId = EngVP1.Engagement__c; 
                                         EngVPView  = new Eng_VP__c ();
                                         EngVPView  = (Eng_VP__c)controller.getRecord(); 
                                         EngVPView =  EngVP1;
                                         NoOfPosition = EngVP1.Eng_VP_Positions__r.size();
                                         filteredPositionList.addAll(EngVP1.Eng_VP_Positions__r); 
                                         for(Eng_VP_Position__c p: EngVP1.Eng_VP_Positions__r)
                                         {                  
                                             if(p.status__c == 'In Progress')
                                                 SelectedInPgItemList.add(p.id); 
                                         }            
                                     }*/
            EngVPView = [select id,Name,Frequency__c,Summary__c,ClientStartDate__c,Invoices__c,Month_Quarter__c,Valuation_Date__c,Engagement__c, currencyIsoCode,Fee_Total__c,Total_Fee_Completed__c,Engagement__r.Client__c, Fee_Notes_Description__c FROM Eng_VP__c WHERE Id=:vpId];
            EngId=EngVPView.Engagement__c;
            filteredPositionList = [Select id, Name, Company__r.Name ,Completed_Date__c,Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c,Fee_Approval_Date__c
                                     from Eng_VP_Position__c WHERE Engagement_VP__c = :vpId order by Completed_Date__c DESC NULLS LAST];
            NoOfPosition = filteredPositionList.size();
            CurSelIDsSet = new Set<ID>();
            EngVPCustomMetaData = new Valuation_Period__mdt();
            EngVPCustomMetaData = [SELECT id, Import_Position_Default_Page_Size__c, DefaultPageSizeForPositionList__c, VP_Page_Size_Options__c, Position_Page_Size_Options__c 
                                   FROM Valuation_Period__mdt
                                   WHERE DeveloperName = 'EngVP'];
            NoOfInProgressItems=0;
            for(Eng_VP_Position__c eVp : filteredPositionList){
                if(String.isNotBlank(eVp.Status__c) && eVp.Status__c=='In Progress'){
                    NoOfInProgressItems++;
                }
            }
            CurPageSize = 10;
            if(EngVPCustomMetaData.DefaultPageSizeForPositionList__c != null)
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.DefaultPageSizeForPositionList__c);
            InitializaList();
        }            
        IshavingValidRoleForRevAccrual = HL_ConstantsUtil.IshavingValidRoleInInternTeamEng(EngId);
        IsSuperVisorOrAdmin = HL_ConstantsUtil.IsSupervisorOrAdmin();        
        IsHavingPVPermissionSetOrIsSysAdmin = HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin();  
        IsCheckAll = false;
        
        // for history tracking related list
        for(PV_HistoryTracking_VisibilitySetting__mdt PVSetting : [Select User_Id__c From PV_HistoryTracking_VisibilitySetting__mdt]){
            if(PVSetting.User_Id__c.length()>= 15 && PVSetting.User_Id__c.substring(0,15) == userInfo.getUserId().substring(0,15))
            {   
                IsMemberofAPTeam = true;
                break;
            }
        }
    }
    
    //Constructor for 'UpdateAutomationFromPeriodView_Page' page
    public HL_EngVPController() {
        posList = new List<Eng_VP_Position__c>();
        for(Eng_VP_Position__c vppId : [SELECT id,Automation_Tool_Utilized__c,Reason__c,Comments__c,Name 
                                        FROM Eng_VP_Position__c 
                                        WHERE Engagement_VP__c=:ApexPages.currentPage().getParameters().get('id') AND Status__c ='In Progress' AND Engagement_VP__r.Overall_VP_Status__c <> 'Completed'
                                        ORDER BY Automation_Tool_Utilized__c ]){
                                            //WHERE Engagement_VP__c=:ApexPages.currentPage().getParameters().get('id') AND Status__c ='In Progress']){
                                            posList.add(vppId); 
                                        }   
    }
    
    /*public Integer NoOfInProgressItems{
        get
        {
            Integer tempCount = 0;
            if(vpId != null){                        
                for(Eng_VP__c EngVP1 : [select id,(Select id from Eng_VP_Positions__r Where Status__c = 'In Progress'  limit 1) From Eng_VP__c WHERE id =: vpId]){
                    tempCount  = EngVP1.Eng_VP_Positions__r .size();                
                    
                }
            }            
            return tempCount ;
        }      
    }
	*/
    public void InitializaList()
    {        
        filteredPositionList = New List<Eng_VP_Position__c>();
        if(vpId != null){            
            /*for(Eng_VP__c EngVP1 : [select id,Name,Summary__c,ClientStartDate__c,Invoices__c,Valuation_Date__c, Frequency__c ,Month_Quarter__c ,Engagement__c, currencyIsoCode,Fee_Total__c,Total_Fee_Completed__c,Fee_Notes_Description__c, 
                                    (Select id, Name, Company__r.Name ,Completed_Date__c,Fee_Completed__c, Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c,Company_Sector__c,Fee_Approval_Date__c  
                                     from Eng_VP_Positions__r Order by Completed_Date__c DESC NULLS LAST) 
                                    From Eng_VP__c WHERE id =: vpId]){
                                        filteredPositionList.addAll(EngVP1.Eng_VP_Positions__r);
                                        EngVPView = EngVP1 ;
                                        NoOfPosition = EngVP1.Eng_VP_Positions__r.size();
                                    }*/
            EngVPView = [select id,Name,Summary__c,ClientStartDate__c,Invoices__c,Valuation_Date__c, Frequency__c ,Month_Quarter__c ,Engagement__c, currencyIsoCode,Fee_Total__c,Total_Fee_Completed__c,Fee_Notes_Description__c FROM Eng_VP__c WHERE Id=:vpId];
            filteredPositionList = new List<Eng_VP_Position__c>([SELECT id, Name, Company__r.Name ,Completed_Date__c,Fee_Completed__c, Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c,Company_Sector__c,Fee_Approval_Date__c 
                                        						FROM Eng_VP_Position__c 
                												WHERE Engagement_VP__c=:vpId
                                                       			ORDER BY Completed_Date__c DESC NULLS LAST]);
            NoOfPosition = filteredPositionList.size();
        }
        
        Std_Set_controller = new ApexPages.StandardSetController(filteredPositionList); 
        RelatedPositionList = new List<RelatedPositionClass>();                 
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize);             
        fetchRelatedData();
    }
    public void ViewData() {
        //build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        system.debug('sortFullExp ...'+sortFullExp);
        //query the database based on the sort expression
        RelatedPositionList = new List<RelatedPositionClass>();
        String Query ='Select id, Name, Company__r.Name ,Completed_Date__c,Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c,Fee_Approval_Date__c  from Eng_VP_Position__c WHERE Engagement_VP__c'+ '=\''+vpId +'\'' +' order by '+sortFullExp + ' NULLS LAST';
        system.debug('query ...'+Query );
        for(Eng_VP_Position__c engVPpos : database.query(Query )){            
            RelatedPositionList.add(new RelatedPositionClass(CurSelIDsSet.contains(engVPpos.ID), engVPpos));
        }
        
        system.debug('RelatedPositionList....'+RelatedPositionList);
        
    }
    public PageReference ImportPosition() {
        string url = '/apex/HL_EngAddPositions?srcId='+ vpId + '&srcParentId=' +EngId;                        
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;        
    }
    public PageReference Backtovp() {
        string url = '/apex/HL_Related_PortfolioValuations?id=' + EngId + '&relatedObjType=EngVP';                        
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;        
    } 
    public PageReference DeleteRecord() { 
        Try{      
            
            if(EngVPView != null)
                delete EngVPView;            
        }catch(Exception e)
        {
            ApexPages.addmessages(e);
            return null;
        }                      
        return Backtovp();   
    }
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    
    // Wrapper Class to ploat Position table on Screen
    public Class RelatedPositionClass {
        public boolean isSelected {get; set;}
        public Eng_VP_Position__c EngVPPositionRecord {get; set;}
        
        public RelatedPositionClass(Boolean isChecked, Eng_VP_Position__c relatedPositionData)
        {
            EngVPPositionRecord = relatedPositionData;
            isSelected = isChecked;
        }
    }
    
    // returns the first page of records 
    public void first()
    {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.first();
            fetchRelatedData();
        }
    }
    
    // returns the last page of records 
    public void last()
    {
        if(Std_Set_controller != null)
        {   
            refreshSelIDs();
            Std_Set_controller.last();
            fetchRelatedData();
        }
    }
    
    //returns the previous page of records 
    public void previous() {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.previous();
            fetchRelatedData();
        }
    }
    
    // returns the next page of records 
    public void next() {        
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.next();
            fetchRelatedData();
        }
    }
    
    public PageReference NewPosition()
    {
        return new PageReference('/apex/HL_EngValuationPeriodPositionNew?VPId='+vpId+'&retURL=/'+vpId);
    }
    
    // To update Position in mass
    public PageReference updatePosition()
    {
        return new PageReference('/apex/UpdateAutomationFromPeriodView_Page?Id='+vpId+'&retURL=/'+vpId);
    }
    
    // returns the page number of the current page set 
    @TestVisible public Integer pageNumber {
        get {
            if(Std_Set_controller == null) return null;
            return Std_Set_controller.getPageNumber();
        }
    }
    @TestVisible public Integer pageSize {
        get {
            if(Std_Set_controller == null) return 0;
            Integer prefix = (Math.mod((Long)Std_Set_controller.getResultSize(),(Long)Std_Set_controller.getPageSize()) != 0)? 1 : 0;
            return  (Std_Set_controller.getResultSize() / Std_Set_controller.getPageSize())+prefix;
        }
    }    
    private void fetchRelatedData() {               
        RelatedPositionList = new List<RelatedPositionClass>();     
        if(Std_Set_controller != null)
            for(Eng_VP_Position__c engVPpos : (List<Eng_VP_Position__c>)Std_Set_controller.getRecords())            
            RelatedPositionList.add(new RelatedPositionClass(CurSelIDsSet.contains(engVPpos.ID), engVPpos));                       
    }
    Public PageReference GenerateAccrual(){
        showPopup = true; 
        positionToDisplayInPopup = new list<Eng_VP_Position__c>();   
        try{
            if(SelectedInProgressItem < NoOfInProgressItems && IsCheckAll)
                IsCheckAll = false;
            refreshSelIDs(); 
            id RelatedEngVPId;
            if(CurSelIDsSet.size() == 0 && !IsCheckAll){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,Label.HL_NoPositionSelected));
                isError = true; 
                showPopup = false;                    
            }
            else if(CurSelIDsSet.size() > 0 || IsCheckAll)
            {
                List<Eng_VP_Position__c> listOfEngPosFiltered = new List<Eng_VP_Position__c>();
                List<Id> listOfEngPosIDFiltered = new List<ID>();
                List<Eng_VP_Position__c> listOfEngPosToUpdate = new List<Eng_VP_Position__c>();
                
                if(IsCheckAll)
                {
                    for(Eng_VP_Position__c engVpPos : [Select id,Status__c,Name,Engagement_VP__c From Eng_VP_Position__c Where Engagement_VP__c =:vpId AND Status__c = 'In Progress' ORDER BY Name ASC])
                    {
                        listOfEngPosFiltered.add(engVpPos); 
                        listOfEngPosIDFiltered.add(engVpPos.id);
                    }                                     
                }    
                else
                {
                    for(Eng_VP_Position__c engVpPos : [Select id,Status__c,Name,Engagement_VP__c From Eng_VP_Position__c Where Id IN: CurSelIDsSet AND Status__c = 'In Progress' ORDER BY Name ASC])
                    {
                        listOfEngPosFiltered.add(engVpPos); 
                        listOfEngPosIDFiltered.add(engVpPos.id);
                    }   
                }  
                if(listOfEngPosFiltered.size() > 0){
                    //positionToDisplayInPopup.addAll(selectedPositionsOnPopup(listOfEngPosIDFiltered));
                    positionToDisplayInPopup.addAll(listOfEngPosFiltered);
                }
            }                       
            
        }catch(Exception e)
        {
            isError = true;           
            Apexpages.addMessages(e);           
        }
        return null;
    }
    
    // DMND0023397(Staffing/Automation Reminders before Accrual)- To find position which don't have all 4 required roles in TeamMember.
    // It returns list of Eng VP Positions which don't have all 4 required roles in their TeamMember.
    /* public List<Eng_VP_Position__c> selectedPositionsOnPopup(List<Id> selectedPositions) {

Map<Id, Set<String>> mapOfPositionWithRole = new Map<Id, Set<String>>();
Set<String> RoleOfTeamMembersSet = new Set<String>{'Analyst', 'Associate', 'Manager', 'Principal'};
List<Eng_VP_Position__c> allPosition = new List<Eng_VP_Position__c>();
List<Eng_VP_Position__c> PositionWithoutRoleOrATU = new List<Eng_VP_Position__c>();

for(Eng_VP_Position__c EVPP: [SELECT id,Name,Automation_Tool_Utilized__c,(SELECT id,Role__c,Team_Member_Status__c FROM Eng_VP_TeamMembers__r) FROM Eng_VP_Position__c WHERE Id IN:selectedPositions ORDER BY Name ASC]){
if(EVPP.Eng_VP_TeamMembers__r == null || (EVPP.Eng_VP_TeamMembers__r).size() == 0){
mapOfPositionWithRole.put(EVPP.id, new Set<String> {'No TeamMember'});
}
for(Eng_VP_TeamMember__c EVPTM : EVPP.Eng_VP_TeamMembers__r){
if(mapOfPositionWithRole.containsKey(EVPP.id)){
Set<String> RoleSet = mapOfPositionWithRole.get(EVPP.id);
if(EVPTM.Team_Member_Status__c == 'Inactive'){
RoleSet.add('Inactive TeamMember');
} else {
RoleSet.add(EVPTM.Role__c);
}
mapOfPositionWithRole.put(EVPP.id,RoleSet);
} else {
if(EVPTM.Team_Member_Status__c == 'Inactive'){
mapOfPositionWithRole.put(EVPP.id, new Set<String> {'Inactive TeamMember'});
} else {
mapOfPositionWithRole.put(EVPP.id, new Set<String> {EVPTM.Role__c});
}
}
}
allPosition.add(EVPP);
}
if(mapOfPositionWithRole.size() > 0){

for(Eng_VP_Position__c filteredEVPP : allPosition){

if(mapOfPositionWithRole.containsKey(filteredEVPP.id) && (!mapOfPositionWithRole.get(filteredEVPP.id).containsAll(RoleOfTeamMembersSet))){
PositionWithoutRoleOrATU.add(filteredEVPP);
}
}
}
return PositionWithoutRoleOrATU;
} */
    
    Public PageReference GenerateAccrualFinal(){
        showPopup = false; 
        
        try{
            if(SelectedInProgressItem < NoOfInProgressItems && IsCheckAll)
                IsCheckAll = false;
            refreshSelIDs(); 
            Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
            MRPC = HL_Eng_VP_PositionTriggerHelper.fetchMRPC();
            if(MRPC == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.HL_MRPC_Not_Exists));
                isError = true;                
            }
            else {
                id RelatedEngVPId;
                if(CurSelIDsSet.size() == 0 && !IsCheckAll){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,Label.HL_NoPositionSelected));
                    isError = true;                    
                }
                else if(CurSelIDsSet.size() > 0 || IsCheckAll){
                    List<Eng_VP_Position__c> listOfEngPosFiltered = new List<Eng_VP_Position__c>();
                    List<Eng_VP_Position__c> listOfEngPosToUpdate = new List<Eng_VP_Position__c>();
                    
                    if(IsCheckAll)
                    {
                        for(Eng_VP_Position__c engVpPos : [Select id,Status__c,Engagement_VP__c From Eng_VP_Position__c Where Engagement_VP__c =:vpId AND Status__c = 'In Progress' ])
                        {
                            listOfEngPosFiltered .add(engVpPos); 
                        }                                     
                    }    
                    else
                    {
                        for(Eng_VP_Position__c engVpPos : [Select id,Status__c,Engagement_VP__c From Eng_VP_Position__c Where Id IN: CurSelIDsSet AND Status__c = 'In Progress' ])
                        {
                            listOfEngPosFiltered .add(engVpPos); 
                        }   
                    }  
                    if(listOfEngPosFiltered.size() > 0)
                        positionToDisplayInPopup.addAll(listOfEngPosFiltered);
                    
                    for(Eng_VP_Position__c engVpPos : listOfEngPosFiltered )
                    {
                        
                        if(engVpPos.status__c == System.Label.HL_Status_In_Progress)
                        {
                            engVpPos.status__c = System.Label.HL_Eng_VP_Status_Completed;
                            engVpPos.Revenue_Year__c    = MRPC.Current_Year__c;
                            engVpPos.Revenue_Month__c   = MRPC.Current_Month__c;
                            engVpPos.Completed_Date__c  = system.now();
                            engVpPos.Fee_Completed__c = engVpPos.Report_Fee__c;
                            engVpPos.Cancel_Month__c  = '';
                            engVpPos.Cancel_Year__c  = '';
                            engVpPos.Cancel_Date__c  = null;
                            listOfEngPosToUpdate.add(engVpPos);
                        }
                    }
                    
                    if(listOfEngPosToUpdate.size() > 0) 
                        update listOfEngPosToUpdate; 
                }                       
            }
            ResetSelection();
            InitializaList(); 
            IsCheckAll = false;
        }catch(Exception e)
        {
            isError = true; 
            showPopup = false;           
            Apexpages.addMessages(e);           
        }
        return null;
    }
    
    public Pagereference EditRecord() {
        PageReference pg = new PageReference('/'+SelectedRecId+'/e'+'?retURL=/'+vpId);
        return pg;
    }
    
    public pagereference DeleteSelectedRecord() {
        try{ 
            
            for(Eng_VP_Position__c  EngVPPostTodelete : [Select id From Eng_VP_Position__c Where Id =:SelectedRecId])
                Delete EngVPPostTodelete ;
            if(EngVPCustomMetaData.DefaultPageSizeForPositionList__c != null)
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.DefaultPageSizeForPositionList__c);
            InitializaList();
            ResetSelection();
            isCheckAll = false;    
        }
        catch (Exception e){                
            ResetSelection();
            isCheckAll = false;    
            Apexpages.addMessages(e);           
        }  
        return null;   
    }   
    private void refreshSelIDs()
    {
        
        if(RelatedPositionList != null && RelatedPositionList.size()>0)
        {
            for(RelatedPositionClass rlPosdata :RelatedPositionList)
            {
                if(rlPosdata.EngVPPositionRecord != null)
                {
                    if(rlPosdata.isSelected){
                        CurSelIDsSet.add(rlPosdata.EngVPPositionRecord.ID);
                    }
                    else 
                    {    
                        CurSelIDsSet.remove(rlPosdata.EngVPPositionRecord.ID);
                    }
                }
            }
        }           
    }  
    
    private void ResetSelection()
    {           
        if(RelatedPositionList != null && RelatedPositionList.size()>0)
        {  
            for(RelatedPositionClass rlPosdata :RelatedPositionList)
            {      
                if(rlPosdata.EngVPPositionRecord != null)
                {    
                    //system.assertEquals(rlPosdata.EngVPPositionRecord.Name,null);
                    //if(rlPosdata.isSelected){                                  
                    rlPosdata.isSelected = false; 
                    CurSelIDsSet.clear();
                    //}
                    
                }
            }
        }           
    }  
    
    public void showMore()
    {
        CurPageSize = NoOfPosition; 
        InitializaList(); 
        //ResetSelection();
        //isCheckAll = false;             
        
    }
    public PageReference saveRc()
    {
        try{            
            if((EngVPView.Name == null || EngVPView.Name == '') && tempName != '' && tempName != null)
                EngVPView.Name = tempName;
            update EngVPView;
        }catch(Exception e )
        {
            ApexPages.addMessages(e);
            return null;
        }
        return new pageReference('/'+EngVPView.Id);
    }
    // method to reset Inline Editing Values
    public PageReference DummyReset(){
        if(fieldAPI == 'Name'){
            EngVPView.Name = OriginalEngVPView.Name;
            tempName = EngVPView.Name;
        }
        else if(fieldAPI == 'Frequency__c' || fieldAPI == 'Month_Quarter__c'){
            EngVPView.Frequency__c = OriginalEngVPView.Frequency__c;
            EngVPView.Month_Quarter__c= OriginalEngVPView.Month_Quarter__c;        
        }
        else if(fieldAPI == 'Summary__c')
            EngVPView.Summary__c= OriginalEngVPView.Summary__c;               
        else if(fieldAPI == 'Valuation_Date__c')
            EngVPView.Valuation_Date__c= OriginalEngVPView.Valuation_Date__c;  
        
        return null;
    }
    
    public List<SelectOption> getReportFeeOption() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('TotalReportFee','Total Report Fee')); 
        options.add(new SelectOption('IndividualReportFee','Individual Report Fee'));
        return options; 
    }
    
    public PageReference reportFeeRedirect() {
        if(reportFeeSelected == null || reportFeeSelected =='')
            return null;
        return new PageReference('/apex/HL_SendEmail?retURL='+vpId+'&template=Billing_Request_VP&ro='+vpId+'&evpp='+vpId+'&reportFeeType='+reportFeeSelected);
    }
    
    public PageReference CancelIt(){
        showPopup = false;
        ischeckAll = false;
        ResetSelection();
        return null;
    } 
}