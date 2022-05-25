/**  
* \arg ClassName      : SL_SobjectMultiselectComponent
* \arg JIRATicket     : HL-18
* \arg CreatedOn      : 20/JUN/2014
* \arg LastModifiedOn : 20/JUN/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Controller class for SL_SobjectMultiselectComponent component.
*/
public with sharing class SL_SobjectMultiselectComponent 
{
	// SelectOption lists for public consumption
    public SelectOption[] leftSideOptions 	{	get; set; 	}
    public SelectOption[] rightSideOptions 	{ 	get; set; 	}
    
    // Parse &-separated values and labels from value and 
    // put them in option
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
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden 
    { 
    	get; 
    	set 
    	{
           leftOptionsHidden = value;
           setOptions(leftSideOptions, value);
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden 
    { 
    	get; 
    	set 
    	{
           rightOptionsHidden = value;
           setOptions(rightSideOptions, value);
        }
    }
}