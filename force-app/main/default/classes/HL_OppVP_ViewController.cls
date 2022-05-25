/***********************************************
*  Name : HL_OppVP_ViewController 
*  Purpose: To override functionality of Opp VP object
*  Test Class : Test_HL_Opp_VP_TriggerHelper
*********************************************/
public class HL_OppVP_ViewController {
    
    //This parameter is determining for Opportunity conversion status or for status of Request  Opportunity Number on opportunity 
    public Boolean isOpportunityConverted {get;set;}
    public id OppId{get;set;}
    public String Oppname {get; set;}
    private Id vpId;
    public boolean IshavingValidRoleForRevAccrual {get; set;}      
    Public Opp_VP__c  OppVPView{get;set;}
    Public Opp_VP__c  OppVpNew;
    Public Integer NoOfPosition{get;set;} 
    Public Boolean IsHavingPVPermissionSetOrIsSysAdmin{get;set;} 
    public List<RelatedPositionClass> RelatedPositionList {get; set;}
    private Valuation_Period__mdt OppVPCustomMetaData;
    public Integer CurPageSize {get; set;}
    private ApexPages.StandardSetController Std_Set_controller;
    public Set<ID> CurSelIDsSet = new Set<ID>();
    Public  boolean isError{get;set;}
    private list<Opp_VP_Position__c> filteredPositionList;
    public  String SelectedRecId {get; set;}
    Public  boolean IsSuperVisorOrAdmin {get;set;}
    public  Boolean IsCheckAll {get; set;}
    Public Integer SelectedInProgressItem{get;set;}
    Public Opp_VP__c  OriginalOppVPView;
    public String fieldAPI{get;set;} 
    public Boolean IsMemberofAPTeam{get;set;} 
    private string tempName;        
    public String userProfileName {
        get {
            return [
                    select Profile.Name
                    from User
                    where Id = :Userinfo.getUserId() 
                    ].Profile.Name;
        }
    }
    public HL_OppVP_ViewController(ApexPages.StandardController controller) {
        vpId = ApexPages.currentPage().getParameters().get('id');   
        OppId= ApexPages.currentPage().getParameters().get('OppId');  
        String OppVpId ;       
        isOpportunityConverted  = false;
        tempName = '';
        // Case: Creating New VP from VP List
        if(OppId != null){
            for(Opportunity__c Opp : [select Name From Opportunity__c WHERE id =: OppId]){
              Oppname = Opp.Name ;          
            }       
            OppVpNew = new Opp_VP__c ();
            OppVpNew = (Opp_VP__c)controller.getRecord();
            OppVpNew.Opportunity__c  = OppId;        
            OppVpNew.Overall_VP_Status__c= 'New';        
        }
        NoOfPosition  = 0;
        filteredPositionList = new list<Opp_VP_Position__c>();     
        // Case : To view VP 
        if(vpId != null){
            OriginalOppVPView = new Opp_VP__c();   
                                    
            for(Opp_VP__c OppVP1 : [select id,Name,Frequency__c,Summary__c,Month_Quarter__c,Valuation_Date__c,Opportunity__r.Converted_to_Engagement__c , Opportunity__r.Approval_Process__c, Opportunity__r.Engagement_Approval_Status__c, Opportunity__c, currencyIsoCode,Fee_Total__c, (Select   id, Name, Company__r.Name ,Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c  from Opp_VP_Positions__r order by Name ASC) From Opp_VP__c WHERE id =: vpId])
            {
                OriginalOppVPView = OppVP1 ;
                OppId = OppVP1.Opportunity__c;  
                OppVpView = new Opp_VP__c ();
                OppVpView = (Opp_VP__c)controller.getRecord(); 
                OppVpView =  OppVP1;
                NoOfPosition  =  OppVP1.Opp_VP_Positions__r.size();
                filteredPositionList.addAll(OppVP1.Opp_VP_Positions__r);  
                isOpportunityConverted = OppVP1.Opportunity__r.Converted_to_Engagement__c;
                if(OppVP1.Opportunity__r.Approval_Process__c == label.HL_AppProcessForEngNo && OppVP1.Opportunity__r.Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
                    isOpportunityConverted = true; 
            }
            CurSelIDsSet = new Set<ID>();
            SelectedInProgressItem = 0;
            OppVPCustomMetaData = new Valuation_Period__mdt();
            OppVPCustomMetaData = [SELECT id, Import_Position_Default_Page_Size__c, DefaultPageSizeForPositionList__c, VP_Page_Size_Options__c, Position_Page_Size_Options__c  FROM Valuation_Period__mdt WHERE DeveloperName = 'OppVP'];
            CurPageSize = 10;
            if(OppVPCustomMetaData.DefaultPageSizeForPositionList__c != null)
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.DefaultPageSizeForPositionList__c);                
            InitializaList();        
             
        }
        IsSuperVisorOrAdmin = HL_ConstantsUtil.IsSupervisorOrAdmin();    
        IshavingValidRoleForRevAccrual = HL_ConstantsUtil.IshavingValidRoleInInternTeamOpp(OppId); 
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
    
    public Integer NoOfInProgressItems{     
         get     
         {       
             Integer tempCount = 0;      
             if(vpId != null){                               
             for(Opp_VP__c OppVP1 : [select id,(Select id from Opp_VP_Positions__r Where Status__c = 'In Progress' ) From Opp_VP__c WHERE id =: vpId]){      
                 tempCount  = OppVP1.Opp_VP_Positions__r .size();                        
                 }       
             }                   
             return tempCount ;      
         }           
     }
    public void InitializaList()
    {
        filteredPositionList = New List<Opp_VP_Position__c>();
        if(vpId != null){  
                                    
            for(Opp_VP__c OppVP1 : [select id,Name,Frequency__c,Summary__c,Month_Quarter__c,Valuation_Date__c,Opportunity__c, currencyIsoCode,Fee_Total__c, (Select id, Name, Company__r.Name , Report_Fee__c, Asset_Classes__c, Company__c, Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c,Company_Sector__c  from Opp_VP_Positions__r Order by Name ASC ) From Opp_VP__c WHERE id =: vpId]){
                filteredPositionList.addAll(OppVP1.Opp_VP_Positions__r);
                OppVPView = OppVP1 ;
                NoOfPosition = OppVP1.Opp_VP_Positions__r.size();
            }
        }
        
        Std_Set_controller = new ApexPages.StandardSetController(filteredPositionList); 
        RelatedPositionList = new List<RelatedPositionClass>();                 
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize);             
        fetchRelatedData();
    }
    
