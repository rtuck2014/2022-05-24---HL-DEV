/**
 * 
 * @author Privlad
 */
public without sharing class SL_LIB16_handler_View
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SL_LIB16_handler_View(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(list<SL_View__c> newRecord)
    {
    	this.checkOnDublicate(newRecord);
    	this.checkOnUserSet(newRecord);
    }
    
    public void OnAfterInsert(map<ID,SL_View__c> newRecordMap)
    {
    	
    }
    
    @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){ }
    
    public void OnBeforeUpdate(map<ID,SL_View__c> oldRecordMap, map<ID,SL_View__c> newRecordMap)
    {
    	this.checkOnChangeIsDefault(oldRecordMap,newRecordMap);
    	this.checkOnDublicate(newRecordMap.values());
    	this.checkOnUserSet(newRecordMap.values());
    }
    
    public void OnAfterUpdate(map<ID,SL_View__c> oldRecordMap, map<ID,SL_View__c> newRecordMap){
    }
    
    @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){ }
    
    public void OnBeforeDelete(map<ID,SL_View__c> oldRecordMap)
    {
    	this.checkOnDeleteViews(oldRecordMap.values());
    }
    
    public void OnAfterDelete(map<ID,SL_View__c> oldRecordMap){
    }
    
    @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){ }
    
    public void OnBeforeUndelete(list<SL_View__c> restoredRecords)
    {
    	this.checkOnDublicate(restoredRecords);
    }
    
    public void OnAfterUndelete(list<SL_View__c> restoredRecords){ }
    
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
    
    public void checkOnChangeIsDefault(map<ID,SL_View__c> oldRecordMap, map<ID,SL_View__c> newRecordMap)
    {
    	for(SL_View__c item:newRecordMap.values())
    	{
    		if(item.IsDefault__c!=oldRecordMap.get(item.Id).IsDefault__c)
    		{
    			item.addError('You can not change value of IsDefault field.');
    		}
    		else if(item.Implementation_Type__c!=oldRecordMap.get(item.Id).Implementation_Type__c && item.IsDefault__c==true)
    		{
    			item.addError('You can not change View\'s Type if IsDefault is True.');
    		}
    		else if(item.Implementation_Type__c!=oldRecordMap.get(item.Id).Implementation_Type__c && oldRecordMap.get(item.Id).Implementation_Type__c=='ManageTargets')
    		{
    			item.addError('You can not change View\'s Type from \'ManageTargets\'.');
    		}    		
    		else if(item.Name!=oldRecordMap.get(item.Id).Name && oldRecordMap.get(item.Id).Implementation_Type__c=='ManageTargets')
    		{
    			item.addError('You can not change View\'s Name for View with Type \'ManageTargets\'.');
    		}    		
    	}
    }
    
    
    public void checkOnUserSet(list<SL_View__c> inRecord)
    {
    	for(SL_View__c item:inRecord)
    	{
    		if(item.Implementation_Type__c=='Target' && item.IsDefault__c!=true && item.User__c==null)
    		{
    			item.addError('User field is required for View with Type \'Target\'.');
    		}
    		else if(item.Implementation_Type__c=='Search' && item.IsDefault__c!=true && item.User__c==null)
    		{
    			item.addError('User field is required for View with Type \'Search\'.');
    		}
    	}
    }
    
    public void checkOnDeleteViews(list<SL_View__c> inRecord)
    {
    	Map<ID,boolean> mapIsAddPage = new Map<ID,boolean>();
    	Set<ID> setImplIDs = new Set<ID>();
    	
    	for(SL_View__c item:inRecord)
    	{
    		setImplIDs.add(item.Implementation__c);
    		if(item.Implementation_Type__c=='Target' && item.IsDefault__c == true)
    		{
    			item.addError('You can not delete Default View with Type \'Target\'.');
    		}
    		else if(item.Implementation_Type__c=='Search' && item.IsDefault__c == true)
    		{
    			item.addError('You can not delete Default View with Type \'Search\'.');
    		}
    		else if(item.Implementation_Type__c=='ManageTargets')
    		{
    			item.addError('You can not delete View with Type \'ManageTargets\'.');
    		}
    	}
    	
    	for(SL_Mass_Implementation__c item:[Select Use_Step2_Multi_Add_Form__c, ID From SL_Mass_Implementation__c where ID in :setImplIDs])
    	{
    		mapIsAddPage.put(item.ID, item.Use_Step2_Multi_Add_Form__c);
    	}
    	
    	for(SL_View__c item:inRecord)
    	{
    		if(item.Implementation_Type__c=='AddPage' && mapIsAddPage.get(item.Implementation__c)==true)
    		{
    			item.addError('You can not delete View with Type \'AddPage\' until \'Use Step2 Multi Add Form\' is Enable for current Implementation.');
    		}
    	}
    }
    
    
    public void checkOnDublicate(list<SL_View__c> inRecord)
    {
    	Map<ID,Map<String,boolean>> mapFlags = new Map<ID,Map<String,boolean>>();
    	/*
    	boolean isDefaultSearchView = false;
    	boolean isDefaultTargetView = false;
    	boolean isAddPageView = false;
    	boolean isManageTargetsView = false;
    	*/
    	if(inRecord==null || inRecord.size()==0) return;
    	Set<ID> setViewIDs = new Set<ID>();
    	Set<ID> setImplIDs = new Set<ID>();
    	for(SL_View__c item:inRecord)
    	{
    		setImplIDs.add(item.Implementation__c);
    		if(item.ID!=null) setViewIDs.add(item.ID);
    		mapFlags.put(item.Implementation__c, new Map<String,boolean>{'DefaultSearch'=>false,'DefaultTarget'=>false,'AddPage'=>false,'ManageTargets'=>false});
    	}
    	
    	for(SL_View__c item:[Select IsDefault__c, Implementation__c, Implementation_Type__c, Id From SL_View__c 
    				where Implementation__c in :setImplIDs and ID not in :setViewIDs and (Implementation_Type__c in ('AddPage','ManageTargets') OR IsDefault__c=true) limit 5000])
    	{
    		if(item.IsDefault__c == true)
    		{
    			if(item.Implementation_Type__c=='Target') mapFlags.get(item.Implementation__c).put('DefaultTarget',true);
    			else if(item.Implementation_Type__c=='Search') mapFlags.get(item.Implementation__c).put('DefaultSearch',true);
    		}
    		else if(item.Implementation_Type__c=='AddPage') mapFlags.get(item.Implementation__c).put('AddPage',true);
    		else if(item.Implementation_Type__c=='ManageTargets') mapFlags.get(item.Implementation__c).put('ManageTargets',true);
    	}
    	
    	for(SL_View__c item:inRecord)
    	{
    		if(item.IsDefault__c == true)
    		{
    			if(item.Implementation_Type__c=='Target' && mapFlags.get(item.Implementation__c).get('DefaultTarget'))
    			{
    				item.addError('Duplicate! Default View with Type \'Target\' already exists.');
    				
    			}
    			else if(item.Implementation_Type__c=='Search' && mapFlags.get(item.Implementation__c).get('DefaultSearch'))
    			{
    				item.addError('Duplicate! Default View with Type \'Search\' already exists.');
    			}
    		}
    		else if(item.Implementation_Type__c=='AddPage' && mapFlags.get(item.Implementation__c).get('AddPage'))
    		{
    			item.addError('Duplicate! Default View with Type \'AddPage\' already exists.');
    		}
    		else if(item.Implementation_Type__c=='ManageTargets' &&  mapFlags.get(item.Implementation__c).get('ManageTargets'))
    		{
    			item.addError('Duplicate! Default View with Type \'ManageTargets\' already exists.');
    		}
    	}
    	
    }
    
    
}