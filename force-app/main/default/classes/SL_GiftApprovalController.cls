public with sharing class SL_GiftApprovalController {
    public SL_Paginator giftRecords                  {   get; set;    } //!< to display the opportunity records.
    private integer counter=0;  //keeps track of the offset
   private integer list_size=20; //sets the page size or number of rows
   public integer total_size; //used to show user the total size of the list
    public List<SL_Gift> GiftList {get; set;}
    public String ViewType {get; set;}
    public Integer YearFilter {get; set;}
    public String MonthFilter {get; set;}
    public String NameFilter {get; set;}
    public String ApprovalComment {get; set;}
    public String NewSort {get; set;}
    public String SortField {get{return sortField == null ? 'GiftName' : sortField;} set{
        ToggleDirection(value);
        SortField = value;
    }}
    public Integer OffsetSize=0;
public Integer LimitSize=500;
public Integer Totalrec=0;
private String temp;
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
    public Map<String, Double> ConversionRates;
    public List<Contact> conList {get; set;}

    public List<Gift__c> lstGifts = new List<Gift__c>();
    public SL_GiftApprovalController() {     
        ViewType = 'Pending';
        YearFilter = Date.Today().Year();
        NameFilter = '';
        ConversionRates = HL_GiftUtil.GetConversionRates();
        searchGifts();
        MonthFilter = 'Jan';
    }
    public void ToggleDirection(string newSort){
        SortDirection = (SortField == newSort) ? (SortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
    public void ApplySort()
    {
       SortField = NewSort;
       searchGifts();
     }
    public List<SelectOption> GetApprovalOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Pending','Pending')); 
        options.add(new SelectOption('Approved','Approved')); 
        options.add(new SelectOption('Denied','Denied'));      
        return options; 
    }
    public List<SelectOption> GetYearFilterOptions() {
        List<SelectOption> years = new List<SelectOption>();
        Integer curYear = Date.Today().Year();
        years.add(new SelectOption(String.valueOf(curYear+1),String.valueOf(curYear+1)));
        for (Integer ii = 0; ii < 5; ii++){
            years.add(new SelectOption(String.valueOf(curYear-ii),String.valueOf(curYear-ii)));
        }

        return years;
    }
    Integer mon = 1;
    public Integer getSelectedMonth(){
        List<Months_of_Year__mdt> lstMonths = getMonths();
        for(Months_of_Year__mdt moy : lstMonths){
            if(MonthFilter == moy.Month_Short_Name__c){
                mon = Integer.ValueOf(moy.MasterLabel);
            }
    }
    System.debug('Current Month >>> ' + mon);

    return mon;
}
    
    public List<Months_of_Year__mdt> getMonths(){
        List<Months_of_Year__mdt> monthsOfYear = new List<Months_of_Year__mdt>([SELECT MasterLabel, Month_Short_Name__c FROM Months_of_Year__mdt]);
        return monthsOfYear;
    }

    public List<SelectOption> GetMonthFilterOptions(){
        List<Months_of_Year__mdt> lstMonths = getMonths();
        
        List<SelectOption> months = new List<SelectOption>();
        String currMonth = 'Jan';
      //  months.add(new SelectOption(currMonth, currMonth));
        for(Months_of_Year__mdt moy : lstMonths){
            months.add(new SelectOption(moy.Month_Short_Name__c, moy.Month_Short_Name__c));
        }
        months.sort();
        return months;
    }
    /******************** Pagination ********************/


    public PageReference SearchGifts() {
        Integer mont = getSelectedMonth();
        List<Contact> lstGifts = new List<Contact>();
        String filter = NameFilter+'%';
  //      String queryString = 'SELECT Id, Name, Account.Name, MailingCountry, Office__c,(SELECT Id,Name,CreatedDate,Gift_Value__c,Approved__c,Approve_Date__c,Desired_Date__c,Recipient__r.Name,Recipient_Company_Name__c,Submitted_For__r.Name,Submitted_By__r.Name,Submitted_By__r.Office__c,Submitted_For__r.MailingCountry,Currency__c,CurrencyIsoCode FROM Gifts__r WHERE CALENDAR_YEAR(Desired_Date__c)=' + YearFilter + ' AND CALENDAR_MONTH(Desired_Date__c)=\'' +MonthFilter +'\') FROM Contact WHERE Id IN (SELECT Recipient__c FROM Gift__c WHERE Gift_Value__c > 0 AND Approved__c =\''+ ViewType + '\')';
        String queryString = 'SELECT Id, Name, Account.Name, MailingCountry, Office__c,(SELECT Id,Name,CreatedDate,Gift_Value__c,Approved__c,Approve_Date__c,Desired_Date__c,Recipient__r.Name,Recipient_Company_Name__c,Submitted_For__r.Name,Submitted_By__r.Name,Submitted_By__r.Office__c,Submitted_For__r.MailingCountry,Currency__c,CurrencyIsoCode FROM Gifts__r WHERE CALENDAR_YEAR(Desired_Date__c)=' + YearFilter + ' AND CALENDAR_MONTH(Desired_Date__c)=' +mont +') FROM Contact WHERE Id IN (SELECT Recipient__c FROM Gift__c WHERE Gift_Value__c > 0 AND Approved__c =\''+ ViewType + '\')';
                 queryString += ' AND LastName Like \'%'+ NameFilter +'\'';
             //    queryString += ' LIMIT ' + LimitSize + ' OFFSET ' + OffsetSize;
                System.Debug('This is the Query 1.00001 ' + queryString);
                System.debug('>>>> 111.111   ' + Totalrec);
                if(Totalrec !=null || Totalrec ==0){
                    lstGifts = Database.query(queryString);
                    Totalrec = (lstGifts !=null &&lstGifts.size()>0)?lstGifts.size():0;
                    System.debug('Test Check Total Records --->>  ' + lstGifts.size());
                 }
            //    lstGifts = Database.query(queryString); 
            //    Totalrec = lstGifts.size();
            queryString += ' ORDER BY Name ASC LIMIT ' + LimitSize + ' OFFSET ' + OffsetSize;
    //        queryString += ' LIMIT ' + LimitSize + ' OFFSET ' + OffsetSize;
            System.Debug('This is the Query 22.00001 ' + queryString);

            conList = Database.query(queryString);
        GiftList = new List<SL_Gift>();
        
        List<SL_GiftRecipient> withGifts = new List<SL_GiftRecipient>();
        Map<Id, Contact> idToContact = new Map<Id, Contact>();
        for(Contact contact: conList) { 
            idToContact.put(contact.Id, contact);
        }
        Map<Id, Decimal> idToYTD = HL_GiftUtil.GetPrevYTDValue(idToContact.keySet());
        Map<Id, Decimal> idToNextYearYTD = HL_GiftUtil.GetPrevYTDNextYearValue(idToContact.keySet());

        for(Id contactId: idToContact.keySet()) {
            if (!idToContact.get(contactId).Gifts__r.isEmpty()){
                SL_GiftRecipient recipient = new SL_GiftRecipient(idToContact.get(contactId), 
                                                    idToYTD.containsKey(contactId) ? idToYTD.get(contactId) : 0.0,
                                                    idToNextYearYTD.containsKey(contactId) ? idToNextYearYTD.get(contactId) : 0.0,
                                                    ConversionRates,idToContact.get(contactId).Gifts__r[0].Desired_Date__c, idToContact.get(contactId).Gifts__r[0].CurrencyIsoCode);
                Boolean anyUSABasedSubmitters = false;
                for (Gift__c previousGift: idToContact.get(contactId).Gifts__r){
                    if (previousGift.Submitted_For__r.MailingCountry=='United States'){
                        anyUSABasedSubmitters = true;
                    }
                } 
                recipient.IsUSA = idToContact.get(contactId).MailingCountry == 'United States' || anyUSABasedSubmitters;
                recipient.IsFrance = idToContact.get(contactId).MailingCountry == 'France';
                withGifts.add(recipient);                                
            }
        }

        for(SL_GiftRecipient recipient: withGifts) {
            if (!recipient.recipient.Gifts__r.isEmpty()) {
                for(Gift__c eachGift: recipient.recipient.Gifts__r) {
                    if (eachGift.Approved__c == ViewType){
                        Decimal PrevYTD = 0.0;
                        if(eachGift.Desired_Date__c.Year() > System.Today().Year()){
                            PrevYTD = recipient.GiftPrevNextYearYTD;
                            }else{
                            PrevYTD = recipient.GiftPrevYTD;
                                }
                        Decimal exchangeRate =   eachGift.CurrencyIsoCode != null 
                                                && ConversionRates.containsKey(eachGift.CurrencyIsoCode) ?
                                                    (Decimal) ConversionRates.get(eachGift.CurrencyIsoCode) :
                                                    1.0;                        
                        if(ViewType == 'Pending'){                            
                            GiftList.add(
                            new SL_Gift(
                                eachGift, 
                                (PrevYTD*exchangeRate + eachGift.Gift_Value__c).setScale(1),
                                PrevYTD,
                                recipient
                            )
                        );
                        }else{
                        GiftList.add(
                            new SL_Gift(
                                eachGift, 
                                PrevYTD+(eachGift.Gift_Value__c!=null ? (eachGift.Gift_Value__c/exchangeRate) : 0),
                                PrevYTD,
                                recipient
                            )
                        );
                    }
                    }
                }
            }
        }
        SL_Gift.SortField = SortField;
        SL_Gift.SortDirection = SortDirection;
        GiftList.sort();
        return null;
    } 
    public void FirstPage()
    {
        OffsetSize = 1;
        SearchGifts();
    }
    public void previous()
    {
        OffsetSize =  LimitSize-OffsetSize;
        SearchGifts();
    }
    public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
        SearchGifts();
    }
    public boolean getprev()
    {
        if(OffsetSize == 0)
            return true;
        else
            return false;
    }
    public boolean getnxt()
    {
    //    if((OffsetSize + LimitSize) > Totalrec)
        if((OffsetSize + LimitSize) > Totalrec || OffsetSize == 2000)
            return true;
        else
            return false;
    }  
      /******************** End Pagination ************* */
      /*
    public PageReference SearchGifts() {
        GiftList = new List<SL_Gift>();
        String filter = NameFilter+'%';
        List<SL_GiftRecipient> withGifts = new List<SL_GiftRecipient>();
        Map<Id, Contact> idToContact = new Map<Id, Contact>();
        for(Contact contact: [SELECT Id,
                                     Name, 
                                     Account.Name,
                                     MailingCountry,
                                     Office__c,
                                     (SELECT Id,
                                             Name,
                                             CreatedDate,
                                             Gift_Value__c,
                                             Approved__c,
                                             Approve_Date__c,
                                             Desired_Date__c,
                                             Recipient__r.Name,
                                             Recipient_Company_Name__c,
                                             Submitted_For__r.Name,
                                             Submitted_By__r.Name,
                                             Submitted_By__r.Office__c,
                                             Submitted_For__r.MailingCountry,
                                             Currency__c,
                                             CurrencyIsoCode
                                     FROM Gifts__r 
                                     WHERE CALENDAR_YEAR(Desired_Date__c)=:YearFilter 
                                      ) 
                             FROM Contact 
                             WHERE Id IN (SELECT Recipient__c 
                                         FROM Gift__c 
                                         WHERE Gift_Value__c > 0) 
                             AND Lastname 
                             LIKE :filter LIMIT 1000]) { 
            idToContact.put(contact.Id, contact);
        }
        Map<Id, Decimal> idToYTD = HL_GiftUtil.GetPrevYTDValue(idToContact.keySet());
        Map<Id, Decimal> idToNextYearYTD = HL_GiftUtil.GetPrevYTDNextYearValue(idToContact.keySet());

        for(Id contactId: idToContact.keySet()) {
            if (!idToContact.get(contactId).Gifts__r.isEmpty()){
                SL_GiftRecipient recipient = new SL_GiftRecipient(idToContact.get(contactId), 
                                                    idToYTD.containsKey(contactId) ? idToYTD.get(contactId) : 0.0,
                                                    idToNextYearYTD.containsKey(contactId) ? idToNextYearYTD.get(contactId) : 0.0,
                                                    ConversionRates,idToContact.get(contactId).Gifts__r[0].Desired_Date__c, idToContact.get(contactId).Gifts__r[0].CurrencyIsoCode);
                Boolean anyUSABasedSubmitters = false;
                for (Gift__c previousGift: idToContact.get(contactId).Gifts__r){
                    if (previousGift.Submitted_For__r.MailingCountry=='United States'){
                        anyUSABasedSubmitters = true;
                    }
                } 
                recipient.IsUSA = idToContact.get(contactId).MailingCountry == 'United States' || anyUSABasedSubmitters;
                recipient.IsFrance = idToContact.get(contactId).MailingCountry == 'France';
                withGifts.add(recipient);                                
            }
        }

        for(SL_GiftRecipient recipient: withGifts) {
            if (!recipient.recipient.Gifts__r.isEmpty()) {
                for(Gift__c eachGift: recipient.recipient.Gifts__r) {
                    if (eachGift.Approved__c == ViewType){
                        Decimal PrevYTD = 0.0;
                        if(eachGift.Desired_Date__c.Year() > System.Today().Year()){
                            PrevYTD = recipient.GiftPrevNextYearYTD;
                            }else{
                            PrevYTD = recipient.GiftPrevYTD;
                                }
                        Decimal exchangeRate =   eachGift.CurrencyIsoCode != null 
                                                && ConversionRates.containsKey(eachGift.CurrencyIsoCode) ?
                                                    (Decimal) ConversionRates.get(eachGift.CurrencyIsoCode) :
                                                    1.0;                        
                        if(ViewType == 'Pending'){                            
                            GiftList.add(
                            new SL_Gift(
                                eachGift, 
                                (PrevYTD*exchangeRate + eachGift.Gift_Value__c).setScale(1),
                                PrevYTD,
                                recipient
                            )
                        );
                        }else{
                        GiftList.add(
                            new SL_Gift(
                                eachGift, 
                                PrevYTD+(eachGift.Gift_Value__c!=null ? (eachGift.Gift_Value__c/exchangeRate) : 0),
                                PrevYTD,
                                recipient
                            )
                        );
                    }
                    }
                }
            }
        }
        SL_Gift.SortField = SortField;
        SL_Gift.SortDirection = SortDirection;
        GiftList.sort();
        return null;
    } */
    public PageReference ApproveSelectedGifts() {
        ProcessSelectedGifts('Approve');
        return null;
    }
    public PageReference DenySelectedGifts() {
        ProcessSelectedGifts('Deny');
        return null;
    }
    public void ProcessSelectedGifts(string action) {
        try { 
            List<Gift__c> selectedGifts = new List<Gift__c>();
            Map<SL_GiftRecipient, Decimal> recipientToYTD = new Map<SL_GiftRecipient, Decimal>();
            Set <SL_GiftRecipient> recipientsOver = new Set<SL_GiftRecipient>();
            for(SL_Gift Gift: GiftList) {
                if(Gift.selected == true) {
                    selectedGifts.add(Gift.gift);
                    if (!recipientToYTD.keyset().contains(Gift.recipient)){
                        recipientToYTD.put(Gift.recipient, Gift.GiftYTD);
                    }
                    else{
                        recipientToYTD.put(Gift.recipient, recipientToYTD.get(Gift.recipient)+Gift.getGiftValue());
                    }
                    if(Gift.recipient.IsValuePassedOver(recipientToYTD.get(Gift.recipient))){
                        recipientsOver.add(Gift.recipient);
                    }
                }
            }

            if (selectedGifts.isEmpty()) {
                throw new SL_GiftLogException('You must select at least one gift to '+action.toLowercase()+'.');
            }
            else if (!recipientsOver.isEmpty()&&action=='Approve'&&ApprovalComment==''){
                String validationError = 'You MUST enter an Approval Comment to exceed the yearly limit.  Recipients exceeding yearly limit: ';
                List <String> errorMessages = new List<String>();
                for (SL_GiftRecipient exceeder: recipientsOver){
                    errorMessages.add(exceeder.recipient.Name + ' - USD ' + recipientToYTD.get(exceeder).setScale(1, RoundingMode.HALF_UP));
                }
                validationError += String.join(errorMessages, ', ');
                throw new SL_GiftLogException(validationError);
            }

            for(Gift__c gift: selectedGifts) {
                gift.Approved__c = action == 'Approve' ? 'Approved' : 'Denied';
                gift.Approved_By__c = UserInfo.getUserId();
                gift.Approve_Date__c = datetime.now();
                gift.Approval_Comment__c = ApprovalComment;
            }
            Database.SaveResult[] MySaveResult = Database.Update(selectedGifts, false);
            Integer giftNumber=0;
            for (Database.SaveResult sr : MySaveResult) {
                if(!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,
                            'Cannot '+ action.toLowercase() + ' ' + selectedGifts[giftNumber].Name + ' for ' 
                            + selectedGifts[giftNumber].Recipient__r.Name + ': ' + err.getMessage());
                        ApexPages.addMessage(msg);  
                    }
                }
            giftNumber++;
            }    
        }    
        catch (SL_GiftLogException e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(msg);
        }
        SearchGifts();
    }
}