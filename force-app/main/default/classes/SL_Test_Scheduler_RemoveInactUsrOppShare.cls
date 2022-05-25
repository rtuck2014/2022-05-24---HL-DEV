/**  
* \arg ClassName        : SL_Test_Scheduler_RemoveInactUsrOppShare
* \arg JIRATicket       : HL-90,HL-32
* \arg CreatedOn        : 22/Jan/2015
* \arg LastModifiedOn   : 22/Jan/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : Test class for SL_Scheduler_RemoveInactiveUserOppShare schedular class 
*/
@isTest
private class SL_Test_Scheduler_RemoveInactUsrOppShare 
{
    static testMethod void Test_Scheduler_RemoveInactUsrOppShare() 
    {
        Test.startTest();
        String strScheduleTime = '0 0 23 * * ?';  
        String strJobId = System.schedule('TestScheduledBatch', strScheduleTime, new SL_Scheduler_RemoveInactiveUserOppShare());
        Test.stopTest();
    }
}