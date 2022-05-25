({
	doInit : function(cmp, event, helper) {
        let navService = cmp.find("navService");
        let sobjectName = cmp.get("v.sObjectName");
        let rId = cmp.get("v.recordId");
        
        let pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: sobjectName,
                actionName: 'edit',
                recordId : rId
            },
            state : {
                nooverride:'1'
            }
        };
        navService.navigate(pageReference);
    }
})