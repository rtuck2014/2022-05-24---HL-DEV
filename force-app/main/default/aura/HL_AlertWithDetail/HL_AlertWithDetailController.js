({
	handleClose: function (component, event, helper) {
		component.set("v.isVisible", false);
	},

	setVisible: function (component, event, helper) {
		component.set("v.isVisible", true);
	}
});