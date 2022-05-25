public class BatchStaffIndustry implements Database.Batchable<sObject>,Schedulable
{
    public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([SELECT Id,Department,Industry_Group__c,Office__c FROM Contact WHERE RecordType.DeveloperName='Houlihan_Employee' AND StaffIndustryExclusion__c=false]);
   }
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact c: scope){
            c.StaffIndustry__c=StaffIndustryUtil.getStaffIndustry(c);
        }
        update scope;
    }
 
   public void finish(Database.BatchableContext BC){
   }
    
   public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchStaffIndustry());
    }
}