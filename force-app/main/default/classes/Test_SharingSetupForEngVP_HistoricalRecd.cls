/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_SharingSetupForEngVP_HistoricalRecd {

    public static User createTestUser(Id profID, String fName, String lName)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
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
    
    Static List<Delegate_Public_Group__c> dpgList;
    Static User usr;   
    
    @testSetup 
    static void setup(){    
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        usr = createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
        insert usr;
         List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
        List<Contact> contactList = new List<Contact>();
        for(Contact contactRecord : HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, 1))
        {
            contactRecord.AccountId = accList[0].Id;
            contactRecord.Title = 'Title-1';
            contactRecord.Phone = '989898989';
            contactRecord.MobilePhone = '989898989';
            contactRecord.Email = 'abc@silverlinecrm.com';      
            contactRecord.AssistantName = 'TestAsst.-1';
            contactRecord.AssistantPhone = '9875487884';
            contactRecord.User__c = usr.Id;
            contactList.add(contactRecord);
        }
        insert contactList;     
        id EngRTid;
        for(RecordType RT : [Select id from RecordType Where SobjectType = 'Engagement__c' AND developername = 'Portfolio_Valuation'])
        {
            EngRTid = RT.Id; 
        }
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Client__c = accList[0].Id;
        Engagement.Subject__c = accList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        Engagement.Total_Estimated_Fee__c = 0.00;
        Engagement.RecordTypeId  = EngRTid ;
        insert Engagement;
              
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        List<Engagement_Internal_Team__c> oitObj = SL_TestSetupUtils.CreateEIT('', oppTeamRoles.size());        
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
        {
            oitObj[i].Contact__c = contactList[0].Id;
            oitObj[i].Engagement__c = Engagement.Id;
            oitObj[i].Staff_Role__c = staffRoles[i].Id;
            oitObj[i].Start_Date__c = Date.today();
        }
        Insert oitObj;
        
         dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = contactList[0].User__c;
        }
        insert dpgList;  
        
        Eng_VP__c EngVPList =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);        
        EngVPList.Name='Historical Valuation Periods';        
        EngVPList.Engagement__c=Engagement.id;
        EngVPList.Valuation_Date__c=System.Today();
        EngVPList.CurrencyIsoCode='USD';   
        EngVPList.Fee_Total__c = 10.00;            
        Insert EngVPList; 
    }
    
    @isTest static void testBatchClass() {             
             
        String QueryStr = 'Select Id, Engagement__c,OwnerId  From Eng_Vp__c Where Name = \'Historical Valuation Periods\'';
		SharingSetupForEngVP_HistoricalRecords batchClsObj = new SharingSetupForEngVP_HistoricalRecords(QueryStr);
		Database.executeBatch(batchClsObj, 1);
        
    }
    
    
}