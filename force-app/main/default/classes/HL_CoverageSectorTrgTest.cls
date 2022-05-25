@IsTest
private class HL_CoverageSectorTrgTest {
    @IsTest
    private static void myUnitTest(){
        CoverageSector__c cs = [SELECT Id,IsMain__c FROM CoverageSector__c WHERE IsMain__c=false];        
        try{
            Test.startTest();
            cs.IsMain__c=true;
            update cs;            
            Test.stopTest();
        }catch(Exception e){
            
        }
        try{
            delete cs;
        }catch(Exception e){
            
        }
    }
    @TestSetup
    private static void setupData(){
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
        List<Coverage_Sector_Dependency__c> csdList = new List<Coverage_Sector_Dependency__c>();
        csdList.add(new Coverage_Sector_Dependency__c(Active__c=true,CoverageType__c=svList.get(0).Id,PrimarySector__c=svList.get(1).Id,
                                                                             SecondarySector__c=svList.get(2).Id,TertiarySector__c=svList.get(3).Id));
        csdList.add(new Coverage_Sector_Dependency__c(Active__c=true,CoverageType__c=svList.get(4).Id,PrimarySector__c=svList.get(5).Id,
                                                                             SecondarySector__c=svList.get(6).Id,TertiarySector__c=svList.get(7).Id));
        insert csdList;
        
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
    }
}