@isTest(seeAllData=true)
public class SL_Test {
    
    public static User init() {
        User testUser;
        
        Profile systemProfile = [SELECT Id FROM Profile WHERE Name Like 'System Administrator' LIMIT 1];
        
        list<User> user1 = [SELECT Id FROM User WHERE ProfileId=:systemProfile.Id AND IsActive=true LIMIT 1];
        
        if (user1.size()>0){
            System.runAs(user1[0]){
                
                // Get Standard User Profile Id
                Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
                // Get Role Id for Field Sales //* NOTE *// (no Role assigned for now)
             // UserRole r = [SELECT Id FROM UserRole WHERE Name='Executive Sales'];
                // Create Test User
             // testUser = new User(Alias='testUser', Email='testuser@houlihan.com',
             //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
             //     LocaleSidKey='en_US', ProfileId=p.Id, UserRoleId=r.Id,
             //     TimeZoneSidKey='America/New_York', UserName='testuser@houlihan.com', IsActive=true);
                testUser = new User(Alias='testUser', Email='testuser@houlihan.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId=p.Id, 
                    TimeZoneSidKey='America/New_York', UserName='testuser@houlihan.com', IsActive=true);
                insert testUser;
                
            }
        }
        return testUser;
    }

    public static User init2() {
        User testUser;
        
        Profile systemProfile = [SELECT Id FROM Profile WHERE Name Like 'System Administrator' LIMIT 1];
        
        list<User> user1 = [SELECT Id FROM User WHERE ProfileId=:systemProfile.Id AND IsActive=true LIMIT 1];
        
        if (user1.size()>0){
            System.runAs(user1[0]){
                
                // Get Acquisitions/Editor User Profile Id
                Profile p = [SELECT Id FROM Profile WHERE Name='Pluralsight Acquisitions/Editor User'];
                // Get Role Id for Acquisitions Author Editor
                UserRole r = [SELECT Id FROM UserRole WHERE Name='Acquisitions Author Editor'];
                // Create Test User
                testUser = new User(Alias='testUser', Email='testuser@pluralsight.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId=p.Id, UserRoleId=r.Id,
                    TimeZoneSidKey='America/Denver', UserName='testuser@pluralsight.com', IsActive=true);
                insert testUser;
                
            }
        }
        return testUser;
    }

    
//----------------------------------------------
// Helper methods for creating objects
//----------------------------------------------

    public static Account newAccount(String name, Id recordtypeId) {
        return new Account(Name=name, RecordTypeId=recordTypeId);
    }
    
    public static CapIQ_Company__c newCapIQCompany(String name, String companyId) {
        return new CapIQ_Company__c (Name=name, Company_ID__c=companyId);       
    }
    
    public static Investment__c newInvestment(Id sponsorCapIQCompanyId, Id portfolioCapIQCompanyId) {
        return new Investment__c (Sponsor_CapIQ_Company__c=sponsorCapIQCompanyId, Portfolio_CapIQ_Company__c=portfolioCapIQCompanyId);
    }
    
//----------------------------------------------
// Test Methods for SL class
//----------------------------------------------

    public static TestMethod void testSLclass() {
        SL.SL_Exception testSLException;
        SL.AssertionException testAssertionException = new SL.AssertionException();
        SL.TriggerException testTriggerException = new SL.TriggerException();
        SL.ValidationException testValidationException = new SL.ValidationException();
        SL.HttpException testHttpException = new SL.HttpException();        
    }

    public class HttpMockResponse implements HttpCalloutMock {
        public String body;
        public Integer status;
         
        public HttpMockResponse(String body, Integer status) {
            this.body = body;
            this.status = status;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse result = new HttpResponse();
            result.setBody(body);
            result.setStatusCode(status);
            return result;
        }
    }
    
    // SL class (utilities)
    static testMethod void testGetPageParam() {
        init();
        System.assertEquals('y', SL.getStringPageParam('x', 'y'));
          
        Test.setCurrentPage(SL.redirect(Page.SL_Test, 'x', 'hi'));
        System.assertEquals('hi', SL.getStringPageParam('x'));
  
        Test.setCurrentPage(SL.redirect(Page.SL_Test, 'x', '7'));
        System.assertEquals('7', SL.getStringPageParam('x'));
        
        Test.setCurrentPage(SL.redirect('SL_Test', 'x', '7', 'y', '8'));
        System.assertEquals('7', SL.getStringPageParam('x'));
        System.assertEquals('8', SL.getStringPageParam('y'));
    }
    
