/*********************************************************
* Author: Harsh Kumar
* Created Date: 13th June 2017
* Purpose: To provide clone Position functionality to user 
*********************************************************/
public with sharing class HL_EngAddPositionsController {
    
    // Private properties
    private Id SourceId;       
    private Boolean IsPVSelected ;            
    private Id EngagementId ;// {get;set;}
    public Boolean isValidPVUser{get;set;}
    //private Set<Id> ExistingCompanyIdSet; 
    private Set<String> ExistingCompanyAssetClsSet;
    private Valuation_Period__mdt EngVPCustomMetaData;
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
    public List<Eng_VP_Position__c> EngVPPositionWithoutAFU {get; set;}
    public boolean isOnNextScreen {get;set;}
    
    public boolean getshowErrorMsg(){
        string redirectFromSrc = Apexpages.currentpage().getparameters().get('redirectFrom');
        if(redirectFromSrc == 'SaveButton'){
            return false;
        } else {
            return true;
        }
    }
    
    
    public List<SelectOption> getImportOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(Label.HL_PositionWithoutTeamMember,Label.HL_PositionWithoutTeamMember)); 
        options.add(new SelectOption(Label.HL_PositionWithTeamMember,Label.HL_PositionWithTeamMember));         
        return options; 
    }
    
    // Constructor 
    public HL_EngAddPositionsController() {
        
        RelatedDataList = new List<RelatedDataClass>();
        RelatedPositionList = new List<RelatedPositionClass>();
        EngVPPositionWithoutAFU = new List<Eng_VP_Position__c>();
        //ExistingCompanyIdSet = new Set<Id>();
        ExistingCompanyAssetClsSet = new Set<String>();
        SourceId = Apexpages.currentpage().getparameters().get('srcId');
        EngagementId = Apexpages.currentpage().getparameters().get('srcParentId');
        EngVPCustomMetaData = new Valuation_Period__mdt();
        EngVPCustomMetaData = [SELECT id, Import_Position_Default_Page_Size__c, Import_Position_Default_VP_Page_Size__c, VP_Page_Size_Options__c, Position_Page_Size_Options__c 
                               FROM Valuation_Period__mdt
                               WHERE DeveloperName = 'EngVP'];
        CurSelIDsSet = new Set<ID>();
        initStdSetController(); 
        SelectedImportOption = Label.HL_PositionWithTeamMember; 
        Engagement__c Eng = new Engagement__c();        
        Eng.id = EngagementId;
        if(Eng != null && Eng.id != null )
            isValidPVUser = HL_EngagementViewController.VerifyUserforVP(Eng, 'PVPositionCreation');         
    }     
        
    private void initStdSetController() {                
        IsPVSelected = false;
        PageSizeValues = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        if(EngVPCustomMetaData != null && EngVPCustomMetaData.VP_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(EngVPCustomMetaData.VP_Page_Size_Options__c).split(',');
        for(String pagesize : listofPageSize)
            PageSizeValues.add(new SelectOption(pagesize, pagesize));
        //CurSelIDsSet = new Set<ID>();
        List<Eng_VP__c> engVPList = new List<Eng_VP__c>();
        for(Eng_VP__c engVP :  [SELECT id, Name, (select Company__c,Asset_Classes__c,Status__c  from Eng_VP_Positions__r Where Status__c != 'Cancelled') 
                                FROM Eng_VP__c 
                                WHERE Engagement__c =: EngagementId ]) {
            If(engVP.Id == SourceId) { 
                for(Eng_VP_Position__c position : engVP.Eng_VP_Positions__r ) { 
                    //ExistingCompanyIdSet.add(position.Company__c);
                    ExistingCompanyAssetClsSet.add(position.Company__c+'_'+position.Asset_Classes__c);
                }
            }
            else {
                engVPList.add(engVP);
            }
        }
        Std_Set_controller = new ApexPages.StandardSetController(engVPList); 
        IsPVSelected = false;
        CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
        Std_Set_controller.first();
        Std_Set_controller.setPageSize(CurPageSize); 
        fetchRelatedData();               
    }
    
    private void fetchRelatedData() { 
        if(!IsPVSelected) { 
            //CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            RelatedDataList = new List<RelatedDataClass>();     
            if(Std_Set_controller != null)
            for(Eng_VP__c engVP : (List<Eng_VP__c>)Std_Set_controller.getRecords()) {
                RelatedDataList.add(new RelatedDataClass(engVP));
            }
        }
        else{
            //CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_Page_Size__c);
            RelatedPositionList = new List<RelatedPositionClass>();     
            if(Std_Set_controller != null)
            for(Eng_VP_Position__c engVPpos : (List<Eng_VP_Position__c>)Std_Set_controller.getRecords())
                RelatedPositionList.add(new RelatedPositionClass(CurSelIDsSet.contains(engVPpos.ID), engVPpos));
        }       
    }
    private Map<Id,Eng_VP_Position__c > Old_New_PositionMap = new Map<Id,Eng_VP_Position__c>();
    public PageReference SavePositions() {
        
        Savepoint sp = Database.setSavepoint();
                
        try{            
            SaveChanges();     
            //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please Update Position with Automation Usage Fields!!'));       
        }
        catch(Exception e) {
            Database.rollback( sp );
            Apexpages.addMessages(e); 
        }        
        return null;
    }
    
     public PageReference SaveChanges()
    {
            // Purpose is to stop populating company Name in to VP Position Name while importing
            HL_ConstantsUtil.stopCopyingNameFromCompToPosition = true;
            EngVPPositionWithoutAFU = new List<Eng_VP_Position__c>();
            String CreatedDateofRec = Label.HL_DeployedtoProd;
            Datetime myDate = datetime.valueOf(CreatedDateofRec);
            
            refreshSelIDs();
            List<Eng_VP_Position__c> positionToInsertList = new List<Eng_VP_Position__c>(); 
            Map<String,Eng_VP_Position__c> CompanyIdwithPositionMap = new Map<String, Eng_VP_Position__c>();
            
            for(Eng_VP__c engVP :  [SELECT id, Name, (select Company__c,Asset_Classes__c,Status__c,Automation_Tool_Utilized__c,Reason__c  from Eng_VP_Positions__r Where Status__c != 'Cancelled' ) 
                                FROM Eng_VP__c 
                                WHERE Id =: SourceId]) {             
                for(Eng_VP_Position__c position : engVP.Eng_VP_Positions__r ) {                     
                    ExistingCompanyAssetClsSet.add(position.Company__c+'_'+position.Asset_Classes__c);
                }
            }
                                                        // Removed Industry_Group_Picklist__c from below query
            for(Eng_VP_Position__c selectedposition : [SELECT id,Name, Asset_Classes__c, Client_Type__c, Company__c, Notes__c,Fee_Approval_Date__c, Engagement_VP__c, Report_Fee__c, Status__c,  Automation_Tool_Utilized__c, Comments__c, Reason__c,Engagement_VP__r.Engagement__c
                                                       ,Industry_Group_Picklist__c,Sector__c,CreatedDate FROM Eng_VP_Position__c 
                                                       WHERE Id IN : CurSelIDsSet ORDER BY Name ASC]) {
                if(!ExistingCompanyAssetClsSet.contains(selectedposition.Company__c+'_'+selectedposition.Asset_Classes__c))
                  CompanyIdwithPositionMap.put(selectedposition.Company__c+'_'+selectedposition.Asset_Classes__c, selectedposition);
                  
                  
                  
                if(String.isBlank(selectedposition.Automation_Tool_Utilized__c) && selectedposition.Status__c == 'In Progress' && selectedposition.CreatedDate > myDate){                    
                    EngVPPositionWithoutAFU.add(selectedposition);
                }
            }
            
            if(EngVPPositionWithoutAFU.size() > 0){ 
                return null;
            }
            Id Position_Current_RT_Id = Schema.SObjectType.Eng_VP_Position__c.getRecordTypeInfosByName().get('Current').getRecordTypeId(); 
            for(String companyIdAssetCls : CompanyIdwithPositionMap.KeySet()) {
                Eng_VP_Position__c tempPosition = new Eng_VP_Position__c();
                tempPosition = CompanyIdwithPositionMap.get(companyIdAssetCls).clone(false, true, false, false);
                tempPosition.Engagement_VP__c = SourceId;
                tempPosition.RecordTypeId = Position_Current_RT_Id;
                tempPosition.Status__c = 'In Progress';
                tempPosition.Report_Fee__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Report_Fee__c;
                tempPosition.Name = CompanyIdwithPositionMap.get(companyIdAssetCls).Name;
                tempPosition.Fee_Approval_Date__c= CompanyIdwithPositionMap.get(companyIdAssetCls).Fee_Approval_Date__c;
                
                
                if(CompanyIdwithPositionMap.get(companyIdAssetCls).CreatedDate > myDate && String.valueOf(CompanyIdwithPositionMap.get(companyIdAssetCls).Reason__c) != 'Historical'){
                    
                          tempPosition.Automation_Tool_Utilized__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Automation_Tool_Utilized__c;
                           tempPosition.Reason__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Reason__c;
                           tempPosition.Comments__c = CompanyIdwithPositionMap.get(companyIdAssetCls).Comments__c;
                    
                }
                else{
                        tempPosition.Automation_Tool_Utilized__c = null;
                        tempPosition.Reason__c = null;
                        tempPosition.Comments__c = '';
                }
                
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
            return null;
    } 
    
    
    public PageReference UpdatePositions() {
        PageReference pr = new PageReference('/apex/UpdateAutomationFromImportPosition_Page?id=' + SourceId+'&srcId='+SourceId+'&srcParentId='+EngVPPositionWithoutAFU[0].Engagement_VP__r.Engagement__c);
        pr.setRedirect(false);
        return pr;
    }
    
    
    // To redirect user to original Valuation period with save changes
    public PageReference BackToVP() {
        try{
            SaveChanges();  
            if(EngVPPositionWithoutAFU.size() > 0){                 
                return null;
            }
            return new PageReference('/'+SourceId);
        }catch(Exception ex){
            Apexpages.addMessages(ex);  
            //throw ex;
            return null;
        }
        
        
    }
        
    
    public PageReference SearchRelatedPositions() {
        RelatedDataList.Clear();        
        PageSizeValues = new List<SelectOption>();
        list<String> listofPageSize = new list<String>(); 
        if(EngVPCustomMetaData != null && EngVPCustomMetaData.Position_Page_Size_Options__c != null)
            listofPageSize = String.Valueof(EngVPCustomMetaData.Position_Page_Size_Options__c).split(',');
        for(String pagesize : listofPageSize)
            PageSizeValues.add(new SelectOption(pagesize, pagesize));       
            
        list<Eng_VP_Position__c> filteredPositionList = new list<Eng_VP_Position__c>();
        for(Eng_VP_Position__c pos :[SELECT id, Name, Company__r.Name ,Fee_Approval_Date__c, Asset_Classes__c, Company__c, Status__c,Reason__c,Automation_Tool_Utilized__c  
                                     FROM Eng_VP_Position__c 
                                     WHERE Engagement_VP__c =: SelectedPVId ORDER BY Name ASC] )
         {
           if(!ExistingCompanyAssetClsSet.contains(pos.Company__c+'_'+pos.Asset_Classes__c))
             filteredPositionList.add(pos);                                                           
         } 
         if(filteredPositionList.size() > 0 )            
         {
           Std_Set_controller = new ApexPages.StandardSetController(filteredPositionList); 
           Std_Set_controller.first();
           IsPVSelected = true;
           CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_Page_Size__c);
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
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
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
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
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
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
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
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_VP_Page_Size__c);
            else
                CurPageSize = Integer.ValueOf(EngVPCustomMetaData.Import_Position_Default_Page_Size__c);*/
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
                    if(rlPosdata.EngVPPositionRecord != null)
                    {
                        if(rlPosdata.isSelected){
                            CurSelIDsSet.add(rlPosdata.EngVPPositionRecord.ID);
                        }
                        else CurSelIDsSet.remove(rlPosdata.EngVPPositionRecord.ID);
                    }
                }
            }           
        }
        
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
    
    public void CloneTeamMembers(Map<Id,Eng_VP_Position__c > originalPositionMap)
    {
        List<Eng_VP_TeamMember__c> clonnedTeamMembers = new List<Eng_VP_TeamMember__c>();
        if(originalPositionMap != null && originalPositionMap.KeySet().size() > 0)
        {
            Set<String> PositionStaffIdCombinationToAvoidDuplication = new Set<String>();
            for(Eng_VP_TeamMember__c OPVPTM : [SELECT Id,Name, Engagement_VP_Position__c, Staff__c, Role__c
                                               FROM Eng_VP_TeamMember__c
                                               WHERE Engagement_VP_Position__c IN : originalPositionMap.KeySet() AND Staff__c IN (SELECT Contact__c FROM Engagement_Internal_Team__c WHERE Engagement__c =: EngagementId ) ])
            {
                if(!PositionStaffIdCombinationToAvoidDuplication.contains(Old_New_PositionMap.get(OPVPTM.Engagement_VP_Position__c).Id+'--'+OPVPTM.Staff__c+'--'+OPVPTM.Role__c))
                {
                  Eng_VP_TeamMember__c ClonedTM = new Eng_VP_TeamMember__c();                   
                  ClonedTM = OPVPTM.clone(false, true, false, false);                  
                  ClonedTM.Engagement_VP_Position__c = Old_New_PositionMap.get(OPVPTM.Engagement_VP_Position__c).Id; 
                  ClonedTM.Name = OPVPTM.Name ;
                  ClonedTM.Start_Date__c = Date.Today();
                  ClonedTM.End_Date__c = Null;
                  clonnedTeamMembers.add(ClonedTM); 
                  PositionStaffIdCombinationToAvoidDuplication.add(Old_New_PositionMap.get(OPVPTM.Engagement_VP_Position__c).Id+'--'+OPVPTM.Staff__c+'--'+OPVPTM.Role__c);  
              }                    
            }
        }
        if(clonnedTeamMembers.size() > 0 )
            Insert clonnedTeamMembers; 
    }
    
    // Wrapper Class to ploat Valuation Period table on Screen
    public Class RelatedDataClass {
        public boolean isSelected {get; set;}
        public Eng_VP__c EngVPRecord {get; set;}
                
        public RelatedDataClass(Eng_VP__c relatedData)
        {
            EngVPRecord = relatedData;
        }
    }
    
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
    
}