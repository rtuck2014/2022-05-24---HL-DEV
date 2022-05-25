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
private class SL_Test_SObjectDataLoader {

@IsTest(seeAllData=true) // http://stackoverflow.com/questions/9164986/how-do-i-avoid-standard-price-not-defined-when-unit-testing-an-opportunitylineit 
    public static void testManuallyConfigured()
    {               
        // Save point to rollback test data
        /*System.Savepoint savePoint = Database.setSavepoint();
        
        // Serialise test data into JSON record set bundle via manual configuration
        String serializedData = SL_SObjectDataLoader.serialize(createOpportunities(), 
            new SL_SObjectDataLoader.SerializeConfig().
                followChild(OpportunityLineItem.OpportunityId).     // Serialize any related OpportunityLineItem's (children)
                    follow(OpportunityLineItem.PricebookEntryId).   // Serialize any related PricebookEntry's
                        follow(PricebookEntry.Product2Id).          // Serialize any related Products's
                        omit(OpportunityLineItem.UnitPrice));       // Do not serialize the UnitPrice, as TotalPrice is enough and both cannot exist together
                    
        // Rollback test data
        Database.rollback(savePoint);
        
        // Recreate test data via deserialize
        Set<ID> resultIds = SL_SObjectDataLoader.deserialize(serializedData, new ApplyStandardPricebook());
        //assertResults(resultIds);*/
    }
    
    @IsTest(seeAllData=true) // http://stackoverflow.com/questions/9164986/how-do-i-avoid-standard-price-not-defined-when-unit-testing-an-opportunitylineit
    public static void testAutoConfigured()
    {
        // Save point to rollback test data
       /* System.Savepoint savePoint = Database.setSavepoint();
        
        // Serialise test data into JSON record set bundle via auto configuraiton (with some manual tweaks)
        String serializedData = SL_SObjectDataLoader.serialize(createOpportunities(),
            new SL_SObjectDataLoader.SerializeConfig().
                auto(Opportunity.sObjectType).          // Automatically determine child and related object references needed (calls follow methods)
                omit(OpportunityLineItem.UnitPrice).    // Do not serialize the UnitPrice, as TotalPrice is enough and both cannot exist together
                omit(PricebookEntry.Pricebook2Id).      // Do not serialize any Pricebook references (these will be reassoicated apone deserialization)
                omit(Opportunity.Pricebook2Id));        // Do not serialize any Pricebook references (these will be reassoicated apone deserialization)

        // Rollback test data
        Database.rollback(savePoint);
        
        // Recreate test data via deserialize
        Set<ID> resultIds = SL_SObjectDataLoader.deserialize(serializedData, new ApplyStandardPricebook());
        assertResults(resultIds);    */           
    }
    
    /**
     * Test implemetnation of IDeserializeCallback, automatically applies Standard Pricebook to new PricebookEntry's
     **/
    private class ApplyStandardPricebook implements SL_SObjectDataLoader.IDeserializeCallback
    {
        private Pricebook2 standardPricebook;
        
        public ApplyStandardPricebook()
        {
            standardPricebook = [select Id from Pricebook2 where IsStandard = true];                
        }
        
        public void unresolvedReferences(Schema.SObjectType sObjectType, List<SL_SObjectDataLoader.UnresolvedReferences> unresolvedReferences)
        {
            if(sObjectType == PricebookEntry.sObjectType) // PricebookEntry object?
                for(SL_SObjectDataLoader.UnresolvedReferences unresolvedReference : unresolvedReferences)
                    if(unresolvedReference.References.contains(PricebookEntry.Pricebook2Id)) // Pricebook2Id field?
                        unresolvedReference.Record.put(PricebookEntry.Pricebook2Id, standardPricebook.id); // Set Standard Pricebook
        }       
    }
    
    private static Set<ID> createOpportunities()
    {
        // Grab the Standard Pricebook (cannot create these via Apex)
        Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true];    
                
