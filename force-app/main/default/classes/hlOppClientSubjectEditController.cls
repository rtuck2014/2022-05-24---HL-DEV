public class hlOppClientSubjectEditController {
	public Opportunity_Client_Subject__c engVP {get;set;} 
    public string engVPId {get;set;}
    public String jobType {get;set;}
    public Static Boolean successMsg{get;set;}
    public String retUrl {get;set;}
    public Opportunity__c eng {get;set;}
    public hlOppClientSubjectEditController(ApexPages.StandardController controller) {
        engVP=new Opportunity_Client_Subject__c();
        engVP= (Opportunity_Client_Subject__c)controller.getRecord();  
        engVPId=apexpages.currentpage().getparameters().get('eid');
        eng = [Select Id,Job_Type__c,Name from Opportunity__c Where Id =: engVPId];
        jobType = eng.Job_Type__c;
        successMsg=false;
    }

    public PageReference redirectToNew(){
        String dId = [SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName ='Opportunity_Client_Subject__c'].DurableId;
        PageReference pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent='+dId);
        pr.getParameters().put('nooverride', '1');
        pr.getParameters().put('save_new_url','/a0U/e?CF00Ni000000DuhQp='+eng.Name+'&CF00Ni000000DuhQp_lkid='+eng.Id);
        pr.getParameters().put('isdtp','vw');
        pr.getParameters().put('retURL','/apex/HL_OppClientSubjectEdit?eid='+engVPId);
        //pr.getParameters().put('cancelURL','/apex/HL_OppClientSubjectEdit?eid='+engVPId);
        pr.getParameters().put('saveURL','/apex/HL_OppClientSubjectEdit?eid='+engVPId);
        return pr;
    }
}