/*********************************************************************
Apex Class Name: HL_EventExpense_Util
Purpose: As Utility class for HL_Event_Expense_ApprovalActionUtil
Test Class : HL_Test_EventExpenseViewClass and HL_Test_EventExpenseClass
*********************************************************************/
public class HL_EventExpense_Util {
  
  // Public Properties
  public final static String BUDGETRANGE_UPTO_10K = '<10K';
  public final static String BUDGETRANGE_BETWEEN_10K_25K = '>10K AND <25K';
  public final static String BUDGETRANGE_OVER_25K = '>25K';
  public final static String EMAIL_TEMPLATE_EVT_EXP_APPROVAL = 'Event Expense Approval Email';
  public final static String EMAIL_TEMPLATE_EVT_EXP_REQUESTOR = 'Event Expense Requestor Email';
  
  public final static String STATUS_PENDING = 'Pending';
  public final static String STATUS_APPROVED = 'Approved';
  public final static String STATUS_REJECTED = 'Rejected';
  public final static String STATUS_MORE_INFO_REQUESTED = 'More Information Requested';
  public final static String STATUS_WAITING_FOR_APPROVAL = 'Waiting for Approval';
  
  public Static boolean IN_APPROVAL_PROCESS = FALSE;
  /******************************************************************
  Method to get the map of Delegate Users of the Requetors
  ******************************************************************/
  public static map<Id, set<Id>> fetchdelegateUsersOfRequestors(set<Id> requestorsIdSet)
  {
    map<Id, set<Id>>  delegateUserIdMap = new map<Id, set<Id>>();
    for(Delegate_Public_Group_Member__c  DGP : [SELECT Delegate__c, Delegate_Public_Group__r.Banker__c  
                                                FROM Delegate_Public_Group_Member__c 
                                                WHERE Delegate_Public_Group__r.Banker__c IN : requestorsIdSet AND Delegate_Public_Group__r.Active__c = true])
    {
        if(!delegateUserIdMap.containsKey(DGP.Delegate_Public_Group__r.Banker__c))
            delegateUserIdMap.put(DGP.Delegate_Public_Group__r.Banker__c, new Set<Id>{DGP.Delegate__c});
        else
            delegateUserIdMap.get(DGP.Delegate_Public_Group__r.Banker__c).add(DGP.Delegate__c); 
    }
    return delegateUserIdMap;
  }
  
  // call this from trigger
  // To set up sharing of event expense  record with All approvers, requestor and additional requestor and submitter
  public static void SetupSharingForEventExpennseOnCreation(list<Event_Expense__c> evtExpenseList)
  {
        list<Event_Expense__share> SharingEventExpenseList = new list<Event_Expense__share>();          
        set<Id> newShareHoldersSet = new set<Id>();
        set<Id> newShareHolderUserIdSet = new set<Id>();
        for(Event_Expense__c EventExpnse : evtExpenseList)
        {   
            if(EventExpnse.Requestor_Name__c != null && EventExpnse.Requestor_Name__c  != EventExpnse.ownerId){
                newShareHoldersSet.add(EventExpnse.Requestor_Name__c);
            }
        } 
        Map<Id, Contact> mapofContIdToUserRecord = new Map<Id, Contact>();
        for(Contact c : [Select id, User__c, User__r.isActive From Contact Where Id IN : newShareHoldersSet])
        {
                mapofContIdToUserRecord.put(c.Id, c);
                if(c.user__c != null)
                    newShareHolderUserIdSet.add(c.user__c);
        }
        map<Id, set<Id>> delegateGroupIdMap = new map<Id,set<Id>>();
        delegateGroupIdMap = fetchdelegateGroupofRequestors(newShareHolderUserIdSet);  
        Id privilegedGroupId = [SELECT Id FROM Group WHERE Name =: System.Label.Event_Expense_Privileged_User_Group].Id;
        for(Event_Expense__c EvntExp : evtExpenseList)
        {           
            if(EvntExp.Requestor_Name__c != null && mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__r.isActive && mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__c  != EvntExp.ownerId){
                SharingEventExpenseList.add(new Event_Expense__share(ParentId = EvntExp.id, UserOrGroupId = mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__c, Accesslevel = 'Edit' ));     
            }
            if(delegateGroupIdMap.containsKey(mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__c)){
                for(Id delegateGrpId1 : delegateGroupIdMap.get(mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__c))
                {
                    SharingEventExpenseList.add(new Event_Expense__share(ParentId = EvntExp.id, UserOrGroupId = delegateGrpId1, Accesslevel = 'Edit' ));
                }   
            } 
            
            SharingEventExpenseList.add(new Event_Expense__share(ParentId = EvntExp.id, UserOrGroupId = privilegedGroupId, Accesslevel = 'Edit' ));
        }
        
        if(SharingEventExpenseList.size() > 0 )
        {
            insert SharingEventExpenseList;
        }  
  }
  
