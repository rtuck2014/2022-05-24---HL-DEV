var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var PaidSearchAd = function(){
	BaseAction.apply(this, arguments);
}

inherits(PaidSearchAd, BaseAction);

PaidSearchAd.prototype.getIconClass = function() {
	return 'icon--paid-search-ad';
}

PaidSearchAd.prototype.getTargetText = function() {
	if (this.marketingAction.paidSearchAd && this.marketingAction.paidSearchAd.headline) {
		return this.marketingAction.paidSearchAd.headline;
	} else {
		return "Untitled";
	}
}

module.exports = PaidSearchAd;
