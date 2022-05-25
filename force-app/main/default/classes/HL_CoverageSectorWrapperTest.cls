@IsTest
private class HL_CoverageSectorWrapperTest {
    @IsTest
    static void myUnitTest(){
        List<SectorValue__c> svList = new List<SectorValue__c>();
        svList.add(new SectorValue__c(Active__c=true,Value__c='A',UniqueKey__c='A',DependencyValue__c='Type'));
        svList.add(new SectorValue__c(Active__c=true,Value__c='B',UniqueKey__c='B',DependencyValue__c='Primary'));
        svList.add(new SectorValue__c(Active__c=true,Value__c='C',UniqueKey__c='C',DependencyValue__c='Secondary'));
        svList.add(new SectorValue__c(Active__c=true,Value__c='D',UniqueKey__c='D',DependencyValue__c='Tertiary'));
        
        svList.add(new SectorValue__c(Active__c=true,Value__c='E',UniqueKey__c='E',DependencyValue__c='Type'));
        svList.add(new SectorValue__c(Active__c=true,Value__c='F',UniqueKey__c='F',DependencyValue__c='Primary'));
        svList.add(new SectorValue__c(Active__c=true,Value__c='G',UniqueKey__c='G',DependencyValue__c='Secondary'));
        svList.add(new SectorValue__c(Active__c=true,Value__c='H',UniqueKey__c='H',DependencyValue__c='Tertiary'));
        insert svList;
        
        Account a = new Account(Name='Test');
        insert a;
        
        Contact c = new Contact(AccountId=a.Id,FirstName='Test',LastName='User',RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Houlihan_Employee').getRecordTypeId(),
                               Industry_Group__c='FS - Financial Sponsors');
        insert c;
        
        Coverage_Team__c ct = new Coverage_Team__c(Company__c=a.Id,Coverage_Level__c='Primary',Coverage_Type__c='Cannabis',Tier__c='A',Officer__c=c.Id,
                                                  RecordTypeId=Schema.SObjectType.Coverage_Team__c.getRecordTypeInfosByDeveloperName().get('Standard_Coverage_Team_Member').getRecordTypeId());
        insert ct;
        
        List<CoverageSector__c> csList = new List<CoverageSector__c>();
        csList.add(new CoverageSector__c(CoverageTeam__c=ct.Id,IsMain__c=true,CoverageType__c=svList.get(0).Id,PrimarySector__c=svList.get(1).Id,
                                                    SecondarySector__c=svList.get(2).Id,TertiarySector__c=svList.get(3).Id));        
        
        csList.add(new CoverageSector__c(CoverageTeam__c=ct.Id,IsMain__c=false,CoverageType__c=svList.get(4).Id,PrimarySector__c=svList.get(5).Id,
                                                    SecondarySector__c=svList.get(6).Id,TertiarySector__c=svList.get(7).Id));
        insert csList;
        
        HL_CoverageSectorWrapper wrapper = new HL_CoverageSectorWrapper(new ApexPages.StandardController(csList.get(0)));
        wrapper.newCoverageTeamId=ct.Id;
        wrapper.handleRedirect();
        
        wrapper = new HL_CoverageSectorWrapper(new ApexPages.StandardController(new CoverageSector__c(CoverageTeam__c=ct.Id)));
    }
}