global with sharing class MobileController {

	@RemoteAction
	global static String getConstants(){
		return MobileConstants.getJSON();	
	}

	@RemoteAction
	global static MobileHelper.MyLearningModel getMyLearningModel(MobileHelper.MyLearningRequest myLearningRequest){
		return MobileHelper.getMyLearningModel(myLearningRequest);	
	}
	
	@RemoteAction
	global static MobileHelper.FindLearningModel getFindLearningModel(MobileHelper.FindLearningRequest findLearningRequest){
		return MobileHelper.getFindLearningModel(findLearningRequest);	
	}
	
	@RemoteAction
	global static MobileHelper.CompletedLearningModel getCompletedLearningModel(MobileHelper.CompletedLearningRequest completedLearningRequest){
		return MobileHelper.getCompletedLearningModel(completedLearningRequest);	
	}
	
	@RemoteAction
	global static MobileHelper.ContainerDetailsModel getContainerDetailsModel(MobileHelper.ContainerDetailsRequest containerDetailsRequest){
		return MobileHelper.getContainerDetailsModel(containerDetailsRequest);	
	}
	
	@RemoteAction
	global static MobileHelper.ModuleDetailsModel getDetailsModel(MobileHelper.LearningObjectDetailsRequest learningObjectDetailsRequest){
		return MobileHelper.getModuleDetailsModel(learningObjectDetailsRequest);	
	}
	
	@RemoteAction
	global static MobileHelper.EnrollResult enroll(MobileHelper.EnrollRequest enrollRequest){
		return MobileHelper.enroll(enrollRequest);	
	}
	
	@RemoteAction
	global static MobileHelper.LaunchModel getLaunchModel(MobileHelper.LaunchRequest launchRequest){
		return MobileHelper.getLaunchModel(launchRequest);	
	}
	
	/*
	@RemoteAction
	global static QuizHelper.QuizMetadata getFakeQuizMetadata(){
		return QuizHelper.getFakeQuiz();
	}
	*/
	
	@RemoteAction
	global static QuizHelper.QuizLaunchModel getQuizLaunchModel(MobileHelper.LearningObjectDetailsRequest learningObjectDetailsRequest){
		return QuizHelper.getQuizLaunchModel(learningObjectDetailsRequest);
	}
	
	@RemoteAction
	global static void saveTemporaryQuizAnswers(QuizHelper.TemporaryQuizAnswers temporaryQuizAnswers){
		QuizHelper.saveTemporaryQuizAnswers(temporaryQuizAnswers);
	}
	
	@RemoteAction
	global static QuizHelper.QuizSubmitResult submitQuiz(QuizHelper.QuizLaunchModel quizLaunchModel){
		return QuizHelper.submitQuiz(quizLaunchModel);
	}

}