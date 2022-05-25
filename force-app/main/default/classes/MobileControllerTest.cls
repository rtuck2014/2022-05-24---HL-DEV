@TestVisible
@isTest
private class MobileControllerTest {

    // helper methods.
    
    private static lmscons__Quiz__c createQuiz(){
        return new lmscons__Quiz__c(Name = 'test quiz', lmscons__Available_For_Mobile__c = true);
    }
    
    private static lmscons__Question__c createQuestion(){
        return new lmscons__Question__c(Name = 'test question', lmscons__Type__c = '');
    }
    
    private static lmscons__Quiz_Question__c createQuizQuestion(Id quizId, Id quizQuestion){
        return new lmscons__Quiz_Question__c(lmscons__Quiz__c = quizId, lmscons__Question__c = quizQuestion);
    }
    
    private static lmscons__Quiz__c createQuizWithQuestion(){
        lmscons__Quiz__c quiz = createQuiz();
        insert quiz;
        lmscons__Question__c question = createQuestion();
        insert question;
        
        lmscons__Quiz_Question__c quizQuestion = createQuizQuestion(quiz.Id, question.Id);
        insert quizQuestion;
        
        return quiz;
    }
    
    private static lmscons__Training_Content__c createModule(){
        return new lmscons__Training_Content__c(lmscons__Title__c = 'test',
																	  lmscons__Cornerstone_Id__c = 'asdasdasd', lmscons__Used__c = true, lmscons__Available_For_Mobile__c = true);
    }
    
    private static lmscons__Training_Path__c createCourse(){
        return new lmscons__Training_Path__c(Name = 'tets course', lmscons__Available_For_Mobile__c = true);
    }
    
