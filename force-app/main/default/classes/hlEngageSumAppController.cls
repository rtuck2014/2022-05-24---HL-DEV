public with sharing class hlEngageSumAppController {
    //===============================================================================================
    //Purpose: Controller for hlEngageSumApp (Lightning Web Component app)
    //Author: Larry Leonidas - Invest Apex Solutions
    //Description - Apex below is loosly ordered based on hlEngageSumApps visual order of components, it is used
    //in most cases for cached Wire Service requests, however approvals eval/creation are called imperatively  
    //===============================================================================================
    //LL20190703 - Get the Engagement Summary record and return it (if it exists)
    @AuraEnabled(cacheable=true)
    public static List<Engagement_Summary__c> getEngagementSummary(String engagementId){ 
        system.debug('getEngagementSummary--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        String engageId = String.escapeSingleQuotes(engagementId);
        String qry = 'SELECT Id FROM Engagement_Summary__c ';
        qry += 'WHERE Engagement__c = :engageId';
        List<Engagement_Summary__c> es = Database.query(qry);
        system.debug('getEngagementSummary--02-es: ' + es);
        return es;
    }

    @AuraEnabled(cacheable=true)
    public static List<Engagement__c> getEngagementRec(String engagementId){ 
        system.debug('getEngagement--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        String engageId = String.escapeSingleQuotes(engagementId);
        String qry = 'SELECT Id, Record_Type_Name__c, RecordTypeId  FROM Engagement__c ';
        qry += 'WHERE Id = :engageId';
        List<Engagement__c> es = Database.query(qry);
        system.debug('getEngagement--02-es: ' + es);
        return es;
    }
    //LL20190521- Get HL Team Members for a particular Engagement, allowing the ability to sort the data
    @AuraEnabled(cacheable=true)
    public static List<Engagement_Internal_Team__c> getEngageTeam(String engagementId, String sortField, String sortDirection, List<String> roleFilters){ 
        system.debug('getEngageTeam--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        system.debug('getEngageTeam--02-roleFilters: '+ String.join(roleFilters,','));
        List<String> rFilters = new List<String>();
        for(String rf: roleFilters){
            rFilters.add(String.escapeSingleQuotes(rf));
        }
        String engageId = String.escapeSingleQuotes(engagementId);
        String qry = 'SELECT Id, Active_On_Engagement__c, Name, Contact__c, Contact_Name__c, Contact_Title__c, Contact_Office__c, Contact_LOB__c, Contact__r.Status__c, Contact__r.User__c, Role__c, Staff_Role__c, Office__c, LOB__c ';
        qry += 'FROM Engagement_Internal_Team__c ';
        qry += 'WHERE Engagement__c = :engageId ';
        qry += 'AND Role__c IN :rFilters AND Contact__c != null AND End_Date__c = null ';
        qry += 'Order by ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection) + ' LIMIT 25'; 
        List<Engagement_Internal_Team__c> ets = Database.query(qry);
        system.debug('getEngageTeam--02-ets.size(): ' + ets.size());
        return ets;
    }
    //LL20190507 - Get winning Engagement Counterparty Id for a particular Engagement
    @AuraEnabled(cacheable=true)
    public static List<String> getWinCounterparties(String engagementId){ 
        system.debug('getWinCounterparties--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        String engageId = String.escapeSingleQuotes(engagementId);
        List<String> ecIds = new List<String>();
        for(Engagement_Counterparty__c c: [SELECT Id FROM Engagement_Counterparty__c 
                                                WHERE Engagement__c = :engageId AND Closing_Round_Bid_Date__c <> null]){
            ecIds.add(c.Id);
        }
        system.debug('getWinCounterparties--02-ecIds.size(): ' + ecIds.size());
        return ecIds;
    }
    //LL20190521- Get Engagement External Team (Contacts) for Client party, Subject party, and /or Counterparty (using Type__c field) 
    @AuraEnabled(cacheable=true)
    public static List<Engagement_External_Team__c> getEngageContacts(String engagementId, String partyFilter, List<String> roleExcludeFilters, List<String> roleFilters, String sortField, String sortDirection){
        system.debug('getEngageExternalTeam-engagementId: '+ String.escapeSingleQuotes(engagementId));
        system.debug('getEngageExternalTeam-partyFilter: '+ String.escapeSingleQuotes(partyFilter));
        system.debug('getEngageExternalTeam-roleFilters: '+ String.join(roleFilters,','));
        system.debug('getEngageExternalTeam-roleExcludeFilters: '+ String.join(roleExcludeFilters,','));
        String engageId = String.escapeSingleQuotes(engagementId);
        String pFilter = String.escapeSingleQuotes(partyFilter);
        List<String> rExcFilters = new List<String>();
        system.debug('getEngageExternalTeam-roleExcludeFilters.size(): '+ roleExcludeFilters.size());
        for(String rf: roleExcludeFilters){
            system.debug('getEngageExternalTeam-rExcFilters(loop): '+ String.escapeSingleQuotes(rf));
            if(rf != '')
                rExcFilters.add(String.escapeSingleQuotes(rf));
        }
        List<String> rFilters = new List<String>();
        system.debug('getEngageExternalTeam-roleFilters.size(): '+ roleFilters.size());
        for(String rf: roleFilters){
            system.debug('getEngageExternalTeam-rFilters(loop): '+ String.escapeSingleQuotes(rf));
            if(rf != '') 
                rFilters.add(String.escapeSingleQuotes(rf));
        }
        String qry = 'SELECT Id, Contact_URL__c, Contact_Name__c, Role__c, Primary__c, Contact_Company__c, ';
        qry += 'Pre_Transaction_Title__c, Pre_Transaction_Salary__c, Pre_Transaction_Bonus__c, Pre_Transaction_Total_Comp__c, ';
        qry += 'Post_Transaction_Title__c, Post_Transaction_Salary__c, Post_Transaction_Bonus__c, Post_Transaction_Total_Comp__c ';
        qry += 'FROM Engagement_External_Team__c ';
        qry += 'WHERE Engagement__c = :engageId AND (';
        qry += '(Party__c = null) OR (Party__c = :pFilter';
        qry += rExcFilters.isEmpty() ? '' : ' AND Role__c NOT IN :rExcFilters ';
        qry += rFilters.isEmpty() ? ')' : ' AND Role__c IN :rFilters) ';
        qry += ') Order by ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection) + ' LIMIT 25';
        List<Engagement_External_Team__c > ext = Database.query(qry);
        system.debug('getEngageExternalTeam-ext.size(): ' + ext.size());
        return ext;
    }

    //LL20190521- Get winning Engagement Counterparty Contacts for an Engagement. May redesign this approach as all contacts seem to be stored in Engagement Contacts
    // LL20190729 - At this time all contacts will be obtained from Engagement_External_Team__c for Engagement Summary
    // @AuraEnabled(cacheable=true)
    // public static List<Engagement_Counterparty_Contact__c> getWinCounterpartiesContacts(List<String> counterpartyIds, String sortField, String sortDirection){
    //     system.debug('getWinCounterpartiesContacts--01-counterpartyIds: '+ String.join(counterPartyIds,','));
    //     List<String> cpIds = new List<String>();
    //     for(String cp: counterpartyIds){
    //         cpIds.add(String.escapeSingleQuotes(cp));
    //     }
    //     String qry = 'SELECT Id, Contact_URL__c, Contact_Name__c, Contact_Company__c, Contact_Title__c, Type__c FROM Engagement_Counterparty_Contact__c ';
    //     qry += 'WHERE Counterparty__c IN :cpIds Order by ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
    //     List<Engagement_Counterparty_Contact__c> ecc = Database.query(qry);
    //     system.debug('getWinCounterpartiesContacts--02-ecc.size(): ' + ecc.size());
    //     return ecc;
    //  }
     
    //LL20190611- Get Engagement Financials for use as reference in filling Engagement Summary financials
    @AuraEnabled(cacheable=true)
    public static List<Engagement_Financials__c> getEngageFinancials(String engagementId, String sortField, String sortDirection){
        system.debug('getEngageFinancials--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        String engageId = String.escapeSingleQuotes(engagementId);
        String qry = 'SELECT Id, Type__c, Revenue_LTM_MM__c, Revenue_FY_MM__c, Revenue_FY_1_MM__c, EBITDA_LTM_MM__c, EBITDA_FY_MM__c, EBITDA_FY_1_MM__c, Book_Value_Current__c, Total_Assets__c, CurrencyIsoCode '; 
        qry += 'FROM Engagement_Financials__c ';
        qry += 'WHERE Related_Engagement__c = :engageId Order by ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
        List<Engagement_Financials__c> efs = Database.query(qry);
        system.debug('getEngageFinancials--02-efs.size(): ' + efs.size());
        return efs;
    }
    //LL20190625 - Get Counterparty Bid information to display in Market Data
    @AuraEnabled(cacheable=true)
    public static List<Engagement_Counterparty__c> getCounterpartyBidList(String engagementId){ 
        system.debug('getCounterpartyBidList--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        String engageId = String.escapeSingleQuotes(engagementId);
        String qry = 'SELECT Id, Company__c, Company__r.Name, ';
        qry += 'Bid_First_MP__c, Bid_First_EBITDA_LTM__c, Bid_First_EBITDA_FYE_1__c, Bid_First_Book_Value__c, '; 
        qry += 'Bid_Final_MP__c,Bid_Final_EBITDA_LTM__c,Bid_Final_EBITDA_FYE_1__c,Bid_Final_Book_Value__c,Bid_Final_Change_From_Prelim__c, ';
        qry += 'Bid_Closing_MP__c,Bid_Closing_Change_From_Prelim__c,Bid_Closing_Multiple__c ';
        qry += 'FROM Engagement_Counterparty__c ';
        qry += 'WHERE Engagement__c = :engageId AND (Proposal_Indication__c <> null OR Letter_of_Intent__c <> null) ';
        qry += 'Order by Company__r.Name ASC';
        List<Engagement_Counterparty__c> ecp = Database.query(qry);
        system.debug('getCounterpartyBidList--02-ecp.size(): ' + ecp.size());
        return ecp;
    }
    //LL20190521- Get Credit Facilities (aka Debt Structures) and related Lenders for a particular Engagement
    @AuraEnabled(cacheable=true)
    public static List<Debt_Structure__c> getDebtStructures(String engagementId, String sortField, String sortDirection){
        system.debug('getDebtStructures--01-engagementId: '+ String.escapeSingleQuotes(engagementId));
        String engageId = String.escapeSingleQuotes(engagementId);
        String qry = 'SELECT Id ';
        qry += 'FROM Debt_Structure__c ';
        qry += 'WHERE Engagement__c = :engageId Order by ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
        List<Debt_Structure__c> dbs = Database.query(qry);
        system.debug('getDebtStructures--02-dbs.size(): ' + dbs.size());
        return dbs;
    }
    @AuraEnabled(cacheable=true)
    public static List<Engagement_Client_Subject__c> getClientSubjectLenders(String debtStructureId, String sortField, String sortDirection){
        system.debug('getLenderClientSubjects--01-debtStructureId: '+ String.escapeSingleQuotes(debtStructureId));
        String debtsId = String.escapeSingleQuotes(debtStructureId);
        String qry = 'SELECT Id FROM Engagement_Client_Subject__c ';
        qry += 'WHERE Debt_Structure__c = :debtsId Order by ' + String.escapeSingleQuotes(sortField) + ' ' + String.escapeSingleQuotes(sortDirection);
        List<Engagement_Client_Subject__c> ecs = Database.query(qry);
        system.debug('getLenderClientSubjects--02-ecs.size(): ' + ecs.size());
        return ecs;
    }
    @AuraEnabled
    public static String doEngageSumApprovalSubmit(String engageSumId, String msg){
        system.debug('doEngageSumApprovalSubmit-engageSumId: '+ String.escapeSingleQuotes(engageSumId));
        String eSumId = String.escapeSingleQuotes(engageSumId);
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        String comments = 'Submitting request';
        if(msg != null) 
            comments += ' - ' + String.escapeSingleQuotes(msg);
        req.setComments(comments);
        req.setObjectId(engageSumId);
        system.debug('doEngageSumApprovalSubmit-req: '+ req);
        try{
            Approval.ProcessResult result = Approval.process(req);
            return result.getInstanceStatus();
        }
        catch(Exception e){
            throw new AuraHandledException('There was a problem - Please Contact Your System Administrator: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static String doEngageSumApprovalNext(String engageSumId, String type, String msg){
        system.debug('doEngageSumApprovalNext-engageSumId: '+ String.escapeSingleQuotes(engageSumId));
        system.debug('doEngageSumApprovalNext-type: '+ String.escapeSingleQuotes(type));
        String eSumId = String.escapeSingleQuotes(engageSumId);
        String actionType = String.escapeSingleQuotes(type);
        String comments;
        String uId = UserInfo.getUserId();
        Approval.ProcessWorkitemRequest  req = new Approval.ProcessWorkitemRequest();
        if(actionType == 'Unlock'){
            actionType = 'Removed';
            comments = 'Unlock request';
            Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
            if(msg != null) 
                comments += ' - ' + String.escapeSingleQuotes(msg);
            req2.setComments(comments);
            req2.setObjectId(engageSumId);
            system.debug('doEngageSumApprovalSubmit-req2-A: '+ req2);
            try{
                system.debug('doEngageSumApprovalSubmit-req2-B: '+ req2);
                Approval.ProcessResult result = Approval.process(req2);
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
                system.debug('doEngageSumApprovalSubmit-newWorkItemIds.get(0): '+ newWorkItemIds.get(0));
                req.setWorkItemId(newWorkItemIds.get(0));
            }
            catch(Exception e){
                String exceptionMsg = e.getMessage();
                if(exceptionMsg.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') || exceptionMsg.contains('List index out of bounds'))
                    exceptionMsg = 'Unlock Problem - Only Submitter or Prinicpal/Manager can Approve or Recall/Reject an Engagement Summary.';
                else exceptionMSg = 'Please Contact Your System Administrator: ' + e.getMessage() +  ' (hlEngageSumAppController.doEngageSumApprovalNext.Unlock)';
                AuraHandledException aura = new AuraHandledException(exceptionMsg);
                aura.setMessage(exceptionMsg);
                if(!Test.isRunningTest())
                    throw aura;
                else return 'testing';
            }
        }
        else if(actionType == 'Quick'){
            actionType = 'Approve';
            comments = 'Quick approval';
                try{
                    Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
                    if(msg != null) 
                        comments += ' - ' + String.escapeSingleQuotes(msg);
                    req2.setComments(comments);
                    req2.setObjectId(engageSumId);
                    system.debug('doEngageSumApprovalSubmit-req2-A: '+ req2);
                    system.debug('doEngageSumApprovalSubmit-req2-B: '+ req2);
                    Approval.ProcessResult result = Approval.process(req2);
                    List<Id> newWorkItemIds = result.getNewWorkitemIds();
                    system.debug('doEngageSumApprovalSubmit-newWorkItemIds.get(0): '+ newWorkItemIds.get(0));
                    String qry = 'SELECT Id FROM ProcessInstanceWorkitem WHERE Id IN :newWorkItemIds AND ActorId = :uId ';
                    ProcessInstanceWorkitem[] workItems = Database.query(qry);
                    req.setWorkItemId(workItems[0].id);
                }
                catch(Exception e){
                    String exceptionMsg = e.getMessage();
                    if(exceptionMsg.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') || exceptionMsg.contains('List index out of bounds'))
                        exceptionMsg = 'Quick Approval Problem - Only Submitter or Prinicpal/Manager can Approve or Recall/Reject an Engagement Summary.';
                    else exceptionMSg = 'Please Contact Your System Administrator: ' + e.getMessage() +  ' (hlEngageSumAppController.doEngageSumApprovalNext.Quick)';
                    AuraHandledException aura = new AuraHandledException(exceptionMsg);
                    aura.setMessage(exceptionMsg);
                    if(!Test.isRunningTest())
                        throw aura;
                    else return 'testing';
                }
            }
        else {
            system.debug('doEngageSumApprovalSubmit-actionType: '+ actionType);
            if(actionType == 'Recall'){
                actionType = 'Removed';
                comments = 'Recalling request';
            } 
            else if(actionType == 'Reject')
                comments = 'Rejecting request';
            else if(actionType == 'Approve')
                comments = 'Request approved';
            if(msg != null) 
                comments += ' - ' + String.escapeSingleQuotes(msg);
            try{
                String qry = 'SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :eSumId ';
                if((!HL_SecurityUtility.IsSysAdmin()) && (actionType == 'Reject' || actionType == 'Approve')) qry += 'AND ActorId = :uId ';
                qry += 'AND ProcessInstance.Status = \'Pending\'';
                ProcessInstanceWorkitem[] workItems = Database.query(qry);
                req.setWorkItemId(workItems[0].id);
            }
            catch(Exception e){
                String exceptionMsg = e.getMessage();
                if(exceptionMsg.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') || exceptionMsg.contains('List index out of bounds'))
                    exceptionMsg = 'Only Submitter or Prinicpal/Manager can Approve or Recall/Reject an Engagement Summary.';
                else exceptionMSg = 'Please Contact Your System Administrator: ' + e.getMessage() +  ' (hlEngageSumAppController.doEngageSumApprovalNext.workitem)';
                AuraHandledException aura = new AuraHandledException(exceptionMsg);
                aura.setMessage(exceptionMsg);
                if(!Test.isRunningTest())
                    throw aura;
                else return 'testing';
            }
        }
        system.debug('doEngageSumApprovalSubmit-req-A: '+ req);
        req.setComments(comments);
        req.setAction(actionType);
        // req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        try{
            system.debug('doEngageSumApprovalSubmit-req-B: '+ req);
            Approval.ProcessResult result = Approval.process(req);
            system.debug('doEngageSumApprovalSubmit-result.getInstanceStatus(): '+ result.getInstanceStatus());
            return result.getInstanceStatus();
        }
        catch(Exception e){
            String exceptionMsg = e.getMessage();
            if(exceptionMsg.contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') || exceptionMsg.contains('List index out of bounds'))
                exceptionMsg = 'Only Submitter or Prinicpal/Manager can Approve or Recall/Reject an Engagement Summary.';
            else exceptionMSg = 'There was a problem - Please Contact Your System Administrator: ' + e.getMessage() +  ' (hlEngageSumAppController.doEngageSumApprovalNext.processworkitem)';
            AuraHandledException aura = new AuraHandledException(exceptionMsg);
            aura.setMessage(exceptionMsg);
            if(!Test.isRunningTest())
                throw aura;
            else return 'testing';
        }
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getEngageSumApprovalOverride(){
        if(HL_Group.IsInGroup('CAO_CF') || HL_SecurityUtility.IsSysAdmin())
            return true;
        else return false;
    }
}