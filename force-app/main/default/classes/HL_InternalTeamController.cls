public class HL_InternalTeamController {
    public Opportunity__c Opp {get; set;}
    public Engagement__c Eng {get; set;}
    public String CustomFilter {get {return 'AND RecordType.Name = \'Houlihan Employee\' AND Status__c = \'Active\'';} set;}
    public String SpecialRole {get; set;}
    public String RevenueAllocation {get; set;}
    public boolean showPopup {get;set;}
    public List<String> ListOfStaffWithError {get;set;}
    public boolean isEnabledProfileUser {get;set;}
    public String JobCode {get{
        if (jobCode == null)
            jobCode = HL_JobType.GetJobCode(EntityType == 'Opportunity__c' ? Opp.Job_Type__c : Eng.Job_Type__c);
        return jobCode;
    } set;
                          }
    public Boolean IsForeign {get{
        if (isForeign == null)
            isForeign = EntityType == 'Opportunity__c' ? Opp.Is_Foreign_Office__c : Eng.Is_Foreign_Office__c;
        return isForeign;
    } set;
                             }
    //Determines if an Initiator Role Selection is Required for the Opportunity/Engagement
    public Boolean InitiatorRequired {
        get{
            return HasModifyAccess && EntityType == 'Opportunity__c' && String.isBlank(SpecialRole) && !HasInitiator;
        }
    }
    private Boolean HasInitiator {get; set;}
    public List<Staff_Role__c> StaffRolesCollection {get{
        HL_Staff_Role.RoleType rt = EntityType == 'Opportunity__c' ?  HL_Staff_Role.RoleType.Opportunity : HL_Staff_Role.RoleType.Engagement;
        HL_Staff_Role.RoleLOB roleLOB = LOB == 'CF' ? HL_Staff_Role.RoleLOB.CF : LOB == 'FVA' ? HL_Staff_Role.RoleLOB.FVA : LOB == 'FR' ? HL_Staff_Role.RoleLOB.FR : HL_Staff_Role.RoleLOB.SC;

        if (staffRolesCollection == null)
            staffRolesCollection = String.isBlank(SpecialRole) ? HL_Staff_Role.GetRoles(rt, roleLOB) : HL_Staff_Role.GetByName(SpecialRole);

        return staffRolesCollection;
    } set;
                                                    }
    
    
    //Used by the component to allow it to be embedded in other objects, but hide the return button where not applicable
    public Boolean ShowReturn {get{
        return HL_PageUtility.GetParameter('showheader') <> null ? Boolean.valueOf(HL_PageUtility.GetParameter('showheader')) : true;
    } set;
                              }
    public String LOB {get; set;}
    public Id EntityId {get; set;}
    public String EntityType {get {if (entityType == null) {entityType = HL_Utility.GetObjectTypeById(EntityId);} return entityType; } set;}
    public String EntityName {get; set;}
    public String SelectedStaffId {get; set;}
    public String SelectedStaffName {get; set;}
    public Boolean HasModifyAccess {get{
        //Opportunities shouldn't be editable once Engaged
        //Only the System Admin and CAO Profile (for their respective LOB) should have access for engagements
        if (hasModifyAccess == null) {            
            if (EntityType == 'Engagement__c') {
                if (HL_SecurityUtility.IsCAO())                    hasModifyAccess = HL_Group.IsInGroup('CAO_' + LOB);
                else
                    hasModifyAccess = HL_SecurityUtility.IsSysAdmin();
            }
            else{
                Boolean accessCheck = true;

                //For FVA, lock down the Opportunity Roles After Initial Entry (We are using the Internal Team Prompt flag as that Check)
                if(Opp.Line_Of_Business__c == 'FVA' && !Opp.Internal_Team_Prompt__c)                    accessCheck = (HL_SecurityUtility.IsCAO() && HL_Group.IsInGroup('CAO_' + LOB)) || HL_SecurityUtility.IsSysAdmin() || !String.isBlank(SpecialRole);

                hasModifyAccess = accessCheck && Opp.Stage__c <> 'Engaged';                
            }
        }
        return hasModifyAccess;
    } set;
                                   }

    public HL_InternalTeamRecord StaffMemberToAdd {get{
        if (staffMemberToAdd == null) {
            if (!String.IsBlank(SelectedStaffId))
                staffMemberToAdd = new HL_InternalTeamRecord(EntityId, EntityType, LOB, HL_Contact.GetById(SelectedStaffId), JobCode, ByPassFS, IsForeign, StaffRolesCollection, null,null);
            else                staffMemberToAdd = new HL_InternalTeamRecord(EntityId, EntityType, StaffRolesCollection);
        }

        return staffMemberToAdd;
    } set;
                                                  }
    public Map<id, String> MapOfITandRevenueAllocation ;
    public Map<Id, List<sObject>> ContactStaffRolesMap {
        get{
            if (contactStaffRolesMap == null) {
                MapOfITandRevenueAllocation = new Map<Id, String>();
                String prefix = EntityType == 'Opportunity__c' ? 'Opportunity' : 'Engagement';
                Id id = EntityId;
                Id contactId;
                String sr = SpecialRole;

                contactStaffRolesMap = new Map<Id, List<sObject>>();

                for (sObject obj : Database.Query('SELECT Contact__c, Contact__r.Name, Contact__r.Title, Contact__r.Department, Contact__r.Is_Foreign_Office__c, ' +
                                                  '       Contact__r.Office__c, Contact__r.Revenue_Allocation__c, Contact__r.Line_Of_Business__c, Contact__r.Industry_Group__C, Contact__r.Registered__c, Contact__r.Staff_Type__c, ' +
                                                  '       Staff_Role__r.Name, Start_Date__c, End_Date__c,Revenue_Allocation__c ' +
                                                  'FROM ' + prefix + '_Internal_Team__c ' +
                                                  'WHERE Staff_Role__c <> null AND Contact__c <> null AND End_Date__c=null AND ' + prefix + '__r.id=:id ' + (!String.isBlank(SpecialRole) ? 'AND Staff_Role__r.Name =:sr ' : '')))
                {

                    if (prefix == 'Opportunity'){
                        contactId = ((Opportunity_Internal_Team__c)obj).Contact__c;
                        if(((Opportunity_Internal_Team__c)obj).Revenue_Allocation__c != null){                            if(!MapOfITandRevenueAllocation.containsKey(contactId))                            {                                           MapOfITandRevenueAllocation.put(contactId,((Opportunity_Internal_Team__c)obj).Revenue_Allocation__c);
                            }   
                        }
                    }else{
                        contactId = ((Engagement_Internal_Team__c)obj).Contact__c;
                        if(((Engagement_Internal_Team__c)obj).Revenue_Allocation__c != null){                            if(!MapOfITandRevenueAllocation.containsKey(contactId))                            {                                           MapOfITandRevenueAllocation.put(contactId,((Engagement_Internal_Team__c)obj).Revenue_Allocation__c);
                            }   
                        }
                    }
                    
                    if (contactStaffRolesMap.get(contactId) == null)
                        contactStaffRolesMap.put(contactId, new List<sObject> {obj});
                    else {                        List<sObject> revisedStaffRoleList = contactStaffRolesMap.get(contactId);                        revisedStaffRoleList.add(obj);                        contactStaffRolesMap.put(contactId, revisedStaffRoleList);
                    }
                }
            }
            return contactStaffRolesMap;
        }
        set;
    }

    //The CAO/CF Users would like to bypass the FS Restriction for them (FS Checkbox on the Staff Role)
    //The Compliance/Registration Requirements will still need to be met
    public Boolean BypassFS {
        get{
            if (bypassFS == null)
                bypassFS = HL_Group.IsInGroup('CAO_CF');

            return bypassFS;
        }
        set;
    }

    public HL_InternalTeamController(ApexPages.StandardController controller) {   this(controller.getId());showPopup = false;
    }
    public HL_InternalTeamController() {
        this(HL_PageUtility.GetParameter('Id'));
        showPopup = false;
        ListOfStaffWithError = new List<String>();
        Set<String> AllowedProfileOrUserIdSet = new Set<String>();
        
        for( Office_Allocation_Profile_List__mdt  OfficeAllocationProfile  : [Select Profile_Name__c,User_ID__c,Security_Type__c From Office_Allocation_Profile_List__mdt ])
        {
            if(OfficeAllocationProfile.Security_Type__c == 'Profile Name'){
                AllowedProfileOrUserIdSet.add(OfficeAllocationProfile.Profile_Name__c);
            } else{
                if(OfficeAllocationProfile.User_ID__c != null && OfficeAllocationProfile.User_ID__c.length() >= 15)
                    AllowedProfileOrUserIdSet.add(OfficeAllocationProfile.User_ID__c.substring(0,15));
            }
        }
        
        if(AllowedProfileOrUserIdSet.size()>0)
        {        
            for(User u : [Select Id, Profile.Name From User Where Id =: userinfo.getUserId()]){
                if(AllowedProfileOrUserIdSet.contains(u.Profile.Name) || AllowedProfileOrUserIdSet.contains(string.valueof(u.Id).substring(0,15)))
                {
                    isEnabledProfileUser = true;
                }
            }
        }        
    }
    public HL_InternalTeamController(Id entityRecordId) {
        EntityId = entityRecordId;
        HasInitiator = false;

        if (EntityType == 'Opportunity_Approval__c') {            EntityId = HL_OpportunityApproval.GetById(entityRecordId).Related_Opportunity__c;            EntityType = 'Opportunity__c';
        }

        if (EntityType == 'Opportunity__c') {
            Opp = HL_Opportunity.GetById(EntityId);
            EntityName = Opp.Name;
            LOB = Opp.Line_of_Business__c;
        }
        else if (EntityType == 'Engagement__c') {
            Eng = HL_Engagement.GetById(EntityId);
            EntityName = Eng.Name;
            LOB = Eng.Line_of_Business__c;
        }
    }

    public List<HL_InternalTeamRecord> TeamRecords {get {
        if (teamRecords == null) {
            Contact c;
            Map<Id, HL_InternalTeamRecord> internalTeamMap = new Map<Id, HL_InternalTeamRecord>();
            HL_InternalTeamRecord itr;
            String roleDescription;
            HasInitiator = false;

            teamRecords = new List<HL_InternalTeamRecord>();

            //Create a map of the staff member to their roles
            for (Id contactId : ContactStaffRolesMap.keySet()) {
                RevenueAllocation = null;
                List<sObject> roleList = ContactStaffRolesMap.get(contactId);

                if (EntityType == 'Opportunity__c'){
                    c = ((Opportunity_Internal_Team__c)roleList[0]).Contact__r;
                    //RevenueAllocation = c.Revenue_Allocation__c != null ? c.Revenue_Allocation__c : c.Office__c ;
                    if(c != null && MapOfITandRevenueAllocation.containsKey(c.Id))                        RevenueAllocation = MapOfITandRevenueAllocation.get(c.Id);
                    
                }else{
                    c = ((Engagement_Internal_Team__c)roleList[0]).Contact__r;
                    //RevenueAllocation = c.Revenue_Allocation__c != null ? c.Revenue_Allocation__c : c.Office__c ;
                    if(c != null && MapOfITandRevenueAllocation.containsKey(c.Id))                        RevenueAllocation = MapOfITandRevenueAllocation.get(c.Id);
                }
                if (!internalTeamMap.containsKey(contactId)) {
                    itr = new HL_InternalTeamRecord(EntityId, EntityType, LOB, c, JobCode, ByPassFS, IsForeign, StaffRolesCollection, roleList,RevenueAllocation);
                    if (!HasInitiator)
                        HasInitiator = itr.ActiveRolesSet.contains('Initiator');
                    internalTeamMap.put(contactId, itr);
                }

            }

            for (String id : internalTeamMap.keySet())
                teamRecords.add(internalTeamMap.get(id));               
            
        }

        //Sort based on our comparable method
        teamRecords.sort();

        return teamRecords;
    } set;
                                                   }

    private void SaveAddedMember(List<sObject> insertList,List<sObject> updateList) {
        if (SelectedStaffId <> '') {
            HL_InternalTeamRecord tr = StaffMemberToAdd;
            tr.ContactId = SelectedStaffId;

            if (!String.IsBlank(SpecialRole)) {                HL_InternalTeamRecord.StaffRoleAssignment sra = new HL_InternalTeamRecord.StaffRoleAssignment(StaffRolesCollection[0], true, true);                tr.RoleAssignments = new List<HL_InternalTeamRecord.StaffRoleAssignment> {sra};
                    }

            //Verify at least one role was selected
            if (tr.HasRoleAssigned) {
                //We still need to check for both here in case they choose a staff member
                //who is already on the team
                insertList.addAll(tr.GetRoleUpdates());
                updateList.addAll(tr.GetRoleInserts());
                SelectedStaffId = null;
                SelectedStaffName = null;
                StaffMemberToAdd = null;
            }
            else
                HL_PageUtility.ShowError('Please Select at least one Role for the New Team Member.');
        }
    }
    
    public void SaveTeamEdits() {
        SL_ManageSharingRules.ENABLE_ASYNCHRONOUS_SHARING = true;
        
        showPopup = true; 
        
        if (HasModifyAccess) {
            try {
                Map<Id, Set<Id>> ExistingRoleMap = new Map<Id, Set<Id>>();
                Map<Id, Set<Id>> RemovingRoleMap = new Map<Id, Set<Id>>();
                Map<Id, Set<Id>> AddingRoleMap =   new Map<Id, Set<Id>>();
                Map<Id, String> StaffIdNameMap =   new Map<Id,String>();
                ListOfStaffWithError = new List<String>();
                if(EntityType == 'Opportunity__c')
                {
                    for(Opportunity_Internal_Team__c OItm :[Select Id,Revenue_Allocation__c ,Contact__r.Revenue_Allocation__c, Contact__c,Contact__r.Name, Contact__r.Office__c, Staff_Role__c  From Opportunity_Internal_Team__c Where End_date__c = null AND Opportunity__c =: Opp.Id]){
                        iF((OITm.Contact__r.Revenue_Allocation__c != null && OITm.Revenue_Allocation__c != OITm.Contact__r.Revenue_Allocation__c) || (OITm.Contact__r.Revenue_Allocation__c == null && OITm.Revenue_Allocation__c != OITm.Contact__r.Office__c)){
                        
                            iF(!ExistingRoleMap.ContainsKey(OITm.Contact__c))                            {                                ExistingRoleMap.put(OITm.Contact__c, new Set<Id>{OITm.Staff_Role__c});
                            }
                            else
                            {
                                ExistingRoleMap.get(OITm.Contact__c).add(OITm.Staff_Role__c);                            }                            StaffIdNameMap.put(OITm.Contact__c, OITm.Contact__r.Name); 
                        }
                    }
                }
                else if(EntityType == 'Engagement__c')
                {
                    for(Engagement_Internal_Team__c EITm: [Select Id,Revenue_Allocation__c ,Contact__r.Revenue_Allocation__c, Contact__c, Contact__r.Name,Contact__r.Office__c, Staff_Role__c From Engagement_Internal_Team__c Where End_date__c = null AND Engagement__c =: Eng.Id])
                    {
                        iF((EITm.Contact__r.Revenue_Allocation__c != null && EITm.Revenue_Allocation__c != EITm.Contact__r.Revenue_Allocation__c) || (EITm.Contact__r.Revenue_Allocation__c == null && EITm.Revenue_Allocation__c != EITm.Contact__r.Office__c)){                        
                            iF(!ExistingRoleMap.ContainsKey(EITm.Id))                            {                                ExistingRoleMap.put(EITm.Contact__c, new Set<Id>{EITm.Staff_Role__c});
                            }
                            else
                            {
                                ExistingRoleMap.get(EITm.Contact__c).add(EITm.Staff_Role__c);                            }                            StaffIdNameMap.put(EITm.Contact__c, EITm.Contact__r.Name);
                        }
                    }
                }
                
                
                for (HL_InternalTeamRecord tr : TeamRecords) {                        
                    if(EntityType == 'Opportunity__c') {
                        for(Sobject rmvItem :tr.GetRoleUpdates()){
                            iF(!RemovingRoleMap.ContainsKey(((Opportunity_Internal_Team__c)rmvItem).Contact__c))                            {                                RemovingRoleMap.put(((Opportunity_Internal_Team__c)rmvItem).Contact__c, new Set<Id>{((Opportunity_Internal_Team__c)rmvItem).Staff_Role__c});
                            }
                            else
                            {
                                RemovingRoleMap.get(((Opportunity_Internal_Team__c)rmvItem).Contact__c).add(((Opportunity_Internal_Team__c)rmvItem).Staff_Role__c);
                            }
                        }
                        
                        for(Sobject AddItem : tr.GetRoleInserts()){
                            iF(!AddingRoleMap.ContainsKey(((Opportunity_Internal_Team__c)AddItem).Contact__c))                            {                                 AddingRoleMap.put(((Opportunity_Internal_Team__c)AddItem).Contact__c, new Set<Id>{((Opportunity_Internal_Team__c)AddItem).Staff_Role__c});
                            }
                            else
                            {
                                AddingRoleMap.get(((Opportunity_Internal_Team__c)AddItem).Contact__c).add(((Opportunity_Internal_Team__c)AddItem).Staff_Role__c);
                            }
                        }
                    }
                    else if(EntityType == 'Engagement__c') {                        for(Sobject rmvItem :tr.GetRoleUpdates()){                            iF(!RemovingRoleMap.ContainsKey(((Engagement_Internal_Team__c)rmvItem).Contact__c))
                            {
                                RemovingRoleMap.put(((Engagement_Internal_Team__c)rmvItem).Contact__c, new Set<Id>{((Engagement_Internal_Team__c)rmvItem).Staff_Role__c});
                            }
                            else
                            {
                                RemovingRoleMap.get(((Engagement_Internal_Team__c)rmvItem).Contact__c).add(((Engagement_Internal_Team__c)rmvItem).Staff_Role__c);
                            }
                        }
                        
                        for(Sobject AddItem : tr.GetRoleInserts()){                            iF(!AddingRoleMap.ContainsKey(((Engagement_Internal_Team__c)AddItem).Contact__c))                            {                                AddingRoleMap.put(((Engagement_Internal_Team__c)AddItem).Contact__c, new Set<Id>{((Engagement_Internal_Team__c)AddItem).Staff_Role__c});
                            }
                            else
                            {
                                AddingRoleMap.get(((Engagement_Internal_Team__c)AddItem).Contact__c).add(((Engagement_Internal_Team__c)AddItem).Staff_Role__c);
                            }
                        }
                    }                    
                    }
                    if(AddingRoleMap != null && AddingRoleMap.KeySet() != null && AddingRoleMap.KeySet().Size() > 0)
                    {   
                        for(Id AddingContactId : AddingRoleMap.KeySet())
                        {
                            
                            If(ExistingRoleMap.containsKey(AddingContactId) && !RemovingRoleMap.containsKey(AddingContactId))                                ListOfStaffWithError.add(StaffIdNameMap.get(AddingContactId));
                            If((RemovingRoleMap.containsKey(AddingContactId) && ExistingRoleMap.containsKey(AddingContactId)))
                                if(!RemovingRoleMap.get(AddingContactId).ContainsAll(ExistingRoleMap.get(AddingContactId)))                                {                                    ListOfStaffWithError.add(StaffIdNameMap.get(AddingContactId));
                                }
                        }
                    }
                    if(ListOfStaffWithError != null && ListOfStaffWithError.size() == 0) 
                    {
                        SaveTeamEditsFinal();
                    }
                    
            }
            catch (DmlException ex) {showPopup = false;                 HL_PageUtility.ShowError(ex);
            }
        }
        else{
            showPopup = false; 
            HL_PageUtility.ShowError('Insufficient Rights to Modify Roles');
        }
    }

    public void SaveTeamEditsFinal() {
        List<SObject> upsertList = new List<SObject>();
        List<SObject> updateList = new List<SObject>();
        List<SObject> insertList = new List<SObject>();
        if (HasModifyAccess) {
            Try{
                for (HL_InternalTeamRecord tr : TeamRecords) {
                    updateList.addAll(tr.GetRoleUpdates());
                    insertList.addAll(tr.GetRoleInserts());
                }
                TeamRecords = null;
                ContactStaffRolesMap = null;               

                // Graham MacRobie, February 16, 2022 - prevent recursion, excessive SOQL queries
                SL_ManageSharingRules.DISABLE_SHARING_RULES_PROCESS = true;

                //Save Added Member at Same Time
                SaveAddedMember(updateList, insertList);
                UpsertChanges(updateList, insertList);
                
                SL_ManageSharingRules.DISABLE_SHARING_RULES_PROCESS = false;

                if (EntityType == 'Opportunity__c') {
                    SL_ManageSharingRules.manageSharingRules(insertList, 'Opportunity__c', 'Opportunity_Internal_Team__c', 'insert');

                } else {
                    SL_ManageSharingRules.manageSharingRules(insertList, 'Engagement__c', 'Engagement_Internal_Team__c', 'insert');
                }
                           
                if (!ApexPages.hasMessages())
                    HL_PageUtility.ShowConfirm(String.IsBlank(SpecialRole) ? 'Staff Roles Updated.' : 'Officers Updated');
                showPopup = false;
            }
            catch (DmlException ex) {  HL_PageUtility.ShowError(ex);
            }
        }
        else{       
             showPopup = false;     HL_PageUtility.ShowError('Insufficient Rights to Modify Roles');
        }        
    }
    
    public void CancelIt(){ showPopup = false;
        
    } 

    //For upsertList, we cannot use a generic sObject so must type cast back
    //Ran into troubles casting the whole list without looping through
    private void UpsertChanges(List<SObject> updateList, List<SObject> insertList) {
        
        if (updateList.size() > 0 || insertList.size() > 0 ) {
            if (EntityType == 'Opportunity__c') {
                List<Opportunity_Internal_Team__c> oitUpdateList = new List<Opportunity_Internal_Team__c>();
                List<Opportunity_Internal_Team__c> oitInsertList = new List<Opportunity_Internal_Team__c>();
                for (sObject obj : updateList)
                    oitUpdateList.add((Opportunity_Internal_Team__c)obj); 
                if(oitUpdateList.size() > 0 )
                    update oitUpdateList;
                for (sObject obj : insertList)
                    oitInsertList.add((Opportunity_Internal_Team__c)obj); 
                if(oitInsertList .size() > 0 )
                    insert oitInsertList ;
            }
            else {
                List<Engagement_Internal_Team__c> eitUpdateList = new List<Engagement_Internal_Team__c>();
                List<Engagement_Internal_Team__c> eitInsertList = new List<Engagement_Internal_Team__c>();
                for (sObject obj : updateList)
                    eitUpdateList.add((Engagement_Internal_Team__c)obj); 
                if(eitUpdateList.size() > 0)
                    update eitUpdateList;
                for (sObject obj : insertList)
                    eitInsertList.add((Engagement_Internal_Team__c)obj); 
                if(eitInsertList.size() > 0)
                    insert eitInsertList ;
            }
        }
    }

    //Refreshes the list of possible role choices for a new staff member
    public void RefreshNewStaffRoles() {
        StaffMemberToAdd = null;
    }

    public PageReference EditClicked() {
        String theme = userInfo.getUIThemeDisplayed();
        PageReference redirect;
        if(theme.contains('4')){
            redirect = new PageReference('/lightning/cmp/c__redirectHL_InternalTeam?c__recordId=' + EntityId + '&c__type=' + EntityType);
        }else{
            redirect = new PageReference('/apex/HL_InternalTeamModifyView?id=' + EntityId + '&type=' + EntityType);
        }
        //PageReference 
         
        redirect.setRedirect(true);
        return redirect;
    }

    public PageReference BackToEntity() {
        if (Opp <> null && Opp.Internal_Team_Prompt__c && !InitiatorRequired) {
            Opp.Internal_Team_Prompt__c = false;
            update Opp;
        }
        else if (InitiatorRequired) {
            Opp.Internal_Team_Prompt__c = true;
            update Opp;
        }
        return new PageReference('/' + EntityId);
    }
   
}