    static testMethod void testFormat() {
        init();
        System.assertEquals('hi there', SL.format('hi {0}', 'there'));
        System.assertEquals('hi 0', SL.format('hi {0}', 0));
        System.assertEquals('hi 0.19', SL.format('hi {0}', 0.19));
        System.assertEquals('hi (1, 2, 3)', SL.format('hi {0}', new List<Integer> {1, 2, 3}));
        System.assertEquals('hi y\'all', SL.format('hi {0}', 'y\'all'));
        System.assertEquals('10 there', SL.format('{1} {0}', 'there', 10));
        System.assertEquals('bye y\'all', SL.format('{1} {0}', 'y\'all', 'bye'));
        System.assertEquals('H 8 er!', SL.format('{0} {1} {2}', 'H', 8, 'er!'));
    }

    static testMethod void testGetPickListAsSelectedOptions() {
        init();
        Test.startTest();
            System.assertEquals(true, SL.getPickListAsSelectOptions(Account.Id).IsEmpty());
            System.assertEquals(false, SL.getPickListAsSelectOptions(Account.Type).IsEmpty());
        Test.stopTest();
    }

    static testMethod void testNullOrEmpty() {
        init();
        System.assertEquals(true, SL.nullOrEmpty((String)null));
        System.assertEquals(true, SL.nullOrEmpty((Integer)null));
        System.assertEquals(true, SL.nullOrEmpty(''));
        System.assertEquals(true, SL.nullOrEmpty(' '));
        System.assertEquals(true, SL.nullOrEmpty('\t  \n\r'));
        System.assertEquals(true, SL.nullOrEmpty((List<String>)null));
        System.assertEquals(true, SL.nullOrEmpty(new String[] {}));
        System.assertEquals(true, SL.nullOrEmpty((Set<String>)null));
        System.assertEquals(true, SL.nullOrEmpty((Map<String,String>)null));
        
        System.assertEquals(false, SL.nullOrEmpty(new Set<String> {}));
        System.assertEquals(false, SL.nullOrEmpty(new Map<String,String> {}));

        System.assertEquals(true, !SL.nullOrEmpty('hi'));
        System.assertEquals(true, !SL.nullOrEmpty(new String[] {'hi'}));
        System.assertEquals(true, !SL.nullOrEmpty(new Set<String> {'hi'}));
        System.assertEquals(true, !SL.nullOrEmpty(new Map<String,String> {'hi'=>'hi'}));
    }
    
    static testMethod void testRedirect() {
        init();
        Test.startTest();
            System.assertEquals(null, SL.redirect((String)null));
            System.assertEquals(null, SL.redirect((String)null, null, null));
            
            String result = SL.redirect(Page.SL_Test).getUrl().toLowerCase();
            System.assert(result.contains(Page.SL_Test.getUrl()));
    
            result = SL.redirect('SL_Test').getUrl().toLowerCase();
            System.assert(result.contains(Page.SL_Test.getUrl()));
            
            result = SL.redirect(Page.SL_Test, 'Key', 'Value').getUrl().toLowerCase();
            System.assert(result.contains(Page.SL_Test.getUrl()));
            System.assert(result.contains('key=value'));
            
            result = SL.redirect('SL_Test', 'Key', 'Value').getUrl().toLowerCase();
            System.assert(result.contains(Page.SL_Test.getUrl()));
            System.assert(result.contains('key=value'));
        Test.stopTest();
    }
    
    static testMethod void testHttpGet() {
        init();
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpMockResponse('test', 200));
            System.assertEquals('test', SL.httpGet('junk', 'user', 'pwd', null, 
                new Map<String,String> { 'key' => 'value' }));
            
            Test.setMock(HttpCalloutMock.class, new HttpMockResponse('test', 300));
            try {
                SL.httpGet('junk', 'user', 'pwd', '[{duSLy:junk}]', null);
                System.assert(false, 'HTTP should have thrown');
            } catch (SL.HttpException e) {
            }

