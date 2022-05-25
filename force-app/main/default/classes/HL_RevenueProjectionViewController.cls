public class HL_RevenueProjectionViewController {
    
    private Id EngId;
    public List<Revenue_Projection__c> revenueProjectionList {get;set;}
    
    public HL_RevenueProjectionViewController (ApexPages.StandardController stdController){
        EngId = stdController.getRecord().Id;
        revenueProjectionList = [SELECT Year__c, Month__c, Projected_Transaction_Fee__c, Projected_Monthly_Fee__C, Archive__c FROM Revenue_Projection__c WHERE Engagement__c =: EngId ORDER BY Year__c,Month__C ASC LIMIT 13];                
    }

    public PageReference getRedirectToPage() {
        PageReference redirect = new PageReference('/apex/HL_RP?id=' + EngId);
        redirect.setRedirect(true);
        return redirect;
    }
    
    public PageReference getRedirectToPageView() {
        PageReference redirect = new PageReference('/apex/HL_RevenueProjectionRelatedListView?id=' + EngId);
        redirect.setRedirect(true);
        return redirect;
    }
}