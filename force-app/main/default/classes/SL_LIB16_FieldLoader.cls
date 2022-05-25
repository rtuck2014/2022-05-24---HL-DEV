public with sharing class SL_LIB16_FieldLoader {
	
	private static Map<String, Schema.SObjectType> globalObjectDescribeMap = Schema.getGlobalDescribe();
	private static Map<String, Map<String, Schema.SObjectField>> objTypeFieldDescribeMap = new Map<String, Map<String, Schema.SObjectField>>();
	private Map<String, String> refNameFieldNameMap;
	private Map<String, String> fieldNameFefNameMap;
	private Map<String,boolean> mapIsSortable = new Map<String,boolean>();
	public Map<String, Schema.SObjectField> primaryFieldDescribeMap {get; set;}
	
	Schema.SObjectType objectType {get; set;}
	
	public List<SelectOption> primaryObjectFields {get; private set;}
	public List<SelectOption> level2ObjectFields {get; private set;}
	public List<SelectOption> level3ObjectFields {get; private set;}
	public String primaryObjectValue {
		get 
        {
            if(level2ObjectValue!=null && level2ObjectValue!='') return this.fixRelFieldAPI(primaryObjectValue);
            else return primaryObjectValue;
        }
        set;
	}
	public String level2ObjectValue {
		get 
        {
            if(level3ObjectValue!=null && level3ObjectValue!='') return this.fixRelFieldAPI(level2ObjectValue);
            else return level2ObjectValue;
        }
		set;
	}
	public String level3ObjectValue {get; set;}
	public Boolean showLevel2 {get; set;}
	public Boolean showLevel3 {get; set;}
	
	
	/*
	
	 get 
        {
            if((strColumnsAndFiltersTemplate==null || strColumnsAndFiltersTemplate=='') && strView!=null && strView!='' && !isNewView) return strView;
            return strColumnsAndFiltersTemplate;
        }
        set;
	*/
	
	
	public String getValue()
	{
		String result;
		
		if(level2ObjectValue != null && level2ObjectValue != '')
		{
			result = fieldNameFefNameMap.get(primaryObjectValue) + '.';
			if(level3ObjectValue != null && level3ObjectValue != '')
			{
				result += fieldNameFefNameMap.get(level2ObjectValue);
				result += '.' + level3ObjectValue;
			} else
				result += level2ObjectValue;
		} else
			result = primaryObjectValue;
		
		return result;		
	}
	
	public boolean getIsSortable()
	{
		boolean retVal = false;
		String sCurField = this.getValue();
		if(mapIsSortable.containsKey(sCurField)){ retVal = mapIsSortable.get(sCurField);}
		
		return retVal;
	}
	
	
	public String getRefName(DescribeFieldResult inFld)
	{
		String retVal = '';
		if(inFld.getType() == Schema.DisplayType.Reference)
		{
			if(inFld.getRelationshipName()!=null){ retVal = inFld.getRelationshipName();}
			else{ retVal = String.valueOf(inFld.getReferenceTo()[0]);}
		}
		
		return retVal;
	}
	
	
	public void setSelectedValues(String str)
	{
		if(str != null){
			str = str.toLowerCase();
			List<String> valuesList = str.split('\\.');
			//System.debug('>>>>>>>>>>>>>>'+valuesList);
			//System.debug('>>>>>>>>>>>>>> refNameFieldNameMap: '+refNameFieldNameMap);
			if(valuesList.size() > 0){
				if(refNameFieldNameMap.get(valuesList[0]) != null ){
					primaryObjectValue = refNameFieldNameMap.get(valuesList[0]).toLowerCase();
					updateFieldLists();
					
					if(valuesList.size() > 1) {
						showLevel2 = true;
						
						//System.debug('>>>>>>>>>>>>>>'+valuesList[1]);
						//System.debug('>>>>>>>>>>>>>> refNameFieldNameMap: '+refNameFieldNameMap.get(valuesList[1]));
						
						if((valuesList.size() > 1) && refNameFieldNameMap.get(valuesList[1]) != null ){
							level2ObjectValue = refNameFieldNameMap.get(valuesList[1]).toLowerCase();
							updateFieldLists();
							
							if(valuesList.size() > 2) {
								showLevel3 = true;
								if((valuesList.size() > 2) && refNameFieldNameMap.get(valuesList[2]) != null ){
									level3ObjectValue = refNameFieldNameMap.get(valuesList[2]).toLowerCase();
								}else
									level3ObjectValue = valuesList[2].toLowerCase();
							}
						}else
							level2ObjectValue = valuesList[1].toLowerCase();
							
						//System.debug('>>>>>>>>>>>>>> level2ObjectValue: '+level2ObjectValue);
					}
				} else
					primaryObjectValue = valuesList[0].toLowerCase();
			}
			
			updateFieldLists();
		}
		
		if(level2ObjectValue!=null && level2ObjectValue.trim()!='') primaryObjectValue = this.fixRelFieldAPI(primaryObjectValue.trim());
		if(level3ObjectValue!=null && level3ObjectValue.trim()!='') level2ObjectValue = this.fixRelFieldAPI(level2ObjectValue.trim());
		
	}
	
	
	public SL_LIB16_FieldLoader()
	{
		//get object name from Custom Settings
		String targetObject;
		for(SL_Mass_Implementation__c item:[select Id,targetObjectName__c from SL_Mass_Implementation__c limit 1])
		{
        	targetObject = item.targetObjectName__c;
		}
        
        objectType = globalObjectDescribeMap.get(targetObject);
        
        Schema.DescribeSObjectResult R = objectType.getDescribe();
        primaryFieldDescribeMap = R.fields.getMap();
        primaryObjectFields = getPrimaryFieldSelectOption();
	}
	
	public SL_LIB16_FieldLoader(String ObjName)
	{
		//get object name from Custom Settings
		String targetObject;
		
        for(SL_Mass_Implementation__c item:[select Id,targetObjectName__c from SL_Mass_Implementation__c where Name=:ObjName limit 1])
		{
        	targetObject = item.targetObjectName__c;
		}
        
        
        objectType = globalObjectDescribeMap.get(targetObject);
        
        Schema.DescribeSObjectResult R = objectType.getDescribe();
        primaryFieldDescribeMap = R.fields.getMap();
        primaryObjectFields = getPrimaryFieldSelectOption();
	}
	
	public SL_LIB16_FieldLoader(ID inImplID, String inImplType)
	{
		//get object name from Custom Settings
		String targetObject;
		
        for(SL_Mass_Implementation__c item:[select Id,targetObjectName__c,searchObjectName__c from SL_Mass_Implementation__c where ID=:inImplID limit 1])
		{
        	if(inImplType=='Search') targetObject = item.searchObjectName__c;
        	else targetObject = item.targetObjectName__c;
		}
        
        
        objectType = globalObjectDescribeMap.get(targetObject);
        
        Schema.DescribeSObjectResult R = objectType.getDescribe();
        primaryFieldDescribeMap = R.fields.getMap();
        primaryObjectFields = getPrimaryFieldSelectOption();
	}
	
	public List<SelectOption> getPrimaryFieldSelectOption()
	{
		return getFieldSelectOptionByObject(objectType,'');
	}
	
	public String fixRelFieldAPI(String inVal)
	{
		if(inVal==null && inVal.length()<3) return inVal;
		else
		{
			if(inVal.substring(inVal.length()-3)=='__r'){ return inVal.substring(0,inVal.length()-1)+'c';}
			else if(inVal.substring(inVal.length()-3)!='__c' && inVal.substring(inVal.length()-2)!='id')
			{
				return inVal+'id';
			}
		}
		return inVal;
	}	
	
	public void updateFieldLists()
	{
		Schema.DescribeFieldResult f;
		String sFirstRefName = '';
		//Schema.SObjectField sof = primaryFieldDescribeMap.get(primaryObjectValue);
		
		if(primaryFieldDescribeMap.get(primaryObjectValue) != null)
		{
			f = primaryFieldDescribeMap.get(primaryObjectValue).getDescribe();
			
	    	if(f.getType() == Schema.DisplayType.Reference)
	    	{
	    		Schema.SObjectType chObj = f.getReferenceTo()[0];
	    		sFirstRefName = this.getRefName(f)+'.';
	    		level2ObjectFields = getFieldSelectOptionByObject(chObj,sFirstRefName);
	    		
	    		showLevel2 = true;
	    		if(level2ObjectValue != null && level2ObjectValue != '' && objTypeFieldDescribeMap.containsKey(String.valueOf(chObj)) && objTypeFieldDescribeMap.get(String.valueOf(chObj)).containsKey(level2ObjectValue))
	    		{	
		    		f = objTypeFieldDescribeMap.get(String.valueOf(chObj)).get(level2ObjectValue).getDescribe();
		    		
		    		if(f.getType() == Schema.DisplayType.Reference)
			    	{
			    		chObj = f.getReferenceTo()[0];
			    		level3ObjectFields = getFieldSelectOptionByObject(chObj,sFirstRefName+this.getRefName(f)+'.');		
			    		showLevel3 = true;
			    	} else
			    	{
		    			showLevel3 = false;
		    			level3ObjectValue = '';
			    	}
	    		}
	    	} else
	    	{
	    		showLevel2 = false;
	    		level2ObjectValue = '';
	    		showLevel3 = false;
	    		level3ObjectFields = null;
	    		level3ObjectValue = '';
	    	}
		}else
    	{
    		showLevel2 = false;
    		level2ObjectValue = '';
    		showLevel3 = false;
    		level3ObjectFields = null;
    		level3ObjectValue = '';
    	}
	}
	
	
	public List<SelectOption> getFieldSelectOptionByObject(Schema.SObjectType tObj, String sPreFldName)
	{
		List<SelectOption> result = new List<SelectOption>(); 
	//	if(objTypeFieldDescribeMap == null)
		//System.debug('>>>>>>>>>>>>>>>> '+sPreFldName);
			
		Map<String, Schema.SObjectField> fldDescribeMap = new Map<String, Schema.SObjectField>();
		objTypeFieldDescribeMap.put(String.valueOf(tObj), fldDescribeMap);

		Schema.DescribeSObjectResult R = tObj.getDescribe();
        fldDescribeMap.putAll(R.fields.getMap());

        Schema.DescribeFieldResult f;

		List<String> labels = new List<String>();
		Map<String, SelectOption> labelFieldMap = new Map<String, SelectOption>(); 
        for(String key : fldDescribeMap.keySet())
        {
        	f = fldDescribeMap.get(key).getDescribe();
        	mapIsSortable.put(sPreFldName+key, f.isSortable());
        	//result.add(new SelectOption(key, f.getLabel()));
        	labels.add(f.getLabel());
        	if(f.getType() == Schema.DisplayType.Reference)
        	{		
        		labelFieldMap.put(f.getLabel(), new SelectOption(key.toLowerCase(), f.getLabel()+' >'));
        		if(refNameFieldNameMap == null){ refNameFieldNameMap = new Map<String, String>();}
        		
        		refNameFieldNameMap.put(this.getRefName(f).toLowerCase(), key);
        		if(fieldNameFefNameMap == null){ fieldNameFefNameMap = new Map<String, String>();}
        		fieldNameFefNameMap.put(key, this.getRefName(f));
        	}
        	else
        	{
        		labelFieldMap.put(f.getLabel(), new SelectOption(key.toLowerCase(), f.getLabel()));
        		//result.add(new SelectOption(key, f.getLabel()));
        	}
        }
        
        //sort fields
        labels.sort();
        for(String lbl : labels)
        {
        	result.add(labelFieldMap.get(lbl));
        }
        
        return result;
	}

}