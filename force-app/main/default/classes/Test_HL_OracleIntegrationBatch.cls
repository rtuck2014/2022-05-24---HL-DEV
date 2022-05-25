@isTest
public class Test_HL_OracleIntegrationBatch {
    
    static testMethod void testMethod1() 
    {       
        List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
            for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;       
        

        String apiName = 'Account';
        String whereClause = 'id!=null';
        Test.startTest();
			
            HL_OracleIntegrationBatch obj = new HL_OracleIntegrationBatch(apiName,whereClause);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }

}