public class HL_OpportunityClientSubjectController {
    public String RecordId {get; set;}
    public Id OpportunityId {get; set;}
    public Integer Action {get; set;}
    public String PEOwnsHighPercent {get; set;}
    public enum ControllerAction{
        AddClientSubject,
        AddCounterparty,
        ModifyClientSubject,
        ModifyCounterparty
    }
    public Opportunity_Client_Subject__c ClientSubject {get{
        if(clientSubject == null){
            if(RecordId <> null)
            {
                List<Opportunity_Client_Subject__c> clientSubjects = [SELECT Client_Subject__c, Client_Subject__r.Name, Does_PE_Own_High_Percent__c, ESOP__c, Financial_Advisors__c, Insiders__c, Market_Cap_MM__c, NFP__c, Opportunity__c, Other_Financial_Advisor_Services__c, Other_Related_Object_Id__c, Outside_Counsel__c, Ownership__c, Public_Or_Private__c, Primary__c, Private_Equity_Ownership__c, Type__c FROM Opportunity_Client_Subject__c WHERE Id =: recordId];
                if(clientSubjects.size() > 0)
                    clientSubject = clientSubjects[0];
                else
                    clientSubject = new Opportunity_Client_Subject__c();
            }
            else
                clientSubject = new Opportunity_Client_Subject__c();
        }
        return clientSubject;
    } set;}
    public List<Opportunity_Client_Subject__c> PEFirms {get{
        if(peFirms == null && RecordID <> null)
            peFirms = [SELECT Client_Subject__c, Client_Subject__r.Name, Private_Equity_Ownership__c, Public_Or_Private__c FROM Opportunity_Client_Subject__c WHERE Other_Related_Object_Id__c =: RecordId ORDER BY Client_Subject__r.Name];
        
        return peFirms;
    } set;}
    
    public HL_OpportunityClientSubjectController(){
        Map<String, String> q = ApexPages.currentPage().getParameters();
        if(q.containsKey('id'))
            RecordId = q.get('id');
        OpportunityId = q.get('opp');
        Action = Integer.valueOf(q.get('action'));
    }
    
    public void TogglePEFirms(){
        System.Debug(ClientSubject.Does_PE_Own_High_Percent__c);
    }
    
    public void PrelimSave(){
        Save('');
    }
    
    public void Save(){
        Save('Save Successful');
    }
    
    private void Save(String successMsg){
        try{
            if(ClientSubject.Opportunity__c == null)
            {
                ClientSubject.Opportunity__c = OpportunityId;
                ClientSubject.Type__c = Action == 1 || Action == 3 ? 'Subject' : 'Contra';
            }
            upsert ClientSubject;
            RecordId = ClientSubject.Id;
            if(!String.IsBlank(successMsg))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,successMsg));
        }
        catch(DmlException ex){
                ApexPages.addMessages(ex);
        }
    }
    
    public void RefreshPEFirms(){
        PEFirms = null;
    }
}