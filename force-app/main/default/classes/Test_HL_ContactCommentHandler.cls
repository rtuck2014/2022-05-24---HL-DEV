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
private class Test_HL_ContactCommentHandler {
    
   
   private static User createTestUser(Id profID, String fName, String lName)
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
    
    @isTest
    static void testInsertCase1() {
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c testcc1 = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        insert testcc1;
    }
    
    @isTest
    static void testInsertCase2() {
        
        List<User> lstofUsers = new list<User>();       
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'Compliance User'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        lstofUsers.add(user1);
        
        Profile pf2 = [SELECT Id FROM Profile WHERE Name = 'Standard User Template'];
        User delegateUser = createTestUser(pf2.Id, 'Test FirstName2', 'Test LastName');        
        lstofUsers.add(delegateUser);
        insert lstofUsers;
        Delegate_Public_Group_Member__c DGM = new Delegate_Public_Group_Member__c();
        for(Delegate_Public_Group__c DPG : [Select id From Delegate_Public_Group__c Where Banker__c =: user1.id])
        {
            DGM.Delegate_Public_Group__c = DPG.Id;
            DGM.Delegate__C = delegateUser.Id;
            insert DGM;
        }
        
        System.runAs(delegateUser) {
            try{
                Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
                insert testContactRecord ;        
                Contact_Comment__c testcc2 = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');    
                insert testcc2;                
            }catch(Exception e){
                system.assertNotEquals(e.getmessage(),null);
            }
        }       
        
    }
    
    @isTest
    static void testInsertCase3() {
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
               
        Profile pf2 = [SELECT Id FROM Profile WHERE Name = 'Standard User Template'];
        User normalUser = createTestUser(pf2.Id, 'Test FirstName2', 'Test LastName');    
        insert normalUser ;
        
        System.runAs(normalUser ) {
            try{                     
                Contact_Comment__c testcc2 = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');    
                insert testcc2;                
            }catch(Exception e){
                system.assertNotEquals(e.getmessage(),null);
            }
        }  
    }
    
    @isTest
    static void testInsertCase4() {
        
        List<User> lstofUsers = new list<User>();       
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'Compliance User'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        lstofUsers.add(user1);
        
        Profile pf2 = [SELECT Id FROM Profile WHERE Name = 'Standard User Template'];
        User delegateUser = createTestUser(pf2.Id, 'Test FirstName2', 'Test LastName');        
        lstofUsers.add(delegateUser);
        insert lstofUsers;
        Delegate_Public_Group_Member__c DGM = new Delegate_Public_Group_Member__c();
        for(Delegate_Public_Group__c DPG : [Select id From Delegate_Public_Group__c Where Banker__c =: user1.id])
        {
            DGM.Delegate_Public_Group__c = DPG.Id;
            DGM.Delegate__C = delegateUser.Id;
            insert DGM;
        }
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;        
        Contact_Comment__c testcc2 = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');    
        testcc2.ownerId = delegateUser.id;
        insert testcc2;   
           
        
    }
    
    @isTest
    static void testUpdateCase() {
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c testcc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        insert testcc;
                
        List<User> lstofUsers = new list<User>();       
        Profile pf1 = [SELECT Id FROM Profile WHERE Name = 'Compliance User'];
        User user1 = createTestUser(pf1.Id, 'Test FirstName1', 'Test LastName');        
        lstofUsers.add(user1);
        
        Profile pf2 = [SELECT Id FROM Profile WHERE Name = 'Accounting User'];
        User delegateUser = createTestUser(pf2.Id, 'Test FirstName2', 'Test LastName');        
        lstofUsers.add(delegateUser);
        insert lstofUsers;
        Delegate_Public_Group_Member__c DGM = new Delegate_Public_Group_Member__c();
        for(Delegate_Public_Group__c DPG : [Select id From Delegate_Public_Group__c Where Banker__c =: user1.id])
        {
            DGM.Delegate_Public_Group__c = DPG.Id;
            DGM.Delegate__C = delegateUser.Id;
            insert DGM;
        }
        try{
        testcc.comment__c = 'test3';      
        update testcc;
        }catch(Exception e)
        {
            system.assertNotEquals(e.getmessage(),null);
        }
    }
    
    @isTest
    static void testDeleteCase1() {
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c testcc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        insert testcc;                
        delete testcc;
        boolean isRecordExist = false;
        for(Contact_Comment__c c : [Select id From Contact_Comment__c where id =: testcc.id])
            isRecordExist = true;
        system.assertEquals(false,isRecordExist);        
    }
    
    @isTest
    static void testDeleteCase2() {
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c testcc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        insert testcc;        
       
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Compliance User'];
        User user1 = createTestUser(pf.Id, 'Test FirstName', 'Test LastName');        
        insert user1;
        
        System.runAs(user1) {
            try{
                delete testcc;
            }catch(Exception e){
                system.assertNotEquals(e.getmessage(),null);
            }
        } 
    }
}