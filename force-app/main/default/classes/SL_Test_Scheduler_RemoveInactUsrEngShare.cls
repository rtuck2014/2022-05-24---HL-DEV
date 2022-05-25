/**  
* \arg ClassName        : SL_Test_Scheduler_RemoveInactUsrEngShare
* \arg JIRATicket       : HL-32
* \arg CreatedOn        : 06/NOV/2014
* \arg LastModifiedOn   : 06/NOV/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : Test class for SL_Scheduler_RemoveInactiveUserEngShare schedular class 
*/
@isTest
private class SL_Test_Scheduler_RemoveInactUsrEngShare 
{
    static testMethod void Test_Scheduler_RemoveInactUsrEngShare() 
    {
        Test.startTest();
        String strScheduleTime = '0 0 23 * * ?';  
        String strJobId = System.schedule('TestScheduledBatch', strScheduleTime, new SL_Scheduler_RemoveInactiveUserEngShare() );
        Test.stopTest();
    }
}