var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var SiteSearchQuery = function(){
	BaseAction.apply(this, arguments);
}

inherits(SiteSearchQuery, BaseAction);

SiteSearchQuery.prototype.getIconClass = function() {
	return 'icon--search';
}

SiteSearchQuery.prototype.getTargetText = function() {
	if (this.marketingAction.siteSearchQuery && this.marketingAction.siteSearchQuery.query) {
		return this.marketingAction.siteSearchQuery.query;
	} else {
		return "Untitled";
	}
}

module.exports = SiteSearchQuery;
