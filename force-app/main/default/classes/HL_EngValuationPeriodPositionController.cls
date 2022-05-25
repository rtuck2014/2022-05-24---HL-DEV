public without sharing class HL_EngValuationPeriodPositionController {
   
    public String EngVPPositionStatus{get;set;}
    public String profileName;
    public String userProfileName {
        get {
            return [select Profile.Name from User where Id = :Userinfo.getUserId()].Profile.Name;
        }
    }

    public List<VPTeamMember> VPTeamMemberList {get;set;}
    public Integer selectItemSrNo {get;set;}
    private Id CurrentPositionId;
    public Boolean isValidPosition {get; private set;}
    public Boolean isChangesSave {get;set;}
    public Boolean isErrorOnSave {get;set;}
    public Integer NoOfAddedTeamMemberButNotSaved {get; set;}
    public Set<id> AddedTeamMemberIdSet {get; set;}
    public  Map<Id, Contact> ContactMap;
    public Integer noOfHLEmployees {get;set;}
    public Boolean IsSaveRequired {get; set;}
    public Boolean UserCanCreateModifyTM {get; set;}        
    public Boolean UserCanDeleteTM {get; set;}
    public Boolean isBelongsToSuperUser {get; set;}
    private Set<Id> tempVPTMSet; // Set of Ids for team members added temporarily   
    public boolean isPositionCancelled {get; set;}
    public boolean IshavingValidRoleForRevAccrual {get; set;}     
    public Boolean isValidPVUser{get;set;}
    public Boolean isRequired{get;set;}{isRequired=false;}
    private Id EngVpId;
    private Map<Id,String> OverallContactMap;
    Public Eng_VP_Position__c  OriginalPosition;         
    public String fieldAPI{get;set;}  
    Public Eng_VP_Position__c EngVPPosition{get;set;}
    Public boolean isError{get;set;}
    Public Boolean IsHavingPVPermissionSetOrIsSysAdmin{get;set;} 
    private string tempName;   
    public Boolean isBelongsToSupervisorGroup{get;set;} 
    public Account selectedAcc {get; set;}
    public Boolean IsMemberofAPTeam{get;set;}
    
    public Integer AllowedMembers {get 
        {
            ContactMap = new Map<Id, Contact>();
            Integer newContactsTobeadded = 0;
            noOfHLEmployees = 0;
            Set<Id> ContactlinkedToTeamMemberSet = new Set<Id>();
            for(Eng_VP_TeamMember__c opVPtm : [SELECT staff__c, Is_Team_Member_Deactivated_Once__c  FROM Eng_VP_TeamMember__c WHERE Is_Team_Member_Deactivated_Once__c = false AND Engagement_VP_Position__c =: CurrentPositionId]) {
                ContactlinkedToTeamMemberSet.add(opVPtm.staff__c);
            }
            if(ContactlinkedToTeamMemberSet != null && ContactlinkedToTeamMemberSet.size()>0){
                 for(Contact c : [SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Engagement_Internal_Team__c WHERE End_Date__c = null AND Engagement__c = : EngagementId)]) {
                  ContactMap.put(c.id, c);
                  OverallContactMap.put(c.id,c.Name);
                  noOfHLEmployees ++;
                  if (!ContactlinkedToTeamMemberSet.contains(c.Id))
                    newContactsTobeadded++;               
                }
            
            }
           
            AllowedMembers = newContactsTobeadded; //ContactMap.values().size();
            Set<Id> InactiveMembers = new Set<Id>();
            Set<Id> activeMembers = new Set<Id>();
            for(Eng_VP_TeamMember__c EngVPtm : [SELECT staff__c, Team_Member_Status__c  FROM Eng_VP_TeamMember__c WHERE Is_Team_Member_Deactivated_Once__c = false AND staff__c IN: ContactMap.KeySet()  AND Engagement_VP_Position__c =: CurrentPositionId ORDER BY CREATEDDATE DESC])
            {
                InactiveMembers.add(EngVPtm.staff__c);
            }
            
            InactiveMembers.addAll(tempVPTMSet);     
            AllowedMembers += InactiveMembers.size();
            return AllowedMembers;
        } set;
    }
        
    private void modifySet() {
            Set<Id> InactiveMembers = new Set<Id>();
            Set<Id> activeMembers = new Set<Id>();
            for(Eng_VP_TeamMember__c EngVPtm : [SELECT staff__c,Team_Member_Status__c  FROM Eng_VP_TeamMember__c WHERE Is_Team_Member_Deactivated_Once__c = false AND Engagement_VP_Position__c =: CurrentPositionId ORDER BY CREATEDDATE DESC])
            {
                InactiveMembers.add(EngVPtm.staff__c);
            }            
            InactiveMembers.addAll(tempVPTMSet);    
            AddedTeamMemberIdSet.removeAll(InactiveMembers);                                   
   }
        
    public List<SelectOption> HLInternalEmployees {get
        {
            HLInternalEmployees = new List<SelectOption>();
            modifySet();// Added this method for SF-821
            for(Contact cont : [SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Engagement_Internal_Team__c WHERE End_Date__c = null AND Engagement__c = : EngagementId) AND Id NOT IN : AddedTeamMemberIdSet ORDER BY Name ASC]) {
              HLInternalEmployees.add(new SelectOption(cont.Id, Cont.Name));
            }
            return HLInternalEmployees;
        }
        set;
    }
        
    private Id EngagementId;
    public string parentId {
        get{
            return EngagementId;
            } set;
    }
       
    //Refreshes the list of possible role choices for a new staff member  
    public void RefreshNewStaffRoles() {
        //StaffMemberToAdd = null;
    }

    public HL_EngValuationPeriodPositionController(ApexPages.StandardController controller){
        AllowedMembers = 0;
        isPositionCancelled  = false;
        tempVPTMSet = new Set<Id>();
        IsSaveRequired = false;
        ContactMap = new Map<Id, Contact>();
        OverallContactMap = new Map<Id, String>();
        HLInternalEmployees = new List<SelectOption>();
        NoOfAddedTeamMemberButNotSaved = 0;
        EngVPPosition = new Eng_VP_Position__c();
        EngVPPosition = (Eng_VP_Position__c)controller.getRecord();
        CurrentPositionId =  apexpages.currentPage().getParameters().get('id');
        AddedTeamMemberIdSet = new Set<id>();
        tempName = '';        
        FetchLatestTeamMembers();
        List<Contact> ValidContactList = new List<Contact>([SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Engagement_Internal_Team__c WHERE End_Date__c = null AND Engagement__c = : EngagementId)]);
            AllowedMembers = ValidContactList.size();
        isValidPVUser = HL_ConstantsUtil.IsSupervisorOrAdmin();
        IshavingValidRoleForRevAccrual = HL_ConstantsUtil.IshavingValidRoleInInternTeamEng(EngagementId);   
        IsHavingPVPermissionSetOrIsSysAdmin = HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin();        
        VerifyAccessibilityToTM();
        deleteTeamMemberPermissionForSuperUsers();
        OriginalPosition = new Eng_VP_Position__c();
                                      
        for(Eng_VP_Position__c vpPos1 : [SELECT Name,Industry_Group__c,Engagement_Number__c,CreatedDate,Cancel_Year__c ,Completed_Date__c ,Cancel_Date__c ,Fee_Completed__c , Asset_Classes__c, Notes__c, Report_Fee__c, Engagement_VP__c,Company__c, Engagement_VP__r.Engagement__c,Engagement_VP__r.Engagement__r.Client__c,Status__c,Revenue_Month__c, Revenue_Year__c, Comments__c, Reason__c, Automation_Tool_Utilized__c, Cancel_Month__c,Industry_Group_Picklist__c,Sector__c,Fee_Approval_Date__c, Fee_Notes_Description__c FROM Eng_VP_Position__c WHERE id =: CurrentPositionId ]) 
        {   
   
            OriginalPosition = vpPos1;
            EngVPPosition = vpPos1;
            //DMND0023397_FVA PV-Staffing/Automation Reminders before Accrual:- To verify Status of Position is 'Completed' to display prompt message
            EngVPPositionStatus = vpPos1.Status__c;
          
            
        }
        
        User getUserProInfo = [SELECT Id,Name, Profile.Name from User Where Id =: userinfo.getUserId()];
                
        Group grpId = [SELECT Id FROM Group WHERE Name = :Label.HL_PV_Portfolio_Valuation_Supervisors];
            HL_getMemberofGroups objGrpId = new HL_getMemberofGroups();
            Set<Id> userIds = objGrpId.getAllPublicGroupUsers(grpId.Id);
            
            if(userIds != NULL && userIds.contains(UserInfo.getUserId())){
                    UserCanCreateModifyTM = true;
                    UserCanDeleteTM = true;
                    isBelongsToSupervisorGroup = true;
            }
        
        CompanyIGSvalues();
        
        // for history tracking related list
        for(PV_HistoryTracking_VisibilitySetting__mdt PVSetting : [Select User_Id__c From PV_HistoryTracking_VisibilitySetting__mdt]){
           if(PVSetting.User_Id__c.length()>= 15 && PVSetting.User_Id__c.substring(0,15) == userInfo.getUserId().substring(0,15))
            {   
                IsMemberofAPTeam = true;
                break;
            }
        }
        
    }
    
  //To ClearFeeApprovalDate on change of report fee
    public void ResetFeeApprovalDate(){
        EngVPPosition.Fee_Approval_Date__c=null;
     
     }  
  //To ClearFeeApprovalDate on change of report fee
    public void ClearFeeApprovalDate(){
        EngVPPosition.Fee_Approval_Date__c=null;
      
        saveRc();
     }  
    //To get IG&S of associated Company
    public void CompanyIGSvalues(){
        if(EngVPPosition.Company__c != null){
            selectedAcc = [SELECT id,Industry_Group__c,Sector__c from Account WHERE id=:EngVPPosition.Company__c];
        }
    }
    
    private void FetchLatestTeamMembers() {
        tempVPTMSet = new Set<id>();
        VPTeamMemberList = new List<VPTeamMember>();    
        Monthly_Revenue_Process_Control__c  MRPC = new Monthly_Revenue_Process_Control__c();
            MRPC = HL_Eng_VP_PositionTriggerHelper.fetchMRPC();
                                        
        for(Eng_VP_Position__c vpPos : [SELECT Name,Industry_Group__c,Fee_Approval_Date__c, Asset_Classes__c, Notes__c, Report_Fee__c, Engagement_VP__c,Company__c, Engagement_VP__r.Engagement__c,Status__c,Revenue_Month__c, Revenue_Year__c, Comments__c, Reason__c, Automation_Tool_Utilized__c,Industry_Group_Picklist__c,Sector__c,Fee_Notes_Description__c, (SELECT id, staff__c, staff__r.Name, Role__c, Start_Date__c, End_Date__c, Team_Member_Status__c, Engagement_VP_Position__c, Is_Team_Member_Deactivated_Once__c FROM Eng_VP_TeamMembers__r ORDER BY  Team_Member_Status__c DESC,staff__r.Name ASC   ) FROM Eng_VP_Position__c WHERE id =: CurrentPositionId ]) 
        {
            EngVPPosition = vpPos;
            if(vpPos.Status__c =='Cancelled')
              isPositionCancelled = true;            
            if(MRPC != null && vpPos.Status__c == System.Label.HL_Eng_VP_Status_Completed && HL_Eng_VP_PositionTriggerHelper.isRevenueMonthYearPassed(vpPos.Revenue_Month__c,vpPos.Revenue_Year__c, MRPC ))
              isPositionCancelled = true;
            isValidPosition = true;
            EngagementId = vpPos.Engagement_VP__r.Engagement__c;
            for(Eng_VP_TeamMember__c vptm : vpPos.Eng_VP_TeamMembers__r)
            {
                VPTeamMemberList.add(new VPTeamMember(VPTeamMemberList.size()+1, vptm));
                if(!vptm.Is_Team_Member_Deactivated_Once__c) {
                    AddedTeamMemberIdSet.add(vptm.staff__c);
                    IsSaveRequired = true;
                }
                OverallContactMap.put(vptm.staff__c, vptm.staff__r.Name);
           }
           EngVpId = vpPos.Engagement_VP__c;
        }
        
        for(Contact c: [SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Engagement_Internal_Team__c WHERE End_Date__c = null AND Engagement__c = : EngagementId)])
        {
            OverallContactMap.put(c.id, c.Name);
        }
        NoOfAddedTeamMemberButNotSaved = 0;
    }   
       
    public PageReference AddMember() {
        IsSaveRequired = true;
        VPTeamMemberList.add(new VPTeamMember(VPTeamMemberList.size()+1 , new Eng_VP_TeamMember__c(Role__c = system.Label.HL_DefaultTeamMember, Engagement_VP_Position__c = CurrentPositionId, Start_Date__c = system.Today())));
        NoOfAddedTeamMemberButNotSaved++;
        for (VPTeamMember vptm : VPTeamMemberList) {            
          if(vptm.EngVPTeamMember.Id == null || (vptm.EngVPTeamMember.Id != null && !vptm.EngVPTeamMember.Is_Team_Member_Deactivated_Once__c)){
            AddedTeamMemberIdSet.add(vptm.SelectedStaffId);
            if(vptm.EngVPTeamMember.Id == null)
                tempVPTMSet.add(vptm.SelectedStaffId);
          }
          if(OverallContactMap.containsKey(vptm.SelectedStaffId) && OverallContactMap.get(vptm.SelectedStaffId) != null)
            vptm.SelectedStaffName = OverallContactMap.get(vptm.SelectedStaffId); 
        }
        return null;
    }
       
    public PageReference RemoveMember() {
        isChangesSave = false;
        IsSaveRequired =  false;
        NoOfAddedTeamMemberButNotSaved--;        
        for (VPTeamMember vptm : VPTeamMemberList) {
          vptm.SelectedStaffName = OverallContactMap.get(vptm.SelectedStaffId);
        }
        if(VPTeamMemberList != null && VPTeamMemberList.size()>0 && selectItemSrNo >0 && VPTeamMemberList[selectItemSrNo-1].EngVPTeamMember.id != null) {
            //for (Opp_VP_TeamMember__c tm : [SELECT id from Opp_VP_TeamMember__c WHERE id =: VPTeamMemberList[selectItemSrNo-1].OppVPTeamMember.id])
                try{
                     Delete VPTeamMemberList[selectItemSrNo-1].EngVPTeamMember;                
                     NoOfAddedTeamMemberButNotSaved++;
                }catch (Exception ex){                           
                    // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, System.Label.HL_VP_TeamMember_StopChange));
                   isErrorOnSave = true;
                   Apexpages.addMessages(ex);                    
                }        
        }
        if(VPTeamMemberList != null && VPTeamMemberList.size() >= selectItemSrNo && AddedTeamMemberIdSet != null && AddedTeamMemberIdSet.contains(VPTeamMemberList[selectItemSrNo-1].SelectedStaffId)){
            AddedTeamMemberIdSet.remove(VPTeamMemberList[selectItemSrNo-1].SelectedStaffId);            
            tempVPTMSet.remove(VPTeamMemberList[selectItemSrNo-1].SelectedStaffId);
        }
        if(selectItemSrNo != null && VPTeamMemberList != null && VPTeamMemberList.size() >= selectItemSrNo )
            VPTeamMemberList.remove(selectItemSrNo-1);          
        Integer i = 1;      
        for (VPTeamMember vptm : VPTeamMemberList) {
            if(vptm.EngVPTeamMember.Id == null || (vptm.EngVPTeamMember.Id != null && !vptm.EngVPTeamMember.Is_Team_Member_Deactivated_Once__c))
              IsSaveRequired = true;
            vptm.SrNo = i++;            
        }        
        return null;
    }
    
    public PageReference SaveTeamMembers() {        
        try{
            Map<Id, Eng_VP_TeamMember__c> MapofTM = new Map<Id, Eng_VP_TeamMember__c>([SELECT id, staff__c, staff__r.Name, Role__c, Start_Date__c, End_Date__c, Team_Member_Status__c, Engagement_VP_Position__c, Is_Team_Member_Deactivated_Once__c FROM Eng_VP_TeamMember__c  WHERE Engagement_VP_Position__c =: CurrentPositionId]);
        
            isErrorOnSave = false;
            List<Eng_VP_TeamMember__c> EngVPTeamMeberList = new List<Eng_VP_TeamMember__c>();
            Eng_VP_TeamMember__c tempItem; 
            Map<Id,Eng_VP_TeamMember__c> ExistingTMMap = new Map<Id,Eng_VP_TeamMember__c>();
            String memberStr2 = '';        
            Map<Id, sObject> mapIdExistingSet = new Map<Id,sObject>();
        
            for (VPTeamMember vptm : VPTeamMemberList) {
                tempItem = new Eng_VP_TeamMember__c();
                tempItem = vptm.EngVPTeamMember;
                tempItem.Staff__c = vptm.SelectedStaffId;
                if(OverallContactMap.containsKey(vptm.SelectedStaffId)) {
                    vptm.SelectedStaffName = OverallContactMap.get(vptm.SelectedStaffId);
                }
                else {
                    OverallContactMap.put(vptm.SelectedStaffId, vptm.SelectedStaffName);
                }
                tempItem.Name = vptm.SelectedStaffName;
                if(tempItem.Id != null)
                {
                    ExistingTMMap.put(tempItem.Id, tempItem);
                }
                else
                    EngVPTeamMeberList.add(tempItem);           
                
                if(vptm.EngVPTeamMember.Start_Date__c  != null && vptm.EngVPTeamMember.End_Date__c !=null && vptm.EngVPTeamMember.Start_Date__c > vptm.EngVPTeamMember.End_Date__c) {
                  memberStr2 += vptm.SelectedStaffName +', ';
                }
            }
            if(memberStr2.contains(',')) {
                memberStr2 = memberStr2.removeEnd(', ');
                memberStr2 +='.';
                DmlException e = new DmlException();
                e.setMessage('Start date can not be after end date, Please correct dates for: '+memberStr2);
                throw e;        
            }
            List<Eng_VP_TeamMember__c> VPTMstoUpdate = new List<Eng_VP_TeamMember__c>();
            for(Eng_VP_TeamMember__c EngVPTM : [Select id From Eng_VP_TeamMember__c WHERE ID IN : ExistingTMMap.KeySet()])
                if(ExistingTMMap.containsKey(EngVPTM.id))
                    VPTMstoUpdate.add(ExistingTMMap.get(EngVPTM.Id));
            if (VPTMstoUpdate.size() > 0) {
                update VPTMstoUpdate;            
            }
            if (EngVPTeamMeberList.size() > 0) {
                upsert EngVPTeamMeberList;            
            }
            isChangesSave = true;
            FetchLatestTeamMembers(); 
        }
        catch (Exception e) {
            isErrorOnSave = true;
            isChangesSave = false;
            Apexpages.addMessages(e);
        }    
        return null;
    }
    
    public class VPTeamMember{
        
        public Integer SrNo{get;set;}
        public Id SelectedStaffId{get;set;}
        public String SelectedStaffName{get;set{SelectedStaffName = value;}}
        public Eng_VP_TeamMember__c EngVPTeamMember{get;set;}
        
        public VPTeamMember(Integer SrNumber, Eng_VP_TeamMember__c EngVPTeamMemberParam )
        {
            EngVPTeamMember = new Eng_VP_TeamMember__c();
            if(EngVPTeamMemberParam != null) {
                EngVPTeamMember = EngVPTeamMemberParam;
                SelectedStaffId = EngVPTeamMemberParam.Staff__c;
                SelectedStaffName = EngVPTeamMemberParam.Staff__r.Name;             
            }
            SrNo = SrNumber;
        }            
    }
        
    
    // To provide Eng TeamMember delete permission to Superusers
    private void deleteTeamMemberPermissionForSuperUsers(){
        
        isBelongsToSuperUser = false;
        for (permissionsetAssignment psa : [SELECT PermissionSet.Name FROM permissionsetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: Label.HL_TMDeletePermissionForSuperUser]) {
                isBelongsToSuperUser = true;                      
        }       
    }     

    // To verify if logged in user is member of Group Portfolio Staffing/Portfolio Supervisor. 
    private void VerifyAccessibilityToTM(){      
      
        UserCanCreateModifyTM = false;
        UserCanDeleteTM = false;      
     
        if(HL_OpportunityViewController.IsUserMemberofPVSuperVisorOrItschildGroup())
        {
            UserCanCreateModifyTM = true;
            UserCanDeleteTM = true;            
        }
        if(UserCanDeleteTM) {
            UserCanDeleteTM = false;
            for (permissionsetAssignment psa : [SELECT PermissionSet.Name 
                             FROM permissionsetAssignment 
                             WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: Label.HL_PVPermissionSetName])
            {
                UserCanDeleteTM = true;                      
            }
        }
        if(!UserCanCreateModifyTM) {
            Engagement__c Eng = new Engagement__c (Id = EngagementId);
            UserCanCreateModifyTM = HL_EngagementViewController.VerifyUserforVP(Eng, 'EngagementPV');
        }
        
        //String profileName = getuserProfileName();
        
        for(User usr : [SELECT Id,Name, Profile.Name from User Where Id =: userinfo.getUserId()])       
        {          
            if(usr.profile.Name == 'System Administrator')     
            {       
                UserCanCreateModifyTM = true;  
                UserCanDeleteTM = true;
                // field added on 15/10/18 for making record editable for system admin
                isBelongsToSupervisorGroup = true;      
            }       
            if(profileName == 'System Administrator (Read Only)')     
            {       
                UserCanCreateModifyTM = false;  
                UserCanDeleteTM = false;      
            } 
        }          
    }
    public PageReference Backtovp() {
        string url = '/' + EngVpId ;                        
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;
        
    }
    public PageReference VoidPosition() {
        string url = '/apex/HL_EngValuationPeriodPositionCancel?id=' + CurrentPositionId;                
        if (!String.isBlank(HL_PageUtility.GetParameter('retURL')))
           url = url + '&retURL=' + HL_PageUtility.GetParameter('retURL');
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;        
    }
    
    public PageReference DeleteRecord() { 
        string url = '/apex/HL_ValuationPeriodPositionDelete?id=' + CurrentPositionId+'&sObjectName=Eng_VP_Position__c&ReturnID='+EngVpId;                
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;
    }  
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }} 
    public PageReference saveRc()
    {
        try{        
            
            if((EngVPPosition.Name == null || EngVPPosition.Name == '') && tempName != '' && tempName != null)
                EngVPPosition.Name = tempName;
                        
            if(EngVPPosition.Automation_Tool_Utilized__c == null || EngVPPosition.Automation_Tool_Utilized__c == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Automation Tool Utilized: Please select a value'));
                return null;
            }
            if(EngVPPosition.Automation_Tool_Utilized__c == 'No' && (EngVPPosition.Reason__c == '' || EngVPPosition.Reason__c == null)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Reason: Please select a Reason because Automation Tool Utilized is selected as \'No\''));
                return null;
            }
            
            if((selectedAcc.Industry_Group__c != null && selectedAcc.Industry_Group__c != '') && (selectedAcc.Sector__c != null && selectedAcc.Sector__c != '') &&
                (EngVPPosition.Industry_Group_Picklist__c == null || EngVPPosition.Industry_Group_Picklist__c == '') && (EngVPPosition.Sector__c == null || EngVPPosition.Sector__c == '')){
                
                EngVPPosition.Industry_Group_Picklist__c = selectedAcc.Industry_Group__c;
                EngVPPosition.Sector__c = selectedAcc.Sector__c;
            }           
            if(((selectedAcc.Industry_Group__c == null || selectedAcc.Industry_Group__c == '') || (selectedAcc.Sector__c == null || selectedAcc.Sector__c == '')) && 
               ((EngVPPosition.Industry_Group_Picklist__c == null || EngVPPosition.Industry_Group_Picklist__c == '') || (EngVPPosition.Sector__c == null || EngVPPosition.Sector__c == ''))){
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_No_IG_S_on_Position));
                return null;
            }
            
            if(EngVPPosition.Automation_Tool_Utilized__c == 'yes' && (EngVPPosition.Reason__c != '' && EngVPPosition.Reason__c != null)){
                EngVPPosition.Reason__c='';
            }
            update EngVPPosition;
        }catch(Exception e )
        {
            ApexPages.addMessages(e);
            return null;
        }        
        return new pageReference('/'+EngVPPosition.Id);
     }
     
    public void DummyReset(){         
        if(fieldAPI == 'Name'){
            EngVPPosition.Name = OriginalPosition.Name;
            tempName = OriginalPosition.Name;            
        }
        else if(fieldAPI == 'Asset_Classes__c')
            EngVPPosition.Asset_Classes__c = OriginalPosition.Asset_Classes__c ;
        else if(fieldAPI == 'Notes__c')
            EngVPPosition.Notes__c = OriginalPosition.Notes__c;
        else if(fieldAPI == 'Report_Fee__c')
            EngVPPosition.Report_Fee__c = OriginalPosition.Report_Fee__c;        
        else if(fieldAPI == 'Status__c')
            EngVPPosition.Status__c = OriginalPosition.Status__c;
        else if(fieldAPI == 'Automation_Tool_Utilized__c')
            EngVPPosition.Automation_Tool_Utilized__c = OriginalPosition.Automation_Tool_Utilized__c;
        else if(fieldAPI == 'Reason__c')
            EngVPPosition.Reason__c = OriginalPosition.Reason__c;
        else if(fieldAPI == 'Comments__c')
            EngVPPosition.Comments__c = OriginalPosition.Comments__c;    
    } 
}