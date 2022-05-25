public with sharing class HL_EmailMerge {
    public String TemplateName {get; set;}
    public Id RecordId {get; set;}
    public Email_Template__c EmailTemplate {get{
        if(emailTemplate == null)
            emailTemplate = HL_EmailTemplate.GetByName(TemplateName);
        
        return emailTemplate;
    } set;} 
    private sObject PrimaryObject {get; set;}
    
    public HL_EmailMerge(string templateName, Id recordId) {
        this(templateName, recordId, null);
    }
    
    public HL_EmailMerge(string templateName, Id recordId, sObject primaryObject) {
        this.TemplateName = templateName;
        this.RecordId = recordId;
        this.PrimaryObject =  primaryObject != null ? primaryObject : GetPrimaryEmailObject();
    }
    
    public HL_EmailMerge MergeData(Boolean clearUnmatchedFields){
        //Merge Subject
        MergeSubjectFields();
        
        //Merge Body
        EmailTemplate.Template_Body__c = MergeFields(EmailTemplate.Related_Object__c, EmailTemplate.Template_Body__c);  
        if(clearUnmatchedFields)
            ClearUnmatchedFields();
        
        return this;
    }
    
    private void MergeSubjectFields(){
        if(PrimaryObject != null){
            //Merge Subject
            if(TemplateName == 'CF_FEIS' || TemplateName == 'FEIS' || TemplateName == 'NBC' ||  TemplateName == 'NBC_LOB'|| TemplateName =='CNBC' || TemplateName == 'CNBC_LOB' || TemplateName=='LegalNBC')
                EmailTemplate.Email_Subject__c += ' ' + ((Opportunity_Approval__c)PrimaryObject).Related_Opportunity__r.Name + ' - ' + ((Opportunity_Approval__c)PrimaryObject).Client_Company__c;
            else if(TemplateName == 'Event')
                EmailTemplate.Email_Subject__c = ((Event)PrimaryObject).Subject;
            else if(TemplateName == 'Billing_Request_VP')
                EmailTemplate.Email_Subject__c +=' ' + ((Eng_VP__c )PrimaryObject).Engagement__r.Engagement_Number__c +' - '+((Eng_VP__c )PrimaryObject).Engagement__r.Client__r.Name ;
            else if(TemplateName == 'FR_Summary')
                EmailTemplate.Email_Subject__c += ' ' + ((Engagement__c)PrimaryObject).Name;
            else if(TemplateName == 'Gift_Log_Status')
                EmailTemplate.Email_Subject__c += ' ' + ((Gift__c)PrimaryObject).Approved__c;
            else if (TemplateName == 'Billing_Request')
                EmailTemplate.Email_Subject__c += ' ' + ((Engagement__c)PrimaryObject).Engagement_Number__c + ' - ' + ((Engagement__c)PrimaryObject).Client__r.Name;
        }
    }
    
    private sObject GetPrimaryEmailObject(){
        return !String.isBlank(RecordId) ? (EmailTemplate.Related_Object__c == 'Engagement__c' ? HL_Engagement.GetMailMerge(RecordId) :
                                            EmailTemplate.Related_Object__c == 'Event' ? HL_Event.GetById(RecordId) : 
                                            EmailTemplate.Related_Object__c == 'Eng_VP__c' ? HL_EngValuationPeriodPositions.GetById(RecordId) : 
                                            EmailTemplate.Related_Object__c == 'Gift__c' ? HL_Gift.GetById(RecordId) : (sObject)HL_OpportunityApproval.GetById(RecordId)) : null;
    }
    
    private string MergeFields(String objectType, string body){
        string ms = '';  //Merge Section
        system.debug('bodyMergeFieldsEntry>>>'+body);
        
        Map<String,Object> fieldsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(PrimaryObject));
        
        if(!String.isBlank(body))
        {
            //Merge the Primary Object Fields
            for(String key : fieldsMap.keySet()){
                if(key.contains('Date')){
                    body = body.replace('{!' + key + '}', MergeDateField(objectType,key,fieldsMap.get(key))) ;
                }else if(String.valueOf(fieldsMap.get(key)) != null && String.valueOf(fieldsMap.get(key)).contains('\n')){
                   
                    String textValue = String.valueOf(fieldsMap.get(key)).replace('\n','<br/>');
                    body = body.replace('{!' + key + '}' , textValue); 
                                                                  
                }else{
                    body = body.replace('{!' + key + '}' , String.valueOf(fieldsMap.get(key))); 
                    
                }
            }
            system.debug('bodyMergeFields>>>'+body);
            //Check for Generic User Detail Fields
            if(body.contains('{!User}') || body.contains('{!Office}'))
                body = MergeUserFields(body);
            
            if(objectType == 'Engagement__c')
                body = MergeEngagementFields(body);
            else if(objectType == 'Event')
                body = MergeEventFields(body);
            else if(objectType == 'Eng_VP__c')
                body = MergeEngVPFields(body);
            else if(objectType == 'Opportunity_Approval__c')
                body = MergeOpportunityApprovalFields(body);
            
            //Merge Generic Fields
            body = body.replace('{!Today}', Date.today().format())
                .replace('{!Now}', DateTime.now().format())
                .replace('{!Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' + PrimaryObject.Id);
        }
        else
            body = '';
        
        return body;
    }
    
    //Clears the Unmatched Merge Fields
    public HL_EmailMerge ClearUnmatchedFields(){
        Pattern p = Pattern.compile('(\\{[{!])\\w+}');
        EmailTemplate.Template_Body__c = p.matcher(EmailTemplate.Template_Body__c).replaceAll('');
        return this;
    }
    
    private string MergeUserFields(string body){
        Contact u = HL_Contact.GetByUserId();
        return body.replace('{!User}',u.Name)
            .replace('{!Office}',u.Office__c);
    }
    
    private string MergeDateField(String objectType, String field, Object oValue){
        string retVal;
        try{
            if(objectType == 'Gift__c' && field == 'Desired_Date__c')
                retVal = String.valueOf(oValue).left(10);
            else
                retVal = HL_DateUtility.FormatJSDate(String.valueOf(oValue));
        }
        catch(Exception e){
            retVal = String.valueOf(oValue);
        }
        
        return retVal;
    }
    
    private string MergeEngagementFields(string body){
        Engagement__c e = (Engagement__c)PrimaryObject;
        body = body.replace('{!Client__r.Name}', e.Client__r.Name);
        body = body.replace('{!Engagement__r.Retainer}', e.Retainer__c != null && e.Retainer__c != 0? e.Retainer__c.format() : '');
        
        //Check for Billing Contact
        List<Engagement_External_Team__c> team = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.Title FROM Engagement_External_Team__c WHERE Billing_Contact__c = true AND Engagement__c =: e.ID];
        
        if (team.size() > 0 && team[0].Contact__r != null) {
            body = body.replace('{!Primary_External_Contact__r.Name}', (String.isBlank(team[0].Contact__r.Name) ? 'N/A' : team[0].Contact__r.Name));
            body = body.replace('{!Primary_External_Contact__r.Title}', (String.isBlank(team[0].Contact__r.Title) ? 'N/A' : team[0].Contact__r.Title));
            body = body.replace('{!Primary_External_Contact__r.Email}', (String.isBlank(team[0].Contact__r.Email) ? 'N/A' : team[0].Contact__r.Email));
        }
        else if(e.Primary_External_Contact__c <> null) {
            body = body.replace('{!Primary_External_Contact__r.Name}', (String.isBlank(e.Primary_External_Contact__r.Name) ? 'N/A' : e.Primary_External_Contact__r.Name));
            body = body.replace('{!Primary_External_Contact__r.Title}', (String.isBlank(e.Primary_Contact_Title__c) ? 'N/A' : e.Primary_Contact_Title__c));
            body = body.replace('{!Primary_External_Contact__r.Email}', (String.isBlank(e.Primary_Contact_Email__c) ? 'N/A' : e.Primary_Contact_Email__c));
        }
        
        //Check for Billing Contact or Primary Contact
        List<Engagement_External_Team__c> PrimaryOrBillingContact = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.Title FROM Engagement_External_Team__c WHERE Billing_Contact__c = true AND Primary__c = true AND Engagement__c =: e.ID];
        
        if(PrimaryOrBillingContact.size() == 0){
            
            body = body.replace('{!Primary_External_Contact__r.Name}', System.Label.HL_NoBillingContactOnEng);
            body = body.replace('{!Primary_External_Contact__r.Title}', '');
            body = body.replace('{!Primary_External_Contact__r.Email}', '');
        }
        
        return body;
    }
    
    private string MergeEngVPFields(string body){
        Eng_VP__c eVP = (Eng_VP__c)PrimaryObject;
        Decimal ReportFeeTotal = 0;
        body = body.replace('{!Client__r.Name}', eVP.Engagement__r.Client__r.Name);
        body = body.replace('{!Engagement__r.Opportunity_Number__c}', (String.isBlank(eVP.Engagement__r.Opportunity_Number__c) ? 'N/A' : eVP.Engagement__r.Opportunity_Number__c));
        body = body.replace('{!Engagement__r.Client_Number__c}', (String.isBlank(eVP.Engagement__r.Client_Number__c) ? 'N/A' : eVP.Engagement__r.Client_Number__c));
        body = body.replace('{!Engagement__r.Client_Billing_Address__c}', (String.isBlank(eVP.Engagement__r.Client_Billing_Address__c) ? 'N/A' : eVP.Engagement__r.Client_Billing_Address__c));
        //Check for Billing Contact
        List<Engagement_External_Team__c> team = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.Title FROM Engagement_External_Team__c WHERE Billing_Contact__c = true AND Engagement__c =: eVP.Engagement__c];
        
        if (team.size() > 0 && team[0].Contact__r != null) {
            body = body.replace('{!Engagement__r.Primary_External_Contact__r.Name}', (String.isBlank(team[0].Contact__r.Name) ? 'N/A' : team[0].Contact__r.Name));
            body = body.replace('{!Engagement__r.Primary_Contact_Title__c}', (String.isBlank(team[0].Contact__r.Title) ? 'N/A' : team[0].Contact__r.Title));
            body = body.replace('{!Engagement__r.Primary_Contact_Email__c}', (String.isBlank(team[0].Contact__r.Email) ? 'N/A' : team[0].Contact__r.Email));
        }
        else {
            body = body.replace('{!Engagement__r.Primary_External_Contact__r.Name}', (String.isBlank(eVP.Engagement__r.Primary_External_Contact__r.Name) ? 'N/A' : eVP.Engagement__r.Primary_External_Contact__r.Name));
            body = body.replace('{!Engagement__r.Primary_Contact_Title__c}', (String.isBlank(eVP.Engagement__r.Primary_Contact_Title__c) ? 'N/A' : eVP.Engagement__r.Primary_Contact_Title__c));
            body = body.replace('{!Engagement__r.Primary_Contact_Email__c}', (String.isBlank(eVP.Engagement__r.Primary_Contact_Email__c) ? 'N/A' : eVP.Engagement__r.Primary_Contact_Email__c));
        }
        
        body = body.replace('{!Engagement__r.Transaction_Description__c}', (String.isBlank(eVP.Engagement__r.Transaction_Description__c) ? 'N/A' : eVP.Engagement__r.Transaction_Description__c));
        
        String reportFeeTypeValue = Apexpages.currentpage().getparameters().get('reportFeeType');
        //UserInfo.getDefaultCurrency()
        string mergeCompanyReport = '<br /><table><tr><th align="left">Company Name</th><th>Report Fee ($)</th></tr>';
        string msVPP = ''; //Merge Section
        
        for(Eng_VP_Position__c evpp : [SELECT Report_Fee__c FROM Eng_VP_Position__c WHERE Engagement_VP__c =: PrimaryObject.Id AND Status__c != 'Cancelled']){
            if(evpp.Report_Fee__c != null)
                ReportFeeTotal = ReportFeeTotal + evpp.Report_Fee__c;               
        }
        if(reportFeeTypeValue == 'IndividualReportFee'){
            for(Eng_VP_Position__c evpTable : HL_EngValuationPeriodPositions.GetEngVPPosition(PrimaryObject.Id)){
                // Removed Industry_Group_Picklist__c
                mergeCompanyReport += '<tr><td>'+evpTable.Company__r.Name+ '</td><td align="right">'  +(String.valueOf(evpTable.Report_Fee__c) == null? '' : String.valueOf((evpTable.Report_Fee__c).format())) + '</td></tr>';               
            }
            mergeCompanyReport += '</table><br />';
            body = body.replace('{!CompanyReportMapping}',mergeCompanyReport.replace('<td>null</td>','<td />'));
            
        }
        
        body = body.replace('{!TotalReportFee}', ReportFeeTotal.format());
        body = body.replace('{!Engagement__r.Retainer__c}', eVP.Engagement__r.Retainer__c != null && eVP.Engagement__r.Retainer__c != 0? eVP.Engagement__r.Retainer__c.format() : '');
        
        return body;
    }
    
    private string MergeEventFields(string body){
        system.debug('body>>>'+body);
        string ms = '';  //Merge Section
        Id id = PrimaryObject.Id;
        Event e = (Event)PrimaryObject;
        //Merge in the Internal Notes
        List<Activity_Supplement__c> s = [SELECT Internal_Notes__c FROM Activity_Supplement__c WHERE Activity__c =: e.Id];
        String internalNotes = '';
        if(s.size() > 0 && !String.isBlank(s[0].Internal_Notes__c)){
            internalNotes  =  s[0].Internal_Notes__c.replace('\n','<br/>');
        }
        body = body.replace('{!InternalNotes}', s.size() <= 0 || String.isBlank(s[0].Internal_Notes__c) ? 'N/A' : internalNotes);
        
        
        //Populate the External Attendees Section
        body = body.replace('{!External}', (e.Type == 'Internal' ? 'Internal Meeting' : 'External'));
        for(Contact c : HL_ActivityController.GetAttendees(id))
            ms += c.Name + ' - ' + (String.isBlank(c.Title) ? 'N/A' : c.Title) + ' - ' + c.Account.Name + '<br />';       
        body = body.replace('{!ExternalAttendees}',ms);
        ms = '';
        
        //Populate the Internal Employees Section
        for(Contact c : HL_ActivityController.GetEmployees(id))
            ms += c.Name + ' - ' + c.Title + '<br />';
        body = body.replace('{!HLEmployees}',ms);
        ms = '';
        
        //Populate the Companies Discussed Section
        for(Account a : HL_ActivityController.GetComps(id))
            ms += a.Name + ' - ' + a.Location__c + '<br />';
        body = body.replace('{!CompaniesDiscussed}',(String.isBlank(ms) ? 'N/A' : ms));
        ms = '';
        
        //Populate the Related Opportunities Section
        for(Opportunity__c o : HL_ActivityController.GetOpps(id))
            ms += o.Name + '<br />';
        
        body =  body.replace('{!RelatedOpportunities}',(String.isBlank(ms) ? 'N/A' : ms));
        ms = '';
        
        //Populate the Related Engagements Section
        for(Engagement__c eng : HL_ActivityController.GetEngs(id))
        ms += eng.Name + '<br />';

        return body.replace('{!RelatedEngagements}',(String.isBlank(ms) ? 'N/A' : ms));
    }
    
    
    public HL_EmailMerge MergeGiftLinks(){
        EmailTemplate.Template_Body__c = EmailTemplate.Template_Body__c.replace('{!Gift_Approval_Link}', URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SL_GiftApproval?sfdc.tabName=01ri0000000y6aZ');
        return this;
    }
    
    public HL_EmailMerge MergeGiftRecipients(List<Gift__c> recipients){
        string ms = ''; //Merge Section
        
        for(Gift__c r : recipients){
            ms += r.Recipient_Name__c + ' - ' + r.Recipient_Company_Name__c ;
            ms += '<br />Approval Number: '+r.fApproval_Number__c +'<br />  <br />' ;
        }
        
        EmailTemplate.Template_Body__c = EmailTemplate.Template_Body__c.replace('{!Gift_Recipients}', ms);
        
        return this;
    }
    
    public HL_EmailMerge MergeInvoiceFields(List<AggregateResult> engagementList){
        string ms = '';
        
        for(AggregateResult ar : engagementList)
            ms += ar.get('Name') + ' - ' + ar.get('Engagement_Number__c') + '<br />';
        
        EmailTemplate.Template_Body__c = EmailTemplate.Template_Body__c.replace('{!EngagementList}', ms);
        EmailTemplate.Template_Body__c = EmailTemplate.Template_Body__c.replace('{!Time_Manager_Link}', URL.getSalesforceBaseUrl().toExternalForm() + '/apex/HL_TimeRecordManager?sfdc.tabName=01r3100000129wJ');
        
        return this;
    }
    
    private string MergeOpportunityApprovalFields(string body){
        string ms = '';  //Merge Section
        
        Opportunity_Approval__c oa = (Opportunity_Approval__c)PrimaryObject;
        
        //Populate the Internal Team Section
        HL_InternalTeamController itc = new HL_InternalTeamController(oa.Id);
        for(HL_InternalTeamRecord t : itc.TeamRecords){
            ms += t.ContactRecord.Name + ' - ' + t.ContactRecord.Title + ' - ' + t.ContactRecord.Office__c + ' - ';
            for(String r : t.ActiveRoles)
                ms += r + ', ';
            ms = ms.subString(0, ms.length() - 2);
            ms += '<br />';
        }
        body = body.replace('{!OIT}', ms);
        ms = '<table><tr><th>Year</th><th>Type</th><th>Revenue (MM)</th><th>EBIT (MM)</th><th>EBITDA (MM)</th><th>Interest & Fee Income</th><th>Pre-Tax Income</th></tr>';
        for(Financials__c f : HL_Financials.GetByOpportunityApproval(oa.Id))
            ms += '<tr><td>' + f.Year__c + '</td><td>' + f.Type__c + '</td><td>' + f.Revenue_MM__c + '</td><td>' + f.EBIT_MM__c + '</td><td>' + f.EBITDA__c + '</td><td>' + f.Interest_and_Fee_Income__c + '</td><td>' + f.Pre_Tax_Income__c + '</td></tr>';
        ms += '</table>';
        body = body.replace('{!Financials}',ms.replace('<td>null</td>','<td />'));
        ms = '<table><tr><th>Target/Subject Company Name</th><th>Public/Private</th><th>Private Equity (%)</th><th>Market Cap (MM)</th><th>ESOP (%)</th><th>Not for Profit (%)</th><th>Insiders (%)</th></tr>';
        
        //Populate the Client Subject Section
        HL_FEISController feis = new HL_FEISController(new ApexPages.StandardController(oa));
        for(Opportunity_Client_Subject__c ocs : feis.ClientsSubjects)
            ms += '<tr><td>' + ocs.Client_Subject__r.Name + '</td><td>' + ocs.Public_Or_Private__c + '</td><td>' + ocs.Private_Equity_Ownership__c + '</td><td>' + ocs.Market_Cap_MM__c + '</td><td>' + ocs.ESOP__c + '</td><td>' + ocs.NFP__c + '</td><td>' + ocs.Insiders__c + '</td></tr>';
        ms += '</table>';
        body = body.replace('{!TargetCompanies}', ms.replace('<td>null</td>','<td />'));
        ms = '<table><tr><th>Counterparty Company Name</th><th>Public/Private</th><th>Private Equity (%)</th><th>Market Cap (MM)</th><th>ESOP (%)</th><th>Not for Profit (%)</th><th>Insiders (%)</th></tr>';
        
        //Populate the Counterparties Section
        for(Opportunity_Client_Subject__c ocs : feis.Counterparties)
            ms += '<tr><td>' + ocs.Client_Subject__r.Name + '</td><td>' + ocs.Public_Or_Private__c + '</td><td>' + ocs.Private_Equity_Ownership__c + '</td><td>' + ocs.Market_Cap_MM__c + '</td><td>' + ocs.ESOP__c + '</td><td>' + ocs.NFP__c + '</td><td>' + ocs.Insiders__c + '</td></tr>';
        ms += '</table>';
        body = body.replace('{!Counterparties}', ms.replace('<td>null</td>','<td />'));
        
        //Get Fairness Roles
        ms = '';
        itc.TeamRecords = null;
        itc.ContactStaffRolesMap = null;
        itc.SpecialRole = 'Fairness';
        for(HL_InternalTeamRecord t : itc.TeamRecords){
            ms += t.ContactRecord.Name + ' - ' + t.ContactRecord.Title + ' - ' + t.ContactRecord.Office__c + ' - ';
            for(String r : t.ActiveRoles)
                ms += r + ', ';
            ms = ms.subString(0, ms.length() - 2);
            ms += '<br />';
        }
        body = body.replace('{!Officers}', ms);
        ms = '';
        
        //Populate the Shareholder Company Section
        for(Opportunity_Client_Subject__c sc : feis.ShareholderCompanies)
            ms += String.valueOf(sc.Shareholder_Vote__c).replace('true','<b>[x]</b>').replace('false','') + ' ' + sc.Client_Subject__r.Name + '<br />';
        
        return body.replace('{!ShareholderCompanies}', ms)
            .replace('{!Related_Opportunity__r.Name}', oa.Related_Opportunity__r.Name)
            .replace('{!Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + (oa.Form_Type__c == 'FEIS' ? 'HL_FEIS?id=' : oa.Form_Type__c == 'NBC' ? 'HL_NBC?id=' : 'HL_CNBC?id=') +  PrimaryObject.Id)
            .replace('{!Notes__c}','');
    }
    
}