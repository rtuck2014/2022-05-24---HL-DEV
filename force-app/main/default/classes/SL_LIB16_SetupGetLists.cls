public with sharing class SL_LIB16_SetupGetLists
{
	private ApexPages.StandardController thisController;
	private SL_Mass_Implementation__c obj;
	
	public String inRecordSelCols {get; set;}
	
	public SL_LIB16_SetupGetLists(ApexPages.StandardController controller)
	{
		this.thisController = controller;
		this.obj = (SL_Mass_Implementation__c)this.thisController.getRecord();
		this.obj = [SELECT Id,Name,searchObjectName__c,Using_Exists_Impl__c FROM SL_Mass_Implementation__c WHERE Id= :obj.Id];
	}

	public PageReference goSave()
    {
    	this.obj.Using_Exists_Impl__c = inRecordSelCols;
    	update this.obj;

		PageReference pageRef = new PageReference('/' + this.obj.Id);   
		pageRef.setRedirect(true);   
		return pageRef;
    }  


	public PageReference goCancel()
    {

		PageReference pageRef = new PageReference('/' + this.obj.Id);   
		pageRef.setRedirect(true);   
		return pageRef;
    } 
    
    
    public List<SelectOption> getUnselectedColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        Set<ID> setSelIDs = new set<ID>();
        
        if(obj.Using_Exists_Impl__c!=null && obj.Using_Exists_Impl__c!='')
        {
        	for(String item: obj.Using_Exists_Impl__c.split(','))
        	{
        		setSelIDs.add((ID)item);
        	}
        }
        
        for(SL_Mass_Implementation__c item: [SELECT Id,Name FROM SL_Mass_Implementation__c WHERE searchObjectName__c= :obj.searchObjectName__c order by Name])
        {
        	if(!setSelIDs.contains(item.ID)){ res.add(new SelectOption(item.ID, item.Name));}
        }
        

        if(res == Null){ res.add(new SelectOption('', ''));}
        return res;
    }
    
	public List<SelectOption> getSelectColumnsOrdered()
	{
        List<SelectOption> res = new List<SelectOption>();
        List<ID> lstSelIDs = new List<ID>();
        map<ID,String> mapAllItems = new map<ID,String>();
        if(obj.Using_Exists_Impl__c!=null && obj.Using_Exists_Impl__c!='')
        {
        	for(String item:obj.Using_Exists_Impl__c.split(',')){ lstSelIDs.add((ID)item);}
        	
        	for(SL_Mass_Implementation__c item: [SELECT Id,Name FROM SL_Mass_Implementation__c WHERE searchObjectName__c= :obj.searchObjectName__c])
        	{
        		mapAllItems.put(item.Id,item.Name);
        	}
        	
        	for(ID item:lstSelIDs)
        	{
        		if(mapAllItems.containsKey(item)){ res.add(new SelectOption(item, mapAllItems.get(item)));}
        	}
        }
        return res;
	}
    
	

}