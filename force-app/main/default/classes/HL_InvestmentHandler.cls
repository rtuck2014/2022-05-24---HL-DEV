/*
* Name: HL_InvestmentHandler  
* Created Date: 2/22/2020
* Description: handler class for Investment object
*/ 
public with sharing class HL_InvestmentHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public boolean IsTriggerContext{get{ return isExecuting;}}
    public static Boolean isBeforeInsertFlag = false;
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isBeforeUpdateFlag = false;

    public HL_InvestmentHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }

    public void OnBeforeInsert(List<Investment__c> newInvestmentList){
        if(!isBeforeInsertFlag){
            isBeforeInsertFlag = true;
            createIndustrySectorFields(newInvestmentList);
        }
    }
        
    public void OnAfterInsert(Map<Id, Investment__c> insertedMap){
        if(!isAfterInsertFlag){            
            isAfterInsertFlag = true;
            HL_OffsiteTemplate.HandleInsertedInvestmentRecords(insertedMap);
        }
    }

    public void OnBeforeUpdate(List<Investment__c> newInvestmentList , List<Investment__c> oldInvestmentList,  Map<Id, Investment__c> newInvestmentMap, Map<Id, Investment__c> oldInvestmentMap){
        if(!isBeforeUpdateFlag){
            isBeforeUpdateFlag = true;
            updateIndustrySectorFields(newInvestmentList, newInvestmentMap, oldInvestmentMap);
        }    
    }
    
    private void createIndustrySectorFields(List<Investment__c> newInvList){
        Set<Id> setInvIds = new Set<Id>();
   
        for(Investment__c InvList : newInvList){
            if(InvList.Portfolio_CapIQ_Company__c != null){
                setInvIds.add(InvList.Portfolio_CapIQ_Company__c);
            }
        }
        if(setInvIds != null && setInvIds.size() > 0){
            setIndustrySectorFields(newInvList, setInvIds);        
        }
    }
        
    private void updateIndustrySectorFields(List<Investment__c> newInvList, Map<Id, Investment__c> newInvMap, Map<Id, Investment__c> oldInvMap){
        Set<Id> setInvIds = new Set<Id>();
   
        for(Investment__c InvList : newInvMap.values()){
            if(newInvMap.get(InvList.Id).Portfolio_CapIQ_Company__c != null && oldInvMap.get(InvList.Id).Portfolio_CapIQ_Company__c != newInvMap.get(InvList.Id).Portfolio_CapIQ_Company__c){
                setInvIds.add(InvList.Portfolio_CapIQ_Company__c);
            }else if (newInvMap.get(InvList.Id).Portfolio_CapIQ_Company__c == null) {
                InvList.HL_Portfolio_Co_HL_Industry__c = '';
                InvList.HL_Portfolio_Co_HL_Sector__c = '';
            }
        }
        if(setInvIds != null && setInvIds.size() > 0){
            setIndustrySectorFields(newInvList, setInvIds);
        }
    }
    
    private void setIndustrySectorFields(List<Investment__c> newInvestmentsList, Set<Id> setInvestmentIds){
        
        Map<Id, CapIQ_Company__c> mapOfCapIQIdWithObject = new Map<Id, CapIQ_Company__c>();    
        
        for(CapIQ_Company__c objCapIQ : [SELECT id, Name, HL_Industry_Group__c, HL_Sector__c from CapIQ_Company__c WHERE Id IN :setInvestmentIds]){
            mapOfCapIQIdWithObject.put(objCapIQ.Id, objCapIQ);
        }
            
        for(Investment__c InvList : newInvestmentsList){
            if(InvList.Portfolio_CapIQ_Company__c != null && mapOfCapIQIdWithObject.containsKey(InvList.Portfolio_CapIQ_Company__c)){
                InvList.HL_Portfolio_Co_HL_Industry__c = mapOfCapIQIdWithObject.get(InvList.Portfolio_CapIQ_Company__c).HL_Industry_Group__c;
                InvList.HL_Portfolio_Co_HL_Sector__c = mapOfCapIQIdWithObject.get(InvList.Portfolio_CapIQ_Company__c).HL_Sector__c;
            }
        }
    }

}