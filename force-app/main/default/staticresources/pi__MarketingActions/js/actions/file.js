var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var File = function(){
	BaseAction.apply(this, arguments);
}

inherits(File, BaseAction);

File.prototype.getActionName = function() {
	return 'Downloaded File';
}

File.prototype.getIconClass = function() {
	return 'icon--file';
}

File.prototype.getTargetText = function() {
	if (this.marketingAction.file && this.marketingAction.file.name) {
		return this.marketingAction.file.name;
	} else {
		return "Untitled";
	}
}

module.exports = File;
