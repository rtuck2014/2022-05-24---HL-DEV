/* created: Vladidmir Prishlyak*/ 
public with sharing class SL_RTR_LIB209_ctrl_SearchBox_JSON
{
	private SL_RTR_LIB16_ME_DescribeObject_Core m_describe_object_core = null;
	
	public SL_RTR_LIB209_ctrl_SearchBox_JSON()
	{
		m_describe_object_core = m_describe_object_core = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance();
	}
	
	public String getJSONResponse()
    {
        String retVal = '';
        
        SL_RTR_LIB16_ME_DescribeObject_Core m_describe_object_core_user = new SL_RTR_LIB16_ME_DescribeObject_Core();
       // Map<String, Schema.DescribeFieldResult> describe_result_Sub = m_describe_object_core_user.getDecribedFieldsByObject('user');
        
        if(TargetObject!=null && TargetObject!='')
        {
            Map<String, Schema.DescribeFieldResult> describe_result = m_describe_object_core.getDecribedFieldsByObject(TargetObject.toLowerCase());
            
            List<String> lstsortVals = new List<String>();
            lstsortVals.addAll(describe_result.keySet());
            lstsortVals.sort();
            for(String item:lstsortVals)
            {
                retVal += ', '+ '{"name" : "'+describe_result.get(item).getLabel().escapeHtml3()+'", "value" : "'+item+'", "type" : "'+describe_result.get(item).getType().name()+'"}';
                /*
                if(item == 'ownerid')
                {
                    
                    List<String> lstsortValsSub = new List<String>();
                    lstsortValsSub.addAll(describe_result_Sub.keySet());
                    lstsortValsSub.sort();
                    for(String itemSub:lstsortValsSub)
                    {
                        retVal += ', '+ '{"name" : "Owner: '+describe_result_Sub.get(itemSub).getLabel().escapeHtml3()+'", "value" : "Owner.'+itemSub+'", "type" : "'+describe_result_Sub.get(itemSub).getType().name()+'"}';
                    }
                }
                */
            }
        }
        return '{"fields" : ['+(retVal!=''?retVal.substring(2):'')+']}';
        
    }
    
    public String TargetObject {
        get{
            String retVal = System.currentPageReference().getParameters().get('targetobj');
            return retVal;     
        }
    }
    
}