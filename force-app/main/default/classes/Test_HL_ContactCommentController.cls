@isTest
private class Test_HL_ContactCommentController{
    @isTest
    private static void testSaveMethod(){
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c cc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        test.startTest();      
            PageReference pageRef = Page.HL_ContactCommentNew; 
            pageRef.getParameters().put('ContactId', testContactRecord.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(cc);
            HL_ContactCommentController ClsObj= new HL_ContactCommentController(sc);
            ClsObj.SaveRecord(); 
            // To cover exception part
            ClsObj.SaveNewRecord();        
            ClsObj.CancelRecord();
        test.stopTest();
        System.assertNotEquals(ClsObj.RelatedContactId,null);
   }
   
   @isTest
    private static void testSaveNewMethod(){
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c cc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        test.startTest();      
            PageReference pageRef = Page.HL_ContactCommentNew; 
            pageRef.getParameters().put('ContactId', testContactRecord.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(cc);
            HL_ContactCommentController ClsObj= new HL_ContactCommentController(sc);
            ClsObj.SaveNewRecord(); 
            // To cover exception part            
            ClsObj.SaveRecord();        
            ClsObj.CancelRecord();
        test.stopTest();
        System.assertNotEquals(ClsObj.RelatedContactId,null);
   }
   
   @isTest
    private static void testSaveMethodWithAlternativeId(){
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        insert testContactRecord ;
        Contact_Comment__c cc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = 'Test');
        test.startTest();      
            PageReference pageRef = Page.HL_ContactCommentNew;             
            pageRef.getParameters().put('retURL', '%2Fapex%2FHL_ContactView%3Fid%3D'+testContactRecord.Id+'%26sfdc.override%3D1');    
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(cc);
            HL_ContactCommentController ClsObj= new HL_ContactCommentController(sc);
            ClsObj.SaveRecord(); 
            // To cover exception part
            ClsObj.SaveNewRecord();        
            ClsObj.CancelRecord();
        test.stopTest();
        System.assertNotEquals(ClsObj.RelatedContactId,null);
   }
   
   @isTest
    private static void testSaveMethodwithValidation(){
        Contact testContactRecord = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        test.startTest();         
            Contact_Comment__c cc = new Contact_Comment__c(Related_Contact__c = testContactRecord.Id, Comment_Type__c = 'Compliance',Comment__c = '');
        test.stopTest();
        try{
        insert testContactRecord ;
        }catch(Exception e){
          String myMsg = e.getMessage();
          //system.assert(myMsg.contains(Label.HL_NoElegible_EditDelCC));
        }
   }
}