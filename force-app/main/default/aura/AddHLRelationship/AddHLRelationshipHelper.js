({
	showToast : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        "title": "Success!",
        "message": "The record has been saved successfully."
        });
        toastEvent.fire();
    }
})