  // To set up sharing of event expense  record with All approvers, requestor and additional requestor and submitter
  public static void SetupSharingForEventExpennseOnUpdate(list<Event_Expense__c> evtExpenseList, map<Id,Event_Expense__c> oldEventExpenseMap)
  {     
        set<Id> RequestorContSet = new set<Id>();
        set<Id> submitterUserIdSet = new set<Id>();
        
        set<Id> TodeleteExistngSharingSet = new set<Id>();
        set<Id> mixShareHoldersSet = new set<Id>();
        
        List<Event_Expense__share> SharingEventExpenseList = new List<Event_Expense__share>();
        
        for(Event_Expense__c EventExpnse : evtExpenseList)
        {
            if(EventExpnse.Requestor_Name__c != oldEventExpenseMap.get(EventExpnse.id).Requestor_Name__c )
            {
                if(EventExpnse.Requestor_Name__c != null)
                {
                    RequestorContSet.add(EventExpnse.Requestor_Name__c);
                    RequestorContSet.add(oldEventExpenseMap.get(EventExpnse.id).Requestor_Name__c);
                }
            }            
        }
                
        Map<Id, Contact> mapofContIdToUserRecord = new Map<Id, Contact>();
        for(Contact c : [Select id, User__c, User__r.isActive From Contact Where Id IN : RequestorContSet ])
        {
                mapofContIdToUserRecord.put(c.Id, c);
        }
                
        for(Event_Expense__c EventExpnse : evtExpenseList)
        {
            if(EventExpnse.Requestor_Name__c != oldEventExpenseMap.get(EventExpnse.id).Requestor_Name__c )
            {
                if(mapofContIdToUserRecord.get(EventExpnse.Requestor_Name__c).User__c != null && mapofContIdToUserRecord.get(EventExpnse.Requestor_Name__c).User__r.isActive  && mapofContIdToUserRecord.get(EventExpnse.Requestor_Name__c).User__c  != EventExpnse.ownerId)
                {
                    SharingEventExpenseList.add(new Event_Expense__share(ParentId = EventExpnse.id, UserOrGroupId = mapofContIdToUserRecord.get(EventExpnse.Requestor_Name__c).User__c , Accesslevel = 'Edit' ));
                    mixShareHoldersSet.add(mapofContIdToUserRecord.get(EventExpnse.Requestor_Name__c).User__c);
                }
                mixShareHoldersSet.add(mapofContIdToUserRecord.get(oldEventExpenseMap.get(EventExpnse.id).Requestor_Name__c).User__c);
                TodeleteExistngSharingSet.add(mapofContIdToUserRecord.get(oldEventExpenseMap.get(EventExpnse.Id).Requestor_Name__c).User__c);
            }
            
        }
            map<Id, set<Id>> delegateGroupIdMap = new map<Id,set<Id>>();
            if(mixShareHoldersSet.size() > 0)
            {
                delegateGroupIdMap = fetchdelegateGroupofRequestors(mixShareHoldersSet);                
                for(Event_Expense__c EvntExp : evtExpenseList)
                {
                    if(EvntExp.Requestor_Name__c != oldEventExpenseMap.get(EvntExp.Id).Requestor_Name__c)
                    {
                        if(delegateGroupIdMap.containsKey(mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__c)){
                            for(Id delegateGrpId1 : delegateGroupIdMap.get(mapofContIdToUserRecord.get(EvntExp.Requestor_Name__c).User__c))
                                SharingEventExpenseList.add(new Event_Expense__share(ParentId = EvntExp.id, UserOrGroupId = delegateGrpId1, Accesslevel = 'Edit' ));
                               
                        }
                        if(delegateGroupIdMap.containsKey(mapofContIdToUserRecord.get(oldEventExpenseMap.get(EvntExp.Id).Requestor_Name__c).User__c))
                            TodeleteExistngSharingSet.addAll(delegateGroupIdMap.get(mapofContIdToUserRecord.get(oldEventExpenseMap.get(EvntExp.Id).Requestor_Name__c).User__c));
                        
                    }                   
                }
            }
            
            list<Event_Expense__share> existingEvenntExpenseSharing = new list<Event_Expense__share>();
            existingEvenntExpenseSharing = [SELECT Id FROM Event_Expense__share WHERE ParentId IN : evtExpenseList AND UserOrGroupId IN : TodeleteExistngSharingSet AND  rowcause != 'Owner'];
            if(existingEvenntExpenseSharing.size() > 0)
                delete existingEvenntExpenseSharing ;
            if(SharingEventExpenseList.size() > 0)
                insert SharingEventExpenseList;
  }
  
