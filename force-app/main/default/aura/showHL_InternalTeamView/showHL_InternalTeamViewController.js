({
	doInit : function(component, event, helper) {
        var pageRef = component.get('v.pageReference');
        var recordId = pageRef.state.c__recordId;
        var type = pageRef.state.c__type;

        component.set('v.recordId',recordId);
        component.set('v.recordType',type);
	}
})