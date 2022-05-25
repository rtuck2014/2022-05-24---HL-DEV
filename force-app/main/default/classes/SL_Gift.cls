public with sharing class SL_Gift implements Comparable {
    public Gift__c Gift {get; set;}
    public Boolean Selected {get; set;}
    public Decimal GiftYTD {get; set;}
    public Decimal GiftPrevYTD {get; set;}
    public SL_GiftRecipient Recipient {get; set;}        
    public static String SortField = 'GiftName';
    public static String SortDirection = 'ASC';    
    public SL_Gift(Gift__c gift, Decimal YTD, Decimal PrevYTD, SL_GiftRecipient recipient) {
            this.Gift = gift;
            this.Recipient = recipient;                                     
            Selected = false;
            GiftYTD = YTD;
            GiftPrevYTD = PrevYTD;
    }        
    public Decimal GetGiftValue(){        
        return GiftYTD-GiftPrevYTD;
    }
    public Boolean GetGiftValueOver(){        
        return recipient.IsValuePassedOver(getGiftValue());
    }
    public Boolean GetTotalOver(){
        return recipient.IsTotalOver(getGiftValue());
    }
     
    public Integer CompareTo(Object compareTo) {
        HL_GiftUtil.SortDirection = SortDirection;
        SL_Gift compareToObj = (SL_Gift)compareTo;        
        if(SortField == 'GiftName'){
            return HL_GiftUtil.CompareStringValues(Gift.Name, compareToObj.Gift.Name);
        }else if(SortField == 'Recipient'){
            return HL_GiftUtil.CompareStringValues(Recipient.recipient.Name, compareToObj.Recipient.recipient.Name);
        }else if(SortField == 'RecipientCompany'){
            return HL_GiftUtil.CompareStringValues(Gift.Recipient_Company_Name__c, compareToObj.Gift.Recipient_Company_Name__c);
        }else if(sortField == 'Office'){
            return HL_GiftUtil.CompareStringValues(Gift.Submitted_By__r.Office__c, compareToObj.Gift.Submitted_By__r.Office__c);
        }else if(SortField == 'SubmittedFor'){            
            return HL_GiftUtil.CompareStringValues(Gift.Submitted_For__r.Name, compareToObj.Gift.Submitted_For__r.Name);            
        }else if(SortField == 'SubmittedBy'){            
           return  HL_GiftUtil.CompareStringValues(Gift.Submitted_By__r.Name, compareToObj.Gift.Submitted_By__r.Name);
        }else if(sortField == 'DesiredDate'){
           return  HL_GiftUtil.CompareDateValues(Gift.Desired_Date__c, compareToObj.Gift.Desired_Date__c);
        }else if(SortField == 'ApprovalDate'){
           return  HL_GiftUtil.CompareDateTimeValues(Gift.Approve_Date__c, compareToObj.Gift.Approve_Date__c);
        }else if(SortField == 'CreatedDate'){
           return  HL_GiftUtil.CompareDateTimeValues(Gift.CreatedDate, compareToObj.Gift.CreatedDate);
        }else if(SortField == 'PrevYTD'){
           return  HL_GiftUtil.CompareCurrencyValues(GiftPrevYTD, compareToObj.GiftPrevYTD);
        }else if(SortField == 'GiftYTD'){
           return  HL_GiftUtil.CompareCurrencyValues(GiftYTD, compareToObj.GiftYTD);
        }else if(SortField == 'GiftValue'){
           return  HL_GiftUtil.CompareCurrencyValues(Gift.Gift_Value__c, compareToObj.Gift.Gift_Value__c);
        }   
        return null;
    }    
}