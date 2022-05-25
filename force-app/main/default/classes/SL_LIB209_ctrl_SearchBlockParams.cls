/*
  created: Vladidmir Prishlyak 
*/
public with sharing class SL_LIB209_ctrl_SearchBlockParams
{
	public List<SelectOption> tabs {get; set;}
	public List<SelectOption> tabsObjName {get; set;}
	public String mainSelTarget {get; set;}
	public String locationBase {get; set;}
	public String searchBtnClick {get; set;}
	public String cb_target {get; set;}
	public String FiltersJSON {get; set;}
	public String cb_advFilters {get; set;}
	public String dateFormat {get; set;}
	
    public String SearchParam {get; set;}
    public String SearchQ {get; set;}
    public String SearchObj {get; set;}
    public String SearchTarget {get; set;}
    
	
	public SL_LIB209_ctrl_SearchBlockParams()
	{
		this.tabs = new List<SelectOption>();
		this.tabsObjName = new List<SelectOption>();
		this.mainSelTarget = '';
		this.locationBase = '';
		this.searchBtnClick = '';
		this.cb_target = '';
		this.FiltersJSON = '';
		this.cb_advFilters = '';
		this.dateFormat = '';
		this.SearchParam = '';
		this.SearchQ = '';
		this.SearchObj = '';
		this.SearchTarget = '';
	}

}