public with sharing class SL_MNJoinerHandler {

	public void onBeforeInsert(List<MN_Joiner__c> lstMNJoiner) {

		for(MN_Joiner__c objMNJoiner:[Select Id,MN_Page_Layout__c,MN_Related_List__c from MN_Joiner__c]) {

			if(objMNJoiner.MN_Page_Layout__c == lstMNJoiner[0].MN_Page_Layout__c && objMNJoiner.MN_Related_List__c == lstMNJoiner[0].MN_Related_List__c) {

				lstMNJoiner[0].addError('Record already exists with provided MN Related List and MN Page Layout combination, Please provide different values');
			}
		}
	}
}