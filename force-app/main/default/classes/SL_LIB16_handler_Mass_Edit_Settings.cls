/**
 * 
 * @author Privlad
 */
public with sharing class SL_LIB16_handler_Mass_Edit_Settings
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_LIB16_handler_Mass_Edit_Settings(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(list<Mass_Edit_Settings__c> newRecord)
    {
    	this.setUnicField(newRecord);
    	if(newRecord.size()==1 && (newRecord[0].API_Type__c==null || newRecord[0].API_Type__c=='')){ this.updAPIFldType(newRecord[0]);}
    }
    
    public void OnAfterInsert(map<ID,Mass_Edit_Settings__c> newRecordMap){
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){ }
    
    public void OnBeforeUpdate(map<ID,Mass_Edit_Settings__c> oldRecordMap, map<ID,Mass_Edit_Settings__c> newRecordMap)
    {
    	this.setUnicField(newRecordMap.values());
    	if(newRecordMap.size()==1)
    	{
    		Mass_Edit_Settings__c item = (newRecordMap.values())[0];
    		if(item.API_Type__c==null || item.API_Type__c=='') this.updAPIFldType(item);
    	}
    }
    
    public void OnAfterUpdate(map<ID,Mass_Edit_Settings__c> oldRecordMap, map<ID,Mass_Edit_Settings__c> newRecordMap){
    }
    
    @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){ }
    
    public void OnBeforeDelete(map<ID,Mass_Edit_Settings__c> oldRecordMap){ }
    
    public void OnAfterDelete(map<ID,Mass_Edit_Settings__c> oldRecordMap){
    }
    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){ }
    
    public void OnBeforeUndelete(list<Mass_Edit_Settings__c> restoredRecords){ }
    
    public void OnAfterUndelete(list<Mass_Edit_Settings__c> restoredRecords){ }
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    }
    
    private void setUnicField(list<Mass_Edit_Settings__c> inVals)
    {
    	for(Mass_Edit_Settings__c item:inVals)
    	{
    		item.CheckOnUnic__c = item.Implementation__c+'-'+item.Implementation_Type__c+'-'+item.Field__c;
    	}
    }
    
    private void updAPIFldType(Mass_Edit_Settings__c item)
    {
    	if(item.Implementation__c!=null && item.Implementation_Type__c!=null && (item.Implementation_Type__c=='Target' || item.Implementation_Type__c=='Search'))
    	{
    		String targetObject = '';
    		for(SL_Mass_Implementation__c itemImp:[select Id,targetObjectName__c,searchObjectName__c from SL_Mass_Implementation__c where ID=:item.Implementation__c limit 1])
			{
	        	if(item.Implementation_Type__c=='Search') targetObject = itemImp.searchObjectName__c;
	        	else targetObject = itemImp.targetObjectName__c;
	        	
	        	system.debug('>>>>>>>>> targetObject: '+targetObject);
	        	system.debug('>>>>>>>>> item.Field__c: '+item.Field__c);
	        	item.API_Type__c = SL_LIB16_ME_DescribeObject_Core.getInstance().getFieldTypeByName(targetObject, item.Field__c);
			}
			
    	}
    }
}