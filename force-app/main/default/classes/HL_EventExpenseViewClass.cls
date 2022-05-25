/*********************************************************************
Apex Class Name: HL_EventExpenseViewClass
Purpose: As controller to display Evennt Expense detail  Page 
Test Class : HL_Test_EventExpenseViewClass
*********************************************************************/
public class HL_EventExpenseViewClass {
    
    // Public variables
    public Id EventExpId ;
    public List<Event_Expense__c> EveExpRecordList{get;set;}
    public Event_Expense__c EveExpRecord{get;set;}
    public List<Event_Expense_Approval_History__c> EventExpenseApprovalHistoryList{get;set;}
    public Event_Expense_Approval_History__c EventExpenseApprovalHistory{get;set;}   
    public list<List_of_team_member__c> ListOfTeamMemberList{get; set;}
    public list<Potential_confirmed_external_guests__c> PotentialConfirmedEGList{get;set;}
    public list<Presenter__c> PresenterList{get;set;}
    public list<User> userList;
    public Boolean showApprovButton {get;set;}
    public Boolean ShowEditSubmitBtn {get;set;} 
    public Boolean ShowEditBtnForPrivilegedUser {get;set;} 
    public Boolean validUser {get; private set;}
    public Boolean displayPopup {get; private set;}
    public Boolean displayClonePopUp {get; private set;}
    public string EventExpenseApprovalHistoryNotes;
    public string currentPopUpSource;
    public string notesLabel{get; set;}
    public boolean requiredForCF {get; set;}  
    public boolean requiredForFVA {get; set;}  // Flag Variable for LOB=FVA
    public boolean requiredForCS ;
    public boolean requiredForSE ;
    public boolean requiredForCE ;
    private String originalStatus;
    public boolean requiredForADMA ;
    public boolean requiredForMKTGMT ;
    public boolean requiredForMKTGMM ;
    public final static String STATUS_MORE_INFO_REQUESTED = 'More Information Requested';
    public final static String STATUS_APPROVED = 'Approved';
    public final static String EVT_EXP_STATUS_WAITING_FOR_APPROVAL  = 'Waiting for Approval';
    public final static String STATUS_REJECTED = 'Rejected';
    public Boolean IsMemberofEventExpenseCAOVisibility{get;set;}
   
