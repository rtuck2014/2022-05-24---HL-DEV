global class SharingSetupForEngVP_HistoricalRecords implements Database.Batchable<sObject>{

   global final String Query;  

   global SharingSetupForEngVP_HistoricalRecords(String q){

      Query= q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Eng_VP__c> EngVPRecords){     
       HL_Eng_VP_TriggerHelper.SetupSharingforEngVp(EngVPRecords);
   }

   global void finish(Database.BatchableContext BC){
   }
}