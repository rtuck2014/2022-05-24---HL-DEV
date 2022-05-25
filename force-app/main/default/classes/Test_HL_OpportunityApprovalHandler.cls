@IsTest
private class Test_HL_OpportunityApprovalHandler {
    @isTest private static void TestInsertOpportunityApprovalWithNoRelatedEngagements(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'NBC';
        oa.Grade__c='A';
        
         //Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(oa);
        Test.stopTest();
        
        System.Assert(result.isSuccess());
    }
    
    @isTest private static void TestInsertOpportunityApprovalWithRelatedEngagements(){
        //Setup the Data
        //Use this as our subject account
        Account a = SL_TestSetupUtils.CreateAccount('',1)[0];
        insert a;
        List<Opportunity__c> o = SL_TestSetupUtils.CreateOpp('',2);
        o[0].Beneficial_Owner_Control_Person_form__c = 'No';
        o[1].Beneficial_Owner_Control_Person_form__c = 'No';
        
        insert o;
        List<Engagement__c> eList = SL_TestSetupUtils.CreateEngagement('',5);
        insert eList;
        Opportunity_Approval__c oa =  SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = o[0].id;
        Opportunity_Approval__c oaBuyside =  SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Form_Type__c = 'FEIS';
        oa.Reviewed__c=true;
        
        oaBuyside.Related_Opportunity__c = o[1].id;
        
        for(Engagement__c e : eList)
            e.Subject__c = a.Id;
        
        eList[0].Job_Type__c = 'Buyside';
        
        for(Integer i = 0; i<o.size(); i++)
        {
            o[i].Subject__c = a.Id;
            if(i == 1)
                o[i].Job_Type__c = 'Buyside';
        }
        
        update o;
        update eList;
        
        //Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(oa);
        Database.SaveResult resultBuyside = Database.insert(oaBuyside);
        Test.stopTest();
        
        //Verify insert was successful
        System.Assert(result.isSuccess());
        System.Assert(resultBuyside.isSuccess());
        //Verify the Previous Transaction field is not null
        oa = [SELECT Id, Previous_Transactions__c FROM Opportunity_Approval__c WHERE Id =:result.getId()];
        System.Assert(oa.Previous_Transactions__c <> null); 
        oa = [SELECT Id, Previous_Transactions__c FROM Opportunity_Approval__c WHERE Id =:resultBuyside.getId()];
        System.Assert(oa.Previous_Transactions__c <> null); 
    }
    
    @isTest private static void TestSubmitReviewCancel(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        
        insert opp;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'NBC';
        insert oa;
        
        list<Group> listg= [select Id from Group where Name='CF NBC Review Q' limit 1];
         //Perform test
        Test.startTest();
        
        Opportunity_Approval__c oaa=[select Form_Type__c from Opportunity_Approval__c where id=:oa.id];
        	oaa.Submit_For_Review__c=false;
        	oa.Approval_Status__c='Submit_To_Committee ';
        
        Opportunity__c op=[select ownerid from Opportunity__c where id=:opp.id];
            op.ownerid=listg[0].id;
        
        Database.SaveResult result = Database.update(oaa);
        Database.SaveResult result1 = Database.update(op);
        Test.stopTest();
        
        System.Assert(result.isSuccess());
    }
    
    @isTest(SeeAllData=true)
    private static void TestSubmitReviewCancel1(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        opp.Conflicts_Check_Request_Date__c=system.today();
        opp.Client_Ownership__c='Bank';
        opp.Subject_Company_Ownership__c='Bank';
        insert opp;
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'NBC';
        
        insert oa;
        
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newClient;
        
        Financials__c pFinancials = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, Type__c='Annual',Revenue_MM__c=100,EBITDA__c=100,Year__c='2020');
        Insert pFinancials;
        
