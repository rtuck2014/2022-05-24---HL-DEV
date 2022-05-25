@isTest
public class Test_HL_JobType {
    Static String JType ;
    
    Static testMethod void validate() {
        Job_Type__c job = new Job_Type__c();
        job.Name = 'test job';
        job.Is_Active__c = true;
        job.Job_Code__c = 'Buyer';
        insert job;
        JType = 'Buyside';
        
        System.assertEquals('', HL_JobType.GetJobCode(JType));
        
        List<Job_Type__c> jobList =  HL_JobType.GetAll();
        System.assertEquals('Buyer', jobList[0].Job_Code__c);
        
        Map<String, Id> jobMap = HL_JobType.GetJobCodeMap();
        System.assertEquals(1, jobMap.Size());
        
        Map<String, Job_Type__c> jobTypeMap = HL_JobType.GetJobTypeMap();
        System.assertEquals(1, jobTypeMap.Size());
    }

}