@isTest
private class Test_HL_CampaignMemberHandler {
     @isTest private static void TestInsertWithOneCampaignMember(){
        //Test data setup
        Campaign childCampaign = CreateThreeTieredCampaign();
        Contact c = SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert c;
        CampaignMember cmToInsert = New CampaignMember(CampaignId = childCampaign.Id, ContactId = c.Id);
        
        //Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(cmToInsert);
        Test.stopTest();
        
        //Verify the Campaign Member was Inserted into the Parent
        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:childCampaign.ParentId AND ContactId=:cmToInsert.ContactId];
        System.Assert(result.isSuccess());
        System.Assert(cm.size() == 1);
    }
    
     @isTest private static void TestInsertWithOneCampaignMemberLead(){
        //Test data setup
        Campaign childCampaign = CreateThreeTieredCampaign();       
        Lead testLead = new Lead(FirstName='TestLead_1', LastName='TestLead_1', Company='TestLeadCompany_1');
        insert testLead;
        CampaignMember cmToInsert = New CampaignMember(CampaignId = childCampaign.Id, LeadId = testLead.Id);
        
        //Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(cmToInsert);
        Test.stopTest();
        
        //Verify the Campaign Member was Inserted into the Parent
        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:childCampaign.ParentId AND LeadId=:cmToInsert.LeadId];
        System.Assert(result.isSuccess());
        System.Assert(cm.size() == 1);
    }
   
    @isTest private static void TestInsertWithExistingParentCampaignMembers(){
        //Test data setup
        Campaign childCampaign = CreateThreeTieredCampaign(); 
        //Create Contacts
        List<Contact> contacts = SL_TestSetupUtils.CreateContact('',2,SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT);
        insert contacts;
        //Create Leads
        List<Lead> leads = New List<Lead> {new Lead(FirstName='TestLead_1', LastName='TestLead_1', Company='TestLeadCompany_1'), new Lead(FirstName='TestLead_2', LastName='TestLead_2', Company='TestLeadCompany_2')};
        insert leads;
        //Parent Campaign Members to Insert
        List<CampaignMember> cmInserts = new List<CampaignMember>();
        
        //Create some existing MemberStatus Records on the Parent Campaign
        List<CampaignMemberStatus> cmStatus = new List<CampaignMemberStatus>();
        cmStatus.Add(New CampaignMemberStatus(CampaignId = childCampaign.ParentId, Label = 'TestStatus1', SortOrder=100, HasResponded = false));
        cmStatus.Add(New CampaignMemberStatus(CampaignId = childCampaign.ParentId, Label = 'TestStatus2', SortOrder=101, HasResponded = false));     
        insert cmStatus;
        
        for(Contact c:contacts)
            cmInserts.Add(New CampaignMember(CampaignId = childCampaign.ParentId, ContactId = c.Id, Status = 'Sent'));
        for(Lead l:leads)
            cmInserts.Add(New CampaignMember(CampaignId = childCampaign.ParentId, LeadId = l.id, Status='Responded'));
        
       insert cmInserts;   
        cmInserts = new List<CampaignMember>();
        cmInserts.Add(New CampaignMember(CampaignId = childCampaign.Id, ContactId = contacts[0].id, Status = 'TestStatus1'));
        cmInserts.Add(New CampaignMember(CampaignId = childCampaign.Id, LeadId = leads[0].id, Status='NewStatus'));
        
        //Perform test
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(cmInserts);
        Test.stopTest();
        
        for(Database.SaveResult result: results)
            System.Assert(result.isSuccess());
            
            
            //To Cover update part of Trigger
  for(CampaignMember objMem : cmInserts)
  {
objMem.Status = 'Responded';
  }
  
  update cmInserts;
    }
    
     @isTest private static void TestInsertWithCampaignMemberNewStatus(){
        //Test data setup
        Campaign childCampaign = CreateThreeTieredCampaign();
        Contact testContact =  SL_TestSetupUtils.CreateContact('',1,SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT)[0];
        insert testContact;
        CampaignMember cmToInsert = New CampaignMember(CampaignId = childCampaign.Id, ContactId = testContact.Id, Status = 'TestStatus');
        
        //Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(cmToInsert);
        Test.stopTest();
        
        //Verify the Campaign Member was Inserted into the Parent
        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:childCampaign.ParentId AND ContactId=:cmToInsert.ContactId];
        System.Assert(result.isSuccess());
        System.Assert(cm.size() == 1);
    }

    @isTest private static void TestInsertWithMultipleCampaignMembers(){
        //Test data setup
        Integer newMembers = 2;
        Campaign childCampaign = CreateThreeTieredCampaign();
        List<Contact> testContacts = SL_TestSetupUtils.CreateContact('', newMembers, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT);
        insert testContacts;
        List<CampaignMember> cmToInsert = New List<CampaignMember>();
        for(Contact c:testContacts)
            cmToInsert.Add(New CampaignMember(CampaignId = childCampaign.Id, ContactId = c.Id, Status='Sent'));

        //Perform test
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(cmToInsert);
        Test.stopTest();
        
        //Verify the Campaign Members were Inserted into the Parent
        List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:childCampaign.ParentId];
        System.Assert(cm.size() == newMembers);
    }
    
    @isTest private static Campaign CreateThreeTieredCampaign(){
        Campaign campaign = SL_TestSetupUtils.CreateCampaign('',1)[0]; 
        insert campaign;
        Campaign subCampaign = SL_TestSetupUtils.CreateCampaign('',1)[0];
        subCampaign.ParentId = campaign.Id;
        insert subCampaign;
        Campaign childCampaign = SL_TestSetupUtils.CreateCampaign('',1)[0];
        childCampaign.ParentId = subCampaign.Id;
        insert childCampaign;
        return childCampaign;
    }
 
 @isTest private static void TestInsertWithFiveCampaignMember(){
     //Test data setup
      Integer newMembers = 4;
      Campaign childCampaign = CreateThreeTieredCampaign();
      List<Contact> testContacts = SL_TestSetupUtils.CreateContact('', newMembers, SL_TestSetupUtils.ContactType.EXTERNAL_CONTACT);
      insert testContacts;
      List<CampaignMember> cmToInsert = New List<CampaignMember>();
      for(Contact c:testContacts)
          cmToInsert.Add(New CampaignMember(CampaignId = childCampaign.Id, ContactId = c.Id, Status='Sent'));

      //Perform test
      Test.startTest();
      List<Database.SaveResult> results = Database.insert(cmToInsert);
      Test.stopTest();
      
      //Verify the Campaign Members were Inserted into the Parent
      List<CampaignMember> cm = [SELECT Id FROM CampaignMember WHERE CampaignId=:childCampaign.ParentId];
      //System.Assert(cm.size() == newMembers);
  
       
            //To Cover update part of Trigger
  for(CampaignMember objMem : cmToInsert)
  {
objMem.Status = 'Responded';
  }
  
  update cmToInsert;
    }
}