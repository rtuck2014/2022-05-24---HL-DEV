var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var WebVisit = function(){
	BaseAction.apply(this, arguments);
}

inherits(WebVisit, BaseAction);

WebVisit.prototype.getIconClass = function() {
	return 'icon--page-view';
}

WebVisit.prototype.getTargetText = function() {
	var title = this.marketingAction.pageView.title;
	if (!title) {
		title = 'Untitled'
	}

	return title;
}

WebVisit.prototype.getActionName = function() {
	return "Page View";
}

module.exports = WebVisit;