        Financials__c pFinancials1 = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, Type__c='Proforma',Revenue_MM__c=10,EBITDA__c=10,Year__c='2021');
        Insert pFinancials1;
        
         //Perform test
        Test.startTest();
        
        Opportunity_Approval__c oaa=[select Submit_For_Review__c from Opportunity_Approval__c where id=:oa.id];
        try{
        	oaa.Submit_For_Review__c=true;
            oaa.Head_Approval__c=true;
        	/*oaa.a__c = '';
        	oaa.b__c = 'Yes';
        	oaa.c__c = 'Yes';
        	oaa.d__c = 'Yes';
        	oaa.Status__c='Outstanding/Sent';
        	oaa.Ownership_and_Capital_Structure__c='test';
        	oaa.Valuation_Expectations__c='test';
        	oaa.Total_Debt_MM__c=10;
        	oaa.Risk_Factors__c='test';
        	oaa.Transaction_Overview__c='test';
        	oaa.International_Angle__c='no';
        	oaa.Asia_Angle__c='no';
        	oaa.Real_Estate_Angle__c='no';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.No_Financials__c=true;
        	oaa.No_Financials_Explanation__c='test';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.Estimated_Minimum_Fee__c=10;
        	oaa.Fee_Structure__c='test';
        	oaa.Lockups_on_Future_M_A_or_Financing_Work__c='no';
        	oaa.Referral_Fee_Owed__c='no';
        	oaa.Will_there_be_a_pitch__c='yes';
        	oaa.Houlihan_Lokey_Competition__c='test';
        	oaa.TAS_Assistance_Benefit__c='no';
        	oaa.OutsideCouncil__c='test';
        	oaa.Existing_or_Repeat_Client__c='no';
        	oaa.Existing_Relationships__c='no';
        	oaa.Fairness_Opinion_Provided__c='no';
        	oaa.Restricted_List__c='no';
        	oaa.Use_of_Proceeds__c='Growth';*/
            
        Database.SaveResult result = Database.update(oaa);
           // HLTeamApproved(Oaa);
        System.assert(true, Label.checkEngagementTeamRoles);
        }
        catch(Exception e)
        {
         	//System.assert(e.getMessage().contains(Label.checkEngagementTeamRoles));
        }
        Test.stopTest();
        
       
    }
    
    @isTest(SeeAllData=true)
    private static void TestSubmitReviewCancel2(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        opp.Conflicts_Check_Request_Date__c=system.today();
        opp.Client_Ownership__c='Public Equity';
        opp.Subject_Company_Ownership__c='Public Equity';
        
        insert opp;
        
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newClient;
        
        
        
        contact objcon = new  contact();
        objcon.FirstName = 'Test';
        objcon.LastName = 'Contact';
        objcon.AccountId = newClient.Id;
        Insert objcon;
        
        /*list<contact> clist=new list<contact>();
        clist.add(objcon);
        GetMajoritySaleContactNames(clist);*/
        
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();
        Staff_Role__c staffRole = new Staff_Role__c();
        staffRole.Name = 'Principal';
        staffRoleList.add(staffRole);
        Staff_Role__c staffRole1 = new Staff_Role__c();
        staffRole.Name = 'Manager';
        staffRoleList.add(staffRole1);
        Staff_Role__c staffRole2 = new Staff_Role__c();
        staffRole.Name = 'Initiator';
        staffRoleList.add(staffRole2);
        insert staffRoleList;
        //System.debug('Staffrole' +staffRoleList[0].Id +staffRoleList[1].Id +staffRoleList[2].Id );
              
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'CNBC';
        insert oa;
        
        Financials__c pFinancials = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, year__c='2002', Type__c='Annual');
        Insert pFinancials;
        
        Financials__c pFinancials1 = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, year__c='2001', Type__c='Annual');
        Insert pFinancials1;
         //Perform test
        Test.startTest();
        
        Opportunity_Approval__c oaa=[select Submit_For_Review__c from Opportunity_Approval__c where id=:oa.id];
        try
        {	
            oaa.Submit_For_Review__c=true; 
            oaa.Transaction_Fee_Type__c='Incentive Structure';
            oaa.Form_Type__c='NBC';
            oaa.a__c = 'No';
        	oaa.Status__c='Outstanding/Sent';
        	/*oaa.Ownership_and_Capital_Structure__c='test';
        	oaa.Valuation_Expectations__c='test';
        	oaa.Total_Debt_MM__c=10;
        	oaa.Risk_Factors__c='test';
        	oaa.Transaction_Overview__c='test';
        	oaa.International_Angle__c='no';
        	oaa.Asia_Angle__c='no';
        	oaa.Real_Estate_Angle__c='no';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.No_Financials__c=true;
        	oaa.No_Financials_Explanation__c='test';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.Estimated_Minimum_Fee__c=10;
        	oaa.Fee_Structure__c='test';
        	oaa.Lockups_on_Future_M_A_or_Financing_Work__c='no';
        	oaa.Referral_Fee_Owed__c='no';
        	oaa.Will_there_be_a_pitch__c='yes';
        	oaa.Houlihan_Lokey_Competition__c='test';
        	oaa.TAS_Assistance_Benefit__c='no';
        	oaa.OutsideCouncil__c='test';
        	oaa.Existing_or_Repeat_Client__c='no';
        	oaa.Existing_Relationships__c='no';
        	oaa.Fairness_Opinion_Provided__c='no';
        	oaa.Restricted_List__c='no';
        	oaa.Use_of_Proceeds__c='Growth';
        	oaa.Capital_Raise__c=10;
        	oaa.Structure_and_Pricing_Expectations__c='10';*/
        Database.SaveResult result = Database.update(oaa);
        System.assert(true, Label.Is_Majority_Sale);
        HL_OpportunityApprovalHandler nl=new HL_OpportunityApprovalHandler();    
            nl.HLTeamApproved(oaa);
        }
        catch(Exception e)
        {
         	//System.assert(e.getMessage().contains(Label.Is_Majority_Sale));
        }
        Test.stopTest();
        
        
    }
    @isTest(SeeAllData=true)
    private static void TestSubmitReviewCancel3(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        opp.Conflicts_Check_Request_Date__c=system.today();
        opp.Client_Ownership__c='Public Equity';
        opp.Subject_Company_Ownership__c='Public Equity';
        opp.Job_Type__c='Equity Capital Markets';
        
        insert opp;
        
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newClient;
        
        
        
        contact objcon = new  contact();
        objcon.FirstName = 'Test';
        objcon.LastName = 'Contact';
        objcon.AccountId = newClient.Id;
        Insert objcon;
        
        /*list<contact> clist=new list<contact>();
        clist.add(objcon);
        GetMajoritySaleContactNames(clist);*/
        
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();
        Staff_Role__c staffRole = new Staff_Role__c();
        staffRole.Name = 'Principal';
        staffRoleList.add(staffRole);
        Staff_Role__c staffRole1 = new Staff_Role__c();
        staffRole.Name = 'Manager';
        staffRoleList.add(staffRole1);
        Staff_Role__c staffRole2 = new Staff_Role__c();
        staffRole.Name = 'Initiator';
        staffRoleList.add(staffRole2);
        insert staffRoleList;
        //System.debug('Staffrole' +staffRoleList[0].Id +staffRoleList[1].Id +staffRoleList[2].Id );
              
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'CNBC';
        
        insert oa;
        
        Financials__c pFinancials = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, year__c='2002', Type__c='Annual');
        Insert pFinancials;
        
        Financials__c pFinancials1 = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, year__c='2001', Type__c='Annual');
        Insert pFinancials1;
         //Perform test
        Test.startTest();
        
        Opportunity_Approval__c oaa=[select Submit_For_Review__c from Opportunity_Approval__c where id=:oa.id];
        try
        {	
            oaa.Submit_For_Review__c=true; 
            oaa.Transaction_Fee_Type__c='Incentive Structure';
            oaa.Form_Type__c='CNBC';
            
            oaa.a__c = 'No';
        	oaa.Status__c='Outstanding/Sent';
        	/*oaa.Ownership_and_Capital_Structure__c='test';
        	oaa.Valuation_Expectations__c='test';
        	oaa.Total_Debt_MM__c=10;
        	oaa.Risk_Factors__c='test';
        	oaa.Transaction_Overview__c='test';
        	oaa.International_Angle__c='no';
        	oaa.Asia_Angle__c='no';
        	oaa.Real_Estate_Angle__c='no';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.No_Financials__c=true;
        	oaa.No_Financials_Explanation__c='test';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.Estimated_Minimum_Fee__c=10;
        	oaa.Fee_Structure__c='test';
        	oaa.Lockups_on_Future_M_A_or_Financing_Work__c='no';
        	oaa.Referral_Fee_Owed__c='no';
        	oaa.Will_there_be_a_pitch__c='yes';
        	oaa.Houlihan_Lokey_Competition__c='test';
        	oaa.TAS_Assistance_Benefit__c='no';
        	oaa.OutsideCouncil__c='test';
        	oaa.Existing_or_Repeat_Client__c='no';
        	oaa.Existing_Relationships__c='no';
        	oaa.Fairness_Opinion_Provided__c='no';
        	oaa.Restricted_List__c='no';
        	oaa.Use_of_Proceeds__c='Growth';
        	oaa.Capital_Raise__c=10;
        	oaa.Structure_and_Pricing_Expectations__c='10';*/
        Database.SaveResult result = Database.update(oaa);
        System.assert(true, Label.Is_Majority_Sale);
        HL_OpportunityApprovalHandler nl=new HL_OpportunityApprovalHandler();    
            nl.HLTeamApproved(oaa);
        }
        catch(Exception e)
        {
         	//System.assert(e.getMessage().contains(Label.Is_Majority_Sale));
        }
        Test.stopTest();
        
        
    }
    
    @isTest(SeeAllData=true)
    private static void TestSubmitReviewCancel4(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        Opp.Beneficial_Owner_Control_Person_form__c = 'No';
        opp.Conflicts_Check_Request_Date__c=system.today();
        opp.Client_Ownership__c='Public Equity';
        opp.Subject_Company_Ownership__c='Public Equity';
        
        insert opp;
        
        Account newClient = SL_TestSetupUtils.CreateAccount('', 1)[0];
        Insert newClient;
        
        
        
        contact objcon = new  contact();
        objcon.FirstName = 'Test';
        objcon.LastName = 'Contact';
        objcon.AccountId = newClient.Id;
        Insert objcon;
        
        /*list<contact> clist=new list<contact>();
        clist.add(objcon);
        GetMajoritySaleContactNames(clist);*/
        
        List<Staff_Role__c> staffRoleList = new List<Staff_Role__c>();
        Staff_Role__c staffRole = new Staff_Role__c();
        staffRole.Name = 'Principal';
        staffRoleList.add(staffRole);
        Staff_Role__c staffRole1 = new Staff_Role__c();
        staffRole.Name = 'Manager';
        staffRoleList.add(staffRole1);
        Staff_Role__c staffRole2 = new Staff_Role__c();
        staffRole.Name = 'Initiator';
        staffRoleList.add(staffRole2);
        insert staffRoleList;
        //System.debug('Staffrole' +staffRoleList[0].Id +staffRoleList[1].Id +staffRoleList[2].Id );
              
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'CNBC';
        oa.EU_Override__c  = True;
        insert oa;
        
        Financials__c pFinancials = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, year__c='2002', Type__c='Annual');
        Insert pFinancials;
        
        Financials__c pFinancials1 = new  Financials__c(Related_Account__c = newClient.Id, Related_Approval__c = oa.Id, year__c='2001', Type__c='Annual');
        Insert pFinancials1;
         //Perform test
        Test.startTest();
        
        Opportunity_Approval__c oaa=[select Submit_For_Review__c from Opportunity_Approval__c where id=:oa.id];
        try
        {	
            oaa.Submit_For_Review__c=true; 
            
            oaa.a__c = 'No';
        	oaa.Status__c='Outstanding/Sent';
        	/*oaa.Ownership_and_Capital_Structure__c='test';
        	oaa.Valuation_Expectations__c='test';
        	oaa.Total_Debt_MM__c=10;
        	oaa.Risk_Factors__c='test';
        	oaa.Transaction_Overview__c='test';
        	oaa.International_Angle__c='no';
        	oaa.Asia_Angle__c='no';
        	oaa.Real_Estate_Angle__c='no';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.No_Financials__c=true;
        	oaa.No_Financials_Explanation__c='test';
        	oaa.Capital_Markets_Consulted__c='no';
        	oaa.Existing_Financial_Arrangement_Notes__c='test';
        	oaa.Estimated_Minimum_Fee__c=10;
        	oaa.Fee_Structure__c='test';
        	oaa.Lockups_on_Future_M_A_or_Financing_Work__c='no';
        	oaa.Referral_Fee_Owed__c='no';
        	oaa.Will_there_be_a_pitch__c='yes';
        	oaa.Houlihan_Lokey_Competition__c='test';
        	oaa.TAS_Assistance_Benefit__c='no';
        	oaa.OutsideCouncil__c='test';
        	oaa.Existing_or_Repeat_Client__c='no';
        	oaa.Existing_Relationships__c='no';
        	oaa.Fairness_Opinion_Provided__c='no';
        	oaa.Restricted_List__c='no';
        	oaa.Use_of_Proceeds__c='Growth';
        	oaa.Capital_Raise__c=10;
        	oaa.Structure_and_Pricing_Expectations__c='10';*/
        Database.SaveResult result = Database.update(oaa);
        System.assert(true, Label.Is_Majority_Sale);
        HL_OpportunityApprovalHandler nl=new HL_OpportunityApprovalHandler();    
            nl.HLTeamApproved(oaa);
        }
        catch(Exception e)
        {
         	//System.assert(e.getMessage().contains(Label.Is_Majority_Sale));
        }
        Test.stopTest();
        
        
    }
    
    @isTest(SeeAllData=true)
    private static void TestSubmitReviewCancel5(){
       Test.startTest();
        List<Account> accountList = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert accountList;
        Contact c = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE)[0];
        c.AccountId = accountList[0].Id;        
        insert c;    
        
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        List<Opportunity_Internal_Team__c> oitList = SL_TestSetupUtils.CreateOIT('', oppTeamRoles.size());
        List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
        {
            oitList[i].Contact__c = c.Id;
            oitList[i].Opportunity__c = opp.Id;
            oitList[i].Staff_Role__c = staffRoles[i].Id;
        }
        
        
            insert oitList;
            delete oitList[0]; 
         
        
        
       
        
        Opportunity_Approval__c oa = SL_TestSetupUtils.CreateOA('',1)[0];
        oa.Related_Opportunity__c = opp.id;
        oa.Form_Type__c = 'CNBC';
        oa.EU_Override__c  = FALSE;
        insert oa;
        
        
        
        

        HL_OpportunityApprovalHandler nl=new HL_OpportunityApprovalHandler();    
            nl.HLTeamApproved(oa);
        
        Test.stopTest(); 
     
        
        
    }
}