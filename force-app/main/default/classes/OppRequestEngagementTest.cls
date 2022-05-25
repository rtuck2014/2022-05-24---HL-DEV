@isTest (SeeAllData=false)
private class OppRequestEngagementTest {
    
    private static User createTestUser(Id profID, String fName, String lName){
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User tuser = new User(firstname = fName,
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
    Static List<Opportunity_Internal_Team__c> oitList;
    Static List<Opportunity_External_Team__c> eitList;
    Static List<Contact> conList ;
    Static List<User> usr;
    
    @testSetup
    private static void setup() {   
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = user1.id;
        }
        insert dpgList;
        
        Delegate_Public_Group_Member__c DPGmember1 = new Delegate_Public_Group_Member__c();
        DPGmember1.Delegate__c = user1.id;
        DPGmember1.Delegate_Public_Group__c = dpgList[0].id;        
        list<Delegate_Public_Group_Member__c> objDPGMemberlist = new list<Delegate_Public_Group_Member__c>(); 
        objDPGMemberlist.add(DPGmember1);             
        insert objDPGMemberlist;   
        
        usr = new List<User>();             
        usr.add(user1);
        insert usr;
        
        List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 1);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState; 
            accList[i].EBITDA_MM__c = 18.1;
            
        }
        insert accList;
        
