@IsTest
private class OutlookPanelConTest {
	@IsTest
    static void myUnitTest(){
        DateTime dt = System.now();        
        Event e = new Event(Subject='Test',StartDateTime=dt,EndDateTime=dt.addMinutes(5));
        insert e;
        
        List<Event> eList = OutlookPanelCon.getEvent('test',e.StartDateTime,e.EndDateTime);
    }
}