public class HL_RevenueProjectionHandler {
    public void onBeforeInsert(List<Revenue_Projection__c> newRevenueProjectionList){
    	Set<Id> engId = new Set<Id>();
    	Map<Id,Engagement__c> engagementMap = new Map<Id,Engagement__c>();
    	for(Revenue_Projection__c rp : newRevenueProjectionList){
    		engId.add(rp.Engagement__c);
    	}
    	for(Engagement__c eng : [SELECT CurrencyIsoCode FROM Engagement__c WHERE Id IN : engId]){
    		engagementMap.put(eng.Id, eng);
    	}
        updateCurrencyIso(engagementMap, newRevenueProjectionList);
		updateArchived(newRevenueProjectionList);
    }

	public void onBeforeUpdate(List<Revenue_Projection__c> newRevenueProjectionList){
        updateArchived(newRevenueProjectionList);
    }

	//Manage Revenue Revenue Projection Sharing Rules
    public void onAfterInsert(Map<Id, Revenue_Projection__c> newRevenueProjectionMap, List<Revenue_Projection__c> newRevenueProjectionList){
		updateEngagementCurrentRevenueProjection(newRevenueProjectionList);
        SL_ManageSharingRules.manageRevAccrualsCounterpartySharingRules(newRevenueProjectionMap.values(), 'Revenue_Projection__c');
    }

    public void onAfterUpdate(List<Revenue_Projection__c> newRevenueProjectionList){
		updateEngagementCurrentRevenueProjection(newRevenueProjectionList);
    }

	public void onAfterDelete(List<Revenue_Projection__c> oldRevenueProjectionList){
		deleteEngagementCurrentRevenueProjection(oldRevenueProjectionList);
    }

    public void updateCurrencyIso(Map<Id,Engagement__c> engagementMap, List<Revenue_Projection__c> revenueProjectionList) {
    	for(Revenue_Projection__c rp : revenueProjectionList){
    		rp.CurrencyIsoCode = engagementMap.get(rp.Engagement__c).CurrencyIsoCode;
    	}
    }

	public void updateArchived(List<Revenue_Projection__c> newRevenueProjectionList) {
		integer year = System.Today().year();
        integer month = System.Today().month();

        for(Revenue_Projection__c p: newRevenueProjectionList) {
            if (Integer.valueof(p.Month__c.trim()) < month && Integer.valueof(p.Year__c.trim()) <= year) {
                p.Archive__c = true;
            }
        }   
	}

	public void updateEngagementCurrentRevenueProjection(List<Revenue_Projection__c> newRevenueProjectionList) {
		integer year = System.Today().year();
        integer month = System.Today().month();
		List<Engagement__c> engUpdateList = new List<Engagement__c>();

        for(Revenue_Projection__c p: newRevenueProjectionList) {
            if (Integer.valueof(p.Month__c.trim()) == month && Integer.valueof(p.Year__c.trim()) == year && (p.Engagement__r.Current_Revenue_Projection__c != p.Id 
            || p.Engagement__r.Projected_Monthly_Fee__c != p.Projected_Monthly_Fee__c || p.Engagement__r.Projected_Transaction_Fee__c != p.Projected_Transaction_Fee__c 
            || p.Engagement__r.Projected_Total_Fee__c != p.Total__c)) {
				engUpdateList.add(new Engagement__c(Id = p.Engagement__c, 
					Current_Revenue_Projection__c = p.Id,
					Projected_Monthly_Fee__c = IfNull(p.Projected_Monthly_Fee__c, 0), 
                    Projected_Transaction_Fee__c = IfNull(p.Projected_Transaction_Fee__c, 0),
                    Projected_Total_Fee__c = IfNull(p.Projected_Monthly_Fee__c, 0) + IfNull(p.Projected_Transaction_Fee__c, 0)
                ));
			}
        }

    	if(engUpdateList.size() > 0){
            //Block the Engagement Trigger from Firing
            SL_Statics.bypassEngagementTrigger = true;
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = true;

            //Perform Updates
    		update engUpdateList;

            //Unblock Engagement Trigger from Firing
            SL_Statics.bypassEngagementTrigger = false;
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = false;
        }
	}

	public void deleteEngagementCurrentRevenueProjection(List<Revenue_Projection__c> newRevenueProjectionList) {
		integer year = System.Today().year();
        integer month = System.Today().month();
		List<Engagement__c> engUpdateList = new List<Engagement__c>();

        for(Revenue_Projection__c p: newRevenueProjectionList) {
            if (Integer.valueof(p.Month__c.trim()) == month && Integer.valueof(p.Year__c.trim()) == year) {
				engUpdateList.add(new Engagement__c(Id = p.Engagement__c, 
					Current_Revenue_Projection__c = null,
					Projected_Monthly_Fee__c = null, 
                    Projected_Transaction_Fee__c = null,
                    Projected_Total_Fee__c = null
                ));
			}
        }

    	if(engUpdateList.size() > 0){
            //Block the Engagement Trigger from Firing
            SL_Statics.bypassEngagementTrigger = true;
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = true;

            //Perform Updates
    		update engUpdateList;

            //Unblock Engagement Trigger from Firing
            SL_Statics.bypassEngagementTrigger = false;
            HL_TriggerContextUtility.ByPassOnMonthlyRevenueProcess = false;
        }
	}

    private decimal IfNull(decimal s1,decimal s2) {
        decimal result = s1;
        if (s1 == null) { result = s2; }
        return result;
    }
}