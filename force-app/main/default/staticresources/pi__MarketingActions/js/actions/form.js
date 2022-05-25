var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var Form = function(){
	BaseAction.apply(this, arguments);
}

inherits(Form, BaseAction);

Form.prototype.getIconClass = function() {
	return 'icon--form-success';
}

Form.prototype.getTargetText = function() {
	var title = this.marketingAction.form.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = Form;
