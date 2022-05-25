public with sharing class SL_GiftPreApprovalController {
    public String WhichController {get; set;}
    public String ProfileId {get; set;}
    public String RoleId {get; set;}
    public String UserType {get; set;}
    public String JustAdded {get; set;}
    public String SearchTextContact {get; set;}
    public String SearchOptionContact {get; set;}
    public String SearchTextAccount {get; set;}
    public String SearchOptionAccount {get; set;}
    public String SearchMessage{get; set;}
    public Gift__c Gift {get; set;}
    public Map<Id, Boolean> ContactToIsUSA;
    public ID CloneId { get; set; }
    public String IsClone { get; set; }
    public String Result { get; set; }
    public Map<String, Double> ConversionRates;
    public List<SL_GiftRecipient> AllRecipientsList { private get; set; }
    public List<SL_GiftRecipient> SelRecipientsList { private get; set; }
    public List<SL_GiftRecipient> ClientsExceedingYTD {get; set;}
    public List<Gift__c> NewGifts {get; set;}
    public Set <Id> GiftIds { get; set; }
    private String ReturnURL;
    public SL_GiftPreApprovalController() {
        ReturnURL = ApexPages.currentPage().getParameters().get('retURL');
        ContactToIsUSA = new Map<Id, Boolean>();
        ConversionRates = HL_GiftUtil.GetConversionRates();
        Gift = new Gift__c();
        List<Contact> contactOfCurrentUser = [SELECT Id FROM Contact WHERE User__c=: UserInfo.getUserId() LIMIT 1];
        Gift.Submitted_For__c = contactOfCurrentUser.isEmpty() ? null : contactOfCurrentUser[0].Id;
        SelRecipientsList = new List<SL_GiftRecipient>();
        ProfileId = UserInfo.getProfileId();
        RoleId = UserInfo.getUserRoleId();
        UserType = UserInfo.getUserType();
        CloneId = ApexPages.currentPage().getParameters().get('id');
        IsClone = ApexPages.currentPage().getParameters().get('clone');
        JustAdded = ApexPages.currentPage().getParameters().get('gifts');
        Result = IsClone;
        if (IsClone == '1') {
            this.Gift = [SELECT Name,Gift_Value__c,Gift_Value_Distributed__c,HL_Relationship__c,CurrencyIsoCode,Desired_Date__c,fApproval_Number__c,Gift_Type__c,Id,Product__c,Reason_For_Gift__c,Recipient__c,Submitted_For__c,Vendor__c FROM Gift__c WHERE id = :CloneId]; 
            Result = Gift.Name;
        }
        GiftIds=new Set<Id>();
        AllRecipientsList = new List<SL_GiftRecipient>();
    }
    public List<SL_GiftRecipient> GetAllRecipientsList () {
        AddSubmittedForContactToUSA();
        for(SL_GiftRecipient recipient: AllRecipientsList) {
            recipient.GiftValue = (Gift.Gift_Value__c==null? 0.0 : Gift.Gift_Value__c) /(Gift.currencyIsoCode==null? 1.0 : ConversionRates.get(Gift.CurrencyIsoCode));
            recipient.currencyCode=Gift.currencyIsoCode;
            recipient.IsUSA = (Gift.Submitted_For__c==null ? true : (ContactToIsUSA.get(Gift.Submitted_For__c) 
                            || (ContactToIsUSA.containsKey(recipient.recipient.Id) ? ContactToIsUSA.get(recipient.recipient.Id) : false)));
            recipient.IsFrance = Gift.Currency__c==null ? false : Gift.Currency__c=='Euro (in France)';
            recipient.IsHongKong = Gift.Currency__c==null ? false: Gift.Currency__c == 'Hong Kong Dollar';
            recipient.IsAustralia = Gift.Currency__c==null ? false: Gift.Currency__c == 'Australian Dollar';

        }
        return AllRecipientsList;
    }
    public List<SL_GiftRecipient> GetSelRecipientsList () {
        Integer recipientsize = SelRecipientsList.size(); 
        for(SL_GiftRecipient recipient: SelRecipientsList) {
            recipient.GiftValue = (Gift.Gift_Value__c==null? 0.0 : Gift.Gift_Value__c)/(Gift.currencyIsoCode==null? 1.0 : ConversionRates.get(Gift.CurrencyIsoCode));
            if(recipientsize > 1 && Gift.Gift_Value_Distributed__c){
               recipient.GiftValue = recipient.GiftValue/recipientsize; 
            }
            recipient.currencyCode=Gift.currencyIsoCode;
            recipient.IsUSA = (Gift.Submitted_For__c==null ? true : (ContactToIsUSA.get(Gift.Submitted_For__c) 
                            || (ContactToIsUSA.containsKey(recipient.recipient.Id) ? ContactToIsUSA.get(recipient.recipient.Id) : false)));
            recipient.IsFrance = Gift.Currency__c==null ? false : Gift.Currency__c=='Euro (in France)';
            recipient.IsHongKong = Gift.Currency__c==null ? false: Gift.Currency__c == 'Hong Kong Dollar';
            recipient.IsAustralia = Gift.Currency__c==null ? false: Gift.Currency__c == 'Australian Dollar';
        }
        return SelRecipientsList;
    }
    public List<SelectOption> GetSearchOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('contains','Contains')); 
        options.add(new SelectOption('exact','Exact Match')); 
        options.add(new SelectOption('startswith','Starts With')); 
        options.add(new SelectOption('endswith','Ends With'));

        return options; 
    }
    public PageReference SearchRecipients() {
        ConvertCurrencyToIso();
        AddSubmittedForContactToUSA();
        SearchTextContact = SearchTextContact.trim();
        SearchTextAccount = SearchTextAccount.trim();
        if (SearchTextContact != '' | SearchTextAccount != '') {
            String whereConditionContact = '%';
            String whereConditionAccount = '%';
            if (SearchOptionContact == 'contains') {
                whereConditionContact = '%' + SearchTextContact + '%';
            }
            else if (SearchOptionContact == 'startswith') {
                whereConditionContact = SearchTextContact + '%';
            }
            else if (SearchOptionContact == 'endswith') {
                whereConditionContact = '%' + SearchTextContact;
            }
            else if (SearchOptionContact == 'exact') {
                whereConditionContact = SearchTextContact;
            }
            if (SearchOptionAccount == 'contains') {
                whereConditionAccount = '%' + SearchTextAccount + '%';
            }
            else if (SearchOptionAccount == 'startswith') {
                whereConditionAccount = SearchTextAccount + '%';
            }
            else if (SearchOptionAccount == 'endswith') {
                whereConditionAccount = '%' + SearchTextAccount;
            }
            else if (SearchOptionAccount == 'exact') {
                whereConditionAccount = SearchTextAccount;
            }

            List<Contact> contacts;
            if (SearchTextAccount <> '') {
                contacts = [SELECT  Id,
                                    Name, 
                                    Account.Name, 
                                    MailingCountry,
                                    (SELECT Submitted_For__r.MailingCountry,
                                            Gift_Value__c
                                     FROM   Gifts__r
                                     WHERE  Approved__c = 'Approved'
                                     AND    Desired_Date__c >= THIS_YEAR
                                    )
                            FROM    Contact 
                            WHERE   (Name LIKE :whereConditionContact) 
                            AND     (Account.Name LIKE :whereConditionAccount) 
                            AND     RecordType.developerName <> 'Houlihan_Employee' 
                            ORDER BY Account.Name, Name LIMIT 1000];
            }
            else {
                contacts = [SELECT  Id,
                                    Name, 
                                    Account.Name, 
                                    MailingCountry,
                                    (SELECT Submitted_For__r.MailingCountry,
                                            Gift_Value__c
                                     FROM   Gifts__r
                                     WHERE  Approved__c = 'Approved'
                                     AND    Desired_Date__c >= THIS_YEAR
                                    )
                            FROM    Contact 
                            WHERE   (Name LIKE :whereConditionContact) 
                            AND     (Account.Name LIKE :whereConditionAccount OR Account.Name = null) 
                            AND     RecordType.developerName <> 'Houlihan_Employee' 
                            ORDER BY Account.Name, Name LIMIT 1000]; 
            }
            Map<Id, Contact> idToContact = new Map<Id, Contact>(contacts);

            Map<Id, Decimal> idToYTD = HL_GiftUtil.GetPrevYTDValue(idToContact.keySet());
            Map<Id, Decimal> idToNextYearYTD = HL_GiftUtil.GetPrevYTDNextYearValue(idToContact.keySet());
            AllRecipientsList = new List<SL_GiftRecipient>();

            for(Id contactId: idToContact.keySet()) {
                AllRecipientsList.add(new SL_GiftRecipient(idToContact.get(contactId), 
                                                           idToYTD.containsKey(contactId) ? idToYTD.get(contactId) : 0.0,
                                                           idToNextYearYTD.containsKey(contactId) ? idToNextYearYTD.get(contactId) : 0.0,
                                                           ConversionRates,Gift.Desired_Date__c,
                                                           Gift.CurrencyIsoCode));
                if (!ContactToIsUSA.keySet().contains(contactId)){
                    Boolean anyUSABasedSubmitters = false;
                    for (Gift__c previousGift: idToContact.get(contactId).Gifts__r){
                        if (previousGift.Submitted_For__r.MailingCountry=='United States'){
                            anyUSABasedSubmitters = true;
                        }
                    }
                    ContactToIsUSA.put(contactId, idToContact.get(contactId).MailingCountry=='United States' || anyUSABasedSubmitters);
                }
            }

            AllRecipientsList.sort();
            if (!contacts.isEmpty()){
                SearchMessage = 'Records returned: ' + contacts.size() + ' (max 1000).';
            }
            else{
                if (SearchTextAccount <> ''){
                    List<Account> potentialAccounts = [SELECT Id FROM Account WHERE Account.Name LIKE :whereConditionAccount];
                    if (potentialAccounts.isEmpty()){
                        SearchMessage = 'No companies were found that match search criteria.';
                    }
                    else {
                        SearchMessage = 'No contacts were found that match search criteria';
                    }
                }
                else {
                    SearchMessage = 'No contacts were found that match search criteria';
                }

            }
        }
        else {
            SearchMessage = 'You must enter at least one search term.';
        }
        if(Gift.Desired_Date__c != null && Gift.Desired_Date__c.year() > System.today().year()+1){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a date that is no more than one year from today. Dates that are more than a year in the future are not valid.');
           ApexPages.addMessage(msg);           
        }else if(Gift.Desired_Date__c != null && Gift.Desired_Date__c < System.today()){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Desired Date cannot be a past date.');
            ApexPages.addMessage(msg);          
        }
        if(Gift.Gift_Value__c <= 0.0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Gift Value cannot be 0 or less.');
           ApexPages.addMessage(msg);           
        }

        return null;
    }
    public PageReference SaveGifts() {
        try {
            if(Gift.Gift_Value__c <= 0.0){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Gift Value cannot be 0 or less.');
              ApexPages.addMessage(msg);
              return null;  
            }
            if(Gift.Desired_Date__c != null && Gift.Desired_Date__c < System.today()){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'Desired Date cannot be a past date.');
                ApexPages.addMessage(msg);
                return null;
            }
            if (SelRecipientsList.isEmpty()) {
                throw new SL_GiftLogException('You must select at least one recipient.');
            }            
            ConvertCurrencyToIso();
            ClientsExceedingYTD = new List<SL_GiftRecipient>();
            NewGifts = new List<Gift__c>();
            Integer selRepSize = SelRecipientsList.size();
            for ( SL_GiftRecipient contact : SelRecipientsList ) {
                Gift__c newGift = new Gift__c();
                newGift = Gift.clone();
                if(selRepSize > 0 && newGift.Gift_Value_Distributed__c){
                   newGift.Gift_Value__c =  newGift.Gift_Value__c/selRepSize;
                }
                contact.GiftValue = (newGift.Gift_Value__c==null? 0.0 : newGift.Gift_Value__c) /(newGift.currencyIsoCode==null? 1.0 : ConversionRates.get(newGift.CurrencyIsoCode));
                newGift.Recipient__c = contact.recipient.id;
                NewGifts.Add(newGift);
                if (contact.GetIsOver() || contact.GetNextYearIsOver()){
                    ClientsExceedingYTD.add(contact);
                }
            }
            if (!ClientsExceedingYTD.isEmpty()){
                PageReference decisionPage = new PageReference('/apex/SL_GiftDecision');
                decisionPage.setRedirect(false);
                return decisionPage;
            }

            return ProceedToCongratulations();
        }          
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;    
    }
    public PageReference Cancel() {
        if (ReturnURL!=null){
            PageReference returnPage = new PageReference(ReturnURL);
            returnPage.setRedirect(true);
            return returnPage;
        }
        return null;
    }
    public PageReference AddSelectedRecipients() {
        ConvertCurrencyToIso();
        try {
            if (AllRecipientsList.isEmpty()){
                throw new SL_GiftLogException('You must select at least one recipient to add!');
            }
            Set<Id> alreadyIn = new Set<Id>();
            for (SL_GiftRecipient recipient: SelRecipientsList){
                alreadyIn.add(recipient.recipient.Id);
            }
            for(SL_GiftRecipient recipient: AllRecipientsList) {
                if(recipient.selected == true) {
                    if (!alreadyIn.contains(recipient.recipient.Id)){
                        SelRecipientsList.add(recipient);
                    }
                    recipient.selected = false;
                }
            }
        }
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
        }

        return null;
    }
    public PageReference RemoveSelectedRecipients() {
        try {
            Integer i = 0;
            if (SelRecipientsList == null)
                SelRecipientsList = new List<SL_GiftRecipient>();

            while (i < SelRecipientsList.size()) {
                SL_GiftRecipient cur = SelRecipientsList.get(i);
                if (cur.selected == true) {
                    SelRecipientsList.remove(i);
                }
                else {
                    i++;
                }
            }

            //Refresh the Selected Recipients data to check and see if the date has changed on the gift record
            for(SL_GiftRecipient selRecipient: SelRecipientsList){  
                if(Gift.Desired_Date__c != null && (Gift.Desired_Date__c.Year() > System.Today().Year())){
                    selRecipient.IsDesiredDateNextYear = true;
                }else{
                    selRecipient.IsDesiredDateNextYear = false;
                }
            }

            if (AllRecipientsList.isEmpty()){
                throw new SL_GiftLogException('You must select at least one recipient to add!');
            }
            
            for(SL_GiftRecipient recipient: AllRecipientsList) {
                recipient.selected = false;
            }
        }
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
        }
        return AddSelectedRecipients();  //Calling the Add Recipients function will refresh the selected list with proper currency info.
    }

    private void ConvertCurrencyToIso(){
        if (Gift.Currency__c=='U.S. Dollar'){
            Gift.CurrencyIsoCode='USD';
        }
        else if (Gift.Currency__c=='Euro (in France)'||Gift.Currency__c=='Euro (not in France)' ){
            Gift.CurrencyIsoCode='EUR';
        }
        else if (Gift.Currency__c=='British Pound' ){
            Gift.CurrencyIsoCode='GBP';
        }
        else if (Gift.Currency__c=='Hong Kong Dollar'){
            Gift.CurrencyIsoCode='HKD';
        }
        else if (Gift.Currency__c=='Australian Dollar'){
            Gift.CurrencyIsoCode='AUD';
        }
    }
    private void AddSubmittedForContactToUSA(){
        if (!ContactToIsUSA.keySet().contains(Gift.Submitted_For__c)){
            List <Contact> submittedFor = [SELECT MailingCountry FROM Contact WHERE Id = :Gift.Submitted_For__c];
            if (!submittedFor.isEmpty()){
                ContactToIsUSA.put(Gift.Submitted_For__c, submittedFor[0].MailingCountry =='United States');
            }
        }

    }
    public PageReference ProceedToCongratulations(){
        try {
            Database.SaveResult[] MySaveResult = Database.Insert(NewGifts);    
            GiftIDs.clear();
            for (Gift__c newGift :NewGifts) {
                GiftIDs.add(newGift.Id);
            }
            PageReference congratsPage = new PageReference('/apex/SL_GiftCongrats');
            congratsPage.setRedirect(false);   
            return congratsPage;
        }
        catch( DmlException ex )
        {
            Set<String> messageSet = new Set<String>();
            String message = '';
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                messageSet.add(ex.getDmlMessage(i));

            }
            for (String s: messageSet){
                message += s + '\r\n'; 
            }    
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,message);
            ApexPages.addMessage(msg);
        } 
        return null;
    }
    public PageReference ReturnToPreApproval(){   
        String newReturnURL='';
        if (ReturnURL!=null){
            newReturnURL='?retURL='+ReturnURL;
        }
        PageReference preApprovalPage = new PageReference('/apex/SL_GiftPreApproval'+newReturnURL);
        preApprovalPage.setRedirect(false);
        return preApprovalPage;
    }
    public PageReference ReturnToBlankPreApproval(){   
        String newReturnURL='';
        if (ReturnURL!=null){
            newReturnURL='?retURL='+ReturnURL;
        }
        PageReference preApprovalPage = new PageReference('/apex/SL_GiftPreApproval'+newReturnURL);
        preApprovalPage.setRedirect(true);
        return preApprovalPage;
    }
    public List<SL_Gift> GetGiftsJustAdded() {
        List<SL_Gift> JustAddedGifts = new List<SL_Gift>();        
        if (GiftIDs.isEmpty()){
            return JustAddedGifts;
        }
        else {            
            List<SL_GiftRecipient> withGifts = new List<SL_GiftRecipient>();


            List<Contact> contacts = [SELECT Id,
                                         Name,
                                         Account.Name,
                                         (SELECT Id,
                                                 Name,
                                                 CreatedDate,
                                                 Approved__c,
                                                 Gift_Value__c,
                                                 Gift_Value_Distributed__c,
                                                 Desired_Date__c,
                                                 Recipient__r.Name,
                                                 Submitted_For__r.Name,
                                                 Submitted_For__r.MailingCountry,
                                                 Submitted_By__r.Name,
                                                 Submitted_By__r.Office__c,
                                                 CurrencyIsoCode 
                                         FROM Gifts__r 
                                         WHERE Id IN :GiftIDs)
                                 FROM Contact 
                                 WHERE Id IN (SELECT Recipient__c 
                                              FROM Gift__c 
                                              WHERE Id IN :GiftIDs)];

            Map<Id, Contact> idToContact = new Map<Id, Contact>();
            for (Contact c: contacts){
                idToContact.put(c.Id, c);
            }
            Map<Id, Decimal> idToYTD = HL_GiftUtil.GetPrevYTDValue(idToContact.keySet());
            Map<Id, Decimal> idToNextYearYTD = HL_GiftUtil.GetPrevYTDNextYearValue(idToContact.keySet());            
            AllRecipientsList = new List<SL_GiftRecipient>();
            

            for(Id contactId: idToContact.keySet()) {
                withGifts.add(new SL_GiftRecipient(idToContact.get(contactId),idToYTD.containsKey(contactId) ? idToYTD.get(contactId) : 0.0,idToNextYearYTD.containsKey(contactId) ? idToNextYearYTD.get(contactId) : 0.0, ConversionRates,Gift.Desired_Date__c, Gift.CurrencyIsoCode));
            }            
            for(SL_GiftRecipient recipient: withGifts) {                 
                recipient.GiftValue = Gift.Gift_Value__c/ConversionRates.get(Gift.CurrencyIsoCode);                
                if (!recipient.recipient.Gifts__r.isEmpty()) {
                    for(Gift__c eachGift: recipient.recipient.Gifts__r) {
                        if(Gift.Desired_Date__c.Year() == System.Today().Year()){
                            JustAddedGifts.add(new SL_Gift(eachGift, recipient.GetGiftYTD(), recipient.GiftPrevYTD, recipient));
                        }else{
                            JustAddedGifts.add(new SL_Gift(eachGift, recipient.GetGiftNextYearYTD(), recipient.GiftPrevNextYearYTD, recipient));
                        }
                    }
                }      
            }
        }
        return JustAddedGifts;
    } 
}