({
    doInit : function(cmp, event, helper) {
        console.log('called');
        let action = cmp.get("c.getEventParentId");
        action.setParams({"recordId": cmp.get("v.recordId")});
        action.setCallback(this, function(a){
            if(a.getState()=='SUCCESS'){
                let finalRecordId = a.getReturnValue();
                console.log('finalRecordId:'+finalRecordId);
                let finalUrl = '/apex/HL_ActivityEventView?nooverride=1'
                if(finalRecordId)
                finalUrl+='&Id='+finalRecordId;
                cmp.find("navService").navigate({ 
                    type: "standard__webPage", 
                    attributes: { 
                        url: finalUrl
                    } 
                });
            }else{
                console.log('failure');
            }
        });
    }
})