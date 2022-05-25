@isTest
public class Test_HL_ValuationPeriodPositionCancel {
    @isTest()
    static void Test_HL_ValuationPeriodPositionCancel(){
    List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 2);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_Account' +i;        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;
        }
        
        insert accountList;
         
        List<Contact> CList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 2);        
        for(integer i = 0; i < CList.size(); i++){
            CList[i].FirstName = 'TestFirst' +i;
            CList[i].LastName = 'TestLast' +i;
            CList[i].AccountId = accountList[0].id;
        }
        Insert CList; 
        
        Engagement__c Engagement =(Engagement__c)HL_TestFactory.CreateSObject('Engagement__c',false);        
        Engagement.Name='Test_Engagement';
        Engagement.Engagement_Number__c ='Testing';
        Engagement.Client__c = accountList[0].Id;
        Engagement.Subject__c = accountList[0].Id;
        Engagement.Stage__c = 'Pitched';
        Engagement.Line_of_Business__c = 'CF';
        Engagement.Job_Type__c = 'Financing';
        Engagement.Primary_Office__c = 'AT';
        insert Engagement;
        
        Monthly_Revenue_Process_Control__c mrpcNew = new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE,
                                                              Current_Month__c = '02', Current_Year__c = '2015');
        insert mrpcNew;

        Revenue_Accrual__c revenueAccrualNew = new Revenue_Accrual__c(Engagement__c = Engagement.Id,
                                                              Period_Accrued_Fees__c = 100000, Total_Estimated_Fee__c = 250000);
        insert revenueAccrualNew;
        
        List<Eng_VP__c> EngVPList = (List<Eng_VP__c>)HL_TestFactory.CreateSObjectList('Eng_VP__c',false,2);
        for(integer i = 0; i < EngVPList.size(); i++){
            EngVPList[i].Name='Test_Engagement_VP'+i;        
            EngVPList[i].Engagement__c=Engagement.id;
            EngVPList[i].Valuation_Date__c=System.Today();
            EngVPList[i].CurrencyIsoCode='USD';    
        }
        Insert EngVPList;
         
         List<Eng_VP_Position__c> EngVPPosList = (List<Eng_VP_Position__c>)HL_TestFactory.CreateSObjectList('Eng_VP_Position__c',false,4);
         for(integer i = 0; i < EngVPPosList.size(); i++){
            EngVPPosList[i].Report_Fee__c=100;
            EngVPPosList[i].Asset_Classes__c='Debt';
            EngVPPosList[i].CurrencyIsoCode='USD';
            EngVPPosList[i].Industry_Group_Picklist__c='SOV - Sovereigns';
            EngVPPosList[i].Sector__c='Sovereigns';
            EngVPPosList[i].id=apexpages.currentpage().getparameters().put('Id',EngVPPosList[0].id);
            if(i == 0 || i == 1)
            {
                EngVPPosList[i].Engagement_VP__c=EngVPList[0].Id;
                EngVPPosList[i].Company__c=accountList[0].Id;
                EngVPPosList[i].Automation_Tool_Utilized__c = 'Yes';
                EngVPPosList[i].Status__c = 'In Progress';
                //EngVPPosList[i].Generate_Accrual__c= 'yes';
            }
            if(i == 2 || i == 3)
            {
                EngVPPosList[i].Engagement_VP__c=EngVPList[1].Id;
                EngVPPosList[i].Company__c=accountList[1].Id;
                EngVPPosList[i].Automation_Tool_Utilized__c = 'Yes';
                EngVPPosList[i].Status__c = 'In Progress';
                //EngVPPosList[i].Generate_Accrual__c= 'yes';
            }           
        }  
        if(HL_ConstantsUtil.ToStopChangesStatusToCancelled == true)              
            insert EngVPPosList; 
        
    
    PageReference pref = Page.HL_EngValuationPeriodPositionCancel; 
        
        Test.setCurrentPage(pref);
        EngVPPosList[0].Status__c =System.Label.HL_Eng_VP_Status_Completed;
       // EngVPPosList[0].Generate_Accrual__c = 'Yes';
        EngVPPosList[0].Company__c=accountList[1].Id;
        update EngVPPosList[0];
        Test.startTest();       
            apexPages.Currentpage().getParameters().put('Id',EngVPPosList[0].id);         
            ApexPages.StandardController con = new ApexPages.StandardController(EngVPPosList[0]);
            HL_ValuationPeriodPositionCancel mycon = new HL_ValuationPeriodPositionCancel(con);
            system.assertequals(System.Label.HL_Eng_VP_Status_Completed,EngVPPosList[0].status__c);
            mycon.CancelAccural();
            mycon.Back();   
            apexPages.Currentpage().getParameters().put('Id',null);         
            ApexPages.StandardController con1 = new ApexPages.StandardController(EngVPPosList[0]);
            HL_ValuationPeriodPositionCancel mycon1 = new HL_ValuationPeriodPositionCancel(con1);   
            mycon1.Back();   
            
        Test.stopTest();
    }
}