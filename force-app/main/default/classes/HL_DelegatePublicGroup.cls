public class HL_DelegatePublicGroup {
    private static List<Delegate_Public_Group__c> supervisors;

    static {
        supervisors = new List<Delegate_Public_Group__c>();
        
        Set<Id> dpgs = new Set<Id>();
        
        for(Delegate_Public_Group_Member__c dpg : [
            SELECT Delegate_Public_Group__c 
            FROM Delegate_Public_Group_Member__c 
            WHERE Delegate__c = :UserInfo.getUserId()]) {
            
            dpgs.add(dpg.Delegate_Public_Group__c);
        }

        if (dpgs.size() > 0) {
            supervisors = [
                SELECT Banker__c, Banker__r.Name 
                FROM Delegate_Public_Group__c 
                WHERE ID IN :dpgs 
                AND Banker__r.IsActive = true 
                ORDER BY Banker__r.Name
            ];
        }
    }

    public static Delegate_Public_Group__c GetByCurrentUser()
    {
        List<Delegate_Public_Group__c> dpgs = [SELECT Id FROM Delegate_Public_Group__c WHERE Banker__c =: UserInfo.getUserId()];
        return dpgs.size() > 0 ? dpgs[0] : new Delegate_Public_Group__c();
    }

    public static List<Delegate_Public_Group__c> GetSupervisors() {
        return supervisors;
    }

    // GM Jan 6, 2022 - this implementation causes too many SOQL queries, moved to static initialization at top of class
/*        
    public static List<Delegate_Public_Group__c> GetSupervisors(){
        List<Delegate_Public_Group__c> supervisors = new List<Delegate_Public_Group__c>();
        Set<Id> dpgs = new Set<Id>();
        for(Delegate_Public_Group_Member__c dpg : [SELECT Delegate_Public_Group__c FROM Delegate_Public_Group_Member__c WHERE Delegate__c =: UserInfo.getUserId()])
            dpgs.Add(dpg.Delegate_Public_Group__c);
        if(dpgs.size() > 0)
            supervisors = [SELECT Banker__c, Banker__r.Name FROM Delegate_Public_Group__c WHERE ID IN : dpgs AND Banker__r.IsActive =: true ORDER BY Banker__r.Name];
        return supervisors;
    }
*/    
}