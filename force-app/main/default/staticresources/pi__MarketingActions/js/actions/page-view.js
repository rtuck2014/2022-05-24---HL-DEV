var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var PageView = function(){
	BaseAction.apply(this, arguments);
}

inherits(PageView, BaseAction);

PageView.prototype.getActionClass = function() {
	return 'page-view';
}

PageView.prototype.getIconClass = function() {
	return 'icon--page-view';
}

PageView.prototype.getTargetText = function() {
	var title = this.marketingAction.pageView.title;
	if (!title) {
		title = 'Untitled';
	}

	return title;
}

module.exports = PageView;
