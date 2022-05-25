@isTest   
global with sharing class SL_RTR_LIB16_test_DescribeObject_Core
{
	public static testMethod void testThis() {
		String sObjName = 'contact';
		String sFieldName = 'accountid';

		SL_RTR_LIB16_ME_DescribeObject_Core core = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance();
		core.isObjectExist(sObjName);
//		system.assert(core.getAllObjects().size() > 0 , 'AllObjects list is empty');
//		system.assert(core.getStandardObjects().size() > 0 , 'Standard objects list is empty');
        system.assert(core.getObjects('Standard Objects').size() > 0 , 'Standard objects list is empty / other way');
//		core.getStandardObjects();
		system.assert(core.getRecordByTypeName(sObjName) != null , 'getRecordByTypeName is null');		
		system.assert(core.getFieldsDescribesByObjectName(sObjName).size() > 0 , sObjName + ' getFieldsDescribesByObjectName is empty');
		
		core.getDefaultFieldValueByName(sObjName, sFieldName);
		system.assert(core.getFieldTypeByName(sObjName, sFieldName) != '' , 'getFieldTypeByName is empty');
		system.assert(core.hasField(sObjName, sFieldName) , 'hasField not true!');

		core.isFieldAccessible(sObjName, sFieldName);
		core.isFieldCreateable(sObjName,sFieldName);
		core.isFieldCreateable(sObjName,'account.Name');
		
		core.getFieldTypeByName('','');
		core.isFieldCreateable(null,null);
		
        system.assert(core.getFieldLabelByName(sObjName, sFieldName) != '' , 'getFieldLabelByName is empty');
		system.assert(core.getFieldByName(sObjName, sFieldName) != null , 'getFieldByName is null');
        system.assert(core.getObjectLabelByName(sObjName) != '' , 'getObjectLabelByName is empty');
        
		core.getObjectFieldsByType(sObjName,  'string');
		core.getData(sObjName, sFieldName, 'limit 5', 'name = \'5\'');
		
		
        core.isFieldUpdatable(sObjName, sFieldName);
		//core.isFieldUpdatable(sObjName, sFieldName);
		core.getData('SELECT Id FROM Account limit 2'); 
		system.assert(core.getReferencedObjectPrefixByFieldName(sObjName, sFieldName) != '' , 'getReferencedObjectPrefixByFieldName is empty');
        system.assert(core.getFieldReferenceByName(sObjName, sFieldName) != '' , 'getFieldReferenceByName is empty');
        system.assert(core.getFieldDescriptionByName(sObjName, sFieldName) != null , 'getFieldDescriptionByName is empty');
        
        core.getFieldsInSOQL('Contact',new Set<String>{'Name','accountid'}, true);
        core.getFieldsInSOQL('Contact',new Set<String>{'Name','accountid'}, false);
        core.getFieldsTypesInSOQL('Contact',new Set<String>{'Name','accountid'});
        core.getReferenceField('Contact','Account.Owner.ID');
        core.getReferenceField('Contact','Account.Name');
        
	}
	
	public static testMethod void testThis2()
	{
		SL_RTR_LIB16_ME_DescribeObject_Core controller = new SL_RTR_LIB16_ME_DescribeObject_Core();
		
		system.debug('==== getInstance() ==== >>>> '+SL_RTR_LIB16_ME_DescribeObject_Core.getInstance());
		
		//system.debug('==== getAllObjects() ==== >>>> '+controller.getAllObjects());
		//system.debug('==== getCustomObjects() ==== >>>> '+controller.getCustomObjects());
		//system.debug('==== getStandardObjects() ==== >>>> '+controller.getStandardObjects());
		//system.debug('==== getDecribedFieldsByObject(Account) ==== >>>> '+controller.getDecribedFieldsByObject('Call_Log__c'));
		system.debug('==== getFieldType() ==== >>>> '+controller.getFieldTypeByName('Account','Name'));
		system.debug('==== getFieldLabel() ==== >>>> '+controller.getFieldLabelByName('Account','Name'));
		system.debug('==== getFieldRef() ==== >>>> '+controller.getFieldReferenceByName('Account','Name'));
		system.debug('==== getFieldByName() ==== >>>> '+controller.getFieldByName('Account','Name'));
		system.debug('==== getObjLabel() ==== >>>> '+controller.getObjectLabelByName('Account'));
		system.debug('==== getFieldsByType() ==== >>>> '+controller.getObjectFieldsByType('Account','DATE'));
		system.debug('==== getNameByPrefix() ==== >>>> '+controller.getObjectNameByPrefix('Acc'));
		system.debug('==== getLabelByPrefix() ==== >>>> '+controller.getObjectLabelByPrefix('Acc'));
		//system.debug('==== getObjByPrefix() ==== >>>> '+controller.getObjectByPrefix('Acc'));
		system.debug('==== getData() ==== >>>> '+controller.getData('Account','Id,Name','limit 10',''));
	}
	
	public static testMethod void testThis4() {
		String sObjName = 'Company_List_Member__c';
		String sFieldName = 'Company_List__c';
		SL_RTR_LIB16_ME_DescribeObject_Core core = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance();
//		system.assert(core.getAllObjects().size() > 0 , 'AllObjects list is empty');
//		system.assert(core.getStandardObjects().size() > 0 , 'Standard objects list is empty');
		core.isObjectExist(sObjName);
		core.isObjectExist('AccountPrivlad__c');
		core.isObjectExist('Test__AccountPrivlad__c');
		SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace = 'Test__';
		core.getDefaultFieldValueByName('Test__AccountPrivlad__c','Filed__c');
		core.isFieldCreateable(sObjName,sFieldName);
		core.isObjectAccessable('Account');
		core.isObjectAccessable(sObjName);
		core.isObjectAccessable('User');

		core.isObjectEditable('Account');
		core.isObjectEditable(sObjName);
		core.isObjectEditable('User');
		
		core.isObjectCreateable('Account');
		core.isObjectCreateable(sObjName);
		core.isObjectCreateable('User');
		
		core.getObjectFieldsByType('Account',new List<String>{'REFERENCE','STRING'});
		
		core.getObjectNameByID('001i000000f3vsg001');
		core.getObjectNameByID('003i000000cyjwZ001');

		core.getObjectLabelByID('001i000000f3vsg001');
		core.getObjectLabelByID('003i000000cyjwZ001');
		
		core.getObjectAllFields('Account');
		core.getObjectAllQueryFields('Account');
		core.getObjectDescription('Account');
		core.getObjectsDescribe();
		core.getObjectDescribe('Account');
		core.isNoNameField('Account');
		core.getObjectNameField('Account');
		core.getFieldsInSOQL('Account',new List<String>{'Name','ID'});
		core.getFieldsInSOQL('Account',new Set<String>{'Name','ID'});
		core.getFieldsTypesInSOQL('Account',new Set<String>{'Name','Type'});
		


		
		
	}
	
	public static testMethod void testThis3() {
		String sObjName = 'Company_List_Member__c';
		String sFieldName = 'Company_List__c';
		SL_RTR_LIB16_ME_DescribeObject_Core core = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance();
		core.isFieldAccessible('Company_List_Member__c','Company_List__c.Name');
//		system.assert(core.getAllObjects().size() > 0 , 'AllObjects list is empty');
//		system.assert(core.getStandardObjects().size() > 0 , 'Standard objects list is empty');
		core.isObjectExist(sObjName);
		core.isObjectExist('AccountPrivlad__c');
		core.isObjectExist('Test__AccountPrivlad__c');
		core.getDefaultFieldValueByName('Test__AccountPrivlad__c','Filed__c');
		core.getDefaultFieldValueByName('Account','Name');
		core.getDefaultFieldValueByName('Account','Industry');
		core.getDefaultFieldValueByName('Contact','DoNotCall');
		core.isFieldCreateable('Contact','DoNotCall');
		core.isFieldCreateable('Account','Industry');
		
		
		core.getObjectRecordTypeValues('Account');
		core.getObjectAllFields('Company_List_Member__c');
		core.getObjectAllQueryFields('Company_List_Member__c');
		core.getObjectDescription('Company_List_Member__c');
		core.getObjectsDescribe();
		core.getObjectDescribe('Company_List_Member__c');
		core.isNoNameField('Company_List_Member__c');
		core.getObjectNameField('Company_List_Member__c');
		core.getFieldsInSOQL('Company_List_Member__c',new List<String>{'Name','ID'});
		core.getFieldsInSOQL('Company_List_Member__c',new Set<String>{'Name','ID'});
		
		
		
		core.getFieldsDescribesByObjectName(sObjName);
		core.getFieldsDescribesByObjectName(sObjName, true);
		SL_RTR_LIB16_ME_DescribeObject_Core.isStringNullOrEmpty(null);
		SL_RTR_LIB16_ME_DescribeObject_Core.isStringNullOrEmpty('Test String');

        system.assert(core.getObjects('Standard Objects').size() > 0 , 'Standard objects list is empty / other way');
//		core.getStandardObjects();
		//system.assert(core.getRecordByTypeName(sObjName) != null , 'getRecordByTypeName is null');		
		//system.assert(core.getFieldsDescribesByObjectName(sObjName).size() > 0 , sObjName + ' getFieldsDescribesByObjectName is empty');
		
		core.getDefaultFieldValueByName(sObjName, sFieldName);
		//system.assert(core.getFieldTypeByName(sObjName, sFieldName) != '' , 'getFieldTypeByName is empty');
		//system.assert(core.hasField(sObjName, sFieldName) , 'hasField not true!');


		core.isFieldAccessible(sObjName, sFieldName);
		
        system.assert(core.getFieldLabelByName(sObjName, sFieldName) != '' , 'getFieldLabelByName is empty');
		//system.assert(core.getFieldByName(sObjName, sFieldName) != null , 'getFieldByName is null');
       // system.assert(core.getObjectLabelByName(sObjName) != '' , 'getObjectLabelByName is empty');
        
		core.getObjectFieldsByType(sObjName,  'string');
		core.getData(sObjName, sFieldName, 'limit 5', 'name = \'5\'');
		
		
        core.isFieldUpdatable(sObjName, sFieldName);
		//core.isFieldUpdatable(sObjName, sFieldName);
		core.getData('SELECT Id FROM Account limit 2'); 
		//system.assert(core.getReferencedObjectPrefixByFieldName(sObjName, sFieldName) != '' , 'getReferencedObjectPrefixByFieldName is empty');
        //system.assert(core.getFieldReferenceByName(sObjName, sFieldName) != '' , 'getFieldReferenceByName is empty');
       // system.assert(core.getFieldDescriptionByName(sObjName, sFieldName) != null , 'getFieldDescriptionByName is empty');
        
	}
	
}