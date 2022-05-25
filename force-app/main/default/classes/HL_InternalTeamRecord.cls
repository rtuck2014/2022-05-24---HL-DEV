global with sharing class HL_InternalTeamRecord implements Comparable {
    public String ContactId {get; set;}
    public Id EntityId {get; set;}
    public String EntityType {get; set;}
    public String JobCode {get; set;}
    public String OfficeAllocationText {get;set;}
    public String RevenueAllocation {get;set;}
    public Contact ContactRecord {get
        {
            if (contactRecord == null)
                contactRecord = HL_Contact.GetById(ContactId);

            return contactRecord;
        } set;
    }
    public List<Staff_Role__c> AllowedRoles {get; set;}
    public Set<String> AllowedRolesSet {
        get{
            if (allowedRolesSet == null) {
                allowedRolesSet = new Set<String>();
                for (Staff_Role__c sr : AllowedRoles)
                    allowedRolesSet.add(sr.Name);
            }
            return allowedRolesSet;
        } set;
    }
    public List<StaffRoleAssignment> RoleAssignments {get
        {
            if (roleAssignments == null) {
                roleAssignments = new List<StaffRoleAssignment>();
                for (Staff_Role__c sr : StaffRoles)
                    roleAssignments.Add(New StaffRoleAssignment(sr, ActiveRolesSet.contains(sr.Name), AllowedRolesSet.contains(sr.Name)));
            }
            return roleAssignments;
        } set;
    }
    public Boolean HasRoleAssigned {get{
            Boolean roleAssigned = false;
            for (StaffRoleAssignment sra : RoleAssignments) {
                if (sra.Assigned) {
                    roleAssigned = true;
                    break;
                }
            }
            return roleAssigned;
        }
    }
    public List<Staff_Role__c> StaffRoles {get; set;}
    private Map<String, Id> StaffRoleMap {get
        {
            if (staffRoleMap == null) {
                staffRoleMap = new Map<String, Id>();
                for (Staff_Role__c sr : StaffRoles)
                    staffRoleMap.put(sr.Name, sr.Id);
            }
            return staffRoleMap;
        } set;
    }
    public Set<String> ActiveRolesSet {get {return new Set<String>(ActiveRoles);}}
    public List<String> ActiveRoles {get; set;}
    public String ActiveRolesString {get {String roles = ''; for (String s : ActiveRoles) roles += s + ':'; return roles;}}
    public List<SObject> CurrentRoles {get {
        if (currentRoles == null) {
                if (EntityType == 'Opportunity__c') {
                    currentRoles = [SELECT Id, Staff_Role__r.Name, Start_Date__c, End_Date__c FROM Opportunity_Internal_Team__c WHERE Staff_Role__c <> null AND Contact__c = : ContactId AND Opportunity__c = : EntityId AND (End_Date__c = :null OR End_Date__c > : Date.Today())];
                }
                else {
                    currentRoles = [SELECT Id, Staff_Role__r.Name, Start_Date__c, End_Date__c FROM Engagement_Internal_Team__c WHERE Staff_Role__c <> null AND Contact__c = : ContactId AND Engagement__c = : EntityId AND (End_Date__c = :null OR End_Date__c > : Date.Today())];
                }
            }
            return currentRoles;
        } set;
    }

    public HL_InternalTeamRecord(Id entityId, String entityType, List<Staff_Role__c> srList) {
        this.EntityId = entityId;
        this.EntityType = entityType;
        this.StaffRoles = srList;
        this.AllowedRoles = new List<Staff_Role__c>();
        this.ActiveRoles = new List<String>();
    }

    public HL_InternalTeamRecord(Id entityId,  String entityType, String lob, Contact c, String jobCode, Boolean bypassFS, Boolean isForeign, List<Staff_Role__c> srList, List<sObject> currentRolesList, String RevenueAllocation) {
        List<String> rolesAvail = new List<String>();
        this.ActiveRoles = new List<String>();
        this.EntityId = entityId;
        this.EntityType = entityType;
        this.JobCode = jobCode;
        this.StaffRoles = srList;
        this.AllowedRoles = HL_Staff_Role.FilterSelectableRoles(c, lob, jobCode, bypassFS, isForeign, srList);
        this.ContactId = c.Id;
        this.ContactRecord = c;
        this.OfficeAllocationText = RevenueAllocation;
        this.CurrentRoles = currentRolesList;
        for (SObject r : CurrentRoles)
            this.ActiveRoles.add(EntityType == 'Opportunity__c' ? ((Opportunity_Internal_Team__c)r).Staff_Role__r.Name : ((Engagement_Internal_Team__c)r).Staff_Role__r.Name);
    }

    public List<SObject> GetRoleUpdates() {
        List<SObject> rolesToUpdate = new List<SObject>();
        Set<String> assignedRoleSet = new Set<String>();
        for (StaffRoleAssignment sra : RoleAssignments) {
            if (sra.Assigned)
                assignedRoleSet.add(sra.StaffRole);
        }

        //End Date any Removed Roles
        for (SObject cr : CurrentRoles) {
            if (!assignedRoleSet.Contains(EntityType == 'Opportunity__c' ? ((Opportunity_Internal_Team__c)cr).Staff_Role__r.Name : ((Engagement_Internal_Team__c)cr).Staff_Role__r.Name)) {
                cr.put('End_Date__c', Date.today());
                rolesToUpdate.add(cr);
            }
        }

        return rolesToUpdate;
    }

    public List<SObject> GetRoleInserts() {
        String roleId;
        List<SObject> rolesToInsert = new List<SObject>();
        Set<String> assignedRoleSet = new Set<String>();
        Set<String> currentRoleSet = new Set<String>();
        for (StaffRoleAssignment sra : RoleAssignments) {
            if (sra.Assigned)
                assignedRoleSet.add(sra.StaffRole);
        }

        //Get Current Role Set
        for (SObject cr : CurrentRoles) {
            if (assignedRoleSet.Contains(EntityType == 'Opportunity__c' ? ((Opportunity_Internal_Team__c)cr).Staff_Role__r.Name : ((Engagement_Internal_Team__c)cr).Staff_Role__r.Name))
            {
                currentRoleSet.Add(EntityType == 'Opportunity__c' ? ((Opportunity_Internal_Team__c)cr).Staff_Role__r.Name : ((Engagement_Internal_Team__c)cr).Staff_Role__r.Name);
            }
        }

        //Add New Roles
        assignedRoleSet.removeAll(currentRoleSet);
        for (String role : assignedRoleSet) {
            roleId = staffRoleMap.get(role);
            if (EntityType == 'Opportunity__c')
                rolesToInsert.Add(New Opportunity_Internal_Team__c(Opportunity__c = EntityId, Contact__c = ContactId, Staff_Role__c = roleId, Start_Date__c = Date.today()));
            else
                rolesToInsert.Add(New Engagement_Internal_Team__c(Engagement__c = EntityId, Contact__c = ContactId, Staff_Role__c = roleId, Start_Date__c = Date.today()));
        }

        return rolesToInsert;
    }


    global Integer compareTo(Object compareTo) {
        HL_InternalTeamRecord tr = (HL_InternalTeamRecord)compareTo;
        Set<String> activeRolesSet = new Set<String>(ActiveRoles);
        Set<String> compareToActiveRolesSet = new Set<String>(tr.ActiveRoles);
        Decimal displayOrder01 = 0, displayOrder02 = 0;
        for (Staff_Role__c sr : StaffRoles) {
            if (activeRolesSet.contains(sr.Name)) {
                displayOrder01 = sr.Display_Order__c;
                break;
            }
        }
        for (Staff_Role__c sr : StaffRoles) {
            if (compareToActiveRolesSet.contains(sr.Name)) {
                displayOrder02 = sr.Display_Order__c;
                break;
            }
        }
        return displayOrder01 > displayOrder02 ? 1 :
               displayOrder01 < displayOrder02 ? -1 :
               ContactRecord.Name > tr.ContactRecord.Name ? 1 :
               ContactRecord.Name < tr.ContactRecord.Name ? -1 : 0;
    }

    public class StaffRoleAssignment {
        public Id StaffRoleId {get; set;}
        public String StaffRole {get; set;}
        public String DisplayName {get; set;}
        public Boolean Assigned {get; set;} //Is the Role Assigned
        public Boolean Allowed {get; set;}  //Is the Role Allowed for Assignment
        public StaffRoleAssignment(Staff_Role__c sr, Boolean isAssigned, Boolean isAllowed) {
            StaffRoleId = sr.Id;
            StaffRole = sr.Name;
            DisplayName = sr.Display_Name__c;
            Assigned = isAssigned;
            Allowed = isAllowed;
        }
    }
}