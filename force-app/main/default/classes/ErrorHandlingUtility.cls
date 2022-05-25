/**
Name                : ErrorHandlingUtility
Author              : Kishan
Functionality       : Utility class to insert Error Log records when any runtime exceptions generated
Created             : 10/04/2019
*/
public without sharing class ErrorHandlingUtility {
    
    public static void logException(DMLException dmlException, Exception ex){
        List<Error_Log__c> exceptionLogs = new List<Error_Log__c>();
        if(dmlException != null){
            exceptionLogs.add(buildExceptionLog(dmlException, null));
        }
        if(ex != null){
            exceptionLogs.add(buildExceptionLog(null, ex));            
        }
        if(!exceptionLogs.isEmpty()){
            insertExceptionLogs(exceptionLogs);
        }        
    }
    
    public static Error_Log__c buildExceptionLog(DMLException dmlEx, Exception ex){
        Error_Log__c log = new Error_Log__c();
        String stackTrace = '';
        String exMessage = '';
        Integer startPoint = -1;
        
        if(dmlEx != null){
            log.Record_Id__c = dmlEx.getDMLId(0);
            exMessage = dmlEx.getMessage();
            stackTrace = dmlEx.getStackTraceString();
            log.Exception_Details__c = stackTrace;
            log.Exception_Description__c = exMessage;
        }else if(ex != null){
            log.Record_Id__c = '';
            exMessage = ex.getMessage();
            if(exMessage != null){
                log.Exception_Description__c = exMessage.left(255);
            }
            stackTrace = ex.getStackTraceString();
            log.Exception_Type__c = ex.getTypeName();
            log.Stack_Trace__c = stackTrace;
            log.Exception_Details__c = ex.getTypeName() + ': ' + exMessage + '\n' + stackTrace.left(32768);
        }
        if(stackTrace != null){
            if(stackTrace.indexOf('Class.') > -1){
                String classException = stackTrace.substring(stackTrace.indexOf('Class.') + 6,stackTrace.indexOf('column'));
                log.Class_Name__c = classException.substring(0,classException.indexOf('.'));
            }
        }
        return log;
    }
    public static void handleDatabaseSaveResults(List<Database.SaveResult> saveResults, String className)
    {
        List<Error_Log__c> exceptionLogs = new List<Error_Log__c>();
        for(Database.SaveResult saveResultRecord : saveResults)
        {
            if(!saveResultRecord.isSuccess())
            {
                for(Database.Error err : saveResultRecord.getErrors())
                {
                    Error_Log__c log = new Error_Log__c();
                    System.debug('recordId>>>'+saveResultRecord.getId());
                    log.Record_Id__c = saveResultRecord.getId();
                    log.Exception_Description__c = err.getMessage();
                    log.Exception_Details__c = 'Status Code: '+String.valueOf(err.getStatusCode()) + ', Fields causing error: ' + err.getFields();
                    log.Class_Name__c = className;
                    exceptionLogs.add(log);
                }      
            }
        }
        if(exceptionLogs.size() > 0){
            insertExceptionLogs(exceptionLogs);
        }
    }
    
    public static void insertExceptionLogs(List<Error_Log__c> exceptionLogs){
        try{
            if(!exceptionLogs.isEmpty()){
                Database.insert(exceptionLogs,false);
            }
        }
        catch(exception ex){
            system.debug('exception>>>'+ex.getMessage());
        }
    }
}