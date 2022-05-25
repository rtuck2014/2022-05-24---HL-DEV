var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var FormSuccess = function(){
	BaseAction.apply(this, arguments);
}

inherits(FormSuccess, BaseAction);

FormSuccess.prototype.getIconClass = function() {
	return 'icon--form-success';
}

FormSuccess.prototype.getTargetText = function() {
	var title = this.marketingAction.form.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = FormSuccess;
