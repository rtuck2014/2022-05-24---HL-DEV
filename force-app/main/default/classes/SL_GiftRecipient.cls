public with sharing class SL_GiftRecipient implements Comparable {
    public Contact Recipient    {get; set;}
    public Decimal GiftPrevYTD  {get; set;}
    public Decimal GiftPrevNextYearYTD  {get; set;}
    public Decimal GiftValue    {get; set;}
    public Boolean Selected     {get; set;}
    public Boolean IsDesiredDateNextYear     {get; set;}
    public Boolean IsUSA        {get; set;}
    public Boolean IsFrance     {get; set;}
    public Boolean IsHongKong   {get; set;}
    public Boolean IsAustralia  {get; set;}
    public Map<String, Double>  Conversion   {get; set;}
    public String               CurrencyCode {get; set;}  
    public SL_GiftRecipient(Contact recipient, Decimal prevYTD,Decimal prevNextYearYTD, Map<String, Double> conversion,Date desiredDate, String currencyCode) {
        this.recipient = recipient;
        selected = false;
        GiftPrevYTD = prevYTD;
        GiftPrevNextYearYTD = prevNextYearYTD;
        GiftValue = 0.0;        
        IsUSA = false;
        IsFrance = false;
        IsHongKong = false;
        IsAustralia = false;
        this.Conversion=conversion;
        this.CurrencyCode=currencyCode;
        if(desiredDate != null && (desiredDate.Year() > System.Today().Year())){
            this.IsDesiredDateNextYear = true;
        }else{
            this.IsDesiredDateNextYear = false;
        }
    }
   public Decimal GetGiftYTD(){
       if(!IsDesiredDateNextYear){
        return GiftPrevYTD + GiftValue;
       }else{
          return GiftPrevYTD; 
       }       
    }
    
    public Decimal GetGiftNextYearYTD(){
        if(IsDesiredDateNextYear){
            return GiftPrevNextYearYTD + GiftValue;
        }else{
            return GiftPrevNextYearYTD;
        }        
    }
        
    public Boolean GetWasOver(){
        return GiftPrevYTD.setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);        
    }
    
    public Boolean GetNextYearWasOver(){
        return GiftPrevNextYearYTD.setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);        
    }

    public Boolean GetIsOver(){
        return GetGiftYTD().setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
    }
    
    public Boolean GetNextYearIsOver(){
        return GetGiftNextYearYTD().setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
    }    
    public Boolean IsValuePassedOver(Decimal giftVal){      
        if(currencyCode != 'USD'){
            return (giftVal/conversion.get(currencyCode)).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
        }else{
            return giftVal.setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
        }
    }        

    public Boolean IsTotalOver(Decimal giftVal){   
        if(!IsDesiredDateNextYear){     
            if(currencyCode != 'USD'){
                return ((giftVal/conversion.get(currencyCode)) + GiftPrevYTD).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
            }else{
                return (giftVal+GiftPrevYTD).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
            }
        }
        else {
            if(currencyCode != 'USD'){
                return ((giftVal/conversion.get(currencyCode)) + GiftPrevNextYearYTD).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
            }else{
                return (giftVal+GiftPrevNextYearYTD).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
            }
        }
    }
    
    public Boolean IsNextYearTotalOver(Decimal giftVal){        
        if(currencyCode != 'USD'){
            return ((giftVal/conversion.get(currencyCode)) + GiftPrevNextYearYTD).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
        }else{
            return (giftVal+GiftPrevNextYearYTD).setScale(2) > GetMaximumInUSD(currencyCode).setScale(2);
        }
    }
    private Decimal GetMaximumInUSD(String currencyCode){
        if(currencyCode != null && !(String.isBlank(currencyCode))){
            if(currencyCode == 'USD' && IsUSA){
                return 100;
            }else if(currencyCode == 'AUD' && IsAustralia){
                return 100/conversion.get('AUD');
            }else if(currencyCode == 'EUR' && IsFrance){
                return 65/conversion.get('EUR');
            }else if(currencyCode == 'HKD' && IsHongKong){
                return 1000/conversion.get('HKD');
            }else{
                return conversion.get(currencyCode) == null ? 100 : 100/conversion.get(currencyCode);
            }
        }else{
            return 100;
        }
    }

    public Integer compareTo(Object compareTo) {
        SL_GiftRecipient compareToRecipient = (SL_GiftRecipient)compareTo;
        Integer returnValue = 0;
        if (recipient.Account.Name < compareToRecipient.recipient.Account.Name) {
            returnValue = -1;
        } else if (recipient.Account.Name > compareToRecipient.recipient.Account.Name) {
            returnValue = 1;
        }
        if (returnValue==0){
             if (recipient.Name < compareToRecipient.recipient.Name) {
                returnValue = -1;
            } else if (recipient.Name > compareToRecipient.recipient.Name) {
                returnValue = 1;
            }
        }
       
        return returnValue; 
    }
}