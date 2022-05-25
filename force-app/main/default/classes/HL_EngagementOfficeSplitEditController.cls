public with sharing class HL_EngagementOfficeSplitEditController {
    public Id EngagementId {get; set;}
    public List<Engagement_Office_Split__c> EngagementOfficeSplitList {get; set;}
    public List<String> SplitTypeList {get {return new List<String>{'','Office Split', 'Office Split Override'};}}
    public List<OfficeSplit> OfficeSplitList {get; set;}
    public List<OfficeSplit> OverrideOfficeSplitList {get; set;}
    
    
    public HL_EngagementOfficeSplitEditController(ApexPages.StandardController controller) {
        Engagement_Office_Split__c record = (Engagement_Office_Split__c)controller.getRecord();
        this.EngagementId = record.Engagement__c;
        this.EngagementOfficeSplitList = [SELECT Office__c,
                                          Office_Split__c,
                                          Office_Split_Override_Percent__c
                                          FROM Engagement_Office_Split__c
                                          WHERE Engagement__c = : this.EngagementId
                                          ORDER BY Office__c];
        
        this.OfficeSplitList = new List<OfficeSplit>();
        this.OverrideOfficeSplitList = new List<OfficeSplit>();
        
        for (Engagement_Office_Split__c els : this.EngagementOfficeSplitList){
            this.OfficeSplitList.add(new OfficeSplit(els.Office__c, els.Office_Split__c  * 100.0));
            this.OverrideOfficeSplitList.add(new OfficeSplit(els.Office__c, els.Office_Split_Override_Percent__c));
        }
    }
    
    public PageReference SaveRecords() {
        PageReference pf = ApexPages.currentPage();
        String errorMsg = this.Validate();
        
        if (String.isBlank(errorMsg)) {
            try {
                this.Save();
                pf = new PageReference('/' + this.EngagementId);
            }
            catch (DmlException ex) {
                ApexPages.addMessages(ex);
            }
        }
        else
            HL_PageUtility.ShowError(errorMsg);
        
        return pf;
    }
    
    public PageReference CancelAndReturn() {
        return new PageReference('/' + this.EngagementId);
    }
    
    private string Validate() {
        decimal overrideTotal = 0;
        
        for (OfficeSplit ls : this.OverrideOfficeSplitList) {
            if (ls.Percent != null)
                overrideTotal += ls.Percent;
        }
        
        //Verify if an Override was Specified the Totals must Equal 100.0
        return overrideTotal > 0 ? overrideTotal != 100 ? 'Override Values Must Equal 100.0' : '' : '';
    }
    
    private List<Engagement_Office_Split__c> Save() {
        Map<String, Decimal> overrideSplitMap = new Map<String, Decimal>();
        
        for(OfficeSplit ls : this.OverrideOfficeSplitList)
            overrideSplitMap.put(ls.Office, ls.Percent);
        
        for (Engagement_Office_Split__c els : this.EngagementOfficeSplitList) {
            Decimal overridePercent = overrideSplitMap.get(els.Office__c);
            if (overridePercent != null)
                els.Office_Split_Override_Percent__c = overridePercent;
            else
                els.Office_Split_Override_Percent__c = 0;
        }
        
        update this.EngagementOfficeSplitList;
        
        return this.EngagementOfficeSplitList;
    }
    
    public class OfficeSplit {
        public String Office {get; set;}
        public Decimal Percent {get; set;}
        
        public OfficeSplit(string Office, decimal percent){
            this.Office = Office;
            this.Percent = percent;
        }
    }
}