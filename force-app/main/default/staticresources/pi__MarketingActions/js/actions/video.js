var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var Video = function(){
	BaseAction.apply(this, arguments);
}

inherits(Video, BaseAction);

Video.prototype.getIconClass = function() {
	return 'icon--video';
}

Video.prototype.getTargetText = function() {
	if (this.marketingAction.video && this.marketingAction.video.name) {
		return this.marketingAction.video.name;
	} else {
		return "Untitled";
	}
}

module.exports = Video;
