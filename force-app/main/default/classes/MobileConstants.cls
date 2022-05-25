public with sharing class MobileConstants {
	public static final String ORDER_BY_TITLE 		= 'title'; 
	public static final String ORDER_BY_TYPE 		= 'objectTypeOrder';	
	public static final String ORDER_BY_STATUS 		= 'statusOrder';
	public static final String ORDER_BY_DUE_DATE 	= 'dueDate';
	public static final String ORDER_BY_DURATION 	= 'duration';
	public static final String ORDER_BY_COMPLETION 	= 'completion';
	public static final String ORDER_BY_SEQUENCE 	= 'sequence';		
	
	public static final String QUIZ_TYPE 			= 'quiz';
	public static final String MODULE_TYPE 			= 'module';
	public static final String COURSE_TYPE 			= 'course';
	public static final String LEARNING_PATH_TYPE 	= 'learningPath';		
	public static final String CURRICULUM_TYPE 		= 'curriculum';
	
	public static final String UNENROLLED_STATUS 	= 'Unenrolled';
	public static final String COMPLETED_STATUS 	= 'Completed';
	public static final String CANCELLED_STATUSD 	= 'Cancelled';
	public static final String IN_PROGRESS_STATUS 	= 'In Progress';
	public static final String PASSED_STATUS 		= 'Passed';
	public static final String ASSIGNED_STATUS 		= 'Assigned';
	public static final String FAILED_STATUS 		= 'Failed';
	public static final String RETIRED_STATUS 		= 'Retired';
	public static final String PAST_DUE_STATUS 		= 'Past Due';
	public static final String NOT_STARTED_STATUS 	= 'Not Started';
	public static final String EMPTY_STATUS 		= '';
	public static final Set<String> COMPLETED_STATUSES = new Set<String>{COMPLETED_STATUS, PASSED_STATUS};
	public static final Set<String> NOT_COMPLETED_STATUSES = new Set<String>{IN_PROGRESS_STATUS, NOT_STARTED_STATUS, EMPTY_STATUS, FAILED_STATUS};
	
	public final static Map<String, String> ENROLL_METHODS = new Map<String, String>{
	        MobileConstants.QUIZ_TYPE => 'assignQuizzes',
	        MobileConstants.MODULE_TYPE => 'assignModules',
	        MobileConstants.COURSE_TYPE => 'assignCourses',
	        MobileConstants.LEARNING_PATH_TYPE => 'assignLearningPaths',
	        MobileConstants.CURRICULUM_TYPE => 'assignCurriculums'
	};
	
	public final static Map<String, String> ENROLL_OBJECT_TYPES = new Map<String, String>{
	        MobileConstants.QUIZ_TYPE => 'quizzes',
	        MobileConstants.MODULE_TYPE => 'modules',
	        MobileConstants.COURSE_TYPE => 'courses',
	        MobileConstants.LEARNING_PATH_TYPE => 'learningPaths',
	        MobileConstants.CURRICULUM_TYPE => 'curriculums'
	};
	
	public static final Map<String, Integer> OBJECT_TYPE_ORDER_WEIGTH = new Map<String, Integer>{
		MODULE_TYPE => 10, 
		QUIZ_TYPE => 20, 
		COURSE_TYPE => 30, 
		LEARNING_PATH_TYPE => 40, 
		CURRICULUM_TYPE => 50};
		
	public static final Map<String, Integer> STATUS_ORDER_WEIGTH = new Map<String, Integer>{
		PAST_DUE_STATUS => 10, 
		NOT_STARTED_STATUS => 20, 
		IN_PROGRESS_STATUS => 30};
	
	
	public static String getJSON(){
		JSONGenerator generator = JSON.createGenerator(true);   
		generator.writeStartObject();               
		generator.writeStringField('ORDER_BY_TITLE', ORDER_BY_TITLE);
		generator.writeStringField('ORDER_BY_TYPE', ORDER_BY_TYPE);
		generator.writeStringField('ORDER_BY_STATUS', ORDER_BY_STATUS);
		generator.writeStringField('ORDER_BY_DUE_DATE', ORDER_BY_DUE_DATE);
		generator.writeStringField('ORDER_BY_DURATION', ORDER_BY_DURATION);
		generator.writeStringField('ORDER_BY_COMPLETION', ORDER_BY_COMPLETION);
		generator.writeStringField('ORDER_BY_SEQUENCE', ORDER_BY_SEQUENCE);		
				
		generator.writeStringField('QUIZ_TYPE', QUIZ_TYPE);
		generator.writeStringField('MODULE_TYPE', MODULE_TYPE);
		generator.writeStringField('COURSE_TYPE', COURSE_TYPE);
		generator.writeStringField('LEARNING_PATH_TYPE', LEARNING_PATH_TYPE);
		generator.writeStringField('CURRICULUM_TYPE', CURRICULUM_TYPE);
		
		generator.writeStringField('UNENROLLED_STATUS', UNENROLLED_STATUS);
		generator.writeStringField('COMPLETED_STATUS', COMPLETED_STATUS);
		generator.writeStringField('CANCELLED_STATUSD', CANCELLED_STATUSD);
		generator.writeStringField('IN_PROGRESS_STATUS', IN_PROGRESS_STATUS);
		generator.writeStringField('PASSED_STATUS', PASSED_STATUS);
		generator.writeStringField('ASSIGNED_STATUS', ASSIGNED_STATUS);
		generator.writeStringField('FAILED_STATUS', FAILED_STATUS);
		generator.writeStringField('RETIRED_STATUS', RETIRED_STATUS);
		generator.writeStringField('PAST_DUE_STATUS', PAST_DUE_STATUS);
		generator.writeStringField('NOT_STARTED_STATUS', NOT_STARTED_STATUS);
		generator.writeStringField('EMPTY_STATUS', EMPTY_STATUS);
		generator.writeEndObject();                 
		return generator.getAsString();
	}
}