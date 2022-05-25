({    
    doInit : function(cmp, event, helper) {
        let navService = cmp.find("navService");
        let sobjectName = cmp.get("v.sObjectName");
        
        let pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: sobjectName,
                actionName: 'list'
            },
            state : {
                nooverride:'1',
                filterName:'Recent'
            }
        };
        navService.navigate(pageReference);
    }
})