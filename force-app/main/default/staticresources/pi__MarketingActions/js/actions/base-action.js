var template = require('jade!../../../../templates/marketing_action.jade');
var timeAgo = require('../time_ago.js');

var BaseAction = function(marketingAction, parentElement) {
	this.marketingAction = marketingAction;
	this.parentElement = parentElement;
};

BaseAction.prototype.render = function() {
	this.element = $(template(this));
	this.parentElement.append(this.element);
}

BaseAction.prototype.getActionClass = function(){
	return '';
}

BaseAction.prototype.getActionName = function() {
	return this.marketingAction.type;
}

BaseAction.prototype.getIconClass = function() {
	throw 'getIconClass() not implemented'
}

BaseAction.prototype.getTargetText = function() {
	throw 'getTargetText() not implemented'
}

BaseAction.prototype.getTimeAgo = function() {
	return timeAgo.getTimeAgo(this.marketingAction.createdAt);
}

BaseAction.prototype.setOnClickCallback = function(onClickCallback) {
	this.onClickCallback = onClickCallback;
}

module.exports = BaseAction;
