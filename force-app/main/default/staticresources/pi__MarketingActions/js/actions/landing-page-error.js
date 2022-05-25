var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var LandingPageError = function(){
	BaseAction.apply(this, arguments);
}

inherits(LandingPageError, BaseAction);

LandingPageError.prototype.getIconClass = function() {
    return 'icon--form-error';
}

LandingPageError.prototype.getActionName = function() {
    return "Form Error";
}

LandingPageError.prototype.getTargetText = function() {
	var title = this.marketingAction.landingPage.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = LandingPageError;
