public class HL_Mass_Bid {
     private static Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();  

	/* Start Variables */
    public String strSelectedRound     									{   get;set;   	}
    public List<Engagement_Counterparty__c> lstCounterparty				{	get;set;	}
    public String strEngagementId										{	get;set;	}
    public String ParentName											{	get;set;	}
    public List<Bid__c> bidList											{	get;set;	}
    public List<Bid__c> bidFinalList									{	get;set;	}
    
     /* Start - Constructor */
    public HL_Mass_Bid() 
    {
        strSelectedRound = 'First';
        strEngagementId = ApexPages.currentPage().getParameters().get('id');
        
        Engagement__c parentObject = [SELECT Id, Name FROM Engagement__c WHERE Id =:strEngagementId];
        ParentName = parentObject.Name;

        lstCounterparty = [SELECT Id, Company__r.Name FROM Engagement_Counterparty__c WHERE Engagement__c =:strEngagementId Order By Company__r.Name];
    }
    
    public List<Bid__c> getBids()
    {        
        if(bidFinalList != null&& !bidFinalList.isEmpty() && bidFinalList[0].Round__c != strSelectedRound) //determine if the Bid Round has changed
			bidFinalList = null;  //Reset the main list so it can be populated below.
        
        if(bidFinalList == null)  //only populate the list if this is null and the first time we are coming into it.
        {
            List<Bid__c> bidMasterList = new List<Bid__c>();
            bidFinalList = new List<Bid__c>();
            
            for(Engagement_Counterparty__c currItem: lstCounterparty)
            {
                Bid__c newBid = new Bid__c();
                newBid.CompanyName__c = currItem.Company__r.Name;
                newBid.Round__c = strSelectedRound;
                newBid.Engagement_Counterparty__c = currItem.Id;
                bidMasterList.add(newBid);
            }
            
            bidList = [SELECT Date__c,Debt__c,Engagement_Counterparty__c,Equity__c,Name,Round_Maximum__c,Round_Minimum__c,Round__c, Comments__c,
                                        Engagement_Counterparty__r.Name, Engagement_Counterparty__r.Company__r.Name    
                                    FROM Bid__c WHERE Engagement_Counterparty__c in:lstCounterparty AND Round__c =:strSelectedRound ];
            
            for(Bid__c masterBid: bidMasterList)
            {            
                Boolean IsFound = false;
                for(Bid__c currBid: bidList)
                {
                     if(masterBid.CompanyName__c == currBid.Engagement_Counterparty__r.Company__r.Name)
                     {
                         Bid__c newBid = new Bid__c();
                         newBid = currBid;
                         newBid.CompanyName__c = currBid.Engagement_Counterparty__r.Company__r.Name;                    
                         bidFinalList.add(newBid);
                         IsFound = true;
                         break;
                     }
                }
                
                if(!IsFound)
                {
                    bidFinalList.add(masterBid);               
                }
            }
        }

        return bidFinalList;          
    }
  
    public PageReference Save(){
        update bidList;
        boolean hasError=false;
        string strError='';
        
        List<Bid__c> newBids = new List<Bid__c>();
        
        for(Bid__c currBid: bidFinalList)
        {   
            if(currBid.Id == null && (currBid.Round_Minimum__c != null || currBid.Round_Maximum__c != null || currBid.Equity__c != null || currBid.Debt__c != null || currBid.Date__c != null || !String.isBlank(currBid.Comments__c)))
            {
                //The date field is required.  If one is not entered, throw an error.
                if(currBid.Date__c == null)
                {
					hasError = true;
                    strError += 'You must enter a date value when creating a new bid entry;  ';
                }
                
                //The Round Minimum is required.  If one is not entered, throw an error.
                if(currBid.Round_Minimum__c == null)
                {
					hasError = true;
                    strError += 'You must enter a Round Minimum value when creating a new bid entry;  ';
                }
                
                //The Round Maximum is required.  If one is not entered, throw an error.
                if(currBid.Round_Maximum__c == null)
                {
					hasError = true;
                    strError += 'You must enter a Round Maximum value when creating a new bid entry;  ';
                }
                
                if(hasError)
                {
                    HL_PageUtility.ShowError(strError);
                    return ApexPages.currentPage();
                }
                
                newBids.add(currBid);
            }
        }  

        if(newBids.size() > 0)
            upsert newBids;
          
        return returnToCounterparties();
    }
    
    public PageReference returnToCounterparties()
    {
        String theme = UserInfo.getUiThemeDisplayed();
        PageReference pr;
        if(theme=='Theme4d'||theme=='Theme4t'|| theme=='Theme4u'){
            pr = new PageReference('/lightning/cmp/c__CounterpartyWrapLwc?c__id='+strEngagementId+'&c__recordId='+strEngagementId);
        }else{
            pr = new Pagereference('/apex/SL_LIB16_MassEdit_CompanyListMember');
            pr.getParameters().put('clid', ApexPages.currentPage().getParameters().get('id'));
            pr.getParameters().put('extId', '2');            
        }
        return pr;
    }    
    
    public PageReference updatePage()
    {
        return null;
    }
    
    /*
        @MethodName : getRoundOptions.
        @param      : NA.
        @Description: to get the options to display the Bid Rounds.
    */
    public List<SelectOption> getRoundOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        for(String objOptions : HL_Utility.GetPicklistValues('Bid__c', 'Round__c'))
        {
            options.add(new SelectOption(objOptions, objOptions));
        }
        return options;
    }
    /* End */      	
}