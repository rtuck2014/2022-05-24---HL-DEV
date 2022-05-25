({
	doInit : function(component, event, helper) {
		var pageRef = component.get('v.pageReference');
        var recordId = pageRef.state.c__recordId;
        component.set('v.recordId',recordId);
	}
})