        conList = SL_TestSetupUtils.CreateContact('Contact', 1, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        for(integer i = 0; i < conList.size(); i++){
            conList[i].FirstName = 'DND Test';
            conList[i].LastName = 'Test LN';
            conList[i].AccountId = accList[0].Id;            
            conList[i].User__c = user1.Id;
        }
        insert conList;
        
        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accList[0].Id;
        opportunity.Subject__c = accList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'CF';
        opportunity.Job_Type__c = 'Financing';
        opportunity.Primary_Office__c = 'AT';
        
        insert opportunity;
        
        test.startTest();
        List<String> oppTeamRoles = new List<String> {'Principal','Seller','Manager','Associate','Initiator','Analyst'};
            List<Staff_Role__c> staffRoles = new List<Staff_Role__c>();
        
        for(Integer i = 0; i<oppTeamRoles.size(); i++)
            staffRoles.add(new Staff_Role__c(Name=oppTeamRoles[i], Display_Name__c = oppTeamRoles[i], CF__c = true, FAS__c = true));
        insert staffRoles;
        
        oitList = (List<Opportunity_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_Internal_Team__c', false, 1);
        for(integer i = 0; i < oitList.size(); i++){
            oitList[i].Contact__c = conList[i].Id;
            oitList[i].Opportunity__c = opportunity.Id;
            oitList[i].Staff_Role__c = staffRoles[0].id;
            oitList[i].Start_Date__c = Date.today();
            
        }
        insert oitList; 
        
        eitList = (List<Opportunity_External_Team__c>)HL_TestFactory.CreateSObjectList('Opportunity_External_Team__c', false, 1);
        for(integer i = 0; i < eitList.size(); i++){
            eitList[i].Contact__c = conList[i].Id;
            eitList[i].Opportunity__c = opportunity.Id;
            eitList[i].Role__c = 'Legal Advisor to Company/Debtor';           
        }
        insert eitList;
        test.stopTest();
    }
 
    @isTest 
    public static void TestMethforSystemAdminFunctionality(){
        test.startTest();   
        Opportunity__c opp = [SELECT Id FROM Opportunity__c where Job_Type__c = 'Financing' LIMIT 1];
        OppRequestEngagement.validateOpp(opp.Id);
        //Boolean onOIT = con.OnOIT;
        test.stopTest();
    }

    @isTest
    public static void testRunAsNonSysAdm() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CAO' LIMIT 1]; 
        User u = new User(Alias = 'tooiyr', Email='standardtestusersfdc@force.com', 
                          EmailEncodingKey='UTF-8', LastName='TestUserQADEV', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@force.com');  
        insert u;
        Test.StartTest();
        System.debug('query at test start : >>>'+Limits.getQueries());
        Account accObj = [SELECT Id, OwnerId, Name FROM Account LIMIT 1];
        System.debug('query at Account : >>>'+Limits.getQueries());
        accObj.OwnerId=u.id;
        update accObj;     
        System.debug('query at update accobj : >>>'+Limits.getQueries());
        Contact conObj =[SELECT Id,Name,OwnerId,User__c FROM Contact LIMIT 1];
        conObj.OwnerId=u.Id;
        conObj.User__c =u.Id;
        update conObj;
        Opportunity__c opp  = [SELECT Id, Name, OwnerId FROM Opportunity__c LIMIT 1];  
        opp.OwnerId= u.id;
        update opp;        
        //Opportunity_Internal_Team__c  oitObj =[SELECT Id, OwnerId, Name FROM Opportunity_Internal_Team__c LIMIT 1];
        //oitObj.OwnerId =u.Id;
        //update oitObj;
        System.runAs(u) {
            Delegate_Public_Group__c dpg = new Delegate_Public_Group__c();
            dpg.Banker__c = u.Id;
            insert dpg;            
            Delegate_Public_Group_Member__c dpmg = new Delegate_Public_Group_Member__c();
            dpmg.Delegate__c=u.id;
            dpmg.Delegate_Public_Group__c =dpg.Id;
            Insert dpmg;

            OppRequestEngagement.validateOpp(opp.Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void testRunAsSysAdmReadOnly() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator (Read Only)' LIMIT 1]; 
        User u = new User(Alias = 'tooiyr', Email='standardtestusersfdc@force.com', 
                          EmailEncodingKey='UTF-8', LastName='TestUserQADEV', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@force.com');  
        insert u;    
        
        Test.StartTest();
        System.debug('query at test start : >>>'+Limits.getQueries());
        Account accObj = [SELECT Id, OwnerId, Name FROM Account LIMIT 1];
        accObj.OwnerId=u.id;
        update accObj;     
       
        Contact conObj =[SELECT Id,Name,OwnerId,User__c FROM Contact LIMIT 1];
        conObj.OwnerId=u.Id;
        conObj.User__c =u.Id;
        update conObj;
        
        Opportunity__c opp  = [SELECT Id, Name, OwnerId FROM Opportunity__c LIMIT 1];  
        opp.OwnerId= u.id;
        update opp;      
        
       // Opportunity_Internal_Team__c  oitObj =[SELECT Id, OwnerId, Name FROM Opportunity_Internal_Team__c LIMIT 1];
      //  oitObj.OwnerId =u.Id;
      //  update oitObj;
        
        System.runAs(u) {   
            
            Delegate_Public_Group__c dpg = new Delegate_Public_Group__c();
            dpg.Banker__c = u.Id;
            insert dpg;            
            Delegate_Public_Group_Member__c dpmg = new Delegate_Public_Group_Member__c();
            dpmg.Delegate__c=u.id;
            dpmg.Delegate_Public_Group__c =dpg.Id;
            Insert dpmg;
            
            //con.RequestEngamentNumberValidation();   
            OppRequestEngagement.validateOpp(opp.Id);
            test.stopTest();
        }
    }
    
    @isTest
    public static void testRunAsSysAdmReadOnly3() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator (Read Only)' LIMIT 1]; 
        User u = new User(Alias = 'tooiyr', Email='standardtestusersfdc@force.com', 
                          EmailEncodingKey='UTF-8', LastName='TestUserQADEV', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@force.com');  
        insert u;       
        
        test.StartTest();
        System.debug('query at test start : >>>'+Limits.getQueries());
        Account accObj = [SELECT Id, OwnerId, Name FROM Account LIMIT 1];
        accObj.OwnerId=u.id;
        update accObj;     
        
        Contact conObj =[SELECT Id,Name,OwnerId,User__c FROM Contact LIMIT 1];
        conObj.OwnerId=u.Id;
        conObj.User__c =u.Id;
        update conObj;
                
        Opportunity__c opportunity1 =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity1.Name='Test Opportunity';
        opportunity1.Client__c = accObj.Id;
        opportunity1.Subject__c = accObj.Id;
        opportunity1.Primary_External_Contact__c = conObj.Id;
        opportunity1.Stage__c = 'Pitched';
        opportunity1.Line_of_Business__c = 'FVA';
        opportunity1.Job_Type__c = 'Solvency';
        opportunity1.Primary_Office__c = 'AT';
        opportunity1.Client_Description__c =  'Test Client desc';
        opportunity1.LegalAdvisorCompany__c = 'No';
        opportunity1.LegalAdvisorCreditor__c = 'No';
        opportunity1.Total_Debt_HL_represents_MM__c = 10002;
        opportunity1.CompanyEUSecurities__c = 'YES';
        opportunity1.TotalDebtMMConfirmed__c = TRUE;
        opportunity1.Estimated_Close_Date__c = Date.newinstance(2018,09,06);
        opportunity1.Tail_Expires__c = Date.newinstance(2018,09,06);
        opportunity1.Valuation_Date__c = Date.newInstance(2018,09,10);
        opportunity1.ProgressMonthly_Fee__c = 18;
        opportunity1.Contingent_Fee__c = 20;
        opportunity1.Discretionary_Fee__c = 30;
        opportunity1.Fee__c = 10001;
        opportunity1.NBC_Approved__c = True;
        opportunity1.Estimated_Transaction_Size_MM__c = 25;
        opportunity1.Fairness_Opinion_Component__c = 'No';
        opportunity1.OwnerId= u.id;
        
        insert opportunity1; 
        
      //  Opportunity_Internal_Team__c  oitObj =[SELECT Id, OwnerId, Name FROM Opportunity_Internal_Team__c LIMIT 1];
       // oitObj.OwnerId =u.Id;
      //  update oitObj;
       
        
        System.runAs(u) {   
            //test.startTest(); 
            Delegate_Public_Group__c dpg = new Delegate_Public_Group__c();
            dpg.Banker__c = u.Id;
            insert dpg;            
            Delegate_Public_Group_Member__c dpmg = new Delegate_Public_Group_Member__c();
            dpmg.Delegate__c=u.id;
            dpmg.Delegate_Public_Group__c =dpg.Id;
            Insert dpmg;
            
            //con.RequestEngamentNumberValidation();  
            //con.reload();   
            //Boolean Result = con.OnOIT;
            //Boolean Result2 = con.isValidForVP;   
            //con.submitApprovalRequest(opportunity1);
            OppRequestEngagement.validateOpp(opportunity1.Id);
            test.stopTest();
            
        }
    }
   
    @isTest
    public static void testRunAsSysAdmReadOnly4() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; 
        User u = new User(Alias = 'tooiyr', Email='standardtestusersfdc@force.com', 
                          EmailEncodingKey='UTF-8', LastName='TestUserQADEV', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@force.com');  
        insert u;       
        
        test.StartTest();
        System.debug('query at test start : >>>'+Limits.getQueries());
        Account accObj = [SELECT Id, OwnerId, Name FROM Account LIMIT 1];
        accObj.OwnerId=u.id;
        accObj.BillingStreet = 'Willium ford';
        accObj.BillingCity = 'New York';
        accObj.BillingPostalCode = '560037';
        accObj.BillingCountry = 'United States';
        update accObj;     
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
        Contact conObj =[SELECT Id,Name,OwnerId,User__c FROM Contact LIMIT 1];
        conObj.OwnerId=u.Id;
        conObj.User__c =u.Id;
        conObj.RecordTypeId = conRecordTypeId;
        update conObj;
        
        SIC_Code__c Sic = new SIC_Code__c();
        Sic.Name = '1021';
        insert Sic;  
        
        Legal_Entity__c legEntity = new Legal_Entity__c();
        legEntity.Name = 'HL Capital, Inc.';
        insert legEntity;
           
        Opportunity__c opportunity1 =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);        
        opportunity1.Confidentiality_Agreement__c = 'Test';
        opportunity1.Conflicts_Check_Outcome__c = 'Cleared';
        opportunity1.Engagement_Team_Assembled__c = True;
        opportunity1.Client_Ownership__c = 'Bank';
        opportunity1.Subject_Company_Ownership__c = 'Bank';
        opportunity1.Date_Engaged__c = Date.newinstance(2020,04,01);
        opportunity1.SIC_Code__c = Sic.Id;
        opportunity1.Retainer__c = 100;
        opportunity1.Opportunity_Description__c = 'test opp description';
        opportunity1.Referral_Type__c = 'Website';
        opportunity1.Referral_Contact__c = conObj.Id;        
        opportunity1.Conflicts_Check_Outcome_Date__c = Date.newinstance(2020,04,04);        
        opportunity1.Conflicts_Bypass__c = True;
        opportunity1.Name='Test Opportunity';
        opportunity1.Client__c = accObj.Id;
        opportunity1.Subject__c = accObj.Id;
        opportunity1.Women_Led__c='Yes';
        opportunity1.Primary_External_Contact__c = conObj.Id;
        opportunity1.Stage__c = 'High';
        opportunity1.Line_of_Business__c = 'FR';
        opportunity1.Client_Description__c =  'Test Client desc';
        opportunity1.LegalAdvisorCompany__c = 'YES';
        opportunity1.LegalAdvisorCreditor__c = 'YES';
        opportunity1.Job_Type__c = 'Equity Advisors';
        opportunity1.Primary_Office__c = 'NY';
        opportunity1.Total_Debt_HL_represents_MM__c = 100;
        opportunity1.CompanyEUSecurities__c = 'YES';
        opportunity1.TotalDebtMMConfirmed__c = TRUE;
        opportunity1.Estimated_Close_Date__c = Date.newinstance(2018,09,06);
        opportunity1.Tail_Expires__c = Date.newinstance(2018,09,06);
        opportunity1.Valuation_Date__c = Date.newInstance(2018,09,10);
        opportunity1.ProgressMonthly_Fee__c = 18;
        opportunity1.Contingent_Fee__c = 20;
        opportunity1.Discretionary_Fee__c = 30;
        opportunity1.Fee__c = 10001;
        opportunity1.NBC_Approved__c = True;
        opportunity1.Estimated_Transaction_Size_MM__c = 25;
        opportunity1.Fairness_Opinion_Component__c = 'No';
        opportunity1.Legal_Entity__c = legEntity.Id;
        opportunity1.OwnerId =u.Id;
        
        insert opportunity1; 
        
      //  Opportunity_Internal_Team__c  oitObj =[SELECT Id, OwnerId, Name FROM Opportunity_Internal_Team__c LIMIT 1];
      //  oitObj.OwnerId =u.Id;
       // update oitObj;
        
      
        
        System.runAs(u) {   
            //test.startTest(); 
            Delegate_Public_Group__c dpg = new Delegate_Public_Group__c();
            dpg.Banker__c = u.Id;
            insert dpg;            
            Delegate_Public_Group_Member__c dpmg = new Delegate_Public_Group_Member__c();
            dpmg.Delegate__c=u.id;
            dpmg.Delegate_Public_Group__c =dpg.Id;
            Insert dpmg;
            
            //con.RequestEngamentNumberValidation(); 
            //HL_OpportunityViewController.VerifyUserforVP(opportunity1,'test');
            //con.reload();   
            //Boolean Result = con.OnOIT;
            //Boolean Result2 = con.isValidForVP;  
            OppRequestEngagement.validateOpp(opportunity1.Id);
            test.stopTest();
            
        }
    }
}