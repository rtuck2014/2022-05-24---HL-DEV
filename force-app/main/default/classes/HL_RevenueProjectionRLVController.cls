public with sharing class HL_RevenueProjectionRLVController {
    private id EngId;
    public boolean CurrentOnly{get;set;}
    public ApexPages.StandardController stdCtrl;
    public ApexPages.StandardSetController setCon {get{
        if(setCon==null){
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                'SELECT Month__c, Year__c, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Total__c, Archive__c, CurrencyIsoCode FROM Revenue_Projection__c WHERE Engagement__C =:EngId' + (CurrentOnly ? ' AND Archive__c = false ' : '') + ' ORDER BY Year__c, Month__c ASC'));
            setCon.setPageSize(5);
        }
        return setCon;
    }set;}
    
    public HL_RevenueProjectionRLVController(ApexPages.StandardController stdController){
        EngId = stdController.getrecord().id;
        CurrentOnly=true;
        stdCtrl = stdController;
    }
    
    public List<Revenue_Projection__c> getRevenueProjectionList(){
        return filterCurrentDate(setCon.getRecords());
    }
    
    public PageReference getRedirectToPage() {
        PageReference redirect = new PageReference('/apex/HL_RevenueProjectionEditView?id=' + EngId);
        redirect.setRedirect(true);
        return redirect;
    }
    
    public void Filter(){
        
        setCon = null;
    }
    
    public boolean hasNext{
        get{
            return setCon.getHasNext();
        }
        set;
    }
    
    public boolean hasPrevious{
        get{
            return setCon.getHasPrevious();
        }
        set;
    }
    
    public integer pageNumber {
        get{
            return setCon.getPageNumber();
        }
        set;
    }
    
    public void first(){
        setCon.first();
    }
    
    public void last(){
        setCon.last();
    } 
    
    public void previous(){
        setCon.previous();
    }
    
    public void next(){
        setCon.next();
    }
    
    public pageReference cancel(){
        return stdCtrl.cancel();
    }
    
    public List<Revenue_Projection__c> filterCurrentDate(List<Revenue_Projection__c> revenueProjections) {
        if (CurrentOnly) {
            integer year = System.Today().year();
            integer month = System.Today().month();
    
            List<Revenue_Projection__c> returnProjections = new List<Revenue_Projection__c>();
    
            for(Revenue_Projection__c p: revenueProjections) {
                if (Integer.valueof(p.Month__c.trim()) >= month && Integer.valueof(p.Year__c.trim()) >= year) {
                    returnProjections.add(p);
                }
            }  
            
            return returnProjections;
        }
        else {
            return revenueProjections;
        }
	}
}