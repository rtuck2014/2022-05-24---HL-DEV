/**************************************************************************
* Purpose : To handle supporting actions on ContactComment records
* Test Class : Test_HL_ContactCommentHandler
**************************************************************************/
trigger HL_ContactCommentTrigger on Contact_Comment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if(trigger.isbefore)
      {
        if(trigger.isInsert)
          HL_ContactCommentHandler.beforeInsert(trigger.New,null,null,null);       
        if(trigger.isUpdate)
            HL_ContactCommentHandler.beforeupdate(trigger.New,null,null,null);
        if(trigger.isDelete)
          HL_ContactCommentHandler.beforeDelete(null,null,trigger.old,null);
      }   
    else if(trigger.Isafter)
    {
    	 if(trigger.isInsert)
         	HL_ContactCommentHandler.afterInsert(trigger.New,null,null,null);
    }
}