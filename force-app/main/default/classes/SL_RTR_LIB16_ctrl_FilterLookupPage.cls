public without sharing class SL_RTR_LIB16_ctrl_FilterLookupPage
{

	public String target {
        get{
            String retVal = System.currentPageReference().getParameters().get('targetobj');
            return retVal;     
        }
    }

	public String picklistName {
        get{
            return System.currentPageReference().getParameters().get('picklist');       
        }
    }

	public static String getRelObject4Field(String inObjName, String inFldName)
    {
    	String fldParts = inFldName;
    	if(inFldName.indexOf('.')>0){ fldParts = inFldName.substring(0,inFldName.indexOf('.'));}
    	else{ return null;}

    	String sParentField = '';
    	if(fldParts.right(3)=='__r'){ sParentField = fldParts.substring(0,fldParts.length()-3)+'__c';}
    	else{ sParentField = fldParts+'Id';}
    	
    	Schema.SObjectType dType = Schema.getGlobalDescribe().get(inObjName).getDescribe().fields.getMap().get(sParentField).getDescribe().getReferenceTo().get(0);
		return String.valueOf(dType);    	
    }

	public List<LookUpPickListValue> getLCPickListValue()
    {
        
        List<LookUpPickListValue> returnList = new List<LookUpPickListValue>();
        integer ccounter = 0;
        try
        { 
            if (picklistName.toLowerCase()=='recordtypeid' || (picklistName.length()>12 && picklistName.toLowerCase().right(12)=='recordtypeid'))
            {
                List<RecordType> rtLst = new List<RecordType>();
				if(picklistName.toLowerCase()=='recordtypeid'){ rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:target ORDER BY Name];}
                else{
                	String sRelObjName = SL_RTR_LIB16_ctrl_FilterLookupPage.getRelObject4Field(target, picklistName);
                	rtLst = [SELECT Id, Name FROM RecordType WHERE SobjectType=:target ORDER BY Name];
                }
                
                
                for (RecordType rt : rtLst){
                    returnList.add(new LookUpPickListValue(''+ccounter,String.escapeSingleQuotes(rt.Name)));
                    ccounter++;
                }
            }
            else
            {
                List<Schema.PicklistEntry> picklist_list = new List<Schema.PicklistEntry>();
                
				if(picklistName.indexOf('.')==-1)
                {
                	picklist_list = Schema.getGlobalDescribe().get(target).getDescribe().fields.getMap().get(picklistName).getDescribe().getPicklistValues();
                }
                else
                {
                	String sRelObjName = SL_RTR_LIB16_ctrl_FilterLookupPage.getRelObject4Field(target, picklistName);
                	String sChildField = picklistName.substring(picklistName.indexOf('.')+1);
                	picklist_list = Schema.getGlobalDescribe().get(sRelObjName).getDescribe().fields.getMap().get(sChildField).getDescribe().getPicklistValues();
                }

                for( Schema.PicklistEntry picklist_value : picklist_list ) {
                    returnList.add(new LookUpPickListValue(''+ccounter,picklist_value.getValue()));
                    ccounter++;
                }
            }
        }catch(Exception e) {
            return null;
        }
        
        return returnList;
    }
    
	public class LookUpPickListValue
    {
        public String  ID   {get;set;}
        public String  Value {get;set;}
        
        public LookUpPickListValue(String inID, String inValue) {
            ID = inID;
            Value = inValue;
        }
    }

}