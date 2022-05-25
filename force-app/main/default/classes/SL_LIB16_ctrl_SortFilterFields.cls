public with sharing class SL_LIB16_ctrl_SortFilterFields {
	
	private Id implId;
	public SL_Filter_Field__c curFFObj {get; set;}
	private ApexPages.StandardController controllerSet; 
	public String currentTab {get; set;}
	
	public SL_LIB16_ctrl_SortFilterFields(ApexPages.StandardController controller) {
		
		this.controllerSet = controller;
		curFFObj = (SL_Filter_Field__c)controller.getRecord();
		
		if (ApexPages.currentPage().getParameters().containsKey('impl')) {
			this.implId = ApexPages.currentPage().getParameters().get('impl');
			if(curFFObj==null){ curFFObj = new SL_Filter_Field__c(Mass_Implementation__c = implId);}
			else if(curFFObj.Mass_Implementation__c==null)
			{
				curFFObj = new SL_Filter_Field__c(ID=curFFObj.ID,Mass_Implementation__c = implId);
			}
		}
		
		this.currentTab = 'Search';
		this.refreshFilterFields();
	} 
	
	public List<Selectoption> tabs;
	
	public List<Selectoption> getTabs() {
		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('Search','Search'));
		options.add(new SelectOption('Target','Target'));
		
		List<Filter_Tab__c> filterTabs = [SELECT Id,Name,Mass_Implementation__c FROM Filter_Tab__c WHERE Mass_Implementation__c=:curFFObj.Mass_Implementation__c];
		for (Filter_Tab__c item: filterTabs) {
			options.add(new SelectOption(item.Id,'Tab - ' + item.Name));
		}
		return options;
	}
	
	public void setTabs(List<Selectoption> tabs) {
		this.tabs = tabs;
	}
	
	public List<SL_Filter_Field__c> filterFields {get; set;}
	
	public void refreshFilterFields() {
		
		List<SL_Filter_Field__c> result;
		
		if (this.currentTab == 'Search') {
			result = [SELECT Id,Order__c,API_Name__c,Name FROM SL_Filter_Field__c WHERE Type__c = 'Search' and Mass_Implementation__c=:curFFObj.Mass_Implementation__c ORDER BY Order__c];
		} else if (this.currentTab == 'Target') {
			result = [SELECT Id,Order__c,API_Name__c,Name FROM SL_Filter_Field__c WHERE Type__c = 'Target' and Mass_Implementation__c=:curFFObj.Mass_Implementation__c ORDER BY Order__c];
		} else {
			result = [SELECT Id,Order__c,API_Name__c,Name FROM SL_Filter_Field__c WHERE Filter_Tab__c = :this.currentTab and Mass_Implementation__c=:curFFObj.Mass_Implementation__c ORDER BY Order__c];
		}
		
		this.filterFields = result;
		
	}
	
	private PageReference doBackRedirect() {
		return new PageReference('/' + this.implId);
	}
	
	public Pagereference doAlphabet() {
		//update this.filterFields;
		
		List<SL_Filter_Field__c> lst2Upd = new List<SL_Filter_Field__c>();
		List<SL_Filter_Field__c> result;
		if (this.currentTab == 'Search') {
			result = [SELECT Id,Order__c,API_Name__c,Name FROM SL_Filter_Field__c WHERE Type__c = 'Search' and Mass_Implementation__c=:curFFObj.Mass_Implementation__c ORDER BY Name];
		} else if (this.currentTab == 'Target') {
			result = [SELECT Id,Order__c,API_Name__c,Name FROM SL_Filter_Field__c WHERE Type__c = 'Target' and Mass_Implementation__c=:curFFObj.Mass_Implementation__c ORDER BY Name];
		} else {
			result = [SELECT Id,Order__c,API_Name__c,Name FROM SL_Filter_Field__c WHERE Filter_Tab__c = :this.currentTab and Mass_Implementation__c=:curFFObj.Mass_Implementation__c ORDER BY Name];
		}
		
		if(result!=null && result.size()>0)
		{
			Integer i = 1;
			for(SL_Filter_Field__c item:result)
			{
				item.Order__c = i++;
				lst2Upd.add(item);
			}
			update lst2Upd;
		}
		this.filterFields = result;
		
		return null;
	}
	
	public Pagereference doSave() {
		update this.filterFields;
		return this.doBackRedirect();
	}
	
	public Pagereference doCancel() {
		return this.doBackRedirect();
	}
	
}