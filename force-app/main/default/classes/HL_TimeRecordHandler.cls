public class HL_TimeRecordHandler {
    public boolean IsTriggerContext {get{ return isExecuting;}}

    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static Boolean isAfterInsertFlag = false;
    public static Boolean isAfterUpdateFlag = false;
    public static Boolean isAfterDeleteFlag = false;

    public HL_TimeRecordHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
        batchSize = size;
    }

    public void OnAfterInsert(List<Time_Record__c> timeRecordList) {
        if (!isAfterInsertFlag) {
            List<Time_Record__c> completedTimeRecordList = new List<Time_Record__c>();

            for (Time_Record__c t : timeRecordList) {
                if (t.Recording_Status__c == 'Complete') {
                    completedTimeRecordList.add(t);
                }  
               
            }

            isAfterInsertFlag = true;
            HL_TimeRecordRollupDayHandler rollupHandler = new HL_TimeRecordRollupDayHandler(completedTimeRecordList);
            rollupHandler.RollupRecords();
        }
    }
    public void OnBeforeInsert(List<Time_Record__c> timeRecordList){
        for(Time_Record__c t: timeRecordList){
            if(t.Timer_Status__c=='Start'){
                t.Start_Time__c=System.Now();
            }
            system.debug('ggg....'+ t.Start_Time__c);
        }
    }
     public void OnBeforeUpdate(List<Time_Record__c> timeRecordList,Map<Id,Time_Record__c> oldMap){
        for(Time_Record__c t: timeRecordList){
            system.debug('t.Hours_Change__c...'+t.Hours_Change__c);
            system.debug('oldMap.get(t.Id).Hours_Change__c...'+oldMap.get(t.Id).Hours_Change__c);
            Decimal houresChanged;
            if(t.Timer_Status__c=='Stop' && oldMap.get(t.Id).Timer_Status__c=='Stop'&& oldMap.get(t.Id).Hours_Worked__c!=t.Hours_Worked__c){
         houresChanged=t.Hours_Worked__c;
        } 
              if(!t.Hours_Change__c && !String.isBlank(t.Timer_Status__c)){
               if( t.Minutes_Worked__c==null) t.Minutes_Worked__c=0;
                if(t.Add_Minute__c!=null && oldMap.get(t.Id).Add_Minute_Change__c!=t.Add_Minute_Change__c && t.Add_Minute_Change__c){
                system.debug(t.Add_Minute_Change__c+'min change'+t.Add_Minute__c+'Before...'+ t.Minutes_Worked__c);
                       t.Minutes_Worked__c= t.Minutes_Worked__c + t.Add_Minute__c;
                      
                system.debug(t.Add_Minute_Change__c+'min change'+t.Add_Minute__c+'Before...'+ t.Minutes_Worked__c);
                }
               if((t.Timer_Status__c=='Pause' || t.Timer_Status__c=='Stop') && oldMap.get(t.Id).Timer_Status__c=='Start' && oldMap.get(t.Id).Timer_Status__c!=t.Timer_Status__c ){
              
               t.Stop_Time__c=System.Now();
                Long dt1Long = t.Start_Time__c.getTime();
                Long dt2Long = DateTime.now().getTime();
                Decimal milliseconds = dt2Long - dt1Long;
                Decimal seconds = milliseconds / 1000;
                Decimal minutes = seconds / 60;
                //t.Seconds_Worked__c=seconds;
                if(t.Minutes_Worked__c==null)t.Minutes_Worked__c=0;
                t.Minutes_Worked__c= t.Minutes_Worked__c+minutes.setScale(1);
                system.debug('min change'+minutes+'minutes...'+ t.Minutes_Worked__c);
               
        }
        if(t.Timer_Status__c=='Start' && oldMap.get(t.Id).Timer_Status__c!=t.Timer_Status__c){
               t.Start_Time__c=System.Now();
                system.debug('ggg....'+ t.Start_Time__c);
               }
            if(oldMap.get(t.Id).Timer_Status__c!='Stop'){   
         Decimal hours =  t.Minutes_Worked__c/ 60;
        t.Hours_Worked__c=hours.setscale(1);
        t.Seconds_Worked__c=hours.setscale(2);
        }
        }
        system.debug(t.Timer_Status__c+'t.Minutes_Worked__c...'+t.Minutes_Worked__c);
        if(t.Minutes_Worked__c!=null && t.Timer_Status__c=='Stop' && t.Minutes_Worked__c<6&& oldMap.get(t.Id).Timer_Status__c!='Stop'){
             t.Hours_Worked__c=0.1;
                }  
         if(t.Timer_Status__c=='Stop' && oldMap.get(t.Id).Timer_Status__c=='Stop'&& oldMap.get(t.Id).Hours_Worked__c!=houresChanged && houresChanged!=null){
                 t.Hours_Worked__c=houresChanged;
        }          
            
      }  
    }
    public void OnAfterUpdate(List<Time_Record__c> timeRecordList, Map<Id, Time_Record__c> oldTimeRecordMap, Map<Id, Time_Record__c> newTimeRecordMap) {
        if (!isAfterUpdateFlag) {
            List<Time_Record__c> completedTimeRecordList = new List<Time_Record__c>();
            for (Time_Record__c t : timeRecordList) {
                if (t.Recording_Status__c == 'Complete') {
                    completedTimeRecordList.add(t);
                }
                 
            }

            isAfterUpdateFlag = true;
            this.HandleProjectUpdates(oldTimeRecordMap, newTimeRecordMap);
            HL_TimeRecordRollupDayHandler rollupHandler = new HL_TimeRecordRollupDayHandler(completedTimeRecordList);
            rollupHandler.RollupRecords();
           
        }
    }

    public void OnAfterDelete(List<Time_Record__c> timeRecordList) {
        if (!isAfterDeleteFlag) {
            isAfterDeleteFlag = true;
            HL_TimeRecordRollupDayHandler rollupHandler = new HL_TimeRecordRollupDayHandler(timeRecordList);
            rollupHandler.RollupRecords();
        }
    }

    private List<Time_Record__c> HandleProjectUpdates(Map<Id, Time_Record__c> oldTimeRecordMap, Map<Id, Time_Record__c> newTimeRecordMap) {
        List<Time_Record__c> projectUpdateList = new List<Time_Record__c>();
        Map<Id, Time_Record_Rollup_Day__c> rollupUpdateMap = new Map<Id, Time_Record_Rollup_Day__c>();
        Map<Id, Time_Record_Rollup_Day__c> rollupDeleteMap = new Map<Id, Time_Record_Rollup_Day__c>();
        List<Time_Record_Time_Record_Rollup_Day__c> junctionDeleteList = new List<Time_Record_Time_Record_Rollup_Day__c>();
        for (Time_Record__c newTimeRecord : newTimeRecordMap.values()) {
            Time_Record__c oldTimeRecord = oldTimeRecordMap.get(newTimeRecord.Id);
            //Determine if the Project has Changed
            if (!(oldTimeRecord.Opportunity__c == newTimeRecord.Opportunity__c
                    && oldTimeRecord.Engagement__c == newTimeRecord.Engagement__c
                    && oldTimeRecord.Special_Project__c == newTimeRecord.Special_Project__c)) {
                projectUpdateList.add(oldTimeRecord);
            }
        }

        for (Time_Record_Time_Record_Rollup_Day__c j : [SELECT Time_Record_Rollup_Day__c,
                Time_Record__c,
                Time_Record_Rollup_Day__r.Opportunity__c,
                Time_Record__r.Opportunity__c,
                Time_Record_Rollup_Day__r.Engagement__c,
                Time_Record__r.Engagement__c,
                Time_Record_Rollup_Day__r.Special_Project__c,
                Time_Record__r.Special_Project__c,
                Time_Record_Rollup_Day__r.Hours_Worked__c,
                Time_Record__r.Hours_Worked__c
                FROM Time_Record_Time_Record_Rollup_Day__c
                WHERE Time_Record__c IN: projectUpdateList]) {
            if ( (j.Time_Record_Rollup_Day__r.Opportunity__c != null && j.Time_Record_Rollup_Day__r.Opportunity__c != j.Time_Record__r.Opportunity__c) ||
                    (j.Time_Record_Rollup_Day__r.Engagement__c != null && j.Time_Record_Rollup_Day__r.Engagement__c != j.Time_Record__r.Engagement__c) ||
                    (j.Time_Record_Rollup_Day__r.Special_Project__c != null && j.Time_Record_Rollup_Day__r.Special_Project__c != j.Time_Record__r.Special_Project__c)) {
                if (rollupDeleteMap.get(j.Time_Record_Rollup_Day__c) == null) {
                    //Update the Hours Worked or Remove the Record if it is 0
                    Time_Record_Rollup_Day__c trrd = rollupUpdateMap.get(j.Time_Record_Rollup_Day__c);
                    boolean inUpdate = false;

                    if (trrd == null)
                        trrd = j.Time_Record_Rollup_Day__r;
                    else
                        inUpdate = true;

                    trrd.Hours_Worked__c = trrd.Hours_Worked__c - j.Time_Record__r.Hours_Worked__c;

                    if (trrd.Hours_Worked__c > 0)
                        rollupUpdateMap.put(trrd.Id, trrd);
                    else {
                        if (inUpdate)
                            rollupUpdateMap.remove(trrd.Id);

                        rollupDeleteMap.put(trrd.Id, trrd);
                    }
                }
                //Delete the Junction Record
                junctionDeleteList.add(j);
            }
        }

        if (junctionDeleteList.size() > 0)
            delete junctionDeleteList;

        if (rollupDeleteMap.size() > 0)
            delete rollupDeleteMap.values();

        if (rollupUpdateMap.size() > 0)
            update rollupUpdateMap.values();

        return projectUpdateList;
    }


}