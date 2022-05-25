public class HL_Email {
    public List<Messaging.SingleEmailMessage> QueuedMessages {get; set;}

    public HL_Email(){
        this.QueuedMessages = new List<Messaging.SingleEmailMessage>();
    }

    public void AddEmailToQueue(string[] to, string[] cc, string[] bcc, string subject, string body, boolean isHtml){
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(to);
        if(cc != null && cc.size() > 0 && !String.isBlank(cc[0]))
            msg.setCcAddresses(cc);
        if(bcc != null && bcc.size() > 0 && !String.IsBlank(bcc[0]))
            msg.setBccAddresses(bcc);
        msg.setSubject(subject);
        if(isHtml)
            msg.setHtmlBody(body);
        else
            msg.setPlainTextBody(body);
        QueuedMessages.add(msg);
    }

    public void SendQueuedMessages(){
        try{
        	Messaging.sendEmail(QueuedMessages);
        }
        //Catch Email Exception if Mail is not Enabled
        catch(System.EmailException ex){}
    }

    @AuraEnabled
    public static void SendEmail(string[] to, string[] cc, string[] bcc, string subject, string body, boolean isHtml){
       Send(new Messaging.SingleEmailMessage(), to, cc, bcc, subject, body, isHtml);
    }
    
    public static void SendEmailWithAttachment(string[] to, string[] cc, string[] bcc, string subject, string body, boolean isHtml, Messaging.EmailFileAttachment[] attachments){
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setFileAttachments(attachments);
        Send(msg, to, cc, bcc, subject, body, isHtml);
    }

    private static void Send(Messaging.SingleEmailMessage msg, string[] to, string[] cc, string[] bcc, string subject, string body, boolean isHtml){
        msg.setToAddresses(to);
        if(cc != null && cc.size() > 0 && !String.isBlank(cc[0]))
            msg.setCcAddresses(cc);
        if(bcc != null && bcc.size() > 0 && !String.IsBlank(bcc[0]))
            msg.setBccAddresses(bcc);
        msg.setSubject(subject);
        if(isHtml)
            msg.setHtmlBody(body);
        else
            msg.setPlainTextBody(body);
        
        try{
        	Messaging.sendEmail(new Messaging.Email[] {msg});
        }
        //Catch Email Exception if Mail is not Enabled
        catch(System.EmailException ex){}
    }
}