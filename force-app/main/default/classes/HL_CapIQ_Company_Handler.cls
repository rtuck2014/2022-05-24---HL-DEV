/*
* Name: HL_CapIQ_Company_Handler
* Created Date: 2/22/2020
* Description: Apex Handler class for CapIQ Company object
*/ 
public with sharing class HL_CapIQ_Company_Handler {
    public static boolean ExecuteOnce = true;
    public static boolean IsTest = false;
    private boolean IsExecuting = false;
    private integer BatchSize = 0;
    
    public HL_CapIQ_Company_Handler (boolean executing, integer size)
    {
        IsExecuting = executing;
        BatchSize = size;
    }

    public void OnAfterUpdate(List<CapIQ_Company__c> newCapIQs, List<CapIQ_Company__c> oldCapIQs, Map<Id, CapIQ_Company__c> newCapIQMap, Map<Id, CapIQ_Company__c> oldCapIQMap)
    {
        if(ExecuteOnce){

            //Set stores All modified CapIQCompany record Ids
            Set<Id> CapIQCompanyIds=new Set<Id>();
            for(CapIQ_Company__c capIQ : newCapIQMap.values()){
                if((oldCapIQMap.get(capIQ.Id).HL_Industry_Group__c != newCapIQMap.get(capIQ.Id).HL_Industry_Group__c) || (oldCapIQMap.get(capIQ.Id).HL_Sector__c != newCapIQMap.get(capIQ.Id).HL_Sector__c)){
                   CapIQCompanyIds.add(capIQ.Id);
                }
            }
            
            if(CapIQCompanyIds.size() > 0){
                UpdateInvestmentFields(CapIQCompanyIds);
            }        
            ExecuteOnce = false;
        }
    }
    
    private void UpdateInvestmentFields(Set<Id> CapIQIds){
        List<Investment__c> InvestmentList = new List<Investment__c>();
        for(Investment__c InvList : [SELECT Id, HL_Portfolio_Co_HL_Industry__c, HL_Portfolio_Co_HL_Sector__c, Portfolio_CapIQ_Company__r.HL_Industry_Group__c, Portfolio_CapIQ_Company__r.HL_Sector__c 
                                    FROM Investment__c WHERE Portfolio_CapIQ_Company__c IN :CapIQIds]){
            InvList.HL_Portfolio_Co_HL_Industry__c = InvList.Portfolio_CapIQ_Company__r.HL_Industry_Group__c;                   
            InvList.HL_Portfolio_Co_HL_Sector__c = InvList.Portfolio_CapIQ_Company__r.HL_Sector__c;
            InvestmentList.add(InvList); 
        }
        
        if(InvestmentList.size() > 0){
            Database.SaveResult[] saveResults =   Database.update(InvestmentList, true);
        }
    }
}