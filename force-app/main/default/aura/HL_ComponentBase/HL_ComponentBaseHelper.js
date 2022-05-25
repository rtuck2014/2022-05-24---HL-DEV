({
	callServerAction: function (
		component,
		methodName,
		params,
		successHandler
	) {
		var action = component.get("c." + methodName);

		if (params) {
			action.setParams(params);
		}

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var result = response.getReturnValue();

				//console.log("Result from server", result);
				successHandler(result);
			} else if (state === "INCOMPLETE") {
				console.log("Incomplete");
				// do something
			} else if (state === "ERROR") {
				var errors = response.getError();

				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message", errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});

		$A.enqueueAction(action);
	},

	fetchAndAssign: function (
		component,
		methodName,
		params,
		attributeName,
		successHandler
	) {
		this.callServerAction(
			component,
			methodName,
			params,
			function (result) {
				if (attributeName) {
					component.set("v." + attributeName, result);
				}

				if (successHandler) {
					successHandler(result);
				}
			}
		);
	},

	showToast: function (type, title, message, mode) {
		var toastEvent = $A.get("e.force:showToast");

		toastEvent.setParams({
			type: type,
			title: title,
			message: message,
			mode: mode
		});

		toastEvent.fire();
	}
});