  // To set up sharing of event expense  record with All approvers, requestor and additional requestor and submitter
  public static void SetupSharingForEventExpennseOnSubmission(Event_Expense__c evtExpense)
  {
        ClearexistingSharing(evtExpense);
      
        set<Id> finalshareholders = new set<Id>();
        finalshareholders = fetchshareholders(evtExpense);
      
        if(finalshareholders.size() > 0)
            CreateSharingRecordsforEventExpense(evtExpense, finalshareholders);
      
  }
  
  // To delete existing event expense sharing to before recalculating for new sharing. 
  public static void ClearexistingSharing(Event_Expense__c evtExpense)
  {
    list<Event_Expense__share> existingEvenntExpenseSharing = new list<Event_Expense__share>();
    existingEvenntExpenseSharing = [SELECT Id FROM Event_Expense__share WHERE ParentId = : evtExpense.Id AND rowcause = 'Manual'];
    if(existingEvenntExpenseSharing.size() > 0)
        delete existingEvenntExpenseSharing ;
  }
  
  /******************************************************************
  // Setup new Sharing records for all share holders
  ******************************************************************/
  public static void createSharingRecordsforEventExpense(Event_Expense__c evtExpense, set<Id> shareHolderIdSet)
  {
    list<Event_Expense__share> SharingEventExpenseList = new list<Event_Expense__share>();
    if(shareHolderIdSet.size() > 0){
      for(Id UserGroupId : shareHolderIdSet) 
      {
        if(UserGroupId != null && UserGroupId != evtExpense.ownerId)
          SharingEventExpenseList.add(new Event_Expense__share(ParentId = evtExpense.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit' ));     
      }
      if(SharingEventExpenseList.size() > 0 )
      {
        insert SharingEventExpenseList;
      }         
    }  
  }
  public static set<Id> fetchshareholders(Event_Expense__c evtExpense)
  {
    //1. Get Approvers based on custom metadata - Event_Expense_Approver__mdt
    set<Id> ApproversIdSet = new set<Id>(); 
    ApproversIdSet = getProdApproversIdSet(evtExpense.Product_Type__c, evtExpense.LOB__c);
    
    //2. Get Requesters
    set<Id> requestorsIdSet = new set<Id>(); 
    requestorsIdSet.add(evtExpense.Requestor_Name__r.User__c);
    
    
    //3. Get Deleagte Group Ids from Requestors
    List<Id> delegateGroupIdList = new List<Id>();
    map<Id, set<Id>> delegateGroupIdMap = new map<Id,set<Id>>();
    if(requestorsIdSet.size() > 0){
        delegateGroupIdMap = fetchdelegateGroupofRequestors(requestorsIdSet);
        for(Id UserId: delegateGroupIdMap.keySet())
        {
            delegateGroupIdList.addAll(delegateGroupIdMap.get(UserId));    
        }
        
    }
    set<Id> finalListofShareHolders = new set<Id>();
    finalListofShareHolders.addAll(ApproversIdSet);
    finalListofShareHolders.addAll(requestorsIdSet);
    finalListofShareHolders.addAll(delegateGroupIdList);
    //return finalListofShareHolders;  
    
    set<Id> finalListofActiveShareHolders = new set<Id>();
    finalListofActiveShareHolders = fetchActiveShareHolders(finalListofShareHolders);
    
    return finalListofActiveShareHolders;
  }
    
    // To fetch all active user for sharing records
    public static set<Id> fetchActiveShareHolders(Set<Id> allSharingUserId){
        
        // To select active User
        set<Id> activeApproversIdSet = new set<Id>();
        for(User activeId : [SELECT Id FROM User WHERE Id IN: allSharingUserId AND IsActive = true]){
            activeApproversIdSet.add(activeId.Id);
        }
        
        // To add group
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        for(string grpId : allSharingUserId){
            if(grpId.startsWith(groupType)){
                activeApproversIdSet.add(grpId);
            }
        }
        
        return activeApproversIdSet;
    }
    
      
  public static map<Id, set<Id>> fetchdelegateGroupofRequestors(set<Id> requestorsIdSet)
  {
    map<Id, set<Id>>  delegateUserIdMap = new map<Id, set<Id>>();
    for(Delegate_Public_Group__c DGP : [SELECT Public_Group_ID__c, Banker__c FROM Delegate_Public_Group__c WHERE Banker__c IN : requestorsIdSet])
    {
        if(!delegateUserIdMap.containsKey(DGP.Banker__c))
            delegateUserIdMap.put(DGP.Banker__c, new Set<Id>{DGP.Public_Group_ID__c});
        else
            delegateUserIdMap.get(DGP.Banker__c).add(DGP.Public_Group_ID__c); 
    }
    return delegateUserIdMap;
  }
  
  // Archive existing approvers history and Create new Approver history with Pending status. 
  public static void ArchiveExistingEEAppHistryCreateNewEEAppHistry(Event_Expense__c EventExpenseRec){
        List<Event_Expense_Approval_History__c> ExistingEEApproverHistoryRecordList = new List<Event_Expense_Approval_History__c>();
        List<Event_Expense_Approval_History__c> NewEEApproverHistoryRecordList = new List<Event_Expense_Approval_History__c>();
        ExistingEEApproverHistoryRecordList = [Select Is_Archive__c, Status__c from Event_Expense_Approval_History__c WHERE Event_Expense__c=:EventExpenseRec.id];
        for(Event_Expense_Approval_History__c ee:ExistingEEApproverHistoryRecordList){
            ee.Is_Archive__c = true;            
        }
        
        // Archive existing approvers history
        if(ExistingEEApproverHistoryRecordList.size() > 0){
            update ExistingEEApproverHistoryRecordList;
        }
        Set<Id> NewApproverSet = new Set<Id>();
        NewApproverSet = getProdApproversIdSet(EventExpenseRec.Product_Type__c, EventExpenseRec.LOB__c);
        // Creating new Approver history with Pending status        
        for(Id  approverId : NewApproverSet){
            NewEEApproverHistoryRecordList.add(new Event_Expense_Approval_History__c(Status__c = 'Pending', Event_Expense__c = EventExpenseRec.Id, Approver__c = approverId));            
        }
        // Archive existing approvers history
        if(NewEEApproverHistoryRecordList.size() > 0){
            insert NewEEApproverHistoryRecordList;
        }
        
    }
    
  public static void UpdateExistingApprovalHistory(Event_Expense__c evtExpense, String ApproverResponse, String ApproverComment){
      List<Event_Expense_Approval_History__c> EvExpApprovalHistryList  = new List<Event_Expense_Approval_History__c>(); 
      EvExpApprovalHistryList = [SELECT Id,Status__c, Approver__c,Approver_s_Level__c  FROM Event_Expense_Approval_History__c Where Is_Archive__c = False AND Status__c =:STATUS_PENDING AND Event_Expense__c =: evtExpense.Id];
      for(Event_Expense_Approval_History__c EvExpApprovalHistry : EvExpApprovalHistryList)
      {          
          if(EvExpApprovalHistry.Approver__c == UserInfo.getUserId()){
              EvExpApprovalHistry.Status__c = ApproverResponse;
              EvExpApprovalHistry.Notes__c = ApproverComment;
          }    
          else
              EvExpApprovalHistry.Status__c = 'No Action Required';
          evtExpense.Current_Approver__c = UserInfo.getUserId();
          evtExpense.Current_Approval_Level__c = EvExpApprovalHistry.Approver_s_Level__c ;      
                    
      }  
      
      if(EvExpApprovalHistryList.size() > 0)
          Update EvExpApprovalHistryList;
      
        
      update evtExpense;
      
  }
  
  /******************************************************************
  Method to get the current approvers from Event_Expense_Approval_History__c for the current Event_Expense__c record
  ******************************************************************/
  public static set<Id> getCrntApproverUsrsFromEvtExpAppHistory (Event_Expense__c evtExpense){
    
        set<Id> crntAppUsrIdSet = new set<Id>();
        for(Event_Expense_Approval_History__c EvExpApprovalHistry : [SELECT Id, Status__c, Approver__c  
                          FROM Event_Expense_Approval_History__c
                          Where Is_Archive__c = false
                          AND Approver__c != null
                          AND Status__c = 'No Action Required'
                          AND Event_Expense__c =: evtExpense.Id
                          AND Approver_s_Level__c = : evtExpense.Current_Approval_Level__c
                          AND Approver__c != : UserInfo.getUserId() 
                          ]){
              
              crntAppUsrIdSet.add(EvExpApprovalHistry.Approver__c);
        }
            
       // return crntAppUsrIdSet;
          set<Id> crntActiveAppUsrIdSet = new set<Id>();
        for(User activeUser : [SELECT Id FROM User WHERE Id IN:crntAppUsrIdSet AND IsActive = true]){
            crntActiveAppUsrIdSet.add(activeUser.Id);
        }
        
        return crntActiveAppUsrIdSet;
  }
  
  /******************************************************************
  Method to update the current Event_Expense__c record with passed values
  ******************************************************************/
  public static void updateEvtExpWithAppResponse (Event_Expense__c evtExpense, String ApproverResponse, String ApproverComment){
    
    evtExpense.Status__c = ApproverResponse;
    evtExpense.Approver_s_Notes__c = ApproverComment;
    evtExpense.Current_Approver__c = UserInfo.getUserId();
    update evtExpense;
  }
  
  /******************************************************************
  Method to check if the approval is the final Approval or not
  ******************************************************************/
  public static list<boolean> isFinalApproval(Event_Expense__c evtExpense, set<Id> lvl2ApproversIdSet){
    
    boolean isFinalApporved = false;
    boolean isRoundOne = false;
    for(Event_Expense_Approval_History__c evtExp_AppHist : [Select Id, Approver_s_Level__c
                                                            From Event_Expense_Approval_History__c
                                                            Where Is_Archive__c = false
                                                            AND Status__c = :STATUS_APPROVED
                                                            AND Approver__c = :UserInfo.getUserId()]){
      isFinalApporved = true;
      isRoundOne = evtExp_AppHist.Approver_s_Level__c == '1';
      break;
    }
    
    if(isFinalApporved){
        if(lvl2ApproversIdSet.size() == 0)
        {
            isFinalApporved = true;
        }
        else        
        {
            isFinalApporved = lvl2ApproversIdSet.contains(UserInfo.getUserId());
        }
        
    }
    return new list<boolean>{isFinalApporved, isRoundOne}; 
  }
  
  /******************************************************************
  Method to get the set of Level-2 Approver User Ids based on the different parameters 
  defined in the custom metadata - Event_Expense_Approver__mdt
  ******************************************************************/
  public static set<Id> getLevl2ApproversIdSet(Event_Expense__c evtExp){
    
    String budgetRange = getBudgetRange(evtExp.Total_Budget_Requested__c);    
    set<Id> approverIdSet = new set<Id>(); 
    if(!(evtExp.Product_Type__c == 'General' && budgetRange == BUDGETRANGE_UPTO_10K)){
        for(Event_Expense_Approver__mdt EE_Approver_mdt : [Select Approver_ID__c, Expense_Budget_Range__c, LOB__c
                                                    From Event_Expense_Approver__mdt
                                                    Where Is_Active__c = true AND LOB__c = :evtExp.LOB__c
                                                    AND Approver_ID__c != null
                                                    AND Expense_Budget_Range__c = :budgetRange]){
          approverIdSet.add(EE_Approver_mdt.Approver_ID__c);
        }
    }
    system.debug('check3--'+approverIdSet.size());
    //return approverIdSet;
     set<Id> activeApproverIdSet = new set<Id>();
    for(User activeUser : [SELECT Id FROM User WHERE Id IN:approverIdSet AND IsActive = true]){
        activeApproverIdSet.add(activeUser.Id);
    }
    
    return activeApproverIdSet; 
  }
  /******************************************************************
  Method to get the budget range corresponding to the total budget amount
  ******************************************************************/
  public static String getBudgetRange(Decimal budget){
    String budgetRange = '';
    
    if(budget <= 10000){
      budgetRange = BUDGETRANGE_UPTO_10K;
    }
    else if(budget > 10000 && budget <= 25000){
      budgetRange = BUDGETRANGE_BETWEEN_10K_25K;
    }else if(budget > 25000){
      budgetRange = BUDGETRANGE_OVER_25K;
    }
    return budgetRange;
  }
  
  /******************************************************************
  Method to get the Contact Id set for the passed set of user Ids
  ******************************************************************/
  public static set<Id> getContIdSet(set<Id> usrIdSet, map<Id, Id> usrIdContIdMap) {
    
    set<Id> contIdSet = new set<Id>();
    
    for(Id usrId : usrIdSet){
      if(usrIdContIdMap.containsKey(usrId)) contIdSet.add(usrIdContIdMap.get(usrId));
    }
    return contIdSet;                    
  }
  
  /******************************************************************
  Method to get email Email Message
  ******************************************************************/
  public static Messaging.SingleEmailMessage getEmailMessage (list<Id> toContIdsLst, Id emlTemId, Id whtId){
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toContIdsLst);
    mail.setTemplateId(emlTemId);
    mail.setTargetObjectId(toContIdsLst.get(0));
    mail.setTreatTargetObjectAsRecipient(false);
    mail.setWhatId(whtId);
    return mail;    
  }
  
  
  /******************************************************************
  Method to get the email Template Id
  ******************************************************************/
  public static map<String, Id> getEmailTempNameIdMap (set<String> emailTempNameSet){
    
    map<String, Id> emlTemNameIdMap = new map<String, Id>(); 
    for(EmailTemplate emlTemp : [SELECT Id, Name
                                FROM EmailTemplate
                                Where Name IN :emailTempNameSet]){
      emlTemNameIdMap.put(emlTemp.Name, emlTemp.Id);
    }
    return emlTemNameIdMap;
  }
  
  /******************************************************************
  Method to get the userId to Contact Id Map for the passed set of user Ids
  ******************************************************************/
  public static map<Id, Id> getUsrIdContIdMap (set<Id> usrIdSet) {
    map<Id, Id> usrIdContIdMap = new map<Id, Id>();
    
    for(Contact cont : [Select Id, User__c, User__r.isActive From Contact 
                        Where Email != null AND User__c IN : usrIdSet AND IsEmailBounced = false AND User__r.isActive = true AND Status__c = 'Active']){
                            
        usrIdContIdMap.put(cont.User__c, cont.Id);
        
      
    }
     
    return usrIdContIdMap;                    
  }
  
  /******************************************************************
  Method to get the Event_Expense_Approval_History__c records list for the passed Event_Expense__c
  ******************************************************************/
  public static void archiveEvtExpApprovalHistoryRecordslst(Event_Expense__c evtExpense) {
       
    list<Event_Expense_Approval_History__c> eeAprHistLstToUpdate = new list<Event_Expense_Approval_History__c>();
      eeAprHistLstToUpdate = [Select Id 
                              From Event_Expense_Approval_History__c
                              Where Event_Expense__c = :evtExpense.Id AND Is_Archive__c = false];
      for(Event_Expense_Approval_History__c eeAprHist : eeAprHistLstToUpdate){
        eeAprHist.Is_Archive__c = true; 
      }
      if(!eeAprHistLstToUpdate.isEmpty()){
        update eeAprHistLstToUpdate;
      }
      
  }
  
  /******************************************************************
  Method to create the Event_Expense_Approval_History__c records for the passed Approver Id set
  ******************************************************************/
  public static void createEvtExpApprovalHistoryRecords(Event_Expense__c evtExpense, set<Id> firstLevelApproverUsrIdSet, String level) {
        
    if(!firstLevelApproverUsrIdSet.isEmpty()){
      
      list<Event_Expense_Approval_History__c> eeAprHistLstToInsert = new list<Event_Expense_Approval_History__c>();
      //for(Id usrId : firstLevelApproverUsrIdSet){
      for(User activeUsrId : [SELECT ID from User WHERE Id IN:firstLevelApproverUsrIdSet AND IsActive = true]){
        eeAprHistLstToInsert.add(createEvtExpApprovalHistory(evtExpense.Id, activeUsrId.Id, level));
      }
      
      if(!eeAprHistLstToInsert.isEmpty()){
        insert eeAprHistLstToInsert;
      }
    }//end if - outer
  }
  
  /******************************************************************
  Method to create the Event_Expense_Approval_History__c records for the passed Approver Id set
  ******************************************************************/
  public static Event_Expense_Approval_History__c createEvtExpApprovalHistory(Id evtExpenseId, Id usrId, String level) {
      return new Event_Expense_Approval_History__c(Event_Expense__c = evtExpenseId, Approver__c = usrId, Approver_s_Level__c = level, Status__c = STATUS_PENDING);
     
  }
  
  /******************************************************************
  Method to get the set of Product Approver User Ids based on the different parameters 
  defined in the custom metadata - Event_Expense_Product_Approver__mdt
  ******************************************************************/
  public static set<Id> getProdApproversIdSet(String prodType, String lob){
    
    set<Id> approverUsrIdSet = new set<Id>();
    
    if(prodType != null && lob != null){
    
        for(Event_Expense_Product_Approver__mdt EE_Prod_Approver_mdt : [Select Approver_User_Id__c, Product_Type__c, Level__c
                                                    From Event_Expense_Product_Approver__mdt
                                                    Where Is_Active__c = true AND Product_Type__c = :prodType AND Approver_User_Id__c != null 
                                                    AND LOB__c = :lob]){
          approverUsrIdSet.add(EE_Prod_Approver_mdt.Approver_User_Id__c);
        }
    }  
    //return approverUsrIdSet;
    set<Id> approverActiveUsrIdSet = new set<Id>();
    for(User activeUser : [SELECT Id FROM User WHERE Id IN:approverUsrIdSet AND IsActive = true]){
        approverActiveUsrIdSet.add(activeUser.Id);
    }
    
    return approverActiveUsrIdSet;
  }

  /******************************************************************
  Method to get the set of CF Approver User Ids based on the different parameters 
  defined in the custom metadata - Event_Expense_CF_Product_Approver__mdt
  ******************************************************************/
  public static set<Id> getCFProdApproversIdSet(Event_Expense__c evtExpense){
    
    set<Id> approverUsrIdSet = new set<Id>();
    set<Id> approverActiveUsrIdSet = new set<Id>();
    list<String> approverLocationList = new List<String>();
        
    for(Event_Expense_CF_Approver__mdt EE_Prod_Approver_mdt : [Select Approver_User_Id__c, Classification__c, Industry_Group__c, Location__c, IsAdmin__c
                                                    From Event_Expense_CF_Approver__mdt
                                                    Where Approver_User_Id__c != null AND IsActive__c = true]){
        
        if(EE_Prod_Approver_mdt.IsAdmin__c && EE_Prod_Approver_mdt.Classification__c == 'All'){
            approverUsrIdSet.add(EE_Prod_Approver_mdt.Approver_User_Id__c);
        }
        
        
         if((evtExpense.Classification__c == 'Marketing' && evtExpense.Classification__c == EE_Prod_Approver_mdt.Classification__c) || evtExpense.Asked_to_Present__c || EE_Prod_Approver_mdt.Classification__c == 'All') {
            if(EE_Prod_Approver_mdt.IsAdmin__c){
                approverUsrIdSet.add(EE_Prod_Approver_mdt.Approver_User_Id__c);
            }
            
            if(evtExpense.Industry_Group__c !=null && evtExpense.Office__c !=null){
                if(evtExpense.Industry_Group__c == EE_Prod_Approver_mdt.Industry_Group__c || (String.isNotBlank(EE_Prod_Approver_mdt.Location__c) && EE_Prod_Approver_mdt.Classification__c == 'All')){
                    approverLocationList = EE_Prod_Approver_mdt.Location__c.split(',');
                    if(approverLocationList.contains(evtExpense.Office__c)){
                        approverUsrIdSet.add(EE_Prod_Approver_mdt.Approver_User_Id__c);
                    }                  
                }
            }      
        }
    }

    for(User activeUser : [SELECT Id FROM User WHERE Id IN:approverUsrIdSet AND IsActive = true]){
        approverActiveUsrIdSet.add(activeUser.Id);
    }
    
    return approverActiveUsrIdSet;
  }

  
  // Method to identify those approver who did not performed any action on Event Expense form
  public static Set<Id> getSameLevelApprovers(Event_Expense__c evtExpense)
  {
        Set<Id> EvExpApprovalHistryIdSet  = new Set<Id>(); 
        for( Event_Expense_Approval_History__c EvExpApprovalHistry: [SELECT Approver__c  FROM Event_Expense_Approval_History__c Where Is_Archive__c = False AND Approver__c !=:  UserInfo.getUserId() AND  Status__c = 'Pending' AND Event_Expense__c =: evtExpense.Id]) 
        {
            EvExpApprovalHistryIdSet.add(EvExpApprovalHistry.Id);
        }
        return EvExpApprovalHistryIdSet;
  }
  
}