            Test.setMock(HttpCalloutMock.class, new HttpMockResponse('test', 400));
            try {
                SL.httpGet('junk', 'user', 'pwd', null, null);
                System.assert(false, 'HTTP should have thrown');
            } catch (SL.HttpException e) {
            }
        Test.stopTest();
    }
    
    static testMethod void testCustomExceptions() {
        init();
        Test.startTest();
            SL.AssertionException a = new SL.AssertionException();
            SL.TriggerException t = new SL.TriggerException();
            SL.HttpException h = new SL.HttpException(99, 'test');
            System.assertEquals(99, h.code);
        Test.stopTest();
    }
    
    static testMethod void testDiagnostics() {
        init();
        Test.startTest();
            Boolean d = SL.debugging;
            
            SL.error('message');
            SL.warn('message');
            SL.info('message');
            SL.debug('message');
            
            try { SL.assert(false); System.assert(false); } catch (SL.AssertionException e) {}
            try { SL.assert(false, 'message'); System.assert(false); } catch (SL.AssertionException e) {}
            try { SL.assertEquals(0, 1); System.assert(false); } catch (SL.AssertionException e) {}
            try { SL.assertEquals(0, 1, 'message'); System.assert(false); } catch (SL.AssertionException e) {}
            try { SL.assertNotEquals(0, 0); System.assert(false); } catch (SL.AssertionException e) {}
            try { SL.assertNotEquals(0, 0, 'message'); System.assert(false); } catch (SL.AssertionException e) {}
        Test.stopTest();
    }
    
    static testMethod void testaddBusinessdays() {
        init();
        Test.startTest();
            Date d = Date.newInstance(2013, 1, 14);                     // Monday
            System.assertEquals(d, SL.addBusinessdays(d, 0));           // Monday
            System.assertEquals(d + 1, SL.addBusinessdays(d, 1));       // Tuesday
            System.assertEquals(d - 3, SL.addBusinessdays(d, -1));  // Friday
            
            d = Date.newInstance(2013, 1, 17); // Thursday
            System.assertEquals(d, SL.addBusinessdays(d, 0));           // Thursday
            System.assertEquals(d + 1, SL.addBusinessdays(d, 1));       // Friday
            System.assertEquals(d - 1, SL.addBusinessdays(d, -1));  // Wednesday
            System.assertEquals(d - 3, SL.addBusinessdays(d, -3));  // Monday
            System.assertEquals(d - 6, SL.addBusinessdays(d, -4));  // Friday
            System.assertEquals(d - 7, SL.addBusinessdays(d, -5));  // Thursday
            System.assertEquals(d - 14, SL.addBusinessdays(d, -10));    // Thursday
            System.assertEquals(d + 4, SL.addBusinessdays(d, 2));       // Monday
            System.assertEquals(d + 8, SL.addBusinessdays(d, 6));       // Friday
            System.assertEquals(d + 11, SL.addBusinessdays(d, 7));  // Monday
            
            d = Date.newInstance(2013, 1, 18);                          // Friday
            System.assertEquals(d, SL.addBusinessdays(d, 0));           // Friday
            System.assertEquals(d + 3, SL.addBusinessdays(d, 1));       // Monday
            System.assertEquals(d - 1, SL.addBusinessdays(d, -1));  // Thursday
            
            d = Date.newInstance(2013, 1, 19);                          // Saturday
            System.assertEquals(d + 2, SL.addBusinessdays(d, 0));       // Monday
            System.assertEquals(d + 3, SL.addBusinessdays(d, 1));       // Tuesday
            System.assertEquals(d - 1, SL.addBusinessdays(d, -1));  // Friday
            
            d = Date.newInstance(2013, 1, 20);                          // Sunday
            System.assertEquals(d + 1, SL.addBusinessdays(d, 0));       // Monday
            System.assertEquals(d + 2, SL.addBusinessdays(d, 1));       // Tuesday
            System.assertEquals(d - 2, SL.addBusinessdays(d, -1));  // Friday
            
            // with EOD before the current time
            Time eod = Time.newInstance(15, 0, 0, 0);
            DateTime dt = DateTime.newInstance(2013, 1, 18, 16, 0, 0);          // Friday
            System.assertEquals(dt.date() + 3, SL.addBusinessdays(dt, 0, eod)); // Monday
            System.assertEquals(dt.date() + 4, SL.addBusinessdays(dt, 1, eod)); // Tuesday
            System.assertEquals(dt.date(), SL.addBusinessdays(dt, -1, eod));        // Friday
            
            // with EOD after the current time
            eod = Time.newInstance(16, 0, 0, 1);
            dt = DateTime.newInstance(2013, 1, 18, 16, 0, 0);                       // Friday
            System.assertEquals(dt.date(), SL.addBusinessdays(dt, 0, eod));     // Friday
            System.assertEquals(dt.date() + 3, SL.addBusinessdays(dt, 1, eod)); // Monday
            System.assertEquals(dt.date() - 1, SL.addBusinessdays(dt, -1, eod));    // Thursday
        Test.stopTest();
    }
    
    static testMethod void testGetFieldValues() {
        init();
        // Create Account
        Id recTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Capital_Provider'].Id;
        Account[] accounts = new Account[] {
            SL_Test.newAccount('Test Account', recTypeId)
        };
        insert accounts;
        Test.startTest();
            final Set<String> idFields = SL.getFieldValues(accounts, 'Id');
            System.assertEquals(accounts.size(), idFields.size());
            
            final Set<String> names = SL.getFieldValues(accounts, 'Name');
            for (account a : accounts) {
                System.assert(names.contains(a.Name));
            }
        Test.stopTest();
    }
    
}