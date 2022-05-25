({
    doInit:function(component, event, helper){
        var action = component.get("c.GetTemplate");
        var templateId = component.get("v.templateId");
        var relatedId = component.get("v.relatedId");
        action.setParams({
            templateName:templateId,
            relatedId:relatedId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var emailTemplate = response.getReturnValue();
                component.find("subject").set("v.value", emailTemplate.Email_Subject__c);
                component.find("body").set("v.value", emailTemplate.Template_Body__c);
            }
        });
	 	$A.enqueueAction(action);
    },
	handleToSelection : function(component, event, helper) {
		var so = event.getParam("selectedOption");
        component.set("v.emailTo",so.Id);
        component.set("v.emailToName", so.Name);
	},
    handleCCSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var ccs = component.get("v.emailCCs");
        if (!ccs) ccs = [];
        ccs.push(so);
        component.set("v.emailCCs",ccs);
    },  
    onRemoveCCClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.emailCCs");
        }  
    },
    sendEmail : function(component){
        var emailTo = component.get("v.emailTo");
        var emailCCs = component.get("v.emailCCs");
        var emailSubject = component.find("subject").get("v.value");
        var emailBody = component.find("body").get("v.value");
        var action = component.get("c.SendJSON");
        component.find("btnSend").set("v.disabled",true);
        action.setParams({
            contactId:emailTo,
            ccsJSON:JSON.stringify(emailCCs),
            emailSubject:emailSubject,
            emailBody:emailBody
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email Sent."
                });
                toastEvent.fire();
                var successEvent = component.getEvent("successEvent");
        		successEvent.fire();
            }
            else
                component.find("btnSend").set("v.disabled",false);
        });
        $A.enqueueAction(action);
    }
})