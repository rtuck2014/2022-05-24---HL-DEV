public with sharing class HL_SaleTransactionController {
    public Id RecordId {get; set;}
    public Id EngagementId {get; set;}
   
    public Sale_Transaction__c SaleTransaction {get{
        if(saleTransaction == null){
            if(RecordId <> null)
                saleTransaction = [SELECT Name, Break_Up_Fee__c, Cash_Component__c, Claim_Conversion__c, Date_of_Sale__c, Deposit__c, Engagement__c, Incremental_Overbid__c, Liability_Assumed__c, Minimum_Overbid__c, Stock_Component__c, Total_Sales_Price__c FROM Sale_Transaction__c WHERE Id =: RecordId LIMIT 1];
            else
                saleTransaction = new Sale_Transaction__c(Engagement__c = EngagementId);
        }
        return saleTransaction;
    } set;}

	public HL_SaleTransactionController(){
        Map<String, String> q = ApexPages.currentPage().getParameters();
        if(q.containsKey('id'))
        	RecordId = q.get('id');
        EngagementId = q.get('eng');
    }
    
    
    public void Save(){
        try{        
            upsert SaleTransaction;
            RecordId = SaleTransaction.Id;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Record Saved'));
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
    }
}