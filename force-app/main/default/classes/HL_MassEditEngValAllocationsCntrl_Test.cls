@isTest
private class HL_MassEditEngValAllocationsCntrl_Test{   
    public static User createTestUser(Id profID, String fName, String lName)
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
    
    Static List<Delegate_Public_Group__c> dpgList;
    Static User usr;   
    
    @testSetup 
    static void setup(){    
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       
         List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
         
        id EngRTid;
        for(RecordType RT : [Select id from RecordType Where SobjectType = 'Engagement__c' AND developername = 'Portfolio_Valuation'])
        {
            EngRTid = RT.Id; 
        }
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Client__c = accList[0].Id;
        Engagement.Subject__c = accList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        Engagement.Total_Estimated_Fee__c = 0.00;
        Engagement.RecordTypeId  = EngRTid ;
        insert Engagement;
              
     
         Monthly_Revenue_Process_Control__c testMRPC = new Monthly_Revenue_Process_Control__c();
        testMRPC.Current_Year__c = String.Valueof(System.today().Year());
        testMRPC.Current_Month__c = String.Valueof(System.today().Month() < 10 ? '0'+String.Valueof(System.today().Month()):String.Valueof(System.today().Month()));
        testMRPC.IsCurrent__c = true;
        insert testMRPC;  
        
        Eng_VP__c EngVPList =(Eng_VP__c)HL_TestFactory.CreateSObject('Eng_VP__c',false);        
        EngVPList.Name='Test Eng Vp';        
        EngVPList.Engagement__c=Engagement.id;
        EngVPList.Valuation_Date__c=System.Today();
        EngVPList.CurrencyIsoCode='USD';   
        EngVPList.Fee_Total__c = 10.00;
        EngVPList.Client_Complexity__c ='1';
        EngVPList.Client_Draft_Deadline__c = System.Today().addDays(30);
        EngVPList.Client_Final_Deadline__c =  System.Today().addDays(60); 
        Insert EngVPList;
         
        List<Eng_Valuation_Period_Allocation__c> lstEVPA =new List<Eng_Valuation_Period_Allocation__c>();
        for(integer i = 0; i <5; i++){
        Eng_Valuation_Period_Allocation__c engVPA = new Eng_Valuation_Period_Allocation__c();
           engVPA.Engagement_Valuation_Period__c=EngVPList.id;
           lstEVPA.add(engVPA);
       
        }
        insert lstEVPA;
  
    }   
    
 @isTest
    static void TestEngVPMassEdit(){ 
        String Engname;  
        Eng_VP__c enObj = [SELECT Id,OwnerId FROM Eng_VP__c LIMIT 1];
        Engagement__c engObj = [SELECT Id,OwnerId,name FROM Engagement__c LIMIT 1]; 
         Eng_VP__c  EngVP = new Eng_VP__c ();               
        EngVP.Name='Test Eng Vp 2';        
        EngVP.Engagement__c=EngObj.id;
        EngVP.Valuation_Date__c=System.Today();
        EngVP.CurrencyIsoCode='USD';    
        EngVP.OwnerId= userinfo.getuserId();
        EngVP.Client_Complexity__c ='1';
        EngVP.Client_Draft_Deadline__c = System.Today().addDays(30);
        EngVP.Client_Final_Deadline__c =  System.Today().addDays(60); 
        Insert EngVP; 
        EngVP.Engagement__c=EngVP.id;
        List<Eng_Valuation_Period_Allocation__c> lstEVPA=[select id,Admin_Allocation__c,Associate_Allocation__c,Analyst_Allocation__c,Engagement_Valuation_Period__c,Week_Ending__c,Week_Starting__c from Eng_Valuation_Period_Allocation__c limit10]; 
        List<string> lstEVPAIds=new List<string>();
        for(Eng_Valuation_Period_Allocation__c obj :[select id,Week_Ending__c,Week_Starting__c from Eng_Valuation_Period_Allocation__c]){
        lstEVPAIds.add(obj.id);
        } 
        
        Test.setCurrentPageReference(new PageReference('Page.HL_Mass_Edit_Eng_Valuation_Allocations')); 
        System.currentPageReference().getParameters().put('eid', enObj.Id );
        test.startTest();           
            ApexPages.StandardController sc = new ApexPages.StandardController(lstEVPA[0]);
            HL_MassEditEngValAllocationsCntrl con = new HL_MassEditEngValAllocationsCntrl(sc);             
            HL_MassEditEngValAllocationsCntrl.getEngValuationPeriodAllocation(enObj.id); 
            HL_MassEditEngValAllocationsCntrl.deleteEngValuationPeriodAllocation(lstEVPAIds);     
            HL_MassEditEngValAllocationsCntrl.checkDeletePermision();
        lstEVPA[0].Week_Starting__c=System.Today().addDays(30);
        lstEVPA[0].Week_Ending__c=System.Today().addDays(90);
         con.save();
         HL_MassEditEngValAllocationsCntrl.CreateEngVPAllocations(lstEVPA);
        HL_MassEditEngValAllocationsCntrl.saveRecord(lstEVPA[0]);
        Eng_Valuation_Period_Allocation__c obj=[select id,Week_Ending__c,Week_Starting__c from Eng_Valuation_Period_Allocation__c limit 1];
      //  HL_MassEditEngValAllocationsCntrl.deleteRecord(obj.id);
       
        test.stopTest();
    } 
  
    

}