@isTest
private class QuizHelperTest {

	private static testMethod void test() {
        lmscons__Quiz__c quiz = MobileControllerTest.createQuizWithQuestion();
        
        lmscons__Question__c question1 = new lmscons__Question__c(Name = 'test question 1', lmscons__Type__c = QuizHelper.QUESTION_TYPE_TRUE_FALSE, lmscons__Randomization__c = true);
        lmscons__Question__c question2 = new lmscons__Question__c(Name = 'test question 2', lmscons__Type__c = QuizHelper.QUESTION_TYPE_FREE_TEXT);
        lmscons__Question__c question3 = new lmscons__Question__c(Name = 'test question 3', lmscons__Type__c = QuizHelper.QUESTION_TYPE_PAGE_BREAK);
        lmscons__Question__c question4 = new lmscons__Question__c(Name = 'test question 4', lmscons__Type__c = QuizHelper.QUESTION_TYPE_MULTI_SELECT);
    
        insert new List<sObject>{question1, question2, question3, question4};
        
        lmscons__Answer__c answer1_1 = new lmscons__Answer__c(lmscons__Correct_incorrect__c = true, lmscons__Answer__c = 'true', lmscons__Question__c = question1.Id);
        lmscons__Answer__c answer1_2 = new lmscons__Answer__c(lmscons__Correct_incorrect__c = false, lmscons__Answer__c = 'false', lmscons__Question__c = question1.Id);
        
        lmscons__Answer__c answer2_1 = new lmscons__Answer__c(lmscons__Answer__c = 'text ', lmscons__Free_Text__c = 'free',  lmscons__Question__c = question2.Id);
        
        lmscons__Answer__c answer4_1 = new lmscons__Answer__c(lmscons__Correct_incorrect__c = true, lmscons__Answer__c = 'true1', lmscons__Question__c = question4.Id);
        lmscons__Answer__c answer4_2 = new lmscons__Answer__c(lmscons__Correct_incorrect__c = false, lmscons__Answer__c = 'false1', lmscons__Question__c = question4.Id);
        lmscons__Answer__c answer4_3 = new lmscons__Answer__c(lmscons__Correct_incorrect__c = false, lmscons__Answer__c = 'false1', lmscons__Question__c = question4.Id);
        lmscons__Answer__c answer4_4 = new lmscons__Answer__c(lmscons__Correct_incorrect__c = true, lmscons__Answer__c = 'true2', lmscons__Question__c = question4.Id);
        
        insert new List<sObject>{answer1_1, answer1_2, answer2_1, answer4_1, answer4_2, answer4_3, answer4_4};
        
        
        insert new List<sObject>{
            new lmscons__Quiz_Question__c(lmscons__Quiz__c = quiz.Id, lmscons__Question__c = question1.Id),
            new lmscons__Quiz_Question__c(lmscons__Quiz__c = quiz.Id, lmscons__Question__c = question2.Id),
            new lmscons__Quiz_Question__c(lmscons__Quiz__c = quiz.Id, lmscons__Question__c = question3.Id),
            new lmscons__Quiz_Question__c(lmscons__Quiz__c = quiz.Id, lmscons__Question__c = question4.Id)
        };
        
        MobileControllerTest.assignQuiz(quiz.Id);
        lmscons__Transcript_Line__c quizAssignment = MobileControllerTest.getQuizAssignment(quiz.Id);
        
        System.assert(quizAssignment != null, 'quiz assignment is NULL');
        
        MobileHelper.LearningObjectDetailsRequest learningObjectDetailsRequest = new MobileHelper.LearningObjectDetailsRequest();
        learningObjectDetailsRequest.id = quiz.Id; 		
		learningObjectDetailsRequest.objectType = MobileConstants.QUIZ_TYPE;
		learningObjectDetailsRequest.assignmentId = quizAssignment.Id;
        QuizHelper.QuizLaunchModel quizLaunchModel = QuizHelper.getQuizLaunchModel(learningObjectDetailsRequest);
        
        QuizHelper.QuizSubmitResult quizSubmitResult = QuizHelper.submitQuiz(quizLaunchModel);
        
	}

}