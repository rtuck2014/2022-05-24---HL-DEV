public with sharing class HL_GiftHandler {
	private boolean isExecuting = false;
	private integer batchSize = 0;
    public static Boolean isBeforeInsertFlag = false;
    public static Boolean isBeforeUpdateFlag = false;
    private HL_Email Emailer{get{
        if(emailer == null)
            emailer = new HL_Email();
        return emailer;
        } set;}
    public HL_GiftHandler(boolean executing, integer size){
        isExecuting = executing;
        batchSize = size;
    }
    
    //Batch the Gifts that are the same with multiple recipients - Use the Required Fields as Key: Type, Name, Submitted For
    public void OnBeforeInsert(List<Gift__c> gifts){
    	AssignSupplementFields(gifts);
    }

    //Assigned the Submitted By and Batch Guid Fields
    private List<Gift__c> AssignSupplementFields(List<Gift__c> gifts){
        Contact c = HL_Contact.GetByUserId();
    	Map<String, String> keyToGuidMap = new Map<String, String>();
    	String key;
    	for(Gift__c g : gifts){
    		key = g.Gift_Type__c + '_' + g.Name + '_' + g.Submitted_For__c;
    		if(!keyToGuidMap.containsKey(key))
    			keyToGuidMap.put(key,HL_Utility.GenerateGUID());
            g.Submitted_By__c = c.Id;
    		g.Batch_Guid__c = keyToGuidMap.get(key);
    	}
    	return gifts;
    }

    //Sends out two notices: Confirmation to the Submitted for and Email to the Reviewers
    public void OnAfterInsert(List<Gift__c> insertedGifts){
    	SendInsertNotifications(insertedGifts);
    }

    private void SendInsertNotifications(List<Gift__c> insertedGifts){
    	//Gifts are Batched with multiple recipients, only send these notices on the batch
    	Map<String, List<Gift__c>> uniqueBatchMap = new Map<String, List<Gift__c>>();
        List<User> submitters = new List<User>();
        List<String> reviewerEmails = GetReviewerEmails();

    	for(Gift__c g : insertedGifts){
            submitters.add(new User(Id = g.CreatedById));
    		if(!uniqueBatchMap.containsKey(g.Batch_Guid__c))
    			uniqueBatchMap.put(g.Batch_Guid__c, new List<Gift__c>{g});
            else{
                List<Gift__c> gifts = uniqueBatchMap.get(g.Batch_Guid__c);
                gifts.add(g);
            }
    	}

        Map<Id, Contact> submitterMap = HL_Contact.GetMapByUsers(submitters);

    	for(String key : uniqueBatchMap.keySet()){
            //Use the first gift in the batch as the parent
            Gift__c parentGift = uniqueBatchMap.get(key)[0];
            //Populate the main gift data from the first record (they will all be the same within the batch)
            HL_EmailMerge emConfirmation = new HL_EmailMerge('Gift_Log_Confirmation', uniqueBatchMap.get(key)[0].Id);
        	HL_EmailMerge emSubmitted = new HL_EmailMerge('Gift_Log_Submitted', uniqueBatchMap.get(key)[0].Id);
            
            emConfirmation.MergeData(false)
                          .MergeGiftRecipients(uniqueBatchMap.get(key))
                          .ClearUnmatchedFields();
            
            emSubmitted.MergeData(false)
                       .MergeGiftRecipients(uniqueBatchMap.get(key))
                       .MergeGiftLinks()
                       .ClearUnmatchedFields();

            //Send Confirmation Email to the Submitter
            if(submitterMap.get(parentGift.CreatedById) != null && emConfirmation.EmailTemplate != null)
            	Emailer.AddEmailToQueue(new string[] {submitterMap.get(parentGift.CreatedById).Email}, null, null, emConfirmation.EmailTemplate.Email_Subject__c, emConfirmation.EmailTemplate.Template_Body__c, true);
            //Send Submission Email to the Reviewers
            if(reviewerEmails.size() > 0 && emSubmitted.EmailTemplate != null)
            	Emailer.AddEmailToQueue(reviewerEmails, null, null, emSubmitted.EmailTemplate.Email_Subject__c, emSubmitted.EmailTemplate.Template_Body__c, true);
        }

        SendQueuedMessages();
    }

    private List<String> GetReviewerEmails(){
        List<Contact> reviewers = new HL_Group('Gift_Log_Reviewer').GetContacts();
        List<String> reviewerEmails = new List<String>();
        for(Contact c : reviewers)
            reviewerEmails.add(c.Email);
        return reviewerEmails;
    }
    
   
    public void OnAfterUpdate(Map<Id, Gift__c> oldMap, Map<Id, Gift__c> newMap){
    	SendUpdateNotifications(oldMap, newMap);
    }

    private void SendUpdateNotifications(Map<Id, Gift__c> oldMap, Map<Id, Gift__c> newMap){
    	Map<String, List<Gift__c>> statusUpdateGiftMap = new Map<String, List<Gift__c>>();
    	List<Gift__c> editedGifts = new List<Gift__c>();
    	List<User> submitters = new List<User>();
        List<String> reviewerEmails = GetReviewerEmails();
        HL_Email email = new HL_Email();

        for(Gift__c updatedGift : newMap.values())
    	{
            submitters.add(new User(Id = updatedGift.CreatedById));

    		//Check if the record was modified
    		if(HasEdits(oldMap.get(updatedGift.Id), updatedGift))
    		   	editedGifts.add(updatedGift);

    		//Check if the status was changed
    		if(updatedGift.Approved__c != oldMap.get(updatedGift.Id).Approved__c)
    		{
	    		//If the status has changed we want to include in the status notification
	    		if(!statusUpdateGiftMap.containsKey(updatedGift.Batch_Guid__c))
	    			statusUpdateGiftMap.put(updatedGift.Batch_Guid__c, new List<Gift__c>{updatedGift});
	    		else
	    		{
	    			List<Gift__c> giftList = statusUpdateGiftMap.get(updatedGift.Batch_Guid__c);
	    			giftList.add(updatedGift);
	    		}
    		}
    	}

        Map<Id, Contact> submitterMap = HL_Contact.GetMapByUsers(submitters); 

    	for(String batchGuid : statusUpdateGiftMap.keySet()){
            //Use the first gift in the batch as the parent
            Gift__c parentGift = statusUpdateGiftMap.get(batchGuid)[0];

            HL_EmailMerge emStatus = new HL_EmailMerge('Gift_Log_Status', parentGift.Id);

            emStatus.MergeData(false);
            emStatus.MergeGiftRecipients(statusUpdateGiftMap.get(batchGuid));
            emStatus.ClearUnmatchedFields();

            //Send Status Update Email to the Submitter
            if(submitterMap.get(parentGift.CreatedById) != null)
            	Emailer.AddEmailToQueue(new string[] {submitterMap.get(parentGift.CreatedById).Email}, null, null, emStatus.EmailTemplate.Email_Subject__c, emStatus.EmailTemplate.Template_Body__c, true);
        }
     	
    	for(Gift__c editedGift : editedGifts){
    		if(editedGift.LastModifiedById == editedGift.CreatedById){
                //Send Edited by Submitter Notices to both the Submitter and Reviewer
                HL_EmailMerge emRevisedToSubmitter = new HL_EmailMerge('Gift_Log_Revised', editedGift.Id);
                HL_EmailMerge emRevisedToReviewer = new HL_EmailMerge('Gift_Log_Revised', editedGift.Id);
                
                emRevisedToSubmitter.MergeData(false)
                                    .MergeGiftRecipients(new List<Gift__c>{editedGift});
                
                emRevisedToSubmitter.EmailTemplate.Template_Body__c = emRevisedToSubmitter.EmailTemplate.Template_Body__c.replace('{!Reviser}', 'you');
                emRevisedToSubmitter.ClearUnmatchedFields();

                emRevisedToReviewer.MergeData(false)
                                    .MergeGiftRecipients(new List<Gift__c>{editedGift})
                                    .MergeGiftLinks();
                emRevisedToReviewer.EmailTemplate.Template_Body__c = emRevisedToReviewer.EmailTemplate.Template_Body__c.replace('{!Reviser}', 'the submitter');
                emRevisedToReviewer.ClearUnmatchedFields();

                //Send Email to the Submitter
                if(submitterMap.get(editedGift.CreatedById) != null)
                	Emailer.AddEmailToQueue(new string[] {submitterMap.get(editedGift.CreatedById).Email}, null, null, emRevisedToSubmitter.EmailTemplate.Email_Subject__c, emRevisedToSubmitter.EmailTemplate.Template_Body__c, true);
                //Send Email to the Reviewers
                if(reviewerEmails.size() > 0)
                	Emailer.AddEmailToQueue(reviewerEmails, null, null, emRevisedToReviewer.EmailTemplate.Email_Subject__c, emRevisedToReviewer.EmailTemplate.Template_Body__c, true);
            }
    		else{
                //Send Edited by Reviewer/Approver notice to the original Submitter
                HL_EmailMerge emEdited = new HL_EmailMerge('Gift_Log_Edited', editedGift.Id);
    			
                emEdited.MergeData(false)
                        .MergeGiftRecipients(new List<Gift__c>{editedGift})
                        .ClearUnmatchedFields();

                //Send Email to the Submitter
                if(submitterMap.get(editedGift.CreatedById) != null)
                	Emailer.AddEmailToQueue(new string[] {submitterMap.get(editedGift.CreatedById).Email}, null, null, emEdited.EmailTemplate.Email_Subject__c, emEdited.EmailTemplate.Template_Body__c, true);
            }
    	}

        SendQueuedMessages();
    }

    public void OnAfterDelete(List<Gift__c> deletedGifts){
    	SendDeleteNotifications(deletedGifts);
    }

    private void SendDeleteNotifications(List<Gift__c> deletedGifts){
        List<User> submitters = new List<User>();
        List<User> approvers = new List<User>();
    	List<String> reviewerEmails = GetReviewerEmails();

        for(Gift__c deletedGift : deletedGifts){
            submitters.add(new User(Id = deletedGift.CreatedById));
            if(!String.isBlank(deletedGift.Approved_By__c))
                approvers.add(new User(Id = deletedGift.Approved_By__c));
        }

        Map<Id, Contact> approverMap = HL_Contact.GetMapByUsers(approvers);
        Map<Id, Contact> submitterMap = HL_Contact.GetMapByUsers(submitters); 

        //Send the Notifications
        for(Gift__c deletedGift : deletedGifts){
            HL_EmailMerge emCancelled = new HL_EmailMerge('Gift_Log_Cancelled', deletedGift.Id, deletedGift);
            
            emCancelled.MergeData(false)
                       .MergeGiftRecipients(new List<Gift__c>{deletedGift})
                       .ClearUnmatchedFields();
          
            //Send Cancelled Email to the Submitter
            Emailer.AddEmailToQueue(new string[] {submitterMap.get(deletedGift.CreatedById).Email}, null, null, emCancelled.EmailTemplate.Email_Subject__c, emCancelled.EmailTemplate.Template_Body__c, true);
            
            if(!String.isBlank(deletedGift.Approved_By__c)) //Send Cancelled Email to the Approver
                Emailer.AddEmailToQueue(new string[] {approverMap.get(deletedGift.Approved_By__c).Email}, null, null, emCancelled.EmailTemplate.Email_Subject__c, emCancelled.EmailTemplate.Template_Body__c, true);
            else if(reviewerEmails.size() > 0) //Send the notice to the reviewers
                Emailer.AddEmailToQueue(reviewerEmails, null, null, emCancelled.EmailTemplate.Email_Subject__c, emCancelled.EmailTemplate.Template_Body__c, true);
        }

        SendQueuedMessages();
    }

    private Boolean HasEdits(Gift__c oldGift, Gift__c newGift){
    	return oldGift.Name != newGift.Name || 
    		   oldGift.Gift_Type__c != newGift.Gift_Type__c ||
    		   oldGift.Submitted_For__c != newGift.Submitted_For__c || 
    		   oldGift.Vendor__c != newGift.Vendor__c ||
    		   oldGift.Gift_Value__c != newGift.Gift_Value__c ||
    		   oldGift.Currency__c != newGift.Currency__c ||
    		   oldGift.HL_Relationship__c != newGift.HL_Relationship__c ||
    		   oldGift.Reason_For_Gift__c != newGift.Reason_For_Gift__c;
    }

    private void SendQueuedMessages(){
        if(Emailer.QueuedMessages.size() > 0)
        {
            try{
                Emailer.SendQueuedMessages();
            }
            catch(Exception ex){
                System.Debug('Error Sending Email: ' + ex.getMessage());
            }
        }
    }
}