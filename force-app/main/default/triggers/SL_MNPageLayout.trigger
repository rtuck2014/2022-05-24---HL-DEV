trigger SL_MNPageLayout on MN_Page_Layout__c (before insert) {
    
    SL_MNPageLayoutHandler objMNPageLayoutHandler = new SL_MNPageLayoutHandler();

    if(trigger.isInsert && trigger.isBefore) {

    	objMNPageLayoutHandler.onBeforeInsert(trigger.new);
    }
}