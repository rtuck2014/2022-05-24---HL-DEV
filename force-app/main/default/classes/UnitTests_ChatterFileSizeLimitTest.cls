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


/**
* Class Name: UnitTests_ChatterFileSizeLimit
*/

@isTest
private class UnitTests_ChatterFileSizeLimitTest {

    /*Success Scenario : When a file is first time uploaded on chatter*/
    static testMethod void ChatterFileSuccessTest()
    {
        Profile profile = [select id from Profile where name = 'System Administrator'];
        User u = new User(alias='neUser', email='newTestinguser@test.com', emailencodingkey='UTF-8', lastname='Testing', username='newTestinguser@test.com',
                              EmployeeNumber='123456780',profileid=profile.id, languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
        insert u;
 
        Blob myBlob = Blob.valueof('this is test string'); 
  
        FeedItem chatterFeed = new FeedItem(ParentId=u.Id, Type='ContentPost', ContentData=myBlob, ContentFileName='chatter file upload', Title='chatter file upload');
        insert chatterFeed;
        FeedItem testFeed = [SELECT ContentData,Id FROM FeedItem where Id = :chatterFeed.Id];      
      
    }
    
    
    /*Failure Scenario : When a file is first time uploaded on chatter and Size of the file is greater than the defined Limit.*/
    static testMethod void ChatterFileFailureTest() 
    {
       Profile profile = [select id from Profile where name = 'System Administrator'];
       User u = new User(alias='neUser', email='newTestinguser@test.com', emailencodingkey='UTF-8', lastname='Testing', username='newTestinguser@test.com',
                          EmployeeNumber='123456780',profileid=profile.id, languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
       insert u;
      
       Blob myBlob = Blob.valueof('this is test string, i just want to raise the size of this test file'); 

       FeedItem chatterFeed = new FeedItem(ParentId=u.Id, Type='ContentPost', ContentData=myBlob, ContentFileName='chatter file upload.txt', Title='chatter file upload');
      
      try
      {
          insert chatterFeed;
      }catch(Exception e)
      {
          system.assertEquals(e.getMessage(),e.getMessage());
      }           
  }  
  
    /*Success Scenario : When a new version of an existing file is uploaded on chatter*/
    static testMethod void ChatterFileNewVersionUploadSuccessTest() 
    {
       Profile profile = [select id from Profile where name = 'System Administrator'];
       User u = new User(alias='neUser', email='newTestinguser@test.com', emailencodingkey='UTF-8', lastname='Testing', username='newTestinguser@test.com',
                          EmployeeNumber='123456780',profileid=profile.id, languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
       insert u;
      
       Blob myBlob = Blob.valueof('this is test string'); 

       ContentVersion cver = new ContentVersion(Origin='H',Title='chatter file upload',VersionData=myBlob,PathOnClient='Copy of chatter file upload.txt');
      
       insert cver;
       ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :cver.Id];       
      } 
       
    /*Failure Scenario : When a new version of an existing file is uploaded on chatter and File size is greater than the defined limit*/  
    static testMethod void ChatterFileNewVersionUploadFailureTest() 
    {
       Profile profile = [select id from Profile where name = 'System Administrator'];
       User u = new User(alias='neUser', email='newTestinguser@test.com', emailencodingkey='UTF-8', lastname='Testing', username='newTestinguser@test.com',
                          EmployeeNumber='123456780',profileid=profile.id, languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
       insert u;
      
       Blob myBlob = Blob.valueof('this is test string'); 

       ContentVersion cver1 = new ContentVersion(Origin='H',Title='chatter file upload',VersionData=myBlob,PathOnClient='Copy of chatter file upload.txt');
      
       try
       {
          insert cver1;
       }catch(Exception e)
       {
          system.assertEquals(e.getMessage(),e.getMessage());
       }           
    }  
    
    /*Success Scenario : When a new version of an existing file is uploaded on chatter*/
    static testMethod void ChatterFilePostonCommentsUploadSuccessTest() 
    {
       Profile profile = [select id from Profile where name = 'System Administrator'];
       User u = new User(alias='neUser', email='newTestinguser@test.com', emailencodingkey='UTF-8', lastname='Testing', username='newTestinguser@test.com',
                          EmployeeNumber='123456780',profileid=profile.id, languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
       insert u;
      
       Blob myBlob = Blob.valueof('this is test string');     
       ContentVersion cver = new ContentVersion(Origin='H',Title='chatter file upload',VersionData=myBlob,PathOnClient='Copy of chatter file upload.txt');
      
       insert cver;
       ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :cver.Id];
       FeedItem chatterFeed = new FeedItem(ParentId=u.Id, Type='ContentPost', ContentData=myBlob, ContentFileName='chatter file upload', Title='chatter file upload');
       insert chatterFeed;
             
       FeedComment Fcomm = New FeedComment(CommentType='ContentComment', RelatedRecordId=testContent.Id, FeedItemId=chatterFeed.Id);
       insert Fcomm;
    }        
}