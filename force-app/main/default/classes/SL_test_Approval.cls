/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The test class for SL_OpportunityApproval class
 */
@isTest
public class SL_test_Approval {
    
    @isTest static void test_PageStandard() {
        createData();

        SL_Approval controller;
        SL_Approval.ApprovalObjectNotFoundException exc;
        controller = new SL_Approval();
        system.assertEquals( null, controller.approvalObject ); 

        ApexPages.currentPage().getParameters().put( 'id', pOpportunityApproval.Id );
        controller = new SL_Approval();
        system.assertNotEquals( null, controller.pagination );
        system.assertEquals( 1, controller.pagination.getPage() );
        system.assert( !controller.sections.isEmpty() );

        system.assertEquals( null, controller.approvalObject.obj.get( 'Proposed_Fee_Range__c' ) );
        controller.approvalObject.obj.put( 'Proposed_Fee_Range__c', '111' );

        system.assertEquals( SL_test_ApprovalValidation.pApprovalPage.Name, controller.pagination.getPageName() );

        controller.Next();
        system.assertEquals( 2, controller.pagination.getPage() );
        controller.Previous();
        system.assertEquals( 1, controller.pagination.getPage() );
        system.assertEquals( '111', controller.approvalObject.obj.get( 'Proposed_Fee_Range__c' ) );
        controller.ChangePage();
        controller.Cancel();
        controller.getDependentPropertiesJSON();
    }

    @isTest static void test_PageRelatedList() {
        createData();

        ApexPages.currentPage().getParameters().put( 'id', pOpportunityApproval.Id );
        ApexPages.currentPage().getParameters().put( 'p', '2' );
        SL_Approval controller = new SL_Approval();

        system.assertEquals( 2, controller.pagination.getPage() );
        system.assert( !controller.relatedLists.isEmpty() );

        system.assertEquals( null, controller.relatedLists[0].wrappers[0].obj.get( 'EBIT_MM__c' ) );

        controller.relatedLists[0].wrappers[0].obj.put( 'EBIT_MM__c', 1.1 );
        controller.relatedLists[0].Save();
        system.assertEquals( 1.1, controller.relatedLists[0].wrappers[0].obj.get( 'EBIT_MM__c' ) );
        controller.relatedLists[0].Next();
        controller.relatedLists[0].Previous();
        controller.relatedLists[0].AddRow();
        controller.relatedLists[0].wrappers[1].obj.put( 'EBIT_MM__c', 2.1 );
        controller.relatedLists[0].wrappers[1].obj.put( 'EBITDA__c', 2.2 );
        controller.relatedLists[0].wrappers[1].obj.put( 'Related_Account__c', pAccount.Id );
        controller.Save();
        controller.relatedLists[0].selected = true;
        controller.relatedLists[0].selectAllRecords();
        system.assert( !controller.relatedLists[0].wrappers.isEmpty() );
        controller.relatedLists[0].RemoveRows();
        system.assert( controller.relatedLists[0].wrappers.isEmpty() );
        controller.relatedLists[0].Cancel();
        controller.relatedLists[0].sortBy = 'EBITDA__c';
        controller.relatedLists[0].refreshRecordsAndPage();
    }

    @isTest static void test_DependentProperties_unit() {
        createData();

        SL_Approval.DependentProperties dependentProperties = new SL_Approval.DependentProperties( pOpportunityApproval.Id.getSObjectType(), SL_test_ApprovalValidation.pApprovalPage.Id );
        
        SL_test_ApprovalValidation.pStandardProperty.Parent_Property__r = pDependentProperty;
        SL_test_ApprovalValidation.pStandardProperty.Parent_Property__r.Section__r = pDependentSection;
        dependentProperties.add( new List<Approval_Properties__c>{ pDependentProperty } );
        dependentProperties.add( new List<Approval_Properties__c>{ SL_test_ApprovalValidation.pStandardProperty } );

        SL_test_ApprovalValidation.pStandardProperty.Hidden__c = false;

        // show
        pOpportunityApproval.Capital_Markets_Consulted__c = 'Yes';
        dependentProperties.hideDependentProperties( pOpportunityApproval );
        system.assertEquals( false, SL_test_ApprovalValidation.pStandardProperty.Hidden__c );

        // hide
        pOpportunityApproval.Capital_Markets_Consulted__c = 'No';
        dependentProperties.hideDependentProperties( pOpportunityApproval );
        system.assert( SL_test_ApprovalValidation.pStandardProperty.Hidden__c );

        Map<ID, List<Approval_Properties__c>> dependentPropertyMap = dependentProperties.getDependentProperties();

        system.assert( dependentPropertyMap.containsKey( pDependentProperty.Id ) );
        system.assert( dependentProperties.getParentFields().contains( pDependentProperty.Field_API_Name__c.toLowerCase() ) );
        
        Boolean childPropertyTest = false;
        for ( Approval_Properties__c property : dependentPropertyMap.get( pDependentProperty.Id ) ) {
            if ( property.Id == SL_test_ApprovalValidation.pStandardProperty.Id ) {
                childPropertyTest = true;
            }
        }
        system.assert( childPropertyTest );     
    }

