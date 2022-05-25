public with sharing class SL_RTR_LIB209_ctrl_Demo
{

	private static Map<String, Schema.SObjectType> oDescribe = Schema.getGlobalDescribe();
	private Set<String> aDefaultObjectList = new Set<String> { 'account', 'case', 'contact', 'event', 'idea', 'lead', 'opportunity', 'task', 'counterparty__c' };
	private String inStrWhere = '';

	public SL_RTR_LIB209_ctrl_SearchBlockParams curSearchBlockParams;
	public SL_RTR_LIB16_FilterSOQLCompiler m_filters = new SL_RTR_LIB16_FilterSOQLCompiler();
	
	public SL_RTR_LIB209_ctrl_Demo(){
		List<String> aResult = new List<String>();
		for ( String sItem : aDefaultObjectList ) {
			aResult.add( oDescribe.get( sItem ).getDescribe().getName() );
		}
		aResult.sort();
		
		for( String sItem : aResult ) {
			if ( this.aObjectsOptions == null ) {
				this.aObjectsOptions = new List<SelectOption>();
			}
			this.aObjectsOptions.add( new SelectOption( sItem, oDescribe.get( sItem ).getDescribe().getLabel() ) );
		}
		this.aSearchColumns = new List<String>();
		this.aSearchColumnLabels = new Map<String, String>();
		this.sSelectedOption = this.aObjectsOptions[0].getValue();		
	}
	
	public String sSelectedOption {
		get;
		set {
			sSelectedOption = value;

			this.aSearchColumnLabels.clear();
			this.aSearchColumns.clear();
			
			if ( oDescribe.containsKey( sSelectedOption ) ) {
				for ( Schema.SObjectField oItem : oDescribe.get( sSelectedOption ).getDescribe().fields.getMap().values() ) {
					
					if(''+oItem.getDescribe().getType()!= 'address' && ''+oItem.getDescribe().getType() != 'location')
					{
						this.aSearchColumns.add( oItem.getDescribe().getName() );
						this.aSearchColumnLabels.put( oItem.getDescribe().getName(), oItem.getDescribe().getLabel() );
					}
				}
				this.aSearchColumns.sort();
			}
		}
	}
	
	public String oWhereClause { get; set; }
	public String sDebugInfo { get; set; }
	
	public List<SelectOption> aObjectsOptions { get; set; }
	public List<String> aSearchColumns { get; set; }
	public Map<String, String> aSearchColumnLabels { get; set; }

	public SL_RTR_LIB209_ctrl_SearchBlockParams getSearchCompParams()
    {
    	if(curSearchBlockParams==null)
    	{
	    	curSearchBlockParams = new SL_RTR_LIB209_ctrl_SearchBlockParams();
	    	curSearchBlockParams.tabs = new List<SelectOption>();
	    	curSearchBlockParams.mainSelTarget = 'Target_000';
	    	curSearchBlockParams.searchBtnClick = 'searchBtnClick()';
	    	curSearchBlockParams.FiltersJSON = '[]';
	    	curSearchBlockParams.cb_target = 'Main';
	    	curSearchBlockParams.cb_advFilters = '';
	    	curSearchBlockParams.dateFormat = SL_RTR_LIB16_DateObject.dateFormat;
    	}
    	curSearchBlockParams.tabsObjName = new List<SelectOption>{new selectOption('Target_000',this.sSelectedOption)};
    	curSearchBlockParams.locationBase = '/apex/SL_LIB209_SearchBox_JSON?targetobj='+this.sSelectedOption+'&evtmp=';
    	
    	return curSearchBlockParams;
    }
    
    public String getComponentWhereClause() {
		/*
		SL_RTR_Condition oWhere = this.getComponentWhereClause( 'FilterComponent' );
		if ( oWhere != null ) {
			return oWhere.toSoql();
		}
		*/
		return inStrWhere;
	}
	
	public void searchBtnClick()
	{
		/*
		sDebugInfo = 'curSearchBlockParams.SearchParam: '+curSearchBlockParams.SearchParam;
		sDebugInfo += '<br/>curSearchBlockParams.SearchQ: '+curSearchBlockParams.SearchQ;
		sDebugInfo += '<br/>curSearchBlockParams.SearchObj: '+curSearchBlockParams.SearchObj;
		sDebugInfo += '<br/>curSearchBlockParams.SearchTarget: '+curSearchBlockParams.SearchTarget;
		*/
		m_filters.Initialize(curSearchBlockParams.SearchQ, curSearchBlockParams.SearchParam, curSearchBlockParams.SearchObj);
		inStrWhere = m_filters.SOQL;
	}
	
	public List<sObject> aRecords {
		get {
			String sNames = '';
            for ( String oItem : this.aSearchColumns ) {
            	sNames += oItem + ', ';
            }
			if ( sNames.length() > 0 ) {
				sNames = sNames.substring( 0, sNames.length() - 2 );
			} else {
				sNames = 'Name';
			}
			try {
				return Database.query( 'SELECT ' + sNames + ' FROM ' + this.sSelectedOption + ( this.getComponentWhereClause() != '' ? ' WHERE ' + this.getComponentWhereClause() : ' limit 30' ) );
			} catch ( Exception e ) {
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage() ) );
				return new List<sObject>();
			}
		}
	}
	
}