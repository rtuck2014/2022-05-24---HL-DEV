/**  
* \arg ClassName        : SL_EngagementInternalTeamHandler
* \arg JIRATicket       : HL-90
* \arg CreatedOn        : 21/Jan/2015
* \arg LastModifiedOn   : 05/March/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Lodhi
* \arg Description      : Utility class to manage sharing rules for Enagament and Opportunity.
*/
public without sharing class SL_ManageSharingRules    
{
    /* Start - Variables */
    public static Boolean ENABLE_ASYNCHRONOUS_SHARING = false;
    public static Boolean DISABLE_SHARING_RULES_PROCESS = false;
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_ManageSharingRules()
    {
        //do nothing.
    } 
    /* Start - Constructor */

    /*
        @MethodName     : manageSharingRules
        @param          : list of SObject, String parent object name, String child object name and string trigger event.
        @JIRATicket     : HL-82,HL-90,HL-93,HL-95
        @Description    : managing the sharing rules for engagement and opportunity
    */
    public static void manageSharingRules(List<SObject> lstSObject, String strParentObjectName, String strChildObjectName, String strTriggerEvent) {
        //if (FeatureManagement.checkPermission('Manage_Sharing_Rules_Asynchronously') && ENABLE_ASYNCHRONOUS_SHARING && (!Test.isRunningTest())) {
        //    HL_RequeryUtility.SObjectsMetadata meta = HL_RequeryUtility.getMetadata(lstSObject);

        //    if (meta.objIds.size() > 0) {
        //        manageSharingRulesFuture(meta.objIds, meta.sobjType, meta.fields, strParentObjectName, strChildObjectName, strTriggerEvent);
        //    }

        //} else {
            manageSharingRulesProcess(lstSObject, strParentObjectName, strChildObjectName, strTriggerEvent);
        //}
    }

    @Future
    public static void manageSharingRulesFuture(List<Id> objIds, String sobjType, List<String> fields, String strParentObjectName, String strChildObjectName, String strTriggerEvent) {
        List<SObject> lstSObject = HL_RequeryUtility.requery(objIds, sobjType, fields);

        manageSharingRulesProcess(lstSObject, strParentObjectName, strChildObjectName, strTriggerEvent);
    }

    static Integer manageSharingRulesProcessCount = 1;

    public static void manageSharingRulesProcess(List<SObject> lstSObject, String strParentObjectName, String strChildObjectName, String strTriggerEvent)
    {
        System.debug('manageSharingRulesProcessCount - ' + (manageSharingRulesProcessCount++));
        System.debug('strParentObjectName - ' + strParentObjectName);
        System.debug('strChildObjectName - ' + strChildObjectName);
        System.debug('strTriggerEvent - ' + strTriggerEvent);

        System.debug('lstSObject - ' + lstSObject?.size());
        for (SObject sobj : lstSObject) {
            System.debug('sobject - ' + sobj);
        }

        if (DISABLE_SHARING_RULES_PROCESS) {
            System.debug('skipping sharing rules process, for now');

            return;
        }

        Set<String> setParentId = new Set<String>();//set of Opportunity/Engagement id
        Set<String> setContactId = new Set<String>();//set of contact id
        Set<String> setParentId_GroupId = new Set<String>();//set of Opportunity/Engagement id and group id
        Set<String> setDNDParentId = new Set<String>();//set of DND Opportunity/Engagement Id
        Set<String> setParentId_UserId = new Set<String>();//Set of Opportunity/Engagement id and user id
        Set<String> setUserId = new Set<String>();//set of user id
        Set<String> setUserOrGroupId = new Set<String>();//Set of User/Group Id
        Set<String> setChildSObjectId = new Set<String>();//Set of Opportunity_Internal_Team__c/Engagement_Internal_Team__c id
        Map<String, String> mapUserIdToGroupId = new Map<String, String>();//Map of user id to group id
        Map<String, String> mapContactIdToUserId = new Map<String, String>();//Map of contact id to user id
        Map<String, SObject> mapParentId_UserOrGroupIdToSObjectShare = new Map<String, SObject>();
        List<SObject> lstFilteredSObject = new List<SObject>();//filtered list of sobject 
        String strSharingObjectName = strParentObjectName.replace('__c', '__Share');//getting sharing object name as per parent object name
        String strStartDateFieldName = 'Start_Date__c';
        //Iterating on list of sobject to getting the parent(Opportunity/Engagement) ids and set of contact ids
        for(SObject sObj : lstSObject)
        {
            if(sObj.get('Contact__c') != null && sObj.get(strParentObjectName) != null)
            {
                setChildSObjectId.add((String)sObj.get('Id'));
                setParentId.add((String)sObj.get(strParentObjectName));
                setContactId.add((String)sObj.get('Contact__c'));
                lstFilteredSObject.add(sObj);
            }
        }
        
        //Fetching all the Opportunity/Engagement whose name starts from DND
        Map<String, SObject> mapParentRecord = new Map<String, SObject>(Database.query('SELECT Id, Name FROM '+ strParentObjectName +
                                                                                       ' WHERE Id IN:setParentId AND Name LIKE \'DND%\''));
        
        //Iterating on contact for getting the map of contact id to user id
        for(Contact objContact : [SELECT Id,
                                         User__c
                                    FROM Contact  
                                   WHERE Id IN : setContactId
                                   AND User__c != null])
        {          
            mapContactIdToUserId.put(objContact.Id, objContact.User__c);
        }
        
        //fetching the user to check the user is active or not
        Map<String, User> mapIdToUser = new Map<String, User>([SELECT Id, IsActive FROM User WHERE Id IN : mapContactIdToUserId.values()]);
        
        //Iterating on Delegate_Public_Group__c for getting the map of user id to group id
        for(Delegate_Public_Group__c objDPG : [SELECT Id,
                                                      Banker__c,
                                                      Public_Group_ID__c
                                                 FROM Delegate_Public_Group__c
                                                WHERE Banker__c IN : mapContactIdToUserId.values()])
        {
            mapUserIdToGroupId.put(objDPG.Banker__c, objDPG.Public_Group_ID__c);
        }
        
        setUserId.addAll(mapContactIdToUserId.values());
        setUserOrGroupId.addAll(mapContactIdToUserId.values());
        setUserOrGroupId.addAll(mapUserIdToGroupId.values());
        
        //Iterating on sharing object records for deleting the sharing records
        for(SObject sObj : Database.query('SELECT Id, UserOrGroupId, ParentId FROM ' + strSharingObjectName +
                                          ' WHERE ParentId IN:setParentId AND UserOrGroupId IN:setUserOrGroupId'))
        {
            mapParentId_UserOrGroupIdToSObjectShare.put((String)sObj.get('ParentId') +'_'+ (String)sObj.get('UserOrGroupId'), sObj);
        }
        
        //Iterating on internal team to avoiding the deletion of sharing record if correponding teams record is existing. 
        for(SObject sObj : Database.query('SELECT Id, Contact__c, Contact__r.User__c, ' + strParentObjectName +
                                          ' FROM ' + strChildObjectName + ' WHERE Contact__c != NULL AND Contact__r.User__c != NULL'+
                                          ' AND ' + strParentObjectName + ' IN:setParentId AND (' + strStartDateFieldName + ' <= today OR '+ 
                                          strStartDateFieldName +' = null) AND (End_Date__c >= today OR End_Date__c = null) AND Contact__r.User__r.IsActive = true'))
        {
            if(mapUserIdToGroupId.containsKey(mapContactIdToUserId.get((String)sObj.get('Contact__c'))) && !mapParentRecord.containsKey((String)sObj.get(strParentObjectName)))
                setParentId_GroupId.add((String)sObj.get(strParentObjectName)+ '_' + mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))));
            else
                setParentId_UserId.add((String)sObj.get(strParentObjectName)+ '_' + mapContactIdToUserId.get((String)sObj.get('Contact__c')));
        }
        
        //Calling method to create sharing records
        if(strTriggerEvent == 'insert')
        {
            createSharingRules(lstSObject, strParentObjectName, strSharingObjectName, mapParentRecord, mapIdToUser,
                               mapParentId_UserOrGroupIdToSObjectShare.keySet(),mapUserIdToGroupId, mapContactIdToUserId);  
        }
        
        //Calling method to delete sharing records
        else if(strTriggerEvent == 'delete')
        {
            deleteSharingRules(lstSObject, strParentObjectName, mapParentRecord, mapUserIdToGroupId, mapIdToUser, mapContactIdToUserId, 
                               mapParentId_UserOrGroupIdToSObjectShare, setParentId_GroupId, setParentId_UserId);
        }
        
        
        //managing sharing rules from batch
        else if(strTriggerEvent == '')
        {
            manageInactiveSObjectSharingRecords(lstFilteredSObject, strParentObjectName, strChildObjectName, strSharingObjectName, 
                                                setParentId, setUserId, setChildSObjectId, mapContactIdToUserId, mapIdToUser,
                                                mapUserIdToGroupId, mapParentRecord, mapParentId_UserOrGroupIdToSObjectShare);
        }
        else{
        //Inserting child sharing rules on insert if Counterparties and Revenue Accural
        //else if(strParentObjectName !='Opportunity__c' || strTriggerEvent == 'Opportunity_Comment__c')
        //{
            createRevAccrualsCounterpartySharingRules(lstSObject, strParentObjectName, mapParentRecord, mapIdToUser,
                                                      mapUserIdToGroupId, mapContactIdToUserId, strTriggerEvent);
        //}
        }
    }
    /* End */
    
    /*
        @MethodName     : removeInactiveSObjectSharingRecords
        @param          : List of SObject.
        @JIRATicket     : HL-90, HL-32
        @Description    : to delete Opportunity__Share/Engagement__Share records for those Opportunity/Engagement 
                          where user and Opportunity_Internal_Team__c/Engagement_Internal_Team__c's are inactive and create 
                          Opportunity__Share/Engagement__Share for those who doesn't have the manual share
    */
    public static void manageInactiveSObjectSharingRecords(List<SObject> lstSObject, String strParentObjectName, String strChildObjectName,
                                                           String strSharingObjectName, Set<String> setParentId, Set<String> setUserId, 
                                                           Set<String> setChildSObjectId, Map<String, String> mapContactIdToUserId, Map<String, User> mapIdToUser,
                                                           Map<String, String> mapUserIdToGroupId, Map<String, SObject> mapParentRecord,
                                                           Map<String, SObject> mapParentId_UserOrGroupIdToSObjectShare)
    {
        Map<String, SObject> mapIdToSObjectShareDelete = new Map<String, SObject>();//Map of Id to SObject Share to delete
        Map<String, Set<String>> mapParentIdToSetUserIdToInsert = new Map<String, Set<String>>();//Map of string to set user id to insert child object sharing records
        Map<String, Set<String>> mapParentIdToSetUserIdToDelete = new Map<String, Set<String>>();//Map of string to set user id to delete child object sharing records
        Set<String> setParentId_GroupId = new Set<String>();//Set of Opportunity/Engagement id to group id
        Set<String> setParentId_UserId = new Set<String>();//Set of Opportunity/Engagement id to user id
        Set<String> setParentId_UserOrGroupId = new Set<String>();//Set of Opportunity/Engagement id to user or group id
        Set<String> setUserId_ParentId_ToCreateShare = new Set<String>();//Set of string combination of userid to Opportunity/Engagement id
        Set<String> setUserOrGroupId = new Set<String>();//set of user or group id
        List<SObject> lstSObjectShareToInsert = new List<SObject>();//List of SObject share record to insert
        String strStartDateFieldName = strParentObjectName == 'Opportunity__c' ? 'Start_Date__c' : 'Start_Date__c';
        
        setUserOrGroupId.addAll(mapUserIdToGroupId.values());
        setUserOrGroupId.addAll(mapContactIdToUserId.values());
        
        //This will help to avoid the deletion of sharing rule for the records which satisfied the condtion of creation but not availble in this chunk. 
        for(SObject sObj : Database.query('SELECT Id, Contact__c, Contact__r.User__r.Id, ' + strParentObjectName + 
                                          ' FROM '+ strChildObjectName + ' WHERE Contact__c != NULL AND Contact__r.User__c != NULL '+ 
                                          ' AND Id NOT IN:setChildSObjectId AND Contact__r.User__r.IsActive = true AND ' +
                                           strParentObjectName + ' IN:setParentId AND Contact__r.User__c IN:setUserId '+
                                          ' AND (' + strStartDateFieldName + ' <= today OR '+ strStartDateFieldName +' = NULL)'+
                                          ' AND (End_Date__c >= today OR End_Date__c = NULL)')) 
        {
            //if((Date)sObj.get(strStartDateFieldName) <= date.today() && (Date)sObj.get('End_Date__c') >= date.today())
            setUserId_ParentId_ToCreateShare.add((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id') +'_'+ (String)sObj.get(strParentObjectName));
        }
        setParentId_UserOrGroupId.addAll(mapParentId_UserOrGroupIdToSObjectShare.keySet());
        
        //Iterating on active Engagement_Internal_Team__c/Opportunity_Internal_Team__c 
        for(SObject sObj : Database.query('SELECT Id, Contact__c, Contact__r.User__c, ' + strParentObjectName +
                                          ' FROM ' + strChildObjectName + ' WHERE Contact__c != NULL AND Contact__r.User__c != NULL'+
                                          ' AND ' + strParentObjectName + ' IN:setParentId AND (' + strStartDateFieldName + ' <= today OR '+ 
                                           strStartDateFieldName +' = NULL) AND (End_Date__c >= today OR End_Date__c = NULL) AND Contact__r.User__r.IsActive = true'))
        {
            if(mapUserIdToGroupId.containsKey(mapContactIdToUserId.get((String)sObj.get('Contact__c'))) && !mapParentRecord.containsKey((String)sObj.get(strParentObjectName)))
                setParentId_GroupId.add((String)sObj.get(strParentObjectName)+ '_' + mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))));
            else
                setParentId_UserId.add((String)sObj.get(strParentObjectName)+ '_' + mapContactIdToUserId.get((String)sObj.get('Contact__c')));
        }
        
        //Iterating on Engagement_Internal_Team__c/Opportunity_Internal_Team__c to insert and delete the Opportunity__Share/Engagement__Share records
        for(SObject sObj : lstSObject)
        {
            //Creating sharing records
            if(((Date)sObj.get(strStartDateFieldName) == null || (Date)sObj.get(strStartDateFieldName) <= date.today()) && ((Date)sObj.get('End_Date__c') == null || (Date)sObj.get('End_Date__c') >= date.today()) 
               && sObj.getSObject('Contact__r').getSObject('User__r') != null && mapIdToUser.containsKey((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id')) && mapIdToUser.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id')).IsActive 
               && mapContactIdToUserId.containsKey((String)sObj.get('Contact__c')) && !setParentId_UserOrGroupId.contains((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c')))
               && !setParentId_UserOrGroupId.contains((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id'))))
            {
                //if parent name not starts with DND and then creating sharing rule corresponding to group id
                if(mapUserIdToGroupId.containsKey((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id')) && !mapParentRecord.containsKey((String)sObj.get(strParentObjectName)))
                {
                    lstSObjectShareToInsert.add(getSharingInstance((String)sObj.get(strParentObjectName), 
                                                                mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id')),
                                                                strSharingObjectName));
                    
                    setParentId_UserOrGroupId.add((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id')));
                    
                    if(!mapParentIdToSetUserIdToInsert.containsKey((String)sObj.get(strParentObjectName)))
                        mapParentIdToSetUserIdToInsert.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                    else
                        mapParentIdToSetUserIdToInsert.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                }
                
                //if Parent name starts with DND or corresponding user do not have delegate public group then creating sharing records corresponding to users
                else 
                {
                    lstSObjectShareToInsert.add(getSharingInstance((String)sObj.get(strParentObjectName), 
                                                                mapContactIdToUserId.get((String)sObj.get('Contact__c')),
                                                                strSharingObjectName));
                    setParentId_UserOrGroupId.add((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                    
                    if(!mapParentIdToSetUserIdToInsert.containsKey((String)sObj.get(strParentObjectName)))
                        mapParentIdToSetUserIdToInsert.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                    else
                        mapParentIdToSetUserIdToInsert.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                }
            }
            
            //delete sharing records
            else if(sObj.getSObject('Contact__r').getSObject('User__r') != null &&  ((Date)sObj.get(strStartDateFieldName) > date.today() || (Date)sObj.get('End_Date__c') < date.today() || !((Boolean)sObj.getSObject('Contact__r').getSObject('User__r').get('IsActive')))
                    && !setUserId_ParentId_ToCreateShare.contains((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id') +'_'+ (String)sObj.get(strParentObjectName)))
            {
                //delete sharing records if existing sharing records are previously created using group id
                if(mapUserIdToGroupId.containsKey((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id'))  
                   && mapParentId_UserOrGroupIdToSObjectShare.containsKey((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id')))
                   && !setParentId_GroupId.contains((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id'))))
                {
                    mapIdToSObjectShareDelete.put(mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id'))).Id,
                                                  mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get((String)sObj.getSObject('Contact__r').getSObject('User__r').get('Id'))));
                    
                    if(!mapParentIdToSetUserIdToDelete.containsKey((String)sObj.get(strParentObjectName)))
                        mapParentIdToSetUserIdToDelete.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                    else
                        mapParentIdToSetUserIdToDelete.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                }
                    
                //delete sharing records if existing sharing records are previously created using user id
                else if(mapContactIdToUserId.containsKey((String)sObj.get('Contact__c'))
                        && !setParentId_UserId.contains((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c')))
                        && mapParentId_UserOrGroupIdToSObjectShare.containsKey((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c'))))
                {
                    mapIdToSObjectShareDelete.put(mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c'))).Id,
                                                  mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c'))));
                    
                    if(!mapParentIdToSetUserIdToDelete.containsKey((String)sObj.get(strParentObjectName)))
                        mapParentIdToSetUserIdToDelete.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                    else
                        mapParentIdToSetUserIdToDelete.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                }
            }
        }
        
        //Insert SObject Share records
        if(!lstSObjectShareToInsert.isEmpty())
            Database.insert(lstSObjectShareToInsert,false);
            
        //Delete the SObject Share records
        if(!mapIdToSObjectShareDelete.isEmpty())
            Database.delete(mapIdToSObjectShareDelete.values(),false);
        
        if(strParentObjectName !='Opportunity__c')
        {   
            if(!mapParentIdToSetUserIdToInsert.isEmpty())
            {
                //calling method to create Engagement_Counterparty__c sharing records
                    manageChildsSharingRules(mapParentIdToSetUserIdToInsert, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToInsert.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Engagement_Counterparty__c', 'insert');    
                
                //calling method to create Revenue_Accrual__c sharing records
                if(!SL_CheckRecursive.skipOnConvert) {
                    manageChildsSharingRules(mapParentIdToSetUserIdToInsert, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToInsert.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Revenue_Accrual__c', 'insert');

                    //calling method to create Revenue_Projection__c sharing records
                    manageChildsSharingRules(mapParentIdToSetUserIdToInsert, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToInsert.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Revenue_Projection__c', 'insert');
                }

                //calling method to create Engagement_Comment__c sharing records
                manageChildsSharingRules(mapParentIdToSetUserIdToInsert, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                         mapParentIdToSetUserIdToInsert.keySet(), setUserOrGroupId, strParentObjectName, 
                                        'Engagement_Comment__c', 'insert');
            }
            if(!mapParentIdToSetUserIdToDelete.isEmpty() && !SL_CheckRecursive.skipOnConvert)
            {
                //calling method to delete Engagement_Counterparty__c sharing records
                 manageChildsSharingRules(mapParentIdToSetUserIdToDelete, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToDelete.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Engagement_Counterparty__c', 'delete');
                
                //calling method to delete Revenue_Accrual__c sharing records
                manageChildsSharingRules(mapParentIdToSetUserIdToDelete, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToDelete.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Revenue_Accrual__c', 'delete');
                
                //calling method to delete Revenue_Projection__c sharing records
                manageChildsSharingRules(mapParentIdToSetUserIdToDelete, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToDelete.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Revenue_Projection__c', 'delete');

                //calling method to delete Engagement_Comment__c sharing records
                 manageChildsSharingRules(mapParentIdToSetUserIdToDelete, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                             mapParentIdToSetUserIdToDelete.keySet(), setUserOrGroupId, strParentObjectName, 
                                            'Engagement_Comment__c', 'delete');
            }
        }
        
    }
    /* End */
    
    /*
        @MethodName     : getSharingInstance
        @param          : Engagement/Opportunity id, user or group id and sharing object name.
        @Description    : method will return the sobject share records
    */
    private static SObject getSharingInstance(String strParentId, String strGroupOrUserId, String strSharingObjectName)
    {
        SObject sObj = Schema.getGlobalDescribe().get(strSharingObjectName).newSObject();
        sObj.put('ParentId', strParentId);
        sObj.put('AccessLevel', strSharingObjectName == 'Opportunity_Comment__Share' || strSharingObjectName == 'Engagement_Comment__Share' ? 'Read' : 'Edit');
        sObj.put('UserOrGroupId', strGroupOrUserId);
        return sObj;
    }
    /* End */

    /*
        @MethodName     : createSharingRules
        @param          : list of SObject, parent object name, sharing object name, map of DND Engagement/Opportunity, 
                          set of existing sharing rules, map of user id to group id and map of contact id to user id.
        @Description    : create the sharing rules for engagement and opportunity
    */
    private static void createSharingRules(List<SObject> lstSObject, String strParentObjectName, String strSharingObjectName, Map<String, SObject> mapParentRecord,
                                           Map<String, User> mapIdToUser, Set<String> setExistingSharingRule, Map<String, String> mapUserIdToGroupId, Map<String, String> mapContactIdToUserId)
    {
        Map<String, Set<String>> mapParentIdToSetUserId = new Map<String, Set<String>>();//Map of string to set user id to insert child object sharing records
        List<SObject> lstSObjectShare = new List<SObject>();//List of Engagement__Share to insert 
        Set<String> setParentId_UserOrGroupId = new Set<String>();//Set of string combination of engagement id and group id
        Set<String> setUserOrGroupId = new Set<String>();
        String strStartDateFieldName = strParentObjectName == 'Opportunity__c' ? 'Start_Date__c' : 'Start_Date__c';
        
        setParentId_UserOrGroupId.addAll(setExistingSharingRule);   
        setUserOrGroupId.addAll(mapUserIdToGroupId.values());
        setUserOrGroupId.addAll(mapContactIdToUserId.values());
        
        //Iterating on list of sobject to create sharing rules corresponding to Opportunity/Enagagement.
        for(SObject sObj : lstSObject)
        {
            if(sObj.get('Contact__c') != null && sObj.get(strParentObjectName) != null && mapContactIdToUserId.containsKey((String)sObj.get('Contact__c')) && mapIdToUser.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))).IsActive)
            {
                if(!mapParentRecord.containsKey((String)sObj.get(strParentObjectName)) && mapContactIdToUserId.containsKey((String)sObj.get('Contact__c')) && mapUserIdToGroupId.containsKey(mapContactIdToUserId.get((String)sObj.get('Contact__c')))
                    && !setParentId_UserOrGroupId.contains((String)sObj.get(strParentObjectName)  +'_'+  mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))))
                    && ((Date)sObj.get(strStartDateFieldName) <= date.today() || (Date)sObj.get(strStartDateFieldName) == null) && ((Date)sObj.get('End_Date__c') >= date.today() || (Date)sObj.get('End_Date__c') == null))
                {
                    lstSObjectShare.add(getSharingInstance((String)sObj.get(strParentObjectName), 
                                                            mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))),
                                                            strSharingObjectName));
                                                                 
                    setParentId_UserOrGroupId.add((String)sObj.get(strParentObjectName)  +'_'+  mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))));
                    setParentId_UserOrGroupId.add((String)sObj.get(strParentObjectName)  +'_'+  mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                    
                    if(!mapParentIdToSetUserId.containsKey((String)sObj.get(strParentObjectName)))
                        mapParentIdToSetUserId.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                    else
                        mapParentIdToSetUserId.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                }
                else 
                {
                    if(mapContactIdToUserId.containsKey((String)sObj.get('Contact__c')) 
                       && !setParentId_UserOrGroupId.contains((String)sObj.get(strParentObjectName)  +'_'+  mapContactIdToUserId.get((String)sObj.get('Contact__c')))
                       && !setParentId_UserOrGroupId.contains((String)sObj.get(strParentObjectName)  +'_'+  mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))))
                       && ((Date)sObj.get(strStartDateFieldName) <= date.today() || (Date)sObj.get(strStartDateFieldName) == null) && ((Date)sObj.get('End_Date__c') >= date.today() || (Date)sObj.get('End_Date__c') == null))
                    {
                        lstSObjectShare.add(getSharingInstance((String)sObj.get(strParentObjectName), 
                                                                mapContactIdToUserId.get((String)sObj.get('Contact__c')),
                                                                strSharingObjectName));
                                                                     
                        setParentId_UserOrGroupId.add((String)sObj.get(strParentObjectName)  +'_'+  mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                        
                        if(!mapParentIdToSetUserId.containsKey((String)sObj.get(strParentObjectName)))
                            mapParentIdToSetUserId.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                        else
                            mapParentIdToSetUserId.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
                    }
                }
            }
        }
        //Inserting sharing records
        if(!lstSObjectShare.isEmpty())
            Database.insert(lstSObjectShare,false);
        
        if(!mapParentIdToSetUserId.isEmpty() && strParentObjectName !='Opportunity__c') 
        {
            //calling method to create Engagement_Counterparty__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser, 
                                         mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 'Engagement_Counterparty__c', 'insert');   
            
                        //calling method to create Engagement_Comment__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                     mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 'Engagement_Comment__c', 'insert');

            //calling method to create Revenue_Accrual__c sharing records
            if(!SL_CheckRecursive.skipOnConvert) {
                manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                         mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 'Revenue_Accrual__c', 'insert');
                //calling method to create Revenue_Projection__c sharing records
                manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                         mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 'Revenue_Projection__c', 'insert');                         
            }
                
        }
    }
    /* End */
    
    /*
        @MethodName     : deleteSharingRules
        @param          : list of SObject, parent object name, child object name, set of Engagement/Opportunity, 
                          map of DND Engagement/Opportunity, map of user id to group id, map of contact id to user id
                          and map of map of Engagement/Opportunity id user id to SObjectshare.
        @JIRATicket     : HL-82,HL-90
        @Description    : create the sharing rules for engagement and opportunity
    */
    private static void deleteSharingRules(List<SObject> lstSObject, String strParentObjectName, Map<String, SObject> mapParentRecord, 
                                           Map<String, String> mapUserIdToGroupId, Map<String, User> mapIdToUser, Map<String, String> mapContactIdToUserId,
                                           Map<String, SObject> mapParentId_UserOrGroupIdToSObjectShare, Set<String> setParentId_GroupId, 
                                           Set<String> setParentId_UserId)
    {
        Map<Id, SObject> mapSObjectShareToDelete = new Map<Id, SObject>();//Map of SObject share to delete sharing records
        Map<String, Set<String>> mapParentIdToSetUserId = new Map<String, Set<String>>();//Map of string to set user id to delete child object sharing records
        Set<String> setUserOrGroupId = new Set<String>();//set of user or group id
        setUserOrGroupId.addAll(mapUserIdToGroupId.values());
        setUserOrGroupId.addAll(mapContactIdToUserId.values());
        
        //Iterating on list of sobject to delete the sharing records
        for(SObject sObj : lstSObject)
        {
            if(sObj.get('Contact__c') != null && sObj.get(strParentObjectName) != null && !mapParentRecord.containsKey((String)sObj.get(strParentObjectName)) 
               && !setParentId_GroupId.contains((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))))
               && mapParentId_UserOrGroupIdToSObjectShare.containsKey((String)sObj.get(strParentObjectName) +'_'+ mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c')))))
            {
                mapSObjectShareToDelete.put(mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName)+ '_' + mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c')))).Id,
                                               mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName)+ '_' + mapUserIdToGroupId.get(mapContactIdToUserId.get((String)sObj.get('Contact__c')))));
                
                //Related to HL-95
                if(!mapParentIdToSetUserId.containsKey((String)sObj.get(strParentObjectName)))
                    mapParentIdToSetUserId.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                else
                    mapParentIdToSetUserId.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
            }
            
            else if(sObj.get('Contact__c') != null && sObj.get(strParentObjectName) != null 
               && !setParentId_UserId.contains((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c')))
               && mapParentId_UserOrGroupIdToSObjectShare.containsKey((String)sObj.get(strParentObjectName) +'_'+ mapContactIdToUserId.get((String)sObj.get('Contact__c'))))
            {
                mapSObjectShareToDelete.put(mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName) + '_' + mapContactIdToUserId.get((String)sObj.get('Contact__c'))).Id,
                                               mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get(strParentObjectName) + '_' + mapContactIdToUserId.get((String)sObj.get('Contact__c'))));
                
                //Related to HL-95
                if(!mapParentIdToSetUserId.containsKey((String)sObj.get(strParentObjectName)))
                    mapParentIdToSetUserId.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                else
                    mapParentIdToSetUserId.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
            }
        }
        //Delete the sharing records
        if(!mapSObjectShareToDelete.isEmpty())
            Database.delete(mapSObjectShareToDelete.values(),false);
            
        if(!mapParentIdToSetUserId.isEmpty() && strParentObjectName !='Opportunity__c')
        {
            //calling method to delete Engagement_Counterparty__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                     mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 
                                    'Engagement_Counterparty__c', 'delete');
            
            //calling method to delete Revenue_Accrual__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                     mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 'Revenue_Accrual__c', 'delete');

            //calling method to delete Revenue_Projection__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                     mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 'Revenue_Projection__c', 'delete');

            //calling method to delete Engagement_Comment__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser,
                                     mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, 
                                    'Engagement_Comment__c', 'delete');
        }                                           
    }
    /* End */

    /*
        @MethodName     : manageChildsSharingRules
        @param          : map of Engagement/Opportunity id to set of user id, parent object name,
                          set of Engagement/Opportunity id, map of contact id to user id, map of user id to group id.
        @JIRATicket     : HL-95
        @Description    : managing the sharing rule for Engagement/Opportunity counterparties and Revenue_Accrual__c when 
                          Engagement/Opportunity internal team is added or deleted.      
    */
    private static void manageChildsSharingRules(Map<String, Set<String>> mapParentIdToSetUserId, Map<String, SObject> mapParentRecord, 
                                                 Map<String, String> mapUserIdToGroupId, Map<String, User> mapIdToUser, 
                                                 Set<String> setParentId, Set<String> setUserOrGroupId, String strParentObjectName,
                                                 String strChildObjectName, String strTriggerEvent)
    {
        Map<String, SObject> mapParentId_UserOrGroupIdToSObjectShare = new Map<String, SObject>();//Map of engagement/opportunity id user or group id to sobject share
        Set<String> setChildRecordIds = new Set<String>();//set of counterparty/revenue accurals id
        String strSharingObjectName = strChildObjectName.replace('__c', '__Share'); 
        
        //Fetching all the opportunity/Engagement counterparties into map 
        Map<String , SObject> mapIdToChildRecords = new Map<String, SObject>(Database.query('SELECT Id, ' + (strChildObjectName == 'Opportunity_Comment__c' ? 'Related_Opportunity__c' : strParentObjectName) + 
                                                                                           ' FROM ' + strChildObjectName + 
                                                                                           ' WHERE ' + (strChildObjectName == 'Opportunity_Comment__c' ? 'Related_Opportunity__c' : strParentObjectName) + ' IN:setParentId' + 
                                                                                           (strChildObjectName == 'Opportunity_Comment__c' || strChildObjectName == 'Engagement_Comment__c'  ? ' AND Comment_Type__c <> \'Administrative\' AND Comment_Type__c <> \'Compliance\' ' : '')));
        
        //adding all the opportunity/Engagement counterparties id into set  
        setChildRecordIds.addAll(mapIdToChildRecords.keySet());
        
        //Fetching all the opportunity/Engagement counterparties to avoid the creation of duplicate sharing records.                                                                             
        for(SObject sObj : Database.query('SELECT Id, UserOrGroupId, ParentId FROM ' + strSharingObjectName +
                                          ' WHERE ParentId IN:setChildRecordIds AND UserOrGroupId IN:setUserOrGroupId'))
        {
            mapParentId_UserOrGroupIdToSObjectShare.put((String)sObj.get('ParentId') +'_'+ (String)sObj.get('UserOrGroupId'), sObj);
        }
        
        if(strTriggerEvent == 'insert')
            createChildsSharingRules(mapIdToChildRecords, mapParentIdToSetUserId, mapUserIdToGroupId, mapParentRecord, mapIdToUser,
                                     mapParentId_UserOrGroupIdToSObjectShare.keySet(), strParentObjectName, strSharingObjectName);
        if(strTriggerEvent == 'delete') 
            deleteChildsSharingRules(mapIdToChildRecords, mapParentIdToSetUserId, mapUserIdToGroupId, mapParentRecord,
                                     mapParentId_UserOrGroupIdToSObjectShare, setUserOrGroupId, strParentObjectName);
    }
    /* End */
    
    /*
        @MethodName     : createChildsSharingRules
        @param          : map of Engagement/Opportunity id to set of user id, parent object name,
                          set of Engagement/Opportunity id, map of contact id to user id, map of user id to group id.
        @JIRATicket     : HL-95
        @Description    : Creating sharing rule for Engagement/Opportunity counterparties and Revenue_Accrual__c when 
                          Engagement/Opportunity internal team is added      
    */
    private static void createChildsSharingRules(Map<String , SObject> mapIdToChildRecords, Map<String , Set<String>> mapParentIdToSetUserId, 
                                                 Map<String, String> mapUserIdToGroupId, Map<String, SObject> mapParentRecord, Map<String, User> mapIdToUser,
                                                 Set<String> setExistingSharingRule, String strParentObjectName, String strSharingObjectName)
    {
        List<SObject> lstSObjectShare = new List<SObject>();
        Set<String> setParentId_UserOrGroupId  = new Set<String>(); 
        setParentId_UserOrGroupId.addAll(setExistingSharingRule);
        
        //Iterating on opportunity/Engagement counterparties to create manual shares with each users
        for(SObject sObj : mapIdToChildRecords.values())
        {
            for(String strUserId : mapParentIdToSetUserId.get((String)sObj.get((strSharingObjectName == 'Opportunity_Comment__Share' ? 'Related_Opportunity__c' : strParentObjectName))))
            {
                if(mapIdToUser.containsKey(strUserId) && mapIdToUser.get(strUserId).IsActive && !setParentId_UserOrGroupId.contains((String)sObj.get('Id')+'_'+strUserId)
                   && !setParentId_UserOrGroupId.contains((String)sObj.get('Id')+'_'+mapUserIdToGroupId.get(strUserId)) )
                {
                    if(mapUserIdToGroupId.containsKey(strUserId) && !mapParentRecord.containsKey((String)sObj.get((strSharingObjectName == 'Opportunity_Comment__Share' ? 'Related_Opportunity__c' : strParentObjectName))))
                    {
                        lstSObjectShare.add(getSharingInstance((String)sObj.get('Id'), mapUserIdToGroupId.get(strUserId), strSharingObjectName));
                        setParentId_UserOrGroupId.add((String)sObj.get('Id')+'_'+mapUserIdToGroupId.get(strUserId));
                    }
                    else
                    {
                        lstSObjectShare.add(getSharingInstance((String)sObj.get('Id'), strUserId, strSharingObjectName));
                        setParentId_UserOrGroupId.add((String)sObj.get('Id')+'_'+strUserId);
                    }
                }       
            }   
        }
        //Insert the opportunity/Engagement counterparty and Revenue_Accrual__c sharing records.
        if(!lstSObjectShare.isEmpty())
            Database.insert(lstSObjectShare,false);
    }
    /* End */
    
    /*
        @MethodName     : deleteChildsSharingRules
        @param          : map of Engagement/Opportunity id to set of user id, parent object name,
                          set of Engagement/Opportunity id, map of contact id to user id, map of user id to group id.
        @JIRATicket     : HL-95
        @Description    : deleting sharing rule for Engagement/Opportunity counterparties and 
                          Revenue_Accrual__c when Engagement/Opportunity internal team is deleted  
    */
    private static void deleteChildsSharingRules(Map<String , SObject> mapIdToChildRecords, Map<String , Set<String>> mapParentIdToSetUserId, 
                                                 Map<String, String> mapUserIdToGroupId, Map<String, SObject> mapParentRecord,
                                                 Map<String, SObject> mapParentId_UserOrGroupIdToSObjectShare, Set<String> setUserOrGroupId, 
                                                 String strParentObjectName)
    {
        Map<String, SObject> mapIdToSObjectShare = new Map<String, SObject>();
        
        //Iterating on opportunity/Engagement counterparties to create manual shares with each users
        for(SObject sObj : mapIdToChildRecords.values())
        {
            for(String strUserId : mapParentIdToSetUserId.get((String)sObj.get(strParentObjectName)))
            {   
                if(mapParentId_UserOrGroupIdToSObjectShare.containsKey((String)sObj.get('Id')+'_'+strUserId))
                    mapIdToSObjectShare.put(mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get('Id')+'_'+strUserId).Id,
                                            mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get('Id')+'_'+strUserId)); 
                
                else if(mapUserIdToGroupId.containsKey(strUserId) && 
                        mapParentId_UserOrGroupIdToSObjectShare.containsKey((String)sObj.get('Id')+'_'+mapUserIdToGroupId.get(strUserId)))
                {
                    mapIdToSObjectShare.put(mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get('Id')+'_'+mapUserIdToGroupId.get(strUserId)).Id,
                                            mapParentId_UserOrGroupIdToSObjectShare.get((String)sObj.get('Id')+'_'+mapUserIdToGroupId.get(strUserId)));
                }
            }   
        }
        
        if(!mapIdToSObjectShare.isEmpty())
            Database.delete(mapIdToSObjectShare.values(),false);
    }
    /* End */
    
    /*
        @MethodName     : deleteSharesOnChangeParentName
        @param          : Set of Engagement/Opportunity id and parent object name.
        @JiraTicket     : HL-93         
        @Description    : If an Engagement/Opportunity is changed from DND to not-DND or vice-versa 
                          then delete all the sharing records  
    */
    public static void deleteSharesOnChangeParentName(Set<String> setParentId, String strParentObjectName)
    {
        if(strParentObjectName == 'Engagement__c')
        {
            delete[SELECT Id FROM Engagement__Share WHERE ParentId IN : setParentId AND AccessLevel='Edit' AND RowCause='Manual'];
            delete[SELECT Id FROM Engagement_Counterparty__Share WHERE ParentId IN : setParentId AND AccessLevel='Edit' AND RowCause='Manual'];
            delete[SELECT Id FROM Revenue_Accrual__Share WHERE ParentId IN : setParentId AND AccessLevel='Edit' AND RowCause='Manual'];
        }
        else if(strParentObjectName == 'Opportunity__c'){
            delete[SELECT Id FROM Opportunity__Share WHERE ParentId IN : setParentId AND AccessLevel='Edit' AND RowCause='Manual'];
            delete[SELECT Id FROM Opportunity_Counterparty__Share WHERE ParentId IN : setParentId AND AccessLevel='Edit' AND RowCause='Manual'];
        }
        
        //calling method for creating sharing rules according to parent name.
        manageDNDSObjectSharingRule(setParentId, strParentObjectName);
    }
    /* End */
    
    /*
        @MethodName     : manageDNDSObjectSharingRule
        @param          : Set of Engagement/Opportunity id and parent object name.
        @JiraTicket     : HL-93         
        @Description    : If an Engagement/Opportunity is changed from DND to not-DND or vice-versa 
                          the sharing records for that Engagement/Opportunity will create/delete accordingly. 
    */
    public static void manageDNDSObjectSharingRule(Set<String> setParentId, String strParentObjectName)
    {
        String strChildObjectName = strParentObjectName == 'Engagement__c' ? 'Engagement_Internal_Team__c' : 'Opportunity_Internal_Team__c';
        String strStartDateFieldName = strParentObjectName == 'Opportunity__c' ? 'Start_Date__c' : 'Start_Date__c';
          
        //Calling the method to create Engagement/Opportunity sharing rule                                  
        manageSharingRules(Database.query('SELECT Id, Contact__c, Contact__r.User__r.Id, End_Date__c, ' + strParentObjectName  + 
                                          ', Contact__r.User__r.IsActive, ' + strStartDateFieldName + ' FROM ' + strChildObjectName + 
                                          ' WHERE Contact__c != NULL AND Contact__r.User__c != NULL '+ 
                                          ' AND ' + strParentObjectName + ' IN:setParentId'), 
                                           strParentObjectName, strChildObjectName, 'insert');  
    }
    /* End */
    
    /*
        @MethodName     : createDeleteShareOnUpdate
        @param          : Old and new map of Engagement/Opportunity, parent object name and child object name.
        @JiraTicket     : HL-90         
        @Description    : If an Engagement/Opportunity internal team is updated then creating and deleting the sharing rules 
    */
    public static void createDeleteShareOnUpdate(Map<Id, SObject> mapOldSObject, Map<Id, SObject> mapNewSObject, String strParentObjectName, String strChildObjectName)
    {
        Map<String, SObject> mapInsertSObjectShare  = new Map<String, SObject>();
        Map<String, SObject> mapDeleteSObjectShare  = new Map<String, SObject>();
        String strStartDateFieldName = strParentObjectName == 'Opportunity__c' ? 'Start_Date__c' : 'Start_Date__c';
        
        for(SObject sObj : mapNewSObject.values())
        {
            //If start date or end date or contact is changed 
            if((Date)sObj.get(strStartDateFieldName) != (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) || (Date)sObj.get('End_Date__c') != (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') )
            {
                //inserting sharing rule for engagement/opportunity when
                //if only start date is changed  
                if(((Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) != null && (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) > Date.today()) 
                    && ((Date)sObj.get(strStartDateFieldName) <= Date.today() || (Date)sObj.get(strStartDateFieldName) == null)
                    && (Date)sObj.get('End_Date__c') == (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') 
                    && ((Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') >= Date.today() || (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') == null))
                {
                    mapInsertSObjectShare.put((String)sObj.get('Id'), sObj);
                }
                
                //if only end date is changed   
                if(((Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') != null && (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') < Date.today()) 
                         && ((Date)sObj.get('End_Date__c') >= Date.today() || (Date)sObj.get('End_Date__c') == null)
                         && (Date)sObj.get(strStartDateFieldName) == (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) 
                         && ((Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) <= Date.today() || (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) == null))
                {
                    mapInsertSObjectShare.put((String)sObj.get('Id'), sObj);
                }
                
                //if both the dates are changed 
                if((Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) != null && (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') != null 
                        && (((Date)sObj.get(strStartDateFieldName) <= Date.today() && (Date)sObj.get('End_Date__c') >= Date.today()) 
                        || ((Date)sObj.get(strStartDateFieldName) == null && (Date)sObj.get('End_Date__c') == null))) 
                {
                    mapInsertSObjectShare.put((String)sObj.get('Id'), sObj);
                }  
                
                //delete sharing rule for engagement/opportunity when
                //if only start date is changed                             
                if((((Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) != null && (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) <= Date.today())
                        || (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) == null) 
                        && (Date)sObj.get(strStartDateFieldName) > Date.today() && (Date)sObj.get('End_Date__c') == (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') 
                        && ((Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') >= Date.today() || (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') == null))
                {
                    mapDeleteSObjectShare.put((String)sObj.get('Id'), sObj);
                }
                
                //if only end date is changed  
                if((((Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') != null && (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') >= Date.today())
                         || (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') == null) 
                         && (Date)sObj.get('End_Date__c') < Date.today() && (Date)sObj.get(strStartDateFieldName) == (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) 
                         && ((Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) <= Date.today() || (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) == null))
                {
                    mapDeleteSObjectShare.put((String)sObj.get('Id'), sObj);   
                }
                
                //if both the dates are changed 
                if(((Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) != null || (Date)mapOldSObject.get((String)sObj.get('Id')).get(strStartDateFieldName) == null) 
                        && ((Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') != null || (Date)mapOldSObject.get((String)sObj.get('Id')).get('End_Date__c') == null)
                        && (((Date)sObj.get(strStartDateFieldName) > Date.today() && (Date)sObj.get('End_Date__c') <= Date.today()) || ((Date)sObj.get(strStartDateFieldName) > Date.today() && (Date)sObj.get('End_Date__c') > Date.today())
                        || ((Date)sObj.get(strStartDateFieldName) <= Date.today() && (Date)sObj.get('End_Date__c') < Date.today())))  
                {
                    mapDeleteSObjectShare.put((String)sObj.get('Id'), sObj);
                } 
            }
            
            //if contact is updated then create new sharing rules 
            if(sObj.get('Contact__c') != mapOldSObject.get((String)sObj.get('Id')).get('Contact__c') && sObj.get('Contact__c') != null)
            {
                mapInsertSObjectShare.put((String)sObj.get('Id'), sObj);    
            }
            
            //if contact is updated to other or null then delete the old sharing rule and create new sharing rules
            if(sObj.get('Contact__c') != mapOldSObject.get((String)sObj.get('Id')).get('Contact__c') || sObj.get('Contact__c') == null)
            {
                mapDeleteSObjectShare.put((String)sObj.get('Id'), sObj);
            }
        }
        //calling method to delete engagement/opportunity and engagement child object sharing rules when internal teams are updated
        if(!mapDeleteSObjectShare.isEmpty())
            manageSharingRules(mapDeleteSObjectShare.values(), strParentObjectName, strChildObjectName, 'delete');
            
        //calling method to create engagement/opportunity and engagement child object sharing rules when internal teams are updated 
        if(!mapInsertSObjectShare.isEmpty())
            manageSharingRules(mapInsertSObjectShare.values(), strParentObjectName, strChildObjectName, 'insert');
    }
    
    /*
        @MethodName     : createChildsSharingRules
        @param          : List of Sobject and child object name  
        @JIRATicket     : HL-112
        @Description    : To find out all the Engagement_Internal_Team__c 
                          corresponding to the current Engagement      
    */
    public static void manageRevAccrualsCounterpartySharingRules(List<SObject> lstSObject, String strTriggerCalledFrom)
    {
        Set<String> setIds = new Set<String>();//set of engagement id

        if(strTriggerCalledFrom == 'Opportunity_Comment__c'){
            for(SObject sObj : lstSObject)
                setIds.add((String)sObj.get('Related_Opportunity__c'));

            //List of Opportunity_Internal_Team__c corresponding to engagements
            List<Opportunity_Internal_Team__c> lstOIT  = new List<Opportunity_Internal_Team__c>([SELECT Id, 
                                                                                                  Contact__c, 
                                                                                                  Contact__r.User__r.Id, 
                                                                                                  Start_Date__c, End_Date__c,
                                                                                                  Opportunity__c, 
                                                                                                  Contact__r.User__r.IsActive  
                                                                                             FROM Opportunity_Internal_Team__c
                                                                                            WHERE Opportunity__c IN : setIds
                                                                                             AND Contact__r.User__r.IsActive = true]);
        
        
            if(!lstOIT.isEmpty())
                manageSharingRules(lstOIT, 'Opportunity__c', 'Opportunity_Internal_Team__c', strTriggerCalledFrom);
        }
        else
        {
            //Iterating over revenue accruals/Engagement couterparty to get engagments id into set
            for(SObject sObj : lstSObject)
            {
                if(sObj.get('Engagement__c') != null)
                    setIds.add((String)sObj.get('Engagement__c'));
            }
        
            //List of Engagement_Internal_Team__c corresponding to engagements
            List<Engagement_Internal_Team__c> lstEIT  = new List<Engagement_Internal_Team__c>([SELECT Id, 
                                                                                                  Contact__c, 
                                                                                                  Contact__r.User__r.Id, 
                                                                                                  Start_Date__c, End_Date__c,
                                                                                                  Engagement__c, 
                                                                                                  Contact__r.User__r.IsActive  
                                                                                             FROM Engagement_Internal_Team__c
                                                                                            WHERE Engagement__c IN : setIds
                                                                                             AND Contact__r.User__r.IsActive = true]);
            if(!lstEIT.isEmpty())
                manageSharingRules(lstEIT, 'Engagement__c', 'Engagement_Internal_Team__c', strTriggerCalledFrom);
        }           
    }
    /* End */
    
    
    /*
        @MethodName     : createChildsSharingRules(manageRevAccrualsCounterpartySharingRulesFuture)
        @param          : List of Sobject and child object name  
        @Project        : PRJ0016578
        @Description    : ssue with counterparties where an error is displayed when adding counterparties to an engagement in bulk (50+ counterparties)     
    */
    @Future
    public static void manageRevAccrualsCounterpartySharingRulesFuture(String JsonString, String strTriggerCalledFrom)
    {
        List<SObject> lstSObject = (List<SObject>) Json.deserialize(JsonString, List<Sobject>.class);
        Set<String> setIds = new Set<String>();//set of engagement id

        if(strTriggerCalledFrom == 'Opportunity_Comment__c'){
            for(SObject sObj : lstSObject)
                setIds.add((String)sObj.get('Related_Opportunity__c'));

            //List of Opportunity_Internal_Team__c corresponding to engagements
            List<Opportunity_Internal_Team__c> lstOIT  = new List<Opportunity_Internal_Team__c>([SELECT Id, 
                                                                                                  Contact__c, 
                                                                                                  Contact__r.User__r.Id, 
                                                                                                  Start_Date__c, End_Date__c,
                                                                                                  Opportunity__c, 
                                                                                                  Contact__r.User__r.IsActive  
                                                                                             FROM Opportunity_Internal_Team__c
                                                                                            WHERE Opportunity__c IN : setIds
                                                                                             AND Contact__r.User__r.IsActive = true]);
        
        
            if(!lstOIT.isEmpty())
                manageSharingRules(lstOIT, 'Opportunity__c', 'Opportunity_Internal_Team__c', strTriggerCalledFrom);
        }
        else
        {
            //Iterating over revenue accruals/Engagement couterparty to get engagments id into set
            for(SObject sObj : lstSObject)
            {
                if(sObj.get('Engagement__c') != null)
                    setIds.add((String)sObj.get('Engagement__c'));
            }
        
            //List of Engagement_Internal_Team__c corresponding to engagements
            List<Engagement_Internal_Team__c> lstEIT  = new List<Engagement_Internal_Team__c>([SELECT Id, 
                                                                                                  Contact__c, 
                                                                                                  Contact__r.User__r.Id, 
                                                                                                  Start_Date__c, End_Date__c,
                                                                                                  Engagement__c, 
                                                                                                  Contact__r.User__r.IsActive  
                                                                                             FROM Engagement_Internal_Team__c
                                                                                            WHERE Engagement__c IN : setIds
                                                                                             AND Contact__r.User__r.IsActive = true]);
            if(!lstEIT.isEmpty())
                manageSharingRules(lstEIT, 'Engagement__c', 'Engagement_Internal_Team__c', strTriggerCalledFrom);
        }           
    }
    
    // @Future Method End
    
    /*
        @MethodName     : createRevAccrualsCounterpartySharingRules
        @param          : List of SObject, parent object name, map of parent records, 
                          Map Id to User, Map of User Id to Group Id, Map of Contact
                          Id to User Id and child object name to know which trigger is fired 
        @JIRATicket     : HL-112
        @Description    : On insert of Revenue Accruals and Engagement Counterparty Create 
                          manual sharing records Revenue Accruals and Engagement Counterparty      
    */
    private static void createRevAccrualsCounterpartySharingRules(List<SObject> lstSObject, String strParentObjectName, Map<String, SObject> mapParentRecord, 
                                                                  Map<String, User> mapIdToUser, Map<String, String> mapUserIdToGroupId, 
                                                                  Map<String, String> mapContactIdToUserId, String strTriggerCalledFrom)
    {
        Map<String, Set<String>> mapParentIdToSetUserId = new Map<String, Set<String>>();//Map of string to set user id to insert child object sharing records
        Set<String> setUserOrGroupId = new Set<String>();
        setUserOrGroupId.addAll(mapUserIdToGroupId.values());
        setUserOrGroupId.addAll(mapContactIdToUserId.values());
         
        //Iterating on list of sobject to create childs sharing rules Enagagement.
        for(SObject sObj : lstSObject)
        {
            if(sObj.get('Contact__c') != null && sObj.get(strParentObjectName) != null && mapContactIdToUserId.containsKey((String)sObj.get('Contact__c')) && mapIdToUser.get(mapContactIdToUserId.get((String)sObj.get('Contact__c'))).IsActive)
            {
                if(!mapParentIdToSetUserId.containsKey((String)sObj.get(strParentObjectName)))
                    mapParentIdToSetUserId.put((String)sObj.get(strParentObjectName), new Set<String>{mapContactIdToUserId.get((String)sObj.get('Contact__c'))});
                else
                    mapParentIdToSetUserId.get((String)sObj.get(strParentObjectName)).add(mapContactIdToUserId.get((String)sObj.get('Contact__c')));
            }
        }
        if(!mapParentIdToSetUserId.isEmpty())   
        {
            //calling method to create Engagement_Counterparty__c sharing records
            manageChildsSharingRules(mapParentIdToSetUserId, mapParentRecord, mapUserIdToGroupId, mapIdToUser, 
                                     mapParentIdToSetUserId.keySet(), setUserOrGroupId, strParentObjectName, strTriggerCalledFrom, 'insert');   
        }
    }
}
/* End */