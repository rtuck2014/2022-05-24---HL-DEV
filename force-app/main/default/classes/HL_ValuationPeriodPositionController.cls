public without sharing class HL_ValuationPeriodPositionController{
  
    public String userProfileName {
        get {
            return [
                    select Profile.Name
                    from User
                    where Id = :Userinfo.getUserId() 
                    ].Profile.Name;
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
    public boolean IshavingValidRoleForRevAccrual {get; set;}     
    public Boolean isOpportunityConverted {get;set;}
    private Set<Id> tempVPTMSet; // Set of Ids for team members added temporarily
    private Id OppVpId ;     
    Public Opp_VP_Position__c OppVPPosition{get;set;}
    Public Boolean IsHavingPVPermissionSetOrIsSysAdmin{get;set;} 
    Public Boolean IsSupervisorOrAdmin{get;set;}  
    private Map<Id,String> OverallContactMap;
    Public Opp_VP_Position__c OriginalPosition; 
    public String fieldAPI{get;set;} 
    private string tempName; 
	public Account selectedAcc {get; set;} 
    public Boolean IsMemberofAPTeam{get;set;} 	
    public Integer AllowedMembers {get 
        {
            ContactMap = new Map<Id, Contact>();
            Integer newContactsTobeadded = 0;
            noOfHLEmployees = 0;
            Set<Id> ContactlinkedToTeamMemberSet = new Set<Id>();
            for(Opp_VP_TeamMember__c opVPtm : [SELECT staff__c, Is_Team_Member_Deactivated_Once__c  FROM Opp_VP_TeamMember__c WHERE Is_Team_Member_Deactivated_Once__c = false AND Opportunity_VP_Position__c =: CurrentPositionId]) {
                ContactlinkedToTeamMemberSet.add(opVPtm.staff__c);
            }            
            for(Contact c : [SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Opportunity_Internal_Team__c WHERE End_Date__c = null AND Opportunity__c = : OpportunityId)]) {
              ContactMap.put(c.id, c);
              OverallContactMap.put(c.id,c.Name);
              noOfHLEmployees ++;
              if (!ContactlinkedToTeamMemberSet.contains(c.Id))
                newContactsTobeadded++;               
            }
            AllowedMembers = newContactsTobeadded; //ContactMap.values().size();
            Set<Id> InactiveMembers = new Set<Id>();
            Set<Id> activeMembers = new Set<Id>();
            for(Opp_VP_TeamMember__c opVPtm : [SELECT staff__c,Team_Member_Status__c  FROM Opp_VP_TeamMember__c WHERE Is_Team_Member_Deactivated_Once__c = false AND staff__c IN: ContactMap.KeySet() AND Opportunity_VP_Position__c =: CurrentPositionId ORDER BY CREATEDDATE DESC])
            {
                InactiveMembers.add(opVPtm.staff__c);
            }   
            system.debug(InactiveMembers.size()+'-------'+AllowedMembers);
            InactiveMembers.addAll(tempVPTMSet);  
            AllowedMembers += InactiveMembers.size();
            return AllowedMembers;
        } set;}
        
        private void modifySet() {
            Set<Id> InactiveMembers = new Set<Id>();
            Set<Id> activeMembers = new Set<Id>();
            for(Opp_VP_TeamMember__c opVPtm : [SELECT staff__c,Team_Member_Status__c  FROM Opp_VP_TeamMember__c WHERE Is_Team_Member_Deactivated_Once__c = false  AND Opportunity_VP_Position__c =: CurrentPositionId ORDER BY CREATEDDATE DESC])
            {
               InactiveMembers.add(opVPtm.staff__c);
            }            
            InactiveMembers.addAll(tempVPTMSet);    
            AddedTeamMemberIdSet.removeAll(InactiveMembers);                        
        }
    public List<SelectOption> HLInternalEmployees {get
        {
            HLInternalEmployees = new List<SelectOption>();
            modifySet();// Added this method for SF-821
            for(Contact cont : [SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Opportunity_Internal_Team__c WHERE End_Date__c = null AND Opportunity__c = : OpportunityId) AND Id NOT IN : AddedTeamMemberIdSet ORDER BY Name ASC]) {
              HLInternalEmployees.add(new SelectOption(cont.Id, Cont.Name));
            }
            return HLInternalEmployees;
        }
        set;}
    private Id OpportunityId;
    
    public string parentId {
        get{
            return OpportunityId;
            } set;}
       
    //Refreshes the list of possible role choices for a new staff member  
    public void RefreshNewStaffRoles() {
        //StaffMemberToAdd = null;
    }
    
    public HL_ValuationPeriodPositionController(ApexPages.StandardController controller) {
        AllowedMembers = 0;
        //isPositionCancelled = false;
        tempVPTMSet = new Set<Id>();
        IsSaveRequired = false;
        ContactMap = new Map<Id, Contact>();
        OverallContactMap = new Map<Id, String>();
        HLInternalEmployees = new List<SelectOption>();
        NoOfAddedTeamMemberButNotSaved = 0;
        OppVPPosition = new Opp_VP_Position__c();
        OppVPPosition = (Opp_VP_Position__c)controller.getRecord();
        CurrentPositionId =  apexpages.currentPage().getParameters().get('id');        
        AddedTeamMemberIdSet = new Set<id>();  
        IsSupervisorOrAdmin = HL_ConstantsUtil.IsSupervisorOrAdmin();
        IsHavingPVPermissionSetOrIsSysAdmin = HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin();
        tempName = '';          
        FetchLatestTeamMembers();        
        List<Contact> ValidContactList = new List<Contact>([SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Opportunity_Internal_Team__c WHERE End_Date__c = null AND Opportunity__c = : OpportunityId)]);
            AllowedMembers = ValidContactList.size();
        VerifyAccessibilityToTM(); 
        OriginalPosition = new Opp_VP_Position__c();
        
                                        //Commenting Industry_Group_Picklist__c picklist from below query
        for(Opp_VP_Position__c vpPos1 : [SELECT Name,Industry_Group__c,Opportunity_Number__c, Asset_Classes__c, Notes__c, Report_Fee__c,Sector__c,Industry_Group_Picklist__c, Opportunity_VP__c,Company__c, Opportunity_VP__r.Opportunity__c, Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c, Opportunity_VP__r.Opportunity__r.Client__c, Opportunity_VP__r.Opportunity__r.Approval_Process__c, Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c , Status__c FROM Opp_VP_Position__c WHERE id =: CurrentPositionId ]) 
        {
            OriginalPosition = vpPos1;
            OppVPPosition = vpPos1;
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
	
	
	//To get IG&S of associated Company
    public void CompanyIGSvalues(){
		if(OppVPPosition.Company__c != null){
            selectedAcc = [SELECT id,Industry_Group__c,Sector__c from Account WHERE id=:OppVPPosition.Company__c];
        }		
    }
    
    private void FetchLatestTeamMembers() {
        
        tempVPTMSet = new Set<id>();
        VPTeamMemberList = new List<VPTeamMember>(); 

                                        //Commenting Industry_Group_Picklist__c picklist from below query
        for(Opp_VP_Position__c vpPos : [SELECT Name,Industry_Group__c,Industry_Group_Picklist__c,Sector__c , Asset_Classes__c, Notes__c, Report_Fee__c, Opportunity_VP__c,Company__c, Opportunity_VP__r.Opportunity__c, Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c, Opportunity_VP__r.Opportunity__r.Approval_Process__c, Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c , Status__c, (SELECT id, staff__c, staff__r.Name, Role__c, Start_Date__c, End_Date__c, Team_Member_Status__c, Opportunity_VP_Position__c, Is_Team_Member_Deactivated_Once__c FROM Opp_VP_TeamMembers__r ORDER BY Team_Member_Status__c DESC, staff__r.Name ASC ) FROM Opp_VP_Position__c WHERE id =: CurrentPositionId ]) 
        {
          OppVPPosition = vpPos;
          isValidPosition = true;
          isOpportunityConverted = vpPos.Opportunity_VP__r.Opportunity__r.Converted_to_Engagement__c;
          if(vpPos.Opportunity_VP__r.Opportunity__r.Approval_Process__c == label.HL_AppProcessForEngNo && vpPos.Opportunity_VP__r.Opportunity__r.Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
          {
              isOpportunityConverted = true;
          }           
          OpportunityId = vpPos.Opportunity_VP__r.Opportunity__c;
          for(Opp_VP_TeamMember__c vptm : vpPos.Opp_VP_TeamMembers__r) {
            VPTeamMemberList.add(new VPTeamMember(VPTeamMemberList.size()+1, vptm));
            if(!vptm.Is_Team_Member_Deactivated_Once__c) {
              AddedTeamMemberIdSet.add(vptm.staff__c);
              IsSaveRequired = true;
            }
            OverallContactMap.put(vptm.staff__c, vptm.staff__r.Name);
          }
          OppVpId = vpPos.Opportunity_VP__c;          
        }
        IshavingValidRoleForRevAccrual = HL_ConstantsUtil.IshavingValidRoleInInternTeamOpp(OpportunityId);        
        for(Contact c: [SELECT id, Name from Contact WHERE Id IN (SELECT Contact__c FROM Opportunity_Internal_Team__c WHERE End_Date__c = null AND Opportunity__c = : OpportunityId)])
        {
            OverallContactMap.put(c.id, c.Name);
        }
        NoOfAddedTeamMemberButNotSaved = 0;
    }
    
    public PageReference AddMember() {
        
        IsSaveRequired = true;
        VPTeamMemberList.add(new VPTeamMember(VPTeamMemberList.size()+1 , new Opp_VP_TeamMember__c(Role__c = system.Label.HL_DefaultTeamMember, Opportunity_VP_Position__c = CurrentPositionId, Start_Date__c = system.Today())));
        NoOfAddedTeamMemberButNotSaved++;
        for (VPTeamMember vptm : VPTeamMemberList) {            
          if(vptm.OppVPTeamMember.Id == null || (vptm.OppVPTeamMember.Id != null && !vptm.OppVPTeamMember.Is_Team_Member_Deactivated_Once__c)){
            AddedTeamMemberIdSet.add(vptm.SelectedStaffId);
            if(vptm.OppVPTeamMember.Id == null)
                tempVPTMSet.add(vptm.SelectedStaffId);
          }
          
          if(OverallContactMap.containsKey(vptm.SelectedStaffId))
            vptm.SelectedStaffName = OverallContactMap.get(vptm.SelectedStaffId); 
        }
        return null;
    }
       
    public PageReference RemoveMember() {
        try{
        isChangesSave = false;
        IsSaveRequired =  false;
        NoOfAddedTeamMemberButNotSaved--;
        for (VPTeamMember vptm : VPTeamMemberList) {
          vptm.SelectedStaffName = OverallContactMap.get(vptm.SelectedStaffId);
        }
        if(VPTeamMemberList != null && VPTeamMemberList.size()>0 && selectItemSrNo >0 && VPTeamMemberList[selectItemSrNo-1].OppVPTeamMember.id != null) {
            //for (Opp_VP_TeamMember__c tm : [SELECT id from Opp_VP_TeamMember__c WHERE id =: VPTeamMemberList[selectItemSrNo-1].OppVPTeamMember.id])
                Delete VPTeamMemberList[selectItemSrNo-1].OppVPTeamMember;
                NoOfAddedTeamMemberButNotSaved++;
        
        }
        if(VPTeamMemberList != null && VPTeamMemberList.size() >= selectItemSrNo && AddedTeamMemberIdSet != null && AddedTeamMemberIdSet.contains(VPTeamMemberList[selectItemSrNo-1].SelectedStaffId)){
            AddedTeamMemberIdSet.remove(VPTeamMemberList[selectItemSrNo-1].SelectedStaffId);
            tempVPTMSet.remove(VPTeamMemberList[selectItemSrNo-1].SelectedStaffId);
        }
        if(selectItemSrNo != null && VPTeamMemberList != null && VPTeamMemberList.size() >= selectItemSrNo )
            VPTeamMemberList.remove(selectItemSrNo-1);          
        Integer i = 1;      
        for (VPTeamMember vptm : VPTeamMemberList) {
            if(vptm.OppVPTeamMember.Id == null || (vptm.OppVPTeamMember.Id != null && !vptm.OppVPTeamMember.Is_Team_Member_Deactivated_Once__c))
              IsSaveRequired = true;
            vptm.SrNo = i++;
        }
        }
         catch (Exception e) {
         isErrorOnSave = true;
         isChangesSave = false;
         Apexpages.addMessages(e);
     }         
        return null;
    }
    
    public PageReference SaveTeamMembers() {        
      try{
        Map<Id, Opp_VP_TeamMember__c> MapofTM = new Map<Id, Opp_VP_TeamMember__c>([SELECT id, staff__c, staff__r.Name, Role__c, Start_Date__c, End_Date__c, Team_Member_Status__c, Opportunity_VP_Position__c, Is_Team_Member_Deactivated_Once__c FROM Opp_VP_TeamMember__c  WHERE Opportunity_VP_Position__c =: CurrentPositionId]);
        
        isErrorOnSave = false;
        List<Opp_VP_TeamMember__c> OppVPTeamMeberList = new List<Opp_VP_TeamMember__c>();       
        Opp_VP_TeamMember__c tempItem; 
        Map<Id,Opp_VP_TeamMember__c> ExistingTMMap = new Map<Id,Opp_VP_TeamMember__c>();
        String memberStr2 = '';        
        
        for (VPTeamMember vptm : VPTeamMemberList) {
            tempItem = new Opp_VP_TeamMember__c();
            tempItem = vptm.OppVPTeamMember;
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
                OppVPTeamMeberList.add(tempItem);          
                        
            if(vptm.OppVPTeamMember.Start_Date__c  != null && vptm.OppVPTeamMember.End_Date__c !=null && vptm.OppVPTeamMember.Start_Date__c > vptm.OppVPTeamMember.End_Date__c) {
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
        List<Opp_VP_TeamMember__c > VPTMstoUpdate = new List<Opp_VP_TeamMember__c >();
        for(Opp_VP_TeamMember__c OppVPTM : [Select id From Opp_VP_TeamMember__c WHERE ID IN : ExistingTMMap.KeySet() ])
            if(ExistingTMMap.containsKey(OppVPTM.id))
                VPTMstoUpdate.add(ExistingTMMap.get(OppVPTM.Id));
                
        if (VPTMstoUpdate.size() > 0) {
            update VPTMstoUpdate;            
        }
        if (OppVPTeamMeberList.size() > 0) {
            insert OppVPTeamMeberList ;
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
        public String SelectedStaffName{get;set{SelectedStaffName = value ; system.debug('---'+SelectedStaffName);}}
        public Opp_VP_TeamMember__c OppVPTeamMember{get;set;}
        
        public VPTeamMember(Integer SrNumber, Opp_VP_TeamMember__c OppVPTeamMemberParam )
        {
            OppVPTeamMember = new Opp_VP_TeamMember__c();
            if(OppVPTeamMemberParam != null) {
                OppVPTeamMember = OppVPTeamMemberParam;
                SelectedStaffId = OppVPTeamMemberParam.Staff__c;
                SelectedStaffName = OppVPTeamMemberParam.Staff__r.Name;             
            }
            SrNo = SrNumber;
        }
            
    }
    
    // To verify if logged in user is member of Group Portfolio Staffing/Portfolio Supervisor. 
    private void VerifyAccessibilityToTM() {        
        
        UserCanCreateModifyTM = false;
        UserCanDeleteTM = false;     
        
        /*for (GroupMember gm : [SELECT group.Name 
                               FROM GroupMember 
                               WHERE UserOrGroupId =: UserInfo.getUserId()])
        {
           // if(gm.group.Name == Label.HL_PV_Portfolio_Valuation_Staffing || gm.group.Name == Label.HL_PV_Portfolio_Valuation_Supervisors)   // Commented code by Harsh Singh SF-820
            if(gm.group.Name == Label.HL_PV_Portfolio_Valuation_Supervisors)
            {
                UserCanCreateModifyTM = true;
            }           
            
            if(gm.group.Name == Label.HL_PV_Portfolio_Valuation_Supervisors)
            {
                UserCanDeleteTM = true;
            }
                        
        }*/
        if(HL_OpportunityViewController.IsUserMemberofPVSuperVisorOrItschildGroup())
        {
            UserCanCreateModifyTM = true;
            UserCanDeleteTM = true;            
        }
        
        if(UserCanDeleteTM) {
            UserCanDeleteTM = false;
            for (permissionsetAssignment psa : [SELECT PermissionSet.Name 
                                                FROM permissionsetAssignment 
                                                WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'PV_Permission_Set_For_Delete'])
            {
                UserCanDeleteTM = true;                 
            }
        }
        if(!UserCanCreateModifyTM) {
            Opportunity__c Opp = new Opportunity__C(Id = OpportunityId);
            UserCanCreateModifyTM = HL_OpportunityViewController.VerifyUserforVP(Opp, 'OpportunityPV');
        }                
        for(User usr : [SELECT Id,Name, Profile.Name from User Where Id =: userinfo.getUserId()])       
        {          
            if(usr.Profile.Name == 'System Administrator')     
            {       
                UserCanCreateModifyTM = true;  
                UserCanDeleteTM = true;      
            }       
            if(usr.Profile.Name == 'System Administrator (Read Only)')     
            {       
                UserCanCreateModifyTM = false;  
                UserCanDeleteTM = false;      
            } 
        }     
    }
    
    public PageReference Backtovp() {
        string url = '/' + OppVpId ;                        
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;        
    }
    
    public PageReference DeleteRecord() { 
        string url = '/apex/HL_ValuationPeriodPositionDelete?id=' + CurrentPositionId+'&sObjectName=Opp_VP_Position__c&ReturnID='+OppVpId;                
        PageReference result = new PageReference(url);
        result.setRedirect(true);
        return result;
    } 
        
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }} 
    
    public PageReference saveRc()
    {
        try{        
            
            if((OppVPPosition.Name == null || OppVPPosition.Name == '') && tempName != '' && tempName != null)
                OppVPPosition.Name = tempName;
            /* if(OppVPPosition.Industry_Group_Picklist__c == null || OppVPPosition.Industry_Group_Picklist__c == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Industry Group: You must enter a value'));
                return null;
            }
            if(OppVPPosition.Industry_Group_Picklist__c != null && (OppVPPosition.Sector__c == null || OppVPPosition.Sector__c == '')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sector: You must enter a value'));
                return null;
            }  */
			if((selectedAcc.Industry_Group__c != null && selectedAcc.Industry_Group__c != '') && (selectedAcc.Sector__c != null && selectedAcc.Sector__c != '') &&
				(OppVPPosition.Industry_Group_Picklist__c == null || OppVPPosition.Industry_Group_Picklist__c == '') && (OppVPPosition.Sector__c == null || OppVPPosition.Sector__c == '')){
				
				OppVPPosition.Industry_Group_Picklist__c = selectedAcc.Industry_Group__c;
				OppVPPosition.Sector__c = selectedAcc.Sector__c;
			}			
			if(((selectedAcc.Industry_Group__c == null || selectedAcc.Industry_Group__c == '') || (selectedAcc.Sector__c == null || selectedAcc.Sector__c == '')) && 
			   ((OppVPPosition.Industry_Group_Picklist__c == null || OppVPPosition.Industry_Group_Picklist__c == '') || (OppVPPosition.Sector__c == null || OppVPPosition.Sector__c == ''))){
				
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_No_IG_S_on_Position));
				return null;
			}
            update OppVPPosition;
        }catch(Exception e )
        {
            ApexPages.addMessages(e);
            return null;
        }        
        return new pageReference('/'+OppVPPosition.Id);
    }
    
    public PageReference DummyReset(){         
        if(fieldAPI == 'Name'){
            OppVPPosition.Name = OriginalPosition.Name;
            tempName = OriginalPosition.Name;
        }
        else if(fieldAPI == 'Asset_Classes__c')
            OppVPPosition.Asset_Classes__c = OriginalPosition.Asset_Classes__c ;
        else if(fieldAPI == 'Notes__c')
            OppVPPosition.Notes__c = OriginalPosition.Notes__c;
        else if(fieldAPI == 'Report_Fee__c')
            OppVPPosition.Report_Fee__c = OriginalPosition.Report_Fee__c;    
        return null;
    }         
}