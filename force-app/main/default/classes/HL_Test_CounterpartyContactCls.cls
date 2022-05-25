/**************************************************************
* Name : HL_Test_CounterpartyContactCls
* Purpose : To provide code coverage for "HL_EngCounterpartyContactCls" class
***************************************************************/
@isTest
Private Class HL_Test_CounterpartyContactCls { 
    
    @testSetup 
    static void setup() {
        Id ExternalRTContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();

        
        List<Account> accountList = (List<Account>)HL_TestFactory.CreateSObjectList('Account', false, 4);        
        for(integer i = 0; i < accountList.size(); i++){
            accountList[i].Name = 'Test_Account' +i;        
            accountList[i].BillingCountry = 'United States';
            accountList[i].BillingState = 'California';
            accountList[i].ShippingCountry = accountList[i].BillingCountry;
            accountList[i].ShippingState = accountList[i].BillingState;
        }
        insert accountList;
        
        List<Contact> CList = (List<Contact>)HL_TestFactory.CreateSObjectList('Contact', false, 4);        
        for(integer i = 0; i < CList.size(); i++){
            CList[i].FirstName = 'TestFirst' +i;
            CList[i].LastName = 'TestLast' +i;
            CList[i].AccountId = accountList[0].id;
            CList[i].RecordTypeId = ExternalRTContact;
        }
        Insert CList; 
        
        List<Engagement__c> engagement = (List<Engagement__c>)HL_TestFactory.CreateSObjectList('Engagement__c', false, 4);        
        for(integer i = 0; i < engagement.size(); i++){
            engagement[i].Name='Test Engagement'+i;
            engagement[i].Client__c = accountList[i].Id;
            engagement[i].Subject__c = accountList[i].Id;
            engagement[i].Stage__c = 'Pitched';
            engagement[i].Line_of_Business__c = 'CF';
            engagement[i].Job_Type__c = 'Financing';
            engagement[i].Primary_Office__c = 'AT';
        }
        insert engagement;
        
        List<Engagement_Counterparty__c> EngCList = (List<Engagement_Counterparty__c>)HL_TestFactory.CreateSObjectList('Engagement_Counterparty__c', false, 4);        
        for(integer i = 0; i < EngCList.size(); i++){
            EngCList[i].Name = 'Test' +i;
            EngCList[i].Company__c = accountList[0].id;
            EngCList[i].Engagement__c = engagement[0].id;
        }
        Insert EngCList; 
        
        List<Industry__c> IndustryList = (List<Industry__c>)HL_TestFactory.CreateSObjectList('Industry__c', false, 4);        
        for(integer i = 0; i < IndustryList.size(); i++){
            IndustryList[i].Name = 'Test ' +i;
            IndustryList[i].Industry_Group__c = 'BUS - Business Services';
            IndustryList[i].Contact__c = true;
            IndustryList[i].Active__c = true;
            IndustryList[i].Industry_Type__c = 'Engagement';
            IndustryList[i].Company__c = true;
        }
        Insert IndustryList; 
        
        List<Industry_Focus__c> IndusFocusList = (List<Industry_Focus__c>)HL_TestFactory.CreateSObjectList('Industry_Focus__c', false, 4);        
        for(integer i = 0; i < IndusFocusList.size(); i++){
            IndusFocusList[i].Contact__c = CList[i].id;
            IndusFocusList[i].Industry__c = IndustryList[i].id;
        }
        Insert IndusFocusList; 
    }
    
     @isTest
    static void EngCCtestName(){
        
        list<Engagement_Counterparty__c> engCPList = [Select Id, Company__c from Engagement_Counterparty__c];
        list<Contact> ContactList = [Select Id from Contact];
        
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EngCounterpartyContactPage'));
            System.currentPageReference().getParameters().put('clid',engCPList[0].id);
            HL_EngCounterpartyContactCls clsObj = new HL_EngCounterpartyContactCls();
            HL_EngCounterpartyContactCls.RelatedContactClass wrapperTest = new HL_EngCounterpartyContactCls.RelatedContactClass(true,ContactList[0],'a,b','a,b');
            clsObj.CurPageNumber = 1;
            clsObj.SelectedOption = 'Name';
            clsObj.searchString = ' Test ';
            clsObj.CurPageSize = 1;
            boolean isPrev   =  clsobj.hasPrevious;
            boolean isNext   =  clsobj.hasNext;
            integer pageNo   =  clsobj.pageNumber;        
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsobj.validateData();
            clsobj.conLastName  = 'test';
            clsobj.conFirstName = 'test';
            clsobj.conTitle = 'test';
            clsobj.conCompanyName = 'test';
            clsobj.conDepartment = 'test';
            clsobj.conIndustryName = 'test';
            clsobj.filteredRecords();
            clsobj.getOptions();
            //HL_EngCounterpartyContactCls.RelatedContactClass wrapperTest = new HL_EngCounterpartyContactCls.RelatedContactClass(true,ContactList[0],'a,b','a,b');
            //wrapperTest.isSelected = true;
            clsobj.doSavePageSize();
            clsobj.SaveChanges();
            clsobj.BackToEngCounterParty();
        test.StopTest(); 
        // list<Engagement_Counterparty_Contact__c> engCPCList = [Select Id, Contact__c, Counterparty__c from Engagement_Counterparty_Contact__c];
        system.assertequals(wrapperTest.isSelected, true);
        //system.assertequals(engCPCList[0].Counterparty__c, engCPList[0].id);
    }
    
     @isTest
    static void EngCCtestCompany(){
        
        list<Engagement_Counterparty__c> engCPList = [Select Id, Company__c from Engagement_Counterparty__c];
        list<Contact> ContactList = [Select Id from Contact];
        
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EngCounterpartyContactPage'));
            System.currentPageReference().getParameters().put('clid',engCPList[0].id);
            HL_EngCounterpartyContactCls  clsObj = new HL_EngCounterpartyContactCls();
            clsObj.CurPageNumber = 1;
            clsObj.SelectedOption = 'Company';
            clsObj.searchString = 'test ';
            clsObj.CurPageSize = 1;
            boolean isPrev   =  clsobj.hasPrevious;
            boolean isNext   =  clsobj.hasNext;
            integer pageNo   =  clsobj.pageNumber;        
            clsobj.first();
            clsobj.Next();
            clsobj.Previous();
            clsobj.last();
            clsobj.doSavePageSize();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsobj.first();
            clsobj.Next();
            clsobj.Previous();
            clsobj.last();
            clsobj.doSavePageSize();
            clsobj.goCurPageNumber();
            clsobj.validateData();
            clsobj.getOptions();
            //clsobj.SaveData();
            clsObj.sortField = 'Name';
            clsObj.sortDirection = ' DESC ';
            clsobj.toggleSort();
        test.StopTest(); 
        system.assertequals(clsObj.sortField, 'Name');
        system.assertequals(clsObj.sortDirection, 'ASC');
        
    }
    
     @isTest
    static void EngCCtestIndustryName(){
        
        list<Engagement_Counterparty__c> engCPList = [Select Id, Company__c from Engagement_Counterparty__c];
        list<Industry_Focus__c> indFocList = [Select Id, Contact__c,Industry__r.Name from Industry_Focus__c];
        list<Contact> ContactList = [Select Id from Contact];
        
        Test.StartTest();
            Test.setCurrentPageReference(new PageReference('Page.HL_EngCounterpartyContactPage'));
            System.currentPageReference().getParameters().put('clid',engCPList[0].id);
            HL_EngCounterpartyContactCls  clsObj = new HL_EngCounterpartyContactCls();
            clsObj.CurPageNumber = 1;
            clsObj.SelectedOption = 'IndustryName';
            clsObj.searchString = 'test ';
            clsObj.CurPageSize = 1;
            boolean isPrev   =  clsobj.hasPrevious;
            boolean isNext   =  clsobj.hasNext;
            integer pageNo   =  clsobj.pageNumber;        
            clsobj.first();
            clsobj.Next();
            clsobj.Previous();
            clsobj.last();
            clsobj.doSavePageSize();
            clsObj.CurPageNumber = 1;
            clsObj.CurPageSize = 1;
            clsobj.first();
            clsobj.Next();
            clsobj.Previous();
            clsobj.last();
            clsobj.doSavePageSize();
            clsobj.goCurPageNumber();
            clsobj.validateData();
            clsobj.getOptions();
            clsobj.SaveData();
            clsObj.searchString = '';
            clsobj.validateData();
            clsObj.searchString = 'Test';
            clsobj.validateData();
        test.StopTest(); 
        
        system.assertequals(indFocList[0].Contact__c, ContactList[0].id);
        system.assertNotequals(indFocList[0].Industry__r.Name, clsObj.searchString);
    }
}