trigger ChatterFileSizeLimitOnFeedItem on FeedItem (before insert) {
/*
 * Trigger Name: ChatterFileSizeLimitOnFeedItem
 * Description: Checks for file size > 3 MB and presents user with an error if larger. This trigger is only called on first file upload, not new versions of same file. Works on Home and standard / custom object feeds.
 *
 */          
            

    //Check for file name is not Null and Type is 'Content Post'. If yes, only then fire the trigger and get the size of the document uploaded          
    List<FeedItem> lstCon = Trigger.new;
    Blob doc;   
    integer docSize;
    integer chatterFileSizeLimit;
    string errorMessage;
    
    //The following 4 lines refers to the Custom Setting "ChatterLimits__c" Custom settings are used for File size limit and Error Message to avoid hardcoding in trigger.
  
    //ChatterLimits__c chatterFileSize = ChatterLimits__c.getInstance('MaxFileUploadSize'); 
    //Size must be in bytes          
    chatterFileSizeLimit = 2999999;    
    //ChatterLimits__c chatterFileError = ChatterLimits__c.getInstance('ChatterFileLimitError');
    errorMessage = 'The file that you attempted to upload is over the limit of 3 MB. Please choose a smaller file and try again.';

    //Trigger.new will always return 1 record , b/c you can only upload one document at a time.
    for(FeedItem c : lstCon) {
     
        if(( c.ContentFileName != null) && c.Type=='ContentPost')
        {                                        
              doc = c.ContentData;            
              docSize =  doc.size();  
              system.debug('$$$$$$$$$$$$$$$$$'+ doc);               
              if(docSize > chatterFileSizeLimit )
              { 
                c.addError(errorMessage);    
                system.debug('$$$$$$$$$$$$$$$$$'+ errormessage);         
              }
              
        }   
    } 
}