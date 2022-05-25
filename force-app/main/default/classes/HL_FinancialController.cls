public class HL_FinancialController {
	public Id RecordId {get; set;}
    public Id ApprovalId {get; set;}
    public Id SubjectId {get; set;}
    public string CurrencyISO {get; set;}
    public Financials__c Financial {get{
        if(financial == null){
            if(RecordId <> null)
                financial = [SELECT Related_Approval__c, Related_Account__c, Assets_Under_Management__c, Book_Value_MM__c, EBIT_MM__c,  EBITDA__c, Face_Value_MM__c, Interest_and_Fee_Income__c, Net_Asset_Value_MM__c, Number_of_Companies__c, Number_of_Loans__c, Number_of_Interests__c, Number_of_Policies__c, Pre_Tax_Income__c,  Revenue_MM__c, Type__c, Year__c, CurrencyIsoCode FROM Financials__c WHERE Id =: recordId LIMIT 1];
            else
                financial = new Financials__c(Related_Approval__c = ApprovalId, Related_Account__c = SubjectId, CurrencyIsoCode = CurrencyISO);
        }
        return financial;
    } set;}
    public HL_FinancialController(){
        RecordId = HL_PageUtility.GetParameter('id');
        ApprovalId = HL_PageUtility.GetParameter('oa');
        SubjectId = HL_PageUtility.GetParameter('subject');
        CurrencyISO = HL_PageUtility.GetParameter('currencyISO');
    }
    public void Save(){
        try{        
            upsert Financial;
            RecordId = Financial.Id;
            HL_PageUtility.ShowConfirm('Record Saved');
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
    }
}