/********************************************************
Class Name : HL_Event_Expense_ApprovalActionUtil
Purpose : To provide Utility for all approval actions by approver
Test Class : HL_Test_EventExpenseViewClass and HL_Test_EventExpenseClass
********************************************************/
public class HL_Event_Expense_ApprovalActionUtil {
  
  // Public Properties
  public final static String BUDGETRANGE_UPTO_10K = '<10K';
  public final static String BUDGETRANGE_BETWEEN_10K_25K = '>10K AND <25K';
  public final static String BUDGETRANGE_OVER_25K = '>25K';
  
  public final static String STATUS_PENDING = 'Pending';
  public final static String STATUS_APPROVED = 'Approved';
  public final static String STATUS_REJECTED = 'Rejected';
  public final static String STATUS_MORE_INFO_REQUESTED = 'More Information Requested';
  public final static String STATUS_WAITING_FOR_APPROVAL = 'Waiting for Approval';
  
  public final static String EMAIL_TEMPLATE_Name_1 = 'Event Expense Submit for Approval for Approver';
  public final static String EMAIL_TEMPLATE_Name_2 = 'Event Expense Submission confirmation notification';
  public final static String EMAIL_TEMPLATE_Name_3 = 'Event Expense approved in 1st round for 1st Round Approver';
  public final static String EMAIL_TEMPLATE_Name_4 = 'Event Expense Submit for 2nd Round Approvers';
  public final static String EMAIL_TEMPLATE_Name_5 = 'Event Expense final approval in 2nd round for RSD';
  public final static String EMAIL_TEMPLATE_Name_6 = 'Event Expense approved in 2nd round for 2nd Round Approver';
  public final static String EMAIL_TEMPLATE_Name_7 = 'Event Expense Rejection 1st Round for Remaining Approvers';
  public final static String EMAIL_TEMPLATE_Name_8 = 'Event Expense Rejection 1st Round for RSD';
  public final static String EMAIL_TEMPLATE_Name_9 = 'Event Expense rejected in 2nd round for 2nd Round Approver';
  public final static String EMAIL_TEMPLATE_Name_10 = 'Event Expense More Information Requested for Remaining 1st Round Approvers';
  public final static String EMAIL_TEMPLATE_Name_11 = 'Event Expense 1st Round More Information Requested for RSD';
  public final static String EMAIL_TEMPLATE_Name_12 = 'Event Expense MIR in 2nd round for Remaining 2nd Round Approvers';
  public final static String EMAIL_TEMPLATE_Name_13 = 'Event Expense Final approved in 1st round';
  public final static String EMAIL_TEMPLATE_Name_14 = 'Event Expense CF Submit for Approval for Approver';
  public final static String EMAIL_TEMPLATE_Name_15 = 'Event Expense CF Submission confirmation notification';
  public final static String EMAIL_TEMPLATE_Name_16 = 'Event Expense CF Rejection 1st Round for RSD';
  public final static String EMAIL_TEMPLATE_Name_17 = 'Event Expense CF Rejection 1st Round for Remaining Approvers';
  public final static String EMAIL_TEMPLATE_Name_18 = 'Event Expense CF 1st Round More Information Requested for RSD';
  public final static String EMAIL_TEMPLATE_Name_19 = 'Event Expense CF More Information Requested for Remaining 1st Round Approvers';
  public final static String EMAIL_TEMPLATE_Name_20 = 'Event Expense CF final approval in 2nd round for RSD';  
  public final static String EMAIL_TEMPLATE_Name_21 = 'Event Expense CF approved in 1st round for 1st Round Approver';  
  
  public final static set<String> EVT_EXP_EMAIL_TEMPLATES_SET = new set<String>{
                                                                    EMAIL_TEMPLATE_Name_1,
                                                                    EMAIL_TEMPLATE_Name_2,
                                                                    EMAIL_TEMPLATE_Name_3,
                                                                    EMAIL_TEMPLATE_Name_4,
                                                                    EMAIL_TEMPLATE_Name_5,
                                                                    EMAIL_TEMPLATE_Name_6,
                                                                    EMAIL_TEMPLATE_Name_7,
                                                                    EMAIL_TEMPLATE_Name_8,
                                                                    EMAIL_TEMPLATE_Name_9,
                                                                    EMAIL_TEMPLATE_Name_10,
                                                                    EMAIL_TEMPLATE_Name_11,
                                                                    EMAIL_TEMPLATE_Name_12,
                                                                    EMAIL_TEMPLATE_Name_13,
                                                                    EMAIL_TEMPLATE_Name_14,
                                                                    EMAIL_TEMPLATE_Name_15,
                                                                    EMAIL_TEMPLATE_Name_16,
                                                                    EMAIL_TEMPLATE_Name_17,
                                                                    EMAIL_TEMPLATE_Name_18,
                                                                    EMAIL_TEMPLATE_Name_19,
                                                                    EMAIL_TEMPLATE_Name_20,
                                                                    EMAIL_TEMPLATE_Name_21
                                                                };
  
