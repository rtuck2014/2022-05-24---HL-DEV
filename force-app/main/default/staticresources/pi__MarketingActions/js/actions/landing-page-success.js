var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var LandingPageSuccess = function(){
	BaseAction.apply(this, arguments);
}

inherits(LandingPageSuccess, BaseAction);

LandingPageSuccess.prototype.getIconClass = function() {
    return 'icon--form-success';
}

LandingPageSuccess.prototype.getActionName = function() {
    return "Form Success";
}

LandingPageSuccess.prototype.getTargetText = function() {
	var title = this.marketingAction.landingPage.name;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = LandingPageSuccess;
