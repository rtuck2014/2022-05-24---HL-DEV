var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var FormHandlerError = function(){
	BaseAction.apply(this, arguments);
}

inherits(FormHandlerError, BaseAction);

FormHandlerError.prototype.getIconClass = function() {
	return 'icon--form-error';
}

FormHandlerError.prototype.getTargetText = function() {
	var title = this.marketingAction.formHandler.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = FormHandlerError;