  /******************************************************************
  Method called when the user clicks on the Submit For Approval button
  ******************************************************************/
  public static void dosubmitForApproval(Event_Expense__c evtExpense){
  
    if(evtExpense.LOB__c != 'CF'){
    
        HL_EventExpense_Util.IN_APPROVAL_PROCESS = TRUE;
        //1. Make Archive Existing Event_Expense_Approval_History__c records
        HL_EventExpense_Util.archiveEvtExpApprovalHistoryRecordslst(evtExpense);
        
        //2. Get First Level Product Approvers Set
        set<Id> firstLevelApproverUsrIdSet = new set<Id>();
        firstLevelApproverUsrIdSet = HL_EventExpense_Util.getProdApproversIdSet(evtExpense.Product_Type__c, evtExpense.LOB__c);
        
        //3. Create Event_Expense_Approval_History__c for First Level
        HL_EventExpense_Util.createEvtExpApprovalHistoryRecords(evtExpense, firstLevelApproverUsrIdSet, '1');
        
        //4. Share Event_Expense__c records with  First Level Product Approvers Set
        //HL_EventExpense_Util.createSharingRecordsforEventExpense(evtExpense, firstLevelApproverUsrIdSet);
        HL_EventExpense_Util.SetupSharingForEventExpennseOnSubmission(evtExpense);
        
        //Update Event Expense
        evtExpense.Status__c = STATUS_WAITING_FOR_APPROVAL;
        evtExpense.Submitter__c = UserInfo.getUserId();
        update evtExpense;
        
        //5. Send Email
        sendEmailOnSubmission(firstLevelApproverUsrIdSet, evtExpense);
    }else if(evtExpense.LOB__c == 'CF'){
        HL_EventExpense_Util.IN_APPROVAL_PROCESS = TRUE;
        //1. Make Archive Existing Event_Expense_Approval_History__c records
        HL_EventExpense_Util.archiveEvtExpApprovalHistoryRecordslst(evtExpense);
        
        //2. Get CF Approvers Set
        set<Id> CFApproverUsrIdSet = new set<Id>();
        CFApproverUsrIdSet = HL_EventExpense_Util.getCFProdApproversIdSet(evtExpense);
        
        //3. Create Event_Expense_Approval_History__c for First Level
        HL_EventExpense_Util.createEvtExpApprovalHistoryRecords(evtExpense, CFApproverUsrIdSet, '1');
        
        //4. Share Event_Expense__c records with  First Level Product Approvers Set
        //HL_EventExpense_Util.createSharingRecordsforEventExpense(evtExpense, firstLevelApproverUsrIdSet);
        HL_EventExpense_Util.SetupSharingForEventExpennseOnSubmission(evtExpense);
        
        //Update Event Expense
        evtExpense.Status__c = STATUS_WAITING_FOR_APPROVAL;
        evtExpense.Submitter__c = UserInfo.getUserId();
        update evtExpense;
        
        //5. Send Email
        sendEmailOnCFSubmission(CFApproverUsrIdSet, evtExpense);    
    }        
  }
  
