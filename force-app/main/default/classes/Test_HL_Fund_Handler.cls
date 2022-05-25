@isTest
private class Test_HL_Fund_Handler {
    @isTest private static void TestInsertOneFundToOpportunity(){
         //TODO: Move into SL_TestSetupUtils once we create appropriate functions
         CapIQ_Company__c cc = new CapIQ_Company__c();
         insert cc;    
         Fund__c existingFund = new Fund__c(CapIQ_Company__c = cc.Id);
         insert existingFund;
         List<Fund__c> funds = new List<Fund__c>();
         for(Integer i=0; i<5; i++)
            funds.add(New Fund__c(CapIQ_Company__c = cc.Id));
         insert funds;
         //Create an existing fund to fully test logic
         existingFund.Latest__c = true;
         update existingFund;
        
         for(Integer i=0; i<funds.size(); i++){
            funds[i].Size__c = i;
            if(i==4)
            	funds[i].Latest__c = true;  
        }
        
        update funds;
        cc = [SELECT Id, Most_Recent_Fund_Size_MM__c FROM CapIQ_Company__c WHERE Id =:cc.Id];
        
        //Validate the Most Recent Fund Size has been updated appropriately
        System.assert(cc.Most_Recent_Fund_Size_MM__c == funds.size() - 1);
        System.assert(funds[0].Latest__c == false);
        System.assert(funds[funds.size() - 1].Latest__c == true);
    }
}