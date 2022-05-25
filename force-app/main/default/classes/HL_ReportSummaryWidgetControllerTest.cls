/**
 *  Unit tests for the HL_ReportSummaryWidget Lightning component's server-side controller (HL_ReportSummaryWidgetController).
 *
 *  @author Graham MacRobie (graham.macrobie1129@hl.com)
 *  @date   February 2022
*/

@isTest(SeeAllData=true)  // there isn't a good way to test report data without using reports already in the org
private class HL_ReportSummaryWidgetControllerTest {
    @isTest
    static void testGetReportData() {
        HL_ReportSummaryWidgetController.ReportData rptData = HL_ReportSummaryWidgetController.getReportData('rptdevname', 'ACTIVITY_ID');

        System.assertEquals('rptLabel', rptData.title);
        System.assert(rptData.columns.size() >= 7);
    }
}