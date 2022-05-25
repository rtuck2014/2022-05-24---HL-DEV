public with sharing class SL_LIB16_SetupButtons {
	
	private ApexPages.StandardController thisController;
	
	private SL_Mass_Implementation__c obj;
	
	public SL_LIB16_SetupButtons(ApexPages.StandardController controller) {
		this.thisController = controller;
		this.obj = (SL_Mass_Implementation__c)this.thisController.getRecord();
		this.obj = [SELECT Id,Search_Object_Title__c,targetObjectName__c,parentObjectName__c, ExtID__c FROM SL_Mass_Implementation__c WHERE Id= :obj.Id];
	}
	
    public String TargetObjName {get{return Schema.getGlobalDescribe().get(this.obj.targetObjectName__c).getDescribe().getLabel();}}
    public String ParentObjName {get{return Schema.getGlobalDescribe().get(this.obj.parentObjectName__c).getDescribe().getLabel();}}
    
	public String searchObjectPlural
	{
		get { return obj.Search_Object_Title__c;}
		set;
	}
	
	public String addSingle
	{
		get
		{
			//return '/apex/SL_LIB16_CompanyListSearch?clid={!'+this.obj.parentObjectName__c+'.Id}&implId=' + this.obj.Id;
			String retVal = 'var url = \'/apex/SL_LIB16_Custom_Lookup_Page?&lksrch=&clid={!'+this.obj.parentObjectName__c+'.Id}&extId=' + this.obj.ExtID__c+'\';\n';
				retVal += 'var width = 670;\n\n';
				retVal += 'openPopup(url, "lookup", 350, 480, "width="+width+",height=480,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no", true);\n';

			return retVal;
		}
		set;
	}
	
	public String addUrl
	{
		get { return '/apex/SL_LIB16_CompanyListSearch?clid={!'+this.obj.parentObjectName__c+'.Id}&extId=' + this.obj.ExtID__c;}
		set;
	}

	public String editUrl
	{
		get { return '/apex/SL_LIB16_MassEdit_CompanyListMember?clid={!'+this.obj.parentObjectName__c+'.Id}&extId=' + this.obj.ExtID__c;}
		set;
	}
	
	public String manageTargetsUrl
    {
        get { return '/apex/SL_LIB16_MassEdit_ManageTargets?clid={!'+this.obj.parentObjectName__c+'.Id}&extId=' + this.obj.ExtID__c + '&mt=1';}
        set;
    }
	
	public String deleteUrl
	{
		get
		{
			String retVal = '{!REQUIRESCRIPT("/soap/ajax/29.0/connection.js")}\n';
			retVal += 'var records = {!GETRECORDIDS($ObjectType.'+this.obj.targetObjectName__c+')};\n';
			retVal += 'if (records[0] == null) {\n';
			retVal += '    alert("Please select at least one record.");\n';
			retVal += '} else {\n';
			retVal += '    var text = "Are you sure to delete the item";\n';
			retVal += '    if (records.toString().indexOf(\',\') == -1){\n';
			retVal += '        text += "?";\n';
			retVal += '    } else {\n';
			retVal += '        text += "s?";\n';
			retVal += '    }\n';
			retVal += '    if (confirm(text)){\n';
			retVal += '        var errors = [];\n';
			retVal += '        var result = sforce.connection.deleteIds(records);\n';
			retVal += '        if (result && result.length){\n';
			retVal += '            var numFailed = 0;\n';
			retVal += '            var numSucceeded = 0;\n';
			retVal += '            for (var i = 0; i < result.length; i++){\n';
			retVal += '                var res = result[i];\n';
			retVal += '                if (res && res.success == \'true\'){\n';
			retVal += '                    numSucceeded++;\n';
			retVal += '                } else {\n';
			retVal += '                    var es = res.getArray("errors");\n';
			retVal += '                    if (es.length > 0) {\n';
			retVal += '                        errors.push(es[0].message);\n';
			retVal += '                    }\n';
			retVal += '                    numFailed++;\n';
			retVal += '                }\n';
			retVal += '            }\n';
			retVal += '        if (numFailed > 0){\n';
			retVal += '            alert("Failed: " + numFailed + "\\nSucceeded: " + numSucceeded + " \\n Due to: " + errors.join("\\n"));\n';
			retVal += '        }\n';
			retVal += '		}\n';
			retVal += '		navigateToUrl(window.location.href);\n';
			retVal += '    }\n';
			retVal += '}\n';
			
			return retVal;
		}
		set;
	}
	
	
/*	
	
*/
	public PageReference goBack()
    {

		PageReference pageRef = new PageReference('/' + this.obj.Id);   
		pageRef.setRedirect(true);   
		return pageRef;
    }         

}