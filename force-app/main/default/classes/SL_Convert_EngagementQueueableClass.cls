public class SL_Convert_EngagementQueueableClass implements Queueable{
    private Id opportunityId;
    
    public SL_Convert_EngagementQueueableClass(ID idToOpp){
        this.opportunityId = idToOpp;
    }
    public void execute(QueueableContext context){
        system.debug('opportunityId-- '+opportunityId);
        list<Engagement_External_Team__c> engETList = new list<Engagement_External_Team__c>();
        List<Engagement__c>  engList = [SELECT Id, Opportunity__c FROM Engagement__c WHERE Opportunity__c =:opportunityId];
        system.debug('engList-- '+engList.size());
        list<Opportunity_External_Team__c> oppETList = [SELECT Contact__c, Opportunity__c, Type__c, Role__c, Sub_Role__c, 
                                                        Description__c, Billing_Contact__c, Acknowledge_Billing_Contact__c, 
                                                        Billing_Contact_Notes__c,  
                                                        Exclude_from_Working_Party__c, Primary__c, Id 
         												FROM Opportunity_External_Team__c WHERE Opportunity__c =:  opportunityId];
        system.debug('oppETList-- '+oppETList.size());
        for(Engagement__c e : engList ){
            for(Opportunity_External_Team__c oet : oppETList){
                Engagement_External_Team__c et = new Engagement_External_Team__c();
                et.Contact__c = oet.Contact__c;
                et.Type__c = oet.Type__c;
                et.Role__c = oet.Role__c;
                et.Sub_Role__c = oet.Sub_Role__c;
                et.Description__c = oet.Description__c;
                et.Billing_Contact__c = oet.Billing_Contact__c;
                et.Acknowledge_Billing_Contact__c = oet.Acknowledge_Billing_Contact__c;
                et.Billing_Contact_Notes__c = oet.Billing_Contact_Notes__c;
                et.Exclude_from_Working_Party__c = oet.Exclude_from_Working_Party__c ;
                et.Primary__c = oet.Primary__c;
                et.Engagement__c = e.Id;
                engETList.add(et);
            }
        }
        system.debug('engETList-- '+engETList.size());
        if(engETList.size() > 0)
        insert engETList;
    }
}