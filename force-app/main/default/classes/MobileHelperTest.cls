@isTest
private class MobileHelperTest {

	private static testMethod void test() {
	    
	    lmscons__Quiz__c quiz = MobileControllerTest.createQuiz();
    	insert quiz;
	    
        lmscons__Training_Content__c module = MobileControllerTest.createModule();
	    insert module;
	    
	    lmscons__Training_Path__c course = MobileControllerTest.createCourse();
	    insert course;
	    
	    lmscons__Learning_Path__c learningPath = MobileControllerTest.createLearningPath();
	    insert learningPath;
	    
	    lmscons__Curriculum__c curriculum = MobileControllerTest.createCurriculum();
	    insert curriculum;
	    
	    insert MobileControllerTest.createCurriculumQuizItem(curriculum.Id, quiz.Id);
	    insert MobileControllerTest.createCurriculumModuleItem(curriculum.Id, module.Id);
	    insert MobileControllerTest.createCurriculumCourseItem(curriculum.Id, course.Id);
	    insert MobileControllerTest.createCurriculumLPItem(curriculum.Id, learningPath.Id);
	    
	    
	    MobileHelper.getItemsFromCurriculum(curriculum.Id);
	    
	    MobileHelper.getQuiz(quiz.Id);
	    
	    
	    insert new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = course.Id, lmscons__Training_Content__c = module.Id);
	    insert new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = course.Id, lmscons__Quiz__c = quiz.Id, lmscons__Training_Content__c = module.Id); 
	    
	    MobileHelper.getItemsFromCourse(course.Id);
	}

}