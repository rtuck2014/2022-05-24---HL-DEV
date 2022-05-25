var inherits = require('inherits');
var BaseAction = require('./base-action.js');
var actionCache = require('../../../../js/caches/marketing-actions.js')
var actionRenderer = require('../action_renderer.js');

var Visit = function(){
	BaseAction.apply(this, arguments);
	this.isVisit = true;
}

inherits(Visit, BaseAction);

Visit.prototype.getIconClass = function() {
	return 'icon--page-view';
}

Visit.prototype.getTargetText = function() {
	var count = this.marketingAction.visit.pageViewCount;
	if(count){
		return count + ' Page Views';
	} else {
		return '';
	}
}

Visit.prototype.getActionName = function() {
	return "Visit";
}

Visit.prototype.render = function(){
	BaseAction.prototype.render.call(this);
	handleClick.call(this);
}

function handleClick(){
	var self = this;
	this.element.on('click', function(event){
		if (self.onClickCallback) {
			self.onClickCallback(event, self);
		}
	})
}

module.exports = Visit;
