/*******************************************************************************
* Purpose : To override New record functionality of Contact Comment
* Test Class  : Test_HL_ContactCommentController
********************************************************************************/
Public class HL_ContactCommentController {
    // Public Properties
    Public Contact_Comment__c ContCommentNew{get; set;}    
    Public Id RelatedContactId;
    
    // Constructor
    public HL_ContactCommentController(ApexPages.StandardController controller){
        RelatedContactId = ApexPages.currentPage().getParameters().get('ContactId');     
        if(RelatedContactId == null)
        {
            String InitialURL = ApexPages.currentPage().getParameters().get('retURL');
            String decodedURL = EncodingUtil.urlDecode(InitialURL , 'UTF-8');
            
            Integer indexpositionRLID = decodedURL.indexOf('rlid='); 
            if(indexpositionRLID != -1){                
                String ModifieddecodedURL = decodedURL.subString(indexpositionRLID+5 ,decodedURL.length());  
                decodedURL = ModifieddecodedURL ;                
            }
            system.debug('****'+decodedURL);
            Integer indexposition = decodedURL.indexOf('id='); 
            if(indexposition  != -1){                
                String ModifieddecodedURL = decodedURL.subString(indexposition ,decodedURL.length());  
                decodedURL = ModifieddecodedURL ;                
            }
            system.debug('****'+decodedURL);                      
            indexposition = decodedURL.indexOf('id='); 
            Integer indexposition2 = decodedURL.indexOf('&'); 
            system.debug(decodedURL.length()+'***'+indexposition+'****'+indexposition2);
            if(indexposition  != -1 && indexposition2 != -1)
            {                  
                if(decodedURL.length()>  indexposition+3 && decodedURL.length()>  indexposition2 )
                    RelatedContactId  = decodedURL.subString(indexposition+3,indexposition2);                
            }
            else if(indexposition  != -1 && indexposition2 == -1)
            {
                if(decodedURL.length()>  indexposition+3)
                    RelatedContactId  = decodedURL.subString(indexposition+3,decodedURL.length());   
            }
        }
        ContCommentNew = new Contact_Comment__c();
        ContCommentNew = (Contact_Comment__c)controller.getRecord();
        ContCommentNew.Related_Contact__c = RelatedContactId;
        ContCommentNew.Comment_Type__c = 'Compliance';     
    }
    public PageReference SaveRecord(){    
        try
        {    
            insert ContCommentNew;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/'+RelatedContactId);
    }
    
    public PageReference SaveNewRecord(){    
        try{    
            insert ContCommentNew;
        }catch(Exception e) 
        {
            ApexPages.addMessages(e);
            return null;
        }
        PageReference Pg  = new PageReference('/apex/HL_ContactCommentNew?ContactId='+RelatedContactId); 
        Pg.setRedirect(true);
        return Pg;
    }
    
    public PageReference CancelRecord(){    
        return new PageReference('/'+RelatedContactId);
    }    
}