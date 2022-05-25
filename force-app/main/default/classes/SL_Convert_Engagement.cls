/**
* \arg ClassName      : SL_Convert_Engagement
* \arg JIRATicket     : HL-7
* \arg CreatedOn      : 14/APR/2014
* \arg LastModifiedOn : 10/DEC/2014
* \arg CreatededBy    : Vishnu
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Handler class for SL_Convert_Engagement page.
* \arg LastModifiedOn : 20/NOV/2019
* \arg Description    : For Oracle integration, call HL_EngagementVatTreatmentHandler.updateTaxClassificationOnContracts() after conversion
*/
global with sharing class SL_Convert_Engagement {
    public static boolean isQueueableActiveForExternalTeam = false;
    webService static String convertEngagement(Id opportunityId) {
    Map<Id,Opportunity__c> mapIdToOpportunity = new Map<Id,Opportunity__c>();
    Boolean hasException = false;
    String oldStage;
    SL_CheckRecursive.skipOnConvert = true;
    try {
        Map<String, String> fieldNames = new Map<String, String>();
        Map<String, Schema.SObjectField> opportunityFields = Opportunity__c.getSObjectType().getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> engagementFields = Engagement__c.getSObjectType().getDescribe().fields.getMap();
        boolean containsStage=false;
        for(SL_Convert__Field_Mapping__c objFM : [SELECT SL_Convert__Context_Field_Name__c,
                                                                                 SL_Convert__Target_Field_Name__c
                                                        FROM SL_Convert__Field_Mapping__c 
                                                       WHERE SL_Convert__Active__c = true 
                                                         AND SL_Convert__Object_Relationship__r.SL_Convert__Parent_Object_Relationship__c = null 
                                                         AND SL_Convert__Object_Relationship__r.SL_Convert__Context_Object_API__c = 'Opportunity__c']){
        if(objFM.SL_Convert__Context_Field_Name__c != null 
            && objFM.SL_Convert__Context_Field_Name__c != '' 
            && objFM.SL_Convert__Target_Field_Name__c != null 
            && objFM.SL_Convert__Target_Field_Name__c != ''
            && opportunityFields.keySet().contains(objFM.SL_Convert__Context_Field_Name__c.toLowerCase())
            && engagementFields.keySet().contains(objFM.SL_Convert__Target_Field_Name__c.toLowerCase())){
            if(objFM.SL_Convert__Context_Field_Name__c=='Stage__c'){
              containsStage=true;
            }
            fieldNames.put(objFM.SL_Convert__Target_Field_Name__c, objFM.SL_Convert__Context_Field_Name__c);
        }
      }      
      String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
      if(!containsStage){
        strQuery+=',Stage__c';
      }
      System.debug('fields:'+strQuery);
      strQuery = 'SELECT Converted_To_Engagement__c' + strQuery + ' FROM Opportunity__c WHERE Id = \'' +opportunityId +'\'';
      system.debug('opportunityId-- '+opportunityId);
        system.debug('strQuery-- '+strQuery);  
      for(Opportunity__c opp : Database.query(strQuery)){
        if (opp.Converted_to_Engagement__c){
          return 'ERROR: Opportunity has already been converted to an Engagement!';
        }
        opp.Converted_To_Engagement__c=true;
        oldStage = opp.Stage__c;
        opp.Stage__c='Engaged';
        update opp;
        mapIdToOpportunity.put(opp.Id, opp);
      }
      isQueueableActiveForExternalTeam = true;
      // To stop un-necessary operations related to PV while converting opportunity in to engagement
      HL_ConstantsUtil.stopExecutionForPVConversion = true;
      
      SL_Convert.SL_MappingTrigger_Handler objMappingTriggerHandler = new SL_Convert.SL_MappingTrigger_Handler();
      objMappingTriggerHandler.createSobjectRecords(mapIdToOpportunity,'Opportunity__c');//<! call createSobjectRecords method
      
      HL_ConstantsUtil.stopExecutionForPVConversion = false;
      System.debug('OppId'+opportunityId);
        SL_Convert_EngagementQueueableClass queueableClass = new SL_Convert_EngagementQueueableClass(opportunityId);
      System.enqueueJob(queueableClass);  
      List<Engagement__c> newEngagement = [SELECT Id, Opportunity__c,Line_of_Business__c FROM Engagement__c WHERE Opportunity__c=:opportunityId ORDER BY CreatedDate Desc LIMIT 1];
      if (!newEngagement.isEmpty()){
          //Call method to update contracts     with tax classification code
          Set<Id> engagementSet = new Set<Id>();
          engagementSet.add(newEngagement[0].Id);  
          HL_EngagementVatTreatmentHandler.updateTaxClassificationOnContracts(engagementSet);

          List<Engagement_Client_Subject__c> ecsList = new List<Engagement_Client_Subject__c>();
          Map<String,Schema.RecordTypeInfo> rtInfoMap = Schema.SobjectType.Engagement_Client_Subject__c.getRecordTypeInfosByDeveloperName();
          String rtId;
          for(Opportunity_Client_Subject__c ocs : [SELECT Id,LineofBusiness__c,
                                                  Notes__c,ClientHoldings__c,   DebtHoldingsMM__c,
                                                  Role__c,KeyCreditorCreated__c,ClientHoldingsMM__c,
                                                  KeyCreditorImportance__c,KeyCreditorWeighting__c,Legacy_SLX_Id__c,
                                                  Other_Related_Object_Id__c,Original_Name__c,RevenueAllocation__c,
                                                  Type__c,Primary__c,RecordType.DeveloperName,Client_Subject__c
                                                  FROM Opportunity_Client_Subject__c WHERE Opportunity__c=:opportunityId]){
            if(ocs.LineOfBusiness__c=='FR'){
              rtId = rtInfoMap.get(ocs.RecordType.DeveloperName).getRecordTypeId();
            }else {
              if(ocs.Type__c=='Client'){
                rtId=rtInfoMap.get('Additional_Client').getRecordTypeId();
              }else if(ocs.Type__c=='Subject'){
                rtId=rtInfoMap.get('Additional_Subject').getRecordTypeId();
              }else{
                rtId=rtInfoMap.get('Additional_Other').getRecordTypeId();
              }
            }
            ecsList.add(new Engagement_Client_Subject__c(Engagement__c=newEngagement[0].Id,Type__c=ocs.Type__c,Client_Subject__c=ocs.Client_Subject__c,RecordTypeId=rtId,            
                                                  Notes__c=ocs.Notes__c,ClientHoldings__c=ocs.ClientHoldings__c,DebtHoldingsMM__c=ocs.DebtHoldingsMM__c,
                                                  Role__c=ocs.Role__c,KeyCreditorCreated__c=ocs.KeyCreditorCreated__c,ClientHoldingsMM__c=ocs.ClientHoldingsMM__c,
                                                  KeyCreditorImportance__c=ocs.KeyCreditorImportance__c,KeyCreditorWeighting__c=ocs.KeyCreditorWeighting__c,Legacy_SLX_Id__c=ocs.Legacy_SLX_Id__c,
                                                  Other_Related_Object_Id__c=ocs.Other_Related_Object_Id__c,Original_Name__c=ocs.Original_Name__c,CreditorRevenueAllocationPercentage__c=ocs.RevenueAllocation__c,
                                                  Primary__c=ocs.Primary__c));
          }
          insert ecsList;

          return newEngagement[0].Id;
      }
      /*List<Engagement__c> newEngagement = [SELECT Id, Opportunity__c FROM Engagement__c WHERE Opportunity__c=:opportunityId ORDER BY CreatedDate Desc LIMIT 1];
      if (!newEngagement.isEmpty()){
          return newEngagement[0].Id;
      } 
      SL_Convert_EngagementQueueableClass queueableClass = new SL_Convert_EngagementQueueableClass(newEngagement);
      System.enqueueJob(queueableClass);*/
        
      return opportunityId;
    }
    catch (DMLException e){ 
      hasException = true;
      return 'ERROR: ' + e.getDMLMessage(0);
    }
    catch (Exception e){
      hasException = true;
      return 'ERROR: ' + e.getMessage();
    }
    finally {
      if (hasException){
        for (Opportunity__c opp: mapIdToOpportunity.values()){
            opp.Converted_To_Engagement__c=false;
            if (oldStage!=null&&oldStage!=''){
                opp.Stage__c = oldStage;
            }
        }
        if (!mapIdToOpportunity.isEmpty()){
          update mapIdToOpportunity.values();
        }
      }
      SL_CheckRecursive.skipOnConvert = false;
     }
  }
    
}