    public PageReference ImportPosition() {
        string url = '/apex/HL_AddPositions?srcId='+ vpId + '&srcParentId=' +OppId;                        
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;        
    }
    public PageReference Backtovp() {
        string url = '/apex/HL_Related_PortfolioValuations?id=' + OppId + '&relatedObjType=OppVP'; 
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;        
    }
    public PageReference DeleteRecord() { 
        Try{          
            
            if(OppVpView != null)
                delete OppVpView;            
        }catch(Exception e){        
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
        public Opp_VP_Position__c OppVPPositionRecord {get; set;}
        
        public RelatedPositionClass(Boolean isChecked, Opp_VP_Position__c relatedPositionData)
        {
            OppVPPositionRecord = relatedPositionData;
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
        return new PageReference('/apex/HL_ValuationPeriodPositionNew?VPId='+vpId+'&retURL=/'+vpId);
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
        for(Opp_VP_Position__c OppVPpos : (List<Opp_VP_Position__c>)Std_Set_controller.getRecords())            
            RelatedPositionList.add(new RelatedPositionClass(CurSelIDsSet.contains(OppVPpos.ID), OppVPpos));                       
    }
        
    public Pagereference EditRecord() {
      PageReference pg = new PageReference('/'+SelectedRecId+'/e'+'?retURL=/'+vpId);
      return pg;
    }
    
    public pagereference DeleteSelectedRecord() {
        try{ 
            
            for(Opp_VP_Position__c  OppVPpostTodelete : [Select id From Opp_VP_Position__c Where Id =:SelectedRecId])
                Delete OppVPpostTodelete ;
            if(OppVPCustomMetaData.DefaultPageSizeForPositionList__c != null)
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.DefaultPageSizeForPositionList__c);
            InitializaList();
        }
        catch (Exception e){
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
                if(rlPosdata.OppVPPositionRecord != null)
                {
                    if(rlPosdata.isSelected){
                        CurSelIDsSet.add(rlPosdata.OppVPPositionRecord.ID);
                        SelectedInProgressItem++;
                    }
                    else {
                        CurSelIDsSet.remove(rlPosdata.OppVPPositionRecord.ID);
                        SelectedInProgressItem--;
                   }
                }
            }
        }           
    }
    
    public void showMore()      
    {       
            CurPageSize = NoOfPosition;             
            InitializaList();       
    }  
    public PageReference saveRc()
    {
        try{            
            if((OppVPView.Name == null || OppVPView.Name == '') && tempName != '' && tempName != null)
                OppVPView.Name = tempName;
            update OppVPView;
        }catch(Exception e )
        {
            ApexPages.addMessages(e);
            return null;
        }
        return new pageReference('/'+OppVPView.Id);
    }     
    
    public void DummyReset(){         
        
        if(fieldAPI == 'Name'){
            OppVPView.Name = OriginalOppVPView.Name;
            tempName = OppVPView.Name;
        }
        else if(fieldAPI == 'Frequency__c' || fieldAPI == 'Month_Quarter__c'){            
            OppVPView.Frequency__c = OriginalOppVPView.Frequency__c;
            OppVPView.Month_Quarter__c= OriginalOppVPView.Month_Quarter__c;        
        }
        else if(fieldAPI == 'Summary__c')
            OppVPView.Summary__c= OriginalOppVPView.Summary__c;            
        else if(fieldAPI == 'Valuation_Date__c')
            OppVPView.Valuation_Date__c= OriginalOppVPView.Valuation_Date__c;                 
    }      
}