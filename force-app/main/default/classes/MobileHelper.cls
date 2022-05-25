global with sharing class MobileHelper {

	// Base wrappers.
	global virtual class BaseItem{
		public String id {get; set;}			
		public String objectType {get; set {this.objectType = value; this.objectTypeOrder = MobileConstants.OBJECT_TYPE_ORDER_WEIGTH.get(this.objectType);}}
		public String title {get; set;}
		public String description {get; set;}
		public Decimal duration {get; set { this.duration = value; this.durationFormatted = formatDuration(this.duration);}}
		public Decimal sequence {get; set;}
		
		// calculated props.
		public String durationFormatted {get; private set;}
		public Integer objectTypeOrder {get; private set;}
	}
	
	global abstract class BaseViewModel{
	    global BaseViewModel(){
	        this.isCFSUser = isCFSUser();
		}
		
		public Boolean isCFSUser {get; private set;}
	}
	
	global abstract class BaseLearningModel extends BaseViewModel{
		public BaseLearningModel(){
			this.items = new List<BaseItem>();
		}
		
		public Integer totalItems;
		public List<BaseItem> items;	
	} 
	
	global abstract class BaseLearningObjectRequest{
		public String id;		
		public String objectType;
		public String assignmentId;		
		public Boolean top;
		
		public String courseAssignmentId {get; set {courseAssignmentId = value == '' ? null : value;}}
		public String learningPathAssignmentId {get; set {learningPathAssignmentId = value == '' ? null : value;}}
		public String curriculumAssignmentId {get; set {curriculumAssignmentId = value == '' ? null : value;}}
	}
	
	global abstract class BaseRequest{
	    public String reqId; // request id, for cache.
		public String searchStr;
		public String orderBy;
		public Boolean ascending;
	}
	
    
    // Shared wrappers
    global class Item extends BaseItem{		
		public String containerAssignmentId {get; set;}					
		public String status {get; set {this.status = value; this.statusOrder = MobileConstants.STATUS_ORDER_WEIGTH.get(this.status);}}					
		public Date dueDate {get; set{this.dueDate = value; this.dueDateFormatted = formatDate(this.dueDate); isDueDatePassed = value == null ? false : value < Date.today();}}					
		public DateTime completedDate {get; set{this.completedDate = value; this.completedDateFormatted = formatDateTime(this.completedDate);}}
		public String score {get; set;}					
		public String nextSession {get; set;}					
		public String progress {get; set;}								
		
		public String courseAssignmentId {get; set {courseAssignmentId = value == null ? '' : value;}}
		public String learningPathAssignmentId {get; set {learningPathAssignmentId = value == null ? '' : value;}}
		public String curriculumAssignmentId {get; set {curriculumAssignmentId = value == null ? '' : value;}}
		
		// calculated props.
		public String dueDateFormatted {get; private set;}					
		public Boolean isDueDatePassed {get; private set;}				
		public String completedDateFormatted {get; private set;}					
		public Integer statusOrder {get; private set;}					
	}

    
    // My Learing wrappers.
    global class MyLearningRequest extends BaseRequest{}	
    global class MyLearningModel extends BaseLearningModel{}	


    // Find Learning wrappers.
    global class FindLearningRequest extends BaseRequest{}	
    global class FindLearningModel extends BaseLearningModel{}		
    
    
    // Completed Learning wrappers.
    global class CompletedLearningRequest extends BaseRequest{}  
    global class CompletedLearningModel extends BaseLearningModel{}		
    
    
    // Containre Details wrappers.
    global class ContainerDetailsRequest extends BaseLearningObjectRequest{}	
    global class ContainerDetailsModel extends BaseLearningModel{				
		public BaseItem parent;			
		public Boolean canEnroll;				
	}
	
	
    // Module Details wrappers.
    global class LearningObjectDetailsRequest extends BaseLearningObjectRequest{} 	
    global class ModuleDetailsModel extends BaseViewModel{					
		public BaseItem item;
		public Boolean assigned;
		public Boolean canEnroll;
		public Boolean canLaunch;
	}
    
    
    // Launch wrappers.
    global class LaunchRequest{
	    public String assignmentId;
	}
    
    global class LaunchModel extends BaseViewModel{
        public String launchLink;
	}
    
    
    // Enroll wrappers.
	global class EnrollRequest{
	    public String id;
	    public String objectType;
	}
	
	global class EnrollResult extends BaseViewModel{
	    public Boolean success;
	    public BaseItem item;
	    public String errorMessage;
	}
	
	
	// Deserialize wrappers. (use for deserialize JSON);
	class JSONObject {
		String selectedObjecID;
		String parentObjectID;
		String userID;
		String objectType;
		String assignmentID;
		String sequenceMessage;
		String prereqMessage;
	}
	
	
	// Custom Exceptions.
	global class MobileException extends Exception {}
	


    // My Learning.
	public static MyLearningModel getMyLearningModel(MyLearningRequest myLearningRequest){
	    MyLearningModel myLearningModel = new MyLearningModel();
	    if (!myLearningModel.isCFSUser){
	        return myLearningModel;
	    }
	    
	    List<lmscons__Transcript_line__c> assignments = AssignmentsDataLoadHelper.getAllAssignments(UserInfo.getUserId(), myLearningRequest.searchStr, true, true, MobileConstants.NOT_COMPLETED_STATUSES);
	    
	    // CYBCORLMSI-1205. temporarily. without status condition.
	    //List<lmscons__Transcript_line__c> assignments = AssignmentsDataLoadHelper.getAllAssignments(UserInfo.getUserId(), myLearningRequest.searchStr, true, FALSE, MobileConstants.NOT_COMPLETED_STATUSES);
	    
		List<Item> items = getTopLevelItems(assignments, null, false);
		MyLearningModel.items = items;
		MyLearningModel.totalItems = myLearningModel.items.size(); 
		
		return myLearningModel;	
	}
	
	
	// Find learning.
	public static FindLearningModel getFindLearningModel(FindLearningRequest findLearningRequest){
	    FindLearningModel findLearningModel = new FindLearningModel();		
	    if (!findLearningModel.isCFSUser){
	        return findLearningModel;
	    }
	    
		Set<Id> catalogs = CatalogDataLoadHelper.getCurentUserCatalogsSet();
		List<BaseItem> items = CatalogDataLoadHelper.getTopCatalogItems(catalogs, findLearningRequest.searchStr);
		
		items = appendAssignStatuses(items);
	
		findLearningModel.items = items;
		findLearningModel.totalItems = findLearningModel.items.size(); 
		
		return findLearningModel;	
	}
	
	
	// Completed Learning.
	public static CompletedLearningModel getCompletedLearningModel(CompletedLearningRequest completedLearningRequest){
	    CompletedLearningModel completedLearningModel = new CompletedLearningModel();		
	    if (!completedLearningModel.isCFSUser){
	        return completedLearningModel;
	    }
	    
	    List<lmscons__Transcript_line__c> assignments = AssignmentsDataLoadHelper.getAllAssignments(UserInfo.getUserId(), completedLearningRequest.searchStr, true, true, MobileConstants.COMPLETED_STATUSES);
		List<Item> items = getTopLevelItems(assignments, null, false); 		
		
		completedLearningModel.items = items;
		completedLearningModel.totalItems = completedLearningModel.items.size(); 
		
		return completedLearningModel;		
	}
	
	
	// Container Details.
	public static ContainerDetailsModel getContainerDetailsModel(ContainerDetailsRequest containerDetailsRequest){
		
		ContainerDetailsModel containerDetailsModel = new ContainerDetailsModel();
		if (!containerDetailsModel.isCFSUser){
		    return containerDetailsModel;
		}
		
		if (containerDetailsRequest.assignmentId != null && !String.isEmpty(containerDetailsRequest.assignmentId)){
		
			List<lmscons__Transcript_line__c> assignments; 
		    
			if (MobileConstants.CURRICULUM_TYPE.equals(containerDetailsRequest.objectType)){
			    assignments = AssignmentsDataLoadHelper.getContainerAssignments(UserInfo.getUserId(), false, false, null, null, 
			        containerDetailsRequest.curriculumAssignmentId, 
			        containerDetailsRequest.learningPathAssignmentId, 
			        containerDetailsRequest.courseAssignmentId, true, false, false);
			} else if (MobileConstants.LEARNING_PATH_TYPE.equals(containerDetailsRequest.objectType)){
			    assignments = AssignmentsDataLoadHelper.getContainerAssignments(UserInfo.getUserId(), false, false, null, null, 
			        containerDetailsRequest.curriculumAssignmentId, 
			        containerDetailsRequest.learningPathAssignmentId, 
			        containerDetailsRequest.courseAssignmentId, true, true, false);
			} else if (MobileConstants.COURSE_TYPE.equals(containerDetailsRequest.objectType)){
			    assignments = AssignmentsDataLoadHelper.getContainerAssignments(UserInfo.getUserId(), false, false, null, null, 
			        containerDetailsRequest.curriculumAssignmentId, 
			        containerDetailsRequest.learningPathAssignmentId, 
			        containerDetailsRequest.courseAssignmentId, true, true, true);
			} else{
				throw new MobileException('[getContainerDetailsModel] Unknown parent type = ' + containerDetailsRequest.objectType);
			}
			
			
			List<Item> items = getTopLevelItems(assignments, containerDetailsRequest.objectType, true);				 
		
			containerDetailsModel.parent = getParentItem(assignments, containerDetailsRequest.objectType, containerDetailsRequest.assignmentId);		
			containerDetailsModel.items = items;
			containerDetailsModel.totalItems = containerDetailsModel.items.size();			
		} else{
									
			// 1. get learning object.
			// 2. get LO items.
			// 4. check if parent in catalog and is it top LO. 
			// 3. fill containerDetailsModel.		
			
			containerDetailsModel.parent = getBaseItemFromLearningObject(containerDetailsRequest.id, containerDetailsRequest.objectType);						 				
			containerDetailsModel.items = getLearningObjectItems(containerDetailsRequest.id, containerDetailsRequest.objectType);
			containerDetailsModel.totalItems = containerDetailsModel.items.size();			
			containerDetailsModel.canEnroll = containerDetailsRequest.top == true && containerDetailsModel.totalItems > 0;					
		}							
				
		return containerDetailsModel;	
	}
	
	
	// Module Details.
	public static ModuleDetailsModel getModuleDetailsModel(LearningObjectDetailsRequest learningObjectDetailsRequest){
		
		ModuleDetailsModel moduleDetailsModel = new ModuleDetailsModel();		
		if (!moduleDetailsModel.isCFSUser){
		    return moduleDetailsModel;
		}
		
		if (learningObjectDetailsRequest.assignmentId != null && !String.isEmpty(learningObjectDetailsRequest.assignmentId)){
			lmscons__Transcript_Line__c assignment = AssignmentsDataLoadHelper.getAssignment(learningObjectDetailsRequest.assignmentId);
			if (assignment != null){				
				moduleDetailsModel.item = fillItemFromTranscriptLine(new Item(), learningObjectDetailsRequest.objectType, null, assignment); 
				moduleDetailsModel.assigned = true;
				moduleDetailsModel.canEnroll = false;												
				
				 				
				String prerequirsitesAndSequences = lmscons.MyTrainingExtension.buttonsInfo(assignment.Id);
				JSONObject prerequirsitesAndSequencesObj; 
				try{
					prerequirsitesAndSequencesObj = (JSONObject)JSON.deserialize(prerequirsitesAndSequences, JSONObject.class);	
				} catch (Exception e){
					prerequirsitesAndSequencesObj = null;
					System.debug(e);
				}
				System.debug(prerequirsitesAndSequencesObj);
				moduleDetailsModel.canLaunch = (prerequirsitesAndSequencesObj != null 
					&& 
					(prerequirsitesAndSequencesObj.sequenceMessage == null || String.isEmpty(prerequirsitesAndSequencesObj.sequenceMessage))
					&&
					(prerequirsitesAndSequencesObj.prereqMessage == null || String.isEmpty(prerequirsitesAndSequencesObj.prereqMessage)));
				
				// check quiz attempts.
				if (moduleDetailsModel.canLaunch && MobileConstants.QUIZ_TYPE.equals(learningObjectDetailsRequest.objectType)){
				    moduleDetailsModel.canLaunch = QuizHelper.canLaunchQuiz(assignment.lmscons__Quiz__r, assignment.lmscons__Attempts__c);
				}
				 
				return  moduleDetailsModel;	  												
			}						
		}
		
		moduleDetailsModel.item = getBaseItemFromLearningObject(learningObjectDetailsRequest.id, learningObjectDetailsRequest.objectType); // throws exception if LO not found.
		
		moduleDetailsModel.assigned = false;
		moduleDetailsModel.canEnroll = learningObjectDetailsRequest.top; //CatalogDataLoadHelper.isLearningObjectInCatalog(module.Id, MobileConstants.MODULE_TYPE);		
		
		return moduleDetailsModel;
	}
	
	
	// Launch.
	public static LaunchModel getLaunchModel(LaunchRequest launchRequest){
	    LaunchModel launchModel = new LaunchModel();	
	    if (!launchModel.isCFSUser){
	        return launchModel;
	    }
	
		if (launchRequest.assignmentId != null && !String.isEmpty(launchRequest.assignmentId)){
			lmscons__Transcript_Line__c assignment = AssignmentsDataLoadHelper.getAssignment(launchRequest.assignmentId);
			if (assignment != null){				
				launchModel.launchLink = getLaunchUrl(assignment.lmscons__Training_User_License__c);
				return launchModel;
			} else{
		        throw new MobileException('[getLaunchModel] Not found assignment with id = ' + launchRequest.assignmentId);		
			}
		} else{
		    throw new MobileException('[getLaunchModel] Assignment id is null!');
		}
	}
	
	@TestVisible
	private static String getLaunchUrl(Id trainingUserLicense){
	    String url;
	    try{
	        url = lmscons.ConsumerDirectorLaunchLink.getLaunchLink(trainingUserLicense);    
	    } catch(Exception e){
	        throw new MobileException('[getLaunchUrl]  Could not get the launch link. Error: ' + e.getMessage());		
	    } 
	    
	    if (url != null && url.indexOf('[000]') != -1){
	        url = url.replace('[000] ', '');
	    }
	    
	    if (url == null || String.isEmpty(url)){
	        throw new MobileException('[getLaunchUrl]  Could not get the launch link.');		
	    } 
	    
	    return url;
	}
	
	// Enroll.
	public static EnrollResult enroll(EnrollRequest enrollRequest){
	    
	    EnrollResult result = new EnrollResult();
	    if (!result.isCFSUser){
	        return result;
	    }
	    
	    if (enrollRequest == null || enrollRequest.id == null || String.isEmpty(enrollRequest.id) || enrollRequest.objectType == null || String.isEmpty(enrollRequest.objectType)){
	        throw new MobileException('[enroll] EnrollRequest is empty!');
	    }
	    
	    try{
	        if (!EnrollHelper.enroll(enrollRequest.id, enrollRequest.objectType)){
	            result.success = false;
	            result.errorMessage = 'Unknown error';
	            return result;
	        } 
	        
	        BaseItem baseItem = new BaseItem();
            baseItem.id = enrollRequest.id;
            baseItem.objectType = enrollRequest.objectType;
            List<BaseItem> items = appendAssignStatuses(new List<BaseItem>{baseItem});
            
            System.debug('items.size() -> ' + items.size());
            System.debug('items -> ' + items);
            
            if (!items.isEmpty()){
                result.item = items.get(0);    
            }
            
            result.success = true;
	        
	    } catch(Exception e){
	        result.success = false;
	        result.errorMessage = e.getMessage();
	    } 
	    
	    System.debug('result -> ' + result);
	    
	    return result;
	}
	
	// Gets base items and replace with Item, if assignments are exists.
	private static List<BaseItem> appendAssignStatuses(List<BaseItem> items){				
		
		Set<Id> curriculums = new Set<Id>();
		Set<Id> learningPaths = new Set<Id>();
		Set<Id> courses = new Set<Id>();
		Set<Id> modules = new Set<Id>();
		Set<Id> quizzes = new Set<Id>();
		Map<Id, BaseItem> baseItemsMap = new Map<Id, BaseItem>();
		
		for(BaseItem item : items){
			if (MobileConstants.CURRICULUM_TYPE.equals(item.objectType)){
				curriculums.add(item.id);
				baseItemsMap.put(item.id, item);	
			} else if (MobileConstants.LEARNING_PATH_TYPE.equals(item.objectType)){
				learningPaths.add(item.id);
				baseItemsMap.put(item.id, item);
			} else if (MobileConstants.COURSE_TYPE.equals(item.objectType)){
				courses.add(item.id);
				baseItemsMap.put(item.id, item);
			} else if (MobileConstants.MODULE_TYPE.equals(item.objectType)){
				modules.add(item.id);
				baseItemsMap.put(item.id, item);
			} else if (MobileConstants.QUIZ_TYPE.equals(item.objectType)){
				quizzes.add(item.id);
				baseItemsMap.put(item.id, item);
			} else{
				throw new MobileException('[appendAssignStatuses] Unknown object type = ' + item.objectType);
			}						
		}			
						
		List<lmscons__Transcript_line__c> assignments = AssignmentsDataLoadHelper.getAssignments(UserInfo.getUserId(), curriculums, learningPaths, courses, modules, quizzes);
		
		List<BaseItem> result = new List<BaseItem>();
		
		for(lmscons__Transcript_line__c assignment : assignments){
			Item newItem = new Item(); 
			String objectType = getObjectType(assignment, null);
			fillItemFromTranscriptLine(newItem, objectType, null, assignment);
			
			// copy sequence and replace BaseItem with Item, that contains assign status information. 
			BaseItem oldItem = baseItemsMap.get(newItem.id);
			if (oldItem !=null ){
				newItem.sequence = oldItem.sequence;
				baseItemsMap.put(newItem.id, newItem);
			} 			
		}
		
		return baseItemsMap.values();	
	}
	
	
	private static BaseItem getBaseItemFromLearningObject(String objectId, String objectType){
		BaseItem item = new BaseItem();
		item.id = objectId;
		item.objectType = objectType;
		if (MobileConstants.CURRICULUM_TYPE.equals(objectType)){
			List<lmscons__Curriculum__c> curriculums = [SELECT Id, Name, lmscons__Description__c, lmscons__Duration__c FROM lmscons__Curriculum__c WHERE Id = :objectId];
			if (curriculums.isEmpty()){
				throw new MobileException('[getBaseItemFromLearningObject] curriculum not found. Id = ' + objectId);
			}	
			lmscons__Curriculum__c curriculum = curriculums.get(0);
			item.id = curriculum.Id;
			item.title = curriculum.Name;
			item.description = curriculum.lmscons__Description__c;
			item.duration = curriculum.lmscons__Duration__c;
			return item;						
		} else if (MobileConstants.LEARNING_PATH_TYPE.equals(objectType)){
			List<lmscons__Learning_Path__c> learningPaths = [SELECT Id, Name, lmscons__Description__c, lmscons__Duration__c FROM lmscons__Learning_Path__c WHERE Id = :objectId];
			if (learningPaths.isEmpty()){
				throw new MobileException('[getBaseItemFromLearningObject] learning path not found. Id = ' + objectId);
			}	
			lmscons__Learning_Path__c learningPath = learningPaths.get(0);
			item.id = learningPath.Id;
			item.title = learningPath.Name;
			item.description = learningPath.lmscons__Description__c;
			item.duration = learningPath.lmscons__Duration__c;
			return item;
		} else if (MobileConstants.COURSE_TYPE.equals(objectType)){
			List<lmscons__Training_Path__c> courses = [SELECT Id, Name, lmscons__Description__c, lmscons__Duration__c FROM lmscons__Training_Path__c WHERE Id = :objectId];
			if (courses.isEmpty()){
				throw new MobileException('[getBaseItemFromLearningObject] course not found. Id = ' + objectId);
			}	
			lmscons__Training_Path__c course = courses.get(0);
			item.id = course.Id;
			item.title = course.Name;
			item.description = course.lmscons__Description__c;
			item.duration = course.lmscons__Duration__c;
			return item;	
		} else if (MobileConstants.MODULE_TYPE.equals(objectType)){
	        lmscons__Training_Content__c module = getTrainingContent(objectId);
	        if (module == null){
	            throw new MobileException('[getBaseItemFromLearningObject] module not found. Id = ' + objectId);
	        }
	        
    		item.title = module.lmscons__Title__c;
    		item.description = module.lmscons__Description__c;	
    		item.duration = module.lmscons__Duration__c;
    		return item;
	    } else if (MobileConstants.QUIZ_TYPE.equals(objectType)){
	        lmscons__Quiz__c quiz = getQuiz(objectId);
	        if (quiz == null){
	            throw new MobileException('[getBaseItemFromLearningObject] quiz not found. Id = ' + objectId);
	        }
	        
    		item.title = quiz.Name;
    		item.description = quiz.lmscons__Description__c;	
    		item.duration = quiz.lmscons__Duration__c; 
    		return item;
	    }
		 
		throw new MobileException('[getBaseItemFromLearningObject] Unknown object type = ' + objectType);		
	}
	
	private static List<BaseItem> getLearningObjectItems(String objectId, String objectType){
		
		List<BaseItem> items;
		
		if (MobileConstants.CURRICULUM_TYPE.equals(objectType)){
			items = getItemsFromCurriculum(objectId);							
		} else if (MobileConstants.LEARNING_PATH_TYPE.equals(objectType)){
			items = getItemsFromLearningPath(objectId);
		} else if (MobileConstants.COURSE_TYPE.equals(objectType)){
			items = getItemsFromCourse(objectId);	
		} else{
			throw new MobileException('[getLearningObjectItems] Unknown object type = ' + objectType);
		}
		
		items = appendAssignStatuses(items);	
		
		return items;
	}
	
	public static Boolean isILT(){
	    return Type.forName('lmsilt__Development_Plan_Task__c') != null;
	}
	
	@TestVisible
	private static List<BaseItem> getItemsFromCurriculum(String curriculumId){
		List<lmscons__Curriculum_Item__c> curriculumItems = Database.query('SELECT '+
				'Id, '+ 
				'lmscons__Curriculum__c, '+
				'lmscons__Learning_Path__c, '+
				'lmscons__Learning_Path__r.Name, '+
				'lmscons__Learning_Path__r.lmscons__Description__c, '+
				'lmscons__Learning_Path__r.lmscons__Duration__c, '+
				'lmscons__Course__c, '+												
				'lmscons__Course__r.Name, '+
				'lmscons__Course__r.lmscons__Description__c, '+
				'lmscons__Course__r.lmscons__Duration__c,  '+
				'lmscons__Module__c, '+
				'lmscons__Module__r.lmscons__Title__c, '+
				'lmscons__Module__r.lmscons__Description__c, '+
				'lmscons__Module__r.lmscons__Duration__c, '+
				'lmscons__Quiz__c, '+
				'lmscons__Quiz__r.Name, '+
				'lmscons__Quiz__r.lmscons__Description__c, '+
				'lmscons__Quiz__r.lmscons__Duration__c, '+
				'lmscons__Sequence__c '+
			'FROM '+ 
				'lmscons__Curriculum_Item__c '+
			'WHERE '+
				'lmscons__Curriculum__c = :curriculumId '+
				'AND '+
				'lmscons__Quiz__c = null '+ // quizzes will be available in phase 3.
				(isILT() ? 'AND lmsilt__Development_Plan_Task__c = null AND lmsilt__Event__c = null ' : '') + // removes devplan task and event if ILT installed.
				'AND '+
				'( '+
				'   lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c = true  '+
                '    OR '+
                '    lmscons__Course__r.lmscons__Available_For_Mobile__c = true '+
                '    OR '+
                '    lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true '+
                '    OR '+
                '    lmscons__Module__r.lmscons__Available_For_Mobile__c = true '+
                ')');
		
		
		if (curriculumItems.isEmpty()){			
			//throw new MobileException('[getItemsFromCurriculum] no items in curriculum with id: ' + curriculumId);
		}
		
		List<BaseItem> items = new List<BaseItem>();		
		for(lmscons__Curriculum_Item__c curriculumItem: curriculumItems){
			BaseItem newItem = new BaseItem();
			items.add(newItem);
			newItem.sequence = curriculumItem.lmscons__Sequence__c;
			if (curriculumItem.lmscons__Learning_Path__c != null){
				newItem.objectType = MobileConstants.LEARNING_PATH_TYPE;
				newItem.id = curriculumItem.lmscons__Learning_Path__c;
				newItem.title = curriculumItem.lmscons__Learning_Path__r.Name;
				newItem.description = curriculumItem.lmscons__Learning_Path__r.lmscons__Description__c;
				newItem.duration = curriculumItem.lmscons__Learning_Path__r.lmscons__Duration__c;
			} else if (curriculumItem.lmscons__Course__c != null){
				newItem.objectType = MobileConstants.COURSE_TYPE;
				newItem.id = curriculumItem.lmscons__Course__c;
				newItem.title = curriculumItem.lmscons__Course__r.Name;
				newItem.description = curriculumItem.lmscons__Course__r.lmscons__Description__c;
				newItem.duration = curriculumItem.lmscons__Course__r.lmscons__Duration__c;
			} else if (curriculumItem.lmscons__Module__c != null){
				newItem.objectType = MobileConstants.MODULE_TYPE;
				newItem.id = curriculumItem.lmscons__Module__c;
				newItem.title = curriculumItem.lmscons__Module__r.lmscons__Title__c;
				newItem.description = curriculumItem.lmscons__Module__r.lmscons__Description__c;
				newItem.duration = curriculumItem.lmscons__Module__r.lmscons__Duration__c;
			} else if (curriculumItem.lmscons__Quiz__c != null){
				newItem.objectType = MobileConstants.QUIZ_TYPE;
				newItem.id = curriculumItem.lmscons__Quiz__c;
				newItem.title = curriculumItem.lmscons__Quiz__r.Name;
				newItem.description = curriculumItem.lmscons__Quiz__r.lmscons__Description__c;
				newItem.duration = curriculumItem.lmscons__Quiz__r.lmscons__Duration__c;
			} 			 
		}
		
		return items;
	}
	
	@TestVisible
	private static List<BaseItem> getItemsFromLearningPath(String learningPathId){
		
		List<lmscons__Learning_Path_Item__c> learningPathItems = Database.query('SELECT '+
			'	Id, '+ 
			'	lmscons__Sequence__c, '+
			'	lmscons__Course__c, '+												
			'	lmscons__Course__r.Name, '+
			'	lmscons__Course__r.lmscons__Description__c, '+
			'	lmscons__Course__r.lmscons__Duration__c, '+
			'	lmscons__Module__c, '+
			'	lmscons__Module__r.lmscons__Title__c, '+
			'	lmscons__Module__r.lmscons__Description__c, '+
			'	lmscons__Module__r.lmscons__Duration__c, '+
			'	lmscons__Quiz__c, '+
			'	lmscons__Quiz__r.Name, '+
			'	lmscons__Quiz__r.lmscons__Description__c, '+
			'	lmscons__Quiz__r.lmscons__Duration__c '+								
			'FROM '+ 
			'	lmscons__Learning_Path_Item__c '+
			'WHERE '+
			'	lmscons__Learning_Path__c = :learningPathId '+
			'	AND '+
			'	lmscons__Quiz__c = null '+ // quizzes will be available in phase 3.
			(isILT() ? 'AND lmsilt__Development_Plan_Task__c = null AND lmsilt__Event__c = null ' : '') + // removes devplan task and event if ILT installed.
			'	AND '+
			'	( '+
            '        lmscons__Course__r.lmscons__Available_For_Mobile__c = true '+
            '        OR '+
            '        lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true '+
            '        OR '+
            '        lmscons__Module__r.lmscons__Available_For_Mobile__c = true '+
            '    ) ');
		
		
		if (learningPathItems.isEmpty()){			
			//throw new MobileException('[getItemsFromLearningPath] no items in learning path with id: ' + learningPathId);
		}
		
		List<BaseItem> items = new List<BaseItem>();		
		for(lmscons__Learning_Path_Item__c learningPathItem: learningPathItems){
			BaseItem newItem = new BaseItem();
			items.add(newItem);
			newItem.sequence = learningPathItem.lmscons__Sequence__c;
			if (learningPathItem.lmscons__Course__c != null){
				newItem.objectType = MobileConstants.COURSE_TYPE;
				newItem.id = learningPathItem.lmscons__Course__c;
				newItem.title = learningPathItem.lmscons__Course__r.Name;
				newItem.description = learningPathItem.lmscons__Course__r.lmscons__Description__c;
				newItem.duration = learningPathItem.lmscons__Course__r.lmscons__Duration__c;
			} else if (learningPathItem.lmscons__Module__c != null){
				newItem.objectType = MobileConstants.MODULE_TYPE;
				newItem.id = learningPathItem.lmscons__Module__c;
				newItem.title = learningPathItem.lmscons__Module__r.lmscons__Title__c;
				newItem.description = learningPathItem.lmscons__Module__r.lmscons__Description__c;
				newItem.duration = learningPathItem.lmscons__Module__r.lmscons__Duration__c;
			} else if (learningPathItem.lmscons__Quiz__c != null){
				newItem.objectType = MobileConstants.QUIZ_TYPE;
				newItem.id = learningPathItem.lmscons__Quiz__c;
				newItem.title = learningPathItem.lmscons__Quiz__r.Name;
				newItem.description = learningPathItem.lmscons__Quiz__r.lmscons__Description__c;
				newItem.duration = learningPathItem.lmscons__Quiz__r.lmscons__Duration__c;
			} 			 
		}
		
		return items;
	}
	
	@TestVisible
	private static List<BaseItem> getItemsFromCourse(String courseId){		
		List<lmscons__Training_Path_Item__c> courseItems = Database.query('SELECT '+ 
			'	Id, '+ 
			'	lmscons__Sequence__c, '+
			'	lmscons__Training_Content__c, '+
			'	lmscons__Training_Content__r.lmscons__Title__c, '+
			'	lmscons__Training_Content__r.lmscons__Description__c, '+
			'	lmscons__Training_Content__r.lmscons__Duration__c, '+
			'	lmscons__Quiz__c, '+
			'	lmscons__Quiz__r.Name, '+
			'	lmscons__Quiz__r.lmscons__Description__c, '+
			'	lmscons__Quiz__r.lmscons__Duration__c '+								
			'FROM '+
			'	lmscons__Training_Path_Item__c '+
			'WHERE '+
			'	lmscons__Training_Path__c = :courseId '+
			'	AND '+
			'	lmscons__Quiz__c = null '+ // quizzes will be available in phase 3.
			(isILT() ? 'AND lmsilt__Development_Plan_Task__c = null AND lmsilt__Event__c = null ' : '') + // removes devplan task and event if ILT installed.
			'	AND '+
			'	( '+
            '       lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true '+
            '        OR '+
            '        lmscons__Training_Content__r.lmscons__Available_For_Mobile__c = true '+
            '    )');
		
		
		if (courseItems.isEmpty()){			
			//throw new MobileException('[getItemsFromCourse] no items in course with id: ' + courseId);
		}
		
		List<BaseItem> items = new List<BaseItem>();		
		for(lmscons__Training_Path_Item__c courseItem: courseItems){
			BaseItem newItem = new BaseItem();
			items.add(newItem);
			newItem.sequence = courseItem.lmscons__Sequence__c;
			if (courseItem.lmscons__Training_Content__c != null){
				newItem.objectType = MobileConstants.MODULE_TYPE;
				newItem.id = courseItem.lmscons__Training_Content__c;
				newItem.title = courseItem.lmscons__Training_Content__r.lmscons__Title__c;
				newItem.description = courseItem.lmscons__Training_Content__r.lmscons__Description__c;
				newItem.duration = courseItem.lmscons__Training_Content__r.lmscons__Duration__c;
			} else if (courseItem.lmscons__Quiz__c != null){
				newItem.objectType = MobileConstants.QUIZ_TYPE;
				newItem.id = courseItem.lmscons__Quiz__c;
				newItem.title = courseItem.lmscons__Quiz__r.Name;
				newItem.description = courseItem.lmscons__Quiz__r.lmscons__Description__c;
				newItem.duration = courseItem.lmscons__Quiz__r.lmscons__Duration__c;
			} 			 
		}
		
		return items;
	}
	
	
	
	private static lmscons__Training_Content__c getTrainingContent(Id id){
		List<lmscons__Training_Content__c> lst = [SELECT Id, lmscons__Description__c, lmscons__Duration__c, lmscons__Title__c FROM lmscons__Training_Content__c WHERE Id = :id];
		if (!lst.isEmpty()){
			return lst.get(0);
		}
		
		return null;
	} 
	
	@TestVisible
	private static lmscons__Quiz__c getQuiz(Id id){
		List<lmscons__Quiz__c> lst = [SELECT Id, lmscons__Description__c, lmscons__Duration__c, Name FROM lmscons__Quiz__c WHERE Id = :id];
		if (!lst.isEmpty()){
			return lst.get(0);
		}
		
		return null;
	} 
	
	private static Item getParentItem(List<lmscons__Transcript_line__c> assignments, String parentType, String parentId){
		
		if (assignments == null || assignments.isEmpty()){
			throw new MobileException('[getParentItem] Can not get parent item. Assignments are empty!');
		}
		
		lmscons__Transcript_line__c assignment = assignments.get(0);
		
		String ignoreLevel = null;
		
		if (MobileConstants.CURRICULUM_TYPE.equals(parentType)){				
			ignoreLevel = null;								
		} else if (MobileConstants.LEARNING_PATH_TYPE.equals(parentType)){			
			ignoreLevel = MobileConstants.CURRICULUM_TYPE;								
		} else if (MobileConstants.COURSE_TYPE.equals(parentType)){				
			ignoreLevel = MobileConstants.LEARNING_PATH_TYPE;					
		}
		
		String objectType = getObjectType(assignment, ignoreLevel);
		Item item = new Item();
		
		return fillItemFromTranscriptLine(item, objectType, parentType, assignment);	
	}

	private static Item fillItemFromTranscriptLine(Item item, String objectType, String parentType, lmscons__Transcript_line__c assignment){
		
		if (assignment == null){
			throw new MobileException('[getItemFromTranscriptLine] => Assignment is NULL');
		}
		
		
		//item.id = assignment.Id;
		item.objectType = objectType;
		
		item.courseAssignmentId = assignment.lmscons__Course_Assignment__c;
		item.learningPathAssignmentId = assignment.lmscons__Learning_Path_Assignment__c;
		item.curriculumAssignmentId = assignment.lmscons__Curriculum_Assignment__c;
		
		if (MobileConstants.CURRICULUM_TYPE.equals(item.objectType)){
			item.id = assignment.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c;
			item.containerAssignmentId = assignment.lmscons__Curriculum_Assignment__c; 																								
			item.title = assignment.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.Name;
			item.description = assignment.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c;
			item.status = formatStatus(assignment.lmscons__Curriculum_Assignment__r.lmscons__Status__c);
			item.dueDate = assignment.lmscons__Curriculum_Assignment__r.lmscons__Due_Date__c;
			item.completedDate = assignment.lmscons__Curriculum_Assignment__r.lmscons__Completion_Date__c;
			item.progress = formatProgress(assignment.lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c);
			item.duration = assignment.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Duration__c;	
									
		} else if (MobileConstants.LEARNING_PATH_TYPE.equals(item.objectType)){
			item.id = assignment.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c;	
			item.containerAssignmentId = assignment.lmscons__Learning_Path_Assignment__c;					
			item.title = assignment.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.Name;
			item.description = assignment.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c;
			item.status = formatStatus(assignment.lmscons__Learning_Path_Assignment__r.lmscons__Status__c);
			item.dueDate = assignment.lmscons__Learning_Path_Assignment__r.lmscons__Due_Date__c;
			item.completedDate = assignment.lmscons__Learning_Path_Assignment__r.lmscons__Completion_Date__c;
			item.progress = formatProgress(assignment.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c);	
			item.duration = assignment.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Duration__c;	
			
			// If LP in Curriulum, than get sequence from curriculum item.
			if (parentType != null && MobileConstants.CURRICULUM_TYPE.equals(parentType) && assignment.lmscons__Curriculum_Item__c != null){
				item.sequence = assignment.lmscons__Curriculum_Item__r.lmscons__Sequence__c;	
			}	
										
		} else if (MobileConstants.COURSE_TYPE.equals(item.objectType)){	
			item.id = assignment.lmscons__Course_Assignment__r.lmscons__Training_Path__c;
			item.containerAssignmentId = assignment.lmscons__Course_Assignment__c;		
			item.title = assignment.lmscons__Course_Assignment__r.lmscons__Training_Path__r.Name;
			item.description = assignment.lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Description__c;
			item.status = formatStatus(assignment.lmscons__Course_Assignment__r.lmscons__Status__c);
			item.dueDate = assignment.lmscons__Course_Assignment__r.lmscons__Due_Date__c;
			item.completedDate = assignment.lmscons__Course_Assignment__r.lmscons__Completion_Date__c;
			item.progress = formatProgress(assignment.lmscons__Course_Assignment__r.lmscons__Progress_Training_path__c);			
			item.duration = assignment.lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Duration__c;	
									
			if (parentType != null){
				
				// If Course in Curriulum, than get sequence from curriculum item.
				if (MobileConstants.CURRICULUM_TYPE.equals(parentType) && assignment.lmscons__Curriculum_Item__c != null){
					item.sequence = assignment.lmscons__Curriculum_Item__r.lmscons__Sequence__c;	
				}
				
				// If Course in LP, than get sequence from LP item.
				if (MobileConstants.LEARNING_PATH_TYPE.equals(parentType) && assignment.lmscons__Learning_Path_Item__c != null){
					item.sequence = assignment.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;	
				}
			}						
						
		} else if (MobileConstants.QUIZ_TYPE.equals(item.objectType)){
			item.id = assignment.lmscons__Quiz__c;
			item.containerAssignmentId = assignment.Id;			
			item.title = assignment.lmscons__Quiz__r.Name;
			item.description = assignment.lmscons__Quiz__r.lmscons__Description__c;
			item.status = formatStatus(assignment.lmscons__Status__c);
			item.dueDate = assignment.lmscons__Due_Date__c;
			item.completedDate = assignment.lmscons__Completion_Date__c;
			item.score = assignment.lmscons__Score__c;
			item.progress = formatProgress(assignment.lmscons__Percent_Complete__c);				
			item.duration = assignment.lmscons__Quiz__r.lmscons__Duration__c;	
			
			if (parentType != null){
				// If Quiz in Curriulum, than get sequence from curriculum item.
				if (MobileConstants.CURRICULUM_TYPE.equals(parentType) && assignment.lmscons__Curriculum_Item__c != null){
					item.sequence = assignment.lmscons__Curriculum_Item__r.lmscons__Sequence__c;	
				}
				
				// If Quiz in LP, than get sequence from LP item.
				if (MobileConstants.LEARNING_PATH_TYPE.equals(parentType) && assignment.lmscons__Learning_Path_Item__c != null){
					item.sequence = assignment.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;	
				}
				
				// If Quiz in Course, than get sequence from Course item.
				if (MobileConstants.COURSE_TYPE.equals(parentType) && assignment.lmscons__Training_Path_Item__c != null){
					item.sequence = assignment.lmscons__Training_Path_Item__r.lmscons__Sequence__c;	
				}
			}			
								
		} else if (MobileConstants.MODULE_TYPE.equals(item.objectType)){
			item.id = assignment.lmscons__Training_Content__c;
			item.containerAssignmentId = assignment.Id;			
			item.title = assignment.lmscons__Training_Content__r.lmscons__Title__c;
			item.description = assignment.lmscons__Training_Content__r.lmscons__Description__c;
			item.status = formatStatus(assignment.lmscons__Status__c);
			item.dueDate = assignment.lmscons__Due_Date__c;			
			item.completedDate = assignment.lmscons__Completion_Date__c;
			item.score = assignment.lmscons__Score__c;
			item.progress = formatProgress(assignment.lmscons__Percent_Complete__c);				
			item.duration = assignment.lmscons__Training_Content__r.lmscons__Duration__c;	                        
			
			if (parentType != null){
				// If Module in Curriulum, than get sequence from curriculum item.
				if (MobileConstants.CURRICULUM_TYPE.equals(parentType) && assignment.lmscons__Curriculum_Item__c != null){
					item.sequence = assignment.lmscons__Curriculum_Item__r.lmscons__Sequence__c;	
				}
				
				// If Module in LP, than get sequence from LP item.
				if (MobileConstants.LEARNING_PATH_TYPE.equals(parentType) && assignment.lmscons__Learning_Path_Item__c != null){
					item.sequence = assignment.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;	
				}
				
				// If Module in Course, than get sequence from Course item.
				if (MobileConstants.COURSE_TYPE.equals(parentType) && assignment.lmscons__Training_Path_Item__c != null){
					item.sequence = assignment.lmscons__Training_Path_Item__r.lmscons__Sequence__c;	
				}
			}
											
		} else{
			throw new MobileException('[getItemFromTranscriptLine] => Unknown assignment object type. Assignment = ' + assignment);
		} 
		
		return item;						
	}	
	
	public static String formatProgress(Decimal progress){
		return progress == null ? '' : String.valueOf(progress.round());                
	}
	
	public static String formatDuration(Decimal duration) {
		try {
			if (duration == NULL || duration == 0) return NULL;
			if (duration < 60) return String.valueOf(duration)+'m';

			Decimal Hrs = duration.divide(60, 0, System.RoundingMode.DOWN);
			Decimal Mns = duration - (Hrs*60);
			String Outp = String.valueOf(Hrs)+'h ';
			if (Mns > 0) Outp += String.valueOf(Mns)+'m ';
			return Outp;
		}
		catch (Exception e) {
			return null;
		}
	}
	
	public static String formatDate(Date dt){
		return dt == null ? '' : dt.format();
	}
	
	public static String formatStatus(String status){
		if (status == null || String.isEmpty(status)){
			return MobileConstants.NOT_STARTED_STATUS;
		}
		
		return status;
	}
	
	public static String formatDateTime(DateTime dt){
		return dt == null ? '' : Date.newInstance(dt.year(), dt.month(), dt.day()).format();
	}


	private static List<Item> getTopLevelItems(List<lmscons__Transcript_line__c> assignments, String ignoreLevelType, Boolean onlyAvailableForMobile){
						
		Set<Id> curriculumAssignments = new Set<Id>();
		Set<Id> learningPathAssignments = new Set<Id>();
		Set<Id> courseAssignments = new Set<Id>();
		
		List<Item> items = new List<Item>();
		for(lmscons__Transcript_line__c assignment : assignments){
			
			/*
			if (onlyAvailableForMobile && assignment.lmscons__Training_Content__r.lmscons__Available_For_Mobile__c != true){
			    continue;
			}
			*/
						
			String objectType = getObjectType(assignment, ignoreLevelType);			
			Item item = new Item();	
			
			if (MobileConstants.CURRICULUM_TYPE.equals(objectType) && !curriculumAssignments.contains(assignment.lmscons__Curriculum_Assignment__c)){				
			    if (onlyAvailableForMobile && assignment.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Available_For_Mobile__c != true) continue;
				curriculumAssignments.add(assignment.lmscons__Curriculum_Assignment__c);																																							
				items.add(fillItemFromTranscriptLine(item, objectType, ignoreLevelType, assignment));								
			} else if (MobileConstants.LEARNING_PATH_TYPE.equals(objectType) && !learningPathAssignments.contains(assignment.lmscons__Learning_Path_Assignment__c)){
			    if (onlyAvailableForMobile && assignment.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c != true) continue;
				learningPathAssignments.add(assignment.lmscons__Learning_Path_Assignment__c);								
				items.add(fillItemFromTranscriptLine(item, objectType, ignoreLevelType, assignment));									
			} else if (MobileConstants.COURSE_TYPE.equals(objectType) && !courseAssignments.contains(assignment.lmscons__Course_Assignment__c)){
			    
			    if (onlyAvailableForMobile && assignment.lmscons__Course_Assignment__r.lmscons__Training_Path__r.lmscons__Available_For_Mobile__c != true) continue;
			    
				courseAssignments.add(assignment.lmscons__Course_Assignment__c);
				items.add(fillItemFromTranscriptLine(item, objectType, ignoreLevelType, assignment));					
			} else if (MobileConstants.QUIZ_TYPE.equals(objectType)){				
			    
			    if (onlyAvailableForMobile && assignment.lmscons__Quiz__r.lmscons__Available_For_Mobile__c != true) continue;
			    
				items.add(fillItemFromTranscriptLine(item, objectType, ignoreLevelType, assignment));																	
			} if (MobileConstants.MODULE_TYPE.equals(objectType)){		
			    
			    if (onlyAvailableForMobile && assignment.lmscons__Training_Content__r.lmscons__Available_For_Mobile__c != true) continue;
			    
				items.add(fillItemFromTranscriptLine(item, objectType, ignoreLevelType, assignment));								
			}								
		}
						
		return items;
	}
	
	private static String getObjectType(lmscons__Transcript_line__c assignment, String ignoreLevelType){
		if (!MobileConstants.CURRICULUM_TYPE.equals(ignoreLevelType) 
		    &&
		    !MobileConstants.LEARNING_PATH_TYPE.equals(ignoreLevelType)
		    &&
		    !MobileConstants.COURSE_TYPE.equals(ignoreLevelType)
		    &&
		    assignment.lmscons__Curriculum_Assignment__c != null){
		        
			return MobileConstants.CURRICULUM_TYPE;
		}
		
		if (!MobileConstants.LEARNING_PATH_TYPE.equals(ignoreLevelType) 
		    &&
		    !MobileConstants.COURSE_TYPE.equals(ignoreLevelType)
		    &&
		    assignment.lmscons__Learning_Path_Assignment__c != null){
		        
			return MobileConstants.LEARNING_PATH_TYPE;
		}
		
		if (!MobileConstants.COURSE_TYPE.equals(ignoreLevelType) && assignment.lmscons__Course_Assignment__c != null){
			return MobileConstants.COURSE_TYPE;
		}
		
		if (assignment.lmscons__Quiz__c != null){
			return MobileConstants.QUIZ_TYPE;
		}
		
		if (assignment.lmscons__Training_Content__c != null){
			return MobileConstants.MODULE_TYPE;
		}
		
		throw new MobileException('[getObjectType] => Unknown assignment object type. Assignment = ' + assignment);	
	}
	
	
	public static Boolean isCFSUser() {
        return [SELECT COUNT() FROM User WHERE Id =:userinfo.getUserId() AND lmscons__Cornerstone_Id__c !='' AND lmscons__CFS_Status__c = 'Active'] != 0;	    
	}		
}