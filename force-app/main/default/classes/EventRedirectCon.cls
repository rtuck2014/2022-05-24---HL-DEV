public with sharing class EventRedirectCon {
    public Event e {get;set;}
    public EventRedirectCon(ApexPages.StandardController con) {
        e = [SELECT Id,ParentId__c FROM Event WHERE Id=:con.getId()];
    }

    public PageReference handleRedirect(){
        if(String.isNotBlank(e.ParentId__c)){            
            PageReference pr = new PageReference('/apex/HL_ActivityEventView');
            pr.getParameters().put('Id',e.ParentId__c);
            pr.getParameters().put('nooverride','1');
            return pr;
        }else{
            PageReference pr = new PageReference('/apex/HL_ActivityEventView');
            pr.getParameters().put('Id',e.Id);
            pr.getParameters().put('nooverride','1');
            return pr;
        }
    }
}