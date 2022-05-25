@IsTest(SeeAllData=true)
private class Test_HL_OpportunityReview {
  @IsTest private static void TestOpportunityReview(){
        //Create Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.job_type__c = 'Buyside & Financing Advisory';
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
       
        ApexPages.currentPage().getParameters().put('oppid',opp.Id);
        ApexPages.currentPage().getParameters().put('JobType','Buyside');
        ApexPages.currentPage().getParameters().put('IsNBC','1');
        id oppid=ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        HL_OpportunityReviewController HLOP= new HL_OpportunityReviewController();
        boolean onOIT=HLOP.getonOIT(opp.Id,UserInfo.getUserId());
        HLOP.getonNBCViewAccess(opp.Id,UserInfo.getUserId());
        HLOP.getclassicopporutnityURL();
        HLOP.onOIT=true;
        HLOP.IsNBC='1';
        
        HLOP.opportunityreview();
        
        system.debug('=onOIT='+onOIT);        
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c();
            destRecord.Related_Opportunity__c = opp.ID;
            destRecord.Form_Type__c = 'NBC'; 
            destRecord.onOIT__c=true;
        insert destRecord; 
        HLOP.destRecord=destRecord;
    //HLOP.existingRecords.add(HLOP.destRecord); 
        
       list< Opportunity_Approval__c > oalist=[SELECT Id, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:opp.Id LIMIT 1];
                
       
        
        //Test Again Now that Record was Created
        HLOP.opportunityreview();
        
        Test.stopTest();
    }
    
    @IsTest private static void Testnbcform1(){
        //Create Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.job_type__c = 'Buyside & Financing Advisory';
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
    	opp.form_type__c='M&A';
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c();
            destRecord.Related_Opportunity__c = opp.ID;
            
            destRecord.onOIT__c=true;
        insert destRecord;
        
        id oppid=ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        HL_OpportunityReviewController HLOP1 = new HL_OpportunityReviewController(sc);
        
        PageReference pageRef = Page.HL_NBCForm;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);       
        
        HLOP1.op=opp;
   
        
        //HLOP1.getonOIT(opp.Id,UserInfo.getUserId());
        //HLOP1.getonNBCViewAccess(opp.Id,UserInfo.getUserId());
        HLOP1.getclassicopporutnityURL();
        HLOP1.onOIT=true;
        HLOP1.IsNBC='1';
        
                  

        HLOP1.destRecord=destRecord;
    
        
        list< Opportunity_Approval__c > oalist=[SELECT Id, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:opp.Id LIMIT 1];
                
       
        
        //Test Again Now that Record was Created
        HLOP1.Radioblock();
        
        Test.stopTest();
    }
    
    @IsTest private static void Testnbcform(){
        //Create Test Data
       Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.job_type__c = 'Buyside & Financing Advisory';
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
    	opp.form_type__c='Capital Market';
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c();
            destRecord.Related_Opportunity__c = opp.ID;
            
            destRecord.onOIT__c=true;
        insert destRecord;
        
        id oppid=ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        HL_OpportunityReviewController HLOP1 = new HL_OpportunityReviewController(sc);
        
        PageReference pageRef = Page.HL_NBCForm;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);       
        
        HLOP1.op=opp;
   
        
        //HLOP1.getonOIT(opp.Id,UserInfo.getUserId());
        //HLOP1.getonNBCViewAccess(opp.Id,UserInfo.getUserId());
        HLOP1.getclassicopporutnityURL();
        HLOP1.onOIT=true;
        HLOP1.IsNBC='1';
        
                  

        HLOP1.destRecord=destRecord;
    
        
        list< Opportunity_Approval__c > oalist=[SELECT Id, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:opp.Id LIMIT 1];
                
       
        
        //Test Again Now that Record was Created
        HLOP1.Radioblock();
        
        Test.stopTest();
    }
    
    @IsTest private static void Testnbcform2(){
          //Create Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.job_type__c = 'Buyside & Financing Advisory';
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
    
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c();
            destRecord.Related_Opportunity__c = opp.ID;
            
            destRecord.onOIT__c=true;
        insert destRecord;
        
        id oppid=ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        HL_OpportunityReviewController HLOP1 = new HL_OpportunityReviewController(sc);
        
        PageReference pageRef = Page.HL_NBCForm;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);       
        
        HLOP1.op=opp;
   
        
        //HLOP1.getonOIT(opp.Id,UserInfo.getUserId());
        //HLOP1.getonNBCViewAccess(opp.Id,UserInfo.getUserId());
        HLOP1.getclassicopporutnityURL();
        HLOP1.onOIT=true;
        HLOP1.IsNBC='1';
        
                  

        HLOP1.destRecord=destRecord;
    
        
        list< Opportunity_Approval__c > oalist=[SELECT Id, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:opp.Id LIMIT 1];
                
       
        
        //Test Again Now that Record was Created
        HLOP1.Radioblock();
        
        Test.stopTest();
    }
    
    @IsTest private static void Testnbcform3(){
          //Create Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.job_type__c = 'Negotiated Fairness';
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
    
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c();
            destRecord.Related_Opportunity__c = opp.ID;
            
            destRecord.onOIT__c=true;
        insert destRecord;
        
        id oppid=ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        HL_OpportunityReviewController HLOP1 = new HL_OpportunityReviewController(sc);
        
        PageReference pageRef = Page.HL_NBCForm;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);       
        
        HLOP1.op=opp;
   
        
        //HLOP1.getonOIT(opp.Id,UserInfo.getUserId());
        //HLOP1.getonNBCViewAccess(opp.Id,UserInfo.getUserId());
        HLOP1.getclassicopporutnityURL();
        HLOP1.onOIT=true;
        HLOP1.IsNBC='1';
        
                  

        HLOP1.destRecord=destRecord;
    
        
        list< Opportunity_Approval__c > oalist=[SELECT Id, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:opp.Id LIMIT 1];
                
       
        
        //Test Again Now that Record was Created
        HLOP1.opportunityreview();
        
        Test.stopTest();
    }
    
    @IsTest private static void Testnbcform4(){
          //Create Test Data
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.job_type__c = 'Debt Capital Markets';
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
    
        insert opp;
        
        Test.startTest();
        //Test with no valid parameters
        Opportunity_Approval__c destRecord = new Opportunity_Approval__c();
            destRecord.Related_Opportunity__c = opp.ID;
            
            destRecord.onOIT__c=true;
        insert destRecord;
        
        id oppid=ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        HL_OpportunityReviewController HLOP1 = new HL_OpportunityReviewController(sc);
        
        PageReference pageRef = Page.HL_NBCForm;
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);       
        
        HLOP1.op=opp;
   
        
        //HLOP1.getonOIT(opp.Id,UserInfo.getUserId());
        //HLOP1.getonNBCViewAccess(opp.Id,UserInfo.getUserId());
        HLOP1.getclassicopporutnityURL();
        HLOP1.onOIT=true;
        HLOP1.IsNBC='1';
        
                  

        HLOP1.destRecord=destRecord;
    
        
        list< Opportunity_Approval__c > oalist=[SELECT Id, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:opp.Id LIMIT 1];
                
       
        
        //Test Again Now that Record was Created
        HLOP1.opportunityreview();
        
        Test.stopTest();
    }
    
}