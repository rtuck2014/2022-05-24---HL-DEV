public with sharing class HL_EmailTemplate {
  public static Email_Template__c GetByName(string templateName){
    List<Email_Template__c> templateList = [SELECT Name, Additional_Distribution_Group__c, Distribution_Group__c, Email_Subject__c, Related_Object__c, Template_Body__c FROM Email_Template__c WHERE Name =: templateName];
    return templateList.size() > 0 ? templateList[0] : new Email_Template__c();
  }
}