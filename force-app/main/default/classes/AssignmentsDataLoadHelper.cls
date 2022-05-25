public with sharing class AssignmentsDataLoadHelper {
    
    public static List<lmscons__Transcript_line__c> getAllAssignments(id userId, String searchStr, Boolean useAvailableForMobileCondition, Boolean useStatusCondition, Set<String> statuses){
		return getAssignments(userId, searchStr, useAvailableForMobileCondition, useStatusCondition, statuses, null, null, null, null);
	}
	
	public static lmscons__Transcript_line__c getAssignment(Id assignmentId){
		List<lmscons__Transcript_Line__c> assignments = getAssignments(null, null, false, false, null, assignmentId, null, null, null);
		if (assignments.isEmpty()){
			return null;
		}
		
		return assignments.get(0);		
	}
	
	public static List<lmscons__Transcript_line__c> getCurriculumAssignments(id userId, String searchStr, Boolean useStatusCondition, Set<String> statuses, Id curriculumAssignmentId){
		return getAssignments(userId, searchStr, false, useStatusCondition, statuses, null, curriculumAssignmentId, null, null);
	}
	
	public static List<lmscons__Transcript_line__c> getLeariningPathAssignments(id userId, String searchStr, Boolean useStatusCondition, Set<String> statuses, Id lpAssignmentId){
		return getAssignments(userId, searchStr, false, useStatusCondition, statuses, null, null, lpAssignmentId, null);
	}
	
	public static List<lmscons__Transcript_line__c> getCourseAssignments(id userId, String searchStr, Boolean useStatusCondition, Set<String> statuses, Id courseAssignmentId){
		return getAssignments(userId, searchStr, false, useStatusCondition, statuses, null, null, null, courseAssignmentId);
	}
	
	public static List<lmscons__Transcript_line__c> getAssignments(id userId, String searchStr, Boolean useAvailableForMobileCondition, Boolean useStatusCondition, Set<String> statuses, 
	                                                               Id assignmentId, Id curriculumAssignmentId, Id lpAssignmentId, Id courseAssignmentId){
		
		String statusCondition = '';	
		
		if (useStatusCondition){
		
			statusCondition = 'AND lmscons__Status__c IN :statuses '+
			'AND (lmscons__Curriculum_Assignment__r.lmscons__Status__c IN :statuses OR lmscons__Curriculum_Assignment__r.lmscons__Status__c = null) '+
			'AND (lmscons__Learning_Path_Assignment__r.lmscons__Status__c IN :statuses OR lmscons__Learning_Path_Assignment__r.lmscons__Status__c = null) '+
			'AND (lmscons__Course_Assignment__r.lmscons__Status__c IN :statuses OR lmscons__Course_Assignment__r.lmscons__Status__c = null) ';
		
		}
		
		String availableForMobileCondition = '';
		
		
		if (useAvailableForMobileCondition){
			availableForMobileCondition = 'AND ((lmscons__Curriculum_Assignment__c <> null AND lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Available_For_Mobile__c = true) ' + 
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c <> null AND lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c = true) ' + 
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c <> null AND lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Available_For_Mobile__c = true)' +
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c = null AND lmscons__Quiz__c <> null AND lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true)' +
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c = null AND lmscons__Quiz__c = null AND lmscons__Training_Content__r.lmscons__Available_For_Mobile__c = true)) ';
		}
		
		/*
		if (useAvailableForMobileCondition){
			availableForMobileCondition = 'AND ((lmscons__Curriculum_Assignment__c = null OR lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Available_For_Mobile__c = true) ' + 
				'AND (lmscons__Learning_Path_Assignment__c = null OR lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c = true) ' + 
				'AND (lmscons__Course_Assignment__c = null OR lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Available_For_Mobile__c = true)' +
				'AND (lmscons__Quiz__c = null OR lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true)' +
				'AND (lmscons__Training_Content__r.lmscons__Available_For_Mobile__c = true)) ';
		}
		*/
				
		String query = 'SELECT '+
				
				' Id,  '+
				
				'lmscons__Curriculum_Assignment__c,  '+				
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.Name, ' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c, ' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Duration__c, ' +				
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c,  '+															
				'lmscons__Curriculum_Assignment__r.lmscons__Due_Date__c, '+
				'lmscons__Curriculum_Assignment__r.lmscons__Completion_Date__c, '+				
				'lmscons__Curriculum_Assignment__r.lmscons__Status__c, '+
				'lmscons__Curriculum_Item__r.lmscons__Sequence__c,' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Available_For_Mobile__c,'+
				
				
				'lmscons__Learning_Path_Assignment__c,' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.Name, ' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c, ' +				
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Duration__c, ' +							
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c, '+
				'lmscons__Learning_Path_Assignment__r.lmscons__Due_Date__c, ' +		
				'lmscons__Learning_Path_Assignment__r.lmscons__Completion_Date__c, '+		
				'lmscons__Learning_Path_Assignment__r.lmscons__Status__c, '+
				'lmscons__Learning_Path_Item__r.lmscons__Sequence__c,' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c,'+
				
								
				'lmscons__Course_Assignment__c, ' +				
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.Name, ' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Description__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Duration__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Progress_Training_path__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Due_Date__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Completion_Date__c, '+
				'lmscons__Course_Assignment__r.lmscons__Status__c, ' +
				'lmscons__Training_Path_Item__r.lmscons__Sequence__c,' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Available_For_Mobile__c,' + 
								
				
				'lmscons__Quiz__c, '+						
				'lmscons__Quiz__r.Name, '+
				'lmscons__Quiz__r.lmscons__Description__c, '+
				'lmscons__Quiz__r.lmscons__Duration__c, ' +
				'lmscons__Quiz__r.lmscons__Max_Attempts__c, ' +
				'lmscons__Quiz__r.lmscons__Available_For_Mobile__c, ' +	
				
				'lmscons__Training_Content__c,  '+
				'lmscons__Training_Content__r.lmscons__Title__c, '+
				'lmscons__Training_Content__r.lmscons__Description__c, ' +
				'lmscons__Training_Content__r.lmscons__Duration__c, ' +
				'lmscons__Training_Content__r.lmscons__Available_For_Mobile__c, ' +
																							
				'lmscons__Progress__c ,' +
				'lmscons__Due_Date__c ,' +
				'lmscons__Status__c,  '+
				'lmscons__Score__c, '+
				'lmscons__Attempts__c, '+				
				'lmscons__Percent_Complete__c,  '+					
				'lmscons__Completion_Date__c,  '+
				'lmscons__Completed_Date__c, '+
				'lmscons__Training_User_License__c '+				
				
			'FROM lmscons__Transcript_line__c '+			
			'WHERE lmscons__Is_Historical__c = false ' + 
			notILT() + 
			((!Test.isRunningTest()) ? 'AND lmscons__Quiz__c = null ' : '')  +                          // !!!!!!!!!!!!!! WITHOUT QUIZZES !!!!!!!!!!!!!!!!!!!!!!
			availableForMobileCondition + 			 
			(userId == null ? '' : 'AND lmscons__Transcript__r.lmscons__Trainee__c =:userId ') +			 
			statusCondition +			
			(assignmentId == null ? '' : 'AND Id = :assignmentId ') +
			(curriculumAssignmentId == null ? '' : 'AND lmscons__Curriculum_Assignment__c = :curriculumAssignmentId ') + 			
			(lpAssignmentId == null ? '' : 'AND lmscons__Learning_Path_Assignment__c = :lpAssignmentId ') +
			(courseAssignmentId == null ? '' : 'AND lmscons__Course_Assignment__c = :courseAssignmentId ') +
			getSearchCriteries(searchStr);				
		
			System.debug('query = ');
			System.debug(query);
		
		try{	
			return Database.query(query);
		} catch (Exception e){
			throw new MobileHelper.MobileException('[getAssignments] Query exception. ' + e.getMessage());
		}		
	}
	
	
	public static List<lmscons__Transcript_line__c> getContainerAssignments(id userId, Boolean useAvailableForMobileCondition, Boolean useStatusCondition, Set<String> statuses, 
	                                                               Id assignmentId, Id curriculumAssignmentId, Id lpAssignmentId, Id courseAssignmentId, 
	                                                               Boolean useCurriculumAssignment, Boolean useLPAssignment, Boolean useCourseAssignment){
		
		String statusCondition = '';	
		
		if (useStatusCondition){
		
			statusCondition = 'AND lmscons__Status__c IN :statuses '+
			'AND (lmscons__Curriculum_Assignment__r.lmscons__Status__c IN :statuses OR lmscons__Curriculum_Assignment__r.lmscons__Status__c = null) '+
			'AND (lmscons__Learning_Path_Assignment__r.lmscons__Status__c IN :statuses OR lmscons__Learning_Path_Assignment__r.lmscons__Status__c = null) '+
			'AND (lmscons__Course_Assignment__r.lmscons__Status__c IN :statuses OR lmscons__Course_Assignment__r.lmscons__Status__c = null) ';
		
		}
		
		String availableForMobileCondition = '';
		
		if (useAvailableForMobileCondition){
			availableForMobileCondition = 'AND ((lmscons__Curriculum_Assignment__c <> null AND lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Available_For_Mobile__c = true) ' + 
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c <> null AND lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c = true) ' + 
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c <> null AND lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Available_For_Mobile__c = true)' +
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c = null AND lmscons__Quiz__c <> null AND lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true)' +
				'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c = null AND lmscons__Quiz__c = null AND lmscons__Training_Content__r.lmscons__Available_For_Mobile__c = true)) ';
		}
				
		String query = 'SELECT '+
				
				' Id,  '+
				
				'lmscons__Curriculum_Assignment__c,  '+				
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.Name, ' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c, ' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Duration__c, ' +				
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c,  '+															
				'lmscons__Curriculum_Assignment__r.lmscons__Due_Date__c, '+
				'lmscons__Curriculum_Assignment__r.lmscons__Completion_Date__c, '+				
				'lmscons__Curriculum_Assignment__r.lmscons__Status__c, '+
				'lmscons__Curriculum_Item__r.lmscons__Sequence__c,' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Available_For_Mobile__c,'+
				
				
				'lmscons__Learning_Path_Assignment__c,' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.Name, ' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c, ' +				
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Duration__c, ' +							
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c, '+
				'lmscons__Learning_Path_Assignment__r.lmscons__Due_Date__c, ' +		
				'lmscons__Learning_Path_Assignment__r.lmscons__Completion_Date__c, '+		
				'lmscons__Learning_Path_Assignment__r.lmscons__Status__c, '+
				'lmscons__Learning_Path_Item__r.lmscons__Sequence__c,' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c,'+
				
								
				'lmscons__Course_Assignment__c, ' +				
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.Name, ' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Description__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Duration__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Progress_Training_path__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Due_Date__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Completion_Date__c, '+
				'lmscons__Course_Assignment__r.lmscons__Status__c, ' +
				'lmscons__Training_Path_Item__r.lmscons__Sequence__c,' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Available_For_Mobile__c,' + 
								
				
				'lmscons__Quiz__c, '+						
				'lmscons__Quiz__r.Name, '+
				'lmscons__Quiz__r.lmscons__Description__c, '+
				'lmscons__Quiz__r.lmscons__Duration__c, ' +
				'lmscons__Quiz__r.lmscons__Max_Attempts__c, ' +
				'lmscons__Quiz__r.lmscons__Available_For_Mobile__c, ' +	
				
				'lmscons__Training_Content__c,  '+
				'lmscons__Training_Content__r.lmscons__Title__c, '+
				'lmscons__Training_Content__r.lmscons__Description__c, ' +
				'lmscons__Training_Content__r.lmscons__Duration__c, ' +
				'lmscons__Training_Content__r.lmscons__Available_For_Mobile__c, ' +
																							
				'lmscons__Progress__c ,' +
				'lmscons__Due_Date__c ,' +
				'lmscons__Status__c,  '+
				'lmscons__Score__c, '+
				'lmscons__Attempts__c, '+				
				'lmscons__Percent_Complete__c,  '+					
				'lmscons__Completion_Date__c,  '+
				'lmscons__Completed_Date__c, '+
				'lmscons__Training_User_License__c '+				
				
			'FROM lmscons__Transcript_line__c '+			
			'WHERE lmscons__Is_Historical__c = false ' + 
			notILT() + 
			((!Test.isRunningTest()) ? 'AND lmscons__Quiz__c = null ' : '')  +                          // !!!!!!!!!!!!!! WITHOUT QUIZZES !!!!!!!!!!!!!!!!!!!!!!
			availableForMobileCondition + 			 
			(userId == null ? '' : 'AND lmscons__Transcript__r.lmscons__Trainee__c =:userId ') +			 
			statusCondition +			
			(assignmentId == null ? '' : 'AND Id = :assignmentId ') +
			(useCurriculumAssignment ? 'AND lmscons__Curriculum_Assignment__c = :curriculumAssignmentId ' : '') + 			
			(useLPAssignment ? 'AND lmscons__Learning_Path_Assignment__c = :lpAssignmentId ' : '') +
			(useCourseAssignment ? 'AND lmscons__Course_Assignment__c = :courseAssignmentId' : '');
		
			System.debug('query = ');
			System.debug(query);
		
		try{	
			return Database.query(query);
		} catch (Exception e){
			throw new MobileHelper.MobileException('[getAssignments] Query exception. ' + e.getMessage());
		}		
	}
	
	private static String notILT(){
	    if (MobileHelper.isILT()){
	        return ' AND lmsilt__Event__c = null AND lmsilt__Development_Plan_Task__c = null AND lmsilt__Dev_Plan_Assignment__c = null ';    
	    }
	    
	    return '';
	}
	
	public static List<lmscons__Transcript_line__c> getAssignments(id userId, Set<Id> curriculums, Set<Id> learningPaths, Set<Id> courses, Set<Id> modules, Set<Id> quizzes){
			
		String emptyId = '';
											
		String query = 'SELECT '+
				
				' Id,  '+
				
				'lmscons__Curriculum_Assignment__c,  '+				
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.Name, ' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c, ' +
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Duration__c, ' +				
				'lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c,  '+															
				'lmscons__Curriculum_Assignment__r.lmscons__Due_Date__c, '+
				'lmscons__Curriculum_Assignment__r.lmscons__Completion_Date__c, '+				
				'lmscons__Curriculum_Assignment__r.lmscons__Status__c, '+
				'lmscons__Curriculum_Item__r.lmscons__Sequence__c,' +
				
				
				'lmscons__Learning_Path_Assignment__c,' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.Name, ' +
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c, ' +				
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Duration__c, ' +							
				'lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c, '+
				'lmscons__Learning_Path_Assignment__r.lmscons__Due_Date__c, ' +		
				'lmscons__Learning_Path_Assignment__r.lmscons__Completion_Date__c, '+		
				'lmscons__Learning_Path_Assignment__r.lmscons__Status__c, '+
				'lmscons__Learning_Path_Item__r.lmscons__Sequence__c,' +
				
								
				'lmscons__Course_Assignment__c, ' +				
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.Name, ' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Description__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Duration__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Progress_Training_path__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Due_Date__c, ' +
				'lmscons__Course_Assignment__r.lmscons__Completion_Date__c, '+
				'lmscons__Course_Assignment__r.lmscons__Status__c, ' +
				'lmscons__Training_Path_Item__r.lmscons__Sequence__c,' +
								
				
				'lmscons__Quiz__c, '+						
				'lmscons__Quiz__r.Name, '+
				'lmscons__Quiz__r.lmscons__Description__c, '+
				'lmscons__Quiz__r.lmscons__Duration__c, ' +	
				'lmscons__Quiz__r.lmscons__Max_Attempts__c, ' +	
				
				'lmscons__Training_Content__c,  '+
				'lmscons__Training_Content__r.lmscons__Title__c, '+
				'lmscons__Training_Content__r.lmscons__Description__c, ' +
				'lmscons__Training_Content__r.lmscons__Duration__c, ' +
				'lmscons__Training_Content__r.lmscons__Available_For_Mobile__c, '+
																							
				'lmscons__Progress__c ,' +
				'lmscons__Due_Date__c ,' +
				'lmscons__Status__c,  '+
				'lmscons__Score__c, '+
				'lmscons__Attempts__c, '+				
				'lmscons__Percent_Complete__c,  '+					
				'lmscons__Completion_Date__c,  '+
				'lmscons__Completed_Date__c, '+
				'lmscons__Training_User_License__c '+				
				
			'FROM lmscons__Transcript_line__c '+			
			'WHERE lmscons__Is_Historical__c = false ' + 
			notILT() +
			(userId == null ? '' : 'AND lmscons__Transcript__r.lmscons__Trainee__c =:userId ') +
			'AND ( id = :emptyId ' +			 					
			(curriculums == null || curriculums.isEmpty() ? '' : 'OR (lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c IN :curriculums) ') +
			(learningPaths == null || learningPaths.isEmpty() ? '' : 'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c IN :learningPaths) ') + 			
			(courses == null || courses.isEmpty() ? '' : 'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__r.lmscons__Training_Path__c IN :courses) ') +
			(modules == null || modules.isEmpty() ? '' : 'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c = null AND lmscons__Quiz__c = null AND lmscons__Training_Content__c IN :modules) ') +
			(quizzes == null || quizzes.isEmpty() ? '' : 'OR (lmscons__Curriculum_Assignment__c = null AND lmscons__Learning_Path_Assignment__c = null AND lmscons__Course_Assignment__c = null AND lmscons__Quiz__c IN :quizzes) ')+
			')';
		
			System.debug('query = ');
			System.debug(query);
		
		try{	
			return Database.query(query);
		} catch (Exception e){
			throw new MobileHelper.MobileException('[getAssignments] Query exception. ' + e.getMessage());
		}		
	}		
	
	private static String getSearchCriteries(String searchStr){

		if (searchStr == null || String.isEmpty(searchStr.trim())){
			return '';
		}

		searchStr = String.escapeSingleQuotes(searchStr);

		// We must get condition like this:
		//'  AND ((condition) OR (condition) OR (condition))'.

		// condition templates.
		List<String> conditionsList = new List<String>();
		conditionsList.Add('lmscons__Curriculum_Assignment__r.lmscons__Title__c LIKE \'\'%{0}%\'\'');
		conditionsList.Add('lmscons__Curriculum_Assignment__c=NULL AND lmscons__Learning_Path_Assignment__r.lmscons__Title__c LIKE \'\'%{0}%\'\'');
		conditionsList.Add('lmscons__Curriculum_Assignment__c=NULL AND lmscons__Learning_Path_Assignment__c=NULL AND lmscons__Training_Path_Item__r.lmscons__Training_Path__r.Name LIKE \'\'%{0}%\'\'');
		conditionsList.Add('lmscons__Curriculum_Assignment__c=NULL AND lmscons__Learning_Path_Assignment__c=NULL AND lmscons__Training_Path_Item__c=NULL AND lmscons__Training_Content__r.lmscons__Title__c LIKE \'\'%{0}%\'\'');

		// final condition.
		String allCondition = '';
		List<String> placeHolder = new List<String>{searchStr};

		// build condition string.
		for(String condition: conditionsList){
			allCondition += '(' + String.format(condition, placeHolder) + ') OR ';
		}

		// remove last OR in all condition.
		allCondition = allCondition.left(allCondition.length() - 4);

		allCondition = ' AND (' + allCondition + ') ';

		return allCondition;
	}
}