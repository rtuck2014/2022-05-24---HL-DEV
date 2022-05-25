@isTest
public class ErrorHandlingUtilityTest {

    @isTest
    public static void handleExceptionsTest(){
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(exception ex){
            ErrorHandlingUtility.logException(null, ex);
        }
        
        Account acc1 = new Account();
        try{
            insert acc1;
        }
        catch(dmlException ex){
            ErrorHandlingUtility.logException(ex, null);
        }
        
        Account acc2 = new Account();
        List<Account> accList= new List<Account>();
        accList.add(acc2);
        Database.SaveResult[] saveResults = Database.insert(accList,false);
        ErrorHandlingUtility.handleDatabaseSaveResults(saveResults, 'ErrorHandlingUtilityTest');
    }
}