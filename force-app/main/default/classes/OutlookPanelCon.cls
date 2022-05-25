public with sharing class OutlookPanelCon {
    
    @AuraEnabled(cacheable=true)
    public static List<Event> getEvent(String subject,DateTime startDate, DateTime endDate){
        try {
            List<Event> eList = new List<Event>([SELECT Id,ParentId__c,Purpose__c,Product_Type__c,Industry_Group__c
                                                FROM Event 
                                                WHERE StartDateTime=:startDate 
                                                AND EndDateTime=:endDate 
                                                AND Subject=:subject]);
            List<Event> returnList = new List<Event>();
            String parentId='';
            String purpose='';
            String productType='';
            String industryGroup='';
            for(Event e : eList){
                if(String.isBlank(e.ParentId__c)){
                    purpose = e.Purpose__c;
                    productType=e.Product_Type__c;
                    industryGroup=e.Industry_Group__c;
                }
                if(String.isNotBlank(e.ParentId__c)){
                    parentId=e.ParentId__c;                    
                }
            }
            if(String.isNotBlank(parentId)){
                return new List<Event>{new Event(Id=parentId,Purpose__c=purpose,Product_Type__c=productType,Industry_Group__c=industryGroup)};
            } else{
                return new List<Event>();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}