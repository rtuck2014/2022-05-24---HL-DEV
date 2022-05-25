public class HL_DebtStructureController {
    public Id RecordId {get; set;}
    public Id EngagementId {get; set;}
    public Integer Action {get; set;}
    public enum ControllerAction{
        PreTransactionDebtStructure,
        PostTransactionDebtStructure
    }
    public Debt_Structure__c DebtStructure {get{
        if(debtStructure == null){
            if(RecordId <> null)
                debtStructure = [SELECT Amoritization__c, Call_Provisions_Prepayment_Premiums__c, Constituent_Debt__c, Covenants__c, Engagement__c, Facility_Balance_MM__c, Fees_Expenses__c, Interest__c, Mandatory_Prepayments_ECF_Sweep__c, Maturity_Date__c, OID_Percent__c, Pre_Post_Transaction__c, Security_Type__c FROM Debt_Structure__c WHERE Id =: recordId LIMIT 1];
            else
                debtStructure = new Debt_Structure__c();
        }
        return debtStructure;
    } set;}
    
     public List<Engagement_Client_Subject__c> Lenders {get {
            if(lenders == null && RecordId <> null)
                lenders = [SELECT Client_Subject__r.Id, Client_Subject__r.Name, Loan_Amount__c FROM Engagement_Client_Subject__c WHERE Other_Related_Object_Id__c =: RecordId AND Type__c =: 'Key Creditor' ORDER BY Client_Subject__r.Name];
            
            return lenders;
        } set;}
    
	public HL_DebtStructureController(){
        Map<String, String> q = ApexPages.currentPage().getParameters();
        if(q.containsKey('id'))
        	RecordId = q.get('id');
        EngagementId = q.get('eng');
        Action = Integer.valueOf(q.get('action'));
    }
    
    public void RefreshLenders(){
        Lenders = null;
    }
    
    public void Save(){
        try{
            if(DebtStructure.Engagement__c == null)
            {
            	DebtStructure.Engagement__c = EngagementId;
                DebtStructure.Pre_Post_Transaction__c = Action == 1 ? 'Pre-Transaction' : 'Post-Transaction'; 
            }
			          
            upsert DebtStructure;
            RecordId = DebtStructure.Id;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Record Saved'));
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
    }
}