@isTest
private class AssignmentsDataLoadHelperTest {

	private static testMethod void test() {
        system.assert(AssignmentsDataLoadHelper.getAllAssignments(UserInfo.getUserID(), 'search str', true, true, new Set<String>{'Fake status'}).isEmpty(), '');
        
        system.assert(AssignmentsDataLoadHelper.getAssignment('00590000002F2Rt') == null, ''); // fake id.
        
        system.assert(AssignmentsDataLoadHelper.getCurriculumAssignments(UserInfo.getUserID(), null, false, null, '00590000002F2Rt').isEmpty(), '');
        system.assert(AssignmentsDataLoadHelper.getLeariningPathAssignments(UserInfo.getUserID(), null, false, null, '00590000002F2Rt').isEmpty(), '');
        system.assert(AssignmentsDataLoadHelper.getCourseAssignments(UserInfo.getUserID(), null, false, null, '00590000002F2Rt').isEmpty(), '');
        
        system.assert(AssignmentsDataLoadHelper.getAssignments(UserInfo.getUserID(), new Set<Id>{'00590000002F2Rt'}, new Set<Id>{'00590000002F2Rt'}, new Set<Id>{'00590000002F2Rt'}, new Set<Id>{'00590000002F2Rt'}, new Set<Id>{'00590000002F2Rt'}).isEmpty(), '');
	}

}