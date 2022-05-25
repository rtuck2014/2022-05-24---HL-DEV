public with sharing class HL_GiftEditControllerExt {
    private final Gift__c Gift {get; set;}
    private Contact GiftContact{get; set;}
    public Map<String, Double> ConversionRates;
    public String ReturnURL;
    public SL_Gift slGift;
    
    public HL_GiftEditControllerExt(ApexPages.StandardController stdController){
        ReturnURL = ApexPages.currentPage().getParameters().get('retURL');
        this.Gift = (Gift__c)stdController.getRecord();        
        ConversionRates = HL_GiftUtil.GetConversionRates();          
    }    
    public PageReference Save() {        
        Set<Id> ContactIds = new Set<Id>();
		Decimal RecipientPrevYTD = 0.0;        
        GiftContact = [SELECT  Id,Name,Account.Name,MailingCountry from Contact where Id=: Gift.Recipient__c limit 1];
        ContactIds.add(GiftContact.Id);     
        Map<Id, Decimal> prevYTD = HL_GiftUtil.GetPrevYTDValue(ContactIds);
		Map<Id, Decimal> idToNextYearYTD = HL_GiftUtil.GetPrevYTDNextYearValue(ContactIds);        
        SL_GiftRecipient recipient = new SL_GiftRecipient(GiftContact,prevYTD.containsKey(GiftContact.Id) ? prevYTD.get(GiftContact.Id) : 0.0,
                                                        idToNextYearYTD.containsKey(GiftContact.Id) ? idToNextYearYTD.get(GiftContact.Id) : 0.0,
                                                           ConversionRates,Gift.Desired_Date__c,Gift.CurrencyIsoCode);                
        if(Gift.Currency__c == 'U.S. Dollar'){
            recipient.IsUSA = true;
            Gift.currencyIsoCode = 'USD';
        }else if(Gift.Currency__c == 'Euro (in France)'){
            recipient.IsFrance = true;
            Gift.currencyIsoCode = 'EUR';
        }else if(Gift.Currency__c == 'Hong Kong Dollar'){
            recipient.IsHongKong = true;
            Gift.currencyIsoCode = 'HKD';
        }else if(Gift.Currency__c == 'Australian Dollar'){
            recipient.IsAustralia = true;
            Gift.currencyIsoCode = 'AUD';
        }else if(Gift.Currency__c == 'Euro (not in France)'){
            Gift.currencyIsoCode = 'EUR';
        }else if(Gift.Currency__c == 'British Pound'){
            Gift.currencyIsoCode = 'GBP';
        }
        recipient.GiftValue = (Gift.Gift_Value__c==null? 0.0 : Gift.Gift_Value__c) /(Gift.currencyIsoCode==null? 1.0 : ConversionRates.get(Gift.CurrencyIsoCode));
        recipient.currencyCode=Gift.currencyIsoCode;
        Decimal exchangeRate =   Gift.CurrencyIsoCode != null && ConversionRates.containsKey(Gift.CurrencyIsoCode) ?
                                                    (Decimal) ConversionRates.get(Gift.CurrencyIsoCode) :
                                                    1.0;
        if(Gift.Desired_Date__c.year() > System.today().year()){
            RecipientPrevYTD = recipient.GiftPrevNextYearYTD;
        }else{
        	RecipientPrevYTD = recipient.GiftPrevYTD;
        }
        slGift = new SL_Gift(Gift,(RecipientPrevYTD *exchangeRate) + ((Decimal)Gift.Gift_Value__c).setScale(1),
                                RecipientPrevYTD,
                                recipient);                                        
        
        if(Gift.Gift_Value__c <= 0){
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Note: The Gift Value Cannot be 0 or less than 0');
            ApexPages.addMessage(msg1);
                return ApexPages.currentPage();
            }
        if(Gift.Desired_Date__c < (System.Today())){
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR,'Note: Desired Date Cannot be past date');
            ApexPages.addMessage(msg1);
                return ApexPages.currentPage();
            }        
         if(slGift.GetGiftValueOver()){
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'Note: The gift recipient will exceed his/her yearly gift maximum if the submitted gifts are approved.You can still update the gift.');
            ApexPages.addMessage(msg1);            
            }
        
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Gift has been updated.');
        ApexPages.addMessage(msg);
        update Gift;
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
    public PageReference AddGift() {
        PageReference pageRef = new PageReference('/apex/SL_GiftPreApproval');
        return pageRef.setRedirect(true);
    }
}