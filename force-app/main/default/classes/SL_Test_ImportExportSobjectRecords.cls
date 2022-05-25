/**  
* \arg ClassName      : SL_Test_Relationship_Rollups
* \arg JIRATicket     : HL-18
* \arg CreatedOn      : 25/JUNE/2014
* \arg LastModifiedOn : 25/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_ImportExportSobjectRecords
*/
@isTest
private class SL_Test_ImportExportSobjectRecords 
{
	static testMethod void Test_ImportExportSobjectRecords() 
	{
		List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 50);
        insert lstAccount;
        	
		SL_ImportExportSobjectRecords objImportExportSobjectRecords = new SL_ImportExportSobjectRecords();
		objImportExportSobjectRecords.sobjectPicklistWrapper.selectedValues = new List<Selectoption>();
		objImportExportSobjectRecords.sobjectPicklistWrapper.selectedValues.add(new Selectoption('Account', 'Account'));
		objImportExportSobjectRecords.exportRecords();
		objImportExportSobjectRecords.importRecords();
		objImportExportSobjectRecords.strExportContentVersionName = 'Export Account';
		objImportExportSobjectRecords.exportRecords();
		
		AggregateResult objAGR = [SELECT COUNT(Id) FROM Account];
		System.assertEquals(objAGR.get('expr0'), 50);
		
		objImportExportSobjectRecords.strImportContentVersionName = 'Export Account';
     	objImportExportSobjectRecords.importRecords();
     	
     	List<ContentVersion> lstCV = [SELECT Title, PathOnClient, VersionData FROM ContentVersion];
     	AggregateResult objAGR1 = [SELECT COUNT(Id) FROM Account];
		
		//System.assertEquals(objAGR1.get('expr0'), 100);     	
     	//System.assertEquals(objCV.Title, 'Export Account');
    }
    
    static testMethod void Test_SobjectMultiselectComponent() 
    {
     	SL_SobjectMultiselectComponent objMC = new SL_SobjectMultiselectComponent();
        objMC.leftSideOptions = new List<SelectOption>();
        objMC.rightSideOptions = new List<SelectOption>();
		objMC.leftOptionsHidden = 'A&a&b&b&C&c';
        objMC.rightOptionsHidden = '';
    }
}