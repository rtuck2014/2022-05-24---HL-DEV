public with sharing class HL_TimeRecordPeriodHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static Boolean isAfterInsertFlag = false;

    //Trigger Constructor
    public HL_TimeRecordPeriodHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
    }
    
    //Trigger Methods
    public void OnAfterInsert(List<Time_Record_Period__c> periods){
        if(!isAfterInsertFlag){            
            isAfterInsertFlag = true;

            for(Time_Record_Period__c trp : periods){
                //Insert the default staff records
                HL_TimeRecordPeriodStaffMemberHandler smHandler = new HL_TimeRecordPeriodStaffMemberHandler(trp);
                List<Time_Record_Period_Staff_Member__c> staffMembers = smHandler.InsertRecords();
                
                //Insert the default time records
                //HL_TimeRecordRollupWeekHandler trHandler = new HL_TimeRecordRollupWeekHandler(trp, staffMembers);
                //trHandler.InsertDefaultRecords();
            }
        }
    }


}