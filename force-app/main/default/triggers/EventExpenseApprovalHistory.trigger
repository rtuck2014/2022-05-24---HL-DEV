trigger EventExpenseApprovalHistory on Event_Expense_Approval_History__c (Before Insert, Before Update) {

    for(Event_Expense_Approval_History__c EEAppHstry : Trigger.New)
    {
        if(Trigger.IsInsert){
           
            EEAppHstry.Status_TimeStamp__c = system.now();
             
        }
        if(Trigger.IsUpdate)
        {
            
            if(EEAppHstry.Status__c != Trigger.OldMap.get(EEAppHstry.Id).Status__c)
             {
                EEAppHstry.Status_TimeStamp__c = EEAppHstry.LastmodifiedDate;               
                    
             }
             
        }
    
    }
}