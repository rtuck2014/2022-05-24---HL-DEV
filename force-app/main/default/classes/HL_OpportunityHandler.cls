/*
* Name: HL_OpportunityHandler
* Created Date: 4/14/2015
* Description: Handler class for Opportunity records
* Modified Date: 10/31/2019
* Description:  Added the following methods for ERP Integration. The new methods are invoked from OnBeforeInsert, OnBeforeUpdate and OnAfterInsert methods.
*   a) cloneOpportunityContracts()
*   b) setContractEndDate()
*   c) updateOpportunityDuetoLegalEntityChange()
*   d) updateOppVATTreatment()
*   e) setERPUpdateFlags()
*   f) setLegalEntityFields()
*   g) clearERPUpdateFlags()
* Modified Date:  1/31/2020
* Description: Modified the following method to set the opportunity 'parent_sponsor_company__c' field
*   a) OnBeforeInsert()
* Modified Date:  3/30/2020
* Description: Added the following method to update CF Expense Request records
*   a) updateCFExpenseRequest()
* Modified Date:  04/34/2020 - Sapient
* Description: Added logic to ensure required fields are entered when CF Opportunity(having Non US Legal Entity) 'stage' value is changed to Verbally Engaged
*   a) validateRequiredFieldsOnStageChange()
*
* Modified Date:  10/04/2020 - Sapient
* Description: Updated logic to Check When 'LOB=CF' and 'legal Entity!= HL Capital Inc.' and if 'stage' changed from other to 'Verbally Engaged' show 'conflict check' error.
*   a) validateRequiredFieldsOnStageChange()
*/

