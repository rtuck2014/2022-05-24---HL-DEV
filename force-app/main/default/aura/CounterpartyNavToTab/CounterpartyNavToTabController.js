({
	doInit : function(cmp, event, helper) {
        var navService = cmp.find("navService");
        console.log('navCmpController:'+cmp.get("v.recordId"));
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__CounterpartyWrapLwc'
            },
            state: {
                "c__id":cmp.get("v.recordId"),
                "c__recordId":cmp.get("v.recordId")
            }
        };
		navService.navigate(pageReference);  
        $A.get("e.force:closeQuickAction").fire();
    }     
})