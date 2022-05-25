var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var EmailClick = function(){
	BaseAction.apply(this, arguments);
}

inherits(EmailClick, BaseAction);

EmailClick.prototype.getIconClass = function() {
	return 'icon--email-click';
}

EmailClick.prototype.getTargetText = function() {
	var title = this.marketingAction.email.subject;

	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = EmailClick;
