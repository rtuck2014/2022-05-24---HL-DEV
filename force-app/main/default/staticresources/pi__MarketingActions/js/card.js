var cardTemplate = require('jade!../../../templates/card.jade');
var ActionFactory = require('./action_factory.js');
var Visitor = require('./visitor.js');
var Prospect = require('./prospect.js');
var actionsCache = require('../../../js/caches/marketing-actions.js');
var maProspectDataConverter = require('./ma_prospect_data_converter.js');
var timeAgo = require('./time_ago.js');
var forceNavigator = require('../../../js/force-navigator.js');
var MAX_HISTORY_ACTIONS_TO_RENDER = 3;

var Card = function(marketingAction, parentElement) {
	this.marketingAction = marketingAction;
	this.parentElement = parentElement;
	if(marketingAction.prospect){
		this.prospect = new Prospect(maProspectDataConverter(marketingAction.prospect));
	}
};

Card.prototype.render = function(){
	this.element = $(cardTemplate(this));
	if(renderAction(this.marketingAction, this.element.find('.most-recent-action'))){
		this.parentElement.append(this.element);
		handleSeeMoreActionsClick.call(this);
		handleVisitorLinkClick.call(this);
		tryToRenderAvatar.call(this);
	}
}

Card.prototype.getFullName = function(){
	if(this.prospect){
		return this.prospect.getFullName();
	}
}

Card.prototype.getCompany = function(){
	if(this.prospect){
		var company = this.prospect.getCompany();
		if(company)
			return company;
	}

	var whois = this.marketingAction.whois;
	if(whois && whois.company){
		return whois.company;
	}
}

Card.prototype.getVisitorIcon = function(){
	if(this.prospect){
		return 'icon--lead';
	} else {
		return 'icon--company';
	}
}

Card.prototype.getPathToRecordView = function(){
	var visitorId = getVisitorId.call(this);

	if(this.prospect){
		return this.prospect.getPathToRecordView(visitorId);
	} else if(visitorId) {
		return 'visitor?visitor_id=' + visitorId;
	} else {
		throw 'Card has no visitor or prospect.';
	}
}

Card.prototype.getTimeAgo = function(){
	return timeAgo.getTimeAgo(this.marketingAction.createdAt);
}

function getVisitorId(){
	if(this.marketingAction.visitor){
		return this.marketingAction.visitor.id;
	}
	return null;
}

function renderAction(marketingAction, element){
	var action;
	try {
		action = getAction(marketingAction, element);
	} catch(e){
		console.log(e);
		console.log(marketingAction);
		return false;
	}

	action.render();
	return true;
}

function getAction(marketingAction, element){
	var ActionClass = ActionFactory.getActionClass(marketingAction);
	return new ActionClass(marketingAction, element);
}

function handleSeeMoreActionsClick(){
	var _this = this;

	onSeeMoreActionsClick.call(this, function(){
		if(!_this.hasFetchedHistory){
			_this.hasFetchedHistory = true;
			fetchAndRenderHistory.call(_this);
		} else {
			toggleMoreActions.call(_this);
		}
	});
}

function fetchAndRenderHistory(){
	var _this = this;
	startLoading.call(this);

	getMoreActions.call(this, function(actions){
		if(actions.length > 0){
			renderMoreActions(actions, _this.element);
			toggleMoreActions.call(_this);
			stopLoading.call(_this);
		} else {
			unbindSeeMoreActionsClick.call(_this);
		}
	});
}

function startLoading(){
	this.element.find('> .dots').addClass('loading');
}

function stopLoading(){
	this.element.find('> .dots').removeClass('loading');
}

function toggleMoreActions(){
	this.element.find('.more-actions').slideToggle();
	var timeAgo = this.element.find('.most-recent-action .time-ago');
	var parent = this;
	timeAgo.slideToggle({ complete: function(){
		var $this = $(this);
		var dots = parent.element.find('.see-more-actions.dots');
		if ($this.css('display') == 'block') {
			dots.fadeTo(200, 0);
		} else {
			dots.fadeTo(200, 1);
		}
	}});


}

function onSeeMoreActionsClick(callback){
	this.element.on('click', '.see-more-actions, .actions', function(event){
		event.preventDefault();
		callback();
	});
}

function unbindSeeMoreActionsClick(){
	this.element.off('click', '.see-more-actions, .actions');
	this.element.find('.more-actions, .see-more-actions').fadeOut('fast', function(){
		$(this).remove();
	});
}

function getMoreActions(callback){
	var self = this;
	var person = getPerson.call(this);
	var limit = 30;
	var includePageViews = true;

	actionsCache.getForPerson(person, limit, includePageViews, function(actions){
		actions = removeCurrentActionAndVisits.call(self, actions);
		callback(actions);
	});
}

function removeCurrentActionAndVisits(actions){
	var currentActionId = this.marketingAction.id;
	var retActions = [];

	for(var i = 0; i < actions.length; i++){
		if(actions[i].id != currentActionId && actions[i].type != 'Visit'){
			retActions.push(actions[i]);
		}
	}

	return retActions;
}

function getPerson(){
	if(this.marketingAction.prospect){
		return { id: this.marketingAction.prospect.id, type: 'prospect' }
	} else if(this.marketingAction.visitor){
		return { id: this.marketingAction.visitor.id, type: 'visitor' }
	}

	throw 'Card has neither a prospect nor visitor';
}

function renderMoreActions(actions, element){
	var actionsRendered = 0, action, rendered;

	for(var i = 0; i < actions.length; i++){
		action = actions[i];
		rendered = renderAction(action, element.find('.more-actions'));
		if(rendered){
			if(++actionsRendered == MAX_HISTORY_ACTIONS_TO_RENDER){
				break;
			}
		}

	}
}

function handleVisitorLinkClick(){
	var _this = this;

	this.element.on('click', 'a.details-link', function(event){
		event.preventDefault();
		if(!_this.prospect){
			navigateToVisitorPage.call(_this);
		} else {
			navigateToProspect.call(_this);
		}
	});
}

function navigateToProspect(){
	var crmFid = this.prospect.getCrmFid();
	if(crmFid){
		forceNavigator.navigateToObject(crmFid);
	} else {
		var visitorId = getVisitorId.call(this);
		var page = this.prospect.getPathToRecordView(visitorId);
		forceNavigator.navigateToPage(page);
	}
}

function navigateToVisitorPage(){
	var visitorId = this.marketingAction.visitor.id;
	var page = 'visitor?visitor_id=' + visitorId;
	forceNavigator.navigateToPage(page);
}

function tryToRenderAvatar(){
	if(this.prospect){
		this.prospect.tryToRenderAvatar(this.element.find('.avatar'));
	}
}

module.exports = Card;
