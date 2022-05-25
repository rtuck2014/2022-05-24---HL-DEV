public with sharing class EmailMessageController {
        
    @AuraEnabled
    public static List<SObject> search(String searchString) {
        List<SObject> searchList = new List<SObject>();
        try {
            String searchStr = '*' + searchString + '*';
            String searchquery =
                'FIND\'' +
                searchStr +
                '\'IN ALL FIELDS RETURNING Contact(id, name, firstname,lastname, email where email != null) LIMIT 10';
            List<List<SObject>> searchResult = search.query(searchquery);
            for (List<SObject> curList : searchResult) {
                searchList.addAll(curList);
            }
            system.debug('searchList:::' + searchList.size());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return searchList;
    }

    @AuraEnabled
    public static void sendEmailController(String emailDetailStr) {
        EmailWrapper emailDetails = (EmailWrapper) JSON.deserialize(emailDetailStr, EmailWrapper.class);
        System.debug('emailDetails:'+emailDetails);
        Messaging.reserveSingleEmailCapacity(1);
        try {
            List<messaging.SingleEmailMessage> mailList = new List<messaging.SingleEmailMessage>();
            Set<Id> docIdSet = new Set<Id>();
            if(emailDetails.files!=null){
                for(FileWrapper fw : emailDetails.files){
                   docIdSet.add(fw.contentVersionId);
                }
            }
            for(String contactId : emailDetails.contactIdList){
                messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
                mail.setTargetObjectId(contactId);
                mail.setWhatId(emailDetails.whatId);
                mail.setTemplateId(emailDetails.templateId);
                mail.setSaveAsActivity(true);
                if(!docIdSet.isEmpty()){                
                    mail.setEntityAttachments(new list<Id>(docIdSet));
                }
                mailList.add(mail);
            }
            //mail.setTargetObjectId('0035A00003eIi0XQAS');
            //mail.setToAddresses(emailDetails.toAddress);
            //mail.setCcAddresses(emailDetails.ccAddress);
            //mail.setReplyTo('test.k@xyz.com');
            //mail.setSenderDisplayName('Test');
            
            //mail.setSubject(emailDetails.subject);
            //mail.setHtmlBody(emailDetails.body);
            
            
            Messaging.sendEmail(mailList);
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class EmailWrapper {
        public List<String> toAddress;
        public List<String> ccAddress;
        public String subject;
        public String body;
        public List<FileWrapper> files;
        public String templateId;
        public String whatId;
        public List<String> contactIdList;
    }

    class FileWrapper {
        
        public String name;
        public String documentId;
        public String contentVersionId;
        public String contentBodyId;
        public String mimeType;
    }

    /*@AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody, String leadId,String folderId,String templateId ){
    
        string leadName = '';
        String leadOwnerName = '' ;
        
        list<EmailTemplate> em = new list<EmailTemplate>();
        em = [SELECT Id,Subject,Body,HtmlValue From EmailTemplate where id =: templateId limit 1];
        
        if(leadId != null ){ 
            Lead ldObj = [select id,name,Owner.Name from Lead where Id =: leadId];
            leadName = ldObj.name;
            if(ldObj.Owner.Name != null){
                leadOwnerName = String.ValueOf(ldObj.Owner.Name);
            }
        }
        List<EmailMessage> emailmessageList =  new List<EmailMessage>();
        emailmessageList = [select id, Subject,TextBody from emailmessage where EmailTemplateId =: templateId order By createddate desc limit 1];
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('HIC Global Solutions'); 
        mail.setSubject(mSubject);
        
        string htmlReplace = '' ;
		if(mbody != null && mbody != ''){
			htmlReplace = mbody; 
		}
        
		if(htmlReplace != null &&  htmlReplace.containsIgnoreCase('{!Lead.Name}')){
			htmlReplace = htmlReplace.replace('{!Lead.Name}',leadName)+'<br/>'; 
		}
		if(htmlReplace != null &&  htmlReplace.containsIgnoreCase('{!Lead.OwnerFullName}')){
			htmlReplace = htmlReplace.replace('{!Lead.OwnerFullName}',leadOwnerName)+'<br/>'; 
		}
         
        mail.setHtmlBody(mbody);
        mail.setTargetObjectId(leadId); 
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setTreatBodiesAsTemplate(true);
        mail.setTemplateId(em.get(0).id);
        mails.add(mail);
        
        Messaging.sendEmail(mails);
    }   
    
    @AuraEnabled
    public static list<emailTemplateWrapper> getEmailTemplates(){
        list<emailTemplateWrapper> emailTemplateWrapperlist = new list<emailTemplateWrapper>();
        
        map<String,emailTemplateWrapper> folderIdVsTemplateMap = new map<String,emailTemplateWrapper>();
        Folder folderObj = new folder();
        folderObj= [SELECT Id,Name FROM Folder where Name='Custom Email Template'];
        for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true and FolderId =: folderObj.Id ]){ 
            if( folderIdVsTemplateMap.containskey( String.valueof(emailtemp.get('FolderId'))) ){
                
                EmailTemplates template = new EmailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                folderIdVsTemplateMap.get( String.valueof(emailtemp.get('FolderId')) ).emailtemplatelist.add( template );
                
            }else{
                emailTemplateWrapper tempWrap = new emailTemplateWrapper();
                tempWrap.folderId = String.valueOf(emailtemp.get('FolderId'));
                tempWrap.folderName = String.valueOf(emailtemp.get('FolderName'));
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                tempWrap.emailtemplatelist = new list<emailTemplates>{ template };
                folderIdVsTemplateMap.put( String.valueof(emailtemp.get('FolderId'))  , tempWrap );
            }   
        }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            emailTemplateWrapperlist.addAll( folderIdVsTemplateMap.values() );
            
            return emailTemplateWrapperlist;
        }
        return null;
    }
    
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  */
}