public with sharing class HL_GiftSubmitterController {
    public List<SL_Gift> GiftList {get; set;}
    public String ViewType {get; set;}
    public Integer YearFilter {get; set;}
    public String NameFilter {get; set;}    
    public String NewSort {get; set;}
    public Id UserId = UserInfo.getUserId();
    public String SortField {get{return sortField == null ? 'GiftName' : sortField;} set{
        ToggleDirection(value);
        SortField = value;
    }}
    public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
    public Map<String, Double> ConversionRates;
    public HL_GiftSubmitterController() {     
        viewType = 'Pending';
        yearFilter = Date.Today().Year();
        nameFilter = '';
        ConversionRates = HL_GiftUtil.GetConversionRates();
        SearchGifts();
    }
    public void ToggleDirection(string newSort){
        SortDirection = (SortField == newSort) ? (SortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
    public void ApplySort()
    {
       SortField = NewSort;
       SearchGifts();
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
    public PageReference AddGift() {
        PageReference pageRef = new PageReference('/apex/SL_GiftPreApproval');
        return pageRef.setRedirect(true);
    }
    public PageReference SearchGifts() {
        giftList = new List<SL_Gift>();
        String filter = nameFilter+'%';
        List<SL_GiftRecipient> withGifts = new List<SL_GiftRecipient>();
        Map<Id, Contact> idToContact = new Map<Id, Contact>();
        for(Contact contact: [SELECT Id,
                                     Name, 
                                     Account.Name,
                                     MailingCountry,                                     
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
                                             Submitted_For__r.Id,
                                             Submitted_By__r.Name,
                                             Submitted_By__r.Office__c,
                                             Submitted_By__r.Id,
                                             Submitted_For__r.MailingCountry,
                                             Currency__c,
                                             CurrencyIsoCode
                                     FROM Gifts__r 
                                     WHERE CALENDAR_YEAR(Desired_Date__c)=:yearFilter 
                                      AND (Submitted_For__r.User__c=:userId AND Submitted_By__r.User__c=:userId)) 
                             FROM Contact
                             WHERE Id IN (SELECT Recipient__c
                                         FROM Gift__c 
                                         WHERE (Gift_Value__c > 0)) 
                             AND Lastname 
                             LIKE :filter]) { 
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
                    //Modified as part of State/Country Picklist, included 'United States'
                    if (previousGift.Submitted_For__r.MailingCountry=='United States' || previousGift.Submitted_For__r.MailingCountry=='USA' || previousGift.Submitted_For__r.MailingCountry=='US'){
                        anyUSABasedSubmitters = true;
                    }
                } 
                
                //Modified as part of State/Country Picklist, included 'United States'
                recipient.IsUSA = idToContact.get(contactId).MailingCountry == 'United States' || idToContact.get(contactId).MailingCountry == 'USA' || idToContact.get(contactId).MailingCountry == 'US' || anyUSABasedSubmitters;
                recipient.IsFrance = idToContact.get(contactId).MailingCountry == 'France';
                withGifts.add(recipient);
            }
        }
        for(SL_GiftRecipient recipient: withGifts) {
            if (!recipient.recipient.Gifts__r.isEmpty()) {
                for(Gift__c eachGift: recipient.recipient.Gifts__r) {
                    if (eachGift.Approved__c == viewType){
                        Decimal PrevYTD;
                        if(!recipient.IsDesiredDateNextYear) {
                            PrevYTD = recipient.GiftPrevYTD;
                        }
                        else {
                            PrevYTD = recipient.GiftPrevNextYearYTD;
                        }
                        Decimal exchangeRate =   eachGift.CurrencyIsoCode != null 
                                                && ConversionRates.containsKey(eachGift.CurrencyIsoCode) ?
                                                    (Decimal) ConversionRates.get(eachGift.CurrencyIsoCode) :
                                                    1.0;
                        if(viewType == 'Pending'){                            
                            giftList.add(
                            new SL_Gift(
                                eachGift, 
                                (PrevYTD*exchangeRate + eachGift.Gift_Value__c).setScale(1),
                                PrevYTD,
                                recipient
                            )
                        );
                        }else{
                            giftList.add(
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
        giftList.sort();
        return null;
    }
}