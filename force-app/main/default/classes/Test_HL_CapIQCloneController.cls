@isTest
private class Test_HL_CapIQCloneController {
    static HL_CapIQCloneController con;
    static CapIQ_Company__c cap;
    static Account acc;
    
    private static void init() {
        cap = new CapIQ_Company__c();
        cap.Name = 'CapIQ Name';
        cap.Street_Address__c = 'testStreet1';
        cap.StreetAddress_2__c = 'testStreet2';
        cap.StreetAddress3__c = 'testStreet3';
        cap.StreetAddress4__c = 'testStreet4';
        cap.City__c = 'testCity';
        
        //Modified as part of State/Country Picklist
        cap.State__c = 'California';
        cap.Country__c ='United States';
        
        cap.Phone__c = 'testPhone';
        cap.Fax__c = 'testFax';
        cap.Website__c = 'testWebsite';
        cap.Business_Description__c = 'testDescription';
        cap.Ticker_Symbol__c = 'testTicker';
        insert cap;
        
        acc = SL_TestSetupUtils.CreateAccount('',1)[0];
        acc.CapIQ_Company__c = cap.Id;
        acc.name='CapIQ Name';
        insert acc;
        
        PageReference pageRef = Page.HL_CapIQClone;
        pageRef.getParameters().put('capIQId', String.valueOf(cap.Id));
        Test.setCurrentPage(pageRef);  

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        con = new HL_CapIQCloneController(sc);
        
    }
    private static testMethod void testCancel(){
        init();
        Test.startTest();
            PageReference pageRef = con.cancel();
            String capId = ApexPages.currentPage().getParameters().get('capIQId');
        Test.stopTest();
        System.assertNotEquals(null, pageRef);
        System.assertEquals(cap.Id, capId);
    }
    
    private static testMethod void testSave(){
        init();
        Test.startTest();
            PageReference pageRef = con.save();
        Test.stopTest();
        System.assertEquals(2,[SELECT count() FROM Account WHERE CapIQ_Company__c = :cap.Id]);
    }
    
    private static testMethod void testBasicFunctionality(){
        init();
        system.debug(con.newAcc.Name);
        System.assertEquals(cap.Name, con.newAcc.Name);
        System.assertEquals(cap.City__c, con.newAcc.BillingCity);
        System.assertEquals(cap.State__c, con.newAcc.BillingState);
        System.assertEquals(cap.Country__c, con.newAcc.BillingCountry);
        System.assertEquals(cap.Phone__c, con.newAcc.Phone);
        System.assertEquals(cap.Fax__c, con.newAcc.Fax);
        System.assertEquals(cap.Website__c, con.newAcc.Website);
        System.assertEquals(cap.Business_Description__c, con.newAcc.Description);
        System.assertEquals(cap.Ticker_Symbol__c, con.newAcc.TickerSymbol);
        System.assertEquals(cap.Website__c, con.newAcc.Website);
        System.assertEquals(cap.Id, con.newAcc.CapIQ_Company__c);
        System.assertEquals(1, [SELECT count() FROM Account WHERE CapIQ_Company__c = :cap.Id]);
    }
   
    private static testMethod void testRelatedAccounts(){
        init();
        Test.startTest();
        List<Account> listAccs = con.getrelatedAccounts();
        Test.stopTest();
        System.assertEquals(listAccs.size(), [SELECT count() FROM Account WHERE CapIQ_Company__c = :cap.Id]);
    }
    
    private static testMethod void testRecordTypes(){
        init();
        Test.startTest();
        List<SelectOption> testAccRTs = con.getRecordTypes();
        Test.stopTest();
        System.assertEquals(2, testAccRTs.size());
    }
}