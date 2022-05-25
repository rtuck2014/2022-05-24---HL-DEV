var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var FormHandlerSuccess = function(){
	BaseAction.apply(this, arguments);
}

inherits(FormHandlerSuccess, BaseAction);

FormHandlerSuccess.prototype.getIconClass = function() {
	return 'icon--form-success';
}

FormHandlerSuccess.prototype.getTargetText = function() {
	var title = this.marketingAction.formHandler.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = FormHandlerSuccess;