  /*****************************************************************************
  Method to send emails on submission for approval
  *****************************************************************************/
  public static void sendEmailOnSubmission(set<Id> firstLevelApproverUsrIdSet, Event_Expense__c evtExpense){
    
    //First level Prod Approvers
    set<Id> allUsrIdSet = new set<Id>();
    allUsrIdSet.addAll(firstLevelApproverUsrIdSet);
    
    //5.2 Send Email to First Level Requestors and thier Delegate Users    
    //Get Requestors
    set<Id> requestorsContIdSet = new set<Id>(); 
    if(evtExpense.Requestor_Name__c != null && evtExpense.Requestor_Name__r.Email != null && evtExpense.Requestor_Name__r.User__r.IsActive && !evtExpense.Requestor_Name__r.IsEmailBounced && evtExpense.Requestor_Name__r.Status__c == 'Active') 
        requestorsContIdSet.add(evtExpense.Requestor_Name__c);
    
    //Get Delegates for the Requestors
    map<Id, set<Id>> reqIdDelegateUserIdSetMap = new map<Id, set<Id>>();
    reqIdDelegateUserIdSetMap = HL_EventExpense_Util.fetchdelegateUsersOfRequestors(new set<Id>{evtExpense.Requestor_Name__r.User__c});
    
    set<Id> delegateUsrIdSet = new set<Id>();
    for(set<Id> delegateIdSet : reqIdDelegateUserIdSetMap.values()){
      delegateUsrIdSet.addAll(delegateIdSet);
    }
    
    allUsrIdSet.addAll(delegateUsrIdSet);
    
    if(allUsrIdSet.isEmpty()) return;
    map<Id, Id> usrIdContIdMap = HL_EventExpense_Util.getUsrIdContIdMap(allUsrIdSet);
    
    requestorsContIdSet.addAll(HL_EventExpense_Util.getContIdSet(delegateUsrIdSet, usrIdContIdMap));
    
    map<String, Id> ETNameIdMap = HL_EventExpense_Util.getEmailTempNameIdMap(EVT_EXP_EMAIL_TEMPLATES_SET);
    
    list<Messaging.SingleEmailMessage> emailsLst = new list<Messaging.SingleEmailMessage>();
    //Send email to First Level Approvers
    list<Id> firstLvlApproversContIdLst = new list<Id>(HL_EventExpense_Util.getContIdSet(firstLevelApproverUsrIdSet, usrIdContIdMap));
    if(firstLvlApproversContIdLst.size() > 0 )
        emailsLst.add(HL_EventExpense_Util.getEmailMessage(firstLvlApproversContIdLst, ETNameIdMap.get('Event Expense Submit for Approval for Approver'), evtExpense.Id));
    if(requestorsContIdSet.size() > 0 )
        emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense Submission confirmation notification'), evtExpense.Id));
    
    //Send Email
    if(emailsLst.size() > 0 && HL_General__c.getOrgDefaults() != null && HL_General__c.getOrgDefaults().Event_Expense_Email_Notifications__c){
      Messaging.sendEmail(emailsLst);      
    }
  }

  /*****************************************************************************
  Method to send emails on submission for approval for LOB = CF
  *****************************************************************************/
  public static void sendEmailOnCFSubmission(set<Id> ApproverUsrIdSet, Event_Expense__c evtExpense){
    
    //CF Approvers
    set<Id> allUsrIdSet = new set<Id>();
    allUsrIdSet.addAll(ApproverUsrIdSet);
    
    //5.2 Send Email to Requestors    
    //Get Requestors
    set<Id> requestorsContIdSet = new set<Id>(); 
    if(evtExpense.Requestor_Name__c != null && evtExpense.Requestor_Name__r.Email != null && evtExpense.Requestor_Name__r.User__r.IsActive && !evtExpense.Requestor_Name__r.IsEmailBounced && evtExpense.Requestor_Name__r.Status__c == 'Active') 
        requestorsContIdSet.add(evtExpense.Requestor_Name__c);
    
    //Get Delegates for the Requestors
    /*map<Id, set<Id>> reqIdDelegateUserIdSetMap = new map<Id, set<Id>>();
    reqIdDelegateUserIdSetMap = HL_EventExpense_Util.fetchdelegateUsersOfRequestors(new set<Id>{evtExpense.Requestor_Name__r.User__c});
    
    set<Id> delegateUsrIdSet = new set<Id>();
    for(set<Id> delegateIdSet : reqIdDelegateUserIdSetMap.values()){
      delegateUsrIdSet.addAll(delegateIdSet);
    }
    
    allUsrIdSet.addAll(delegateUsrIdSet);*/
    
    if(allUsrIdSet.isEmpty()) return;
    map<Id, Id> usrIdContIdMap = HL_EventExpense_Util.getUsrIdContIdMap(allUsrIdSet);
    
    //requestorsContIdSet.addAll(HL_EventExpense_Util.getContIdSet(delegateUsrIdSet, usrIdContIdMap));
    
    map<String, Id> ETNameIdMap = HL_EventExpense_Util.getEmailTempNameIdMap(EVT_EXP_EMAIL_TEMPLATES_SET);
    
    list<Messaging.SingleEmailMessage> emailsLst = new list<Messaging.SingleEmailMessage>();
    //Send email to CF Approvers
    list<Id> CFApproversContIdLst = new list<Id>(HL_EventExpense_Util.getContIdSet(ApproverUsrIdSet, usrIdContIdMap));
    if(CFApproversContIdLst.size() > 0 )
        emailsLst.add(HL_EventExpense_Util.getEmailMessage(CFApproversContIdLst, ETNameIdMap.get('Event Expense CF Submit for Approval for Approver'), evtExpense.Id));
    if(requestorsContIdSet.size() > 0 )
        emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense CF Submission confirmation notification'), evtExpense.Id));
    
    //Send Email
    if(emailsLst.size() > 0 && HL_General__c.getOrgDefaults() != null && HL_General__c.getOrgDefaults().Event_Expense_Email_Notifications__c){
      Messaging.sendEmail(emailsLst);      
    }
  }
  
