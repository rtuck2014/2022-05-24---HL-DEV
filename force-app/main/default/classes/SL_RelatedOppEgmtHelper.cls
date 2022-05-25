public with sharing class SL_RelatedOppEgmtHelper {
    public static Boolean ALREADY_UPDATED = false;

    /*
        * MethodName        : createInitialRelatedJoiners
        * param             : Map<id, SObject> newOppsEgmts, String oppOrEgmt
        * Description       : This function is called after inserting Opportunity or Engagement records
                              It creates Related Opportunity/Engagement Joiner object records.
    */
    public static void createInitialRelatedJoiners (Map<Id, SObject> newOppsEgmts, String oppOrEgmt){
        Schema.SObjectType joinerType = Schema.getGlobalDescribe().get(oppOrEgmt);
        String parentAPI = oppOrEgmt == 'Engagement_Client_Subject__c' ? 'Engagement__c' : 'Opportunity__c';
 
        // Map used to store filter Engagements which have either client__c or Subject__c field populated to create Joiner Object records.
        // Z.Engman: Prevent this from continuing for engagements converted from opportunities since the conversion handler already mapps the joiner object separately
        Map<Id,SObject> filteredNewOppsEgmts = new Map<Id,SObject>(); 
        for(SObject newOppEng : newOppsEgmts.values()){
            if(!(parentAPI == 'Engagement__c' && newOppEng.get('Engagement__c') == null) && (newOppEng.get('Client__c') != null || newOppEng.get('Subject__c') != null))
                filteredNewOppsEgmts.put((Id)newOppEng.get('Id'),newOppEng);
        }
        // Method Called to insert Joiner Object records for newly inserted Opportunities having either Client or Subject Field Populated.
        if(filteredNewOppsEgmts.isEmpty()){
            return;
        }
        List<SObject> joinersToInsert = new List<SObject>(); 
    
        for(SObject oppOrEng: filteredNewOppsEgmts.values()){
            if(oppOrEng.get('Client__c') != null){                                                                        
                // Adding in a List to insert Joiner object record                                                                    
                joinersToInsert.add(createJoinerRecord(parentAPI, (String) oppOrEng.get('Id'), (String) oppOrEng.get('Client__c'), 'Client', joinerType));                                             
            } //&& oppOrEng.get('Subject__c') != oppOrEng.get('Client__c')
            if(oppOrEng.get('Subject__c') != null){
                joinersToInsert.add(createJoinerRecord(parentAPI, (String) oppOrEng.get('Id'), (String) oppOrEng.get('Subject__c'), 'Subject', joinerType));    
            }
        }
        if(!joinersToInsert.IsEmpty())
            Database.insert(joinersToInsert,false);
    }

    private static SObject createJoinerRecord(String parentAPI, String parentId, String clientSubject, String type, Schema.SObjectType joinerType){
        SObject joinerRecord = joinerType.newSObject();
        joinerRecord.put(parentAPI, parentId);
        joinerRecord.put('Client_Subject__c', clientSubject);
        joinerRecord.put('Primary__c', true);
        joinerRecord.put('Type__c', type);     
        return joinerRecord;
    }

    /*
        * MethodName        : updateRelatedJoiners
        * param             : Map<Id, SObject> newOppsEgmts, Map<Id, SObject> oldOppsEgmts
        * Description       : This function is called after updating an opportunity or engagement Records(either Client__c or Subject__c field) to 
                              Create/Update/Delete Related Opportunity/Engagement Joiner object records.
    */
    public static void updateRelatedJoiners (Map<Id, SObject> newOppsEgmts, Map<Id, SObject> oldOppsEgmts, String oppOrEgmt)  {
        if (ALREADY_UPDATED) {
            return;
        }

        ALREADY_UPDATED = true;
        
        Schema.SObjectType joinerType = Schema.getGlobalDescribe().get(oppOrEgmt);
        String parentAPI = oppOrEgmt == 'Engagement_Client_Subject__c' ? 'Engagement__c' : 'Opportunity__c';
        // List used to store Joiner records which will be deleted when Client__c Or Subject__c field is nullified.
        List<SObject> joinerRecordsToDelete = new List<SObject>(); 
        // List used to store Joiner records which will be inserted when Client__c Or Subject__c field is Populated.
        List<SObject> joinerRecordsToCreate = new List<SObject>(); 

        //Set of AccountIds that have tobe deleted from the joiner object
        Set<Id> accountIds = new Set<Id>();

        //Map to store all the updated client or Subject values
        Map<String, Id> clientOrSubjectToOppOrEng = new Map<String, Id>();
        Set<String> deletionCodes = new Set<String>();
        for(SObject opportunityorEngagement : newOppsEgmts.values()){
            if(opportunityorEngagement.get('Client__c') !=  oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Client__c')){
                //Put the Client value into the map, insert a new record of type 'Client' 
                clientOrSubjectToOppOrEng.put(opportunityorEngagement.get('Client__c') + '_' + opportunityorEngagement.get('Id') + '_' + 'Client', (Id)opportunityorEngagement.get('Client__c'));
                // if the client and subject are now the same
                //if (opportunityorEngagement.get('Client__c')==opportunityorEngagement.get('Subject__c')){
                    // delete the 'Subject' record
                     //Id idAccount = (Id) oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Subject__c');
                     //deletionCodes.add(idAccount + '_' + opportunityorEngagement.get('Id') + '_' + 'Subject');
                     //accountIds.add(idAccount);
                //}
                // if the client and subject were the same, and the subject has not changed
                //if (oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Client__c') == oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Subject__c') && opportunityorEngagement.get('Subject__c') == oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Subject__c')){
                    //Put the Subject value into the map, insert a new record of type 'Subject'
                    //clientOrSubjectToOppOrEng.put(opportunityorEngagement.get('Subject__c') + '_' + opportunityorEngagement.get('Id') + '_' + 'Subject', (Id)opportunityorEngagement.get('Subject__c'));
                //}
                // delete the old 'Client' record associated with this Engagement
                Id idAccount = (Id)oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Client__c');
                deletionCodes.add(idAccount + '_' + opportunityorEngagement.get('Id') + '_' + 'Client');
                accountIds.add(idAccount);
            }
            if(opportunityorEngagement.get('Subject__c') != oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Subject__c')){
                // if the client and subject are not the same
                //if(opportunityorEngagement.get('Client__c') != opportunityorEngagement.get('Subject__c')){
                    //Put the Subject value into the Map, insert a new record of type 'Subject'  
                    clientOrSubjectToOppOrEng.put(opportunityorEngagement.get('Subject__c') + '_' + opportunityorEngagement.get('Id') + '_'  + 'Subject', (Id)opportunityorEngagement.get('Subject__c'));
               //}
                // delete the old 'Subject' record associated with this Engagement
                Id idAccount = (Id)oldOppsEgmts.get((Id)opportunityorEngagement.get('Id')).get('Subject__c');
                deletionCodes.add(idAccount + '_' + opportunityorEngagement.get('Id') + '_' + 'Subject');
                accountIds.add(idAccount);
            }
        }
        String query = 'SELECT Id, Client_Subject__c,Type__c, '+ parentAPI  
                       +' FROM '+oppOrEgmt+' WHERE Client_Subject__c IN :accountIds';
        //collect all the Engagement Client subject to be deleted
        for(SObject objOpportuntiyClientSub : Database.query(query)){            
            if(deletionCodes.Contains(objOpportuntiyClientSub.get('Client_Subject__c') + '_' + objOpportuntiyClientSub.get(parentAPI) + '_' + objOpportuntiyClientSub.get('Type__c')))
                joinerRecordsToDelete.add(objOpportuntiyClientSub);
        }
        //iterate the clientOrSubjectToOppOrEng to create new EngagementClientSubject records
        for(String strAccountEngagementType : clientOrSubjectToOppOrEng.keyset()){
            if(strAccountEngagementType.split('_')[2] == 'Subject'){
                 // Adding in a List to insert Joiner object record   
                 joinerRecordsToCreate.add(createJoinerRecord(parentAPI, strAccountEngagementType.split('_')[1], clientOrSubjectToOppOrEng.get(strAccountEngagementType), 'Subject', joinerType));    
         
            }
            else if(strAccountEngagementType.split('_')[2] == 'Client'){
                 // Adding in a List to insert Joiner object record                                                                
                 joinerRecordsToCreate.add(createJoinerRecord(parentAPI, strAccountEngagementType.split('_')[1], clientOrSubjectToOppOrEng.get(strAccountEngagementType), 'Client', joinerType));  
            }
        }
        //Delete the Records
        if(!joinerRecordsToDelete.IsEmpty()) {
            // Added by Sandeep (SF-507 Date 17th March 2017) Purpose: To stop deleting opportunity client Subject record In trigger 'HL_OpportunityClientSubjectTrigger'
            HL_ConstantsUtil.StopValidation = true;
            Database.delete(joinerRecordsToDelete,false);
            // Added by Sandeep (SF-507 Date 17th March 2017)
            HL_ConstantsUtil.StopValidation = false;
        }
        //Create new records
        if(!joinerRecordsToCreate.IsEmpty())
          // Database.insert(joinerRecordsToCreate,false);
          // Added by Harsh (SF-400 Date 23th March 2017) Purpose: To stop duplicate opportunity client or opportunity Subject on opportunity client Subject record in trigger 'HL_OpportunityClientSubjectTrigger'
            insert joinerRecordsToCreate ;
    }
}