public with sharing class HL_OpportunityHandler {
    private static Map<Id, Legal_Entity__c> hlLegalEntityMap;

    static {
        hlLegalEntityMap = new Map<Id, Legal_Entity__c>([
            SELECT Id, Name 
            FROM Legal_Entity__c 
            WHERE Name = 'HL Capital, Inc.' 
            LIMIT 1
        ]);
    }

    public static boolean ExecuteOnce = true;
    public static boolean IsTest = false;
    private boolean IsExecuting = false;
    private integer BatchSize = 0;
    public static Id recHLInternalOpp = Schema.SObjectType.Opportunity__c.getRecordTypeInfosByDeveloperName().get('HL_Internal_Opportunity').getRecordTypeId();
    
    public HL_OpportunityHandler(boolean executing, integer size)
    {
        IsExecuting = executing;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(List<Opportunity__c> opps){
        // 04/30/20 Start - Change added as part of CF 'Verbally Engaged' Requirements
        validateRequiredFieldsOnStageChange();
        // 04/30/20 End
        User UserOppData = [SELECT Office__c, DefaultCurrencyIsoCode FROM User WHERE id = :UserInfo.getUserId()];
        Map<String,Id> currencyToRateMap = HL_ExchangeRate.GetCurrencyIsoCodeMap();
        //Map of Id to the Code
        Set<Id> RelatedAccountIds = new Set<Id>();
        for(Opportunity__c Opp1 : opps){
            RelatedAccountIds.add(opp1.Client__c);
            RelatedAccountIds.add(opp1.Subject__c);
        }
        Map<String, Job_Type__c> jobTypeToCodeMap = HL_JobType.GetJobTypeMap();
        Map<Id,Account> AccMap = new Map<Id, Account>([Select Id, Ownership, parent_sponsor_company__c From Account Where Id IN: RelatedAccountIds ]);
        for(Opportunity__c Opp : opps){
            if(Opp.Client_Ownership__c == null && AccMap.get(Opp.Client__c) != null)
                Opp.Client_Ownership__c = AccMap.get(Opp.Client__c).Ownership;
            if(Opp.Subject_Company_Ownership__c== null && AccMap.get(Opp.Subject__c) != null)
                Opp.Subject_Company_Ownership__c =  AccMap.get(Opp.Subject__c).Ownership;
            if(Opp.Primary_Office__c == NULL){
                Opp.Primary_Office__c = UserOppData.Office__c;
            }
            if(UserOppData.DefaultCurrencyIsoCode == 'USD')
                Opp.Total_Debt_Currency__c = 'USD - U.S. Dollar';
            if(UserOppData.DefaultCurrencyIsoCode == 'AUD')
                Opp.Total_Debt_Currency__c = 'AUD - Australian Dollar';
            if(UserOppData.DefaultCurrencyIsoCode == 'EUR')
                Opp.Total_Debt_Currency__c = 'EUR - Euro';
            if(UserOppData.DefaultCurrencyIsoCode == 'GBP')
                Opp.Total_Debt_Currency__c = 'GBP - British Pound';
            if(UserOppData.DefaultCurrencyIsoCode == 'HKD')
                Opp.Total_Debt_Currency__c = 'HKD - Hong Kong Dollar';
            if(UserOppData.DefaultCurrencyIsoCode == 'JPY')
                Opp.Total_Debt_Currency__c = 'JPY - Japanese Yen';
            if(currencyToRateMap.get(Opp.CurrencyIsoCode) <> null)
                Opp.Exchange_Rate__c = currencyToRateMap.get(Opp.CurrencyIsoCode);
            if(!String.isBlank(Opp.Job_Type__c) && jobTypeToCodeMap.get(Opp.Job_Type__c) != null){
                Opp.Related_Job_Type__c = jobTypeToCodeMap.get(Opp.Job_Type__c).Id;
                Opp.Product_Type__c = jobTypeToCodeMap.get(Opp.Job_Type__c).Product_Line__c;
                Opp.ERP_Product_Type_Code__c = jobTypeToCodeMap.get(Opp.Job_Type__c).Product_Type_Code__c;
            }
            //update Parent Sponsor Company field
            if(AccMap.get(Opp.Client__c) != null){
                if(AccMap.get(Opp.Client__c).parent_sponsor_company__c != null)
                    Opp.parent_sponsor_company__c = AccMap.get(Opp.Client__c).parent_sponsor_company__c;
            }    
        }
        //Update Legal Entity fields
        setLegalEntityFields(opps);
    }
    
    public void OnBeforeUpdate(List<Opportunity__c> oldRecords, Map<Id, Opportunity__c> newRecordsMap){
        // 04/30/20 Start - Change added as part of CF 'Verbally Engaged' Requirements
        validateRequiredFieldsOnStageChange();
        // 04/30/20 End
        //Store the Changed Opportunity DND Records to Update the Related Engagements
        Map<Id, String> oppDNDMap = new Map<Id, String>();
        //Store the Engagements to Update the DND Status On
        List<Engagement__c> engagementUpdateList = new List<Engagement__c>();
        //Store the Changed Exchange Rate Opportunities
        Map<String,Id> currencyToRateMap = HL_ExchangeRate.GetCurrencyIsoCodeMap();
        //Map of Id to the Code
        Map<String, job_Type__c> jobTypeToCodeMap = HL_JobType.GetJobTypeMap();
        map<id, Opportunity__c> mapoffilteredOppWithChangedCurrency = new map<Id, Opportunity__c>();
        for(Opportunity__c ctOld : oldRecords)
        {
            Opportunity__c newOpp = ((Opportunity__c)newRecordsMap.get(ctOld.Id));
            if(ctOld.DND_Status__c <> newOpp.DND_Status__c)
                oppDNDMap.put(ctOld.Id, newRecordsMap.get(ctOld.Id).DND_Status__c);
            if(ctOld.CurrencyIsoCode <> newOpp.CurrencyIsoCode){
                if(currencyToRateMap.get(newOpp.CurrencyIsoCode) <> null)
                    newOpp.Exchange_Rate__c = currencyToRateMap.get(newOpp.CurrencyIsoCode);
                if(!newOpp.Converted_to_Engagement__c)
                    mapoffilteredOppWithChangedCurrency.put(ctOld.Id,newOpp);
            }            
            if(!String.isBlank(newOpp.Job_Type__c)){
                if(jobTypeToCodeMap.get(newOpp.Job_Type__c) != null){
                    newOpp.Related_Job_Type__c = jobTypeToCodeMap.get(newOpp.Job_Type__c).Id;
                    newOpp.Product_Type__c = jobTypeToCodeMap.get(newOpp.Job_Type__c).Product_Line__c;
                    newOpp.ERP_Product_Type_Code__c = jobTypeToCodeMap.get(newOpp.Job_Type__c).Product_Type_Code__c;
                }
            }     
            else
                newOpp.Related_Job_Type__c = null;
        }
        
        if(oppDNDMap.size() > 0)
        {
            for(Engagement__c e : [SELECT Name, Name1__c, Eng_Name_Store__c, Opportunity__c, DND_Status__c
                                   FROM Engagement__c
                                   WHERE Opportunity__c IN : oppDNDMap.keySet()]){
                                       e.DND_Status__c = oppDNDMap.get(e.Opportunity__c);
                                       
                                       if(e.DND_Status__c == 'Add Requested')
                                           e.Eng_Name_Store__c = e.Name;
                                       
                                       if(e.DND_Status__c == 'APPROVED'){
                                           e.Eng_Name_Store__c = e.Name;//e.eng_name_store = e.Name = 'Test Eng'
                                           e.Name = 'DND - ' + e.Id;
                                   		}
                                       else{
                                           if(e.DND_Status__c != 'Removal Requested')
                                               e.Name = e.Eng_Name_Store__c;
                                       }
                                       engagementUpdateList.add(e);
                                   }
            if(engagementUpdateList.size() > 0)
                update engagementUpdateList;
        }
        
        //Update Comments
        UpdateForComments(newRecordsMap.values());
        if(mapoffilteredOppWithChangedCurrency.keySet() != null && mapoffilteredOppWithChangedCurrency.keySet().size() > 0)
            UpdateCurrenyofPVfamily(mapoffilteredOppWithChangedCurrency);
        
        //Check changes to fields that needs to be synced with Oracle
        setERPUpdateFlags(oldRecords, newRecordsMap);
        
        //Clear out ERP Status flags if sync is successful
        clearERPUpdateFlags(oldRecords, newRecordsMap);
        
        //Assign a new opportunty number suffix and Legal Entity if 'Legal Entity' changes
        if(!HL_ConstantsUtil.stopOpportunityLegalEntityChangeTrigger 
           && HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Legal_Entity_Change))
            updateOpportunityDuetoLegalEntityChange();
        //Assign a new opportunty number suffix and Legal Entity if 'Currency' changes
        if(!HL_ConstantsUtil.stopOpportunityCurrencyChangeTrigger)
            updateOpportunityDuetoCurrencyChange();
    }    
    
    public void OnAfterInsert(Map<Id, Opportunity__c> newOpportunityMap)
    {
        SL_RelatedOppEgmtHelper.CreateInitialRelatedJoiners(newOpportunityMap, 'Opportunity_Client_Subject__c');
    }
    
    public void OnAfterUpdate(Map<Id, Opportunity__c> newOpportunityMap, Map<Id, Opportunity__c> oldOpportunityMap)
    {
        if(ExecuteOnce){
            SL_RelatedOppEgmtHelper.UpdateRelatedJoiners(newOpportunityMap, oldOpportunityMap, 'Opportunity_Client_Subject__c');
            ExecuteOnce = false;
        }
        
        updateCFExpenseRequest(newOpportunityMap, oldOpportunityMap);        
        ManageDNDSharingRule(newOpportunityMap, oldOpportunityMap);
        
        //Get Opportunities whose Legal Entity changed
        if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Legal_Entity_Change)){
            Set<Id> opportunityIdSet = new Set<Id>();
            for(Opportunity__c opp : newOpportunityMap.values()){
                if(opp.Legal_Entity__c != oldOpportunityMap.get(opp.Id).Legal_Entity__c
                   && opp.Legal_Entity__c != null){
                       opportunityIdSet.add(opp.Id);
                   }
            } 
            
            //When the Legal Entity of an opportunity changes, perform the following:
            // a) Update related opportunity VAT Treatments
            // b) Update the 'End Date' of related contracts
            // c) Clone related contracts (Type = engagement and 'End Date' is null)
            if(opportunityIdSet.size() > 0){
                if(!HL_ConstantsUtil.stopOpportunityLegalEntityChangeTrigger){
                    updateOppVATTreatment(opportunityIdSet);
                    setContractEndDate(opportunityIdSet);
                    cloneOpportunityContracts(opportunityIdSet);
                    HL_ConstantsUtil.stopOpportunityLegalEntityChangeTrigger = true;
                  
                }
            }
           if(!HL_ConstantsUtil.stopOpportunityCurrencyChangeTrigger) 
                 HL_ConstantsUtil.stopOpportunityCurrencyChangeTrigger = true;
        }
    }
    
    private void ManageDNDSharingRule(Map<Id, Opportunity__c> newOpportunityMap, Map<Id, Opportunity__c> oldOpportunityMap)
    {
        if(!SL_CheckRecursive.skipOnConvert){
            Set<String> opportunityIdSet = new Set<String>();
            
            //Iterating over Opportunity__c to get only those Opportunity id whose name is updated.
            for(Opportunity__c objOpportunity : newOpportunityMap.values())
            {
                if(objOpportunity.Name == null || oldOpportunityMap.get(objOpportunity.Id).Name == null) continue;
                if(objOpportunity.Name != oldOpportunityMap.get(objOpportunity.Id).Name
                   && (oldOpportunityMap.get(objOpportunity.Id).Name.startsWithIgnoreCase('DND')) || objOpportunity.Name.startsWithIgnoreCase('DND'))
                {
                    opportunityIdSet.add(objOpportunity.Id);
                }
            }
            
            //Calling the method to create the sharing rule according to the Opportunity__c names
            if(!opportunityIdSet.isEmpty())
                SL_ManageSharingRules.deleteSharesOnChangeParentName(opportunityIdSet, 'Opportunity__c');
        }
    }
    
    
    private void UpdateForComments(List<Opportunity__c> opps){
        List<Opportunity_Comment__c> commentList = new List<Opportunity_Comment__c>();
        
        for(Opportunity__c opp: opps){
            
            //Check to see if the new comment has a value or not
            if(opp.Opportunity_Comments__c != null && opp.Opportunity_Comments__c != '')
            {
                //If a value is found, create a new Engagement_Comments Object
                Opportunity_Comment__c oppComment = new Opportunity_Comment__c();
                
                oppComment.Comment__c = opp.Opportunity_Comments__c;
                oppComment.Comment_Type__c = 'Internal';
                oppComment.Line_of_Business__c = opp.Line_of_Business__c;
                oppComment.Related_Opportunity__c = opp.Id;
                oppComment.CurrencyIsoCode = opp.CurrencyIsoCode;
                commentList.add(oppComment);
                FormatLastComment(opp, oppComment, true);
                //Remove the value for the new comments field so it is never saved to the object and will be blank the next time Pipeline Manager is displayed
                opp.Opportunity_Comments__c = null;
            }
        }
        
        if(commentList.size() > 0){
            HL_TriggerContextUtility.SetFirstRunFalse();
            insert commentList;
        }
    }
    
    public static void FormatLastComment(Opportunity__c opp, Opportunity_Comment__c oc, boolean openToAll){
        integer newStartLocation,
            currCommentSize = oc.Comment__c.length(),
            newCommentStartSize;
        string newPartialComment, remainderComment,
            firstName = oc.CreatedBy == null ? UserInfo.getFirstName() : oc.CreatedBy.FirstName,
                lastName = oc.CreatedBy == null ? UserInfo.getLastName() : oc.CreatedBy.LastName,
                    createdDate = (oc.CreatedDate == null ? Date.today() : Date.valueOf(oc.CreatedDate)).format();
        string nameLog = (String.isBlank(firstName) ? '' : firstName.subString(0,1)) + lastName;
        
        //Update the last comments field as well (Split into 4 parts so the formula field can display the correct values)
        if(openToAll)
        {
            opp.Last_Opportunity_Comment_Part_1__c = '';  //Init fields to make sure they are blank from last usage
            opp.Last_Opportunity_Comment_Part_2__c = '';
            opp.Last_Opportunity_Comment_Part_3__c = '';
            opp.Last_Opportunity_Comment_Part_4__c = '';
            opp.Last_Opportunity_Comment_Part_1__c = createdDate + ' - ' + nameLog + ': ';
            newCommentStartSize = opp.Last_Opportunity_Comment_Part_1__c.length();
            if( currCommentSize + newCommentStartSize <= 255 )
                opp.Last_Opportunity_Comment_Part_1__c += oc.Comment__c;
            else
            {
                newPartialComment = oc.Comment__c.substring(0, 255 - newCommentStartSize);
                newStartLocation = newPartialComment.length();
                opp.Last_Opportunity_Comment_Part_1__c += newPartialComment;
                remainderComment = oc.Comment__c.substring(newStartLocation);
                if( remainderComment.length() <= 255)
                    opp.Last_Opportunity_Comment_Part_2__c = remainderComment;
                else
                {
                    newPartialComment = remainderComment.substring(0, 255);
                    opp.Last_Opportunity_Comment_Part_2__c = newPartialComment;
                    remainderComment = remainderComment.substring(255);
                    if(remainderComment.length() <= 255)
                        opp.Last_Opportunity_Comment_Part_3__c = remainderComment;
                    else
                    {
                        newPartialComment = remainderComment.substring(0, 255);
                        opp.Last_Opportunity_Comment_Part_3__c = newPartialComment;
                        remainderComment = remainderComment.substring(255);
                        if(remainderComment.length() <= 255)
                            opp.Last_Opportunity_Comment_Part_4__c = remainderComment;
                        else
                            opp.Last_Opportunity_Comment_Part_4__c = remainderComment.substring(0, 252) + '...'; //Truncate the reaminder of the comment
                    }
                }
            }
        }
        
        opp.Last_Opportunity_Comment_Any_Part_1__c = '';  //Init fields to make sure they are blank from last usage
        opp.Last_Opportunity_Comment_Any_Part_2__c = '';
        opp.Last_Opportunity_Comment_Any_Part_3__c = '';
        opp.Last_Opportunity_Comment_Any_Part_4__c = '';
        opp.Last_Opportunity_Comment_Any_Part_1__c = createdDate + ' - ' + nameLog + ': ';
        newCommentStartSize = opp.Last_Opportunity_Comment_Any_Part_1__c.length();
        if( currCommentSize + newCommentStartSize <= 255 )
            opp.Last_Opportunity_Comment_Any_Part_1__c += oc.Comment__c;
        else
        {
            newPartialComment = oc.Comment__c.substring(0, 255 - newCommentStartSize);
            newStartLocation = newPartialComment.length();
            opp.Last_Opportunity_Comment_Any_Part_1__c += newPartialComment;
            remainderComment = oc.Comment__c.substring(newStartLocation);
            if( remainderComment.length() <= 255)
                opp.Last_Opportunity_Comment_Any_Part_2__c = remainderComment;
            else
            {
                newPartialComment = remainderComment.substring(0, 255);
                opp.Last_Opportunity_Comment_Any_Part_2__c = newPartialComment;
                remainderComment = remainderComment.substring(255);
                if(remainderComment.length() <= 255)
                    opp.Last_Opportunity_Comment_Any_Part_3__c = remainderComment;
                else
                {
                    newPartialComment = remainderComment.substring(0, 255);
                    opp.Last_Opportunity_Comment_Any_Part_3__c = newPartialComment;
                    remainderComment = remainderComment.substring(255);
                    if(remainderComment.length() <= 255)
                        opp.Last_Opportunity_Comment_Any_Part_4__c = remainderComment;
                    else
                        opp.Last_Opportunity_Comment_Any_Part_4__c = remainderComment.substring(0, 252) + '...'; //Truncate the reaminder of the comment
                }
            }
        }
    }
    
    // To Update Currency of VP and position to follow currency of parent Opportunity
    private void UpdateCurrenyofPVfamily(map<Id, Opportunity__c> mapoffilteredOppWithChangedCurrency) {
        list<Opp_VP__c> listofVPsToUpdate = new list<Opp_VP__c>();
        list<Opp_VP_Position__c> listofPositionsToUpdate = new list<Opp_VP_Position__c>();
        for(Opp_VP__c OppVP : [SELECT CurrencyIsoCode,Fee_Total__c, Opportunity__c, (SELECT CurrencyIsoCode,Report_Fee__c, Opportunity_VP__r.Opportunity__c From Opp_VP_Positions__r ) FROM Opp_VP__c WHERE Opportunity__c IN: mapoffilteredOppWithChangedCurrency.keySet()])
        {
            if(mapoffilteredOppWithChangedCurrency.containsKey(OppVP.Opportunity__c)){
                OppVP.CurrencyIsoCode = mapoffilteredOppWithChangedCurrency.get(OppVP.Opportunity__c).CurrencyIsoCode; 
                OppVP.Fee_Total__c = (OppVP.Fee_Total__c != null)? OppVP.Fee_Total__c*1.00: null;
            }    
            for(Opp_VP_Position__c position : OppVP.Opp_VP_Positions__r)
            {
                if(mapoffilteredOppWithChangedCurrency.containsKey(position.Opportunity_VP__r.Opportunity__c)){
                    position.CurrencyIsoCode = mapoffilteredOppWithChangedCurrency.get(position.Opportunity_VP__r.Opportunity__c).CurrencyIsoCode;
                    position.Report_Fee__c = (position.Report_Fee__c!= null)? position.Report_Fee__c*1.00: null;
                }
            }
            listofVPsToUpdate.add(OppVP);
            listofPositionsToUpdate.addAll(OppVP.Opp_VP_Positions__r);
        }
        
        if(listofVPsToUpdate != null && listofVPsToUpdate.size() > 0)
            update listofVPsToUpdate;
        if(listofPositionsToUpdate != null && listofPositionsToUpdate.size() > 0)
            update listofPositionsToUpdate;
    }
    
    // To Update CF Expense Request records of parent Opportunity
    public void updateCFExpenseRequest(Map<Id, Opportunity__c> newOpptyMap, Map<Id, Opportunity__c> oldOpptyMap)
    {
        //Set stores All modified Internal Opportunity record Ids
        Set<Id> OpportunityIds=new Set<Id>();
        List<Event_Expense__c> evtExpUpdateList = new List<Event_Expense__c>();
        for(Opportunity__c Oppty : newOpptyMap.values()){
            if(Oppty.recordTypeId == recHLInternalOpp && ((newOpptyMap.get(Oppty.Id).Name != oldOpptyMap.get(Oppty.Id).Name) || (newOpptyMap.get(Oppty.Id).Event_Type__c != oldOpptyMap.get(Oppty.Id).Event_Type__c) || (newOpptyMap.get(Oppty.Id).Event_Format__c != oldOpptyMap.get(Oppty.Id).Event_Format__c) || (newOpptyMap.get(Oppty.Id).City__c != oldOpptyMap.get(Oppty.Id).City__c) || (newOpptyMap.get(Oppty.Id).Event_Location__c != oldOpptyMap.get(Oppty.Id).Event_Location__c))){
                OpportunityIds.add(Oppty.Id);
            }
        }
        
        if(OpportunityIds.size() > 0){
            List<Event_Expense__c> eventExpense = [SELECT id, LOB__c, Event_Type_Format__c, Event_Format__c, Event_Name__c, City__c, Event_Location__c, Event__c, Event__r.Event_Type__c,
                                                   Event__r.Event_Format__c, Event__r.Name, Event__r.City__c, Event__r.Event_Location__c FROM Event_Expense__c WHERE Event__c IN :OpportunityIds AND Status__c <> 'Deleted'];
            for(Event_Expense__c evtExp : eventExpense){
                evtExp.Event_Type_Format__c = evtExp.Event__r.Event_Type__c;
                evtExp.Event_Format__c = evtExp.Event__r.Event_Format__c;                 
                evtExp.Event_Name__c = evtExp.Event__r.Name;
                evtExp.City__c = evtExp.Event__r.City__c;
                evtExp.Event_Location__c = evtExp.Event__r.Event_Location__c;                                              
                evtExpUpdateList.add(evtExp); 
            }
            
            if(evtExpUpdateList.size() > 0){
                Database.SaveResult[] saveResults =   Database.update(evtExpUpdateList, true);
            }        
        }
    }
    
    //Update related Opportunity VAT Treatment records when 'Legal Entity' changes
    public static void updateOppVATTreatment(Set<Id> opportunityIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Update_VAT_Treatments)){
            return;
        }
        
        if(opportunityIdSet.size() > 0){
            List<Opportunity_VAT_Treatment__c> oppVATTreatmentList = [SELECT Id, Treatment__c, Opportunity__c, Opportunity__r.Legal_Entity__c, Opportunity__r.Legal_Entity__r.ERP_Entity_Code__c FROM Opportunity_VAT_Treatment__c WHERE Opportunity__c IN: OpportunityIdSet];
            if(oppVATTreatmentList.size() > 0){
                HL_OpportunityVATTreatmentHandler.updateTaxClassificationCode(oppVATTreatmentList, null, true);
            }
        }
    }
    
     
    public static void updateOpportunityDuetoCurrencyChange(){
        Set<Id> opportunityIdSet = new Set<Id>();
        Map<Id,Legal_Entity__c> legalEntityMap = New Map<Id,Legal_Entity__c>();
        Map<Id,Opportunity__c> OldOpportunityMap = (Map<Id,Opportunity__c>)Trigger.oldMap;
        integer i=0;
        for(Opportunity__c opp : (List<Opportunity__c>)trigger.new){
            if(opp.CurrencyIsoCode!=OldOpportunityMap.get(opp.Id).CurrencyIsoCode){
                system.debug('==integer=='+opp);
                //Assign a new opportunity number suffix
                //if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Assign_Number_Suffix)){
                    if(OldOpportunityMap.get(opp.Id).CurrencyIsoCode != null){
                        opportunityIdSet.add(opp.Id);
                        String oldChar = opp.Opportunity_Number_Suffix__c;
                        system.debug('==oldChar=='+oldChar);
                        if(oldChar == null || oldChar.trim() == ''){
                            opp.Opportunity_Number_Suffix__c = 'A';
                        }
                        else{
                            Integer charCode = oldChar.charAt(0);
                            system.debug('==charCode=='+charCode);
                            List<Integer> chars = new List<Integer>{charCode+1};
                                opp.Opportunity_Number_Suffix__c = String.fromCharArray(chars);
                           system.debug('==charCode=='+String.fromCharArray(chars));   
                        }
                    }
                    
                }
            //}
        }
    }
    //When the 'Legal Entity' of an opportunity changes, assign a new opportunity suffix number and update Legal Entity fields
    public static void updateOpportunityDuetoLegalEntityChange(){
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<Id> legalEntityIdSet = new Set<Id>();
        Map<Id,Legal_Entity__c> legalEntityMap = New Map<Id,Legal_Entity__c>();
        Map<Id,Opportunity__c> OldOpportunityMap = (Map<Id,Opportunity__c>)Trigger.oldMap;
        
        //Retrieve new Legal Entity information
        for(Opportunity__c opp : (List<Opportunity__c>)trigger.new){
            if(opp.Legal_Entity__c != OldOpportunityMap.get(opp.Id).Legal_Entity__c && opp.Legal_Entity__c != null)
                legalEntityIdSet.add(opp.Legal_Entity__c );
        }
        
        /*        
        List<Legal_Entity__c> legalEntityList = [SELECT Id, Name, ERP_Business_Unit__c, ERP_Business_Unit_Id__c, ERP_Entity_Code__c, ERP_Legislation_Code__c, ERP_VAT_Legal_Entity__c,
                                                 ERP_Legal_Entity_Id__c , ERP_Opportunity_Type_Template_number__c, ERP_Event_Type_Template_Number__c, ERP_Ledger_Name__c
                                                 FROM Legal_Entity__c
                                                 WHERE Id IN :legalEntityIdSet];
        */
        List<Legal_Entity__c> legalEntityList = HL_LegalEntity.getLegalEntitiesByIdSet(legalEntityIdSet);
                                                 
        for(Legal_Entity__c le : legalEntityList){
            legalEntityMap.put(le.Id, le);
        }        
        
        for(Opportunity__c opp : (List<Opportunity__c>)trigger.new){
            
            if(opp.Legal_Entity__c != OldOpportunityMap.get(opp.Id).Legal_Entity__c){
                //Assign a new opportunity number suffix
                if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Assign_Number_Suffix)){
                    if(OldOpportunityMap.get(opp.Id).Legal_Entity__c != null){
                        opportunityIdSet.add(opp.Id);
                        String oldChar = opp.Opportunity_Number_Suffix__c;
                        if(oldChar == null || oldChar.trim() == ''){
                            opp.Opportunity_Number_Suffix__c = 'A';
                        }
                        else{
                            Integer charCode = oldChar.charAt(0);
                            List<Integer> chars = new List<Integer>{charCode+1};
                                opp.Opportunity_Number_Suffix__c = String.fromCharArray(chars);
                        }
                    }
                    
                }
                
                //Update opportunity with new Legal Entity information
                Legal_Entity__c le = legalEntityMap.get(opp.Legal_Entity__c);
                if(le!= null){
                    opp.HL_Entity__c = le.Name;
                    opp.ERP_Template__c = opp.recordTypeId == recHLInternalOpp ? le.ERP_Event_Type_Template_Number__c : le.ERP_Opportunity_Type_Template_number__c;
                    opp.ERP_Legal_Entity_Id__c =  le.ERP_Legal_Entity_Id__c;
                    opp.ERP_Business_Unit__c =  le.ERP_Business_Unit__c;
                    opp.ERP_Business_Unit_Id__c =  le.ERP_Business_Unit_Id__c;
                    opp.ERP_Entity_Code__c = le.ERP_Entity_Code__c;
                    opp.ERP_Legislation_Code__c = le.ERP_Legislation_Code__c;
                    opp.ERP_VAT_Treatment_Entity__c = le.ERP_VAT_Legal_Entity__c;
                }
            }
        }
    }
    
    //Set Contract End Dates for related opportunities whose Legal Entity changed   
    public static void setContractEndDate(Set<Id> opportunityIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Clone_Contracts)){
            return;
        }
        
        List<Contract__c> contractList = Database.query('SELECT Id, End_Date__c FROM Contract__c WHERE Opportunity__c IN :opportunityIdSet AND End_Date__c = NULL');
        if(contractList.size() > 0){
            for(Contract__c contract :contractList){
                contract.End_Date__c = System.today();
            }
            Database.SaveResult[] saveResults =   Database.update(contractList, true);
        }
    }
    
    //Clone 'Engagement' type Contracts for related Opportunities whose Legal Entity changed
    public static void cloneOpportunityContracts(Set<Id> opportunityIdSet){
        if(!HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Clone_Contracts)){
            return;
        }
        
        Map<Id,Opportunity__c> updatedOpportunitySuffixMap = New Map<Id,Opportunity__c>();        
        String queryFields = '';
        List<Schema.FieldSetMember> fieldSetList = SObjectType.Contract__c.FieldSets.Clone_Fields.getFields();
        List<String> stringList = new List<String>();
        Map<String, Contract__c> uniqueBillToContracts =  New Map<String, Contract__c>();
        
        for(Schema.FieldSetMember fieldSetMember : fieldSetList){
            stringList.add(String.valueOf(fieldSetMember.getSObjectField()));
        }
        queryFields = String.join(stringList,',');
        
        List<Opportunity__c> opportunityList = [SELECT Id, Opportunity_Number_Suffix__c, Legal_Entity__c, ERP_HL_Entity__c,
                                                ERP_Business_Unit_Id__c, ERP_Business_Unit__c, ERP_Entity_Code__c
                                                FROM Opportunity__c 
                                                WHERE Id IN:opportunityIdSet];
        for(Opportunity__c opp : opportunityList){
            updatedOpportunitySuffixMap.put(opp.Id, opp);
        }
        
        List<Contract__c> contractCloneList = Database.query('SELECT ' + queryFields + ' FROM Contract__c WHERE Opportunity__c IN : opportunityIdSet AND ERP_Contract_Type__c = \'Engagement\'');
        List<Contract__c> contractInsertList = new List<Contract__c>();
        String contractKey = '';
        
        //Identity unique contracts based on 'Bill TOs'
        for(Contract__c contract :contractCloneList){
            contractKey = contract.Opportunity__c + '-' + contract.Bill_To__c;
            if(uniqueBillToContracts.get(contractKey) == null){
                uniqueBillToContracts.put(contractKey, contract);
            }
        }
        
        for(Contract__c contract : uniqueBillToContracts.values()){
            Contract__c clonedContract = new Contract__c();
            clonedContract = contract.clone(false, true, false, false);
            Opportunity__c conOpportunity = updatedOpportunitySuffixMap.get(contract.Opportunity__c);
            if(conOpportunity != null){
                clonedContract.Contract_Number_Suffix__c = conOpportunity.Opportunity_Number_Suffix__c;
                if(conOpportunity.Legal_Entity__c != null){
                    clonedContract.ERP_Legal_Entity__c = conOpportunity.ERP_HL_Entity__c;
                    clonedContract.ERP_Legal_Entity_Lookup__c = conOpportunity.Legal_Entity__c;
                    clonedContract.ERP_Business_Unit_Id__c = conOpportunity.ERP_Business_Unit_Id__c;
                    clonedContract.ERP_Business_Unit__c = conOpportunity.ERP_Business_Unit__c;
                    clonedContract.HL_Entity__c = conOpportunity.ERP_Entity_Code__c; 
                }
                contractInsertList.add(clonedContract);
            }
            system.debug('contractInsertList: ' + contractInsertList);
        }
        
        if(contractInsertList.size() > 0){
            Database.SaveResult[] saveResults = Database.insert(contractInsertList, true);
            ErrorHandlingUtility.handleDatabaseSaveResults(saveResults,'HL_OpportunityHandler');
        }
    }        
    
    //Set ERP Flags needed to sync records to Oracle
    public static void setERPUpdateFlags(List<Opportunity__c> oldOpportunityList, Map<Id, Opportunity__c> newOpportunityMap){
        for(Opportunity__c opp : oldOpportunityList){
            Opportunity__c newOpp = newOpportunityMap.get(opp.Id);
            if(newOpp != null){
                if(HL_TriggerSetting.IsEnabled(HL_TriggerSetting.TriggerType.Opportunity_Set_DFF_Flags)){
                    //Set Update DFF Flag
                    if(opp.Primary_Office__c != newOpp.Primary_Office__c
                       || opp.Industry_Group__c != newOpp.Industry_Group__c
                       || opp.Sector__c != newOpp.Sector__c
                       || opp.Line_of_Business__c != newOpp.Line_of_Business__c
                       || opp.Job_Type__c != newOpp.Job_Type__c
                       || opp.Client_Ownership__c != newOpp.Client_Ownership__c
                       || opp.Product_Type__c != newOpp.Product_Type__c
                       || opp.CurrencyIsoCode!=newOpp.CurrencyIsoCode
                       || opp.Legal_Entity__c !=newOpp.Legal_Entity__c){
                           newOpp.ERP_Update_DFF__c = true;
                       }
                    //Set Update Opportunity Name Flag
                    if(opp.Name != newOpp.Name)
                        newOpp.ERP_Update_Opportunity__c = true;
                    //Set Update Status Flag
                    if(opp.Stage__c != newOpp.Stage__c)
                        newOpp.ERP_Update_Status__c = true;
                }
            }
        }
    }
    
    //Set Legal Entity Fields for new records
    public static void setLegalEntityFields (List<Opportunity__c> newOpportunityList){
        Set<Id> legalEntityIdSet = new Set<Id>();
        Map<Id,Legal_Entity__c> legalEntityMap = New Map<Id,Legal_Entity__c>();
        
        //Retrieve new Legal Entity Id
        for(Opportunity__c opp : newOpportunityList){
            if(opp.Legal_Entity__c != null)
                legalEntityIdSet.add(opp.Legal_Entity__c );
        }
        
        /*
        List<Legal_Entity__c> legalEntityList = [SELECT Id, Name, ERP_Business_Unit__c, ERP_Business_Unit_Id__c, ERP_Entity_Code__c, ERP_Legislation_Code__c, ERP_VAT_Legal_Entity__c,
                                                 ERP_Legal_Entity_Id__c , ERP_Opportunity_Type_Template_number__c, ERP_Event_Type_Template_Number__c, ERP_Ledger_Name__c
                                                 FROM Legal_Entity__c
                                                 WHERE Id IN :legalEntityIdSet];
        */
        List<Legal_Entity__c> legalEntityList = HL_LegalEntity.getLegalEntitiesByIdSet(legalEntityIdSet);
                                                 
        for(Legal_Entity__c le : legalEntityList){
            legalEntityMap.put(le.Id, le);
        }        
        
        for(Opportunity__c opp : newOpportunityList){
            if(opp.Legal_Entity__c != null){
                Legal_Entity__c le = legalEntityMap.get(opp.Legal_Entity__c);
                if(le != null){
                    opp.HL_Entity__c = le.Name;
                    //opp.ERP_Template__c =  le.ERP_Opportunity_Type_Template_number__c;
                    opp.ERP_Template__c = opp.recordTypeId == recHLInternalOpp ? le.ERP_Event_Type_Template_Number__c : le.ERP_Opportunity_Type_Template_number__c;
                    opp.ERP_Legal_Entity_Id__c =  le.ERP_Legal_Entity_Id__c;
                    opp.ERP_Business_Unit__c =  le.ERP_Business_Unit__c;
                    opp.ERP_Business_Unit_Id__c =  le.ERP_Business_Unit_Id__c;
                    opp.ERP_Entity_Code__c = le.ERP_Entity_Code__c;
                    opp.ERP_Legislation_Code__c = le.ERP_Legislation_Code__c;
                    opp.ERP_VAT_Treatment_Entity__c = le.ERP_VAT_Legal_Entity__c; 
                }
            }
        }
    }
    
    //Clear out ERP Update flags if ERP Status is set to 'Success'
    public static void clearERPUpdateFlags(List<Opportunity__c> oldOpportunityList, Map<Id, Opportunity__c> newOpportunityMap){
        for(Opportunity__c opp : oldOpportunityList){
            Opportunity__c newOpp = newOpportunityMap.get(opp.Id);
            if(newOpp != null){
                if(newOpp.ERP_Last_Integration_Response_Date__c != null
                   && newOpp.ERP_Last_Integration_Response_Date__c != opp.ERP_Last_Integration_Response_Date__c){
                       if(newOpp.ERP_Last_Integration_Status__c != null 
                          && newOpp.ERP_Last_Integration_Status__c.toUpperCase() == 'SUCCESS'){
                              newOpp.ERP_Update_Attributes__c = false;
                              newOpp.ERP_Update_DFF__c = false;
                              newOpp.ERP_Update_Initiator__c = false;
                              newOpp.ERP_Update_Manager__c = false;
                              newOpp.ERP_Update_New_Task__c = false;
                              newOpp.ERP_Update_Opportunity__c = false;
                              newOpp.ERP_Update_Status__c = false;
                          }
                   }
            }
        }
    }
    //Added logic to ensure required fields are entered when CF Opportunity(having Non US Legal Entity) 'stage' value is changed to Verbally Engaged
    //10/04/2020 - Updated logic to Check When 'LOB=CF' and 'legal Entity!= HL Capital Inc.' and if 'stage' changed from other to 'Verbally Engaged' show 'conflict check' error.
    public static void validateRequiredFieldsOnStageChange(){
        // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
        //Map<Id,Legal_Entity__c> hlLegalEntityMap = new Map<Id,Legal_Entity__c>([SELECT Id,Name FROM Legal_Entity__c WHERE Name='HL Capital, Inc.' LIMIT 1]);

        for(Opportunity__c opp : (List<Opportunity__c>) trigger.new){
            Boolean isError = false;
            if(opp.Line_of_Business__c == 'FR' && opp.Primary_Country__c == 'EMEA Required' && opp.EU_Initiatives__c == null){
                opp.addError('Marketing Information - EMEA Initiative is required for Non-US Offices.');
            }
            if(opp.Stage__c == 'Verbally Engaged' && opp.Line_of_Business__c == 'CF' && !hlLegalEntityMap.containsKey(opp.Legal_Entity__c)){
                String errorMessage = '  The following fields are required before changing Opportunity Stage to Verbally Engaged. <br/>';
                if(String.isBlank(opp.Success_Probability__c)){
                    isError = true;
                    errorMessage = errorMessage + 'Opportunity Detail - Success Probability <br/>';
                }
                if(opp.Estimated_Transaction_Size_MM__c == null){
                    isError = true;
                    errorMessage = errorMessage + 'Estimated Financials - Est. Transaction Size / Market Cap (MM) <br/>';
                }
                if(opp.Retainer__c == null){
                    isError = true;
                    errorMessage = errorMessage + 'Estimated Fees - Retainer. Input zero if there is no retainer fee. <br/>';
                }
                /*if(opp.Tail_Expires__c == null){
                    isError = true;
                    errorMessage = errorMessage + 'Estimated Fees - Tail Expires <br/>';
                }*/
                if(opp.ProgressMonthly_Fee__c == null){
                    isError = true;
                    errorMessage = errorMessage + 'Estimated Fees - Progress/Monthly Fee <br/>';
                }
                if(opp.Contingent_Fee__c == null){
                    isError = true;
                    errorMessage = errorMessage + 'Estimated Fees - Contingent Fee <br/>';
                }
                if(opp.Estimated_Close_Date__c == null){
                    isError = true;
                    errorMessage = errorMessage + 'Administration - Estimated Close Date <br/>';
                }
                if((Trigger.isInsert 
                    || (Trigger.isUpdate
                        && Trigger.oldMap.get(opp.Id).get('Stage__c') != opp.Stage__c))  
                   && !opp.Conflicts_Outcome__c){
                       isError = true;
                       errorMessage = errorMessage + 'A Conflicts Check was completed more than 30 days ago. A new Conflicts Check must be completed. <br/>';
                   }
                /*      if(!opp.ConflictsOutcomeAllowEdit__c){
isError = true;
errorMessage = errorMessage + 'A Conflicts Check was completed more than 30 days ago. A new Conflicts Check must be completed. <br/>';
} */
                if(!opp.NBC_Approved__c){
                    isError = true;
                    errorMessage = errorMessage + 'Approved NBC form - Please complete and submit this form via the NBC button.  <br/>';
                }
                //if(String.isBlank(opp.Fairness_Opinion_Component__c)){
                //errorMessage = errorMessage + 'Administration - Fairness Opinion Component';
                //}
                if(isError){
                    opp.addError(errorMessage,false);
                }
            }
        }
    }

    
    //Added by Shruthi on 9th Dec 2021
    public void OnBeforeUpsert(List<Opportunity__c> OpportunityList)
    {
    	Boolean onOIT;
        for(Opportunity__c opp:OpportunityList)
        {
        	if(onOIT == null)
            onOIT=(HL_Utility.IsSysAdmin() ||  (HL_Utility.IsCAO() && HL_SecurityUtility.IsCAOCF()) || HL_OIT.IsActiveOnTeam(Opp.Id,UserInfo.getUserId()) || HL_SecurityUtility.IsNBCViewGroup());  
    		system.debug('onOIT='+onOIT);
            opp.onOIT__c=onOIT;
        }
    }
    //Added by Shruthi on 9th Dec 2021
}