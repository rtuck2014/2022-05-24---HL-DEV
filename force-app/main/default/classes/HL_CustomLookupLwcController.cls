public class HL_CustomLookupLwcController {
   // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName , String whereClauseFieldName) {    
        List < sObject > returnList = new List < sObject > ();

        string sWildCardText = '%' + searchKey + '%';
        string sQuery ;
        if(String.isNotBlank(whereClauseFieldName))
            sQuery = 'Select Id,Name,'+whereClauseFieldName+ (sObjectApiName == 'Engagement__c' ? ',(Select id from Engagement_Counterparties__r)':'') +' From ' + sObjectApiName + ' Where Name Like : sWildCardText or '+whereClauseFieldName+' like :sWildCardText order by createdDate DESC LIMIT 10';
        else
            sQuery = 'Select Id,Name '+(sObjectApiName == 'Engagement__c' ? ',(Select id from Engagement_Counterparties__r)':'') +' From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 10';

        
        System.debug('sQuery'+sQuery);
        for (sObject obj: database.query(sQuery)) {
            if(sObjectApiName == 'Engagement__c'){
                Engagement__c inx = (Engagement__c)obj;
               // System.debug('inx.Engagement_Counterparties__r.size()'+inx.Engagement_Counterparties__r.size());
                /*if(inx.Engagement_Counterparties__r.size()>0){
                    returnList.add(obj);
                }*/
                boolean moreThanOne = false;
                for(Engagement_Counterparty__c ind: inx.Engagement_Counterparties__r){
                    moreThanOne = true;
                    break;
                }
                if(moreThanOne){
                    returnList.add(obj);
                }
            }else{
                returnList.add(obj);
            }
            
        }
        system.debug(returnList.size());
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName ,  String whereClauseFieldName) {
        string sRecId = recordId;    
        string sQuery;
        if(String.isNotBlank(whereClauseFieldName))
            sQuery = 'Select Id,Name,'+whereClauseFieldName+' From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        else
            sQuery = 'Select Id,Name  From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
    
    
}