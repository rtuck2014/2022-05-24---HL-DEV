public with sharing class PickListDescController {

	public Sobject sobj {get;set;}
	public List<String> pickListFieldName {get;set;}

	public PickListDescController() {

		Map<String, String> reqParams = ApexPages.currentPage().getParameters();

		String recordTypeId = reqParams.get('recordTypeId');
		String sobjectTypeName = reqParams.get('sobjectType');
		this.pickListFieldName = reqParams.get('picklistFieldName').split(',');

		Schema.SobjectType sobjectType = null;

		if (sobjectTypeName != null && sobjectTypeName.trim().length() > 0) {

			sobjectType = Schema.getGlobalDescribe().get(sobjectTypeName);

			// create blank sobject record
			sobj = sobjectType.newSobject();

			if(recordTypeId != '' && recordTypeId != null)
				sobj.put('RecordTypeId', recordTypeId);
		} 
        
	}
}