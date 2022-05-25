public with sharing class HL_OTIListController {
	private ApexPages.StandardSetController standardController;
    private List<Offsite_Template_Industry__c> industryList;
    private PageReference returnPage;
    public HL_OTIListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference updateFocus()
    {       
        // Get the selected records 
        List<Offsite_Template_Industry__c> selectedIndustries = (List<Offsite_Template_Industry__c>)standardController.getSelected();
        // Update records       
        for(Offsite_Template_Industry__c selectedIndustry : selectedIndustries)
            selectedIndustry.Focus__c = !selectedIndustry.Focus__c;
        return standardController.save();        
    }
    
    public PageReference updateMeeting()
    {       
        // Get the selected records 
        List<Offsite_Template_Industry__c> selectedIndustries = (List<Offsite_Template_Industry__c>)standardController.getSelected();
        // Update records       
        for(Offsite_Template_Industry__c selectedIndustry : selectedIndustries)
            selectedIndustry.Meeting__c = !selectedIndustry.Meeting__c;
        return standardController.save();      
    }

    public PageReference updateIndustriesAndReturn()
    {       
        updateIndustries();
        return returnPage;
    }

    public void updateIndustries()
    {       
        if(industryList != null){
        	update industryList;
            HL_PageUtility.ShowConfirm('Records Saved'); 
        }
    }
    
    public PageReference cancel(){
        return returnPage;
    }
    
    public List<Offsite_Template_Industry__c> getIndustries(){
        if(industryList == null){
            //This is really bad to have to go off Recently Viewed, but seems to be the only option at present
            List<RecentlyViewed> rvList = [SELECT Id FROM RecentlyViewed WHERE Type = 'Offsite_Template__c' ORDER BY LastViewedDate DESC];
            if(rvList.size() > 0){
				industryList = [SELECT Offsite_Template__c, Industry__c, Focus__c, Meeting__c FROM Offsite_Template_Industry__c WHERE Offsite_Template__c =: rvList[0].Id ORDER BY Industry__r.Name];
                returnPage = new PageReference('/' + rvList[0].Id);
            }
            else
                industryList = new List<Offsite_Template_Industry__c>();
        }
        return industryList;
    }
}