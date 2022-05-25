/*********************************************************
* Author: Sandeep Singhal
* Created Date: 10th March 2017
* Purpose: To provide clon Position functionality to user 
*********************************************************/
public with sharing class HL_AddPositionsController {
    
    // Private properties
    private Id SourceId;       
    private Boolean IsPVSelected ;            
    private Id OpportunityId ;// {get;set;}
    public Boolean isValidPVUser{get;set;}
    //private Set<Id> ExistingCompanyIdSet; 
    private Set<String> ExistingCompanyAssetClsSet;
    private Valuation_Period__mdt OppVPCustomMetaData;
    private ApexPages.StandardSetController Std_Set_controller ;// {get; set;}    
    
    // Public properties
    public Id SelectedPVId {get; set;}
    public String SelectedImportOption {get; set;}
    public Integer CurPageSize {get; set;}
    public Integer CurPageNumber {get; set;}    
    public Set<ID> CurSelIDsSet = new Set<ID>();
    public List<SelectOption> PageSizeValues {get; set;}
    public List<RelatedDataClass> RelatedDataList {get; Set;}
    public List<RelatedPositionClass> RelatedPositionList {get; set;}
    public boolean isOnNextScreen {get;set;}
    
    public List<SelectOption> getImportOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(Label.HL_PositionWithoutTeamMember,Label.HL_PositionWithoutTeamMember)); 
        options.add(new SelectOption(Label.HL_PositionWithTeamMember,Label.HL_PositionWithTeamMember)); 
        return options; 
    }
    
    // Constructor 
    public HL_AddPositionsController() {
        RelatedDataList = new List<RelatedDataClass>();
        RelatedPositionList = new List<RelatedPositionClass>();
        //ExistingCompanyIdSet = new Set<Id>();
        ExistingCompanyAssetClsSet = new Set<String>();
        SourceId = Apexpages.currentpage().getparameters().get('srcId');
        OpportunityId = Apexpages.currentpage().getparameters().get('srcParentId');
        OppVPCustomMetaData = new Valuation_Period__mdt();
        OppVPCustomMetaData = [SELECT id, Import_Position_Default_Page_Size__c, Import_Position_Default_VP_Page_Size__c, VP_Page_Size_Options__c, Position_Page_Size_Options__c 
                               FROM Valuation_Period__mdt
                               WHERE DeveloperName = 'OppVP'];
        CurSelIDsSet = new Set<ID>();
        initStdSetController(); 
        SelectedImportOption = Label.HL_PositionWithTeamMember;     
        Opportunity__c Opp = new Opportunity__c();        
        Opp.id = OpportunityId;
        if(Opp != null && Opp.id != null )
            isValidPVUser = HL_OpportunityViewController.VerifyUserforVP(Opp, 'PVPositionCreation');         
    }     
        
    private void initStdSetController() {                
        IsPVSelected = false;
        PageSizeValues = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        if(OppVPCustomMetaData != null && OppVPCustomMetaData.VP_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(OppVPCustomMetaData.VP_Page_Size_Options__c).split(',');
        for(String pagesize : listofPageSize)
            PageSizeValues.add(new SelectOption(pagesize, pagesize));
        //CurSelIDsSet = new Set<ID>();
        List<Opp_VP__c> oppVPList = new List<Opp_VP__c>();
        for(Opp_VP__c oppVP :  [SELECT id, Name, (select Company__c,Asset_Classes__c  from Opp_VP_Positions__r ) 
                                FROM Opp_VP__c 
                                WHERE Opportunity__c =: OpportunityId ]) {
            If(oppVP.Id == SourceId) { 
                for(Opp_VP_Position__c position : oppVP.Opp_VP_Positions__r ) { 
                    //ExistingCompanyIdSet.add(position.Company__c);
                    ExistingCompanyAssetClsSet.add(position.Company__c+'_'+position.Asset_Classes__c);
                }
            }
            else {
                oppVPList.add(oppVP);
            }
        }
        Std_Set_controller = new ApexPages.StandardSetController(oppVPList); 
        IsPVSelected = false;
        CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize);        
        fetchRelatedData();        
    }
    
    private void fetchRelatedData() { 
        if(!IsPVSelected) { 
            //CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            RelatedDataList = new List<RelatedDataClass>();     
            if(Std_Set_controller != null)
            for(Opp_VP__c oppVP : (List<Opp_VP__c>)Std_Set_controller.getRecords()) {
                RelatedDataList.add(new RelatedDataClass(oppVP));
            }
        }
        else{
            //CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_Page_Size__c);
            RelatedPositionList = new List<RelatedPositionClass>();     
            if(Std_Set_controller != null)
            for(Opp_VP_Position__c oppVPpos : (List<Opp_VP_Position__c>)Std_Set_controller.getRecords())
                RelatedPositionList.add(new RelatedPositionClass(CurSelIDsSet.contains(oppVPpos.ID), oppVPpos));
        }       
    }
    private Map<Id,Opp_VP_Position__c > Old_New_PositionMap = new Map<Id,Opp_VP_Position__c>();
    public PageReference SavePositions() {
        Savepoint sp = Database.setSavepoint();
               
        try{            
            SaveChanges();
        }
        catch(Exception e) {
            Database.rollback( sp );            
            Apexpages.addMessages(e);
        }        
        return null;
    }
    
    public void SaveChanges() {
        
        // Purpose is to stop populating company Name in to VP Position Name while importing
        HL_ConstantsUtil.stopCopyingNameFromCompToPosition = true;
        refreshSelIDs();
        List<Opp_VP_Position__c> positionToInsertList = new List<Opp_VP_Position__c>(); 
        Map<String,Opp_VP_Position__c> CompanyIdwithPositionMap = new Map<String, Opp_VP_Position__c>();
        
        for(Opp_VP__c oppVP :  [SELECT id, Name, (select Company__c,Asset_Classes__c  from Opp_VP_Positions__r ) 
                                FROM Opp_VP__c 
                                WHERE Id =: SourceId]) {
             
                for(Opp_VP_Position__c position : oppVP.Opp_VP_Positions__r ) {                     
                    ExistingCompanyAssetClsSet.add(position.Company__c+'_'+position.Asset_Classes__c);
                }
            
        }
        
                                                    
        for(Opp_VP_Position__c selectedposition : [SELECT id, Name, Asset_Classes__c, Client_Type__c, Company__c, Notes__c, Opportunity_VP__c, Report_Fee__c,
                                                     Status__c,Industry_Group__c,Industry_Group_Picklist__c,Sector__c
                                                   FROM Opp_VP_Position__c 
                                                   WHERE Id IN : CurSelIDsSet ORDER BY Name ASC]) {                                                                       
            
            if(!ExistingCompanyAssetClsSet.contains(selectedposition.Company__c+'_'+selectedposition.Asset_Classes__c))
                CompanyIdwithPositionMap.put(selectedposition.Company__c+'_'+selectedposition.Asset_Classes__c, selectedposition);            
        }
        
        for(String companyIdAssetCls : CompanyIdwithPositionMap.KeySet()) {
            
            Opp_VP_Position__c tempPosition = new Opp_VP_Position__c();
            tempPosition = CompanyIdwithPositionMap.get(companyIdAssetCls).clone(false, true, false, false);
            tempPosition.Opportunity_VP__c = SourceId;
            tempPosition.Status__c = 'In Progress';
            tempPosition.Report_Fee__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Report_Fee__c;
            tempPosition.Industry_Group_Picklist__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Industry_Group_Picklist__c;
            tempPosition.Sector__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Sector__c;
            tempPosition.Name = CompanyIdwithPositionMap.get(companyIdAssetCls).Name;
            Old_New_PositionMap.put(CompanyIdwithPositionMap.get(companyIdAssetCls).Id,tempPosition);                
            positionToInsertList.add(tempPosition);                     
            
        }
        //ExistingCompanyIdSet.addAll(CompanyIdwithPositionMap.KeySet());
        if(positionToInsertList.size() > 0 ) {                 
            insert positionToInsertList ;
        }
        if(positionToInsertList != null && positionToInsertList .size() > 0 && SelectedImportOption == Label.HL_PositionWithTeamMember)
            CloneTeamMembers(Old_New_PositionMap);            
        SearchRelatedPositions();
    } 
    public PageReference SearchRelatedPositions() {
        RelatedDataList.Clear();
        PageSizeValues = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        if(OppVPCustomMetaData != null && OppVPCustomMetaData.Position_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(OppVPCustomMetaData.Position_Page_Size_Options__c).split(',');
        for(String pagesize : listofPageSize)
            PageSizeValues.add(new SelectOption(pagesize, pagesize));       
            
        list<Opp_VP_Position__c> filteredPositionList = new list<Opp_VP_Position__c>();
        for(Opp_VP_Position__c pos :[SELECT id, Name, Company__r.Name , Asset_Classes__c, Company__c
                                     FROM Opp_VP_Position__c 
                                     WHERE Opportunity_VP__c =: SelectedPVId ORDER BY Name ASC] )
         {
            if(!ExistingCompanyAssetClsSet.contains(pos.Company__c+'_'+pos.Asset_Classes__c))
                filteredPositionList.add(pos);                                                          
         } 
         if(filteredPositionList.size() > 0 )            
         {
            Std_Set_controller = new ApexPages.StandardSetController(filteredPositionList); 
            Std_Set_controller.first();
            IsPVSelected = true;
            CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_Page_Size__c);
            Std_Set_controller.setPageSize(CurPageSize);  
            fetchRelatedData(); 
            
         }  
         isOnNextScreen = true;             
         return null;
    }
    
   //indicates whether there are more records after the current page set. 
    @TestVisible public Boolean hasNext {
        get {
            if(Std_Set_controller == null) return false;
            return Std_Set_controller.getHasNext();
        }
    }
     
    //indicates whether there are more records before the current page set.
    @TestVisible public Boolean hasPrevious {
        get {
            if(Std_Set_controller == null) return false;
                return Std_Set_controller.getHasPrevious();
            }
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

    // returns the first page of records 
    public void first()
    {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.first();
            /*if(!IsPVSelected)
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
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
            /*if(!IsPVSelected)
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
            fetchRelatedData();
        }
    }
     
    //returns the previous page of records 
    public void previous() {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.previous();
            /*if(!IsPVSelected)
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
            fetchRelatedData();
        }
    }
     
    // returns the next page of records 
    public void next() {
        if(Std_Set_controller != null)
        {            
            refreshSelIDs();
            Std_Set_controller.next();
            /*if(!IsPVSelected)
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(OppVPCustomMetaData.Import_Position_Default_Page_Size__c);
            */
            fetchRelatedData();
        }
    }       
    
    // To save pagesize for manual change by User through page size drop down 
    public void doSavePageSize()
    {
        if(Std_Set_controller != null)
        {
            refreshSelIDs();
            Std_Set_controller.setPageSize(this.CurPageSize);
            Std_Set_controller.first();           
            fetchRelatedData();                       
        }
    }
    
    private void refreshSelIDs()
    {
        if(IsPVSelected) {        
            if(RelatedPositionList != null && RelatedPositionList.size()>0)
            {
                for(RelatedPositionClass rlPosdata :RelatedPositionList)
                {
                    if(rlPosdata.OppVPPositionRecord != null)
                    {
                        if(rlPosdata.isSelected){
                            CurSelIDsSet.add(rlPosdata.OppVPPositionRecord.ID);
                        }
                        else CurSelIDsSet.remove(rlPosdata.OppVPPositionRecord.ID);
                    }
                }
            }           
        }
        
    }
    
    // To redirect user to original Valuation period with save changes
    public PageReference BackToVP() {        
        try{            
            SaveChanges();
            return new PageReference('/'+SourceId);
        }catch (Exception ex){            
            Apexpages.addMessages(ex);                                   
        } 
        return null;        
    }
    
    // To redirect back screen (Valuation Period screen) 
    public pageReference backToVPScreen() {
        isOnNextScreen = false;
        if(RelatedDataList.size() == 0 && RelatedPositionList.size() == 0 )
        {
            return  new PageReference('/'+SourceId);
        }
        else
        {
            refreshSelIDs();
            RelatedPositionList = new List<RelatedPositionClass>();
            initStdSetController();
            return null; 
        }
    }
    
    // To redirect user to original Valuation period without save changes
    public PageReference Cancel() {
        return new PageReference('/'+SourceId);
    }
    
    public void goCurPageNumber()
    {
        if(Std_Set_controller != null)
        {
            if(this.CurPageNumber == null) this.CurPageNumber = 0;
            refreshSelIDs();
            if(this.CurPageNumber<1) this.CurPageNumber = 1;
            else if(this.CurPageNumber>pageSize) this.CurPageNumber = pageSize;

            Std_Set_controller.setpageNumber(this.CurPageNumber);
        }
    }
    
    public void CloneTeamMembers(Map<Id,Opp_VP_Position__c > originalPositionMap)
    {
        List<Opp_VP_TeamMember__c> clonnedTeamMembers = new List<Opp_VP_TeamMember__c>();
        if(originalPositionMap != null && originalPositionMap.KeySet().size() > 0)
        {
            Set<String> PositionStaffIdCombinationToAvoidDuplication = new Set<String>();
            for(Opp_VP_TeamMember__c OPVPTM : [SELECT Id,Name, Opportunity_VP_Position__c, Staff__c, Role__c
                                               FROM Opp_VP_TeamMember__c
                                               WHERE Opportunity_VP_Position__c IN : originalPositionMap.KeySet() AND Staff__c IN (SELECT Contact__c FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: OpportunityId ) ])
            {
                if(!PositionStaffIdCombinationToAvoidDuplication.contains(Old_New_PositionMap.get(OPVPTM.Opportunity_VP_Position__c).Id+'--'+OPVPTM.Staff__c+'--'+OPVPTM.Role__c))
                {
                    Opp_VP_TeamMember__c ClonedTM = new Opp_VP_TeamMember__c(); 
                    ClonedTM = OPVPTM.clone(false, true, false, false);
                    ClonedTM.Opportunity_VP_Position__c = Old_New_PositionMap.get(OPVPTM.Opportunity_VP_Position__c).Id; 
                    ClonedTM.Name = OPVPTM.Name ;
                    ClonedTM.Start_Date__c = Date.Today();
                    ClonedTM.End_Date__c = Null;
                    clonnedTeamMembers.add(ClonedTM); 
                    PositionStaffIdCombinationToAvoidDuplication.add(Old_New_PositionMap.get(OPVPTM.Opportunity_VP_Position__c).Id+'--'+OPVPTM.Staff__c+'--'+OPVPTM.Role__c);  
                }                    
            }
        }
        if(clonnedTeamMembers.size() > 0 )
            Insert clonnedTeamMembers; 
    }
    
    // Wrapper Class to ploat Valuation Period table on Screen
    public Class RelatedDataClass {
        public boolean isSelected {get; set;}
        public Opp_VP__c OppVPRecord {get; set;}
                
        public RelatedDataClass(Opp_VP__c relatedData)
        {
            OppVPRecord = relatedData;
        }
    }
    
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
    
}