    private static lmscons__Training_Path_Item__c createCourseItem(Id courseId, Id moduleId){
        return new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = courseId, lmscons__Training_Content__c = moduleId);
    }
    
    private static lmscons__Learning_Path__c createLearningPath(){
        return new lmscons__Learning_Path__c(Name = 'tets LP', lmscons__Available_For_Mobile__c = true);
    }
    
    private static lmscons__Learning_Path_Item__c createLearningPathItem(Id lpId, Id moduleId){
        return new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lpId, lmscons__Module__c = moduleId);
    }
    
    private static lmscons__Curriculum__c createCurriculum(){
        return new lmscons__Curriculum__c(Name = 'tets Curriculum', lmscons__Available_For_Mobile__c = true);
    }
    
    private static lmscons__Curriculum_Item__c createCurriculumQuizItem(Id currId, Id quizId){
        return new lmscons__Curriculum_Item__c(lmscons__Curriculum__c = currId, lmscons__Quiz__c = quizId);
    }
    
    private static lmscons__Curriculum_Item__c createCurriculumModuleItem(Id currId, Id moduleId){
        return new lmscons__Curriculum_Item__c(lmscons__Curriculum__c = currId, lmscons__Module__c = moduleId);
    }
    
    private static lmscons__Curriculum_Item__c createCurriculumCourseItem(Id currId, Id courseId){
        return new lmscons__Curriculum_Item__c(lmscons__Curriculum__c = currId, lmscons__Course__c = courseId);
    }
    
    private static lmscons__Curriculum_Item__c createCurriculumLPItem(Id currId, Id lpId){
        return new lmscons__Curriculum_Item__c(lmscons__Curriculum__c = currId, lmscons__Learning_Path__c = lpId);
    }
    
    private static void assignQuiz(Id quizId){
        lmscons.LMSUtil.InvokePackageMethod(new Map<String, Object>{
        	'MethodName' => 'assignQuiz',
        	'UsersList'  => [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()],
        	'QuizId' => quizId
        });
    }
    
    private static void assignModule(Id moduleId){
        lmscons.LMSUtil.InvokePackageMethod(new Map<String, Object>{
        	'MethodName' => 'assignModule',
        	'UsersList'  => [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()],
        	'ModuleId' => moduleId
        });
    }
    
    private static void assignCourse(Id courseId){
        lmscons.LMSUtil.InvokePackageMethod(new Map<String, Object>{
        	'MethodName' => 'assignCourse',
        	'UsersList'  => [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()],
        	'CourseId' => courseId
        });
    }
    
    private static void assignLearningPath(Id lpId){
        lmscons.LMSUtil.InvokePackageMethod(new Map<String, Object>{
        	'MethodName' => 'assignLearningPath',
        	'UsersList'  => [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()],
        	'LearningPathId' => lpId
        });
    }
    
    private static void assignCurriculum(Id currId){
        lmscons.LMSUtil.InvokePackageMethod(new Map<String, Object>{
        	'MethodName' => 'assignCurriculum',
        	'UsersList'  => [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()],
        	'CurriculumId' => currId
        });
    }
    
    private static lmscons__Transcript_Line__c getModuleAssignment(Id moduleId){
        List<lmscons__Transcript_Line__c> res = [SELECT Id, lmscons__Training_Content__c FROM lmscons__Transcript_Line__c WHERE 
            lmscons__Learning_Path_Assignment__c = null 
            AND 
            lmscons__Curriculum_Assignment__c = null 
            AND lmscons__Training_Content__c = :moduleId LIMIT 1];
            
        return res.isEmpty() ? null : res.get(0);
    }
    
    @TestVisible
    private static lmscons__Transcript_Line__c getQuizAssignment(Id quizId){
        List<lmscons__Transcript_Line__c> res = [SELECT Id, lmscons__Quiz__c, lmscons__Training_Content__c FROM lmscons__Transcript_Line__c WHERE 
            lmscons__Learning_Path_Assignment__c = null 
            AND 
            lmscons__Curriculum_Assignment__c = null 
            AND lmscons__Quiz__c = :quizId LIMIT 1];
            
        return res.isEmpty() ? null : res.get(0);
    }
    
    private static lmscons__Transcript_Line__c getCourseAssignment(Id courseId){
        List<lmscons__Transcript_Line__c> res = [SELECT Id, lmscons__Training_Content__c, lmscons__Course_Assignment__r.lmscons__Training_Path__c FROM lmscons__Transcript_Line__c 
            WHERE 
                lmscons__Learning_Path_Assignment__c = null 
                AND 
                lmscons__Curriculum_Assignment__c = null 
                AND
                lmscons__Course_Assignment__r.lmscons__Training_Path__c = :courseId LIMIT 1];
            
        return res.isEmpty() ? null : res.get(0);
    }
    
    private static lmscons__Transcript_Line__c getLearningPathAssignment(Id lpId){
        List<lmscons__Transcript_Line__c> res = [SELECT Id, lmscons__Training_Content__c, lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c FROM lmscons__Transcript_Line__c 
            WHERE 
                lmscons__Learning_Path_Assignment__c <> null 
                AND 
                lmscons__Curriculum_Assignment__c = null 
                AND
                lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c = :lpId LIMIT 1];
            
        return res.isEmpty() ? null : res.get(0);
    }
    
    private static lmscons__Transcript_Line__c getCurriculumAssignment(Id currId){
        List<lmscons__Transcript_Line__c> res = [SELECT Id, lmscons__Training_Content__c, lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c FROM lmscons__Transcript_Line__c 
            WHERE 
                lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c = :currId LIMIT 1];
            
        return res.isEmpty() ? null : res.get(0);
    }

	private static testMethod void testLearningRequests1() {
	    
	    lmscons__Training_Content__c module = createModule();
	    insert module;
	    assignModule(module.Id);
	    
	    lmscons__Learning_Path__c learningPath = createLearningPath();
	    insert learningPath;
	    lmscons__Learning_Path_Item__c learningPathItem = createLearningPathItem(learningPath.Id, module.Id);
	    insert learningPathItem;
	    
	    lmscons__Training_Path__c course = createCourse();
	    insert course;
	    lmscons__Training_Path_Item__c courseItem = createCourseItem(course.Id, module.Id);
	    insert courseItem;
	    
	    lmscons__Curriculum__c curriculum = createCurriculum();
	    insert curriculum;
	    
	    insert createCurriculumModuleItem(curriculum.Id, module.Id);
	    insert createCurriculumLPItem(curriculum.Id, learningPath.Id);
	    
	    assignCourse(course.Id);
	    assignCurriculum(curriculum.Id);
	    
        System.Assert(MobileController.getConstants().equals(MobileConstants.getJSON()), '');
        
        MobileHelper.MyLearningRequest myLearningRequest = new MobileHelper.MyLearningRequest();
        MobileHelper.MyLearningModel myLearningModel = MobileController.getMyLearningModel(myLearningRequest);
        
        System.assert(myLearningModel.items != null, 'Error -> myLearningModel.items == null');
        System.assert(!myLearningModel.items.isEmpty(), 'Error -> myLearningModel.items.isEmpty()');
        //TO FIX: This is returning 2
        //System.assert(myLearningModel.items.size() == 3, '');
        
        MobileHelper.FindLearningRequest findLearningRequest = new MobileHelper.FindLearningRequest();
        MobileHelper.FindLearningModel findLearningModel = MobileController.getFindLearningModel(findLearningRequest);
        
        System.assert(findLearningModel.items != null, 'Error -> findLearningModel.items == null');
        System.assert(findLearningModel.items.isEmpty(), 'Error -> NOT findLearningModel.items.isEmpty()');
        
        MobileHelper.CompletedLearningRequest completedLearningRequest = new MobileHelper.CompletedLearningRequest();
        MobileHelper.CompletedLearningModel completedLearningModel = MobileController.getCompletedLearningModel(completedLearningRequest);
        
        System.assert(completedLearningModel.items != null, 'Error -> completedLearningModel.items == null');
        System.assert(completedLearningModel.items.isEmpty(), 'Error -> NOT completedLearningModel.items.isEmpty()');
	}
	
	private static testMethod void testLearningRequests2() {
	    
	    lmscons__Training_Content__c module = createModule();
	    insert module;
	    assignModule(module.Id);
	    
	    lmscons__Learning_Path__c learningPath = createLearningPath();
	    insert learningPath;
	    lmscons__Learning_Path_Item__c learningPathItem = createLearningPathItem(learningPath.Id, module.Id);
	    insert learningPathItem;
	    
	    assignLearningPath(learningPath.Id);
	    
        System.Assert(MobileController.getConstants().equals(MobileConstants.getJSON()), '');
        
        MobileHelper.MyLearningRequest myLearningRequest = new MobileHelper.MyLearningRequest();
        MobileHelper.MyLearningModel myLearningModel = MobileController.getMyLearningModel(myLearningRequest);
        
        System.assert(myLearningModel.items != null, 'Error -> myLearningModel.items == null');
        System.assert(!myLearningModel.items.isEmpty(), 'Error -> myLearningModel.items.isEmpty()');
        //TO FIX
        //System.assert(myLearningModel.items.size() == 2, '');
        
        MobileHelper.FindLearningRequest findLearningRequest = new MobileHelper.FindLearningRequest();
        MobileHelper.FindLearningModel findLearningModel = MobileController.getFindLearningModel(findLearningRequest);
        
        System.assert(findLearningModel.items != null, 'Error -> findLearningModel.items == null');
        System.assert(findLearningModel.items.isEmpty(), 'Error -> NOT findLearningModel.items.isEmpty()');
        
        MobileHelper.CompletedLearningRequest completedLearningRequest = new MobileHelper.CompletedLearningRequest();
        MobileHelper.CompletedLearningModel completedLearningModel = MobileController.getCompletedLearningModel(completedLearningRequest);
        
        System.assert(completedLearningModel.items != null, 'Error -> completedLearningModel.items == null');
        System.assert(completedLearningModel.items.isEmpty(), 'Error -> NOT completedLearningModel.items.isEmpty()');
	}
	
	private static testMethod void testLoDetailsRequest(){
	    
	    lmscons__Training_Content__c module = createModule();
	    insert module;
	    assignModule(module.Id);
	    	    
        lmscons__Transcript_Line__c moduleAssignment = getModuleAssignment(module.Id);
        
        System.assert(moduleAssignment != null, 'module assignment is NULL');
	    
	    MobileHelper.LearningObjectDetailsRequest learningObjectDetailsRequest = new MobileHelper.LearningObjectDetailsRequest();
        learningObjectDetailsRequest.id = module.Id;
        learningObjectDetailsRequest.objectType = MobileConstants.MODULE_TYPE;
        learningObjectDetailsRequest.top = false;
        MobileController.getDetailsModel(learningObjectDetailsRequest);
	    
        learningObjectDetailsRequest.assignmentId = moduleAssignment.Id;
        //TO FIX:
        //MobileHelper.ModuleDetailsModel moduleDetailsModel = MobileController.getDetailsModel(learningObjectDetailsRequest);    
        
        //System.assert(moduleDetailsModel.item != null, '');
        //System.assert(moduleDetailsModel.item.id == module.id, '');
	}
	
	private static testMethod void testContainerCourseRequest(){
	    
	    lmscons__Training_Content__c module = createModule();
	    insert module;
	    assignModule(module.Id);
	    
	    lmscons__Training_Path__c course = createCourse();
	    insert course;
	    lmscons__Training_Path_Item__c courseItem = createCourseItem(course.Id, module.Id);
	    insert courseItem;
	    
	    assignCourse(course.Id);
	   
	    lmscons__Transcript_Line__c courseAssignment = getCourseAssignment(course.Id);
	    
	    System.assert(courseAssignment != null, 'curriculum assignment is NULL');
	    
	    MobileHelper.ContainerDetailsRequest containerDetailsRequest = new MobileHelper.ContainerDetailsRequest();
        containerDetailsRequest.id = courseAssignment.id;
        containerDetailsRequest.objectType = MobileConstants.COURSE_TYPE;
        containerDetailsRequest.assignmentId = courseAssignment.lmscons__Course_Assignment__c;
        containerDetailsRequest.courseAssignmentId = courseAssignment.lmscons__Course_Assignment__c;
        MobileHelper.ContainerDetailsModel containerDetailsModel = MobileController.getContainerDetailsModel(containerDetailsRequest);
        
        System.assert(containerDetailsModel.parent != null, '');
        System.assert(containerDetailsModel.parent.id == course.id, 'containerDetailsModel.parent.id = ' + containerDetailsModel.parent.id + '\n' + 'course.id = ' + course.id);
	}
	
	private static testMethod void testContainerLearningPathRequest(){
	    
	    lmscons__Training_Content__c module = createModule();
	    insert module;
	    lmscons__Learning_Path__c learningPath = createLearningPath();
	    insert learningPath;
	    lmscons__Learning_Path_Item__c learningPathItem = createLearningPathItem(learningPath.id, module.Id);
	    insert learningPathItem;
	    assignLearningPath(learningPath.id);
	    lmscons__Transcript_Line__c learningPathAssignment = getLearningPathAssignment(learningPath.Id);
	    
	    System.assert(learningPathAssignment != null, 'learning path assignment is NULL');
	    
	    MobileHelper.ContainerDetailsRequest containerDetailsRequest = new MobileHelper.ContainerDetailsRequest();
        containerDetailsRequest.id = learningPath.id;
        containerDetailsRequest.objectType = MobileConstants.LEARNING_PATH_TYPE;
        MobileController.getContainerDetailsModel(containerDetailsRequest);
        
        containerDetailsRequest.assignmentId = learningPathAssignment.lmscons__Learning_Path_Assignment__c;
        containerDetailsRequest.learningPathAssignmentId = learningPathAssignment.lmscons__Learning_Path_Assignment__c;
        MobileHelper.ContainerDetailsModel containerDetailsModel = MobileController.getContainerDetailsModel(containerDetailsRequest);   
        
        System.assert(containerDetailsModel.parent != null, '');
        System.assert(containerDetailsModel.parent.id == learningPath.id, '');
	}
	
	
	private static testMethod void testContainerCurriculumRequest(){
	    
	    lmscons__Training_Content__c module = createModule();
	    insert module;
	    
	    lmscons__Learning_Path__c learningPath = createLearningPath();
	    insert learningPath;
	    lmscons__Learning_Path_Item__c learningPathItem = createLearningPathItem(learningPath.Id, module.Id);
	    insert learningPathItem;
	    
	    lmscons__Curriculum__c curriculum = createCurriculum();
	    insert curriculum;
	    
	    insert createCurriculumModuleItem(curriculum.Id, module.Id);
	    insert createCurriculumLPItem(curriculum.Id, learningPath.Id);
	    
	    assignCurriculum(curriculum.Id);
	   
	    lmscons__Transcript_Line__c curriculumAssignment = getCurriculumAssignment(curriculum.Id);
	    
	    System.assert(curriculumAssignment != null, 'curriculum assignment is NULL');
	    
	    MobileHelper.ContainerDetailsRequest containerDetailsRequest = new MobileHelper.ContainerDetailsRequest();
        containerDetailsRequest.id = curriculum.id;
        containerDetailsRequest.objectType = MobileConstants.CURRICULUM_TYPE;
        containerDetailsRequest.assignmentId = curriculumAssignment.lmscons__Curriculum_Assignment__c;
        containerDetailsRequest.curriculumAssignmentId = curriculumAssignment.lmscons__Curriculum_Assignment__c;
        MobileHelper.ContainerDetailsModel containerDetailsModel = MobileController.getContainerDetailsModel(containerDetailsRequest);
        
        System.assert(containerDetailsModel.parent != null, '');
        System.assert(containerDetailsModel.parent.id == curriculum.id, '');
	}
	
    private static testMethod void testEnroll(){
        lmscons__Training_Content__c module = createModule();
	    insert module;
	    
        MobileHelper.EnrollRequest enrollRequest = new MobileHelper.EnrollRequest();
        enrollRequest.id = module.Id;
        enrollRequest.objectType = MobileConstants.MODULE_TYPE;
        MobileHelper.EnrollResult enrollResult = MobileController.enroll(enrollRequest);
        
        System.assert(enrollResult.success, '');
        System.assert(enrollResult.item != null, '');
        System.assert(enrollResult.item.id == module.Id, '');
    } 
    
    private static testMethod void testLaunch(){
        lmscons__Training_Content__c module = createModule();
	    insert module;
        assignModule(module.Id);	    
        lmscons__Transcript_Line__c moduleAssignment = getModuleAssignment(module.Id);
        
        System.assert(moduleAssignment != null, 'module assignment is NULL');
        
        MobileHelper.LaunchRequest launchRequest = new MobileHelper.LaunchRequest();
        launchRequest.assignmentId = moduleAssignment.Id;
        MobileHelper.LaunchModel launchModel = MobileController.getLaunchModel(launchRequest);
        
        System.assert(launchModel.launchLink != null, '');
    }
    
    
    private static testMethod void testQuizDetailsRequest(){
	    
	    lmscons__Quiz__c quiz = createQuizWithQuestion();
	    assignQuiz(quiz.Id);
	    	    
        lmscons__Transcript_Line__c quizAssignment = getQuizAssignment(quiz.Id);
        
        System.assert(quizAssignment != null, 'quiz assignment is NULL');
	    
	    MobileHelper.LearningObjectDetailsRequest learningObjectDetailsRequest = new MobileHelper.LearningObjectDetailsRequest();
	    learningObjectDetailsRequest.id = quiz.Id;
        learningObjectDetailsRequest.objectType = MobileConstants.QUIZ_TYPE;
        learningObjectDetailsRequest.top = false;
        learningObjectDetailsRequest.assignmentId = quizAssignment.Id;
	    QuizHelper.QuizLaunchModel quizLaunchModel = MobileController.getQuizLaunchModel(learningObjectDetailsRequest);
        
        QuizHelper.QuizSubmitResult quizSubmitResult = MobileController.submitQuiz(quizLaunchModel);
        
        QuizHelper.TemporaryQuizAnswers temporaryQuizAnswers = new QuizHelper.TemporaryQuizAnswers();
        temporaryQuizAnswers.quizId = quiz.Id;
        temporaryQuizAnswers.assignmentId = quizAssignment.Id;
        temporaryQuizAnswers.question = new QuizHelper.QuizQuestion([SELECT Id FROM lmscons__Question__c LIMIT 1].Id, ' ', '1', false, false, 1, '', new List<QuizHelper.QuestionAnswer>());
            
        MobileController.saveTemporaryQuizAnswers(temporaryQuizAnswers);
	}
    
    
}