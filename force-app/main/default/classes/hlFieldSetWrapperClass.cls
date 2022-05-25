public with sharing class hlFieldSetWrapperClass {
    @AuraEnabled  public boolean hideDefaultActions {get;set;}
    @AuraEnabled  public string label {get;set;}
    @AuraEnabled  public string fieldName {get;set;}
    @AuraEnabled  public string type {get;set;}
    @AuraEnabled  public TypeAttributes typeAttributes {get;set;}
    @AuraEnabled  public boolean editable {get;set;}
    @AuraEnabled  public boolean sortable {get;set;}
    public class TypeAttributes {
        @AuraEnabled  public string tooltip {get;set;}
        @AuraEnabled  public string target {get;set;}
        @AuraEnabled  public Label label {get;set;}
    }
    
    public class Label{
        @AuraEnabled  public string fieldName {get;set;}
    }
}