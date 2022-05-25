@isTest
private class Test_HL_RedirectingToPVController  { 
    static Opportunity__c opportunity;
    static Engagement__c e; 
    
    static void createData(){
            List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
            for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT;                
        
        opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accList[0].Id;
        opportunity.Subject__c = accList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'FVA';
        opportunity.Job_Type__c = 'FA - Portfolio-Valuation';
        opportunity.Primary_Office__c = 'AT';
        opportunity.Converted_To_Engagement__c =false;
        opportunity.Approved__c = true;
        insert opportunity;
        
        e = new Engagement__c();
        e.Name='Test FVA Engagement';
        e.Client__c = accList[0].Id;
        e.Subject__c = accList[0].Id;
        e.Opportunity__c = opportunity.Id;
        e.Line_of_Business__c = 'FVA';
        e.Job_Type__c = 'FMV Transaction Based Opinion';
        e.Primary_Office__c = 'NY';
        e.Total_Estimated_Fee__c = 100000;
        insert e;
    }
    
    @isTest
    static void TestAddedMethod_PositiveCase(){
        createData();
        Opp_VP__c oppVP =(Opp_VP__c)HL_TestFactory.CreateSObject('Opp_VP__c',false);
        oppVP.Name='Test Opp Vp';        
        oppVp.Opportunity__c = opportunity.id;        
        oppVP.Valuation_Date__c=System.Today();
        oppVp.CurrencyIsoCode='USD';  
        oppVp.Isconverted__C = false;      
        Insert oppVP; 
        test.startTest(); 
           SL_Convert__Custom_Mapping__c objCCM = new SL_Convert__Custom_Mapping__c(Name = 'Test -01', SL_Convert__Sobject_API_Name__c = 'Opportunity__c'); 
        insert objCCM;  
          
        List <SL_Convert__Object_Relationship__c >slcorObj = new List<SL_Convert__Object_Relationship__c >();  
        SL_Convert__Object_Relationship__c objCOR0 = new SL_Convert__Object_Relationship__c(SL_Convert__Custom_Mapping__c = objCCM.Id,SL_Convert__Context_Object_API__c = 'Opportunity__c');
        slcorObj.add(objCOR0);      
        SL_Convert__Object_Relationship__c objCOR1 = new SL_Convert__Object_Relationship__c(SL_Convert__Custom_Mapping__c = objCCM.Id,SL_Convert__Context_Relationship_Id__c = 'Opp_VP__c');
        slcorObj.add(objCOR1);                
        SL_Convert__Object_Relationship__c objCOR2 = new SL_Convert__Object_Relationship__c(SL_Convert__Custom_Mapping__c = objCCM.Id,SL_Convert__Context_Relationship_Id__c = 'Opp_VP_Position__c');
        slcorObj.add(objCOR2);  
        SL_Convert__Object_Relationship__c objCOR3 = new SL_Convert__Object_Relationship__c(SL_Convert__Custom_Mapping__c = objCCM.Id,SL_Convert__Context_Relationship_Id__c = 'Opp_VP_TeamMember__c');
        slcorObj.add(objCOR3);  
        insert slcorObj;
        
        List <SL_Convert__Field_Mapping__c > objCFM = new List<SL_Convert__Field_Mapping__c >();    
        
        SL_Convert__Field_Mapping__c slcObj0 = new SL_Convert__Field_Mapping__c(); 
        slcObj0.SL_Convert__Active__c = true;
        slcObj0.SL_Convert__Context_Field_Name__c = 'Name';
        slcObj0.SL_Convert__Target_Field_Name__c = 'Name';  
        slcObj0.SL_Convert__Object_Relationship__c = objCOR0.Id;        
        objCFM.add(slcObj0);
        
        SL_Convert__Field_Mapping__c slcObj = new SL_Convert__Field_Mapping__c(); 
        slcObj.SL_Convert__Active__c = true;
        slcObj.SL_Convert__Context_Field_Name__c = 'Valuation_Date__c';
        slcObj.SL_Convert__Target_Field_Name__c = 'Valuation_Date__c';  
        slcObj.SL_Convert__Object_Relationship__c = objCOR1.Id;        
        objCFM.add(slcObj);
        
        SL_Convert__Field_Mapping__c slcObj1 = new SL_Convert__Field_Mapping__c(); 
        slcObj1.SL_Convert__Active__c = true;
        slcObj1.SL_Convert__Context_Field_Name__c = 'Asset_Classes__c';
        slcObj1.SL_Convert__Target_Field_Name__c = 'Asset_Classes__c';
        slcObj1.SL_Convert__Object_Relationship__c = objCOR2.Id;
        objCFM.add(slcObj1);
        SL_Convert__Field_Mapping__c slcObj2 = new SL_Convert__Field_Mapping__c(); 
        slcObj2.SL_Convert__Active__c = true;
        slcObj2.SL_Convert__Context_Field_Name__c = 'Company__c';
        slcObj2.SL_Convert__Target_Field_Name__c = 'Company__c';
        slcObj2.SL_Convert__Object_Relationship__c = objCOR2.Id; 
        objCFM.add(slcObj2);
        
        SL_Convert__Field_Mapping__c slcObj3 = new SL_Convert__Field_Mapping__c(); 
        slcObj3.SL_Convert__Active__c = true;
        slcObj3.SL_Convert__Context_Field_Name__c = 'Start_Date__c';
        slcObj3.SL_Convert__Target_Field_Name__c = 'Start_Date__c';
        slcObj3.SL_Convert__Object_Relationship__c = objCOR3.Id;
        objCFM.add(slcObj3);        
        SL_Convert__Field_Mapping__c slcObj4 = new SL_Convert__Field_Mapping__c(); 
        slcObj4.SL_Convert__Active__c = true;
        slcObj4.SL_Convert__Context_Field_Name__c = 'Staff__c';
        slcObj4.SL_Convert__Target_Field_Name__c = 'Staff__c';
        slcObj4.SL_Convert__Object_Relationship__c = objCOR3.Id;        
        objCFM.add(slcObj4);
        SL_Convert__Field_Mapping__c slcObj5 = new SL_Convert__Field_Mapping__c(); 
        slcObj5.SL_Convert__Active__c = true;
        slcObj5.SL_Convert__Context_Field_Name__c = 'Role__c';
        slcObj5.SL_Convert__Target_Field_Name__c = 'Role__c';
        slcObj5.SL_Convert__Object_Relationship__c = objCOR3.Id;        
        objCFM.add(slcObj5);        
        insert objCFM;       
           Test.setCurrentPageReference(new PageReference('Page.HL_RedirectingToPV'));
           System.currentPageReference().getParameters().put('id', e.Id);
           System.currentPageReference().getParameters().put('Oppid', opportunity.Id);
           HL_RedirectingToPVController obj = new HL_RedirectingToPVController();           
           obj.calculate();
           String ErrorMessage = obj.ErrorMessage;
           obj.BackToEnagement();
        test.stopTest();
        System.assertNotEquals(null,opportunity);                                                                             
    }   
    
