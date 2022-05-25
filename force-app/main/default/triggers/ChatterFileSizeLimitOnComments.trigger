trigger ChatterFileSizeLimitOnComments on FeedComment (after insert) {               
/*
 * Trigger Name: ChatterFileSizeLimitOnComments
 * Description: A Trigger that checks for size of files uploaded with a comment, and presents error if file is over the limit.
 *
 */                      
         
    List<FeedComment> lstCon = Trigger.new;
    Blob doc;
    integer docSize;
    integer chatterFileSizeLimit;
    string errorMessage;    
    FeedComment Comment = lstCon[0];                                    
    
    system.debug('Comment'+Comment);    
    // To check if the post on comment is Content Post
    if(Comment.CommentType=='ContentComment')
    {
        //The following 4 lines refers to the Custom Setting "ChatterLimits__c" Custom settings are used for File size limit and Error Message to avoid hardcoding in trigger.
        
        //ChatterLimits__c chatterFileSize = ChatterLimits__c.getInstance('MaxFileUploadSize'); 
        //Size must be in bytes          
        chatterFileSizeLimit = 2999999;    
        //ChatterLimits__c chatterFileError = ChatterLimits__c.getInstance('ChatterFileLimitError');
        errorMessage = 'The file that you attempted to upload is over the limit of 3 MB. Please choose a smaller file and try again.';
        
        
        //Once you Browse file and hit attach, file is not attached with the comment Post, but it is uploaded to Chatter Files.
        //A query on Content Version will Query on that file and check for the Size of the file.        
        ContentVersion Content = Database.query('SELECT PublishStatus ,Id,VersionData,ContentDocumentId FROM ContentVersion where Id IN (SELECT RelatedRecordId FROM FeedComment WHERE Id = \'' + comment.Id + '\')');        
        //System.debug(comment.relatedrecordid);                                     
        //System.debug(content.ContentDocumentId);
        //System.debug(content.Id);
        doc = Content.VersionData;
         //system.debug('Content ' + content);
        docSize =  doc.size();               
        if(docSize > chatterFileSizeLimit )
        { 
            //String status = ChatterFileSizeLimitProcessor.DeleteChatterFiles(Comment.RelatedRecordId);
            comment.addError(errorMessage); 
            system.debug('Content Document Id'+ content.ContentDocumentId);
                
        }
    }
    

}