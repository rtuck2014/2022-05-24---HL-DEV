@isTest
private class CatalogDataLoadHelperTest {

	private static testMethod void test() {
	    
	    System.RunAs([select Id from user where id = :UserInfo.getUserId() limit 1].get(0)) {
            
    	    lmscons__Catalog__c catalog = new lmscons__Catalog__c(Name = 'test name');
    	    insert catalog;
    	    insert new lmscons__Catalog_Group__c(lmscons__Catalog__c = catalog.Id);
    	    
    	    insert new lmscons__Catalog_Profile__c(lmscons__Catalog__c = catalog.Id, lmscons__Profile_Id__c = UserInfo.getProfileId());
    	    
    	    lmscons__Quiz__c quiz = MobileControllerTest.createQuiz();
    	    insert quiz;
    	    insert new lmscons__Catalog_Quiz__c(lmscons__Catalog__c = catalog.Id, lmscons__Quiz__c = quiz.Id);
    	    
    	    lmscons__Training_Content__c module = MobileControllerTest.createModule();
    	    insert module;
    	    insert new lmscons__Catalog_Course__c(lmscons__Catalog__c = catalog.Id, lmscons__Training_Course__c = module.Id);
    	    
    	    lmscons__Learning_Path__c lp = MobileControllerTest.createLearningPath();
    	    insert lp;
    	    insert new lmscons__Catalog_Learning_Path__c(lmscons__Catalog__c = catalog.Id, lmscons__Learning_Path__c = lp.Id);
    	    
    	    lmscons__Curriculum__c curriculum = MobileControllerTest.createCurriculum();
    	    insert curriculum;
    	    insert new lmscons__Catalog_Curriculum__c(lmscons__Catalog__c = catalog.Id, lmscons__Curriculum__c = curriculum.Id);
    	    
            CatalogDataLoadHelper.getTopCatalogItems(CatalogDataLoadHelper.getCurentUserCatalogsSet(), null);
            CatalogDataLoadHelper.getTopCatalogItems(CatalogDataLoadHelper.getCurentUserCatalogsSet(), 'test');
        
	    }
	}

}