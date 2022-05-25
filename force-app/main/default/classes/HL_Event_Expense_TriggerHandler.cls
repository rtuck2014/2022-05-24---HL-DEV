/***********************************************************************************************
Name    : HL_Event_Expense_TriggerHandler 
Purpose    : Trigger Handler Class for all trigger events of the Object - Event_Expense__c 
Test Class : HL_Test_EventExpenseViewClass and HL_Test_EventExpenseClass
/***********************************************************************************************/
public without sharing class HL_Event_Expense_TriggerHandler {
    
    public final static String EVT_EXP_STATUS_APPROVED = 'Approved';
    public final static String EVT_EXP_STATUS_SAVED = 'Saved';
    public final static String EVT_EXP_STATUS_REJECTED = 'Rejected';
    public final static String EVT_EXP_STATUS_WAITING_FOR_APPROVAL  = 'Waiting for Approval';
    public final static String EVT_EXP_STATUS_MORE_INFO_REQUESTED  = 'More Information Requested';
    public final static String EVT_EXP_STATUS_DELETED  = 'Deleted';
    public final static String EVT_EXP_LOB_CF  = 'CF';
    
    /*****************************************************
Method to be called on Before Insert
******************************************************/
    public static void beforeInsert(List<Event_Expense__c> newEventExpenseList, Map<Id, Event_Expense__c> newEventExpenseMap, List<Event_Expense__c> oldEventExpenseList , Map<Id, Event_Expense__c> oldEventExpenseMap) {
        //string user_id = UserInfo.getUserId();
        checkInternalUser(newEventExpenseList);
        checkRequestorsDelegateUser(newEventExpenseList, oldEventExpenseMap, 'Insert'); 
        updateCFEventInformation(newEventExpenseList, oldEventExpenseMap, 'Insert');            
    }
    
    /*****************************************************
Method to be called on Before Update
******************************************************/
    public static void beforeUpdate(List<Event_Expense__c> newEventExpenseList, Map<Id, Event_Expense__c> newEventExpenseMap, List<Event_Expense__c> oldEventExpenseList , Map<Id, Event_Expense__c> oldEventExpenseMap) {
        HL_EventExpense_Util.SetupSharingForEventExpennseOnUpdate(newEventExpenseList,oldEventExpenseMap);
        //Method to update the Status based on Crucial Feilds when user clicks on Save button
        updateEvtExpOnSaveBtn(newEventExpenseList, oldEventExpenseMap);
        checkRequestorsDelegateUser(newEventExpenseList, oldEventExpenseMap, 'Update');
        formSubmittedDate(newEventExpenseList, oldEventExpenseMap);
        updateCFEventInformation(newEventExpenseList, oldEventExpenseMap, 'Update');         
        //Nara-01272020: Method commented for project: PRJ0016816
        //checkValidUserAndField(newEventExpenseList, oldEventExpenseMap);
    }
    
    /*****************************************************
Method to be called on Before Delete
******************************************************/
    public static void beforeDelete(List<Event_Expense__c> newEventExpenseList, Map<Id, Event_Expense__c> newEventExpenseMap, List<Event_Expense__c> oldEventExpenseList , Map<Id, Event_Expense__c> oldEventExpenseMap) {
        
    }
    
    /*****************************************************
Method to be called on After Insert
******************************************************/
    public static void afterInsert(List<Event_Expense__c> newEventExpenseList, Map<Id, Event_Expense__c> newEventExpenseMap, List<Event_Expense__c> oldEventExpenseList , Map<Id, Event_Expense__c> oldEventExpenseMap) {
        HL_EventExpense_Util.SetupSharingForEventExpennseOnCreation(newEventExpenseList);     
    }

    /*****************************************************
Method to be called on After Update
******************************************************/
    public static void afterUpdate(List<Event_Expense__c> newEventExpenseList, Map<Id, Event_Expense__c> newEventExpenseMap, List<Event_Expense__c> oldEventExpenseList , Map<Id, Event_Expense__c> oldEventExpenseMap) {
// Deactivated this on Sep 2020 because of Oracle changes
//  OpptyInternalTeam(newEventExpenseList, newEventExpenseMap, oldEventExpenseList, oldEventExpenseMap);
    }    
    
    /********************************************************************************************************
//Method to Check submitter is delegate of Requestor
********************************************************************************************************/
    public static boolean checkdelegateUser (Id submitterId, Id requestorId) {
        boolean isValidDelegate = false;
        if(submitterId == requestorId){
            isValidDelegate = true;
        } else{
            for(Delegate_Public_Group_Member__c dpgm:[Select Id, Delegate_ID__c from Delegate_Public_Group_Member__c WHERE Delegate_Public_Group__r.Banker__c=:requestorId]){
                if(dpgm.Delegate_ID__c == submitterId){
                    isValidDelegate = true;
                    break;
                }
            }
        }
        return isValidDelegate;
    }
    
    /********************************************************************************************************
//Method to insert Opportunity Internal Team on approval of CF Expense Request 
********************************************************************************************************/
    public static void OpptyInternalTeam(List<Event_Expense__c> newEvtExpenseList, Map<Id, Event_Expense__c> newEvtExpenseMap, List<Event_Expense__c> oldEvtExpenseList , Map<Id, Event_Expense__c> oldEvtExpenseMap) {
        Map<Id, Id> mapOfEvtAndRequestADD = new Map<Id, Id>();
        Map<Id, Id> mapOfEvtAndRequestDEL = new Map<Id, Id>();
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();        
        List<Opportunity_Internal_Team__c> oitToInsert = new List<Opportunity_Internal_Team__c>();  
        List<Opportunity_Internal_Team__c> oitToUpdate = new List<Opportunity_Internal_Team__c>();
       
        for(Event_Expense__c EvtExpense : newEvtExpenseMap.values()){
            if((oldEvtExpenseMap.get(EvtExpense.Id).Status__c != newEvtExpenseMap.get(EvtExpense.Id).Status__c)){
                if(newEvtExpenseMap.get(EvtExpense.Id).Status__c == 'Approved'){
                    mapOfEvtAndRequestADD.put(EvtExpense.Event__c, EvtExpense.Requestor_Name__c);    
                }else if(newEvtExpenseMap.get(EvtExpense.Id).Status__c == 'Deleted'){
                    mapOfEvtAndRequestDEL.put(EvtExpense.Event__c, EvtExpense.Requestor_Name__c);
                }
            
            }

            /*if(newEvtExpenseMap.get(EvtExpense.Id).Marketing_support__c == 'Yes'){
               mapOfEvtAndRequestADD.put(EvtExpense.Event__c, EvtExpense.Requestor_Name__c);
            }else if(newEvtExpenseMap.get(EvtExpense.Id).Marketing_support__c == 'No'){
               mapOfEvtAndRequestDEL.put(EvtExpense.Event__c, EvtExpense.Requestor_Name__c);
            }*/
        }

        if(mapOfEvtAndRequestADD.size() > 0){
            List<Staff_Role__c> staffRole = [SELECT Id, Name, Opportunity__c, CF__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Fin_Only__c, Non_Fin_Only__c, Registered_Excluded_Job_Codes__c 
                                          FROM Staff_Role__c WHERE Name = 'Expense Only'];

            if(staffRole.size() > 0){
                for(Staff_Role__c sRole : staffRole){
                    staffRoleList.add(sRole); 
                }
            }
            if(staffRole.size() > 0){
                List<Opportunity__c> opportunityList = [SELECT Id, Name FROM Opportunity__c WHERE Id IN: mapOfEvtAndRequestADD.KeySet() and Id NOT IN 
                                                        (SELECT Opportunity__c
                                                        FROM Opportunity_Internal_Team__c 
                                                        WHERE Contact__c IN :mapOfEvtAndRequestADD.Values() AND Role__c = 'Expense Only' AND End_Date__c = null
                                                        )
                                                     ];
                if(opportunityList.size() > 0){
                    for(Opportunity__c oppList: opportunityList){
                        oitToInsert.Add(New Opportunity_Internal_Team__c(Opportunity__c = oppList.id, Contact__c = mapOfEvtAndRequestADD.get(oppList.id), Staff_Role__c = staffRoleList.get(0).Id, Start_Date__c = Date.today())); 
                    }
                }
    
                if(oitToInsert.size() > 0){
                     insert oitToInsert;
                }
            }
        }   

        if(mapOfEvtAndRequestDEL.size() > 0){
            List<Opportunity_Internal_Team__c> oppInternalTeamList = [SELECT Id, Name, Opportunity__c, Contact__c FROM Opportunity_Internal_Team__c 
                                                    WHERE Opportunity__c IN: mapOfEvtAndRequestDEL.KeySet() AND 
                                                    Contact__c IN :mapOfEvtAndRequestDEL.Values() AND Role__c = 'Expense Only' AND End_Date__c = null
                                                 ];
            if(oppInternalTeamList.size() > 0){
                for(Opportunity_Internal_Team__c oitList: oppInternalTeamList){
                    
                    if(mapOfEvtAndRequestDEL.containsKey(oitList.Opportunity__c) && oitList.Contact__c == mapOfEvtAndRequestDEL.get(oitList.Opportunity__c)){
                        oitList.End_Date__c = Date.today();
                        oitToUpdate.Add(oitList); 
                    }
                }
            }

            if(oitToUpdate.size() > 0){
                update oitToUpdate;
            }
        }  
    }

    /********************************************************************************************************
//Method to update Event Information on CF Expense Request
********************************************************************************************************/
    public static void updateCFEventInformation(list<Event_Expense__c> newEventExpenseList,  map<Id, Event_Expense__c> oldEventExpenseMap, string source) {
        Event_Expense__c oldEvtExp;
        Set<Id> setReqIds = new Set<Id>();
        Set<Id> setEveIds = new Set<Id>();
        Map<Id, Contact> mapOfContactWithObject = new Map<Id, Contact>(); 
        Map<Id, Opportunity__c> mapOfOpptyWithObject = new Map<Id, Opportunity__c>(); 
                                
        for(Event_Expense__c evtExp : newEventExpenseList){
            if(source == 'Insert'){
                if(evtExp.LOB__c == EVT_EXP_LOB_CF && evtExp.Requestor_Name__c != null){
                    setReqIds.add(evtExp.Requestor_Name__c);
                }
                if(evtExp.LOB__c == EVT_EXP_LOB_CF && evtExp.Event__c != null){
                    setEveIds.add(evtExp.Event__c);
                }
            }
            if(source == 'Update'){
                oldEvtExp = oldEventExpenseMap.get(evtExp.Id);

                if(evtExp.LOB__c == EVT_EXP_LOB_CF && evtExp.Requestor_Name__c != null && oldEvtExp.Requestor_Name__c != evtExp.Requestor_Name__c){
                    setReqIds.add(evtExp.Requestor_Name__c);
                }                
                if(evtExp.LOB__c == EVT_EXP_LOB_CF && evtExp.Event__c != null && oldEvtExp.Event__c != evtExp.Event__c){
                    setEveIds.add(evtExp.Event__c);
                }else if(evtExp.LOB__c == EVT_EXP_LOB_CF && evtExp.Event__c == null){
                    evtExp.Event_Name__c = '';
                    evtExp.City__c = '';
                    evtExp.Event_Location__c = '';
                    evtExp.Event_Format__c = '';
                } 
            }
        }
        
        if(setReqIds != null && setReqIds.size() > 0){
            for(Contact objContact : [SELECT id, Name, CurrencyIsoCode from Contact WHERE Id IN :setReqIds]){
                mapOfContactWithObject.put(objContact.Id, objContact);
            }
            
            for(Event_Expense__c evtExp : newEventExpenseList){
                if(evtExp.Requestor_Name__c != null && mapOfContactWithObject.containsKey(evtExp.Requestor_Name__c)){
                    evtExp.CurrencyIsoCode = mapOfContactWithObject.get(evtExp.Requestor_Name__c).CurrencyIsoCode;
                }
            }
        }
        if(setEveIds != null && setEveIds.size() > 0){
            for(Opportunity__c objOppty : [SELECT id, Line_of_Business__c, Event_Type__c, Event_Format__c, Name, City__c,Event_Location__c from Opportunity__c WHERE Id IN :setEveIds]){
                mapOfOpptyWithObject.put(objOppty.Id, objOppty);
            }
            for(Event_Expense__c evtExp : newEventExpenseList){
                if(evtExp.Event__c != null && mapOfOpptyWithObject.containsKey(evtExp.Event__c)){
                    //evtExp.LOB__c = mapOfOpptyWithObject.get(evtExp.Event__c).Line_of_Business__c;   
                    evtExp.Event_Type_Format__c = mapOfOpptyWithObject.get(evtExp.Event__c).Event_Type__c;   
                    evtExp.Event_Format__c = mapOfOpptyWithObject.get(evtExp.Event__c).Event_Format__c;                                                           
                    evtExp.Event_Name__c = mapOfOpptyWithObject.get(evtExp.Event__c).Name;
                    evtExp.City__c = mapOfOpptyWithObject.get(evtExp.Event__c).City__c;
                    evtExp.Event_Location__c = mapOfOpptyWithObject.get(evtExp.Event__c).Event_Location__c;                                        
                }
            }                    
        }
    }

    
    /********************************************************************************************************
//Method to Check submitter is delegate of Requestor in Before insert
********************************************************************************************************/
    public static void checkRequestorsDelegateUser (list<Event_Expense__c> newEventExpenseList,  map<Id, Event_Expense__c> oldEventExpenseMap, string source) {
        Event_Expense__c oldEvtExp;
        for(Event_Expense__c evtExp : newEventExpenseList){
            if(source == 'Insert'){
                if(!evtExp.Is_Clone__c && !checkdelegateUser(UserInfo.getUserId(), evtExp.Requestor_s_User__c)){
                    evtExp.addError(Label.HL_EventExpenseRequestorOrDelegateOnCreate);
                }
            }
            if(source == 'Update'){
                oldEvtExp = oldEventExpenseMap.get(evtExp.Id);
                if((oldEvtExp.Status__c != evtExp.Status__c && evtExp.Status__c == EVT_EXP_STATUS_WAITING_FOR_APPROVAL) || oldEvtExp.Requestor_s_User__c != evtExp.Requestor_s_User__c){
                    if(!checkdelegateUser(UserInfo.getUserId(), evtExp.Requestor_s_User__c)){
                        evtExp.addError(Label.HL_EventExpenseRequestorOrDelegate);
                    }
                }
            }
        }
    }
    
    
    /********************************************************************************************************
//Method to update 'Submitted_Date__c' fields with the date on which user submits form.
********************************************************************************************************/
    public static void formSubmittedDate (list<Event_Expense__c> newEventExpenseList,  map<Id, Event_Expense__c> oldEventExpenseMap) {
        for(Event_Expense__c evtExp : newEventExpenseList){
            if(evtExp.Submitted_Date__c == null && evtExp.Status__c == EVT_EXP_STATUS_WAITING_FOR_APPROVAL){
                evtExp.Submitted_Date__c = system.today();
            }
        }
    }
    
    
    
    /********************************************************************************************************
//Method to check if valid P User is modifying correct field.
********************************************************************************************************/
    public static void checkValidUserAndField (list<Event_Expense__c> newEventExpenseList,  map<Id, Event_Expense__c> oldEventExpenseMap) {
        IF(!HL_EventExpense_Util.IN_APPROVAL_PROCESS){
            boolean validUser = checkPrivilegedUser();
            list<string> restrictedfields = validFieldsForUpdate();
            
            for(Event_Expense__c evtExp : newEventExpenseList){
                
                if((evtExp.Status__c == EVT_EXP_STATUS_APPROVED || evtExp.Status__c == EVT_EXP_STATUS_REJECTED || 
                    evtExp.Status__c == EVT_EXP_STATUS_WAITING_FOR_APPROVAL || evtExp.Status__c == EVT_EXP_STATUS_MORE_INFO_REQUESTED) && 
                   (oldEventExpenseMap.get(evtExp.Id).Status__c == evtExp.Status__c)){                
                       for(String eachField : restrictedfields){
                           
                           if((evtExp.get(eachField) != ((Event_Expense__c)Trigger.oldMap.get(evtExp.Id)).get(eachField)) &&
                              !(eachField == 'Specify__c' && (evtExp.Any_additional_cost_Specify__c > 0)) && validUser){
                                  
                                  evtExp.addError(System.Label.EventExpense_PrivilegedUser_FieldError);
                                  break;
                              }
                       }
                   }
            }
        }
    }
    
    
    
    // To check Privileged User
    public static boolean checkPrivilegedUser(){
        
        boolean isPrivilegedUser = false;
        
        // to check logged in user in privileged group
        list<GroupMember> GroupMemberList = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember 
                                             WHERE Group.Name =: System.Label.Event_Expense_Privileged_User_Group  AND UserOrGroupId =: UserInfo.getUserId()];
        if(GroupMemberList.size() > 0)
            isPrivilegedUser = true;
        
        // to check logged in user in privileged label
        if(!isPrivilegedUser){
            list<Profile> currentUserProfileName = [Select Id,Name from Profile 
                                                    where Id =: UserInfo.getProfileId() AND Name IN: System.Label.Event_Expense_Privileged_Users_Label.split(',')];
            if(currentUserProfileName.size() > 0)
                isPrivilegedUser = true;
        }
        return isPrivilegedUser;
    }
    
    
    // To check fields which can be modified by Privileged User
    public static list<string> validFieldsForUpdate(){
        
        List<string> lstFieldstoUpdate = new List<String>();
        List<String> apiNamesEE =  new list<String>();
        
        List<Schema.FieldSetMember> fields = Schema.SObjectType.Event_Expense__c.fieldSets.getMap().get('Event_Expense_Privileged_Users_FieldSet').getFields();
        
        for(Schema.FieldSetMember fieldSetMemberObj : fields){
            lstFieldstoUpdate.add(fieldSetMemberObj.getFieldPath().toLowerCase());
        }
        
        Schema.DescribeSObjectResult AllEEFields = Event_Expense__c.sObjectType.getDescribe();
        //apiNamesEE.addAll(AllEEFields.fields.getMap().keySet().removeAll(lstFieldstoUpdate));
        
        for(string apiName : AllEEFields.fields.getMap().keySet()){
            Boolean fieldTypeOrEditable = AllEEFields.fields.getMap().get(apiName).getDescribe().isUpdateable();
            
            if(!lstFieldstoUpdate.contains(apiName.toLowerCase()) && fieldTypeOrEditable){
                apiNamesEE.add(apiName);
            }
            
        }
        
        return apiNamesEE;
    }
    
    
    /********************************************************************************************************
//Method to Check only internal user can create or submit record
********************************************************************************************************/
    public static void checkInternalUser (list<Event_Expense__c> newEventExpenseList) {
        
        Id HLContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Houlihan Employee').getRecordTypeId();
        contact currentUserContact = new Contact();
        boolean isValidUser = false;
        //Verifying if contact is internal contact 
        for(Contact cont : [SELECT RecordTypeId ,User__c FROM Contact Where User__c =: UserInfo.getUserId() lIMIT 1])
        {
            currentUserContact = cont;      
        }
        if(currentUserContact.RecordTypeId == HLContRecordTypeId){
            isValidUser = true;     
        }
        // verifying if user is system administrator
        if(!isValidUser){
            for(Profile P : [Select Name From Profile Where Name = 'System Administrator'])
            {
                if(p.id == UserInfo.getProfileId())
                    isValidUser = true;
            } 
        }
        if(!isValidUser){
            for(Event_Expense__c evtExp : newEventExpenseList){
                evtExp.addError(Label.HL_OnlyInternalUserCanCreateSubmit);
            }
        }
    }
    
    /********************************************************************************************************
//Method to update the Status based on Crucial Feilds when user clicks on Save button
********************************************************************************************************/
    public static void updateEvtExpOnSaveBtn (list<Event_Expense__c> newEventExpenseList, map<Id, Event_Expense__c> oldEventExpenseMap) {
        
        //Set of Crucial Fields
        set<String> EE_CrucialFldsSet = new set<String>();
        for(HL_Event_Expense_Crucial_Fields__c EE_CF : HL_Event_Expense_Crucial_Fields__c.getAll().values()){
            EE_CrucialFldsSet.add(EE_CF.Name);
        }
        
        Event_Expense__c oldEvtExp;
        for(Event_Expense__c evtExp : newEventExpenseList){
            
            oldEvtExp = oldEventExpenseMap.get(evtExp.Id);
            //Handle when old status is Approved
            if(oldEvtExp.Status__c == EVT_EXP_STATUS_APPROVED){
                
                if(isCrucialFldUpdated(evtExp, oldEvtExp, EE_CrucialFldsSet)){
                    evtExp.Status__c = EVT_EXP_STATUS_SAVED;
                }
            }
            //Handle when old status is Rejected/More Information Requested 
            else if((oldEvtExp.Status__c == EVT_EXP_STATUS_REJECTED || oldEvtExp.Status__c == EVT_EXP_STATUS_MORE_INFO_REQUESTED) && (evtExp.Status__c != EVT_EXP_STATUS_WAITING_FOR_APPROVAL && evtExp.Status__c != EVT_EXP_STATUS_DELETED)){
                evtExp.Status__c = EVT_EXP_STATUS_SAVED;
            }
        }//end for loop
    }
    
    /********************************************************************************************************
//Method to update the Status based on Crucial Feilds when user clicks on Save button
/********************************************************************************************************/
    public static boolean isCrucialFldUpdated (Event_Expense__c evtExp, Event_Expense__c oldEvtExp, set<String> EE_CrucialFldsSet) {
        
        //Check if there is change in crucial fields maintained in custom setting HL_Event_Expense_Crucial_Fields__c
        for(String crucFld : EE_CrucialFldsSet){
            if(evtExp.get(crucFld) != oldEvtExp.get(crucFld)){
                return true;
            }
        }
        return false;
    }   
}