var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var LandingPage = function(){
	BaseAction.apply(this, arguments);
}

inherits(LandingPage, BaseAction);

LandingPage.prototype.getIconClass = function() {
	return 'icon--page-view';
}

LandingPage.prototype.getActionName = function() {
	return "Form";
}

LandingPage.prototype.getTargetText = function() {
	var title = this.marketingAction.landingPage.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = LandingPage;
