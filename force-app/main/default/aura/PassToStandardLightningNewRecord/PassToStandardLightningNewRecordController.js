({
	doInit : function(cmp, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": cmp.get("v.sObjectName"),
            "recordTypeId":cmp.get("v.pageReference").state.recordTypeId
        });
        createRecordEvent.fire();

        /*
        let navService = cmp.find("navService");
        let sobjectName = cmp.get("v.sObjectName");
        console.log('sobjectName:'+sobjectName);
		let rtId = cmp.get("v.pageReference").state.recordTypeId;
        console.log('rtId:'+rtId)
        let pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: sobjectName,
                actionName: 'new'
            },
            state : {
                nooverride:'1'
            }
        };
        console.log('pr:'+JSON.stringify(pageReference));
        navService.navigate(pageReference);
        */
    }
})