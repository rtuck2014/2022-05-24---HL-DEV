var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var EmailOpen = function(){
	BaseAction.apply(this, arguments);
}

inherits(EmailOpen, BaseAction);

EmailOpen.prototype.getIconClass = function() {
	return 'icon--email-open';
}

EmailOpen.prototype.getTargetText = function() {
	var title = this.marketingAction.email.subject;

	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = EmailOpen;