  /******************************************************************
  Method called when the user clicks on the Approve button
  ******************************************************************/
  public static void doApprove (Event_Expense__c evtExpense, String ApproverResponse, String ApproverComment){
    HL_EventExpense_Util.IN_APPROVAL_PROCESS = TRUE;
    //Update existing Approval History records
    HL_EventExpense_Util.UpdateExistingApprovalHistory(evtExpense, ApproverResponse, ApproverComment);
    
    //Get First Level Product Approvers Set
    set<Id> firstLevelApproverUsrIdSet = new set<Id>();
    //firstLevelApproverUsrIdSet = HL_EventExpense_Util.getProdApproversIdSet(evtExpense.Product_Type__c, evtExpense.LOB__c);
    //Find current approvers from Approval History with Status = "No Action Required" and IsArchive = false
    
    set<Id> currentAppFromHistUsrIdSet = new set<Id>();
    currentAppFromHistUsrIdSet = HL_EventExpense_Util.getCrntApproverUsrsFromEvtExpAppHistory(evtExpense);
    firstLevelApproverUsrIdSet = currentAppFromHistUsrIdSet;
    
    // Send Email to First level Prod Approvers
    set<Id> allUsrIdSet = new set<Id>();
    allUsrIdSet.addAll(firstLevelApproverUsrIdSet);
    
    set<Id> lvl2ApproversIdSet = new set<Id>();
    set<Id> lvl2ApproversContIdSet = new set<Id>();
    if(evtExpense.LOB__c != 'CF'){
        if(evtExpense.Total_Budget_Requested__c > 2500){
            
            lvl2ApproversIdSet = HL_EventExpense_Util.getLevl2ApproversIdSet(evtExpense);
            
            //Second level Approvers
            allUsrIdSet.addAll(lvl2ApproversIdSet);
        }
    }        
      
    //Get Requestors
    set<Id> requestorsContIdSet = new set<Id>(); 
    if(evtExpense.Requestor_Name__c != null && evtExpense.Requestor_Name__r.Email != null && evtExpense.Requestor_Name__r.User__r.IsActive && !evtExpense.Requestor_Name__r.IsEmailBounced && evtExpense.Requestor_Name__r.Status__c == 'Active') 
    //if(evtExpense.Requestor_Name__c != null && evtExpense.Requestor_Name__r.Email != null) 
        requestorsContIdSet.add(evtExpense.Requestor_Name__c);
    
    //Get Delegates for the Requestors
    set<Id> delegateUsrIdSet = new set<Id>();
    if(evtExpense.LOB__c != 'CF'){    
        map<Id, set<Id>> reqIdDelegateUserIdSetMap = new map<Id, set<Id>>();
        reqIdDelegateUserIdSetMap = HL_EventExpense_Util.fetchdelegateUsersOfRequestors(new set<Id>{evtExpense.Requestor_Name__r.User__c});
        
        for(set<Id> delegateIdSet : reqIdDelegateUserIdSetMap.values()){
          delegateUsrIdSet.addAll(delegateIdSet);
        }
        
        allUsrIdSet.addAll(delegateUsrIdSet);
    }
    
    map<Id, Id> usrIdContIdMap;
    if(!allUsrIdSet.isEmpty()) 
        usrIdContIdMap = HL_EventExpense_Util.getUsrIdContIdMap(allUsrIdSet);
    
    if(evtExpense.LOB__c != 'CF'){     
        requestorsContIdSet.addAll(HL_EventExpense_Util.getContIdSet(delegateUsrIdSet, usrIdContIdMap));
    }
    
    //1. Check if the Approval is Final or not
    list<Boolean> isFinalApprovalLst = new list<Boolean>();
    if(evtExpense.Total_Budget_Requested__c <= 2500 || evtExpense.LOB__c == 'CF'){
        isFinalApprovalLst.add(true);
        isFinalApprovalLst.add(true);
    }else{
        isFinalApprovalLst = HL_EventExpense_Util.isFinalApproval(evtExpense, lvl2ApproversIdSet);
    }
    system.debug('check5.0---'+isFinalApprovalLst);
    map<String, Id> ETNameIdMap = HL_EventExpense_Util.getEmailTempNameIdMap(EVT_EXP_EMAIL_TEMPLATES_SET);
    list<Messaging.SingleEmailMessage> emailsLst = new list<Messaging.SingleEmailMessage>();
    //On Final Approval
    if(isFinalApprovalLst.size() == 2){
        if(isFinalApprovalLst.get(0)){
          //Update current Event Expense record
          HL_EventExpense_Util.updateEvtExpWithAppResponse(evtExpense, ApproverResponse, ApproverComment);
          
          //Final Approval in Round 1
          if(isFinalApprovalLst.get(1)){
            //Send email to First Level Approvers
            
            //Remove logged in User
            firstLevelApproverUsrIdSet.remove(UserInfo.getUserId());
                
                list<Id> firstLvlApproversContIdLst = new list<Id>(HL_EventExpense_Util.getContIdSet(firstLevelApproverUsrIdSet, usrIdContIdMap));
                if(firstLvlApproversContIdLst.size() > 0 ){
                    if(evtExpense.LOB__c != 'CF'){ 
                        emailsLst.add(HL_EventExpense_Util.getEmailMessage(firstLvlApproversContIdLst, ETNameIdMap.get('Event Expense approved in 1st round for 1st Round Approver'), evtExpense.Id));
                    }else if(evtExpense.LOB__c == 'CF'){ 
                        emailsLst.add(HL_EventExpense_Util.getEmailMessage(firstLvlApproversContIdLst, ETNameIdMap.get('Event Expense CF approved in 1st round for 1st Round Approver'), evtExpense.Id));
                    }
                }
                //Send email to Requestors
                if(requestorsContIdSet.size() > 0){
                    if(evtExpense.LOB__c != 'CF'){ 
                        emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense final approval in 2nd round for RSD'), evtExpense.Id));
                    }else if(evtExpense.LOB__c == 'CF'){ 
                        emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense CF final approval in 2nd round for RSD'), evtExpense.Id));
                    }
                }
                
                if(evtExpense.LOB__c != 'CF'){
                    if(evtExpense.Total_Budget_Requested__c > 25000) {
                        lvl2ApproversIdSet.remove(UserInfo.getUserId());
                        lvl2ApproversContIdSet.addAll(HL_EventExpense_Util.getContIdSet(lvl2ApproversIdSet, usrIdContIdMap));
                        if(lvl2ApproversContIdSet.size() > 0)
                            emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(lvl2ApproversContIdSet), ETNameIdMap.get('Event Expense Final approved in 1st round'), evtExpense.Id));
                    }
                }      
          }
          //Final Approval in Round 2
          else{
            
            //Send email to First Level Approvers
            //Remove logged in User
            //lvl2ApproversIdSet.remove(UserInfo.getUserId());
            currentAppFromHistUsrIdSet.remove(UserInfo.getUserId());
            
            //lvl2ApproversContIdSet.addAll(HL_EventExpense_Util.getContIdSet(lvl2ApproversIdSet, usrIdContIdMap));
            lvl2ApproversContIdSet.addAll(HL_EventExpense_Util.getContIdSet(currentAppFromHistUsrIdSet, usrIdContIdMap));
            if(lvl2ApproversContIdSet.size() > 0)
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(lvl2ApproversContIdSet), ETNameIdMap.get('Event Expense approved in 2nd round for 2nd Round Approver'), evtExpense.Id));
            
