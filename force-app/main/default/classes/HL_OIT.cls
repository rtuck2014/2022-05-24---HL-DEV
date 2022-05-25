public class HL_OIT {
    private static Map<String, Boolean> activeOnTeamMap;

    static {
        activeOnTeamMap = new Map<String, Boolean>();
    }

    //Returns True for Deal Team Members and Their Delegates
    public static Boolean IsActiveOnTeam(Id oppId, Id userId){
        String key = oppId + '~' + userId;

        Boolean result = activeOnTeamMap.get(key);

        if (result != null) {
            return result;
        }

        Set<Id> supervisors = new Set<Id>();
        
        for (Delegate_Public_Group__c dpg : HL_DelegatePublicGroup.GetSupervisors()) {
            supervisors.add(dpg.Banker__c);
        }

        //Add Current User to Make Query Easier
        supervisors.add(userId); 
        result = ([SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: oppId AND Contact__r.User__c IN: supervisors AND End_Date__c = null]).size() > 0;

        activeOnTeamMap.put(key, result);

        return result;
    }
}