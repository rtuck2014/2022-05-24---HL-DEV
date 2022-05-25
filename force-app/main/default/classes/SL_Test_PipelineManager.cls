/**  
* \arg ClassName      : SL_Test_PipelineManager
* \arg JIRATicket     : HL-16
* \arg CreatedOn      : 09/JUNE/2014
* \arg LastModifiedOn : 09/JUNE/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Test class for SL_PipelineManager and SL_Paginator class.
*/
@isTest()
private class SL_Test_PipelineManager 
{    
    static testMethod void Test_PipelineManager() 
    {
        SL_PipelineManager objPipelineManager = new SL_PipelineManager();
        objPipelineManager.getOpportunityOptions();
        
       	List<Opportunity__c> lstOpportunity = new List<Opportunity__c>();
        For(Opportunity__c objOpportunity : SL_TestSetupUtils.CreateOpp('Opportunity__c', 5))
        {
        	objOpportunity.Estimated_Capital_Raised_MM__c = 123456789;
            objOpportunity.Beneficial_Owner_Control_Person_form__c = 'No';
        	lstOpportunity.add(objOpportunity);
        }
        insert lstOpportunity;
        
        List<Engagement__c> lstEngagement = new List<Engagement__c>(); 
        For(Engagement__c objEngagement : SL_TestSetupUtils.CreateEngagement('Engagement__c', 5))
        {
        	objEngagement.Bill_Subject__c = true;
        	objEngagement.Bond_Price__c = 123456789;
        	lstEngagement.add(objEngagement);
        }
        insert lstEngagement;
        
        objPipelineManager.getEngagementOptions();
        objPipelineManager.getOpenOrClosed();
        objPipelineManager.searchRecords();
        objPipelineManager.changeColumns();
        
        String strMsg = SL_PipelineManager.updateSobjectRecord('Opportunity__c', lstOpportunity[0].Id, 'Name', 'Name 1');
        String strMsg1 = SL_PipelineManager.updateSobjectRecord('Engagement__c', lstEngagement[0].Id, 'Bond_Price__c', '987654321');
        
        System.assertEquals(strMsg, '');
		System.assertEquals(strMsg1, '');         
    }
}