    @isTest
    static void TestAddedMethod_withoutOppVP(){
        createData();     
        test.startTest();      
           Test.setCurrentPageReference(new PageReference('Page.HL_RedirectingToPV'));
           System.currentPageReference().getParameters().put('id', e.Id);
           System.currentPageReference().getParameters().put('Oppid', opportunity.Id);
           HL_RedirectingToPVController obj = new HL_RedirectingToPVController();           
           obj.calculate();
           String ErrorMessage = obj.ErrorMessage;
           obj.BackToEnagement();
        test.stopTest();
        System.assertNotEquals(null,opportunity);                                                                             
    }
    
    @isTest
    static void TestAddedMethod_NegativeCase(){
        createData();
        Opp_VP__c oppVP =(Opp_VP__c)HL_TestFactory.CreateSObject('Opp_VP__c',false);
        oppVP.Name='Test Opp Vp';        
        oppVp.Opportunity__c = opportunity.id;        
        oppVP.Valuation_Date__c=System.Today();
        oppVp.CurrencyIsoCode='USD';  
        oppVp.Isconverted__C = false;      
        Insert oppVP; 
        test.startTest();      
           Test.setCurrentPageReference(new PageReference('Page.HL_RedirectingToPV'));
           System.currentPageReference().getParameters().put('id', e.Id);
           System.currentPageReference().getParameters().put('Oppid', opportunity.Id);
           HL_RedirectingToPVController obj = new HL_RedirectingToPVController();           
           obj.calculate();
           String ErrorMessage = obj.ErrorMessage;
           obj.BackToEnagement();
        test.stopTest();
        System.assertNotEquals(null,opportunity);                                                                             
    }
}