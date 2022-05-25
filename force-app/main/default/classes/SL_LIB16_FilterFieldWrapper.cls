public with sharing class SL_LIB16_FilterFieldWrapper {
	
	public Boolean selected  {get;set;}
	public Boolean selectedColumn  {get;set;}
	public String customLabel {get;set;}
	public String customColumnLabel {get;set;}
	public String systemLabel {get;set;}
	public String systemName {get;set;}
	public String fieldType {get;set;}
	
	public SL_LIB16_FilterFieldWrapper(Map<String,String> values, Boolean selected) {
		this.init(values,selected,false);
	}

	public SL_LIB16_FilterFieldWrapper(Map<String,String> values, Boolean selected, Boolean inSelectedColumn) {
		this.init(values,selected,inSelectedColumn);
	}
	
	private void init(Map<String,String> values, Boolean selected, Boolean inSelectedColumn)
	{
		if (values.containsKey('customLabel')) {
			this.customLabel = values.get('customLabel');
		}
		if (values.containsKey('customColumnLabel')) {
			this.customColumnLabel = values.get('customColumnLabel');
		}
		if (values.containsKey('systemLabel')) {
			this.systemLabel = values.get('systemLabel');
		}
		if (values.containsKey('systemName')) {
			this.systemName = values.get('systemName');
		}
		if (values.containsKey('fieldType')) {
			this.fieldType = values.get('fieldType');
		}
		this.selected = selected;
		this.selectedColumn = inSelectedColumn;
	}


}