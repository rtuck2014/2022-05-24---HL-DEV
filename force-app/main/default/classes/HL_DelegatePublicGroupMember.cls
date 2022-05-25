public class HL_DelegatePublicGroupMember {
	public static List<Delegate_Public_Group_Member__c> GetByDelegatePublicGroup(Id dpgId)
    {
        return [SELECT Id, Delegate__c FROM Delegate_Public_Group_Member__c WHERE Delegate_Public_Group__c =: dpgId];
    }
}