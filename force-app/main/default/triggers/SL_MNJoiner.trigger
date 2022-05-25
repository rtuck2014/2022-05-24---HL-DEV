trigger SL_MNJoiner on MN_Joiner__c (before insert) {
    
    SL_MNJoinerHandler objMNJoinerHandler = new SL_MNJoinerHandler();

    if(trigger.isInsert && trigger.isBefore) {

    	objMNJoinerHandler.onBeforeInsert(trigger.new);
    }
}