            //Send email to Requestors
            if(requestorsContIdSet.size() > 0)
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense final approval in 2nd round for RSD'), evtExpense.Id));
            
          }
          
        }
        //On Partial Approval
        else{
             system.debug('check5---');
          //Create Event_Expense_Approval_History__c for Second Level
          HL_EventExpense_Util.createEvtExpApprovalHistoryRecords(evtExpense, lvl2ApproversIdSet, '2');
          
          //Share Event_Expense__c records with  First Level Product Approvers Set
          HL_EventExpense_Util.createSharingRecordsforEventExpense(evtExpense, lvl2ApproversIdSet);
          
          //Send Email
          //Remove logged in User
          firstLevelApproverUsrIdSet.remove(UserInfo.getUserId());
          
          //Remove the common User Ids that are in both levels 1 and 2
          firstLevelApproverUsrIdSet.removeAll(lvl2ApproversIdSet);
          
          //Send email to First Level Approvers
          if(firstLevelApproverUsrIdSet.size() > 0)
            emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(HL_EventExpense_Util.getContIdSet(firstLevelApproverUsrIdSet, usrIdContIdMap)), ETNameIdMap.get('Event Expense approved in 1st round for 1st Round Approver'), evtExpense.Id));
          
          //Send email to Second Level Approvers
          //Remove logged in User
          lvl2ApproversIdSet.remove(UserInfo.getUserId());
            
          lvl2ApproversContIdSet.addAll(HL_EventExpense_Util.getContIdSet(lvl2ApproversIdSet, usrIdContIdMap));
          if(lvl2ApproversContIdSet.size() > 0)
            emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(lvl2ApproversContIdSet), ETNameIdMap.get('Event Expense Submit for 2nd Round Approvers'), evtExpense.Id));
        }
    }
    //Send Email
    if(emailsLst.size() > 0 && HL_General__c.getOrgDefaults() != null && HL_General__c.getOrgDefaults().Event_Expense_Email_Notifications__c){
      Messaging.sendEmail(emailsLst);      
    }
  }
  
  /******************************************************************
  Method called when the user clicks on the Reject/MIR button
  ******************************************************************/
  public static void doReject_MIR (Event_Expense__c evtExpense, String ApproverResponse, String ApproverComment){
    HL_EventExpense_Util.IN_APPROVAL_PROCESS = TRUE;
    //Update existing Approval History records
    HL_EventExpense_Util.UpdateExistingApprovalHistory(evtExpense, ApproverResponse, ApproverComment);
    //Update current Event Expense record
    HL_EventExpense_Util.updateEvtExpWithAppResponse(evtExpense, ApproverResponse, ApproverComment);
      
    //Send Email
    //1. Remaining same level approvers from Approval History with Status = No Action Required and IsArchive = false
    //Find current approvers from Approval History with Status = "No Action Required" and IsArchive = false
    
    set<Id> currentAppFromHistUsrIdSet = new set<Id>();
    currentAppFromHistUsrIdSet = HL_EventExpense_Util.getCrntApproverUsrsFromEvtExpAppHistory(evtExpense);
    
    //Send Email to same level Approvers
    set<Id> allUsrIdSet = new set<Id>();
    allUsrIdSet.addAll(currentAppFromHistUsrIdSet);
    
    //Get Requestors
    set<Id> requestorsContIdSet = new set<Id>(); 
    if(evtExpense.Requestor_Name__c != null && evtExpense.Requestor_Name__r.Email != null && evtExpense.Requestor_Name__r.User__r.IsActive && !evtExpense.Requestor_Name__r.IsEmailBounced && evtExpense.Requestor_Name__r.Status__c == 'Active') 
    //if(evtExpense.Requestor_Name__c != null && evtExpense.Requestor_Name__r.Email != null) 
        requestorsContIdSet.add(evtExpense.Requestor_Name__c);
    
    //Get Delegates for the Requestors
    set<Id> delegateUsrIdSet = new set<Id>();
    if(evtExpense.LOB__c != 'CF'){
        map<Id, set<Id>> reqIdDelegateUserIdSetMap = new map<Id, set<Id>>();
        reqIdDelegateUserIdSetMap = HL_EventExpense_Util.fetchdelegateUsersOfRequestors(new set<Id>{evtExpense.Requestor_Name__r.User__c});
    
        //set<Id> delegateUsrIdSet = new set<Id>();
        for(set<Id> delegateIdSet : reqIdDelegateUserIdSetMap.values()){
          delegateUsrIdSet.addAll(delegateIdSet);
        }
    
        allUsrIdSet.addAll(delegateUsrIdSet);
    }    
    
      map<Id, Id> usrIdContIdMap ;
      if(!allUsrIdSet.isEmpty())
        usrIdContIdMap = HL_EventExpense_Util.getUsrIdContIdMap(allUsrIdSet);
    
    if(evtExpense.LOB__c != 'CF'){  
      requestorsContIdSet.addAll(HL_EventExpense_Util.getContIdSet(delegateUsrIdSet, usrIdContIdMap));
    }
    
    map<String, Id> ETNameIdMap = HL_EventExpense_Util.getEmailTempNameIdMap(EVT_EXP_EMAIL_TEMPLATES_SET);
    list<Messaging.SingleEmailMessage> emailsLst = new list<Messaging.SingleEmailMessage>();
    
    //Send email to Same Level Approvers
    list<Id> sameLvlApproversContIdLst = new list<Id>(HL_EventExpense_Util.getContIdSet(currentAppFromHistUsrIdSet, usrIdContIdMap));
    if(ApproverResponse == 'Rejected')
    {
        if(evtExpense.Current_Approval_Level__c == '1'){
            if(sameLvlApproversContIdLst.size() > 0){
                if(evtExpense.LOB__c != 'CF'){ 
                    emailsLst.add(HL_EventExpense_Util.getEmailMessage(sameLvlApproversContIdLst, ETNameIdMap.get('Event Expense Rejection 1st Round for Remaining Approvers'), evtExpense.Id));
                }else if(evtExpense.LOB__c == 'CF'){
                    emailsLst.add(HL_EventExpense_Util.getEmailMessage(sameLvlApproversContIdLst, ETNameIdMap.get('Event Expense CF Rejection 1st Round for Remaining Approvers'), evtExpense.Id));
                }
            }
        }
        else if(evtExpense.Current_Approval_Level__c == '2')
        {   
            if(sameLvlApproversContIdLst.size() > 0)  
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(sameLvlApproversContIdLst, ETNameIdMap.get('Event Expense rejected in 2nd round for 2nd Round Approver'), evtExpense.Id));
            
        }
            
           
        //Send email to Requestors
        if(requestorsContIdSet.size() > 0){
            if(evtExpense.LOB__c != 'CF'){     
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense Rejection 1st Round for RSD'), evtExpense.Id));
            }else if(evtExpense.LOB__c == 'CF'){
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense CF Rejection 1st Round for RSD'), evtExpense.Id));
            }
        }
    }
    else if (ApproverResponse == 'More Information Requested')
    {
        if(evtExpense.Current_Approval_Level__c == '1'){
            if(sameLvlApproversContIdLst.size() > 0){
                if(evtExpense.LOB__c != 'CF'){ 
                    emailsLst.add(HL_EventExpense_Util.getEmailMessage(sameLvlApproversContIdLst, ETNameIdMap.get('Event Expense More Information Requested for Remaining 1st Round Approvers'), evtExpense.Id));
                }else if(evtExpense.LOB__c == 'CF'){
                    emailsLst.add(HL_EventExpense_Util.getEmailMessage(sameLvlApproversContIdLst, ETNameIdMap.get('Event Expense CF More Information Requested for Remaining 1st Round Approvers'), evtExpense.Id));
                }
            }    
        }
        else if(evtExpense.Current_Approval_Level__c == '2')
        {
            if(sameLvlApproversContIdLst.size() > 0)
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(sameLvlApproversContIdLst, ETNameIdMap.get('Event Expense MIR in 2nd round for Remaining 2nd Round Approvers'), evtExpense.Id));
        }
                    
        //Send email to Requestors
        if(requestorsContIdSet.size() > 0){
            if(evtExpense.LOB__c != 'CF'){ 
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense 1st Round More Information Requested for RSD'), evtExpense.Id));
            }else if(evtExpense.LOB__c == 'CF'){
                emailsLst.add(HL_EventExpense_Util.getEmailMessage(new list<Id>(requestorsContIdSet), ETNameIdMap.get('Event Expense CF 1st Round More Information Requested for RSD'), evtExpense.Id));
            }
        }    
    }
    
    
    //Send Email
    if(emailsLst.size() > 0 && HL_General__c.getOrgDefaults() != null && HL_General__c.getOrgDefaults().Event_Expense_Email_Notifications__c){
      Messaging.sendEmail(emailsLst);      
    }
  }
}