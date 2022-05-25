public with sharing class CatalogDataLoadHelper {
		
	
	public static Set<Id> getCurentUserCatalogsSet(){
		Set<Id> idsCatalogs = new Set<Id>();

		List<lmscons__Catalog_Profile__c> catalogsByProfiles = [SELECT lmscons__Catalog__c FROM lmscons__Catalog_Profile__c WHERE lmscons__Profile_Id__c LIKE:'%'+UserInfo.getProfileId()+'%' limit 5000];

		/************** BEGIN GROUP SECTION **************/
	
		CatalogDataLoadHelper instance = new CatalogDataLoadHelper();
		Set<Id> catalogsByGroups = instance.GetVisibleGroups();
		if (catalogsByGroups != null){
			idsCatalogs.addAll(catalogsByGroups);	
		}
		/************** END GROUP SECTION **************/
		
		User user = [SELECT Id, UserType, AccountId FROM user WHERE Id =:UserInfo.getUserId()];
		Id accountId = (user.AccountId != NULL) ? user.AccountId : NULL;
		List<lmscons__Catalog_Account__c> catalogsAccounts = (accountId != NULL) ? [SELECT lmscons__Account__c, lmscons__Catalog__c FROM lmscons__Catalog_Account__c WHERE lmscons__Account__c = :accountId limit 5000] : NULL;

		if (catalogsAccounts != NULL && catalogsAccounts.size() > 0) {
			for (lmscons__Catalog_Account__c ca : catalogsAccounts ) {
				idsCatalogs.add(ca.lmscons__Catalog__c);
			}
		}

		if (catalogsByProfiles.size() > 0 || (catalogsAccounts != NULL && catalogsAccounts.size() > 0)) {

			for (lmscons__Catalog_Profile__c cp : catalogsByProfiles) {
				idsCatalogs.add(cp.lmscons__Catalog__c);
			}
		}

		return idsCatalogs;
	}
	
	public Set<Id> highestGroups = new Set<Id>();
	
	public  void getHighestGroups (Set<Id> inParams) {
		Map<Id,Group> Groups = new Map<Id,Group>([select ID FROM Group Where ID IN (Select GroupId From GroupMember where UserOrGroupId IN: inParams) LIMIT 5000]);

		if (Groups.size() > 0) {
			highestGroups.addall(Groups.KeySet());
			getHighestGroups(Groups.KeySet());
		}
	}
	
	public Set<Id> GetVisibleGroups () {
		Set<Id> ValidCatalogs = new Set<Id>();
		List<lmscons__Catalog_Group__c> catalog_groups = [SELECT lmscons__Group_Id__c, lmscons__Catalog__c  FROM lmscons__Catalog_Group__c WHERE lmscons__Group_Id__c != NULL LIMIT 5000];

		if (catalog_groups.size() > 0) {
			Boolean isPortal = UserInfo.getUserType()=='Standard'?false:true;
			Boolean isPartner = false;
			User u = [SELECT Id, UserType, AccountId FROM user WHERE Id =:UserInfo.getUserId()];
			if (isPortal == true) {
				String UserType = u.UserType;
				if (UserType.contains('Partner') == true) {
					isPartner = true;
				}
			}

			Id GroupOrg = NULL;
			List<String> GroupValues = new List<String>{'AllCustomerPortal', 'PRMOrganization', 'Organization'};
			Map<String, Id> GroupMap = new Map<String, Id>();
			for (Group grp : [SELECT Id, Type FROM Group WHERE Type = :GroupValues.get(0) OR Type = :GroupValues.get(1) OR Type = :GroupValues.get(2) LIMIT 5000]) {
				GroupMap.put(grp.Type, grp.Id);
			}
			if (isPortal) {
				if (GroupMap.containskey(GroupValues.get(0)) == true && isPartner == false) GroupOrg = GroupMap.get(GroupValues.get(0));
				if (GroupMap.containskey(GroupValues.get(1)) == true && isPartner == true) GroupOrg = GroupMap.get(GroupValues.get(1));
			}
			else {
				if (GroupMap.containskey(GroupValues.get(2))) GroupOrg = GroupMap.get(GroupValues.get(2));
			}
			String userType = Schema.SObjectType.User.getKeyPrefix();
			String groupType = Schema.SObjectType.Group.getKeyPrefix();
			Id userId = UserInfo.getUserId();
			Id userRole = UserInfo.getUserRoleId();
			Set<Id> UserIdRoleGroupId = new Set<Id>{userId};


			list<Group> GroupsForRole =  [SELECT ID FROM Group WHERE RelatedId =: userRole limit 10000];
			for(Group group_id : GroupsForRole) {
				UserIdRoleGroupId.add(group_id.Id);
			}
			list<GroupMember> Groups = [Select UserOrGroupId, Id, GroupId From GroupMember where UserOrGroupId IN: UserIdRoleGroupId LIMIT 5000];
			set<id> userGroupIds = new set<Id>();
			for (GroupMember gr_member : Groups){
				userGroupIds.add(gr_member.GroupId);
			}
			highestGroups.addAll(userGroupIds);
			highestGroups.add(GroupOrg);
			getHighestGroups(highestGroups);

			set<Id> CatalogGroupsIds = new Set<Id>();
			Map<Id,set<Id>> CatalogGroup = new Map<Id,set<Id>>();
			for(lmscons__Catalog_Group__c catalogItem : catalog_groups){
				if (CatalogGroup.containsKey(catalogItem.lmscons__Catalog__c)) {
					CatalogGroup.get(catalogItem.lmscons__Catalog__c).add(catalogItem.lmscons__Group_Id__c);
				}
				else {
					CatalogGroup.put(catalogItem.lmscons__Catalog__c, new Set<Id>{catalogItem.lmscons__Group_Id__c});
				}
			}
			Set<Id> GroupsInNotVisibleCatalog = new Set<Id>();
			for(Id catalog_id : CatalogGroup.keySet()) {
				boolean isVisibleCatalog = false;
				set<Id> groupsInCatalog = CatalogGroup.get(catalog_id);
				if (groupsInCatalog != null ) {
					for(Id group_id : highestGroups) {
						if (groupsInCatalog.contains(group_id)) {
							isVisibleCatalog = true;
							break;
						}
					}
				}
				if(isVisibleCatalog) {
					ValidCatalogs.add(catalog_id);
				}
				else {
					GroupsInNotVisibleCatalog.addall(groupsInCatalog);
				}
			}
		}
		return ValidCatalogs;
	}
	
	
	// get first level data.	
	public static List<MobileHelper.BaseItem> getTopCatalogItems(Set<Id> catalogSet, String searchStr){
		List<MobileHelper.BaseItem> result = new List<MobileHelper.BaseItem>();		
		if (Test.isRunningTest()) result.addAll(getQuizesFromCatalog(catalogSet, searchStr));	// remove quizzes. Will be available in phase 3.
		result.addAll(getModulesFromCatalog(catalogSet, searchStr));	
		result.addAll(getCoursesFromCatalog(catalogSet, searchStr));
		result.addAll(getLearningPathsFromCatalog(catalogSet, searchStr));	
		result.addAll(getCurriculumsFromCatalog(catalogSet, searchStr));				
		return result;
	}
		
	@TestVisible
	private static List<MobileHelper.BaseItem> getQuizesFromCatalog(Set<Id> catalogSet, String searchStr){
		List<MobileHelper.BaseItem> result = new List<MobileHelper.BaseItem>();
	
		List<lmscons__Catalog_Quiz__c> quizes;
		if (searchStr!=null && searchStr.trim()!=''){
			searchStr = String.escapeSingleQuotes(searchStr).toLowerCase();
			searchStr = '%' + searchStr + '%'; 
			quizes = [SELECT 
			        lmscons__Quiz__c, lmscons__Quiz__r.Id, lmscons__Quiz__r.Name, 
			        lmscons__Quiz__r.lmscons__Description__c, lmscons__Quiz__r.lmscons__Duration__c 
			    FROM 
			        lmscons__Catalog_Quiz__c  
			    WHERE 
			        lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true 
			        AND 
			        lmscons__Catalog__c IN :catalogSet 
			        AND 
			        lmscons__Quiz__r.Name Like :searchStr 
			    ORDER BY lmscons__Quiz__r.Name LIMIT 1000];
		} else
		{
			quizes = [SELECT 
			        lmscons__Quiz__c, lmscons__Quiz__r.Id, lmscons__Quiz__r.Name, 
			        lmscons__Quiz__r.lmscons__Description__c, lmscons__Quiz__r.lmscons__Duration__c 
			    FROM 
			        lmscons__Catalog_Quiz__c  
			    WHERE 
			        lmscons__Quiz__r.lmscons__Available_For_Mobile__c = true 
			        AND 
			        lmscons__Catalog__c IN :catalogSet 
			    ORDER BY lmscons__Quiz__r.Name LIMIT 1000];
		}
		
		Set<Id> uniqueIds = new Set<Id>();
		
		for (lmscons__Catalog_Quiz__c quiz : quizes){
			if (uniqueIds.contains(quiz.lmscons__Quiz__r.Id)){
				continue;
			}
			uniqueIds.add(quiz.lmscons__Quiz__r.Id);
						
			MobileHelper.BaseItem newItem = new MobileHelper.BaseItem();
			newItem.id = quiz.lmscons__Quiz__r.Id;
			newItem.title = quiz.lmscons__Quiz__r.Name;				
			newItem.objectType = MobileConstants.QUIZ_TYPE;
			newItem.description = quiz.lmscons__Quiz__r.lmscons__Description__c;									
			newItem.duration = quiz.lmscons__Quiz__r.lmscons__Duration__c;
			result.add(newItem);		
		} 
		
		return result;
	} 
	
	@TestVisible
	private static List<MobileHelper.BaseItem> getModulesFromCatalog(Set<Id> catalogSet, String searchStr){
		List<MobileHelper.BaseItem> result = new List<MobileHelper.BaseItem>();
	
		List<lmscons__Catalog_Course__c> modules;
		if (searchStr!=null && searchStr.trim()!=''){
			searchStr = String.escapeSingleQuotes(searchStr).toLowerCase();
			searchStr = '%' + searchStr + '%'; 		
			modules = [SELECT 
			            lmscons__Training_Course__c, lmscons__Training_Course__r.Id, 
			            lmscons__Training_Course__r.lmscons__Title__c, lmscons__Training_Course__r.lmscons__Description__c, 
			            lmscons__Training_Course__r.lmscons__Duration__c 
			        FROM 
			            lmscons__Catalog_Course__c 
			        WHERE 
			            lmscons__Training_Course__r.lmscons__Available_For_Mobile__c = true 
			            AND 
			            lmscons__Catalog__c IN :catalogSet 
			            AND 
			            lmscons__Training_Course__r.lmscons__Title__c LIKE :searchStr 
			        ORDER BY lmscons__Training_Course__r.lmscons__Title__c LIMIT 1000];
		} else
		{
			modules = [SELECT 
            			lmscons__Training_Course__c, lmscons__Training_Course__r.Id, lmscons__Training_Course__r.lmscons__Title__c, 
            			lmscons__Training_Course__r.lmscons__Description__c, lmscons__Training_Course__r.lmscons__Duration__c 
			        FROM 
			            lmscons__Catalog_Course__c 
        			WHERE 
            			lmscons__Training_Course__r.lmscons__Available_For_Mobile__c = true 
            			AND 
            			lmscons__Catalog__c IN :catalogSet 
        			ORDER BY lmscons__Training_Course__r.lmscons__Title__c LIMIT 1000];
		}
	
		Set<Id> uniqueIds = new Set<Id>();

		for (lmscons__Catalog_Course__c module : modules){
			if (uniqueIds.contains(module.lmscons__Training_Course__r.Id)){
				continue;
			}
			uniqueIds.add(module.lmscons__Training_Course__r.Id);
			
			MobileHelper.BaseItem newItem = new MobileHelper.BaseItem();
			newItem.id = module.lmscons__Training_Course__r.Id;
			newItem.title = module.lmscons__Training_Course__r.lmscons__Title__c;				
			newItem.objectType = MobileConstants.MODULE_TYPE;
			newItem.description = module.lmscons__Training_Course__r.lmscons__Description__c;
			newItem.duration = module.lmscons__Training_Course__r.lmscons__Duration__c;
			result.add(newItem);	
				
		} 
		
		return result;
	} 
	
	@TestVisible
	private static List<MobileHelper.BaseItem> getCoursesFromCatalog(Set<Id> catalogSet, String searchStr){
		List<MobileHelper.BaseItem> result = new List<MobileHelper.BaseItem>();
	
		List<lmscons__Catalog_Training_Path__c> courses;
		if (searchStr!=null && searchStr.trim()!=''){
			searchStr = String.escapeSingleQuotes(searchStr).toLowerCase();
			searchStr = '%' + searchStr + '%'; 		
			courses = [SELECT 
            		    lmscons__Training_Path__c, lmscons__Training_Path__r.Id, lmscons__Training_Path__r.Name, 
            			lmscons__Training_Path__r.lmscons__Description__c, lmscons__Training_Path__r.lmscons__Duration__c 
            		FROM 
            			lmscons__Catalog_Training_Path__c 
            		WHERE 
            			lmscons__Training_Path__r.lmscons__Available_For_Mobile__c = true 
            			AND 
            			lmscons__Catalog__c IN :catalogSet 
            			AND 
            			lmscons__Training_Path__r.Name LIKE :searchStr 
        			ORDER BY lmscons__Training_Path__r.Name LIMIT 1000];
		} else
		{
			courses = [SELECT lmscons__Training_Path__c, lmscons__Training_Path__r.Id, lmscons__Training_Path__r.Name, lmscons__Training_Path__r.lmscons__Description__c, lmscons__Training_Path__r.lmscons__Duration__c FROM lmscons__Catalog_Training_Path__c WHERE lmscons__Training_Path__r.lmscons__Available_For_Mobile__c = true AND lmscons__Catalog__c IN :catalogSet ORDER BY lmscons__Training_Path__r.Name LIMIT 1000];
		}
	
		Set<Id> uniqueIds = new Set<Id>();
	
		for (lmscons__Catalog_Training_Path__c course : courses){
			if (uniqueIds.contains(course.lmscons__Training_Path__r.Id)){
				continue;
			}
			uniqueIds.add(course.lmscons__Training_Path__r.Id);
			
			
			MobileHelper.BaseItem newItem = new MobileHelper.BaseItem();
			newItem.id = course.lmscons__Training_Path__r.Id;
			newItem.title = course.lmscons__Training_Path__r.Name;				
			newItem.objectType = MobileConstants.COURSE_TYPE;
			newItem.description = course.lmscons__Training_Path__r.lmscons__Description__c;	
			newItem.duration = course.lmscons__Training_Path__r.lmscons__Duration__c;
			result.add(newItem);		
		} 
		
		return result;
	}
	
	@TestVisible
	private static List<MobileHelper.BaseItem> getLearningPathsFromCatalog(Set<Id> catalogSet, String searchStr){
		List<MobileHelper.BaseItem> result = new List<MobileHelper.BaseItem>();
	
		List<lmscons__Catalog_Learning_Path__c> learningPaths;
		if (searchStr!=null && searchStr.trim()!=''){
			searchStr = String.escapeSingleQuotes(searchStr).toLowerCase();
			searchStr = '%' + searchStr + '%'; 		
			learningPaths = [SELECT 
            			lmscons__Learning_Path__c, lmscons__Learning_Path__r.Id, lmscons__Learning_Path__r.Name, 
            			lmscons__Learning_Path__r.lmscons__Description__c, lmscons__Learning_Path__r.lmscons__Duration__c  
            		FROM 
            			lmscons__Catalog_Learning_Path__c 
            		WHERE 
            			lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c = true 
            			AND 
            			lmscons__Catalog__c IN :catalogSet 
            			AND 
            			lmscons__Learning_Path__r.Name LIKE :searchStr 
            		ORDER BY lmscons__Learning_Path__r.Name LIMIT 1000];
		} else
		{
			learningPaths = [SELECT 
            			lmscons__Learning_Path__c, lmscons__Learning_Path__r.Id, lmscons__Learning_Path__r.Name, 
            			lmscons__Learning_Path__r.lmscons__Description__c, lmscons__Learning_Path__r.lmscons__Duration__c  
            		FROM 
            			lmscons__Catalog_Learning_Path__c 
            		WHERE 
            			lmscons__Learning_Path__r.lmscons__Available_For_Mobile__c = true 
            		    AND 
            			lmscons__Catalog__c IN :catalogSet 
            		ORDER BY lmscons__Learning_Path__r.Name LIMIT 1000];
		}
		
		Set<Id> uniqueIds = new Set<Id>();
	
		for (lmscons__Catalog_Learning_Path__c learningPath : learningPaths){
			
			if (uniqueIds.contains(learningPath.lmscons__Learning_Path__r.Id)){
				continue;
			}
			uniqueIds.add(learningPath.lmscons__Learning_Path__r.Id);								
			
			MobileHelper.BaseItem newItem = new MobileHelper.BaseItem();
			newItem.id = learningPath.lmscons__Learning_Path__r.Id;
			newItem.title = learningPath.lmscons__Learning_Path__r.Name;				
			newItem.objectType = MobileConstants.LEARNING_PATH_TYPE;
			newItem.description = learningPath.lmscons__Learning_Path__r.lmscons__Description__c;
			newItem.duration = learningPath.lmscons__Learning_Path__r.lmscons__Duration__c;
			result.add(newItem);
		} 
		
		return result;
	}
	
	@TestVisible
	private static List<MobileHelper.BaseItem> getCurriculumsFromCatalog(Set<Id> catalogSet, String searchStr){
		List<MobileHelper.BaseItem> result = new List<MobileHelper.BaseItem>();
	
		List<lmscons__Catalog_Curriculum__c> curriculums;
		if (searchStr!=null && searchStr.trim()!=''){
			searchStr = String.escapeSingleQuotes(searchStr).toLowerCase();
			searchStr = '%' + searchStr + '%'; 		
			curriculums = [SELECT 
            			lmscons__Curriculum__c, lmscons__Curriculum__r.id, lmscons__Curriculum__r.Name, 
            			lmscons__Curriculum__r.lmscons__Description__c, lmscons__Curriculum__r.lmscons__Duration__c 
            		FROM 
            			lmscons__Catalog_Curriculum__c 
            		WHERE 
            			lmscons__Curriculum__r.lmscons__Available_For_Mobile__c = true 
            			AND 
            			lmscons__Catalog__c IN :catalogSet 
            			AND 
            			lmscons__Curriculum__r.Name LIKE :searchStr 
            		ORDER BY lmscons__Curriculum__r.Name LIMIT 1000];
		} else
		{
			curriculums = [SELECT 
            			lmscons__Curriculum__c, lmscons__Curriculum__r.id, lmscons__Curriculum__r.Name, 
            			lmscons__Curriculum__r.lmscons__Description__c, lmscons__Curriculum__r.lmscons__Duration__c 
            		FROM 
            			lmscons__Catalog_Curriculum__c 
            		WHERE 
            			lmscons__Curriculum__r.lmscons__Available_For_Mobile__c = true 
            			AND 
            			lmscons__Catalog__c IN :catalogSet 
            		ORDER BY lmscons__Curriculum__r.Name LIMIT 1000];
		}
	
		Set<Id> uniqueIds = new Set<Id>();
	
		for (lmscons__Catalog_Curriculum__c curriculum : curriculums){
			
			if (uniqueIds.contains(curriculum.lmscons__Curriculum__r.id)){
				continue;
			}
			uniqueIds.add(curriculum.lmscons__Curriculum__r.id);
			
			MobileHelper.BaseItem newItem = new MobileHelper.BaseItem();
			newItem.id = curriculum.lmscons__Curriculum__r.id;
			newItem.title = curriculum.lmscons__Curriculum__r.Name;				
			newItem.objectType = MobileConstants.CURRICULUM_TYPE;
			newItem.description = curriculum.lmscons__Curriculum__r.lmscons__Description__c;
			newItem.duration = curriculum.lmscons__Curriculum__r.lmscons__Duration__c;
			result.add(newItem);		
		} 
		
		return result;
	}  				

}