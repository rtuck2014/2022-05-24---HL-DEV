public without sharing class HL_TimeRecordPeriod {

    public static Time_Record_Period__c GetByDate(string category, Date periodDate){
        if(String.isBlank(category))
            category = HL_Group.GetTimeTrackingGroup();

        List<Time_Record_Period__c> trpList = [SELECT Start_Date__c, End_Date__c, Is_Locked__c, Public_Group__c FROM Time_Record_Period__c WHERE Start_Date__c <=: periodDate AND End_Date__c >=: periodDate AND Period_Category__c =: category];

        if(trpList.size() == 0){
            Date start = category == 'FR' ? GetClosestMonday(periodDate) : category == 'SC' ? GetClosestSaturday(periodDate) : GetClosestSunday(periodDate);
            trpList.add(new Time_Record_Period__c(Start_Date__c = start, End_Date__c = start.addDays(6), Period_Category__c = category));
            insert trpList;
        }

        //For FR We Still Want to Create the Current Week Record (Above), But Return the Previous Week Record as the Default
        if(category == 'FR'){
            periodDate = periodDate.addDays(-7);
            List<Time_Record_Period__c> trpPreviousList = [SELECT Start_Date__c, End_Date__c, Is_Locked__c, Public_Group__c FROM Time_Record_Period__c WHERE Start_Date__c <=: periodDate AND End_Date__c >=: periodDate AND Period_Category__c =: category];
            if(trpPreviousList.size() > 0)
                trpList = trpPreviousList;
        }

        return trpList[0];
    }

    public static List<Time_Record_Period__c> CreatePeriods(string category, List<Date> periodDates){
        if(String.isBlank(category)) {
            category = HL_Group.GetTimeTrackingGroup();
        }
        
        List<Time_Record_Period__c> trpList = new List<Time_Record_Period__c> ();
        
        if(periodDates.size() > 0){
            for (Date d : periodDates) {
                Date start = category == 'FR' ? GetClosestMonday(d) : category == 'SC' ? GetClosestSaturday(d) : GetClosestSunday(d);
                trpList.add(new Time_Record_Period__c(Start_Date__c = start, End_Date__c = start.addDays(6), Period_Category__c = category));
            }

            insert trpList;
        }
		Date filter = Date.today().addMonths(-2); 
        return [SELECT Start_Date__c, End_Date__c, Is_Locked__c FROM Time_Record_Period__c WHERE Period_Category__c =: category AND Start_Date__c >=: filter ORDER BY Start_Date__c DESC];
    }

    public static Time_Record_Period__c GetCurrentPeriod(string category){
        return GetByDate(category, Date.today());
    }

    public static List<Time_Record_Period__c> GetPeriods(string category){
        Date filter = Date.today().addMonths(-2); 
        List<Date> periodDates = new List<Date>();
        List<Time_Record_Period__c> trpList = [SELECT Start_Date__c, End_Date__c, Is_Locked__c FROM Time_Record_Period__c WHERE Period_Category__c =: category AND Start_Date__c >=: filter ORDER BY Start_Date__c DESC];
		
        if(trpList.size() == 0) {
            trpList.add(GetCurrentPeriod(category));
        }
        else {
            Integer j = 0;
            if(category == 'Beta'){
                j = -21;
            }
            for (integer i = j; i < 56; i += 7) {
                boolean hasTimePeriod = false;
    
                Date day = Date.today().addDays(-i);
                Date start = category == 'FR' ? GetClosestMonday(day) : category == 'SC' ? GetClosestSaturday(day) : GetClosestSunday(day);
                for (Time_Record_Period__c trp : trpList) {
                    if (trp.Start_Date__c <= start && trp.End_Date__c >= start) {
                        hasTimePeriod = true;
                    }
                }
    
                if(!hasTimePeriod) {
                    periodDates.add(start); 
                }
            }    

            if (periodDates.size() > 0) {
                trpList = CreatePeriods(category, periodDates);
            }
		}
            
        return trpList;
    }

    public static Time_Record_Period__c GetPeriod(Id id){
        return [SELECT Start_Date__c, End_Date__c, Is_Locked__c FROM Time_Record_Period__c WHERE Id=:id];
    }

    private static Date GetClosestMonday(Date startDate){
        Date monday = Date.newInstance(1900, 1, 1);
        while(Math.mod(monday.daysBetween(startDate), 7) != 0)
            startDate = startDate.addDays(-1);
        return startDate;
    }

    private static Date GetClosestSunday(Date startDate){
        Date sunday = Date.newInstance(1900, 1, 7);
        while(Math.mod(sunday.daysBetween(startDate), 7) != 0)
            startDate = startDate.addDays(-1);
        return startDate;
    }

    private static Date GetClosestSaturday(Date startDate){
        Date saturday = Date.newInstance(1900, 1, 6);
        while(Math.mod(saturday.daysBetween(startDate), 7) != 0)
            startDate = startDate.addDays(-1);
        return startDate;
    }
}