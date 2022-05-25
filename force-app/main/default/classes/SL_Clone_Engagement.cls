/**
* \arg ClassName      : SL_Clone_Engagement
* \arg JIRATicket     : HL-7
* \arg CreatedOn      : 14/APR/2014
* \arg LastModifiedOn : 10/DEC/2014
* \arg CreatededBy    : Vishnu
* \arg ModifiedBy     : Edward Rivera
* \arg Description    : Handler class for SL_Convert_Engagement page.
*/
global with sharing class SL_Clone_Engagement {
  
  @AuraEnabled
  webService static String cloneEngagement(Id engagementId) {
    Map<Id,Engagement__c> mapIdToEngagement = new Map<Id,Engagement__c>();
    try {
      Map<String, String> fieldNames = new Map<String, String>();
      Map<String, Schema.SObjectField> engagementFields = Engagement__c.getSObjectType().getDescribe().fields.getMap();
      for(SL_Convert__Field_Mapping__c objFM : [SELECT SL_Convert__Context_Field_Name__c,
                                                       SL_Convert__Target_Field_Name__c
                                                  FROM SL_Convert__Field_Mapping__c 
                                                   WHERE SL_Convert__Active__c = true 
                                                     AND SL_Convert__Object_Relationship__r.SL_Convert__Parent_Object_Relationship__c = null 
                                                     AND SL_Convert__Object_Relationship__r.SL_Convert__Context_Object_API__c = 'Engagement__c']){
        if(objFM.SL_Convert__Context_Field_Name__c != null 
            && objFM.SL_Convert__Context_Field_Name__c != '' 
            && objFM.SL_Convert__Target_Field_Name__c != null 
            && objFM.SL_Convert__Target_Field_Name__c != ''
            && engagementFields.keySet().contains(objFM.SL_Convert__Target_Field_Name__c.toLowerCase())){
            fieldNames.put(objFM.SL_Convert__Target_Field_Name__c, objFM.SL_Convert__Context_Field_Name__c);
        }
      }
          
      String strQuery = !fieldNames.isEmpty() ? String.join(fieldNames.values(), ', ') : '';
      strQuery = 'SELECT ' + strQuery + ' FROM Engagement__c WHERE Id = \'' +engagementId +'\'';          
      for(Engagement__c eng : Database.query(strQuery)){
        mapIdToEngagement.put(eng.Id, eng);
      }

      SL_Convert.SL_MappingTrigger_Handler objMappingTriggerHandler = new SL_Convert.SL_MappingTrigger_Handler();
      objMappingTriggerHandler.createSobjectRecords(mapIdToEngagement,'Engagement__c');//<! call createSobjectRecords method
      
      List<Engagement__c> newEngagement = [SELECT Id FROM Engagement__c WHERE Engagement__c =: engagementId ORDER BY CreatedDate Desc];

      if (!newEngagement.isEmpty()){
        return newEngagement[0].Id;
      }
      return engagementId;
    }
    catch (DMLException e){ 
      return 'ERROR: ' + e.getDMLMessage(0);
    }
    catch (Exception e){
      return 'ERROR: ' + e.getMessage();
    }
  }
}