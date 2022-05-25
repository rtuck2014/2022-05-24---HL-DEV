@IsTest class EmailMessageControllerTest {
    @IsTest
    static void myUnitTest(){
		EmailMessageController.search('testuser');
        Contact con = [SELECT Id FROM Contact WHERE LastName='testuser'];
        
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName='unique_name_addSomethingSpecialHere'];
        
        Engagement_Counterparty__c ec = [SELECT Id FROM Engagement_Counterparty__c];
        try{
        	EmailMessageController.sendEmailController('{"contactIdList":["'+con.Id+'"],"templateId":"'+et.Id+'","whatId":"'+ec.Id+'"}');
        }catch(Exception e){
            
        }
    }
    
    @TestSetup
    static void makeData(){
		Account a = new Account();
        a.Name = 'test';
        insert a;
                       
        Contact con = new Contact(AccountId=a.Id,LastName='testuser',firstname='test',Email='testasdf234@xyz.com');        
        insert con;
        
        Legal_Entity__c lgE = new Legal_Entity__c ();
        lge.name ='test LGE';        
        insert lgE;
        
        Engagement__c engMent = new Engagement__c ();
        engMent.name = 'Test';
        engMent.Subject__c  = a.Id;
        engMent.Client__c   = a.Id;
        engMent.Line_of_Business__c  = 'CF';
        engMent.Job_Type__c ='Activism Advisory';
        engMent.Industry_Group__c  = 'BUS - Business Services';
        engMent.Sector__c  ='Education & Training';
        engMent.Stage__c  = 'Retained';
        engMent.Primary_Office__c  = 'AM';
        engMent.Legal_Entity__c  = lgE.Id;        
        insert engment;
        
        Engagement_Counterparty__c ec = new Engagement_Counterparty__c(Name='Test',Engagement__c=engment.Id);
        insert ec;
        
        Test.startTest();
        createTemplate();
        Test.stopTest();
    }
    
    @Future
    static void createTemplate(){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.Subject = 'Your Subject Here';
        insert validEmailTemplate;
    }
}