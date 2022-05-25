public class HL_GiftUtil {
    public static String SortDirection = 'ASC';
    public static Integer CompareStringValues(String s1, String s2){
        if(!(string.isBlank(s1)) && (s1 != null) && !(string.isBlank(s2)) && (s2 != null)){
        if (SortDirection == 'ASC')     
            return s1.toUpperCase().compareTo(s2.toUpperCase());   
        else 
            return s2.toUpperCase().compareTo(s1.toUpperCase());
        }
        return 0;
    }
    public static Integer CompareDateValues(Date d1, Date d2){
        if (SortDirection == 'ASC')     
            return d1.daysBetween(d2);   
        else 
            return d2.daysBetween(d1);
    }
    public static Integer CompareDateTimeValues(DateTime d1, DateTime d2){
        if (SortDirection == 'ASC')
            return (d1.getTime() - d2.getTime()).intValue();
        else 
            return (d2.getTime() - d1.getTime()).intValue();
    }
    public static Integer CompareCurrencyValues(Decimal de1, Decimal de2){
        if (SortDirection == 'ASC')
            return (de1 - de2).intValue();
        else 
            return (de2 - de1).intValue();
    }
    
    public static Map<Id, Decimal> GetPrevYTDValue(Set<Id> contactIds){
        Map <Id, Decimal> idToYTD = new Map <Id, Decimal>();
        for (AggregateResult ar : [ SELECT  Sum(Gift_Value__c) total,
                                                Recipient__c
                                        FROM    Gift__c
                                        WHERE   Recipient__c IN :contactIds
                                        AND     Approved__c = 'Approved'
                                        AND     Desired_Date__c = THIS_YEAR
                                        GROUP BY Recipient__c ]){
                idToYTD.put((Id)ar.get('Recipient__c'), (Double)ar.get('total'));
        }
        return idToYTD;
    }
	
	public static Map<Id, Decimal> GetPrevYTDNextYearValue(Set<Id> contactIds){
        Map <Id, Decimal> idToYTD = new Map <Id, Decimal>();
        for (AggregateResult ar : [ SELECT  Sum(Gift_Value__c) total,
                                                Recipient__c
                                        FROM    Gift__c
                                        WHERE   Recipient__c IN :contactIds
                                        AND     Approved__c = 'Approved'
                                        AND     Desired_Date__c > THIS_YEAR
                                        GROUP BY Recipient__c ]){
                idToYTD.put((Id)ar.get('Recipient__c'), (Double)ar.get('total'));
        }
        return idToYTD;
    }
    
    public static Map<String,Decimal> GetConversionRates(){
        Map<String,Decimal> conversionRates = new Map<String,Decimal>();
        for(CurrencyType dcr: [SELECT  ConversionRate, 
                                                IsoCode 
                                        FROM CurrencyType]){
            conversionRates.put(dcr.IsoCode, dcr.ConversionRate);           
        }
         return conversionRates;
    }

}