public class HL_EIT {
    //Returns True for Deal Team Members and Their Delegates
    public static Boolean IsActiveOnTeam(Id engagementId, Id userId){
        Set<Id> supervisors = new Set<Id>();
        for(Delegate_Public_Group__c dpg : HL_DelegatePublicGroup.GetSupervisors())
            supervisors.add(dpg.Banker__c);
        //Add Current User to Make Query Easier
        supervisors.add(userId);
        
        return ([SELECT Id FROM Engagement_Internal_Team__c WHERE Engagement__c =: engagementId AND Contact__r.User__c In: supervisors AND End_Date__c = null]).size() > 0;
    }
}