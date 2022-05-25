var inherits = require('inherits');
var BaseAction = require('./base-action.js');
var FormError = function(){
	BaseAction.apply(this, arguments);
}

inherits(FormError, BaseAction);

FormError.prototype.getIconClass = function() {
	return 'icon--form-error';
}

FormError.prototype.getTargetText = function() {
	var title = this.marketingAction.form.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = FormError;
