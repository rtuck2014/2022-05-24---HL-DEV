/**  
* \arg ClassName      : SL_MultiselectedPicklist
* \arg JIRATicket     : HL-17
* \arg CreatedOn      : 4/JUNE/2014
* \arg LastModifiedOn : 4/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : 
*/

public with sharing class SL_MultiselectedPicklist 
{
	/* Start Variables */
	// SelectOption lists for public consumption
    public SelectOption[] leftOptions 		{ 	get; set; 	}
    public SelectOption[] rightOptions	 	{ 	get; set; 	}
    public static String strSobjectName		{	get;set;	}
    
    private static Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
	/* End Variables */
    
    /* Start - Constructor */
    public SL_MultiselectedPicklist() 
    {
    	// do nothing.
    }  
    /* End - Constructor */
    
    /* 
        @MethodName : setOptions.
        @param      : SelectOption[] options, String value
        @Description:  Parse &-separated values and labels from value and put them in option
    */
    private void setOptions(SelectOption[] options, String value) 
    {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) 
        {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              							 EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    /* End */
    
    /* 
        @MethodName : leftOptionsHidden.
        @param      : NA.
        @Description: Backing for hidden text field containing the options from the left list
    */
    public String leftOptionsHidden 
    { 	
    	get; set 
    	{
           	if(leftOptions != null)
           	{
	           	leftOptionsHidden = value;
	        	setOptions(leftOptions, value);
           	}
        }
    }
    /* End */
    
    /* 
        @MethodName : setOptions.
        @param      : NA.
        @Description: Backing for hidden text field containing the options from the right list
    */
    public String rightOptionsHidden 
    { 
    	get; set 
    	{
           if(rightOptions != null)
           {
	           rightOptionsHidden = value;
	          
	           setOptions(rightOptions, value);
           }
        }
    }
    /* End */
    
    /*
    	@MethodName : validateDependentPicklist
        @param      : String strSobjectName and String strCSVSelectedFieldAPI    
        @Description: This method to vlidate the dependent picklist.
	*/
    @RemoteAction
	public static String validateDependentPicklist(String sobjectName, String strCSVSelectedFieldAPI, String strCSVExistFieldAPI, Boolean isLeft)
	{
		Map<String, Schema.SObjectField> mapFieldDef = mapGlobalDescribe.get(sobjectName).getDescribe().fields.getMap();
		if(isLeft)
		{
			strCSVExistFieldAPI += strCSVSelectedFieldAPI;
			for(String strFieldAPIName : strCSVSelectedFieldAPI.split(';'))
			{
				if(strFieldAPIName != '' && !strFieldAPIName.contains('__r.'))
				{
					Schema.SObjectField field = mapFieldDef.get(strFieldAPIName);
					if(field.getDescribe().isDependentPicklist())
					{
						Schema.SObjectField fieldController  = field.getDescribe().getController();
						Set<String> setExistField = new Set<String>();
						setExistField.addAll(strCSVExistFieldAPI.split(';'));
						if(!setExistField.contains(fieldController.getDescribe().getName()))
						{
							return field.getDescribe().getLabel() + ' cannot be added as a column without including ' + fieldController.getDescribe().getLabel();
						}
					}
				}
			}
		}
		else
		{
			for(String strFieldAPIName : strCSVExistFieldAPI.split(';'))
			{
				if(strFieldAPIName != '' && !strFieldAPIName.contains('__r.'))
				{
					Schema.SObjectField field = mapFieldDef.get(strFieldAPIName);
					if(field.getDescribe().isDependentPicklist())
					{
						Schema.SObjectField fieldController  = field.getDescribe().getController();
						Set<String> setExistField = new Set<String>();
						setExistField.addAll(strCSVSelectedFieldAPI.split(';'));
						if(setExistField.contains(fieldController.getDescribe().getName()))
						{
							return fieldController.getDescribe().getLabel() + ' cannot be remove as ' + field.getDescribe().getLabel() +' is dependent field';
						}
					}
				}
			}
		}
		
		return 'done';
	} 	
}