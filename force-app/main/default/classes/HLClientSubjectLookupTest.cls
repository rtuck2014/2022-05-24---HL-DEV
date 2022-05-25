@isTest
public class HLClientSubjectLookupTest {
    @isTest
    public static void testMethodForlookup(){
        Test.startTest();
        HLClientSubjectLookup.lookUp('test','Opportunity__c','Name != null');
        HLClientSubjectLookup.lookUp('test','Opportunity__c','');
        HLClientSubjectLookup.lookUp('','Opportunity__c','');
        Test.stopTest();
    }
    
}