public class HL_AdditionalClientsSubjectsController {
    public Opportunity__c Opp {get{
        if(opp == null){
            opp = [SELECT Job_Type__c, Has_Adverse_Clients__c, Internal_Team_Prompt__c, Additional_Client__c, Additional_Subject__c, Completed_Additional_Client__c, Completed_Additional_Subject__c FROM Opportunity__c WHERE Id =: EntityId];
            if(opp.Additional_Client__c == 'No')
                 NoClients();
            if(opp.Additional_Subject__c == 'No')
                NoSubjects();
        }
        return opp;
    } set;}
    public Id EntityId {get; set;}
    public List<Opportunity_Client_Subject__c> AdditionalClients {get{
        if(additionalClients == null){
            additionalClients = GetAdditionalClientsSubjectsByType('Client');
        }  
        return additionalClients;
    } set;}
    public List<Opportunity_Client_Subject__c> AdditionalSubjects {get{
        if(additionalSubjects == null)
            additionalSubjects = GetAdditionalClientsSubjectsByType('Subject');

        return additionalSubjects;
    } set;}
    
    public Id ClientToRemove{get; set;}
    public Id SubjectToRemove{get; set;}
    
    public HL_AdditionalClientsSubjectsController(){
        Map<String, String> q = ApexPages.currentPage().getParameters();
        if(q.containsKey('id'))
        	EntityId = q.get('id');
    }
    
    private List<Opportunity_Client_Subject__c> GetAdditionalClientsSubjectsByType(String type){
        List<Opportunity_Client_Subject__c> ocsList = [SELECT Client_Subject__r.Name, Client_Subject__r.BillingStreet, Client_Subject__r.BillingCity, Client_Subject__r.BillingState,Client_Subject__r.BillingPostalCode, Client_Subject__r.BillingCountry, Primary__c  FROM Opportunity_Client_Subject__c WHERE Opportunity__c =: EntityId AND Type__c =:type ORDER BY Client_Subject__r.Name];
        return ocsList;
    }
    
    public void RefreshAdditionalClients(){
        AdditionalClients = null;
        if(AdditionalClients.size() > 1 && Opp.Completed_Additional_Client__c == false){
                Opp.Completed_Additional_Client__c = true;
                update Opp;
        }
    }
    
    public void RefreshAdditionalSubjects(){
        AdditionalSubjects = null;
        if(AdditionalSubjects.size() > 1 && Opp.Completed_Additional_Subject__c == false){
                Opp.Completed_Additional_Subject__c = true;
                update Opp;
        }
    }
    
    public void RemoveClient(){
        Opportunity_Client_Subject__c removeClient;
        for(Opportunity_Client_Subject__c ocs : AdditionalClients){
            if(ocs.Id == ClientToRemove)
            {
                removeClient = ocs;
                break;
            }
        }
        if(removeClient <> null)
        {
            if (AdditionalClients.size() == 2)
            {
                Opp.Completed_Additional_Client__c = false;
                update Opp;
            }
            delete removeClient;
            AdditionalClients = null;
        }
    }
    
    public void RemoveSubject(){
        Opportunity_Client_Subject__c removeSubject;
        for(Opportunity_Client_Subject__c ocs : AdditionalSubjects){
            if(ocs.Id == SubjectToRemove)
            {
                removeSubject = ocs;
                break;
            }
        }
        if(removeSubject <> null)
        {
            if (AdditionalSubjects.size() == 2)
            {
                Opp.Completed_Additional_Subject__c = false;
                update Opp;
            }
            delete removeSubject;
            AdditionalSubjects = null;
        }
    }
    
    public void SaveOpp(){
		Opp.Completed_Additional_Subject__c = true;
        Opp.Completed_Additional_Client__c = true;
        update Opp;
    }
    
    public void NoClients(){
         opp.Additional_Client__c = 'No';
         opp.Completed_Additional_Client__c = true;
         update opp;
    }
    
    public void NoSubjects(){
        opp.Additional_Subject__c = 'No';
        opp.Completed_Additional_Subject__c = true;
        update opp;
    }
}