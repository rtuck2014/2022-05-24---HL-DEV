/**
* @Trigger Name     : SL_Test_ReportButton
* @JIRATicket       : DLIB-4
* @CreatedOn        : 26/AUG/2014
* @ModifiedBy       : Lodhi
* @Description      : Test class for SL_ReportButton class.
*/
@isTest
private class SL_Test_ReportButton 
{
    static testMethod void Test_ReportButton() 
    {
    	SL_Mass_Implementation__c objImplementation = new SL_Mass_Implementation__c(Name = 'TestImp-01',
    																				parentObjectName__c = 'Company_List__c',
    																				searchObjectName__c = 'Account',
    																				targetObjectName__c = 'Company_List_Member__c',
    																				targetObjectParentFieldName__c = 'company_list__c',
    																				targetObjectSearchFieldName__c = 'company__c');
    	insert objImplementation;
    	
    	Company_List__c objCompLst = new Company_List__c(Name='TestCL-01');
		insert objCompLst;
    	
    	SL_ReportButton objReportButton = new SL_ReportButton();
    	SL_ReportButton.generateReport(objImplementation.Id, 'All', objCompLst.Id);
    	SL_ReportButton.generateReport('', 'All', objCompLst.Id);
    	
    }
}