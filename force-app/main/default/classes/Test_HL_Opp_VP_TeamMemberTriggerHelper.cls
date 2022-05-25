@isTest
Private Class Test_HL_Opp_VP_TeamMemberTriggerHelper {
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
    Static List<Opportunity_Internal_Team__c> oitList;
    Static List<Contact> conList ;
    @testSetup static void setup() {    
        List<User> usr = new List<User>();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = Test_HL_Opp_VP_TeamMemberTriggerHelper.createTestUser(pf.Id, 'Test FirstName', 'Test LastName');
        insert user1;
        usr.add(user1);
        User user2 = Test_HL_Opp_VP_TeamMemberTriggerHelper.createTestUser(pf.Id, 'Test FirstName2', 'Test LastName2');
        insert user2;
        usr.add(user2);
        List<Account> accList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 3);        
        for(integer i = 0; i < accList.size(); i++){
            accList[i].Name = 'Test_' + String.valueOf(i);        
            accList[i].BillingCountry = 'United States';
            accList[i].BillingState = 'California';
            accList[i].ShippingCountry = accList[i].BillingCountry;
            accList[i].ShippingState = accList[i].BillingState;      
        }
        insert accList;
        
        conList = SL_TestSetupUtils.CreateContact('Contact', 2, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE);
        for(integer i = 0; i < conList.size(); i++){
            conList[i].FirstName = 'DND Test';
            conList[i].LastName = 'Test LN';
            conList[i].AccountId = accList[0].Id;            
            conList[i].User__c = usr[i].Id;
        }
        insert conList;
        
        Job_Type__c JT = new Job_Type__c(Name = 'FA - Portfolio-Valuation', Is_Active__c = true, Is_Transactional__c = 'Yes', Job_Code__c = '232',Engagement_Record_Type__c = 'Portfolio_Valuation');
        insert JT; 
        
        Opportunity__c opportunity =(Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c',false);               
        opportunity.Name='Test Opportunity';
        opportunity.Client__c = accList[0].Id;
        opportunity.Subject__c = accList[0].Id;
        opportunity.Stage__c = 'Pitched';
        opportunity.Line_of_Business__c = 'FVA';
        opportunity.Job_Type__c = 'FA - Portfolio-Valuation';
        opportunity.Primary_Office__c = 'AT';
        insert opportunity;
        test.starttest();
        Opp_VP__c oppVP =(Opp_VP__c)HL_TestFactory.CreateSObject('Opp_VP__c',false);
        oppVP.Name='Test Opp Vp';        
        oppVp.Opportunity__c=opportunity.id;
        oppVP.Valuation_Date__c=System.Today();
        oppVp.CurrencyIsoCode='USD';        
        Insert oppVP; 
        
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        oppVPPos.Name=accList[0].Id;
        oppVPPos.Company__c=accList[0].Id;
        oppVPPos.Opportunity_VP__c=oppVP.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        insert oppVPPos;  
        
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
            oitList[i].End_Date__c = Date.today();
        }
        insert oitList; 
        
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = conList[i].User__c;
        }
        insert dpgList; 
        
        Delegate_Public_Group_Member__c DPGmember1 = new Delegate_Public_Group_Member__c();
        DPGmember1.Delegate__c = usr[0].id;
        DPGmember1.Delegate_Public_Group__c = dpgList[0].id;
        
        Delegate_Public_Group_Member__c DPGmember2 = new Delegate_Public_Group_Member__c();
        DPGmember2.Delegate__c = usr[1].id;
        DPGmember2.Delegate_Public_Group__c = dpgList[0].id;
               
        list<Delegate_Public_Group_Member__c> objDPGMemberlist = new list<Delegate_Public_Group_Member__c>(); 
        objDPGMemberlist.add(DPGmember1);       
        objDPGMemberlist.add(DPGmember2);  
        insert objDPGMemberlist;
        test.stopTest();
    }
 
    @isTest
    static void TestPopulatingPositionName2(){   
        // Testing scenario where user update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];
        Contact testCont = [SELECT Id,User__c FROM Contact LIMIT 1];
        User user = [SELECT Id, Name FROM User LIMIT 1];
        Opp_VP_Position__c oppObj1 =[SELECT Id FROM Opp_VP_Position__c ];
        List<Delegate_Public_Group_Member__c> dpgObj =[SELECT Id FROM Delegate_Public_Group_Member__c  LIMIT 2];
        Opp_VP_Position__c oppVPPos =(Opp_VP_Position__c)HL_TestFactory.CreateSObject('Opp_VP_Position__c',false);
        
        List<Opp_VP_TeamMember__c> oppVPTMList = new List<Opp_VP_TeamMember__c>();
        Opp_VP_TeamMember__c oppVPTM = new Opp_VP_TeamMember__c();
        oppVPTM.Opportunity_VP_Position__c = oppObj1.id; 
        oppVPTM.Staff__c = testCont.id;
        oppVPTM.Role__c = 'Analyst';
        oppVPTM.start_Date__c = Date.today();
        oppVPTMList.add(oppVPTM);
        
        Opp_VP_TeamMember__c oppVPTM1 = new Opp_VP_TeamMember__c();
        oppVPTM1.Opportunity_VP_Position__c = oppObj1.id; 
        oppVPTM1.Staff__c = testCont.id;
        oppVPTM1.Role__c = 'Analyst';
        oppVPTM1.start_Date__c = Date.today()+3;
        oppVPTMList.add(oppVPTM1);
        test.startTest();  
        try{
            insert oppVPTMList;
        }catch(Exception e)
        {
            String ErrorMsg = e.getmessage();
            system.assert(ErrorMsg.contains('Please update the time range or role as team members cannot overlap the same time frames with the same role'));
        }  
                
        dpgList = (List<Delegate_Public_Group__c>)HL_TestFactory.CreateSObjectList('Delegate_Public_Group__c', false, 1);
        for(integer i = 0; i < dpgList.size(); i++){
            dpgList[i].Banker__c = testCont.User__c;
        }
        insert dpgList; 
        
        oppVPPos.Company__c=accList2[0].Id;
        oppVPPos.Name=oppVPPos.Company__r.Name;
        oppVPPos.Opportunity_VP__c=oppObj.Id;
        oppVPPos.Report_Fee__c=100;
        oppVPPos.Asset_Classes__c='Debt';
        oppVPPos.CurrencyIsoCode='USD';
        oppVPPos.Status__c='In Progress';
        insert oppVPPos; 
        
        
        oppObj1.Status__c ='In Progress';
        
        update oppObj1;
        
        
        test.stopTest();     
        System.assertNOTEquals(null, oppObj1);
        System.assertNOTEquals(null, oppVPPos);    
    } 
    
    @isTest
    static void TestPopulatingPositionName3(){   
        // Testing scenario where user update existing from VP to roll up VP's status
        List<Account> accList2 = [SELECT Id,Name FROM Account ORDER BY Name DESC LIMIT 1];
        Opp_VP__c oppObj = [SELECT Id FROM Opp_VP__c LIMIT 1];
        Contact testCont = [SELECT Id,User__c FROM Contact LIMIT 1];
        User user = [SELECT Id, Name FROM User LIMIT 1];
        Opp_VP_Position__c oppObj1 =[SELECT Id FROM Opp_VP_Position__c ];
        Delegate_Public_Group__c dpgList1  = [SELECT Id FROM Delegate_Public_Group__c LIMIT 1];
        Delegate_Public_Group_Member__c dpgObj =[SELECT Id FROM Delegate_Public_Group_Member__c  LIMIT 1];
        test.startTest();
        Opportunity_Internal_Team__c oit =[SELECT Id FROM Opportunity_Internal_Team__c LIMIT 1];
        oit.End_Date__c = null;
               
         
        update oit;       
        Delegate_Public_Group_Member__c DPGmember1 = new Delegate_Public_Group_Member__c();
        DPGmember1.Delegate__c = user.id;
        DPGmember1.Delegate_Public_Group__c = dpgList1.id;
        insert DPGmember1;
        test.stopTest();     
    } 
}