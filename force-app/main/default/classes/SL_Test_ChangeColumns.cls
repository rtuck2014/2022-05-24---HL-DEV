/**  
* \arg ClassName      : SL_Test_ChangeColumns
* \arg JIRATicket     : HL-17
* \arg CreatedOn      : 16/JUNE/2014
* \arg LastModifiedOn : 16/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class SL_ChangeColumns 
*/
@isTest
private class SL_Test_ChangeColumns 
{
	static testMethod void Test_ChangeColumns () 
    {
        SL_ChangeColumns objChangeColumns = new SL_ChangeColumns();
		
		//objChangeColumns.opportunityPicklist.selectedValues = new List<SelectOption>();
        //objChangeColumns.saveChangeColumn();

		//objChangeColumns.opportunityPicklist.selectedValues = new List<SelectOption>();
        //objChangeColumns.opportunityPicklist.selectedValues.add(new Selectoption('Description__c','Description'));
        //objChangeColumns.engagementPicklist.selectedValues = new List<SelectOption>();
        //objChangeColumns.engagementPicklist.selectedValues.add(new Selectoption('Bill_Hourly__c','Bill Hourly'));
        //objChangeColumns.saveChangeColumn();
        //objChangeColumns.cancelChangeColumn();
        //List<Pipeline_Column_Selection__c> lstPCS = [SELECT Id, 
        													//Engagement_Columns__c, 
        												    //Opportunity_Columns__c,
        												    //User__c 
        											   //FROM Pipeline_Column_Selection__c];
        //System.assertEquals(lstPCS.size(),1);
        //System.assertEquals(lstPCS[0].User__c,Userinfo.getUserId());
        //System.assertEquals(lstPCS[0].Engagement_Columns__c, 'Bill_Hourly__c');
        //System.assertEquals(lstPCS[0].Opportunity_Columns__c, 'Description__c');
    }
}