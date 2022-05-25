Public Class HL_ConstantsUtil {

    Public Static Boolean StopValidation = false; 
    Public Static Boolean AllowExecutionForManualInsertEngCounterparty = true;
    // Purpose is to stop populating company Name in to VP Position Name while importing
    Public Static Boolean stopCopyingNameFromCompToPosition = false; 
    Public Static Boolean stopExecutionForPVConversion = false; 
    Public Static Boolean engagementValue = false;
    Public Static list<Engagement_Internal_Team__c> EngInternalTeamMemberList = new list<Engagement_Internal_Team__c>();
    Public Static List<Group> PVGroupList = new List<Group>();
    Public Static List<Delegate_Public_Group__c> DPGroupList = new List<Delegate_Public_Group__c>();
    Public Static Boolean stopExecuteEstFeeUpdateTrigger = false;
    Public Static Boolean ToStopChangesStatusToCancelled = true;
    Public Static Boolean ToStopChangesCurrency = true;
    Public Static Boolean stopUpdatingPVValueStatusChange = false;
    Public Static Boolean resultFromSupervisorCalculation = false;
    Public Static Boolean isSupervisorMethodExecuted = false;
    //Public Static Boolean stopValidationFromInactiveContact = false;
    Public Static Boolean ToStopRecursionOfEEThandler = true;
    Public Static Boolean AllowExecutionCoverageTeamTriggerFlow = true;
    Public Static User currentLoggedInUser;
    Public Static Boolean stopContractCreationOnConversion = false; 
    Public Static Boolean stopEngagementLegalEntityChangeTrigger = false; 
    Public Static Boolean stopEngagementCurrencyChangeTrigger = false; 
    Public Static Boolean stopOpportunityLegalEntityChangeTrigger = false;
    Public Static Boolean stopEngagementContractChangeTrigger = false;
    Public Static Boolean automatedContractCreation = false;
    Public Static Boolean stopOpportunityCurrencyChangeTrigger = false; 
    public static Boolean IsSupervisorOrAdmin(){
        boolean isSupervisorOrAdmin = false;              
        isSupervisorOrAdmin  = HL_OpportunityViewController.IsUserMemberofPVSuperVisorOrItschildGroup();           
        if(!isSupervisorOrAdmin){
            User u = currentLoggedInUser != null ? currentLoggedInUser : EventExpensecurrentLoggedInUser();
            if(u.Profile.Name == 'System Administrator')
                isSupervisorOrAdmin = true;  
        }       
        return isSupervisorOrAdmin;
    }    
       
    public static Boolean IsHavingPVPermissionSetOrIsSysAdmin (){
        boolean IsHavingPVPermissionSetOrisSysAdmin = false;                                      
        User u = currentLoggedInUser != null ? currentLoggedInUser : EventExpensecurrentLoggedInUser();
        if(u.Profile.Name == 'System Administrator')
            IsHavingPVPermissionSetOrisSysAdmin = true;
        
        if(!IsHavingPVPermissionSetOrisSysAdmin ){
            for(PermissionSetAssignment  PSA : [SELECT Id from PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: Label.HL_PVPermissionSetName])
            {
                IsHavingPVPermissionSetOrisSysAdmin = true;            
            }       
        } 
        return IsHavingPVPermissionSetOrisSysAdmin ;
    }    
    
    // Method to identify if logged in user's role with respect to deal team on Engagement
    public static Boolean IshavingValidRoleInInternTeamEng(Id EngagementId){
        boolean isHavingValidRoleOrSupervisor = false;
        list<String> RoleList = new list<String>();
        RoleList = system.label.HL_ValidRolesForRevenueAccrual.split(';');
        Set<Id> SetofValidDealTeamMembers = new Set<Id>();
        for (Engagement_Internal_Team__c eit : [SELECT Id,Contact__r.User__c FROM Engagement_Internal_Team__c where End_Date__c = null AND Engagement__c =: EngagementId AND Role__c IN : RoleList ]){
            SetofValidDealTeamMembers.add(eit.Contact__r.User__c);            
        }  
        Set<Id> SetOFMasterUserIds = new Set<Id>();
        for(Delegate_Public_Group_Member__c DGM : [Select id , Delegate_Public_Group__r.Banker__c From Delegate_Public_Group_Member__c Where Delegate__c =: userInfo.getUserId()])
        {
            if(DGM.Delegate_Public_Group__r.Banker__c != null)
                SetOFMasterUserIds.add(DGM.Delegate_Public_Group__r.Banker__c);
        }
        SetOFMasterUserIds.add(userInfo.getUserId());
        for(ID containuser : SetOFMasterUserIds){        
            if(SetofValidDealTeamMembers.contains(containuser))
            {
                isHavingValidRoleOrSupervisor = true;
                break;
            }            
        }        
        if(!isHavingValidRoleOrSupervisor)
            isHavingValidRoleOrSupervisor = IsSupervisorOrAdmin();
        
        if(!isHavingValidRoleOrSupervisor){
            User u = currentLoggedInUser != null ? currentLoggedInUser : EventExpensecurrentLoggedInUser();
            if(u.Profile.Name == 'System Administrator (Read Only)')
                isHavingValidRoleOrSupervisor = true;  
        }
        return isHavingValidRoleOrSupervisor;
    }
    
    // Method to identify if logged in user's role with respect to deal team on Opportunity
    public static Boolean IshavingValidRoleInInternTeamOpp(Id opportunityId){
        boolean isHavingValidRoleOrSupervisor = false;
        list<String> RoleList = new list<String>();
        RoleList = system.label.HL_ValidRolesForRevenueAccrual.split(';');
        Set<Id> SetofValidDealTeamMembers = new Set<Id>();        
        for (Opportunity_Internal_Team__c eit : [SELECT Id,Contact__r.User__c FROM Opportunity_Internal_Team__c where End_Date__c = null AND Opportunity__c =: opportunityId AND Role__c IN : RoleList]){
            SetofValidDealTeamMembers.add(eit.Contact__r.User__c);            
        }  
        Set<Id> SetOFMasterUserIds = new Set<Id>();        
        for(Delegate_Public_Group_Member__c DGM : [Select id , Delegate_Public_Group__r.Banker__c From Delegate_Public_Group_Member__c Where Delegate__c =: userInfo.getUserId()])
        {
            if(DGM.Delegate_Public_Group__r.Banker__c != null)
                SetOFMasterUserIds.add(DGM.Delegate_Public_Group__r.Banker__c);               
        }
        SetOFMasterUserIds.add(userInfo.getUserId());        
        for(ID containuser : SetOFMasterUserIds){        
            if(SetofValidDealTeamMembers.contains(containuser))
            {
                isHavingValidRoleOrSupervisor = true;
                break;
            }
        }     
        if(!isHavingValidRoleOrSupervisor)
            isHavingValidRoleOrSupervisor = IsSupervisorOrAdmin();
        if(!isHavingValidRoleOrSupervisor)
        {
            
            User u = currentLoggedInUser != null ? currentLoggedInUser : EventExpensecurrentLoggedInUser();
            if(u.Profile.Name == 'System Administrator (Read Only)')
                    isHavingValidRoleOrSupervisor = true;  
        }
        return isHavingValidRoleOrSupervisor;
    }
    
    //Event Expense Filter Section Changes
    public static final map<String, String> DATE_PARAM_MAP = new map<String, String>{'--None--' => '--None--','30 days' => 'LAST_N_DAYS:30', '60 days' => 'LAST_N_DAYS:60',
        'This year' => 'THIS_YEAR', 'Last year' => 'LAST_YEAR', 'This quarter' => 'THIS_QUARTER', 'Last quarter' => 'LAST_QUARTER'};
    
    //Map to maintain the dependency for Event Type to Event Format Picklist             
    public static map<String, list<String>> EVENTTYPE_TO_EVENTFORMAT_MAP = new map<String, list<String>>{
      'ADM - Staff Entertainment' => new list<String> {'Staff Entertainment'},
      'MKTG - Client Entertainment' => new list<String> {'Client Entertainment', 'Client Gifts','Closing Party','External Client Meeting','Sporting Events','Other Client Entertainment'},
      'MKTG - Conference/ Seminar' => new list<String> {'Branding and Leadership (IP)','Conference/Seminar','Networking Events','Professional Memberships','Sponsorship / Charity Events','Talent Development','Other Professional Event'},
      'ADM - Administrative' => new list<String> {'FVA Management Request','FY Annual Meeting','Service Line Request'},
      'MKTG - Marketing Trip' => new list<String> {'Local Marketing', 'Regional Marketing'},
      'MKTG - Marketing Membership' => new list<String> {'Marketing Membership'},
      'Staff Entertainment' => new list<String> {'Group Meals', 'Holiday Party', 'Other', 'Teambuilding Activity', 'Team Drinks'},
      'Client Entertainment' => new list<String> {'N/A'},
      'Administrative' => new list<String> {'CF Charitable Contribution Match', 'Offsite Meeting', 'Other', 'Training'},
      'Branding and Advertising' => new list<String> {'N/A'},
      'Conference/Summit/Seminar' => new list<String> {'N/A'},
      'HL Hosted Client Event' => new list<String> {'N/A'},
      'HL Hosted Client Event (during 3rd - party events)' => new list<String> {'N/A'},
      'Membership Dues' => new list<String> {'N/A'},
      'Sponsorship' => new list<String> {'N/A'},
      'Third Party Conference/Seminar Attendance' => new list<String> {'N/A'}
    };
    
    /*********************************************************************
    Method to build WHERE Clause of main list of event Expenses to display
    **********************************************************************/
    public static String buildEventExpenseWhereClause(Event_Expense__c eventExp, String logicCriteriaSelVal, String submissionDateSelVal, String createdDateSelVal, String evtExpNumberVal){
        
        String filterLogicString, filtersubmissionDate, filtercreatedDate;
        filterLogicString = filtersubmissionDate = filtercreatedDate = '';
        
        if(!String.isBlank(logicCriteriaSelVal)){
            
            if(!String.isBlank(submissionDateSelVal) && submissionDateSelVal != '--None--'){
                filtersubmissionDate = ' = '+ submissionDateSelVal;
                filterLogicString += ' Submitted_Date__c ' + filtersubmissionDate + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(createdDateSelVal) && createdDateSelVal != '--None--'){
                filtercreatedDate = ' = '+ createdDateSelVal;
                filterLogicString += ' CreatedDate ' + filtercreatedDate + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(eventExp.Product_Type__c)){
                filterLogicString += ' Product_Type__c = ' + getSingleQuotesStr(eventExp.Product_Type__c) + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(eventExp.Requestor_Name__c)){
                filterLogicString += ' Requestor_Name__c = ' + getSingleQuotesStr(eventExp.Requestor_Name__c) + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(eventExp.Event_Name__c)){
                String filterEventName = ' \'%'+eventExp.Event_Name__c+'%\'';
                filterLogicString += ' Event_Name__c LIKE ' + filterEventName + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(evtExpNumberVal)){
                String filterevtExpNumberVal = ' \'%'+evtExpNumberVal+'%\'';
                filterLogicString += ' Name LIKE ' + filterevtExpNumberVal + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(eventExp.LOB__c)){
                filterLogicString += ' LOB__c = ' + getSingleQuotesStr(eventExp.LOB__c) + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(eventExp.Event_Type_Format__c)){
                filterLogicString += ' Event_Type_Format__c = ' + getSingleQuotesStr(eventExp.Event_Type_Format__c) + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(eventExp.Event_Format__c != 'None' && eventExp.Event_Format__c !=null){
                filterLogicString += ' Event_Format__c = ' + getSingleQuotesStr(eventExp.Event_Format__c) + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(eventExp.Status__c != '[]'){
                
                String pfilterStatus = eventExp.Status__c;
                pfilterStatus = pfilterStatus.removeStart('[');
                pfilterStatus = pfilterStatus.removeEnd(']');
                
                  list<String> statusLst = new list<String>();
                  for(String status : pfilterStatus.split(',')){
                    statusLst.add(status.trim());
                  }  
                  String filterStatus = '(\'' + String.join(statusLst, '\', \'') + '\')';
                  filterLogicString += ' Status__c IN ' + filterStatus + ' ' + logicCriteriaSelVal + ' ';
            }
            
            if(!String.isBlank(filterLogicString)){
                filterLogicString = filterLogicString.removeEnd('AND ');
                filterLogicString = filterLogicString.removeEnd('OR ');
            }
        }
        system.debug('from Util filterLogicString::>>   '+filterLogicString);
        return filterLogicString;
    }
    
    public static String getSingleQuotesStr(String val){
       if(!String.isBlank(val)) val = '\'' + val + '\'';
      return val;  
    }    
    
    // Method to identify if logged in user has same access as of CAO profile User
    public static Boolean EventExpenseNonCAOPrivilegedUsers(){
        Boolean IsPrivilegedUser = false;
        User u = currentLoggedInUser != null ? currentLoggedInUser : EventExpensecurrentLoggedInUser();
        for(Event_Expense_CAO_Visibility_Setting__mdt cmd : [Select Profile_Name__c,User_ID__c,Security_Type__c  From Event_Expense_CAO_Visibility_Setting__mdt])
        {
            if(cmd.Security_Type__c == 'Profile Name')
            {
                if(cmd.Profile_Name__c == u.Profile.Name)
                {
                    IsPrivilegedUser = true;
                    break; 
                }
            }
            
            if(!IsPrivilegedUser && cmd.Security_Type__c == 'User ID')
            {
                If(cmd.User_ID__c != null && cmd.User_ID__c.substring(0,15) == userinfo.getUserId().substring(0,15))
                {   
                    IsPrivilegedUser = true;
                    break;
                }
            }                
        }
        return IsPrivilegedUser;
    }
    
    // Method to identify logged in user 
    public static User EventExpensecurrentLoggedInUser(){
        currentLoggedInUser = [SELECT id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        return currentLoggedInUser;
    }
}