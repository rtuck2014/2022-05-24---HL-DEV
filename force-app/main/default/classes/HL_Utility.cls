public without sharing class HL_Utility {
    public static Map<String, Decimal> GetConversionMap(){
		Map<String, Decimal> conversionMap = new Map<String, Decimal>();
		for(CurrencyType ct : [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = true])
			conversionMap.put(ct.IsoCode, ct.ConversionRate);
		return conversionMap;
	}
    
	@AuraEnabled
    public static List<String> GetPicklistValues(String ObjectApi_Name,String Field_Name){ 
          return GetPicklistValues(ObjectApi_Name, Field_Name, null);
    }
    @AuraEnabled
    public static List<String> GetPicklistValues(String ObjectApi_Name, String Field_Name, String RecordTypeId){
         List<String> lstPickvals=new List<String>();
          //From the Object Api name retrieving the SObject
          Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_Name);
          Sobject Object_Name = targetType.newSObject();
          if(RecordTypeId <> null)
              Object_Name.put('RecordTypeId', RecordTypeId);
          //Grab the sobject that was passed
          Schema.sObjectType sobject_type = Object_Name.getSObjectType(); 
          //Describe the sobject
          Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
          //Get a map of fields for the passed sobject
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
          //Grab the list of picklist values for the passed field on the sobject
          List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_Name).getDescribe().getPickListValues();
          //For all values in the picklist list
          for (Schema.PicklistEntry a : pick_list_values)  
              lstPickvals.add(a.getValue());//Add the value  to our final list
          
        return lstPickvals;
    }

    public static Schema.FieldSet GetFieldSet(string sObjectName, string fieldSetName){
    	return GetFieldSet(Schema.getGlobalDescribe(), sObjectName, fieldSetName);
    }
    public static Schema.FieldSet GetFieldSet(Map<String, Schema.SObjectType> mapGlobalDescribe, string sObjectName, string fieldSetName){
    	return mapGlobalDescribe.get(sObjectName).getDescribe().FieldSets.getMap().get(fieldSetName);
    }
    
    //Defaults to Contact - Would like to remove/get rid of this when we have time to find references
    @AuraEnabled
    public static Id GetRecordTypeId(String recordType)
    {
        return GetRecordTypeId('Contact', recordType);
    }
    @AuraEnabled
    public static Id GetRecordTypeId(String sObjectType, String recordType){
        if(sObjectType == 'Engagement_External_Team__c')
            return Schema.SObjectType.Engagement_External_Team__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if(sObjectTYpe == 'Coverage_Team__c')
            return Schema.SObjectType.Coverage_Team__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if(sObjectType == 'Opportunity__c')
            return Schema.SObjectType.Opportunity__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if(sObjectType == 'Offsite_Template__c')
        	return Schema.SObjectType.Offsite_Template__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();

        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
    }

    @AuraEnabled
    public static Integer MobileDefault(){
    	return (Integer)HL_General__c.getOrgDefaults().Mobile_Search_Result_Default__c;
    }

    @AuraEnabled
    public static Integer MobileLimit(){
    	return (Integer)HL_General__c.getOrgDefaults().Mobile_Search_Result_Limit__c;
    }
    
    public static String GetObjectTypeById(Id value)
    {
        return !String.isBlank(value) ? value.getSObjectType().getDescribe().getName() : '';
    }

    public static string GenerateGUID(){
      Blob b = Crypto.GenerateAESKey(128);
      String h = EncodingUtil.ConvertTohex(b);
      return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

    //Standard Select Options
    public static List<SelectOption> SearchSelectOptions(){
        return new List<SelectOption> {new SelectOption('Starts With','Starts With'), new SelectOption('Contains', 'Contains')};
    }
    

    //Deprecated: Please use our HL_SecurityUtility for these
    //These will be removed once all references have been changed 
    public static Boolean HasProfile(string profile){
        return HL_SecurityUtility.HasProfile(profile);
    }
    //Deprecated: Please use our HL_SecurityUtility for these
    //Profile Related Checks
    public static Boolean IsCAO(){
        return HL_SecurityUtility.IsCAO();
    }
    //Deprecated: Please use our HL_SecurityUtility for these
    public static Boolean IsSysAdmin(){
        return HL_SecurityUtility.IsSysAdmin();
    }
}