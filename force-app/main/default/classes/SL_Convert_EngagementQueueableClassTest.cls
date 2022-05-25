@isTest
public class SL_Convert_EngagementQueueableClassTest {
    private static User createTestUser(Id profID, String fName, String lName){
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User tuser = new User(firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId
                             );
        return tuser;
    }
	@isTest
    public static void TestOpptoEngConversion(){
        List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 1);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState; 
            accList[i].EBITDA_MM__c = 18.1;
            
        }
        insert accList;
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
         User user1 = SL_Convert_EngagementQueueableClassTest.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
        list<Contact> conList = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        for(integer i = 0; i < conList.size(); i++){
            conList[i].FirstName = 'DND Test';
            conList[i].LastName = 'Test LN';
            conList[i].AccountId = accList[0].Id;            
            conList[i].User__c = user1.Id;
        }
        insert conList;
        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accList[0].Id;
        opportunity.Subject__c = accList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'CF';
        opportunity.Job_Type__c = 'Financing';
        opportunity.Primary_Office__c = 'AT';
        
        insert opportunity;
        List<Opportunity_External_Team__c> eitList = (List<Opportunity_External_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_External_Team__c', false, 1);
        for(integer i = 0; i < eitList.size(); i++){
            eitList[i].Contact__c = conList[i].Id;
            eitList[i].Opportunity__c = opportunity.Id;
            eitList[i].Role__c = 'Legal Advisor to Company/Debtor';           
        }
        insert eitList;
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        e.Client__c = client.Id;
        e.Subject__c = subject.Id;
        e.Opportunity__c = opportunity.Id;
        insert e;
        Test.startTest();
        SL_Convert_EngagementQueueableClass queueableClass = new SL_Convert_EngagementQueueableClass(opportunity.Id);
     	 System.enqueueJob(queueableClass);  
        Test.stopTest();
    }
}