    // Constructor
    public HL_EventExpenseViewClass(ApexPages.StandardController controller){
        
        requiredForCF = requiredForCS = requiredForSE = requiredForCE = requiredForADMA = requiredForMKTGMT = requiredForMKTGMM = displayClonePopUp = requiredForFVA = false;
        showApprovButton = false;
        ShowEditSubmitBtn = false;
        ShowEditBtnForPrivilegedUser = false;
        validUser = true;
        EventExpId = ApexPages.currentPage().getParameters().get('id');
        EventExpenseApprovalHistoryList = new List<Event_Expense_Approval_History__c>();
        EventExpenseApprovalHistory = new Event_Expense_Approval_History__c();
        userList = new List<User>();
        EventExpenseApprovalHistoryNotes = '';
        currentPopUpSource = '';
        notesLabel = 'Notes';
        ListOfTeamMemberList = new List<List_of_team_member__c>();
        PotentialConfirmedEGList = new List<Potential_confirmed_external_guests__c>();
        PresenterList = new List<Presenter__c>();
        if(EventExpId != null ){
            EveExpRecordList = [select id, Requestor_Name__c, Requestor_Name__r.Id, Start_Date__c,Current_Approval_Level__c,Requestor_s_User__c,Requestor_Name__r.User__r.IsActive,   
                                Industry_Group__c, Status__c, Title__c, Primary_Email__c,Submitter__c, Event_Format__c,Specify__c, SubLedger_Number__c,
                                Primary_phone_number__c, Event_Contact__c, Product_Type__c, LOB__c , Event_Name__c, Event_location__c, Name,
                                City__c, End_Date__c,createddate, Event_Type_Format__c, Event_Type_Format_Other__c, Event_Purpose__c,Requestor_Name__r.Email,Requestor_Name__r.IsEmailBounced,
                                What_is_desired_outcome_of_this_event__c, Target_Audience__c, Audience_Industry_if_applicable__c,Submitted_Date__c,
                                Number_of_guests__c, Marketing_support__c, Marketing_support_Other__c, Related_campaign_if_30_guests__c,
                                Potential_Revenue__c, Expected_Travel_cost__c, Expected_F_B_cost__c,Requestor_Name__r.User__c,Requestor_Name__r.Status__c,
                                Any_additional_cost_Specify__c, Total_Budget_Requested__c, CreatedById, Who_is_evaluating_the_event__c, OwnerId , When_this_event_will_be_evaluated__c, What_are_KPIs__c, Any_additional_requests__c,HL_Internal_Opportunity_Number__c,
                                Notes__c,Is_Clone__c, Office__c, Internal_Opportunity_Number__c,Event__c, Expected_Airfare_Cost__c, Expected_Lodging_Cost__c, Expected_Registration_Fee__c, Classification__c,Asked_to_Present__c,Onsite_Support_Needed__c,Is_Actual_Date__c FROM Event_Expense__c WHERE Id=:EventExpId];
            if(EveExpRecordList.size() > 0 ){
                EveExpRecord = EveExpRecordList[0];
                originalStatus = EveExpRecordList[0].Status__c;
                ListOfTeamMemberList = [Select id, Contact__c, Event_Expense__c, Contact__r.Name, Contact__r.id, Contact__r.Title, Contact__r.Industry_Group__c from List_of_team_member__c where Event_Expense__c=:EventExpId];
                
                PotentialConfirmedEGList = [Select id, Contact__c, Event_Expense__c, Contact__r.Name, Contact__r.id, Contact__r.Title, Contact__r.Industry_Group__c from Potential_confirmed_external_guests__c where Event_Expense__c=:EventExpId];
                
                PresenterList = [Select id, Contact__c, Event_Expense__c, Contact__r.Name, Contact__r.id, Contact__r.Title, Contact__r.Industry_Group__c from Presenter__c where Event_Expense__c=:EventExpId];
                
                getApprovalHistoryRecords();
                string user_id = UserInfo.getUserId();
                if(EveExpRecord.status__c == 'Waiting for Approval' && (ishavingApprovalPermission(EveExpRecord.Id)))
                    showApprovButton = true;
                ShowEditSubmitBtn = HL_Event_Expense_TriggerHandler.checkdelegateUser(UserInfo.getUserId(), EveExpRecord.Requestor_s_User__c);
                
                boolean checkPrivilegedUser = HL_Event_Expense_TriggerHandler.checkPrivilegedUser();
                if(EveExpRecord.LOB__c == 'CF'){
                    ShowEditBtnForPrivilegedUser = checkPrivilegedUser;              
                }else{
                    ShowEditBtnForPrivilegedUser = (originalStatus == EVT_EXP_STATUS_WAITING_FOR_APPROVAL || originalStatus == STATUS_MORE_INFO_REQUESTED || originalStatus == STATUS_APPROVED || originalStatus == STATUS_REJECTED) && checkPrivilegedUser;
                }
            }
        }
        // To indentify if logged in user is internal/system admin /having sharing of record
        validUser = HL_EventExpenseClass.checkValidUser();
        if(!validUser){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_EventExpenseRequiredPermission));
        } 
        
        IsMemberofEventExpenseCAOVisibility = HL_ConstantsUtil.EventExpenseNonCAOPrivilegedUsers();
        requiredOnPage();              
    }
    
    // Populating list of Approval history List
    public void getApprovalHistoryRecords(){
        List<Event_Expense_Approval_History__c> tempList = new List<Event_Expense_Approval_History__c>();
        List<Event_Expense_Approval_History__c> tempList2 = new List<Event_Expense_Approval_History__c>();
        EventExpenseApprovalHistoryList = new List<Event_Expense_Approval_History__c>();
        for(Event_Expense_Approval_History__c EvntExpAppHstry : [Select id, Approver__c, LastModifiedDate, Event_Expense__c, Notes__c, Status__c, Is_Archive__c,Approver_s_Level__c,Status_TimeStamp__c from Event_Expense_Approval_History__c where Event_Expense__c=:EventExpId ORDER BY Status_TimeStamp__c DESC , Approver_s_Level__c DESC])
        {
            if(EvntExpAppHstry.status__c == 'Pending')
                tempList.add(EvntExpAppHstry);
            else
                tempList2.add(EvntExpAppHstry);
        }
        EventExpenseApprovalHistoryList.addAll(tempList);
        EventExpenseApprovalHistoryList.addAll(tempList2);
    }
             
    // To render as PDF
    public void toRenderAsPDF(){
        // Dummy Method     
    }
         
    // To Submit record after approval
    public void toApprove(){
        Savepoint sp = Database.setSavepoint();
        try{          
          currentPopUpSource = 'Approved';
          HL_Event_Expense_ApprovalActionUtil.doApprove(EveExpRecord, currentPopUpSource, '');
          getApprovalHistoryRecords();
          showApprovButton = ishavingApprovalPermission(EveExpRecord.Id);
          ShowEditSubmitBtn = HL_Event_Expense_TriggerHandler.checkdelegateUser(UserInfo.getUserId(), EveExpRecord.Requestor_s_User__c);
         }catch(Exception e)
        {
            EveExpRecord.status__c = originalStatus;
            ShowEditSubmitBtn= false;
            Database.rollback( sp );
            Apexpages.addMessages(e);
        }
        
    }
    
         
    // To Submit record after Rejection
    public void toReject(){
        Savepoint sp = Database.setSavepoint();
        try{          
          currentPopUpSource = 'Rejected';
          notesLabel = 'Notes for Rejection: ';
          displayPopup = true;
         
        }catch(Exception e)
        {
            EveExpRecord.status__c = originalStatus;
            Database.rollback( sp );
            Apexpages.addMessages(e);
        }
    }
    
         
    // To Submit record after Request More Information
    public void toRequestMoreInformation(){
        currentPopUpSource = 'More Information Requested';
        notesLabel = 'Notes for Request More Information: ';
        displayPopup = true;       
    }
    
         
    // To Delete record after Approval
    public void toDelete(){
        Savepoint sp = Database.setSavepoint();
        try{          
          currentPopUpSource = 'Deleted';
          notesLabel = 'Notes for Deletion: ';
          displayPopup = true;
        }catch(Exception e)
        {
            EveExpRecord.status__c = originalStatus;
            Database.rollback( sp );
            Apexpages.addMessages(e);
        }
    }
    
    //To check active 1st level approver
    public boolean checkActiveFirstLevelApprover(Event_Expense__c evntExpense){
        Boolean isApproverActive = false;
        set<Id> approverIdFromMDT = new set<Id>();
        for(Event_Expense_Product_Approver__mdt EEPAmdt : [SELECT Approver_User_Id__c FROM Event_Expense_Product_Approver__mdt
                                                    Where Product_Type__c = :evntExpense.Product_Type__c AND Is_Active__c = true]){
            approverIdFromMDT.add(EEPAmdt.Approver_User_Id__c);
        }
        
        for(User activeFirstLevelApprover : [SELECT Id FROM User WHERE Id IN:approverIdFromMDT AND IsActive = true]){
            isApproverActive = true;
        }
        
        if(!isApproverActive)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_NoActive1stLevelApprover));
        
        return isApproverActive;
    }
    
         
    // To Submit record for approval
    public PageReference SubmitForApproval(){
    
        if(!requiredForCF){
            if(validate() && checkActiveFirstLevelApprover(EveExpRecord)){
                Savepoint sp = Database.setSavepoint();
                try{                    
                    ShowEditBtnForPrivilegedUser = HL_Event_Expense_TriggerHandler.checkPrivilegedUser();
                    HL_Event_Expense_ApprovalActionUtil.dosubmitForApproval(EveExpRecord);
                    // After Submission refresh list of approval history on view page
                    getApprovalHistoryRecords();
                    if(EveExpRecord.status__c == 'Waiting for Approval' && (ishavingApprovalPermission(EveExpRecord.Id)))
                        showApprovButton = true;
                }catch(Exception e)
                {
                  EveExpRecord.status__c = originalStatus;
                  showApprovButton = false;
                  Database.rollback( sp );
                  Apexpages.addMessages(e);
                }
            }                    
        }else if(requiredForCF){
    
            if (validate()){
                Savepoint sp = Database.setSavepoint();
                try{
                    ShowEditBtnForPrivilegedUser = HL_Event_Expense_TriggerHandler.checkPrivilegedUser();                                    
                    HL_Event_Expense_ApprovalActionUtil.dosubmitForApproval(EveExpRecord);
                    // After Submission refresh list of approval history on view page
                    getApprovalHistoryRecords();
                    if(EveExpRecord.status__c == 'Waiting for Approval' && (ishavingApprovalPermission(EveExpRecord.Id)))
                        showApprovButton = true;
                }catch(Exception e)
                {
                    EveExpRecord.status__c = originalStatus;
                    showApprovButton = false;
                    Database.rollback( sp );
                    Apexpages.addMessages(e);
                }
            }      
        } 
        return null;
    }

        
    // To Validate record
    public boolean validate(){
        
        requiredOnPage();
        Boolean isValid = true;
        if (String.isBlank(EveExpRecord.Requestor_Name__c)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseRequestorNameRequired));
        }
        if (String.isBlank(EveExpRecord.Event_Contact__c) && !requiredForMKTGMM) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseEventContactRequired));
        }
        if (String.isBlank(EveExpRecord.Product_Type__c) && !requiredForCF) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseProductTypeRequired));
        }
        if ((String.isBlank(EveExpRecord.Event_Name__c) && !requiredForCF) || (String.isBlank(EveExpRecord.Event__c) && requiredForCF)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseNameRequired));
        }
        if (String.isBlank(EveExpRecord.City__c) && !requiredForMKTGMM) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseCityRequired));
        }
        if (String.isBlank(EveExpRecord.Event_Format__c) && !requiredForMKTGMM) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseFormatRequired));
        }
        if (EveExpRecord.Start_Date__c == null) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseStartDateRequired));
        }
        if (EveExpRecord.LOB__c == null) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseLOBRequired));
        }
        if (EveExpRecord.Event_Type_Format__c == null) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseEventTypeRequired));
        }
        if (String.isBlank(EveExpRecord.Number_of_guests__c) && !(requiredForADMA || requiredForMKTGMT || requiredForMKTGMM)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseNumberOfGuestsRequired));
        }
        if (EveExpRecord.Expected_Travel_cost__c == null && !(requiredForMKTGMM || requiredForCF)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseTravelCostRequired));
        }
        if (EveExpRecord.Expected_Airfare_Cost__c == null && requiredForCF) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseAirfareCostRequired));
        }
        if (EveExpRecord.Expected_Lodging_Cost__c == null && requiredForCF) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseLodgingCostRequired));
        }        
        if (EveExpRecord.Expected_Registration_Fee__c == null && requiredForCF) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseRegistrationFeeRequired));
        }
        if (EveExpRecord.Expected_F_B_cost__c == null && !requiredForMKTGMM) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseFBCostRequired));
        }
        if (EveExpRecord.Any_additional_cost_Specify__c == null) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseAdditionalCostRequired));
        }
        if (String.isBlank(EveExpRecord.SubLedger_Number__c) && !(requiredForMKTGMM || requiredForCF || requiredForFVA)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseLedgerNumberRequired));
        }
        // Error Msg added for Lob = FA
        if (String.isBlank(EveExpRecord.HL_Internal_Opportunity_Number__c) && requiredForFVA) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseHLInternalOppNumberRequired));
        }
        
        if (requiredForCS && String.isBlank(EveExpRecord.Target_Audience__c)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseTagetAudienceRequired));
        }
        if (requiredForCE && String.isBlank(EveExpRecord.Marketing_support__c)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpenseMarketingSupportRequired));
        }
        if (EveExpRecord.Any_additional_cost_Specify__c > 0 && (EveExpRecord.Specify__c == null || EveExpRecord.Specify__c == '')) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_NoSpecifiedonAddCost));
        }
        if (ListOfTeamMemberList.size() == 0 && !(requiredForADMA || requiredForMKTGMT || requiredForMKTGMM || requiredForCF)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_No_TeamMember));
        }
        if ((requiredForCS || requiredForCE || requiredForMKTGMT) && (String.isBlank(EveExpRecord.Related_campaign_if_30_guests__c) && PotentialConfirmedEGList.size() == 0)) {
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,Label.HL_EventExpensePCEGorCampaignRequired));
        }
        if(EveExpRecord.Marketing_support__c == 'Yes' && String.isBlank(EveExpRecord.Marketing_support_Other__c )){
            isValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_Marketing_support_Other_Required));
        }
        System.debug('IsValid value' + isValid);
        return isValid;
    }
    
    // To make different fields required
    public void requiredOnPage(){
        if(EveExpRecord.Event_Type_Format__c == 'MKTG - Conference/ Seminar' || EveExpRecord.Event_Type_Format__c == 'MKTG â€“ Conference/ Seminar'){
            requiredForCS = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'ADM - Staff Entertainment' || EveExpRecord.Event_Type_Format__c == 'ADM â€“ Staff Entertainment'){
            requiredForSE = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG - Client Entertainment' || EveExpRecord.Event_Type_Format__c == 'MKTG â€“ Client Entertainment'){
            requiredForCE = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG - Marketing Membership' || EveExpRecord.Event_Type_Format__c == 'MKTG â€“ Marketing Membership'){
            requiredForMKTGMM = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'MKTG - Marketing Trip' || EveExpRecord.Event_Type_Format__c == 'MKTG â€“ Marketing Trip'){
            requiredForMKTGMT = true;
        }
        if(EveExpRecord.Event_Type_Format__c == 'ADM - Administrative' || EveExpRecord.Event_Type_Format__c == 'ADM â€“ Administrative'){
            requiredForADMA = true;
        }
        if(EveExpRecord.LOB__c == 'CF'){
            requiredForCF = true;
        }  
        // Setting Flag Variable true for FVA
         if(EveExpRecord.LOB__c == 'FVA'){
            requiredForFVA = true;
        }
        
    }  
        
    //To close popup om click of cancel
    public void closePopup() {
        displayClonePopUp = false;
        displayPopup = false;
        currentPopUpSource = '';
        EventExpenseApprovalHistory.Notes__c = '';
    }
    
    public PageReference backToRecord() {
        Savepoint sp = Database.setSavepoint();
        try{          
            displayPopup = false;
            if(currentPopUpSource == 'Deleted'){
                EveExpRecord.Status__c = 'Deleted';
                update EveExpRecord;
                
                Event_Expense_Approval_History__c newEventExpenseApprovalHistory = new Event_Expense_Approval_History__c();
                newEventExpenseApprovalHistory.Approver__c = UserInfo.getUserId();
                newEventExpenseApprovalHistory.Event_Expense__c = EveExpRecord.Id;
                newEventExpenseApprovalHistory.Notes__c = EventExpenseApprovalHistory.Notes__c;
                newEventExpenseApprovalHistory.Status_TimeStamp__c = system.now();
                newEventExpenseApprovalHistory.Status__c = 'Deleted';
                insert newEventExpenseApprovalHistory;
                
            } else {
                HL_Event_Expense_ApprovalActionUtil.doReject_MIR(EveExpRecord, currentPopUpSource, EventExpenseApprovalHistory.Notes__c);
                showApprovButton = ishavingApprovalPermission(EveExpRecord.Id);
                if(!requiredForCF){
                    ShowEditSubmitBtn = HL_Event_Expense_TriggerHandler.checkdelegateUser(UserInfo.getUserId(), EveExpRecord.Requestor_s_User__c);
                }
            }  
        }catch(Exception e)
        {
            EveExpRecord.status__c = originalStatus;
            ShowEditSubmitBtn= false;
            Database.rollback( sp );
            Apexpages.addMessages(e);
            return null;
        }
        PageReference p = new Pagereference('/'+EveExpRecord.Id);
        p.setRedirect(true);
        return p; 
    }
        
    // To Edit record
    public PageReference Edit(){
        return new PageReference('/apex/HL_EventExpenseEditPage?id='+EveExpRecord.Id+'&retUrl=' + EveExpRecord.Id);
    }
    
   
    // To return on main page
    public PageReference backToMainPage(){
        
        return new PageReference('/apex/HL_EventExpenseLandingPage');
    }
    
    // Method to identify to control visibility of Approve,Reject, More Information Requested button
    public Static boolean ishavingApprovalPermission(Id EventExpenseRecordId){
        
        boolean ishavingApprovalPermission = false;
        for (Event_Expense_Approval_History__c EvExpApprovalHistry : [SELECT Approver__c  FROM Event_Expense_Approval_History__c Where Is_Archive__c = False AND Approver__c =: UserInfo.getUserId() AND  Status__c = 'Pending' AND Event_Expense__c =: EventExpenseRecordId])
        {
            ishavingApprovalPermission = true;
            break;
        }
        return ishavingApprovalPermission;
    }
    
    public void dummyCall(){
        //No logic
    }
    
    public void confirmCloneEE(){
        displayClonePopUp = true;
    }
    
    // Cloning Event Expense Record    
    public PageReference cloneEventExpense()
    {
        try{
            Event_Expense__c newEventExpense = new Event_Expense__c();
            newEventExpense  = EveExpRecord.clone(false, true, false, false);
            newEventExpense.Status__c = 'Saved';
            newEventExpense.Approver_s_Notes__c = '';
            newEventExpense.Current_Approval_Level__c = '';
            newEventExpense.Current_Approver__c = null;
            newEventExpense.Submitted_Date__c = null;
            newEventExpense.Submitter__c = null;
            newEventExpense.Is_Clone__c = true;
            newEventExpense.OwnerId = UserInfo.getUserID();
            insert newEventExpense ;
            
            ClonechildRecords(newEventExpense.Id, EveExpRecord.id);
            return new PageReference('/'+newEventExpense.Id+'/e');
        }catch(Exception e)
        {    
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    //Cloning related child object (List of Team Member, Potential confirmed external guests & Presenters) records 
    private void ClonechildRecords(Id newEEId, Id OldEEId){
        
        // Fetch List of Team Mmember from Old Event Expenses
        List_of_team_member__c newLOTM ;
        List<List_of_team_member__c> newLOTMList = new List<List_of_team_member__c>();
        for(List_of_team_member__c LOTM: [Select Id,Event_Expense__c,Contact__c From List_of_team_member__c Where Event_Expense__c =: OldEEId])
        {
            newLOTM = new List_of_team_member__c();
            newLOTM = LOTM.clone(false, true, false, false);
            newLOTM.Event_Expense__c = newEEId ;
            newLOTMList.add(newLOTM);
        }
        if(newLOTMList.size() > 0) 
            insert newLOTMList;
        
        // Fetch Potential confirmed external guests from Old Event Expenses
        Potential_confirmed_external_guests__c newPCEG ;
        List<Potential_confirmed_external_guests__c> newPCEGList = new List<Potential_confirmed_external_guests__c>();
        for(Potential_confirmed_external_guests__c PCEG: [Select Id,Event_Expense__c,Contact__c From Potential_confirmed_external_guests__c Where Event_Expense__c =: OldEEId])
        {
            newPCEG = new Potential_confirmed_external_guests__c();
            newPCEG = PCEG.clone(false, true, false, false);
            newPCEG.Event_Expense__c = newEEId ;
            newPCEGList.add(newPCEG);
        }
        if(newPCEGList.size() > 0) 
            insert newPCEGList;
        
        // Fetch Presenters from Old Event Expenses
        Presenter__c newPresenter ;
        List<Presenter__c> newPresenterList = new List<Presenter__c>();
        for(Presenter__c Presenter: [Select Id,Event_Expense__c,Contact__c From Presenter__c Where Event_Expense__c =: OldEEId])
        {
            newPresenter = new Presenter__c();
            newPresenter = Presenter.clone(false, true, false, false);
            newPresenter.Event_Expense__c = newEEId ;
            newPresenterList.add(newPresenter);
        }
        if(newPresenterList.size() > 0) 
            insert newPresenterList;        
    }
    
}