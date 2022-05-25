public class HL_EngagementCounterpartyHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isBeforeInsertFlag = false;
    public static Boolean isBeforeUpdateFlag = false;

    public HL_EngagementCounterpartyHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }

    public void onAfterInsert(List<Engagement_Counterparty__c> ecList){
        Set<Id> acctSet = new Set<Id>();
        for(Engagement_Counterparty__c ecs : ecList) {
            acctSet.add(ecs.Company__c);
        }
        IndicateCounterparty(acctSet);
    }
    
    public void onAfterUpdate(List<Engagement_Counterparty__c> oldECList, Map<Id,Engagement_Counterparty__c> newECMap){
        Set<Id> acctSet = new Set<Id>();
        for (Engagement_Counterparty__c ecs : oldECList) {
             Engagement_Counterparty__c newECs = newECMAP.get(ecs.id);   
            if(ecs.Company__c <> newECs.Company__c){
                acctSet.add(ecs.Company__c);
                acctSet.add(newECs.Company__c);
            }
        }
        IndicateCounterparty(acctSet);
    }
    
    public void onAfterDelete(List<Engagement_Counterparty__c> ecList){
        Set<Id> acctSet = new Set<Id>();
        for(Engagement_Counterparty__c ecs : ecList) {
            acctSet.add(ecs.Company__c);
        }
        IndicateCounterparty(acctSet);
    }
    
    public void onAfterUndelete(List<Engagement_Counterparty__c> ecList){
        Set<Id> acctSet = new Set<Id>();
        for(Engagement_Counterparty__c ecs : ecList) {
            acctSet.add(ecs.Company__c);
        }
        IndicateCounterparty(acctSet);
    }

    public void InsertCounterpartyComments(List<Engagement_Counterparty__c> ecs){
         List<Engagement_Counterparty_Comment__c> CommentList = new List<Engagement_Counterparty_Comment__c>();
         for(Engagement_Counterparty__c ecp: ecs){
             
            //Check to see if the new comment has a value or not
            if(ecp.Engagement_Counterparty_Comment__c != null && ecp.Engagement_Counterparty_Comment__c != ''){
                //If a value is found, create a new Engagement_Comments Object
                Engagement_Counterparty_Comment__c ecpComment = new Engagement_Counterparty_Comment__c();
                ecpComment.Comment__c = ecp.Engagement_Counterparty_Comment__c;
                ecpComment.Comment_Type__c = 'Internal';
                ecpComment.Line_of_Business__c = 'CF';  //Engagement Counter Party is only CF at this time.
                ecpComment.Related_Engagement_Counterparty__c = ecp.Id;
                ecpComment.CurrencyIsoCode = ecp.CurrencyIsoCode;
                CommentList.add(ecpComment);
                
                //Remove the value for the new comments field so it is never saved to the object and will be blank the next time Pipeline Manager is displayed
                ecp.Engagement_Counterparty_Comment__c = null;
             }      
         }
         insert CommentList;
     }
    
    //Assign the Coverage Officer (if exists), Primary and Secondary Calling Responsibility to Manager/Associate/Analyst
    public void UpdateDefaultFields(List<Engagement_Counterparty__c> ecs){
        Set<Id> accounts = new Set<Id>();
        Set<Id> engagements = new Set<Id>();
        Map<Id, Id> ultimateParentMap = new Map<Id, Id>();
        Map<Id, Id> coverageMap = new Map<Id, Id>();
        Map<Id, Id> managerMap = new Map<Id, Id>();
        Map<Id, Id> associateMap = new Map<Id, Id>();
        for(Engagement_Counterparty__c ec : ecs){
            engagements.add(ec.Engagement__c);
            accounts.add(ec.Company__c);  
        }
        
        //Get the accounts
        for(Account a : [SELECT Primary_FS_Coverage_Officer__c, Ultimate_Parent__c FROM Account WHERE Id IN:accounts]){
            ultimateParentMap.put(a.Id, a.Ultimate_Parent__c);
            if(!String.isBlank(a.Primary_FS_Coverage_Officer__c))
                coverageMap.put(a.Id, a.Primary_FS_Coverage_Officer__c);
        }
        
        //Get the Coverage Officer - this is a standalone query that will grab the FS Officer
        /*for(Coverage_Team__c ct : [SELECT Company__c, Officer__c
                                     FROM Coverage_Team__c 
                                     WHERE (Company__c IN: ultimateParentMap.keySet() OR (Company__r.Ultimate_Parent__c <> null AND (Company__r.Ultimate_Parent__c IN: ultimateParentMap.values() OR Company__r.Ultimate_Parent__c IN: ultimateParentMap.keySet()))) 
                                     AND RecordType.DeveloperName = 'FS_Coverage_Team_Member'
                                     AND Officer__r.Status__c = 'Active'
                                     AND Coverage_level__c = 'Sponsor Officer'
                                     AND Coverage_Team_Status__c = 'Active'
                                     ORDER BY Tier__c ASC]){
                                       coverageMap.put(ct.Company__c, ct.Officer__c);
                                   }
        */
        
        //Get the Manager and Associate
        for(Engagement_Internal_Team__c eit : [SELECT Contact__c, Engagement__c, Role__c FROM Engagement_Internal_Team__c WHERE Engagement__c IN:engagements AND End_Date__c = null AND (Role__c = 'Manager' OR Role__c = 'Associate')]){
            if(eit.Role__c == 'Manager')
                managerMap.put(eit.Engagement__c, eit.Contact__c);
            else 
               associateMap.put(eit.Engagement__c, eit.Contact__c);
        }
        
        for(Engagement_Counterparty__c ec : ecs){
            ec.Coverage_Officer__c = coverageMap.get(ec.Company__c);
            ec.Primary_Calling_Responsibility__c = managerMap.get(ec.Engagement__c);
            if(String.isBlank(ec.Primary_Calling_Responsibility__c))
                ec.Primary_Calling_Responsibility__c = associateMap.get(ec.Engagement__c);
            else{
                ec.Secondary_HL_Contact__c = associateMap.get(ec.Engagement__c);
                if(ec.Primary_Calling_Responsibility__c == ec.Secondary_HL_Contact__c)
                    ec.Secondary_HL_Contact__c = null;
            }
        }
    }

    public List<Engagement_Counterparty__c> InsertConversionRelatedItems(List<Engagement_Counterparty__c> ecList){
        //Check if these are from opportunity conversion
        if(ecList.size() > 0 && !String.isBlank(ecList[0].Opportunity_Counterparty__c)){
            List<Engagement_Counterparty_Contact__c> ecContactsToInsert = new List<Engagement_Counterparty_Contact__c>();
            List<Engagement_Counterparty_Comment__c> ecCommentsToInsert = new List<Engagement_Counterparty_Comment__c>();
            //Create a Map of Opportunity Counterparty Id to Engagement Counterparty
            Map<Id, Engagement_Counterparty__c> ocMap = new Map<Id, Engagement_Counterparty__c>();
            for(Engagement_Counterparty__c ec : ecList){
                if(!String.isBlank(ec.Opportunity_Counterparty__c))
                    ocMap.put(ec.Opportunity_Counterparty__c, ec);
            }

            if(ocMap.size() > 0){
                //Get Opportunity Counterparty Contacts
                for(Opportunity_Counterparty_Contact__c occ : [SELECT Contact__c, Contact_Type__c, Counterparty__c FROM Opportunity_Counterparty_Contact__c WHERE Counterparty__c IN:ocMap.keySet()])
                    ecContactsToInsert.add(new Engagement_Counterparty_Contact__c(Contact__c = occ.Contact__c, Type__c = occ.Contact_Type__c, Counterparty__c = ocMap.get(occ.Counterparty__c).Id));
                for(Opportunity_Counterparty_Comment__c occ : [SELECT Comment__c, Comment_Type__c, Line_of_Business__c, Related_Opportunity_Counterparty__c FROM Opportunity_Counterparty_Comment__c WHERE Related_Opportunity_Counterparty__c IN:ocMap.keySet()])
                    ecCommentsToInsert.add(new Engagement_Counterparty_Comment__c(Comment__c = occ.Comment__c, Comment_Type__c = occ.Comment_Type__c, Line_of_Business__c = occ.Line_of_Business__c, Related_Engagement_Counterparty__c = ocMap.get(occ.Related_Opportunity_Counterparty__c).Id));
            }

            if(ecContactsToInsert.size() > 0)
                insert ecContactsToInsert;     
            if(ecCommentsToInsert.size() > 0)
                insert ecCommentsToInsert;  
        }
        return ecList;
    }

    public void IndicateCounterparty(Set<Id> engagementCounterpartySet){
        List<Account> updateAcctList = new List<Account>();      
        for(Account account : [SELECT Id, (SELECT Id FROM Opportunity_Counterparties__r LIMIT 1), (SELECT Id FROM Engagement_Counterparties__r LIMIT 1) FROM Account WHERE Id IN : engagementCounterpartySet]) {
            account.CounterParty__c = (account.Opportunity_Counterparties__r.size() > 0 || account.Engagement_Counterparties__r.size() > 0) ? true : false;
            updateAcctList.add(account);
        }
        update updateAcctList;
    }
}