        // Insert Opportunities
        List<Opportunity> opps = new List<Opportunity>();
        List<List<Product2>> productsByOpp = new List<List<Product2>>();        
        List<List<PricebookEntry>> pricebookEntriesByOpp = new List<List<PricebookEntry>>();        
        List<List<OpportunityLineItem>> oppLinesByOpp = new List<List<OpportunityLineItem>>();      
        for(Integer o=0; o<10; o++)
        {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Name ' + o;
            opp.StageName = 'Open';
            opp.CloseDate = System.today();
            opps.add(opp);
            List<Product2> products = new List<Product2>();
            List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for(Integer i=0; i<o+1; i++)
            {                       
                Product2 product = new Product2();
                product.Name = opp.Name + ' : Product : ' + i;
                products.add(product);
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = 10;
                pbe.IsActive = true;
                pbe.UseStandardPrice = false;
                pbe.Pricebook2Id = pb.Id;
                pricebookEntries.add(pbe);
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.Quantity = 1;
                oppLineItem.TotalPrice = 10;
                oppLineItems.add(oppLineItem);
            }
            productsByOpp.add(products);
            pricebookEntriesByOpp.add(pricebookEntries);
            oppLinesByOpp.add(oppLineItems);                
        }
        // Insert Opportunities
        insert opps;
        // Insert Products
        List<Product2> allProducts = new List<Product2>(); 
        for(List<Product2> products : productsByOpp)
        {
            allProducts.addAll(products);           
        }
        insert allProducts;
        // Insert Pricebooks
        Integer oppIdx = 0;         
        List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();              
        for(List<PricebookEntry> pricebookEntries : pricebookEntriesByOpp)
        {
            List<Product2> products = productsByOpp[oppIdx++];
            Integer lineIdx = 0;
            for(PricebookEntry pricebookEntry : pricebookEntries)
            {
                pricebookEntry.Product2Id = products[lineIdx++].Id;
            }
            allPricebookEntries.addAll(pricebookEntries);
        }           
        insert allPricebookEntries;
        // Insert Opportunity Lines
        oppIdx = 0;                     
        List<OpportunityLineItem> allOppLineItems = new List<OpportunityLineItem>();            
        for(List<OpportunityLineItem> oppLines : oppLinesByOpp)
        {
            List<PricebookEntry> pricebookEntries = pricebookEntriesByOpp[oppIdx];
            Integer lineIdx = 0;
            for(OpportunityLineItem oppLine : oppLines)
            {
                oppLine.OpportunityId = opps[oppIdx].Id;
                oppLine.PricebookEntryId = pricebookEntries[lineIdx++].Id;
            }
            allOppLineItems.addAll(oppLines);
            oppIdx++;
        }           
        insert allOppLineItems;     
        return new Map<Id, Opportunity>(opps).keySet();         
    }
    
    private static void assertResults(Set<ID> opportunityIds)
    {
        Pricebook2 standardPriceBook = [select Id from Pricebook2 where IsStandard = true];
        List<Opportunity> opportunities = 
            [select Id, Name, Amount, 
                (select id, PricebookEntry.Product2.Name, PricebookEntry.Pricebook2Id, UnitPrice 
                 from OpportunityLineItems 
                 order by PricebookEntry.Product2.Name) 
                from Opportunity 
                where Id in :opportunityIds 
                order by Name];
        System.assertEquals(10, opportunities.size());
        System.assertEquals('Test Name 0', opportunities[0].Name);
        System.assertEquals(10, opportunities[0].Amount);
        System.assertEquals('Test Name 9', opportunities[9].Name);
        System.assertEquals(100, opportunities[9].Amount);      
        System.assertEquals(1, opportunities[0].OpportunityLineItems.size());
        System.assertEquals(10, opportunities[0].OpportunityLineItems[0].UnitPrice);
        System.assertEquals('Test Name 0 : Product : 0', opportunities[0].OpportunityLineItems[0].PricebookEntry.Product2.Name);
        System.assertEquals(standardPriceBook.Id, opportunities[0].OpportunityLineItems[0].PricebookEntry.Pricebook2Id);
        System.assertEquals(10, opportunities[9].OpportunityLineItems.size());
        System.assertEquals(10, opportunities[9].OpportunityLineItems[0].UnitPrice);
        System.assertEquals('Test Name 9 : Product : 9', opportunities[9].OpportunityLineItems[9].PricebookEntry.Product2.Name);
        System.assertEquals(standardPriceBook.Id, opportunities[9].OpportunityLineItems[9].PricebookEntry.Pricebook2Id);        
    }

    /**
        --Without Whitelisting RecordTypeId, the autoconfig serialize/deserialize
            will try to insert a new RecordType object which throws:
            'System.TypeException: DML not allowed on RecordType'

        --Test uses dynamic binding to prevent compile-time errors in orgs without RecordTypes enabled
        --Currently, the test method only tests the logic if there are 2+ RecordTypes on the Account object
            otherwise, the if statement will silently ignore the rest of the testMethod.
    **/

    @isTest(seeAllData=False)
    private static void shouldNotTryToInsertRecordType(){
        List<RecordType> accountRecordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND isActive = TRUE];
        //Only run this test if there are multiple active recordtypes on Account object
        if (accountRecordTypes.size() > 0){
            List<sObject> testAccounts = new List<Account>();
            for (RecordType aRT : accountRecordTypes){
                sObject testAccount = new Account(Name = 'Test' + aRT.DeveloperName);
                
                //dynamic binding will prevent any compile time errors if RecordTypeId field doesn't exist
                testAccount.put('RecordTypeId', aRT.Id);
                testAccounts.add(testAccount);
            }
            insert testAccounts;
            Set<Id> newAccountIds = new Set<Id>();
            for (sObject myAccount : testAccounts){
                newAccountIds.add(myAccount.Id);
            }
            String serializedData = SL_SObjectDataLoader.serialize(newAccountIds);
            Set<Id> resultIds = SL_SObjectDataLoader.deserialize(serializedData);
            
            //dynamic soql will prevent any compile time errors if RecordTypeId field doesn't exist
            String accountsQuery = 'SELECT Id, RecordTypeId FROM Account WHERE Id IN :newAccountIds';
            testAccounts = Database.query(accountsQuery);
            Set<Id> recordTypeIdsOfNewAccounts = new Set<Id>();

            for (sObject myAccount : testAccounts){
                recordTypeIdsOfNewAccounts.add((Id) myAccount.get('RecordTypeId'));
            }
            system.assertEquals(recordTypeIdsOfNewAccounts.size(), accountRecordTypes.size());
        }
    }

