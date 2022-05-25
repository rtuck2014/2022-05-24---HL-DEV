@IsTest
private class HLSectorDependentPicklistTest {
    @IsTest
    static void myUnitTest(){
        List<HLSectorDependentPicklist.wrapper> ctList = HLSectorDependentPicklist.getCoverageType();
        
        List<HLSectorDependentPicklist.wrapper> primaryList = HLSectorDependentPicklist.getPrimaryCoverage(ctList.get(0).value);
        
        List<HLSectorDependentPicklist.wrapper> secondaryList = HLSectorDependentPicklist.getSecondaryCoverage(ctList.get(0).value,primaryList.get(0).value);
        
        List<HLSectorDependentPicklist.wrapper> tertiaryList = HLSectorDependentPicklist.getTertiaryCoverage(ctList.get(0).value,primaryList.get(0).value,secondaryList.get(0).value);
    }
    @TestSetup
    static void setupData(){
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
    }
}