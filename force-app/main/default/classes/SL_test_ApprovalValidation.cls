/**
 * \author Vladimir Dobrelya
 * \date Jan 20, 2015
 * \brief The test class for SL_handler_ApprovalSection and SL_handler_ApprovalProperty trigger handlers
 */
@isTest
public class SL_test_ApprovalValidation {
	
	static String incorrectName = '!##$#(&(YAS';
	static Boolean hasError = false;

	@isTest static void test_validate_Standard() {
		pStandardSection.Object_API_Name__c = incorrectName; // incorrect object name
		system.assertEquals( false, upsertObject( pStandardSection ) );

		pStandardSection.Object_API_Name__c = 'Opportunity_Approval__c'; // correct object name
		system.assertEquals( true, upsertObject( pStandardSection ) );

		pStandardProperty.Field_API_Name__c = incorrectName; // incorrect field name
		system.assertEquals( false, upsertObject( pStandardProperty ) );

		pStandardProperty.Field_API_Name__c = 'Is_Majority_Sale__c'; // correct field name
		system.assertEquals( true, upsertObject( pStandardProperty ) );

		pStandardSection.Object_API_Name__c = 'Financials__c'; // correct object name, but incorrect for pStandardProperty.Field_API_Name__c
		system.assertEquals( false, upsertObject( pStandardSection ) );
	}
	
	@isTest static void test_validate_RelatedList() {
		pRelatedListSection.Object_API_Name__c = incorrectName; // incorrect object name
		pRelatedListSection.Relationship_Field__c = incorrectName;
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Relationship_Field__c = null; // https://silverline.jira.com/browse/HL-61
		pRelatedListSection.Object_API_Name__c = 'Financials__c';
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Relationship_Field__c = 'Related_Account__c'; // correct object name
		pRelatedListSection.Object_API_Name__c = 'Financials__c';
		system.assertEquals( true, upsertObject( pRelatedListSection ) );

		pRelatedListProperty.Field_API_Name__c = incorrectName; // incorrect field name
		system.assertEquals( false, upsertObject( pRelatedListProperty ) );

		pRelatedListProperty.Field_API_Name__c = 'Name'; // correct field name
		system.assertEquals( true, upsertObject( pRelatedListProperty ) );

		pRelatedListProperty.Field_API_Name__c = incorrectName; // incorrect field name, just for update coverage
		system.assertEquals( false, upsertObject( pRelatedListProperty ) );

		// https://silverline.jira.com/browse/HL-61
		pRelatedListSection.Relationship_Field__c = 'Related_Account__c'; // correct field name
		pRelatedListSection.Parent_Relationship_Field__c = incorrectName; // incorrect field name
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Relationship_Field__c = 'Related_Account__c'; // correct field name
		pRelatedListSection.Parent_Relationship_Field__c = 'Related_Opportunity__r.Client_c'; // incorrect field name
		system.assertEquals( false, upsertObject( pRelatedListSection ) );

		pRelatedListSection.Parent_Relationship_Field__c = 'Related_Opportunity__r.Client__c'; // correct field name
		system.assertEquals( true, upsertObject( pRelatedListSection ) );
	}

	@isTest static void test_validate_ApprovalObject() {
		Approval_Object__c approvalObject = new Approval_Object__c(
			Form__c = 'FVA'
		);

		approvalObject.Base_Object__c = incorrectName; // incorrect Base_Object__c
		system.assertEquals( false, upsertObject( approvalObject ) );

		approvalObject.Base_Object__c = 'Opportunity_Approval__c'; // correct Base_Object__c
		system.assertEquals( true, upsertObject( approvalObject ) );
		
		approvalObject.Master_Detail_Field__c = incorrectName; // incorrect Master_Detail_Field__c
		system.assertEquals( false, upsertObject( approvalObject ) ); 

		approvalObject.Master_Detail_Field__c = 'Related_Opportunity__c'; // correct Master_Detail_Field__c
		system.assertEquals( true, upsertObject( approvalObject ) );
	}

	static Boolean upsertObject( SObject obj ) {
		try {
			upsert obj;
		} catch ( Exception e ) {
			return false;
		}
		return true;
	}

	public static Approval_Object__c pApprovalObject {
		get {
			if ( pApprovalObject == null ) {
				pApprovalObject = new Approval_Object__c(
					Base_Object__c = 'Opportunity_Approval__c',
					Master_Detail_Field__c = 'Related_Opportunity__c',
					Form__c = 'FVA'
				);
				insert pApprovalObject;
			}
			return pApprovalObject;
		} set;
	}

	public static Approval_Page__c pApprovalPage {
		get {
			if ( pApprovalPage == null ) {
				pApprovalPage = new Approval_Page__c(
					Name = 'TestOAPage',
					Order__c = 1,
					Approval_Object__c = pApprovalObject.Id
				);
				insert pApprovalPage;
			}
			return pApprovalPage;
		} set;
	}

	// STANDARD 
	public static Approval_Section__c pStandardSection {
		get {
			if ( pStandardSection == null ) {
				pStandardSection = new Approval_Section__c(
					Name = 'TestApprovalSection',
					Approval_Page__c = pApprovalPage.Id,
					Order__c = 1,
					RecordTypeId = idStandardSectionRT
				);
			}
			return pStandardSection;
		} set;
	}

	public static Approval_Properties__c pStandardProperty {
		get {
			if ( pStandardProperty == null ) {
				pStandardProperty = new Approval_Properties__c(
					Name = 'TestApprovalSection',
					Order__c = 1,
					Section__c = pStandardSection.Id
				);
			}
			return pStandardProperty;
		} set;
	}

	public static ID idStandardSectionRT {
		get {
			if ( idStandardSectionRT == null ) {
				for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Approval_Section__c' AND DeveloperName = 'Standard_Fields' limit 1 ] ) {
					idStandardSectionRT = record.Id;
				}
				system.assertNotEquals( null, idStandardSectionRT, 'Could not find "Standard_Fields" RecordType for the Approval Section object.' );
			}
			return idStandardSectionRT;
		}
	}


	// RELATED LIST
	public static Approval_Section__c pRelatedListSection {
		get {
			if ( pRelatedListSection == null ) {
				pRelatedListSection = new Approval_Section__c(
					Name = 'TestApprovalSection',
					Approval_Page__c = pApprovalPage.Id,
					Order__c = 2,
					RecordTypeId = idRelatedListSectionRT
				);
			}
			return pRelatedListSection;
		} set;
	}

	public static Approval_Properties__c pRelatedListProperty {
		get {
			if ( pRelatedListProperty == null ) {
				pRelatedListProperty = new Approval_Properties__c(
					Name = 'TestApprovalSection',
					Order__c = 2,
					Section__c = pRelatedListSection.Id
				);
			}
			return pRelatedListProperty;
		} set;
	}

	public static ID idRelatedListSectionRT {
		get {
			if ( idRelatedListSectionRT == null ) {
				for ( RecordType record : [ SELECT Id FROM RecordType WHERE SObjectType = 'Approval_Section__c' AND DeveloperName = 'Related_List' limit 1 ] ) {
					idRelatedListSectionRT = record.Id;
				}
				system.assertNotEquals( null, idStandardSectionRT, 'Could not find "Related_List" RecordType for the Opportunity Approval Section object.' );
			}
			return idRelatedListSectionRT;
		}
	}
}