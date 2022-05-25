/**************************************************************************
* Purpose : To handle supporting methods for Trigger ContactCommentTrigger
* Test Class : Test_HL_ContactCommentHandler
**************************************************************************/
public class HL_ContactCommentHandler {
    
    public static void beforeInsert(List<Contact_Comment__c> newContactcommentList, Map<Id, Contact_Comment__c> newContactcommentMap, List<Contact_Comment__c> oldContactcommentList , Map<Id, Contact_Comment__c> oldContactcommentMap) {
        // To stop creating contact comment by user (having insufficient permisison)
        if(!isValidToCreateContactComment())
        {
            if(newContactcommentList != null && newContactcommentList.size() > 0)
                newContactcommentList[0].addError(Label.HL_NoElegible_CreateCC);
        }       
    }
    
    public static void afterInsert(List<Contact_Comment__c> newContactcommentList, Map<Id, Contact_Comment__c> newContactcommentMap, List<Contact_Comment__c> oldContactcommentList , Map<Id, Contact_Comment__c> oldContactcommentMap) { 
        SetupSharingforContactComment(newContactcommentList);
    }
    
    public static void beforeUpdate(List<Contact_Comment__c> newContactcommentList, Map<Id, Contact_Comment__c> newContactcommentMap, List<Contact_Comment__c> oldContactcommentList , Map<Id, Contact_Comment__c> oldContactcommentMap) {
        // To stop creating contact comment by user (having insufficient permisison)
        validateEditDeleteAccessToContactComment(newContactcommentList);
    }
    /*
    public static void afterUpdate(List<Contact_Comment__c> newContactcommentList, Map<Id, Contact_Comment__c> newContactcommentMap, List<Contact_Comment__c> oldContactcommentList , Map<Id, Contact_Comment__c> oldContactcommentMap) {
    }*/
    
    public static void beforeDelete(List<Contact_Comment__c> newContactcommentList, Map<Id, Contact_Comment__c> newContactcommentMap, List<Contact_Comment__c> oldContactcommentList , Map<Id, Contact_Comment__c> oldContactcommentMap) {        
        validateEditDeleteAccessToContactComment(oldContactcommentList);
    }
    /*
    public static void afterDelete(List<Contact_Comment__c> newContactcommentList, Map<Id, Contact_Comment__c> newContactcommentMap, List<Contact_Comment__c> oldContactcommentList , Map<Id, Contact_Comment__c> oldContactcommentMap) {

    }*/
    
    /*
    * Purpose : To identify if logged in user is able to Edit/Delete contact comment record.
    */
    public static void validateEditDeleteAccessToContactComment(List<Contact_Comment__c> ProcessedContactComments){
         boolean isValidToAccessContactComment  = false;
         for(User u : [SELECT Id, Profile.Name from User Where Id =: userinfo.getUserId() AND Profile.Name = 'System Administrator'])
            isValidToAccessContactComment = true;
         if(!isValidToAccessContactComment)
         {
            Set<id> SetofRelatedBankersIdofLoggedInUser = new set<id>();         
            Set<id> SetofRelatedDelegateMembersOfLoggedInUser = new set<id>();
            for(Delegate_Public_Group_Member__c delegate_Member : [ SELECT Delegate__c, Delegate_Public_Group__c, Delegate_Public_Group__r.banker__c  
                                                                    FROM Delegate_Public_Group_Member__c 
                                                                    WHERE (Delegate_Public_Group__r.banker__r.Profile.name = 'Compliance User' OR Delegate_Public_Group__r.banker__r.Profile.name = 'Compliance User Training Admin')])
             {
                if(delegate_Member.Delegate__c == userinfo.getUserId()){
                    SetofRelatedBankersIdofLoggedInUser.add(delegate_Member.Delegate_Public_Group__r.banker__c);
                }
                        
                if(delegate_Member.Delegate_Public_Group__r.banker__c == userinfo.getUserId()){
                       SetofRelatedDelegateMembersOfLoggedInUser.add(delegate_Member.Delegate__c);   
                }                                                                          
             }            
                
            boolean isError = false;
            for(Contact_Comment__c cc : ProcessedContactComments)
            {
                if(cc.ownerId != userinfo.getUserId()){ 
                    if(SetofRelatedBankersIdofLoggedInUser.size() == 0 && SetofRelatedDelegateMembersOfLoggedInUser.size() == 0)
                        cc.addError(Label.HL_NoElegible_EditDelCC);                       
                    // If user is delegate member but need to check if he is delegate member of banker who owns this record
                    if(SetofRelatedBankersIdofLoggedInUser.size() > 0 && !SetofRelatedBankersIdofLoggedInUser.contains(cc.ownerId))
                        isError = true;  
                    // If user is delegate Group Leader but need to check if his delegate member owns this record
                    if(SetofRelatedDelegateMembersOfLoggedInUser.size() > 0 && !SetofRelatedDelegateMembersOfLoggedInUser.contains(cc.ownerId))
                        isError = true;  
                    if(isError)
                        cc.addError(Label.HL_NoElegible_EditDelCC);
                }               
             }
         }         
    }
            
