/*
// Date: 2021-03-29
// class name: HL_MassEditEngValAllocationsCntrl
//Purpose:Req: Mass Edit button
//Created By : Sravan Devada
*/
Public class HL_MassEditEngValAllocationsCntrl{
 public Eng_Valuation_Period_Allocation__c engVP {get;set;} 
 public string engVPId {get;set;}
 public Static Boolean successMsg{get;set;}
 public HL_MassEditEngValAllocationsCntrl(ApexPages.StandardController controller) {
   engVP=new Eng_Valuation_Period_Allocation__c();
   engVP= (Eng_Valuation_Period_Allocation__c)controller.getRecord();  
   engVPId=apexpages.currentpage().getparameters().get('eid');
   successMsg=false;
 }
 
 /*
 // Date: 2021-03-29
// Description: Called from lwc c:hlengVPAmassedit
//Method name: getEngValuationPeriodAllocation
//Purpose:Req: Mass Edit button
//Created By : Sravan Devada
 */
 @AuraEnabled(Cacheable=true)
 public static List <Eng_Valuation_Period_Allocation__c> getEngValuationPeriodAllocation(String recordId) {
 List<Eng_Valuation_Period_Allocation__c> engValAllocationList = [SELECT Id,Name,Week_Starting__c,Week_Ending__c,Associate_Allocation__c,Analyst_Allocation__c,Admin_Allocation__c,Engagement_Valuation_Period__r.Engagement__c
 FROM Eng_Valuation_Period_Allocation__c
 Where Engagement_Valuation_Period__c =:recordId Order by Week_Starting__c
 LIMIT 1000];
 return engValAllocationList;
 } 

/*
 // Date: 2021-03-29
// Description: Called from lwc c:hlengVPAmassedit
//Method name: deleteEngValuationPeriodAllocation
//Purpose:Req: Mass Edit button
//Created By : Sravan Devada
*/
 @AuraEnabled()
 public static void deleteEngValuationPeriodAllocation(list<Id> recordIds) {
 list<Eng_Valuation_Period_Allocation__c> engValAllocation=[SELECT Id FROM Eng_Valuation_Period_Allocation__c where id in: recordIds];
 delete engValAllocation;
 }

/*
 // Date: 2021-03-29
// Description: Called from lwc c:hlengVPAmassedit
//Method name: deleteEngValuationPeriodAllocation
//Purpose:Req: Mass Edit button
//Created By : Sravan Devada
*/
 @AuraEnabled()
 public static Boolean checkDeletePermision() {
     string myObjectIds =label.Eng_VPA_Obj_id;
     UserRecordAccess accessList = [SELECT HasDeleteAccess, HasEditAccess, HasReadAccess, RecordId FROM UserRecordAccess WHERE RecordId = :myObjectIds AND UserId = :UserInfo.getUserId()];
     if(accessList.HasDeleteAccess){
     return true;
     }
     return false;
 }
     public static String CreateEngVPAllocations(list<Eng_Valuation_Period_Allocation__c> lstEngVPRec){
        Boolean duplicatecheck=false;
        string errorMsg='';
        List<Eng_Valuation_Period_Allocation__c> engVPAllocToInsert = new List<Eng_Valuation_Period_Allocation__c>();
        set<date> startdateSet = new set<date>();
         set<date> existingStartdateSet = new set<date>();
         for(Eng_Valuation_Period_Allocation__c egVpRec :[Select id,Week_Starting__c from Eng_Valuation_Period_Allocation__c where Engagement_Valuation_Period__c =: lstEngVPRec[0].Engagement_Valuation_Period__c]){
         startdateSet.add(egVpRec.Week_Starting__c);
         existingStartdateSet.add(egVpRec.Week_Starting__c);
        }
        for(Eng_Valuation_Period_Allocation__c egVpRec : lstEngVPRec){
                  if(egVpRec.Week_Ending__c != null){
             Date cliendDateWeekStart = egVpRec.Week_Starting__c.toStartofWeek();
             Date ClientWeekEnd = cliendDateWeekStart.addDays(6);
             system.debug('cliendDateWeekStart...'+cliendDateWeekStart);
              system.debug('ClientWeekEnd ...'+ClientWeekEnd);
            List<Date> lstOfWeekStartDates = GetEngVPAllocatioNStartDate(egVpRec.Week_Ending__c,egVpRec.Week_Starting__c);
            system.debug('lstOfWeekStartDates ...'+lstOfWeekStartDates);
            for(Date d : lstOfWeekStartDates){
                    Decimal adminAllocation;
                    Decimal analystAllocation;
                    Decimal associateAllocation;
                    if(!startdateSet.contains(d)){
                    engVPAllocToInsert.add(new Eng_Valuation_Period_Allocation__c(Engagement_Valuation_Period__c = egVpRec.Engagement_Valuation_Period__c ,
                                                                   Week_Starting__c = d,Admin_Allocation__c=egVpRec.Admin_Allocation__c,Associate_Allocation__c=egVpRec.Associate_Allocation__c,Analyst_Allocation__c=egVpRec.Analyst_Allocation__c,
                                                                   Week_Ending__c = d.addDays(6)));
                   }
                    else{
                    duplicatecheck=true;
                    }                                               
                    startdateSet.add(d);
            }
            Date cliendDateWeekStart1 = egVpRec.Week_Ending__c.toStartofWeek();
            if(!startdateSet.contains(cliendDateWeekStart1 )){
            engVPAllocToInsert.add(new Eng_Valuation_Period_Allocation__c(Engagement_Valuation_Period__c = egVpRec.Engagement_Valuation_Period__c,
                                                                   Week_Starting__c = cliendDateWeekStart1,Admin_Allocation__c=egVpRec.Admin_Allocation__c,Associate_Allocation__c=egVpRec.Associate_Allocation__c,Analyst_Allocation__c=egVpRec.Analyst_Allocation__c,
                                                                   Week_Ending__c = cliendDateWeekStart1.addDays(6)));
            }
            else if(existingStartdateSet!=null && existingStartdateSet.contains(cliendDateWeekStart1)){
             duplicatecheck=true;
            }
           
                                                                   }
            

        }
        if(duplicatecheck && engVPAllocToInsert.isEmpty()){
        errorMsg ='Duplicate Record/s Exists';
        }
        if(duplicatecheck && !engVPAllocToInsert.isEmpty()){
        errorMsg ='Duplicate Record/s Exists but valid record/s got inserted';
        }
         if(!duplicatecheck && !engVPAllocToInsert.isEmpty()){
         successMsg=true;
       
        }
        else{
        successMsg=false;
        }
        if(!engVPAllocToInsert.isEmpty()){
        system.debug('engVPAllocToInsert....size...'+engVPAllocToInsert.size());
            Database.insert(engVPAllocToInsert, false);
           //insert engVPAllocToInsert;
        }
        return errorMsg;
    } 
     
    /* Added Date : March 10, 2021
    Logic to Get the Start of the Week Date upt to the Client_Final_Deadline__c */
    public static List<Date> GetEngVPAllocatioNStartDate(Date endDate,Date startDate){
        List<Date> dateList = new List<Date>();
        if(startDate==null){
        startDate=Date.today();
        }
        Date todaysDate = startDate;
         Date clientDate = endDate;
        Date weekStart = todaysDate.toStartofWeek();
        Date weekEnd = weekStart.addDays(6);
        Date cliendDateWeekStart = clientDate.toStartofWeek();
        Date ClientWeekEnd = cliendDateWeekStart.addDays(6);
        Integer x = weekStart.daysBetween(cliendDateWeekStart);
        Integer totalWeeksBetweenDates = x/7;
        for(Integer i = 0; i < totalWeeksBetweenDates; i++){
            System.debug('I is: ' + i);
            if(dateList.isEmpty()){
                dateList.add(weekStart);
               // dateList.add(cliendDateWeekStart);
            } else {
                Date dd = dateList[i-1];
                dateList.add(dd.addDays(7));
            }
        }
    System.debug('Date List to Return is  ' + dateList);
        return dateList;
    }
      public pagereference save()
    {
    try{
    List<Eng_Valuation_Period_Allocation__c> engVPAllocLst = new List<Eng_Valuation_Period_Allocation__c>();
    engVPAllocLst.add(engVP);
        system.debug('engVP....'+engVP);
     String errorMsg =CreateEngVPAllocations(engVPAllocLst);
         if (engVP != null ){
  // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Valid Record/s inserted successfully,please click Cancel'));
   }
   if(!string.isBlank(errorMsg) && !successMsg){
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,errorMsg));
    return null;
   }else{
    PageReference pg = new PageReference('/apex/HL_EngValuationPeriodView');//Second //VFPage is another visualforce page
     pg.getParameters().put('id', engVP.Engagement_Valuation_Period__c);
        pg.setRedirect(true);
        return pg;
        }
    }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
  @AuraEnabled()
 public static String saveRecord(Eng_Valuation_Period_Allocation__c engVPAlloc) {
 system.debug('engVPAlloc....'+engVPAlloc);
  List<Eng_Valuation_Period_Allocation__c> engVPAllocLst = new List<Eng_Valuation_Period_Allocation__c>();
    engVPAllocLst.add(engVPAlloc);
 String errorMsg=  CreateEngVPAllocations(engVPAllocLst);
 system.debug('errorMsg....'+errorMsg);
  return errorMsg;
 }
  @AuraEnabled()
 public static string deleteRecord(String engVPAllocId) {
  if(engVPAllocId!=null && engVPAllocId!=''){
  Eng_Valuation_Period_Allocation__c engVp=[select id from Eng_Valuation_Period_Allocation__c where id=:engVPAllocId];
  delete engVp;
  
  }
  return 'Sucess';
 }
}