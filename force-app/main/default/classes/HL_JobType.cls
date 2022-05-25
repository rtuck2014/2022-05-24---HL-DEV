/*
* Name: HL_JobType
* Created Date: 4/17/2015
* Description: Apex handler for Job_Type__c object
* Modified Date: 11/04/2019
* Description: Modified GetJobTypeMap() to retreive the following fields:
*              Product_Line__c, Product_Type__c, Product_Type_Code__c
*/

public class HL_JobType {
    private static Map<String, Job_Type__c> mapJobType;
    private static Map<String, Id> mapJobCode;

    static {
        mapJobType = new Map<String, Job_Type__c>();
        mapJobCode = new Map<String, Id>();

        for (Job_Type__c jobType : [
            SELECT Id, Name, Job_Code__c, Product_Line__c, Has_Multiple_Deliverables__c, 
            Is_Active__c, Product_Type__c, Product_Type_Code__c 
            FROM Job_Type__c]) {

            mapJobType.put(jobType.Name, jobType);
            mapJobCode.put(jobType.Name, jobType.Id);
        }
    }

    public static String GetJobCode(String jobType) {
        Job_Type__c jt = mapJobType.get(jobType);

        return (jt != null) ? jt.Job_Code__c : '';

        //List<Job_Type__c> jt = [SELECT Job_Code__c FROM Job_Type__c WHERE Name=:jobType LIMIT 1];
        //return jt.size() > 0 ? jt[0].Job_Code__c : '';
    }
    
    public static List<Job_Type__c> GetAll() {
        return mapJobType.values();

        //return [SELECT Name, Job_Code__c FROM Job_Type__c];
    }

    public static Map<String, Id> GetJobCodeMap() {
        return mapJobCode;
    }

    public static Map<String, Job_Type__c> GetJobTypeMap() {
        return mapJobType;
    }

    // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
/*    
    //This Map returns the Job Type Name with the Job Code
    public static Map<String, Id> GetJobCodeMap(){
         List<Job_Type__c> jobTypes = GetAll();
         Map<String, Id> mapJobCode = new Map<String, Id>();
         for(Job_Type__c jt : jobTypes)
                mapJobCode.put(jt.Name, jt.Id);
        return mapJobCode;
    }
*/    

    // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
/*
    //This Map returns the job type name and the Job Type sObject
    public static Map<String, Job_Type__c> GetJobTypeMap(){
         Map<String, Job_Type__c> mapJobType = new Map<String, Job_Type__c>();
         for (Job_Type__c jobType : [SELECT Id, Name, Job_Code__c,Product_Line__c, Has_Multiple_Deliverables__c, Is_Active__c, Product_Type__c, Product_Type_Code__c FROM Job_Type__c])
             mapJobType.put(jobType.Name, jobType);
        return mapJobType;
    }
*/    
}