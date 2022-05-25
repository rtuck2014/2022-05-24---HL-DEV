/**
 * 
 * @author Privlad
 */
public without sharing class SL_LIB16_handler_UserChoise
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_LIB16_handler_UserChoise(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(list<SL_LIB16_UserChoise__c> newRecord)
    {
		this.fixUserChoiseValues(newRecord);
    }
    
    public void OnAfterInsert(map<ID,SL_LIB16_UserChoise__c> newRecordMap){
    	
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){ }
    
    public void OnBeforeUpdate(map<ID,SL_LIB16_UserChoise__c> oldRecordMap, map<ID,SL_LIB16_UserChoise__c> newRecordMap)
    {
    	this.fixUserChoiseValues(newRecordMap.values());
    }
    
    public void OnAfterUpdate(map<ID,SL_LIB16_UserChoise__c> oldRecordMap, map<ID,SL_LIB16_UserChoise__c> newRecordMap){

    }
    
    @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){ }
    
    public void OnBeforeDelete(map<ID,SL_LIB16_UserChoise__c> oldRecordMap){ }
    
    public void OnAfterDelete(map<ID,SL_LIB16_UserChoise__c> oldRecordMap){
    }
    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){ }
    
    public void OnBeforeUndelete(list<SL_LIB16_UserChoise__c> restoredRecords){ }
    
    public void OnAfterUndelete(list<SL_LIB16_UserChoise__c> restoredRecords){ }
    
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
    
    private void fixUserChoiseValues(list<SL_LIB16_UserChoise__c> newRecord)
    {
    	//for(newRecord)
    	//Map<String, String> mappedData = (Map<String, String>)Json.deserialize(choiceObject.Serialized_Data__c, Map<String, String>.class);
		//String SearchQ = mappedData.get('SearchQ');
		Map<String, String> mappedData;
		for(SL_LIB16_UserChoise__c item:newRecord)
		{
			if(item.Serialized_Data__c!=null && item.Serialized_Data__c.trim()!='')
			{
				try
				{
					mappedData = (Map<String, String>)Json.deserialize(item.Serialized_Data__c, Map<String, String>.class);
					//mappedData.put('SearchQ','');
					if(mappedData!=null && mappedData.containsKey('SearchQ'))
					{
						mappedData.put('SearchQ', mappedData.get('SearchQ').replace('"', '&quot;'));
						mappedData.put('SearchQ', mappedData.get('SearchQ').replace('\'', '&#39;'));
						mappedData.put('SearchQ', mappedData.get('SearchQ').replace('<', '&lt;'));
						mappedData.put('SearchQ', mappedData.get('SearchQ').replace('>', '&gt;'));
						mappedData.put('SearchQ', mappedData.get('SearchQ').replace('\\', ''));
						mappedData.put('SearchQ', mappedData.get('SearchQ').replace('|', ''));
						if(mappedData.get('SearchQ')=='' && mappedData.get('SearchParam')!='')
						{
							mappedData.put('SearchParam','');
						}						
						
						item.Serialized_Data__c = Json.serialize(mappedData);
					}
				}
				catch(Exception ex){ }
			}
			
			system.debug('item.Serialized_Data__c >>>>>>>>>>>> '+item.Serialized_Data__c);
		
		}
    }
}