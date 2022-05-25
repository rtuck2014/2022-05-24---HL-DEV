public with sharing class HL_EmailController {
    public HL_EmailMerge EmailMerge {get; set;}
    public static List<String> PrimaryContactWithNoEmailTitle {get; set;}
    public static Boolean PrimaryContactWithNoEmailTitleSize {get; set;}
        public static Boolean BillingContactWithNoEmailTitleSize {get; set;}
    public static List<String> BillingContactWithNoEmailTitle {get; set;}
    public Boolean PrimaryContactEmailTitleCheck{get;set;}    
    public Email_Template__c EmailTemplate {get{
        if(emailTemplate == null)
            emailTemplate = EmailMerge.EmailTemplate;
        return emailTemplate;
        } set;} 
    public List<Contact> EmailCCs {get{if(emailCCs == null){emailCCs = String.isBlank(EmailTemplate.Additional_Distribution_Group__c) ? new List<Contact>() : new List<Contact> {HL_Contact.GetById(EmailTemplate.Additional_Distribution_Group__c)};} return emailCCs;} set;}
    public Id DelId {get; set;}
    public String SelectedCCId {get; set;}
    public String SelectedCCName {get; set;}
    public String CustomCCFilter{get {return 'AND (RecordType.Name = \'Houlihan Employee\' OR RecordType.Name = \'Distribution Lists\') AND Status__c = \'Active\'';}set;}
    public Transient String EmailFileName {get;set;}
    public Transient Blob EmailFileBody {get;set;} 
    public string formtype {get;set;}
    public String theme {get;set;}

    //Constructors
    public HL_EmailController() 
    {
       this(HL_PageUtility.GetParameter('template'), HL_PageUtility.GetParameter('ro'));
      /* list<ContentDocumentLink> CDL= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : HL_PageUtility.GetParameter('ro')];
       Note&Attachments =[Select Id ,Title from ContentDocument Where ID =: CDL[0].ContentDocumentId];
       system.debug('notesAndAttachments=='+ HL_PageUtility.GetParameter('ro'));
       system.debug('CD=='+ CD);*/
       formtype= HL_PageUtility.GetParameter('template');
       system.debug('formtype=='+ formtype);
       
    }
    
    public HL_EmailController(string templateName, string relatedId){
        
        PrimaryContactWithNoEmailTitleSize = false;
        BillingContactWithNoEmailTitleSize = false;
        PrimaryContactEmailTitleCheck = true;
        if(templateName == 'Billing_Request'){
            PrimaryContactEmailTitleCheck = validatePrimaryBillingContactEmailTitle();
        }
        this.EmailMerge = new HL_EmailMerge(templateName, relatedId);
        //Merge the Data
        this.EmailMerge.MergeData(true);
    }

    // To check if Primary/Billing contact has email and title populated or not
        public static Boolean validatePrimaryBillingContactEmailTitle(){
        PrimaryContactWithNoEmailTitle = new List<String>();
        BillingContactWithNoEmailTitle = new List<String>();
        Set<String> BillingContactWithNoEmailTitleSet = new Set<String>();
        boolean PrimaryBillingContactHasEmailAndTitle  = true;
                String roId = ApexPages.currentPage().getParameters().get('ro');
                
        if(roId != null && roId != ''){
                       
            for(Engagement_External_Team__c allEngExtTeam : [SELECT Id,Contact__c,Contact__r.Name,Billing_Contact__c,Primary__c FROM Engagement_External_Team__c 
                        WHERE Engagement__c=:roId  AND (Contact__r.Title = null OR Contact__r.Email = null) AND (Primary__c = true OR Billing_Contact__c = true)]){
                
                                if(allEngExtTeam.Primary__c){
                                        PrimaryContactWithNoEmailTitle.add(allEngExtTeam.Contact__r.Name);
                    PrimaryContactWithNoEmailTitleSize = true;
                                } else {
                                        BillingContactWithNoEmailTitleSet.add(allEngExtTeam.Contact__r.Name);
                    BillingContactWithNoEmailTitleSize = true;
                                }
                                PrimaryBillingContactHasEmailAndTitle  = false;
            }
            BillingContactWithNoEmailTitle.addAll(BillingContactWithNoEmailTitleSet);

        }
        
                return PrimaryBillingContactHasEmailAndTitle;
        }
        
    public PageReference SendEmail(){
        List<String> emailCCList = new List<String>();

system.debug('EmailCCs='+EmailCCs);
        for (Contact c: EmailCCs) 
            emailCCList.add(c.Email);
system.debug('emailCCList='+emailCCList);
        if(EmailTemplate.Name == 'NBC' || EmailTemplate.Name == 'NBC_L')
            SendNBCEmail(HL_PageUtility.GetParameter('ro'), emailCCList);
        
                if(EmailTemplate.Name == 'CNBC' || EmailTemplate.Name == 'CNBC_L')
            SendCNBCEmail(HL_PageUtility.GetParameter('ro'), emailCCList);
        
        if(EmailTemplate.Name == 'FEIS')
            SendFEISEmailAndReview(HL_PageUtility.GetParameter('ro'), emailCCList);

        //CNBC/NBC/FEIS use their own methods, everything else should be sent either with attachments or without
        if(!(new Set<String>{'CNBC','NBC', 'FEIS', 'NBC_L', 'CNBC_L'}).contains(EmailTemplate.Name)){
        //Send Attachment Emails - only when the User adds them DIRECTLY on the Send Email page
            if(EmailFileName != null && EmailFileBody != null){
                Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
                emailAttach.setFileName(EmailFileName);
                emailAttach.setBody(EmailFileBody);
                SendWithAttachment(EmailTemplate.Distribution_Group__c, emailCCList , EmailTemplate.Email_Subject__c, EmailTemplate.Template_Body__c, new Messaging.EmailFileAttachment[] {emailAttach});
            }
            else
                Send(EmailTemplate.Distribution_Group__c, emailCCList, EmailTemplate.Email_Subject__c, EmailTemplate.Template_Body__c);
         }

         if(EmailTemplate.Name == 'FR_Summary'){
               UpdateEngagement();
         }

        /*PageReference dest;
        String roId2 = ApexPages.currentPage().getParameters().get('ro');
        String formtype = ApexPages.currentPage().getParameters().get('template');
        
        if(formtype.CONTAINS('_L'))
        {            
            dest=new PageReference('/lightning/r/Opportunity_Approval__c/'+roId2+'/view?0.source=alohaHeader');
            dest.setRedirect(true);        
        }
        else
        {        
            dest=new PageReference(HL_PageUtility.GetParameter('retURL'));
        }
        return dest;    */
        return Cancel();
    }
    
    private void UpdateEngagement(){
        Engagement__c e = HL_Engagement.GetById(HL_PageUtility.GetParameter('ro'));
        if(e.One_Pager_Completed_Date__c == null){
            e.One_Pager_Completed__c = true;
            e.One_Pager_Completed_By__c = UserInfo.getName();
            e.One_Pager_Completed_Date__c = DateTime.now();
            update e; 
        }
    }
    
    private Boolean ShouldSendToLegal(Opportunity_Approval__c oa){
        return
            (oa.Form_Type__c == 'NBC' && (oa.Conflicts_2a_Not_Listed__c=='Yes' || oa.Conflicts_3a_Related_to_Transaction__c=='Yes' || oa.Conflicts_35a_Related_to_Client__c=='Yes' || oa.Conflicts_4a_Conflict_of_Interest__c=='Yes' || oa.Conflicts_5a_Other_Conflicts__c=='Yes' ) && !oa.Submitted_to_Legal__c) || (oa.Form_Type__c == 'FEIS' && ( oa.Conflicts_3a_Related_to_Transaction__c=='Yes' || oa.Conflicts_35a_Related_to_Client__c=='Yes' || oa.Conflicts_4a_Conflict_of_Interest__c=='Yes' || oa.Conflicts_5a_Other_Conflicts__c=='Yes' ) && !oa.Submitted_to_Legal__c);
    }

    private void SendNBCEmail(Id id, String[] emailCCList){
        Opportunity_Approval__c oa = HL_OpportunityApproval.GetById(id);
        //legal won't fire if we dont use a query
        if(ShouldSendToLegal(oa)){
            HL_EmailController.SendFromTemplate(HL_EmailController.GetTemplate('LegalNBC', oa.Id), new string[]{}, EmailFileAttachments);    
            oa.Submitted_to_Legal__c = TRUE;
            update oa;
         }
        
        system.debug('EmailFileAttachments=='+ EmailFileAttachments);
        HL_EmailController.SendFromTemplate(EmailTemplate, emailCCList, EmailFileAttachments);
        
        if(oa.Date_Submitted__c == null){
            oa.Date_Submitted__c = date.today();
            update oa;
        }
    }
    
    private void SendCNBCEmail(Id id, String[] emailCCList){
        Opportunity_Approval__c oa = new Opportunity_Approval__c(Id = id);

        HL_EmailController.SendFromTemplate(EmailTemplate, emailCCList, EmailFileAttachments);
        
        if(oa.Date_Submitted__c == null){
            oa.Date_Submitted__c = date.today();
            update oa;
        }
    }

    private void SendFEISEmailAndReview(Id id, String[] emailCCList){
        //check if the User has added any attachments directly to the Send Email page, add attachments (if any) to an array for SendFromTemplate, otherwise it'll be NULL
        Messaging.EmailFileAttachment[] emailAttachArray = new Messaging.EmailFileAttachment[]{};
        if(EmailFileName != null && EmailFileBody != null){
            Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
            emailAttach.setFileName(EmailFileName);
            emailAttach.setBody(EmailFileBody);
            emailAttachArray.add(emailAttach);
        }

        Opportunity_Approval__c oa = HL_OpportunityApproval.GetById(id);
        if(ShouldSendToLegal(oa)){
            HL_EmailController.SendFromTemplate(HL_EmailController.GetTemplate('LegalFEIS', oa.Id), emailCCList, emailAttachArray);   
            oa.Submitted_to_Legal__c = TRUE;
            update oa;
         }

        HL_EmailController.SendFromTemplate(EmailTemplate, emailCCList, emailAttachArray);

        oa.Reviewed__c = TRUE;
        oa.Date_Submitted__c = date.today();
        update oa;
    }

    @AuraEnabled
    public static void SendJSON(string contactId, string ccsJSON, string emailSubject, string emailBody){
        string[] emailCCs = new string[] {};
        //Convert the cc JSON to Contact Objects
        List<Contact> ccs = HL_JSONUtility.ConvertJSONToListOfSObject('Contact', ccsJSON);
        for(Contact c : ccs)
            emailCCs.add(c.Email);     
            
        Send(contactId, emailCCs, emailSubject, emailBody);    
    }
    
    @AuraEnabled
    public static void Send(string contactId, string[] emailCCs, string emailSubject, string emailBody){   
        Contact c = HL_Contact.GetById(contactId);
        string[] emailTo = new string[] {c.Email};
        string[] emailBcc = new string[] {HL_Contact.GetByUserId().Email};
        HL_Email.SendEmail(emailTo, emailCCs, emailBcc, emailSubject, emailBody, true);
    }
    
    private static void SendFromTemplate(Email_Template__c et, string[] emailCCs, Messaging.EmailFileAttachment[] attachments){
        system.debug('et.Distribution_Group__c='+et.Distribution_Group__c);
        system.debug('emailCCs='+emailCCs);
        system.debug('attachments='+attachments);
        if(attachments == null)
            Send(et.Distribution_Group__c, emailCCs, et.Email_Subject__c, et.Template_Body__c);
        else
            SendWithAttachment(et.Distribution_Group__c, emailCCs, et.Email_Subject__c, et.Template_Body__c, attachments);
    }
    
    public static void SendWithAttachment(string contactId, string[] emailCCs, string emailSubject, string emailBody, Messaging.EmailFileAttachment[] attachments){   
        Contact c = HL_Contact.GetById(contactId);
        string[] emailTo = new string[] {c.Email};
        string[] emailBcc = new string[] {HL_Contact.GetByUserId().Email};
        HL_Email.SendEmailWithAttachment(emailTo, emailCCs, emailBcc, emailSubject, emailBody, true, attachments);
    }
    
    public static PageReference Cancel()
    {
        PageReference dest;
        string themeDisplayed = UserInfo.getUiThemeDisplayed();
        string theme = UserInfo.getUiTheme();
        Map<String,String> paramMap = ApexPages.currentPage().getParameters();
        String roId2 = paramMap.get('ro');
        String formtype = paramMap.get('template');        
        if(paramMap.containsKey('isFromOutlook') && paramMap.get('isFromOutlook')=='true'){
            System.debug('inside outlook...'+HL_PageUtility.GetParameter('retUrl'));
            dest=new PageReference(HL_PageUtility.GetParameter('retUrl'));
            dest.setRedirect(true);
        }
        else if(formtype.CONTAINS('_L'))
        {            
            System.debug('inside _L:');
            dest=new PageReference('/lightning/r/Opportunity_Approval__c/'+roId2+'/view?0.source=alohaHeader');
            dest.setRedirect(true);        
        }
        else
        {
            System.debug('theme is:'+theme+' displayed:'+themeDisplayed);
            System.debug('no _L attempting to return to:'+HL_PageUtility.GetParameter('retURL'));
            dest=new PageReference(HL_PageUtility.GetParameter('retURL'));
        }
        return dest;      
    }

    @AuraEnabled
    public static Email_Template__c GetTemplate(string templateName, string relatedId){
        HL_EmailController ec = new HL_EmailController(templateName, relatedId);
        return ec.EmailTemplate;
    }

     public void AddCC(){
        if(SelectedCCId <> '')
        {
            EmailCCs.add(HL_Contact.GetById(SelectedCCId));
            SelectedCCId = null;
            SelectedCCName = null;
        }
    }

    //Removes the Employee
    public void RemoveCC(){
        if(!String.isBlank(DelId))
        {
            for(Integer i=0;i<EmailCCs.size();i++){
                if(EmailCCs[i].Id == DelId)
                {
                    EmailCCs.remove(i);
                    break;
                }
            }
        }
    }

    //ayu added to show attachments on NBC/CNBC email submissions
    public List<Attachment> notesAndAttachments {
       
        get{
            //if(notesAndAttachments == null)
                notesAndAttachments = [SELECT Id, Name, LastModifiedDate, LastModifiedById, Body FROM Attachment WHERE ParentId =: ApexPages.currentPage().getParameters().get('ro')];  //HL_PageUtility.GetParameter('ro')
            return notesAndAttachments;
        }
        set;
        
    }
    
    public Transient list<ContentDocumentLink> CDL {get;set;}
    public set<id> listid= new set<id>();
    public boolean attachments;
    
    public Transient list<ContentVersion> NoteAttachments {
       
        get{
            if(NoteAttachments == null && (formtype=='NBC_L' || formtype=='CNBC_L'))
               CDL= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : HL_PageUtility.GetParameter('ro')];
               if(CDL.size()>0)
               {
                   for(ContentDocumentLink c: CDL)
                   listid.add(C.ContentDocumentId);  
                   attachments=true;                   
               }
               if(listid.size()>0)
                   NoteAttachments =[Select Id ,Title, LastModifiedDate, LastModifiedById, VersionData, FileExtension from ContentVersion Where ContentDocumentId =: listid];
            return NoteAttachments;
        }
        set;
        
    }

    private List<Messaging.Emailfileattachment> EmailFileAttachments{
        get{
            if(emailFileAttachments == null && !formtype.CONTAINS('_L') ){
                emailFileAttachments = new List<Messaging.Emailfileattachment>();

                for(Attachment a : notesAndAttachments){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    emailFileAttachments.add(efa);
                }
            }
            else if(emailFileAttachments == null && formtype.CONTAINS('_L') ){
            emailFileAttachments = new List<Messaging.Emailfileattachment>();
            if(attachments==true)
            {
                for(ContentVersion a : NoteAttachments){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                Blob fileData = a.VersionData; 
                efa.setFileName(a.FileExtension);
                efa.setBody(fileData);
                emailFileAttachments.add(efa);
                    
                }
             }
            }
            return emailFileAttachments;
        }
        set;
    }

}