    static void createData() {
        SL_test_ApprovalValidation.pStandardSection.Object_API_Name__c = 'Opportunity_Approval__c';
        insert SL_test_ApprovalValidation.pStandardSection;

        insert pDependentProperty;

        SL_test_ApprovalValidation.pStandardProperty.Form__c = 'CF;FRG;FVA';
        SL_test_ApprovalValidation.pStandardProperty.Field_API_Name__c = 'Proposed_Fee_Range__c';
        SL_test_ApprovalValidation.pStandardProperty.Parent_Property__c = pDependentProperty.Id;
        SL_test_ApprovalValidation.pStandardProperty.Parent_Property_Values__c = 'Yes';
        insert SL_test_ApprovalValidation.pStandardProperty;

        SL_test_ApprovalValidation.pRelatedListSection.Approval_Page__c = pApprovalPage2.Id;
        SL_test_ApprovalValidation.pRelatedListSection.Object_API_Name__c = 'Financials__c';
        SL_test_ApprovalValidation.pRelatedListSection.Relationship_Field__c = 'Related_Approval__c';
        insert SL_test_ApprovalValidation.pRelatedListSection;

        SL_test_ApprovalValidation.pRelatedListProperty.Form__c = 'CF;FRG;FVA';
        SL_test_ApprovalValidation.pRelatedListProperty.Field_API_Name__c = 'EBIT_MM__c';

        insert new Approval_Properties__c( // additional property to fill in master-detail
            Name = 'Related_Account__c',
            Field_API_Name__c = 'Related_Account__c',
            Form__c = 'CF;FRG;FVA',
            Order__c = 5,
            Section__c = SL_test_ApprovalValidation.pRelatedListProperty.Section__c
        );

        insert SL_test_ApprovalValidation.pRelatedListProperty;
        insert pRelatedListProperty;

        insert pOpportunity;
        insert pOpportunityApproval;
        insert pFinancials;
    }

    public static Approval_Page__c pApprovalPage2 {
        get {
            if ( pApprovalPage2 == null ) {
                pApprovalPage2 = new Approval_Page__c(
                    Name = 'TestOAPage2',
                    Order__c = 2,
                    Approval_Object__c = SL_test_ApprovalValidation.pApprovalObject.Id
                );
                insert pApprovalPage2;
            }
            return pApprovalPage2;
        } set;
    }

    // dependent property gets hidden when child and parent properties are on the different pages
    public static Approval_Section__c pDependentSection {
        get {
            if ( pDependentSection == null ) {
                pDependentSection = new Approval_Section__c(
                    Name = 'TestDependentSection2',
                    Order__c = 2,
                    Object_API_Name__c = 'Opportunity_Approval__c',
                    Approval_Page__c = pApprovalPage2.Id
                );
                insert pDependentSection;
            }
            return pDependentSection;
        } set;
    }
    
    public static Approval_Properties__c pDependentProperty {
        get {
            if ( pDependentProperty == null ) {
                pDependentProperty = new Approval_Properties__c(
                    Name = 'TestDependentProperty',
                    Order__c = 4,
                    Form__c = 'CF;FRG;FVA',
                    Field_API_Name__c = 'Capital_Markets_Consulted__c',
                    Section__c = pDependentSection.Id
                );
            }
            return pDependentProperty;
        } set;
    }
    
    public static Approval_Properties__c pRelatedListProperty {
        get {
            if ( pRelatedListProperty == null ) {
                pRelatedListProperty = new Approval_Properties__c(
                    Name = 'TestEBITDA',
                    Order__c = 3,
                    Form__c = 'CF;FRG;FVA',
                    Field_API_Name__c = 'EBITDA__c',
                    Parent_Property__c = pDependentProperty.Id,
                    Parent_Property_Values__c = 'No',
                    Section__c = SL_test_ApprovalValidation.pRelatedListProperty.Section__c
                );
            }
            return pRelatedListProperty;
        } set;
    }

    public static Opportunity_Approval__c pOpportunityApproval {
        get {
            if ( pOpportunityApproval == null ) {
                pOpportunityApproval = new Opportunity_Approval__c(
                    Related_Opportunity__c = pOpportunity.Id,
                    Is_Client_Public__c = 'Yes',
                    Is_Majority_Sale__c = 'Yes',
                    Who_will_be_at_the_pitch__c = 'Feinstein',
                    Capital_Markets_Consulted__c = 'Yes', // dependent propety test
                    Restricted_List_Explanation__c = 'Test'
                );
            }
            return pOpportunityApproval;
        } set;
    }

    public static Financials__c pFinancials {
        get {
            if ( pFinancials == null ) {
                pFinancials = new Financials__c(
                    Related_Account__c = pAccount.Id,
                    Related_Approval__c = pOpportunityApproval.Id
                );
            }
            return pFinancials;
        } set;
    }

    public static Opportunity__c pOpportunity {
        get {
            if ( pOpportunity == null ) {
                pOpportunity = new Opportunity__c(
                    Name = 'SL Test',
                    Client__c = pAccount.Id,
                    Subject__c = pAccount.Id,
                    Primary_Office__c = 'AT',
                    Line_of_Business__c = 'FVA',
                    Job_Type__c = 'Consulting',
                    Industry_Group__c = 'CFR',
                    Sector__c = 'Apparel',
                    Stage__c = 'Engaged',
                    Referral_Type__c = 'Accountant',
                    Beneficial_Owner_Control_Person_form__c = 'No',
                    RecordTypeId = pRTOpportunityFVAId
                );
            }
            return pOpportunity;
        } set;
    }

    public static ID pRTOpportunityFVAId {
        get {
            if ( pRTOpportunityFVAId == null ) {
                for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity__c' AND DeveloperName = 'FAS' limit 1 ] ) {
                    pRTOpportunityFVAId = record.Id;
                }
                system.assertNotEquals( null, pRTOpportunityFVAId, 'Could not find "FAS" RecordType for the Opportunity object.' );
            }
            return pRTOpportunityFVAId;
        } private set;
    }

    static Account pAccount {
        get {
            if ( pAccount == null ) {
                pAccount = new Account(
                    Name = 'TestAccount'
                );
                insert pAccount;
            }
            return pAccount;
        } set;
    }
}