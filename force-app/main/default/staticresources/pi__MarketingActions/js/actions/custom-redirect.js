var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var CustomRedirect = function(){
	BaseAction.apply(this, arguments);
}

inherits(CustomRedirect, BaseAction);

CustomRedirect.prototype.getIconClass = function() {
	return 'icon--custom-redirect';
}

CustomRedirect.prototype.getTargetText = function() {
	if (this.marketingAction.customUrl && this.marketingAction.customUrl.name) {
		return this.marketingAction.customUrl.name;
	} else {
		return "Untitled";
	}
}

module.exports = CustomRedirect;
