trigger HL_FinancialsTrigger on Financials__c (before insert, before update) 
{
    HL_FinancialsTriggerHandler handler= new HL_FinancialsTriggerHandler ();
    handler.FinancialValidationsbeforeinsetandupdate(trigger.new);
}