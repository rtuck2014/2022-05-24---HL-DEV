public with sharing class HL_EngagementLOBSplitEditController {
	public Id EngagementId {get; set;}
	public List<Engagement_LOB_Split__c> EngagementLOBSplitList {get; set;}
	public List<String> SplitTypeList {get {return new List<String>{'','LOB Split', 'LOB Split Override'};}}
	public List<LOBSplit> LOBSplitList {get; set;}
	public List<LOBSplit> OverrideLOBSplitList {get; set;}


	public HL_EngagementLOBSplitEditController(ApexPages.StandardController controller) {
		Engagement_LOB_Split__c record = (Engagement_LOB_Split__c)controller.getRecord();
		this.EngagementId = record.Engagement__c;
		this.EngagementLOBSplitList = [SELECT LOB__c,
		                               LOB_Split__c,
		                               LOB_Split_Override_Percent__c
		                               FROM Engagement_LOB_Split__c
		                               WHERE Engagement__c = : this.EngagementId
		                                   ORDER BY LOB__c];

		this.LOBSplitList = new List<LOBSplit>();
		this.OverrideLOBSplitList = new List<LOBSplit>();

		for (Engagement_LOB_Split__c els : this.EngagementLOBSplitList){
				this.LOBSplitList.add(new LOBSplit(els.LOB__c, els.LOB_Split__c  * 100.0));
				this.OverrideLOBSplitList.add(new LOBSplit(els.LOB__c, els.LOB_Split_Override_Percent__c));
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

		for (LOBSplit ls : this.OverrideLOBSplitList) {
			if (ls.Percent != null)
				overrideTotal += ls.Percent;
		}

		//Verify if an Override was Specified the Totals must Equal 100.0
		return overrideTotal > 0 ? overrideTotal != 100 ? 'Override Values Must Equal 100.0' : '' : '';
	}

	private List<Engagement_LOB_Split__c> Save() {
		Map<String, Decimal> overrideSplitMap = new Map<String, Decimal>();

		for(LOBSplit ls : this.OverrideLOBSplitList)
			overrideSplitMap.put(ls.LOB, ls.Percent);

		for (Engagement_LOB_Split__c els : this.EngagementLOBSplitList) {
			Decimal overridePercent = overrideSplitMap.get(els.LOB__c);
			if (overridePercent != null)
				els.LOB_Split_Override_Percent__c = overridePercent;
			else
				els.LOB_Split_Override_Percent__c = 0;
		}

		update this.EngagementLOBSplitList;

		return this.EngagementLOBSplitList;
	}

	public class LOBSplit {
		public String LOB {get; set;}
		public Decimal Percent {get; set;}

		public LOBSplit(string lob, decimal percent){
			this.LOB = lob;
			this.Percent = percent;
		}
	}
}