@isTest(seeAllData=False)
    private static void deserializingObjectsWithSelfRefernces(){
        Account testParentAccount = new Account(Name = 'ParentAccount');
        insert testParentAccount;
        Account childAccount = new Account();
        childAccount.ParentId =testParentAccount.Id;
        childAccount.Name = 'ChildAccount'; 
        insert childAccount;
        Set<Id> childAccountIds = new Set<Id>();
        childAccountIds.add(childAccount.Id);
        String serializedData = SL_SObjectDataLoader.serialize(childAccountIds);
        Integer recordsBeforeDeletion = [Select count() from Account];
        List<Account> recordsToDelete =  new List<Account>();
        recordsToDelete.add(testParentAccount);
        recordsToDelete.add(childAccount);
        delete recordsToDelete;
        Integer recordsAfterDeletion = [Select count() from Account];
        system.assertEquals(recordsBeforeDeletion,recordsAfterDeletion+2);
        Set<Id> resultIds = SL_SObjectDataLoader.deserialize(serializedData);
        List<Account> recordsAfterDeserialization =[Select Id,Name,ParentId from Account];
        system.assertEquals(recordsBeforeDeletion,recordsAfterDeserialization.size());
        Id parentRecordId;
        for(Account acc : recordsAfterDeserialization){
            if('childAccount'.equals(acc.Name)){
                parentRecordId = acc.ParentId;
                break;
            }
        }
        for(Account acc : recordsAfterDeserialization){
            if(parentRecordId!=null && acc.id ==parentRecordId){
                system.assertEquals(acc.Name,'ParentAccount');
                break;
            }
        }
    }
    
    @isTest(seeAllData=False)
    private static void deserializingObjectsWithSelfReferncesLevel2(){
        //add a ParentAccount
        Account testParentAccount = new Account(Name = 'ParentAccount');
        insert testParentAccount;
        
        //add a child to ParentAccount
        Account childAccount1 = new Account();
        childAccount1.ParentId =testParentAccount.Id;
        childAccount1.Name = 'ChildAccount1';   
        insert childAccount1;
        
        //add a child to childAccount1
        Account childAccount2 = new Account();
        childAccount2.ParentId =childAccount1.Id;
        childAccount2.Name = 'ChildAccount2';   
        insert childAccount2;

        //Create Bundle with childAccount2 as subcomponent
        Set<Id> childAccountIds = new Set<Id>();
        childAccountIds.add(childAccount2.Id);
        //Records are exported
        String serializedData = SL_SObjectDataLoader.serialize(childAccountIds);
        
        Integer recordsBeforeDeletion = [Select count() from Account];
        List<Account> recordsToDelete =  new List<Account>();
        recordsToDelete.add(testParentAccount);
        recordsToDelete.add(childAccount1);
        recordsToDelete.add(childAccount2); 
        //delete recordsToDelete;
        
        Integer recordsAfterDeletion = [Select count() from Account];
        //system.assertEquals(recordsBeforeDeletion,recordsAfterDeletion+3);
        
        //Importing Records
        Set<Id> resultIds = SL_SObjectDataLoader.deserialize(serializedData);
        List<Account> recordsAfterDeserialization =[Select Id,Name,ParentId from Account];
        //system.assertEquals(recordsBeforeDeletion,recordsAfterDeserialization.size());
        //Verify Parent child Relationship is maintained between Account Objects
        Account parentAcc = [select Id,Name from Account where Name like 'ParentAccount' LIMIT 1];
        Account Child1Acc = [select Id,Name from Account where ParentId = :parentAcc.Id LIMIT 1];
        Account Child2Acc = [select Id,Name from Account where ParentId = :Child1Acc.Id LIMIT 1];
        //Account acc =[select a2.Id,a2.Name from Account a2 where a2.ParentId in (select a1.Id from Account a1 where a1.ParentId in (select a.Id from Account where a.Name like 'ParentAccount' ))];
        //system.assertEquals(Child2Acc.Name,'ChildAccount2');
    }
    
    @isTest(seeAllData=False)
    private static void deserializingObjectsWithoutSelfRefernces(){
        List<Account> AccountList = new List<Account>();
        Account testAccount1 =  new Account(Name ='TestAccount1');
        Account testAccount2 =  new Account(Name ='TestAccount1');
        Account testAccount3 =  new Account(Name ='TestAccount1');
        
        AccountList.add(testAccount1);
        AccountList.add(testAccount2);
        AccountList.add(testAccount3);
        insert AccountList;
        
        //Create Bundle with Account Objects as subcomponent
        Set<Id> AccountIds = new Set<Id>();
        AccountIds.add(testAccount1.Id);
        AccountIds.add(testAccount2.Id);
        AccountIds.add(testAccount3.Id);
        //Records are exported
        String serializedData = SL_SObjectDataLoader.serialize(AccountIds);
        
        Integer recordsBeforeDeletion = [Select count() from Account];
        List<Account> recordsToDelete =  new List<Account>();
        recordsToDelete.add(testAccount1);
        recordsToDelete.add(testAccount2);
        recordsToDelete.add(testAccount3);
        delete recordsToDelete;
        
        Integer recordsAfterDeletion = [Select count() from Account];
        system.assertEquals(recordsBeforeDeletion,recordsAfterDeletion+3);
        
        //Importing Records
        Set<Id> resultIds = SL_SObjectDataLoader.deserialize(serializedData);
        List<Account> recordsAfterDeserialization =[select a.ParentId, a.Id from Account a where a.ParentId  =null];
        //system.assertEquals(recordsBeforeDeletion,recordsAfterDeserialization.size());
    }   
    
     @isTest(seeAllData=False)
    private static void serializeIdWithDifferentSObjectTypes(){
        Account testAccount =  new Account(Name ='TestAccount');
        Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'TestOpportunity' ;
            testOpportunity.StageName = 'Open';
            testOpportunity.CloseDate = System.today();
        
        insert testAccount;
        insert testOpportunity;
        
        //Create Bundle with Account and Lead Objects as subcomponent
        Set<Id> objectIds = new Set<Id>();
        objectIds.add(testAccount.Id);
        objectIds.add(testOpportunity.Id);
        
        //Records are exported
        String serializedData = SL_SObjectDataLoader.serialize(objectIds);
        
        delete testAccount;
        delete testOpportunity;
        
        Integer accountRecordsAfterDeletion = [Select count() from Account where Name like 'TestAccount'];
        system.assertEquals(accountRecordsAfterDeletion,0);
        Integer opportunityRecordsAfterDeletion = [Select count() from Opportunity where Name like 'TestOpportunity'];
        system.assertEquals(opportunityRecordsAfterDeletion,0);
        
        //Importing Records
        Set<Id> resultIds = SL_SObjectDataLoader.deserialize(serializedData);
         Integer accountRecordsAfterImport = [Select count() from Account where Name like 'TestAccount'];
        //system.assertEquals(accountRecordsAfterImport,1);
        Integer opportunityRecordsAfterImport = [Select count() from Opportunity where Name like 'TestOpportunity'];
        //system.assertEquals(opportunityRecordsAfterImport,1);
    }  
    
     /*
    * Donot save an record subcomponent if error occurs
    */
     @isTest(seeAllData=False)
     private static void processUnorderedRecordsinJsonTest()
    {
        String testObjectJson = '{"RecordSetBundles":[{"Records":[{"attributes":{"type":"Contact","url":"/services/data/v29.0/sobjects/Contact/003b000000NStFRAA1"},'+
        '"IsEmailBounced":false,"HasOptedOutOfFax":false,"LastModifiedDate":"2014-03-01T12:32:28.000+0000","HasOptedOutOfEmail":false,'+
        '"FirstName":"Test","LastName":"MyContact","Name":"Test MyContact","DoNotCall":false,"AccountId":"001b000000P8LZgAAN","SystemModstamp":"2014-03-01T12:32:28.000+0000","CreatedDate":"2014-03-01T12:11:58.000+0000",'+
        '"IsDeleted":false,"Id":"003b000000NStFRAA1"}],"ObjectType":"Contact"},{"Records":[{"attributes":{"type":"Account","url":"/services/data/v29.0/sobjects/Account/001b000000P8LZgAAN"},'+
        '"Name":"ChildAccount","ParentId":"001b000000PBLqsAAH","SystemModstamp":"2014-03-06T06:04:38.000+0000","CreatedDate":"2014-03-01T11:42:34.000+0000",'+
        '"LastModifiedDate":"2014-03-06T06:04:38.000+0000","IsDeleted":false,"Id":"001b000000P8LZgAAN"},{"attributes":{"type":"Account","url":"/services/data/v29.0/sobjects/Account/001b000000PBLqsAAH"},'+
        '"Name":"Parent Account","SystemModstamp":"2014-03-06T06:04:15.000+0000","CreatedDate":"2014-03-06T06:04:15.000+0000","LastModifiedDate":"2014-03-06T06:04:15.000+0000",'+
        '"IsDeleted":false,"Id":"001b000000PBLqsAAH"}],"ObjectType":"Account"}]}' ;
        
        delete [Select Id from Account where Name = 'ChildAccount']; 
        delete [Select Id from Account where Name = 'Parent Account']; 
        delete [Select Id from Contact where Name = 'MyContact'];

        //Importing Records
        Set<Id> resultIds = SL_SObjectDataLoader.deserialize(testObjectJson);
        List<Account> childAccountRecords = [select Id , ParentId from Account where Name like 'ChildAccount'];
        List<Account> parentAccountRecords = [select Id from Account where Name like 'Parent Account'];
        List<Contact> contactRecords = [select Id , AccountId from Contact where Name like 'Test MyContact'];
        
        system.assertEquals(childAccountRecords.size(), 1);
        system.assertEquals(parentAccountRecords.size(), 1);
        system.assertEquals(contactRecords.size(), 1);
        system.assertEquals(parentAccountRecords[0].Id, childAccountRecords[0].ParentId);
        system.assertEquals(childAccountRecords[0].Id,contactRecords[0].AccountId);
    }
    
    @isTest(seeAllData=False)
     private static void reportLimitExceptions()
    {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Account accountObj = new Account(Name ='Account1');
        insert accountObj;
        List<Account> accList =[select Id from Account];
        for(Integer i=0;i<100;i++)
        {
            Schema.DescribeSObjectResult sObjectDesc = accList[0].Id.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> sObjectFields = sObjectDesc.fields.getMap();
        }
        String error ='';
        Set<Id> IdToSerialize = new Set<ID>();
        IdToSerialize.add(accountObj.Id);
        try
        {
            String serializedData = SL_SObjectDataLoader.serialize(IdToSerialize);
        }
        catch(Exception e)
        {
            error = e.getMessage();
        }
        //system.assert(error.contains('Too many fields describes: 101'));
    }
  
}