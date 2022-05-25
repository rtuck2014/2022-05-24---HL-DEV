public with sharing class HL_Financials {
    public static List<Financials__c> GetByOpportunityApproval(Id id){
       return [SELECT Financials__c.Name, Type__c, Year__c, Revenue_MM__c, EBIT_MM__c, EBITDA__c, Pre_Tax_Income__c, Book_Value_MM__c, Assets_Under_Management__c, Interest_and_Fee_Income__c FROM Financials__c WHERE Related_Approval__c =: id];
    }
}