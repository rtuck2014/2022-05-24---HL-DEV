var template = require('jade!../../../templates/prospect.jade');
var prospectCache = require('../../../js/caches/prospect.js');
var fakeRecordUtil = require('./fake_record_ui_util.js');
var actionsCache = require('../../../js/caches/marketing-actions.js');
var ActionFactory = require('./action_factory.js');
var loader = require('../../../js/basic-loader.js');
var NUMBER_OF_ACTIONS_TO_SHOW = 60;


var Prospect = function(){
	switch(typeof arguments[0]){
		case 'object':
			this.prospect = arguments[0];
			break;
		case 'string':
		case 'number':
			this.prospectId = arguments[0];
			break;
		default:
			throw new Error('Invalid argument for Prospect. Expecting a prospect object or prospect id!');
	}
	if(arguments[1] && (typeof arguments[1] == 'string' || typeof arguments[1] == 'number')){
		this.visitorId = arguments[1];
	}
}

Prospect.prototype.render = function(){
	var _this = this;
	loader.start();

	prospectCache.get(getProspectId.call(this), function(prospect){
		_this.prospect = prospect;
		renderIfAllRemoteDataHasBeenFetched.call(_this);
	});

	if(this.visitorId || getProspectId.call(this)){
		getHistory.call(this, function(actions){
			_this.marketingActions = actions;
			renderIfAllRemoteDataHasBeenFetched.call(_this);
		});
	}

}

Prospect.prototype.getFullName = function(){
	var firstName = this.prospect.first_name;
	var lastName = this.prospect.last_name;
	if(firstName && lastName){
		return firstName + ' ' + lastName;
	} else if(firstName){
		return firstName;
	} else if(lastName){
		return lastName;
	} else if(this.prospect.email){
		return this.prospect.email;
	} else {
		return 'Name Unknown';
	}
}

Prospect.prototype.getCompany = function(){
	if(this.prospect.company){
		return this.prospect.company;
	}
}

Prospect.prototype.getPathToRecordView = function(visitorId){
	var crmFid = this.getCrmFid();
	if(crmFid){
		return crmFid;
	}

	var path = 'visitor' + '?prospect_id=' + this.prospect.id;

	if(visitorId){
		path += path.indexOf('?') === -1 ? '?' : '&';
		path += 'visitor_id=' + visitorId;
	}

	return path;
}

Prospect.prototype.tryToRenderAvatar = function(element){
	var fid = this.getCrmFid();

	if(!fid)
		return;

	var image = new Image();
	image.onload = function(){
		element.replaceWith($(image));
	}
	image.src = '/services/images/photo/' + fid;
}

Prospect.prototype.getEmail = function(){
	return this.prospect.email;
}

Prospect.prototype.getPhone = function(){
	return this.prospect.phone;
}

Prospect.prototype.getGrade = function(){
	return this.prospect.grade;
}

Prospect.prototype.getScore = function(){
	return this.prospect.score;
}

Prospect.prototype.getJobTitle = function(){
	return this.prospect.job_title;
}

Prospect.prototype.getCrmFid = function(){
	var fid = null;
	if (this.prospect.crm_lead_fid && this.prospect.crm_lead_fid.indexOf('[[') !== 0) {
		fid = this.prospect.crm_lead_fid;
	} else if (this.prospect.crm_contact_fid && this.prospect.crm_contact_fid.indexOf('[[') !== 0) {
		fid = this.prospect.crm_contact_fid;
	}

	return fid;
}

function getProspectId(){
	if(this.prospectId){
		return this.prospectId;
	} else if(this.prospect){
		return this.prospect.id;
	}

	return null;
}

function renderIfAllRemoteDataHasBeenFetched(){
	if( !(this.prospect && this.marketingActions) ){
		return;
	}

	this.element = $(template(this));
	$('body').empty().append(this.element);
	this.tryToRenderAvatar(this.element.find('.avatar'));
	fakeRecordUtil.handleTabClicks(this.element);

	renderActions.call(this);
	loader.stop();
}

function renderActions(){
	var totalNumberOfActions = this.marketingActions.length;

	var actionsCopy = JSON.parse(JSON.stringify(this.marketingActions));
	actionsCopy.splice(NUMBER_OF_ACTIONS_TO_SHOW);

	var actionsElement = this.element.find('.actions');
	actionsCopy.forEach(function(action){
		renderAction(action, actionsElement, onActionClickedCallback);
	});

	if(totalNumberOfActions > NUMBER_OF_ACTIONS_TO_SHOW){
		this.element.find('.count').text(NUMBER_OF_ACTIONS_TO_SHOW+'+');
	} else{
		this.element.find('.count').text(totalNumberOfActions);
	}
}

function renderAction(marketingAction, parentElement, actionClickCallback){
	var action, ActionClass;
	try {
		ActionClass = ActionFactory.getActionClass(marketingAction);
		action = new ActionClass(marketingAction, parentElement, actionClickCallback);
		action.setOnClickCallback(onActionClickedCallback);
	} catch(e){
		return console.log(e);
	}

	action.render();
}

function getHistory(callback){
	var prospectId = getProspectId.call(this);
	var person = prospectId ? { id: prospectId, type: 'prospect' } : { id: this.visitorId, type: 'visitor' };
	var limit = NUMBER_OF_ACTIONS_TO_SHOW;
	var includePageViews = false;

	actionsCache.getForPerson(person, limit+1, includePageViews, callback);
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
	visitActions.forEach(function(action){
		renderAction(action, actionsElement);
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

module.exports = Prospect;
