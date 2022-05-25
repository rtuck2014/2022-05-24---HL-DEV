/**  
* \arg ClassName        : SL_Test_BuyerAccountPDFReport
* \arg JIRATicket       : HL-38
* \arg CreatedOn        : 03/NOV/2014
* \arg LastModifiedOn   : 03/NOV/2014
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : Test class for SL_BuyerAccountPDFReport class. 
*/
@isTest
private class SL_Test_BuyerAccountPDFReport 
{
    static testMethod void Test_BuyerAccountPDFReport() 
    {
        List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account', 10);
        insert lstAccount; 
        System.assertEquals(lstAccount.size(), 10);
        
        List<Contact> lstContactHL = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 10, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE))
        {
            objContact.AccountId = lstAccount[0].Id;
            lstContactHL.add(objContact);
        }   
        insert lstContactHL;
        System.assertEquals(lstContactHL.size(), 10);
        
        List<Contact> lstContactExt = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 10, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT))
        {
            lstContactExt.add(objContact);
        }
        insert lstContactExt;
        System.assertEquals(lstContactExt.size(), 10);
        
        List<Engagement__c> lstEngagement = SL_TestSetupUtils.CreateEngagement('Engagement', 1);
        insert lstEngagement;
        System.assertEquals(lstEngagement.size(), 1);
        
        Integer i = 0;
        List<Engagement_Counterparty__c> lstEC = new  List<Engagement_Counterparty__c>();
        for(Engagement_Counterparty__c objEC : SL_TestSetupUtils.CreateEC('Engagement_Counterparty__c', 10))
        {
            objEC.Company__c = lstAccount[i].Id;
            objEC.Engagement__c = lstEngagement[0].Id;
            objEC.Type__c = 'Financial';
            objEC.Tier__c = 'B';
            objEc.Status_pl__c = 'Declined / Passed';
            objEC.Secondary_HL_Contact__c = lstContactHL[i].Id;
            if(i < 8)
            {
	            objEC.Initial_Contact__c = Date.today();
	            objEC.Phone_Discussion__c = Date.today().addDays(2);  
	            objEC.Sent_Teaser__c = Date.today().addDays(2);
	            objEC.Sent_Counter_Executed_CA__c = Date.today().addDays(4);
	            objEC.Executed_Confidentiality_Agreement__c = Date.today().addDays(4);
	            objEC.Sent_Book__c = Date.today().addDays(6);
	            objEC.Process_Letter_Sent__c = Date.today().addDays(6);
	            objEC.Book_Returned__c = Date.today().addDays(2);
	            objEC.Proposal_Indication__c = Date.today().addDays(4);
	            objEC.Met_With_Management__c = Date.today().addDays(2);
	            objEC.Letter_of_Intent__c = Date.today().addDays(4);
	            objEC.Declined_Passed__c = Date.today().addDays(2);
	            objEC.Sent_Blow_up_Letter__c = Date.today().addDays(4);
            }	            
            lstEC.add(objEC);
            i++;
        }
        insert lstEC;
        
        System.assertEquals(lstEC.size(), 10);
        
        i = 0;
        List<Engagement_Counterparty_Contact__c> lstECC = new  List<Engagement_Counterparty_Contact__c>();
        for(Engagement_Counterparty_Contact__c objECC : SL_TestSetupUtils.CreateECC('Engagement_Counterparty_Contact__c', 10))
        {
        	objECC.Contact__c = lstContactExt[i].Id;
        	objECC.Counterparty__c = lstEC[0].Id;
        	lstECC.add(objECC);		
        	i++;
        }
        insert lstECC;
        
        System.assertEquals(lstECC.size(), 10);
        
        System.currentPageReference().getParameters().put('Id', lstEngagement[0].Id);
        System.currentPageReference().getParameters().put('report', 'SL_BuyerAccountListMediumPDFReport');
        ApexPages.StandardController sc = new ApexPages.standardController(lstEngagement[0]);
        SL_BuyerAccountPDFReport objBuyerAccountPDFReport = new SL_BuyerAccountPDFReport(sc);
        objBuyerAccountPDFReport.strBuyerType = 'Bank';
        objBuyerAccountPDFReport.strDealRanking = 'A';
        objBuyerAccountPDFReport.strPhaseStatus = 'Initial Contact';
        objBuyerAccountPDFReport.strSortColumn = 'Type__c';
        objBuyerAccountPDFReport.strSelectedContact = lstContactHL[0].Id + ',' + lstContactHL[1].Id + ',' + lstContactHL[2].Id; 
        objBuyerAccountPDFReport.generateReport();
        objBuyerAccountPDFReport.getBuyerAccountWrappers();
        objBuyerAccountPDFReport.getBuyerAccountMediumWrappers();
        objBuyerAccountPDFReport.getBuyerAccountRegularWrappers();
        objBuyerAccountPDFReport.getColumnWrappers();
        objBuyerAccountPDFReport.getCSVCommonFields();
        objBuyerAccountPDFReport.getHLContacts();
        objBuyerAccountPDFReport.getSortingColumns();
        objBuyerAccountPDFReport.getReportVersions();
        objBuyerAccountPDFReport.getIsPrintColumn();
        objBuyerAccountPDFReport.getCurrentDateTime();
        
        SL_SummaryReport objSummaryReport = new SL_SummaryReport(sc);
    }
}