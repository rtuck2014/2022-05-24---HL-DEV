/*
Original Author: Privlad
Source: https://silverline.jira.com/browse/LIB-151
Jira Ticket: LIB-151
*/
public with sharing class SL_LIB16_Custom_Lookup_Page extends SL_LIB16_ctrl_CompanyListSearch
{
	
	public SL_Mass_Implementation__c currMainCusSettings { get;set;}
	public String acc {get;set;} // new account to create
	public List<SObject> results{get;set;} // search results
	public string searchString{get;set;} // search keyword
    public String targetedListId{get;set;} // ID of Targeted List we came from
	public String targetedList{ // ID of Targeted List we came from
        get{
            if(System.currentPageReference().getParameters().get('mt')=='1'){
                return 'apex/SL_LIB16_MassEdit_ManageTargets?mt=1&clid='+CompanyListID+'&implId='+implementationId;
            }
            return targetedListId;
        }
        set;
    } 
	public String saveOK{get;set;}
	
	public string searchMsg{get;set;}
	
	public SL_LIB16_Custom_Lookup_Page()
	{
		saveOK = '0';
		searchMsg = '';

		if (!isNullOrEmpty(implementationId))
		{
			try
			{
				SL_Mass_Implementation__c item = [Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c,
						searchObjectName__c, parentObjectName__c, Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, 
						Search_Object_Title__c, Name, Id, Get_Element_from_List_Tab__c, Use_Step2_Multi_Add_Form__c From SL_Mass_Implementation__c where Id=:implementationId limit 1];
							
				SL_LIB16_ctrl_CompanyListSearch.MainObjName = item.name;
				SL_LIB16_ctrl_CompanyListSearch.MainObjNameID = item.ID;
				currMainCusSettings = item;
			}
			catch(Exception e)
			{
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Incorrect Implementation or problem with custom settings!'));
			}
		}
		
		// get the current search string
		searchString = System.currentPageReference().getParameters().get('lksrch');
		targetedListId = CompanyListID;
    
		runSearch();
		isShowStep2 = false;
		 
	}
	
	public String CompanyListID
	{
		get { return System.currentPageReference().getParameters().get('clid');}
	}

    public String implementationId
    {
    	get
    	{
    		//extId
    		String retVal = null;
    		if(System.currentPageReference().getParameters().get('implId')!=null && System.currentPageReference().getParameters().get('implId')!='')
    		{
    			retVal = System.currentPageReference().getParameters().get('implId');
    		}
    		else if(System.currentPageReference().getParameters().get('extId')!=null && System.currentPageReference().getParameters().get('extId')!='')
    		{
    			try
    			{
    				Decimal inExtID = Decimal.valueOf(System.currentPageReference().getParameters().get('extId'));
    				for(SL_Mass_Implementation__c item:[select ID from SL_Mass_Implementation__c where ExtID__c=:inExtID limit 1])
    				{
    					retVal = item.ID;
    				}
    			}
    			catch(Exception ex){}
    		}
    		
    		return retVal;
    	}
    }
    
	// performs the keyword search
	public PageReference search()
	{
		runSearch();
		return null;
	}
  
	// prepare the query and issue the search command
	@TestVisible
	private void runSearch()
	{
		searchString = String.escapeSingleQuotes(searchString);
		results = performSearch(searchString);               
	} 
  
	// run the search and return the records found. 
	private List<SObject> performSearch(string searchString)
	{
		List<SObject> retList = null;
		searchMsg = '';
		// Get the records already listed in the Targeted List
		List<Id> listedCompanyIds = new List<Id>();
		

		String soql_pre = 'Select ID from '+currMainCusSettings.searchObjectName__c+' where ID in (select '+currMainCusSettings.targetObjectSearchFieldName__c;
			soql_pre += ' from '+currMainCusSettings.targetObjectName__c+' where '+currMainCusSettings.targetObjectParentFieldName__c+'=\''+CompanyListID+'\')';
		
		for(SObject item:database.query(soql_pre))
		{
			listedCompanyIds.add(item.ID);
		}

		// Can't use a SOSL query to get all results                                                
		if(searchString == '' || searchString == null)
		{
			String soql = 'SELECT Id, Name FROM '+currMainCusSettings.searchObjectName__c+' WHERE Id NOT IN :listedCompanyIds ORDER BY Name ASC LIMIT 200';
			System.debug('SOQL Query: ' + soql);
			retList = database.query(soql);
	
		// SOSL queries must have more than one character in the search term
		}else if(searchString.length() == 1 || (searchString.length() == 2 && searchString.contains('*'))){
			String soql = 'SELECT Id, Name FROM '+currMainCusSettings.searchObjectName__c;
			soql += ' WHERE Name LIKE \'%' + searchString +'%\'';
			soql += ' AND Id NOT IN :listedCompanyIds ORDER BY Name ASC LIMIT 200';
	
			System.debug('SOQL Query: ' + soql);
			retList =  database.query(soql);
	
		}else{ // Use SOSL
	
			searchString = searchString.replace('*','');
			String sosl = 'FIND \'' + searchString + '*\'';
			sosl += ' IN NAME FIELDS RETURNING '+currMainCusSettings.searchObjectName__c+'(Name, Id WHERE Id NOT IN :listedCompanyIds ORDER BY Name LIMIT 200)';
	      
			System.debug('SOSL Query: ' + sosl);
			retList =  search.query(sosl)[0];
	    }
	    if(retList!=null && retList.size()>=200){ searchMsg = 'You can see only first 200 records from the list';}
	    
	    return retList;
	}
  
	// Saves a new Company_List_Member record
	public PageReference SaveBtn()
	{
		List<SObject> list2Insert = new List<SObject>();
		SObject tmpSObj = null;
		tmpSObj = Schema.getGlobalDescribe().get(currMainCusSettings.targetObjectName__c).newSObject();
		tmpSObj.put(currMainCusSettings.targetObjectSearchFieldName__c, acc);
		tmpSObj.put(currMainCusSettings.targetObjectParentFieldName__c, targetedListId);
		list2Insert.add(tmpSObj);
        System.Debug('tmpSObj: ' + tmpSObj);
		Database.insert(list2Insert,false);

		return null;
	}
	
	public void saveStep1Btn()
	{
		isShowStep2 = true;
		SObject tmpSObj = null;
		tmpSObj = Schema.getGlobalDescribe().get(currMainCusSettings.targetObjectName__c).newSObject();
		tmpSObj.put(currMainCusSettings.targetObjectSearchFieldName__c, acc);
		tmpSObj.put(currMainCusSettings.targetObjectParentFieldName__c, targetedListId);
		
		lstMemberItems = new List<SObject>();
		lstMemberItems.add(tmpSObj);
		//massEditSettings = currMainCusSettings;
		
	}
	
	public void doSaveStep3()
	{
		if(lstMemberItems!=null && lstMemberItems.size()>0) Database.insert(lstMemberItems,false);
		saveOK = '1';
	}
	
	public void doCancelStep3()
	{
		isShowStep2 = false;
		lstMemberItems = new List<SObject>();
	}
	
}