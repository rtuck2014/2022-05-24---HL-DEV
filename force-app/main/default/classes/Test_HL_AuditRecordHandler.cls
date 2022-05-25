@isTest
private class Test_HL_AuditRecordHandler {
    @isTest
    private static void TestBatchAccountUpdateAudit() {
        integer recordSize = 20;
        integer auditRecordCount = 0;
        List<Account> aList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, recordSize);
        system.debug('>>>' +aList);
        insert aList;

        //Check for String and/or Double Fields as Samples
        for (integer i = 0; i < recordSize; i++) {
            for (FieldSetMember fsm : SObjectType.Account.FieldSets.Audit_Record_Fields.getFields()) {
                if (fsm.getType() == Schema.DisplayType.STRING) {
                    if (aList[i].get(fsm.getFieldPath()) == null) {
                        try {
                            aList[i].put(fsm.getFieldPath(), String.valueOf(i));
                            //Added as part of State/Country Picklist
                            aList[i].BillingCountry = 'United States';
                            aList[i].BillingState = 'California';
                            
                            system.debug('>>>>' +fsm.getFieldPath() );
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
                else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                    if (aList[i].get(fsm.getFieldPath()) == null) {
                        try {
                            aList[i].put(fsm.getFieldPath(), 1);
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
            }
        }

        Test.startTest();

        update aList;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestAccountUpdateAudit() {
        integer auditRecordCount = 0;
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Account.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (a.get(fsm.getFieldPath()) == null) {
                    try {
                        a.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (a.get(fsm.getFieldPath()) == null) {
                    try {
                        a.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();
        //Added as part of State/Country Picklist
        a.BillingCountry = 'United States';
        a.BillingState = 'California';
        update a;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestAccountDeleteAudit() {
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        insert a;

        Test.startTest();

        delete a;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestBidUpdateAudit() {
        integer auditRecordCount = 0;
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        Bid__c b = (Bid__c)HL_TestFactory.CreateSObject('Bid__c', false);
        insert a;
        insert e;
        ec.Company__c = a.Id;
        ec.Engagement__c = e.ID;
        insert ec;
        b.Engagement_Counterparty__c = ec.Id;
        insert b;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Bid__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (b.get(fsm.getFieldPath()) == null) {
                    try {
                        b.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (b.get(fsm.getFieldPath()) == null) {
                    try {
                        b.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update b;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestBidDeleteAudit() {
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        Bid__c b = (Bid__c)HL_TestFactory.CreateSObject('Bid__c', false);
        insert a;
        insert e;
        ec.Company__c = a.Id;
        ec.Engagement__c = e.ID;
        insert ec;
        b.Engagement_Counterparty__c = ec.Id;
        insert b;

        Test.startTest();

        delete b;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestBatchCampaignMemberUpdateAudit() {
        integer auditRecordCount = 0;
        integer recordSize = 4;
        Campaign campaign = HL_TestFactory.CreateCampaign(false);
        List<CampaignMember> cmList = (List<CampaignMember>)HL_TestFactory.CreateSObjectList('CampaignMember', false, recordSize);
        List<Contact> contactList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, recordSize);
        insert campaign;
        insert contactList;
        for (integer i = 0; i < recordSize; i++) {
            cmList[i].CampaignId = campaign.Id;
            cmList[i].ContactId = contactList[i].Id;
        }

        insert cmList;

        //Check for String and/or Double Fields as Samples
        for (integer i = 0; i < recordSize; i++) {
            for (FieldSetMember fsm : SObjectType.CampaignMember.FieldSets.Audit_Record_Fields.getFields()) {
                if (fsm.getType() == Schema.DisplayType.STRING) {
                    if (cmList[i].get(fsm.getFieldPath()) == null) {
                        try {
                            cmList[i].put(fsm.getFieldPath(), 'A');
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
                else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                    if (cmList[i].get(fsm.getFieldPath()) == null) {
                        try {
                            cmList[i].put(fsm.getFieldPath(), 1);
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
                else if (fsm.getType() == Schema.DisplayType.Date) {
                    if (cmList[i].get(fsm.getFieldPath()) == null) {
                        try {
                            cmList[i].put(fsm.getFieldPath(), Date.today());
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
            }
        }

        Test.startTest();

        update cmList;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestCampaignMemberUpdateAudit() {
        integer auditRecordCount = 0;
        Campaign campaign = HL_TestFactory.CreateCampaign(false);
        CampaignMember cm = (CampaignMember)HL_TestFactory.CreateSObject('CampaignMember', false);
        Contact contact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact,false);
        insert campaign;
        insert contact;
        cm.CampaignId = campaign.Id;
        cm.ContactId = contact.Id;
        insert cm;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.CampaignMember.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (cm.get(fsm.getFieldPath()) == null) {
                    try {
                        cm.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (cm.get(fsm.getFieldPath()) == null) {
                    try {
                        cm.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.Date) {
                if (cm.get(fsm.getFieldPath()) == null) {
                    try {
                        cm.put(fsm.getFieldPath(), Date.today());
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update cm;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestCampaignMemberDeleteAudit() {
        Campaign campaign = HL_TestFactory.CreateCampaign(false);
        CampaignMember cm = (CampaignMember)HL_TestFactory.CreateSObject('CampaignMember', false);
        Contact contact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert campaign;
        insert contact;
        cm.CampaignId = campaign.Id;
        cm.ContactId = contact.Id;
        insert cm;

        Test.startTest();

        delete cm;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestBatchContactUpdateAudit() {
        integer recordSize = 20;
        integer auditRecordCount = 0;
        List<Contact> cList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.External_Contact, false, recordSize);
        insert cList;

        //Check for String and/or Double Fields as Samples
        for (Contact c : cList) {
            for (FieldSetMember fsm : SObjectType.Contact.FieldSets.Audit_Record_Fields.getFields()) {
                if (fsm.getType() == Schema.DisplayType.STRING) {
                    if (c.get(fsm.getFieldPath()) == null) {
                        try {
                            c.put(fsm.getFieldPath(), 'A');
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
                else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                    if (c.get(fsm.getFieldPath()) == null) {
                        try {
                            c.put(fsm.getFieldPath(), 1);
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
            }
        }

        Test.startTest();

        update cList;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() >= recordSize);
    }

    @isTest
    private static void TestContactUpdateAudit() {
        integer auditRecordCount = 0;
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert c;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Contact.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (c.get(fsm.getFieldPath()) == null) {
                    try {
                        c.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (c.get(fsm.getFieldPath()) == null) {
                    try {
                        c.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update c;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestContactDeleteAudit() {
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        insert c;

        Test.startTest();

        delete c;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestCoverageTeamUpdateAudit() {
        integer auditRecordCount = 0;
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        Contact contact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Coverage_Team__c ct = (Coverage_Team__c)HL_TestFactory.CreateSObject('Coverage_Team__c', false);
        insert a;
        insert contact;
        ct.Officer__c = contact.Id;
        ct.Company__c = a.Id;
        insert ct;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Coverage_Team__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (ct.get(fsm.getFieldPath()) == null) {
                    try {
                        ct.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (ct.get(fsm.getFieldPath()) == null) {
                    try {
                        ct.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update ct;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestCoverageTeamDeleteAudit() {
        Account a = (Account)HL_TestFactory.CreateSObject('Account', false);
        Contact contact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Coverage_Team__c ct = (Coverage_Team__c)HL_TestFactory.CreateSObject('Coverage_Team__c', false);
        insert a;
        insert contact;
        ct.Officer__c = contact.Id;
        ct.Company__c = a.Id;
        insert ct;

        Test.startTest();

        delete ct;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }
/*
    @isTest
    private static void TestEngagementUpdateAudit() {
        integer auditRecordCount = 0;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Opportunity__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (e.get(fsm.getFieldPath()) == null) {
                    try {
                        e.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (e.get(fsm.getFieldPath()) == null) {
                    try {
                        e.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update e;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }
*/
    @isTest
    private static void TestEngagementDeleteAudit() {
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;

        Test.startTest();

        delete e;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEngagementCounterpartyUpdateAudit() {
        integer auditRecordCount = 0;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        insert e;
        ec.Engagement__c = e.Id;
        insert ec;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Engagement_Counterparty__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (ec.get(fsm.getFieldPath()) == null) {
                    try {
                        ec.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (ec.get(fsm.getFieldPath()) == null) {
                    try {
                        ec.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update ec;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEngagementCounterpartyDeleteAudit() {
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_Counterparty__c ec = (Engagement_Counterparty__c)HL_TestFactory.CreateSObject('Engagement_Counterparty__c', false);
        insert e;
        ec.Engagement__c = e.Id;
        insert ec;

        Test.startTest();

        delete ec;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEngagementExternalTeamUpdateAudit() {
        integer auditRecordCount = 0;
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_External_Team__c eet = (Engagement_External_Team__c)HL_TestFactory.CreateSObject('Engagement_External_Team__c', false);
        insert c;
        insert e;
        eet.Engagement__c = e.Id;
        eet.Contact__c = c.Id;

        insert eet;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Engagement_External_Team__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (eet.get(fsm.getFieldPath()) == null) {
                    try {
                        eet.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (eet.get(fsm.getFieldPath()) == null) {
                    try {
                        eet.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update eet;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEngagementExternalTeamDeleteAudit() {
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_External_Team__c eet = (Engagement_External_Team__c)HL_TestFactory.CreateSObject('Engagement_External_Team__c', false);
        insert c;
        insert e;
        eet.Engagement__c = e.Id;
        eet.Contact__c = c.Id;
        insert eet;

        Test.startTest();

        delete eet;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestBatchEngagementInternalTeamUpdateAudit() {
        integer recordSize = 20;
        integer auditRecordCount = 0;
        List<Contact> cList = HL_TestFactory.CreateContactList(HL_TestFactory.ContactRecordType.Houlihan_Employee, false, recordSize);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        List<Engagement_Internal_Team__c> eitList = (List<Engagement_Internal_Team__c>)HL_TestFactory.CreateSObjectList('Engagement_Internal_Team__c', false, recordSize);
        insert e;
        insert cList;
        for (Integer i = 0; i < recordSize; i++) {
            eitList[i].Contact__c = cList[i].Id;
            eitList[i].Engagement__c = e.Id;
        }
        insert eitList;

        //Check for String and/or Double Fields as Samples
        for (Engagement_Internal_Team__c eit : eitList) {
            for (FieldSetMember fsm : SObjectType.Engagement_Internal_Team__c.FieldSets.Audit_Record_Fields.getFields()) {
                if (fsm.getType() == Schema.DisplayType.STRING) {
                    if (eit.get(fsm.getFieldPath()) == null) {
                        try {
                            eit.put(fsm.getFieldPath(), 'A');
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
                else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                    if (eit.get(fsm.getFieldPath()) == null) {
                        try {
                            eit.put(fsm.getFieldPath(), 1);
                            auditRecordCount++;
                        }
                        catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                    }
                }
            }
        }

        Test.startTest();

        update eitList;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() >= recordSize);
    }

    @isTest
    private static void TestEngagementInternalTeamUpdateAudit() {
        integer auditRecordCount = 0;
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_Internal_Team__c eit = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c', false);
        insert c;
        insert e;
        eit.Engagement__c = e.Id;
        eit.Contact__c = c.Id;
        insert eit;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Engagement_Internal_Team__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (eit.get(fsm.getFieldPath()) == null) {
                    try {
                        eit.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (eit.get(fsm.getFieldPath()) == null) {
                    try {
                        eit.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update eit;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEngagementInternalTeamDeleteAudit() {
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        Engagement_Internal_Team__c eit = (Engagement_Internal_Team__c)HL_TestFactory.CreateSObject('Engagement_Internal_Team__c', false);
        insert c;
        insert e;
        eit.Contact__c = c.Id;
        eit.Engagement__c = e.Id;
        insert eit;

        Test.startTest();

        delete eit;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEventUpdateAudit() {
        integer auditRecordCount = 0;
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Event e = (Event)HL_TestFactory.CreateSObject('Event', false);
        insert c;
        e.StartDateTime = System.now();
        e.EndDateTime = e.StartDateTime;
        e.Start_Date__c = System.today();
        e.Start_Time__c = '12:00 AM';
        e.End_Date__c = System.today();
        e.End_Time__c = '12:00 AM';
        e.DurationInMinutes = 0;
        e.WhoId = c.Id;
        insert e;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Event.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (e.get(fsm.getFieldPath()) == null) {
                    try {
                        e.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (e.get(fsm.getFieldPath()) == null) {
                    try {
                        e.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update e;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestEventDeleteAudit() {
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Event e = (Event)HL_TestFactory.CreateSObject('Event', false);
        insert c;
        e.StartDateTime = System.now();
        e.EndDateTime = e.StartDateTime;
        e.Start_Date__c = System.today();
        e.Start_Time__c = '12:00 AM';
        e.End_Date__c = System.today();
        e.End_Time__c = '12:00 AM';
        e.DurationInMinutes = 0;
        e.WhoId = c.Id;
        insert e;

        Test.startTest();

        delete e;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestFSEngagementUpdateAudit() {
        integer auditRecordCount = 0;
        CapIQ_Company__c a = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        FS_Engagement__c fsEngagement = (FS_Engagement__c)HL_TestFactory.CreateSObject('FS_Engagement__c', false);
        insert a;
        insert e;
        fsEngagement.Company__c = a.Id;
        fsEngagement.Engagement__c = e.Id;
        insert fsEngagement;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.FS_Engagement__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (fsEngagement.get(fsm.getFieldPath()) == null) {
                    try {
                        fsEngagement.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (fsEngagement.get(fsm.getFieldPath()) == null) {
                    try {
                        fsEngagement.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update fsEngagement;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestFSEngagementDeleteAudit() {
        CapIQ_Company__c a = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        FS_Engagement__c fsEngagement = (FS_Engagement__c)HL_TestFactory.CreateSObject('FS_Engagement__c', false);
        insert a;
        insert e;
        fsEngagement.Company__c = a.Id;
        fsEngagement.Engagement__c = e.Id;
        insert fsEngagement;

        Test.startTest();

        delete fsEngagement;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestFSOpportunityUpdateAudit() {
        integer auditRecordCount = 0;
        CapIQ_Company__c a = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        FS_Opp__c fsOpp = (FS_Opp__c)HL_TestFactory.CreateSObject('FS_Opp__c', false);
        insert a;
        insert o;
        fsOpp.Company__c = a.Id;
        fsOpp.Opportunity__c = o.Id;
        insert fsOpp;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.FS_Opp__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (fsOpp.get(fsm.getFieldPath()) == null) {
                    try {
                        fsOpp.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (fsOpp.get(fsm.getFieldPath()) == null) {
                    try {
                        fsOpp.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update fsOpp;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestFSOpportunityDeleteAudit() {
        CapIQ_Company__c a = (CapIQ_Company__c)HL_TestFactory.CreateSObject('CapIQ_Company__c', false);
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        FS_Opp__c fsOpp = (FS_Opp__c)HL_TestFactory.CreateSObject('FS_Opp__c', false);
        insert a;
        insert o;
        fsOpp.Company__c = a.Id;
        fsOpp.Opportunity__c = o.Id;
        insert fsOpp;

        Test.startTest();

        delete fsOpp;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityUpdateAudit() {
        integer auditRecordCount = 0;
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert o;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Opportunity__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (o.get(fsm.getFieldPath()) == null) {
                    try {
                        o.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (o.get(fsm.getFieldPath()) == null) {
                    try {
                        o.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update o;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityDeleteAudit() {
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        insert o;

        Test.startTest();

        delete o;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityCounterpartyUpdateAudit() {
        integer auditRecordCount = 0;
        Opportunity_Counterparty__c oc = (Opportunity_Counterparty__c)HL_TestFactory.CreateSObject('Opportunity_Counterparty__c', false);
        insert oc;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Opportunity_Counterparty__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (oc.get(fsm.getFieldPath()) == null) {
                    try {
                        oc.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (oc.get(fsm.getFieldPath()) == null) {
                    try {
                        oc.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.Date) {
                if (oc.get(fsm.getFieldPath()) == null) {
                    try {
                        oc.put(fsm.getFieldPath(), Date.today());
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update oc;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityCounterpartyDeleteAudit() {
        Opportunity_Counterparty__c oc = (Opportunity_Counterparty__c)HL_TestFactory.CreateSObject('Opportunity_Counterparty__c', false);
        insert oc;

        Test.startTest();

        delete oc;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityExternalTeamUpdateAudit() {
        integer auditRecordCount = 0;
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        Opportunity_External_Team__c oet = (Opportunity_External_Team__c)HL_TestFactory.CreateSObject('Opportunity_External_Team__c', false);
        insert c;
        insert o;
        oet.Contact__c = c.Id;
        oet.Opportunity__c = o.Id;
        insert oet;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Opportunity_External_Team__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (oet.get(fsm.getFieldPath()) == null) {
                    try {
                        oet.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (oet.get(fsm.getFieldPath()) == null) {
                    try {
                        oet.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update oet;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityExternalTeamDeleteAudit() {
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        Opportunity_External_Team__c oet = (Opportunity_External_Team__c)HL_TestFactory.CreateSObject('Opportunity_External_Team__c', false);
        insert c;
        insert o;
        oet.Contact__c = c.Id;
        oet.Opportunity__c = o.Id;
        insert oet;

        Test.startTest();

        delete oet;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityInternalTeamUpdateAudit() {
        integer auditRecordCount = 0;
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        Opportunity_Internal_Team__c oit = (Opportunity_Internal_Team__c)HL_TestFactory.CreateSObject('Opportunity_Internal_Team__c', false);
        insert c;
        insert o;
        oit.Contact__c = c.Id;
        oit.Opportunity__c = o.Id;
        insert oit;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Opportunity_Internal_Team__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (oit.get(fsm.getFieldPath()) == null) {
                    try {
                        oit.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (oit.get(fsm.getFieldPath()) == null) {
                    try {
                        oit.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update oit;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestOpportunityInternalTeamDeleteAudit() {
        Contact c = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Opportunity__c o = (Opportunity__c)HL_TestFactory.CreateSObject('Opportunity__c', false);
        Opportunity_Internal_Team__c oit = (Opportunity_Internal_Team__c)HL_TestFactory.CreateSObject('Opportunity_Internal_Team__c', false);
        insert c;
        insert o;
        oit.Contact__c = c.Id;
        oit.Opportunity__c = o.Id;
        insert oit;

        Test.startTest();

        delete oit;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestRelationshipUpdateAudit() {
        integer auditRecordCount = 0;
        Contact hlContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Contact externalContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Relationship__c r = (Relationship__c)HL_TestFactory.CreateSObject('Relationship__c', false);
        insert hlContact;
        insert externalContact;
        r.HL_Contact__c = hlContact.Id;
        r.External_Contact__c = externalContact.Id;
        insert r;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Relationship__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (r.get(fsm.getFieldPath()) == null) {
                    try {
                        r.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (r.get(fsm.getFieldPath()) == null) {
                    try {
                        r.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update r;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestRelationshipDeleteAudit() {
        Contact hlContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.Houlihan_Employee, false);
        Contact externalContact = HL_TestFactory.CreateContact(HL_TestFactory.ContactRecordType.External_Contact, false);
        Relationship__c r = (Relationship__c)HL_TestFactory.CreateSObject('Relationship__c', false);
        insert hlContact;
        insert externalContact;
        r.HL_Contact__c = hlContact.Id;
        r.External_Contact__c = externalContact.Id;
        insert r;

        Test.startTest();

        delete r;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestRevenueAccrualUpdateAudit() {

        integer auditRecordCount = 0;
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        insert new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE, Current_Month__c = String.valueOf(Date.Today().Month()), Current_Year__c = String.valueOf(Date.Today().Year()));
        Revenue_Accrual__c ra = (Revenue_Accrual__c)HL_TestFactory.CreateSObject('Revenue_Accrual__c', false);
        ra.Engagement__c = e.Id;
        insert ra;

        //Check for String and/or Double Fields as Samples
        for (FieldSetMember fsm : SObjectType.Revenue_Accrual__c.FieldSets.Audit_Record_Fields.getFields()) {
            if (fsm.getType() == Schema.DisplayType.STRING) {
                if (ra.get(fsm.getFieldPath()) == null) {
                    try {
                        ra.put(fsm.getFieldPath(), 'A');
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
            else if (fsm.getType() == Schema.DisplayType.DOUBLE) {
                if (ra.get(fsm.getFieldPath()) == null) {
                    try {
                        ra.put(fsm.getFieldPath(), 1);
                        auditRecordCount++;
                    }
                    catch (System.SObjectException ex) {} //Field Not Accessible/Editable
                }
            }
        }

        Test.startTest();

        update ra;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }

    @isTest
    private static void TestRevenueAccrualDeleteAudit() {
        Engagement__c e = HL_TestFactory.CreateEngagement(false);
        insert e;
        insert new Monthly_Revenue_Process_Control__c(IsCurrent__c = TRUE, Current_Month__c = String.valueOf(Date.Today().Month()), Current_Year__c = String.valueOf(Date.Today().Year()));
        Revenue_Accrual__c ra = (Revenue_Accrual__c)HL_TestFactory.CreateSObject('Revenue_Accrual__c', false);
        ra.Engagement__c = e.Id;
        insert ra;

        Test.startTest();

        delete ra;

        Test.stopTest();

        System.assert([SELECT Id FROM Audit_Record__c].size() > 0);
    }
}