    /*
    * Purpose : To identify if logged in user is able to Edit/Delete contact comment record.
    */
    public static void SetupSharingforContactComment(List<Contact_Comment__c> ProcessedContactComments){
        //system.assertEquals('a','b');
        Set<Id> CCOwnerIds = new Set<Id>();
        for(Contact_Comment__c cc : ProcessedContactComments)
            CCOwnerIds.add(cc.OwnerId);
        /******************************** builidng map of record owner and related  DPGs when record owner are delegates **************************/
        // Buildng map of related Banker and other DPG under related to his BankerIds of record owners
        map<String, Set<Id>> mapOfCCOwnerWIthRelatedBankerAndDPGs = new map<String, Set<Id>>();     
        Set<Id> setOfRelatedBankerIds = new Set<Id>();
        for(Delegate_Public_Group_Member__c delegate_Member : [ SELECT Delegate__c, Delegate_Public_Group__c, Delegate_Public_Group__r.banker__c  
                                                                FROM Delegate_Public_Group_Member__c 
                                                                WHERE Delegate_Public_Group__r.Active__c = true AND Delegate__c IN: CCOwnerIds])
        {
            setOfRelatedBankerIds.add(delegate_Member.Delegate_Public_Group__r.banker__c);
            if(!mapOfCCOwnerWIthRelatedBankerAndDPGs.containsKey(delegate_Member.Delegate__c))
                mapOfCCOwnerWIthRelatedBankerAndDPGs.put(delegate_Member.Delegate__c+'_BnkDPG', new Set<Id>{delegate_Member.Delegate_Public_Group__r.banker__c});
            else
                mapOfCCOwnerWIthRelatedBankerAndDPGs.get(delegate_Member.Delegate__c+'_BnkDPG').add(delegate_Member.Delegate_Public_Group__r.banker__c);        
        }
        /******************************** builidng map of record owner and related  DPGs when record owner are Bankers **************************/
        // Buildng map of related Delegate Public Group Ids of record owners
        map<String, Set<Id>> mapOfCCOwnerWIthRelatedDPGs = new map<String, Set<Id>>();
        // Buildng map of related Banker and other DPG under related to his BankerIds of record owners
        map<String, Set<Id>> mapOfBankerAndRelatedDPGs = new map<String, Set<Id>>();    
        for(Delegate_Public_Group__c DPG : [Select id, Banker__c,Public_Group_ID__c  
                                            From Delegate_Public_Group__c 
                                            Where Active__c = true AND (Banker__c IN: CCOwnerIds OR Banker__c IN: setOfRelatedBankerIds)])
        {
            if(CCOwnerIds.Contains(DPG.Banker__c)){
                if(!mapOfCCOwnerWIthRelatedDPGs.containsKey(DPG.Banker__c))
                    mapOfCCOwnerWIthRelatedDPGs.put(DPG.Banker__c+'_DPG', new Set<Id>{DPG.Public_Group_ID__c});
                else
                    mapOfCCOwnerWIthRelatedDPGs.get(DPG.Banker__c+'_DPG').add(DPG.Public_Group_ID__c);   
            }
            if(setOfRelatedBankerIds.contains(DPG.Banker__c))
            {
                if(!mapOfBankerAndRelatedDPGs.containsKey(DPG.Banker__c))
                    mapOfBankerAndRelatedDPGs.put(DPG.Banker__c, new Set<Id>{DPG.Public_Group_ID__c});
                else
                    mapOfBankerAndRelatedDPGs.get(DPG.Banker__c).add(DPG.Public_Group_ID__c);
            }       
        }
                
        for(String DelegateKey : mapOfCCOwnerWIthRelatedBankerAndDPGs.KeySet())
        {   
            for(ID BankerId : mapOfCCOwnerWIthRelatedBankerAndDPGs.get(DelegateKey))
            {   
                if(mapOfBankerAndRelatedDPGs.containsKey(BankerId)){
                    mapOfCCOwnerWIthRelatedBankerAndDPGs.get(DelegateKey).addAll(mapOfBankerAndRelatedDPGs.get(BankerId));
                    mapOfCCOwnerWIthRelatedBankerAndDPGs.get(DelegateKey).remove(BankerId);
                }
            }           
        } 
        
        /*************************************** Creating Sharing Records **************************************************/
        list<Contact_Comment__share> SharingCCList = new list<Contact_Comment__share>();
        for(Contact_Comment__c cc : ProcessedContactComments) 
        {   
               if(mapOfCCOwnerWIthRelatedBankerAndDPGs.containskey(cc.OwnerId+'_BnkDPG'))
               {
                     for(Id UserGroupId : mapOfCCOwnerWIthRelatedBankerAndDPGs.get(cc.OwnerId+'_BnkDPG'))
                     {
                         if(UserGroupId != null && UserGroupId != cc.OwnerId)
                            SharingCCList.add(new Contact_Comment__share(ParentId = cc.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                     }
               }
               
               if(mapOfCCOwnerWIthRelatedDPGs.containskey(cc.OwnerId+'_DPG'))
               {    
                     for(Id UserGroupId : mapOfCCOwnerWIthRelatedDPGs.get(cc.OwnerId+'_DPG'))
                     {
                         if(UserGroupId != null && UserGroupId != cc.OwnerId){
                            SharingCCList.add(new Contact_Comment__share(ParentId = cc.id, UserOrGroupId = UserGroupId, Accesslevel = 'Edit'));
                         }
                     }
               }
        }
        
        if(SharingCCList.size() > 0 )
        {   
            insert SharingCCList;
        }
    } 
     /*
    * Purpose : To identify if logged in user is able to create contact comment record.
    */
    public static Boolean isValidToCreateContactComment(){
        boolean isValidToAccessContactComment = false;
         for(User u : [SELECT Id, Profile.Name from User Where Id =: userinfo.getUserId() AND (Profile.Name = 'System Administrator' OR Profile.Name = 'Compliance User' OR Profile.Name = 'Compliance User Training Admin')])
            {            
            isValidToAccessContactComment = true;            
            }
        if(!isValidToAccessContactComment)
        {
             // To Fetch the record from delegate public group member where its banker is 'Compliance User' or 'Compliance User Training Admin'
             Set<Delegate_Public_Group_Member__c> delegate_Member_set = new Set<Delegate_Public_Group_Member__c>();
             for(Delegate_Public_Group_Member__c DGM : [SELECT Delegate__c, Delegate_Public_Group__c  FROM Delegate_Public_Group_Member__c where Delegate__c =: userinfo.getUserId() AND (Delegate_Public_Group__r.banker__r.Profile.name = 'Compliance User' OR Delegate_Public_Group__r.banker__r.Profile.name = 'Compliance User Training Admin')])
             {
                 isValidToAccessContactComment = true;
                 break;
             }
        }        
        return isValidToAccessContactComment;
    }      
    
}