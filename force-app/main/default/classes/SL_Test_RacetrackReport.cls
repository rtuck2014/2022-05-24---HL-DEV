/** 
* \arg ClassName      : SL_Test_RacetrackReport
* \arg JIRATicket     : HL-8,9,10
* \arg CreatedOn      : 13/MAY/2014
* \arg LastModifiedOn : 13/MAY/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_RacetrackReport.cls
*/

@isTest
private class SL_Test_RacetrackReport 
{
    private static testmethod void  test_RacetrackReport() 
    {

        
        List<Account> lstAccount = new List<Account>();
        
        lstAccount.add(new Account(Name='Acc 1'));
        lstAccount.add(new Account(Name='Acc 2'));
        lstAccount.add(new Account(Name='Acc 3'));

        insert lstAccount; 
        
        
        List<Opportunity> lstEC = new  List<Opportunity>();
        for(Opportunity objEC : SL_Test_RacetrackReport.CreateEC('Opp NN1 ', lstAccount[0].Id, 5))
        {
            objEC.OwnerID = UserInfo.getUserId();
            lstEC.add(objEC);
        }
        
        for(Opportunity objEC : SL_Test_RacetrackReport.CreateEC('Opp NN2 ', lstAccount[0].Id, 5))
        {
            objEC.OwnerID = UserInfo.getUserId();
            lstEC.add(objEC);
        }
        
        for(Opportunity objEC : SL_Test_RacetrackReport.CreateEC('Opp NN3 ', lstAccount[0].Id, 5))
        {
            objEC.OwnerID = UserInfo.getUserId();
            lstEC.add(objEC);
        }
        insert lstEC;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('parentId',String.valueOf(lstAccount[0].Id));
        ApexPages.currentPage().getParameters().put('cs','default');
        
        SL_RacetrackReport objRR = new SL_RacetrackReport();
        objRR.getSearchCompParams();


        SL_RacetrackReport__c objRRCustomSetting = new SL_RacetrackReport__c( Name = 'default', 
                                                                              ChildObjectAPIName__c = 'Opportunity',
                                                                              FieldSetAPIName__c = 'SL_OppRacetrackReport',
                                                                              GroupingObjectAPIName__c = 'Account',
                                                                              GroupingObjectRelationshipAPIName__c ='AccountID',   
                                                                              Logo_URL__c = 'https://google.com',
                                                                              ParentObjectAPIName__c = 'User', 
                                                                              ParentObjectRelationshipAPIName__c = 'OwnerId',
                                                                              ShowExtraGroupOption__c = true,
                                                                              Show_Filter__c = true);
       
        
        insert objRRCustomSetting;
        
        objRR = new SL_RacetrackReport();

        
        String strTmp = '';
        SL_RacetrackReport.RecordWrapper recWr = new SL_RacetrackReport.RecordWrapper('Name',lstAccount[0],'Acc 1');
        Sobject sObj = recWr.sObj;
        strTmp = recWr.strRT;
        strTmp = recWr.companyName;
        
        List<SL_RacetrackReport.RecordWrapper> lstRw = new List<SL_RacetrackReport.RecordWrapper>();
        lstRw.add(recWr);
        SL_RacetrackReport.GroupWrapper grWr = new SL_RacetrackReport.GroupWrapper('Name', lstRw, new Map<String, Integer>{'Name'=>10});

        strTmp = grWr.strRT;
        grWr.lstRecordWrapper = lstRw;
        grWr.mapSubTotal = new Map<String, Integer>{'Name'=>5};
        strTmp = objRR.getCurrentDateTime();
         strTmp = objRR.formatDate('2011/10/10');
        
        
        //objRR.engagementCounterparty.OwnerID = UserInfo.getUserId();
        objRR.getGroupByOptions();
        objRR.getCurrentDateTime();
        objRR.getSortingOption();
        objRR.getStageOptions();
        objRR.generateReport();
        
        //objRR.strChildObject = 'Opportunity';
        objRR.inRecordFiltersCols = '';
        objRR.inRecordFiltersAdv = '';
        objRR.generateReport();
        
        
        
        //objRR.isFilter = true;
        objRR.generateReport();
        //objRR.lstPicklistWrapperL[0].selectedValues = new List<String>();
        /*
        objRR.lstSelectedStage = new List<String>{'Book_Returned__c', 'Closing_Round_Bid_Date__c', 'Confidentiality_Agreement__c', 
                                                  'Final_Round_Bid_Date__c','Deal_Ranking__c', 'Declined_Passed__c'};
        */
        objRR.strGroupBy = 'Account:Name';
        objRR.strSortBy = 'Name';
        objRR.generateReport();
        objRR.strGroupBy = 'Account:REFERENCE';
        objRR.generateReport();
        objRR.strGroupBy = 'Account.OwnerId:REFERENCE';
        objRR.generateReport();
        //objRR.lstPicklistWrapperL[0].selectedValues = new List<String>{'A', 'B', 'C'};
        //objRR.generateReport();
        Test.stopTest();
    }
    
    public static List<Opportunity> CreateEC(String basename, ID inAccID, Integer inCount)
	{
		List<Opportunity> results = new List<Opportunity>();
		
		for(Integer x = 0; x< inCount; x++)
		{
			Opportunity objEC = new Opportunity(Name=basename+' '+x, AccountId=inAccID, CloseDate=Date.today(),StageName='Qualification');
			results.add(objEC);
		}
		return results;
	}
    
}