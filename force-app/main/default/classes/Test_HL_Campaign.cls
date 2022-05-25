@isTest
public class Test_HL_Campaign {

static testmethod void HL_Campaign(){

Campaign obj= new Campaign();
obj.name='test_Event_1';
//obj.RecordType.name='Conference / Event';
obj.Type='Webniar';
obj.Message_Type__c='Update';
obj.Event_Location__c='India';
obj.Target_Audience__c='India';
obj.Project_Manager__c='PM';
//obj.Parent.name='Parent_test';
obj.Marketing_Channel__c='Email';
obj.Lines_of_Business__c='CF';
obj.Industry_Groups__c='None';
obj.HL_Sub_Group__c='CM';
//obj.Seed_1__c='Harsh Singh';
insert obj;
HL_Campaign.GetById(obj.Id);
}
}