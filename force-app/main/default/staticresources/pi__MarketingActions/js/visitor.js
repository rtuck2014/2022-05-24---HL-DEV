var actionsCache = require('../../../js/caches/marketing-actions.js');
var Card = require('./card.js');
var ActionFactory = require('./action_factory.js');
var template = require('jade!../../../templates/anonymous.jade');
var fakeRecordUtil = require('./fake_record_ui_util.js');
var NUMBER_OF_ACTIONS_TO_SHOW = 60;

var Visitor = function(visitorId){
	this.visitor = { id: visitorId, type: 'visitor' };
}

Visitor.prototype.render = function(){
	var self = this;
	actionsCache.getForPerson(this.visitor, NUMBER_OF_ACTIONS_TO_SHOW+1, false, function(actions){
		self.card = new Card(actions[0]);
		self.actions = actions;
		self.element = $(template(self));
		$('body').empty().append(self.element);
		fakeRecordUtil.handleTabClicks(self.element);
		renderActions.call(self);
	});
}

Visitor.prototype.getTitle = function(){
	return this.card.getFullName() || this.card.getCompany();
}

Visitor.prototype.getAddressOne = function(){
	return getVisitorProperty(this, 'addressOne');
}

Visitor.prototype.getAddressTwo = function(){
	return getVisitorProperty(this, 'addressTwo');
}

Visitor.prototype.getCityState = function(){
	var city = getVisitorProperty(this, 'city');
	var state = getVisitorProperty(this, 'state');
	if(city && state){
		return city + ', ' + state;
	} else if(city) {
		return city;
	} else if(state) {
		return state;
	}
}

Visitor.prototype.getCountry = function(){
	return getVisitorProperty(this, 'country');
}

Visitor.prototype.getPhone = function(){
	return getVisitorProperty(this, 'phone') || 'unknown';
}

Visitor.prototype.getIcon = function(){
	return this.card.getVisitorIcon();
}

Visitor.prototype.getPhotoUrl = function(){
	return this.card.getPhotoUrl();
}

function getVisitorProperty(_this, property){
	var prospect = _this.card.marketingAction.prospect;
	var whois = _this.card.marketingAction.whois;
	if(prospect && prospect[property] && prospect[property].trim() !== ''){
		return prospect[property];
	} else if(whois && whois[property] && whois[property].trim() !== ''){
		return whois[property];
	}
}

function renderActions(){
	var parentElement = this.element.find('.actions');

	this.actions.forEach(function(action){
		renderAction(action, parentElement);
	});

	if(this.actions.length > NUMBER_OF_ACTIONS_TO_SHOW){
		this.element.find('.count').text(NUMBER_OF_ACTIONS_TO_SHOW+'+');
	} else{
		this.element.find('.count').text(this.actions.length);
	}
}

function renderAction(marketingAction, parentElement){
	var action;
	try {
		action = getAction(marketingAction, parentElement, onActionClickedCallback);
	} catch(e){
		return console.log(e);
	}

	action.render();
}

function getAction(marketingAction, parentElement, onClickCallback){
	var ActionClass = ActionFactory.getActionClass(marketingAction);
	var action = new ActionClass(marketingAction, parentElement);
	action.setOnClickCallback(onClickCallback);

	return action;
}

function onActionClickedCallback(event, action) {
	if (!action.isVisit) {
		return;
	}

	if (action.element.find('.sub-elements').first().children().length > 0) {
		toggleSubElementsVisibility(action.element);
	} else {
		action.element.find('.dots').addClass('loading');
		actionsCache.getForVisit({ id: action.marketingAction.visit.id }, function(actions){
				renderVisitActions(action, actions);
		});
	}
}

function renderVisitActions(parentAction, visitActions) {
	var actionsElement = parentAction.element.find('.sub-elements').first();
	visitActions.forEach(function(visitAction) {
		renderAction(visitAction, actionsElement);
	});

	toggleSubElementsVisibility(parentAction.element);

	parentAction.element.find('.dots').removeClass('loading');
}

function toggleSubElementsVisibility(element) {
	var subElements = element.find('.sub-elements').first();
	var downArrow = element.find('.arrow > .icon-utility-down');
	var rightArrow = element.find('.arrow > .icon-utility-right');

	if (subElements.is(':visible')) {
		subElements.slideToggle();
		rightArrow.show();
		downArrow.hide();
	} else {
		subElements.slideToggle();
		rightArrow.hide();
		downArrow.show();
	}

	element.find('.dots').removeClass('loading');
}

module.exports = Visitor;
