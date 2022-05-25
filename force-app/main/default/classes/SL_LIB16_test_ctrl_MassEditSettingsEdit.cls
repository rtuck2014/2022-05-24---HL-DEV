@isTest(SeeAllData=true)
private class SL_LIB16_test_ctrl_MassEditSettingsEdit
{
	public static testmethod void test_SL_LIB16_ctrl_MassEditSettingsEdit_newRecord()
    {
        SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();
		
        List<SL_Mass_Implementation__c> defaultSettings = [SELECT TargetObjectName__c FROM SL_Mass_Implementation__c];
        if ( defaultSettings!= null && !defaultSettings.isEmpty() ) 
        {   
             defaultSettings[0].targetObjectName__c = 'Account';
             try{ update defaultSettings[0];}
             catch(Exception e){ }
        } else {
        	try{ insert new SL_Mass_Implementation__c( Name = 'Target', targetObjectName__c = 'Account' );}
        	catch(Exception e){ }
        }
        
        Test.startTest();
        //ApexPages.currentPage().getParameters().put('id', ICObj.Id);
        Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(obj);
        SL_LIB16_ctrl_MassEditSettingsEdit controller = new SL_LIB16_ctrl_MassEditSettingsEdit(stdController);
        
        controller.fieldLoader.primaryObjectValue = 'MasterRecord';
        controller.fieldLoader.level2ObjectValue = 'CreatedBy';
        controller.fieldLoader.level3ObjectValue = 'alias';
        
        controller.updateFieldLists();
        
        controller.sortedFieldLoader.primaryObjectValue = 'MasterRecord';
        controller.sortedFieldLoader.level2ObjectValue = 'CreatedBy';
        controller.sortedFieldLoader.level3ObjectValue = 'alias';
        
        controller.updateSortedFieldLists();
		//controller.CurMESettings.Implementation__c = defaultSettings[0].ID;
        controller.saveBtn();
		controller.cancelBtn();
            
        Test.stopTest();
    }
    
    public static testmethod void test_SL_LIB16_ctrl_MassEditSettingsEdit_existenRecord()
    {
        SL_LIB16_install controller_pre = new SL_LIB16_install();
		controller_pre.runChecker();
		
        List<SL_Mass_Implementation__c> defaultSettings = [SELECT ID, TargetObjectName__c FROM SL_Mass_Implementation__c];
        if ( defaultSettings!= null && !defaultSettings.isEmpty() ) 
        {
             defaultSettings[0].TargetObjectName__c = 'Account';
             try{ update defaultSettings[0];}
             catch(Exception e){ }
        } else {
        	try{ insert new SL_Mass_Implementation__c( Name = 'Target', TargetObjectName__c = 'Account' );}
        	catch(Exception e){ }
        	defaultSettings = [SELECT ID, TargetObjectName__c FROM SL_Mass_Implementation__c];
        }
        
        Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        obj.Implementation__c = defaultSettings[0].ID;
        obj.Implementation_Type__c = 'Search';
        obj.Field__c = 'MasterRecord.CreatedBy.alias';
        obj.Sort_Field__c = 'name';
        insert obj;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        //Mass_Edit_Settings__c obj = new Mass_Edit_Settings__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(obj);
        SL_LIB16_ctrl_MassEditSettingsEdit controller = new SL_LIB16_ctrl_MassEditSettingsEdit(stdController);
        
        controller.fieldLoader.level2ObjectValue = 'billingcity';
        controller.updateFieldLists();
        
        controller.fieldLoader.primaryObjectValue = 'name';
        controller.updateFieldLists();
        //controller.CurMESettings.Implementation__c = defaultSettings[0].ID;
        
        controller.saveNewBtn();
        controller.cancelBtn();
        
        ApexPages.currentPage().getParameters().put('id', obj.Id);
        controller = new SL_LIB16_ctrl_MassEditSettingsEdit();
        
        controller.goStForm();
        controller.CurMESettingsId = null;
        controller.goStForm();
        controller.CurMESettingsId = defaultSettings[0].ID;
        controller.goStForm();
        
            
        Test.stopTest();
    }

}