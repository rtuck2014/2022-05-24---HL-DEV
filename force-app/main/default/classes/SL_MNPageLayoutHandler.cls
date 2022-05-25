public with sharing class SL_MNPageLayoutHandler {

	public void onBeforeInsert(List<MN_Page_Layout__c> lstMNPageLayout) {
		
		if(lstMNPageLayout[0].RecordType__c != null && lstMNPageLayout[0].RecordType__c != '') {

			List<RecordType> lstRecordType = [Select Id,DeveloperName from RecordType where DeveloperName =: lstMNPageLayout[0].RecordType__c];

			if(!lstRecordType.isEmpty()) {

				lstMNPageLayout[0].RecordTypeId__c = lstRecordType[0].Id;

			} else {

				lstMNPageLayout[0].addError('Invalid Record Type, Please provide existing Record Type');
			}
		}

		if(lstMNPageLayout[0].RecordType__c != null && lstMNPageLayout[0].Profile__c != null) {

			for(MN_Page_Layout__c objMNPageLayout:[Select Id,Name,RecordType__c,Profile__c from MN_Page_Layout__c]) {

				if(objMNPageLayout.RecordType__c == lstMNPageLayout[0].RecordType__c && objMNPageLayout.Profile__c == lstMNPageLayout[0].Profile__c){

					lstMNPageLayout[0].addError('Provided RecordType and Profile combination already exists, Please provide different combination');
				}
			}
		}
	}
}