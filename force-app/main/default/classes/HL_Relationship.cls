public with sharing class HL_Relationship {
    public static final string STANDARD_SELECT = 'SELECT Contact_Status__c, Last_Activity_Date__c, Number_of_Activities_LTM__c, Personal_Note__c, Outlook_Categories__c, Share_Active_Deal__c, Share_Open_Opp__c, Strength_Rating__c, Sync_to_Outlook__c, Type__c, External_Contact__c, External_Contact__r.Name, HL_Contact__c, HL_Contact__r.Name ';
    
    @AuraEnabled
    public static Relationship__c GetById(Id id){
        List<Relationship__c> r = [SELECT Id, HL_Contact__c FROM Relationship__c WHERE Id=:id];
        return r.size() > 0 ? r[0] : new Relationship__c();
    }
    //Returns a List of Contact Ids by User Relationship
    //Must be a List return type For AuraEnabled Property(Although a Set is preferred, not allowed at this time)
	@AuraEnabled
    public static List<Id> GetContactRelationshipsByUser(Id userId){
      List<Id> relIds = new List<Id>();
      for(Relationship__c r : [SELECT External_Contact__c
                               FROM Relationship__c 
                               WHERE HL_Contact__c =:userId OR HL_Contact__r.User__c =:userId])
          relIds.Add(r.External_Contact__c);
      return relIds;
  }
  //Returns a List of Company Ids by User Relationship
  //Must be a List return type for AuraEnabled Property(Although a Set is preferred, not allowed at this time)
  @AuraEnabled
  public static List<Id> GetCompanyRelationshipsByUser(Id userId){
      List<Id> relIds = new List<Id>();
      for(Relationship__c r : [SELECT External_Contact__r.Account.Id
                               FROM Relationship__c 
                               WHERE HL_Contact__c =:userId OR HL_Contact__r.User__c =:userId])
          relIds.Add(r.External_Contact__r.Account.Id);
      return relIds;
  }
    
  //Checks if the Relationship Exists Between the Employee and External Contact
  @AuraEnabled
  public static Boolean DoesExist(Id empId, Id contactId){
        return ([SELECT Id FROM Relationship__c WHERE HL_Contact__c =: empId AND External_Contact__c =: contactId]).size() > 0;
  }

  @AuraEnabled
  public static Relationship__c GetByEmployeeAndContact(Id empId, Id contactId){
        List<Relationship__c> rel = [SELECT Strength_Rating__c, Type__c, Personal_Note__c, Outlook_Categories__c, Sync_to_Outlook__c FROM Relationship__c WHERE HL_Contact__c =: empId AND External_Contact__c =: contactId LIMIT 1];
        return rel.size() > 0 ? rel[0] : new Relationship__c();
  }

  @AuraEnabled 
  public static void UpdateRelationship(Id empId, Id contactId, string rating, string type, string description, string outlookCategories, boolean sync){
       Relationship__c rel = [SELECT Strength_Rating__c, Type__c, Personal_Note__c, Outlook_Categories__c,  Sync_to_Outlook__c FROM Relationship__c WHERE HL_Contact__c =: empId AND External_Contact__c =: contactId LIMIT 1];
       rel.Strength_Rating__c = rating;
       rel.Type__c = type;
       rel.Personal_Note__c = description;
       rel.Outlook_Categories__c = outlookCategories;
       rel.Sync_to_Outlook__c = sync;
       update rel;
  }
  
  @AuraEnabled
  public static void SaveRelationship(Id empId, Id contactId, String rating, String type, String description, String outlookCategories, boolean sync){
        Relationship__c rel = new Relationship__c(External_Contact__c = contactId, HL_Contact__c = empId, Strength_Rating__c = rating, Type__c = type, Personal_Note__c = description, Outlook_Categories__c = outlookCategories, Sync_to_Outlook__c = sync);
        insert rel;
  }
  
  @AuraEnabled
  public static List<Contact> GetDefaultContact(){
        return new List<Contact> {HL_Contact.GetByUserId(UserInfo.getUserId())};
  }
  
  //Determine if the user has full access (used for the private note)
  @AuraEnabled
    public static Boolean HasFullAccess(Id Id, Id userId){
        Set<Id> access = new Set<Id>{userId};
        Relationship__c r = GetById(id);
        //Get the Supervisors to provide appropriate rights
        for(Delegate_Public_Group__c dpg : HL_DelegatePublicGroup.GetSupervisors())
            access.add(dpg.Banker__c);
        return HL_SecurityUtility.IsSysAdmin() || access.contains(HL_Contact.GetById(r.HL_Contact__c).User__c);
    }
}