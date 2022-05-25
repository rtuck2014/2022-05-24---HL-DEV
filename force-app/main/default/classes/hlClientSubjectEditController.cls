public with sharing class hlClientSubjectEditController {
    public Engagement_Client_Subject__c engVP {get;set;} 
    public string engVPId {get;set;}
    public String jobType {get;set;}
    public Static Boolean successMsg{get;set;}
    public Engagement__c eng {get;set;}
    
    public hlClientSubjectEditController(ApexPages.StandardController controller) {
        engVP=new Engagement_Client_Subject__c();
        engVP= (Engagement_Client_Subject__c)controller.getRecord();  
        engVPId=apexpages.currentpage().getparameters().get('eid');
        eng = [Select Id,Job_Type__c,Name from Engagement__c Where Id =: engVPId];
        jobType = eng.Job_Type__c;
        successMsg=false;
    }
    public PageReference redirectToNew(){
        String dId = [SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName ='Engagement_Client_Subject__c'].DurableId;
        PageReference pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent='+dId);
        pr.getParameters().put('nooverride', '1');
        pr.getParameters().put('save_new_url','/a0T/e?CF00Ni000000D9DbX='+eng.Name+'&CF00Ni000000D9DbX_lkid='+eng.Id);
        pr.getParameters().put('isdtp','vw');
        pr.getParameters().put('retURL','/apex/HL_ClientSubjectEdit?eid='+engVPId);
        //pr.getParameters().put('cancelURL','/apex/HL_OppClientSubjectEdit?eid='+engVPId);
        pr.getParameters().put('saveURL','/apex/HL_ClientSubjectEdit?eid='+engVPId);
        pr.setRedirect(true);
        return pr;
    }
    
    @AuraEnabled(Cacheable=true)
    public static list<hlFieldSetWrapperClass> getFieldSet(String recordId){
        list<hlFieldSetWrapperClass> fieldSetWrapperList = new list<hlFieldSetWrapperClass>();
        list<Schema.FieldSetMember> fieldetList = new list<Schema.FieldSetMember>();
        Id sId =Id.valueOf(recordId);
        String soobjectType = sId.getSObjectType().getDescribe().getName();
        system.debug(soobjectType);
        if(soobjectType != 'Opportunity__c'){
            fieldetList = SObjectType.Engagement_Client_Subject__c.FieldSets.EngagementClientFiedset.getFields();
        }  
        else{
            fieldetList = SObjectType.Opportunity_Client_Subject__c.FieldSets.OpportunityClientSubjectFieldSet.getFields();
        }       
        for(Schema.FieldSetMember fm : fieldetList){
            hlFieldSetWrapperClass f = new hlFieldSetWrapperClass();
            if(fm.getFieldPath() == 'Name'){                
               f.hideDefaultActions = true;
                f.label = 'Name';
                f.fieldName = 'recordlink';
                f.type = 'url';
                hlFieldSetWrapperClass.Label labelcls = new hlFieldSetWrapperClass.Label();
                labelcls.fieldName = 'Name';
                
                hlFieldSetWrapperClass.TypeAttributes tAttr = new  hlFieldSetWrapperClass.TypeAttributes();
                tAttr.tooltip = 'Name';
                tAttr.target = '_blank';
                tAttr.label = labelcls;
                
                f.typeAttributes = tAttr ;
            }
            else{
                f.hideDefaultActions = true;
                f.label = fm.getLabel();
                f.fieldName = fm.getFieldPath();
                f.editable = true;
                f.sortable = true;
            }
           fieldSetWrapperList.add(f); 
        }
        return fieldSetWrapperList;
    }

    @AuraEnabled(Cacheable=true)
    public static list<hlFieldSetWrapperClass> getFieldSetForTotalTable(String recordId){
        list<hlFieldSetWrapperClass> fieldSetWrapperList = new list<hlFieldSetWrapperClass>();
        list<Schema.FieldSetMember> fieldetList = new list<Schema.FieldSetMember>();
        Id sId =Id.valueOf(recordId);
        String soobjectType = sId.getSObjectType().getDescribe().getName();
        system.debug(soobjectType);
        if(soobjectType != 'Opportunity__c'){
            fieldetList = SObjectType.Engagement_Client_Subject__c.FieldSets.EngagementClientFiedset.getFields();
        }  
        else{
            fieldetList = SObjectType.Opportunity_Client_Subject__c.FieldSets.OpportunityClientSubjectFieldSet.getFields();
        }       
        for(Schema.FieldSetMember fm : fieldetList){
            hlFieldSetWrapperClass f = new hlFieldSetWrapperClass();        
                f.hideDefaultActions = true;
                f.label = fm.getLabel();
                f.fieldName = fm.getFieldPath();
                f.editable = false;
                f.sortable = false;
                fieldSetWrapperList.add(f); 
        }
        return fieldSetWrapperList;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List <sObject> getEngClientSub(String recordId) {
        list<Schema.FieldSetMember> fieldetList = new list<Schema.FieldSetMember>();
        Id sId =Id.valueOf(recordId);
        String soobjectType = sId.getSObjectType().getDescribe().getName();
        system.debug(soobjectType);
        if(soobjectType != 'Opportunity__c'){
           fieldetList = SObjectType.Engagement_Client_Subject__c.FieldSets.EngagementClientFiedset.getFields();
        }
        else{
            fieldetList = SObjectType.Opportunity_Client_Subject__c.FieldSets.OpportunityClientSubjectFieldSet.getFields();
        }
        String queryStr = 'SELECT Id';
        for(Schema.FieldSetMember f : fieldetList){
            queryStr = queryStr + ' ,'+f.getFieldPath();
        }       
        if(soobjectType != 'Opportunity__c'){
            Decimal totalPer = 0.0;
            queryStr = queryStr + ' FROM Engagement_Client_Subject__c WHERE Engagement__c = \''+ recordId+'\' LIMIT 1000'
                ;
            List<Engagement_Client_Subject__c> ec =  Database.query(queryStr);
            for(Engagement_Client_Subject__c e : ec){
                if( e.CreditorRevenueAllocationPercentage__c != null)
                    totalPer = totalPer + e.CreditorRevenueAllocationPercentage__c;
            }
            Engagement_Client_Subject__c eClient = new Engagement_Client_Subject__c();
            eClient.Type__c =  'Total';
            eClient.CreditorRevenueAllocationPercentage__c = totalPer;
            ec.add(eClient);
            return ec;
        }   
        else{
            queryStr = queryStr + ' FROM Opportunity_Client_Subject__c WHERE Opportunity__c = \''+ recordId+'\' LIMIT 1000';
        }
        system.debug('query-- '+queryStr);
        return Database.query(queryStr);
    } 
    
    @AuraEnabled
    public static DeleteWrapClass deleteRecord(list<Id> lstIds, String objectApiName){
        DeleteWrapClass dc = new DeleteWrapClass();
        try {
            if(objectApiName == 'Engagement_Client_Subject__c'){
            list<Engagement_Client_Subject__c> lstEngSubToDelete = [Select Id From Engagement_Client_Subject__c 
                                                                    Where Id IN:lstIds];
            System.debug('lstIds ====> '+lstIds);
            if(!lstEngSubToDelete.isEmpty()) {
                delete lstEngSubToDelete;
            }
            }else{
                list<Opportunity_Client_Subject__c> lstOppSubToDelete = [Select Id From Opportunity_Client_Subject__c 
                                                                    Where Id IN:lstIds];
                System.debug('lstIds ====> '+lstIds);
                if(!lstOppSubToDelete.isEmpty()) {
                    delete lstOppSubToDelete;
                }
            }
            
            dc.status = true;
            return dc;
        }
        catch(Exception ex) {
            //throw new AuraHandledException(ex.getMessage());
            dc.status = false;
            dc.errMsg = ex.getMessage();
            return dc;
        }
    }

    public class DeleteWrapClass {
        @AuraEnabled public Boolean status;
        @AuraEnabled public String errMsg;
    }
}