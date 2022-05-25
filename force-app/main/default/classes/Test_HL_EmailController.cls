@isTest
private class Test_HL_EmailController {
    @isTest private static void TestEventEmail(){
        //Setup Test Data
        
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
        
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        c.Office__c = 'LA';
        c.Email = 'sampletest@hl.com';
        c.accountid=client.id;
        insert c;
        
        Event e = SL_TestSetupUtils.CreateEvent('',1)[0];
        e.StartDateTime = DateTime.now();
        e.EndDateTime = e.StartDateTime;
        insert e;
        Email_Template__c et = new Email_Template__c(Name='Event', Distribution_Group__c = c.Id, Email_Subject__c = 'Test', Related_Object__c = 'Event', Template_Body__c = 'Test');
        insert et;
        
        Engagement__c eg = SL_TestSetupUtils.CreateEngagement('',1)[0];
        eg.Client__c = client.Id;
        eg.Subject__c = subject.Id;
        insert eg;
        
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
        ApexPages.currentPage().getParameters().put('ro', eg.Id);
        ApexPages.currentPage().getParameters().put('retURL', eg.Id);
        
        Test.startTest();
            HL_EmailController con = new HL_EmailController();
        try{con.SendEmail();
            con.SelectedCCId = c.id;
            con.DelId = c.Id;
            con.AddCC();
            con.RemoveCC();
            HL_EmailController.Cancel();
            con.EmailTemplate.Name = 'FR_Summary';
            con.SendEmail();
            HL_EmailController.GetTemplate('Billing_Request',et.id);
            
        }
        //Catch Email Exception if Mail is not Enabled
        catch(System.EmailException ex){}
        Test.stopTest();
        
        //Validate no page errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
    
     @isTest private static void TestOpportunityApprovalEmail(){
        //Setup Test Data
        
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
         
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        c.Office__c = 'LA';
        c.Email = 'sampletest@hl.com';
        c.AccountId=client.id;
        insert c;
         
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Name = 'Test Opp';
         o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = o.Id;
        insert oa;
        Email_Template__c et = new Email_Template__c(Name='FEIS', Distribution_Group__c = c.Id, Email_Subject__c = 'Test', Related_Object__c = 'Opportunity_Approval__c', Template_Body__c = 'Test');
        insert et;
        
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
        ApexPages.currentPage().getParameters().put('ro', oa.Id);
        ApexPages.currentPage().getParameters().put('retURL', oa.Id);
         
        Test.startTest();
            HL_EmailController con = new HL_EmailController();
            try{con.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        Test.stopTest();
         
        //Validate no page errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
    
     @isTest private static void TestEngVPPBillingRequest(){
        //Setup Test Data
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0]; 
        client.Name = 'TestClient'; 
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
         
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        c.Office__c = 'LA';
        c.Email = 'sampletest@hl.com';
        c.AccountId=client.id;
        insert c;
        
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        e.Client__c = client.Id;
        e.Subject__c = subject.Id;
        insert e;
                   
        Eng_VP__c testEngVP = new Eng_VP__c(); 
        testEngVP .Valuation_Date__c = system.today(); 
        testEngVP.Engagement__c = e.id; 
        insert testEngVP;
        
        Eng_VP_Position__c testPosition = new Eng_VP_Position__c();        
        testPosition.Engagement_VP__c = testEngVP.id;
        testPosition.Company__c = client.id; 
        testPosition.Report_Fee__c = 100.0;
        testPosition.Asset_Classes__c = 'Equity';
        testPosition.Automation_Tool_Utilized__c = 'Yes';
         testPosition.Status__c = 'In Progress';
        insert testPosition;
        
        Email_Template__c et = new Email_Template__c(Name='Billing_Request_VP',  Email_Subject__c = 'Test', Related_Object__c = 'Eng_VP__c', Template_Body__c = 'Test');
        insert et;
        
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
        ApexPages.currentPage().getParameters().put('ro', testEngVP.Id);
        ApexPages.currentPage().getParameters().put('retURL', testEngVP.Id);
        ApexPages.currentPage().getParameters().put('reportFeeType', 'IndividualReportFee');
         
        Test.startTest();
            HL_EmailController con = new HL_EmailController();
            try{con.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        Test.stopTest();
         
        //Validate no page errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
    
     @isTest private static void TestEngBillingRequest(){
        //Setup Test Data
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
        Account subject = SL_TestSetupUtils.CreateAccount('', 1)[0];
        insert subject;
         
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        c.Office__c = 'LA';
        c.Email = 'sampletest@hl.com';
        c.AccountId=client.id;
        insert c;
       
        Engagement__c e = SL_TestSetupUtils.CreateEngagement('',1)[0];
        e.Client__c = client.Id;
        e.Subject__c = subject.Id;
        insert e;
                   
        Eng_VP__c testEngVP = new Eng_VP__c(); 
        testEngVP .Valuation_Date__c = system.today(); 
        testEngVP.Engagement__c = e.id; 
        insert testEngVP;
        
        Eng_VP_Position__c testPosition = new Eng_VP_Position__c();        
        testPosition.Engagement_VP__c = testEngVP.id;
        testPosition.Company__c = client.id; 
        testPosition.Report_Fee__c = 100.0;
        testPosition.Asset_Classes__c = 'Equity';
        testPosition.Automation_Tool_Utilized__c = 'Yes';
         testPosition.Status__c = 'In Progress';
        insert testPosition;
        
        Email_Template__c et = new Email_Template__c(Name='Billing_Request',  Email_Subject__c = 'Test', Related_Object__c = 'Engagement__c', Template_Body__c = 'Test {!User}');
        insert et;
        
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
        ApexPages.currentPage().getParameters().put('ro', e.Id);
        ApexPages.currentPage().getParameters().put('retURL', e.Id);
         
        //Test.startTest();
            HL_EmailController con = new HL_EmailController();
            try{con.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        //Test.stopTest();
        
        //et.Name='FR_Summary';
        update et;
         
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
         
        //Test.startTest();
            HL_EmailController conFRS = new HL_EmailController();
            try{conFRS.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        //Test.stopTest();
         
        //Validate no page errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
    
     @isTest private static void TestNBCBillingRequest(){
        //Setup Test Data
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
        
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        c.Office__c = 'LA';
        c.Email = 'sampletest@hl.com';
        c.AccountId=client.id;
        insert c;
         
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Name = 'Test Opp';
         o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = o.Id;
        insert oa;
        Email_Template__c et = new Email_Template__c(Name='NBC', Distribution_Group__c = c.Id, Email_Subject__c = 'Test', Related_Object__c = 'Opportunity_Approval__c', Template_Body__c = 'Test');
        insert et;
        
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
        ApexPages.currentPage().getParameters().put('ro', oa.Id);
        ApexPages.currentPage().getParameters().put('retURL', oa.Id);
         
        //Test.startTest();
            HL_EmailController con = new HL_EmailController();
            try{con.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        //Test.stopTest();
        
         et.Name='CNBC';
         update et;
         
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
         
        //Test.startTest();
            HL_EmailController conCNBC = new HL_EmailController();
            try{conCNBC.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        //Test.stopTest();
         
        //Validate no page errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
    
    @isTest private static void Testmethod1(){
        //Setup Test Data
        Account client = SL_TestSetupUtils.CreateAccount('', 1)[0];
        client.Name = 'TestClient'; 
        insert client;
        
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.User__c = UserInfo.getUserId();
        c.Office__c = 'LA';
        c.Email = 'sampletest@hl.com';
        c.AccountId=client.id;
        insert c;
         
        Opportunity__c o = SL_TestSetupUtils.CreateOpp('',1)[0];
        o.Name = 'Test Opp';
         o.Beneficial_Owner_Control_Person_form__c = 'No';
        insert o;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = o.Id;
        insert oa;
        Email_Template__c et = new Email_Template__c(Name='NBC', Distribution_Group__c = c.Id, Email_Subject__c = 'Test', Related_Object__c = 'Opportunity_Approval__c', Template_Body__c = 'Test');
        insert et;
        
        Attachment at=new Attachment();
            at.ParentId=oa.id;
                String tempString = 'TheBlogReaders.com';
                Blob beforeblob = Blob.valueOf(tempString);
            at.Body=beforeblob;
            at.Name='tset';
        insert at;
        
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
        ApexPages.currentPage().getParameters().put('ro', oa.Id);
        ApexPages.currentPage().getParameters().put('retURL', oa.Id);
         
        //Test.startTest();
            HL_EmailController con = new HL_EmailController();
            try{con.SendEmail();}
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        //Test.stopTest();
        
         et.Name='CNBC_L';
         update et;
         
        //Setup the Query String Parameters
        ApexPages.currentPage().getParameters().put('template', et.Name);
         
        Test.startTest();
            HL_EmailController conCNBC = new HL_EmailController();
            conCNBC.attachments=true;
            try{conCNBC.SendEmail();
               HL_EmailController.Cancel();
               
               }
            //Catch Email Exception if Mail is not Enabled
            catch(Exception ex){}
        Test.stopTest();
         
        //Validate no page errors
        System.assert(!ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
}