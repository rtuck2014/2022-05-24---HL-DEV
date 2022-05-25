var ChatTranscript = require('./actions/chat-transcript.js');
var CustomRedirect = require('./actions/custom-redirect.js');
var EmailClick = require('./actions/email-click.js');
var EmailOpen = require('./actions/email-open.js');
var Event = require('./actions/event.js');
var File = require('./actions/file.js');
var Form = require('./actions/form.js');
var FormSuccess = require('./actions/form-success.js');
var FormError = require('./actions/form-error.js');
var FormHandlerSuccess = require('./actions/form-handler-success.js');
var FormHandlerError = require('./actions/form-handler-error.js');
var LandingPage = require('./actions/landing-page.js');
var LandingPageSuccess = require('./actions/landing-page-success.js');
var LandingPageError = require('./actions/landing-page-error.js');
var PageView = require('./actions/page-view.js');
var PaidSearchAd = require('./actions/paid-search-ad.js');
var SiteSearchQuery = require('./actions/site-search-query.js');
var SocialPostClick = require('./actions/social-post-click.js');
var UserVoice = require('./actions/user-voice.js');
var Video = require('./actions/video.js');
var Visit = require('./actions/visit.js');
var WebVisit = require('./actions/web-visit.js');
var Webinar = require('./actions/webinar.js');

function getActionClass(marketingAction){
	// Calling eval can be dangerous.
	//   Strip out all non alphabet characters before calling eval() on the marketingAction type
	var className = marketingAction.type.replace(/[^A-Za-z]/g, '');

	// JsHint will error out when calls to eval have been detected
	/* jshint ignore:start */
	var actionClass = eval(className);
	/* jshint ignore:end */

	if(typeof actionClass === 'function'){
		return actionClass;
	} else {
		throw 'Action class ' + marketingAction.type + ' not defined.';
	}
}

module.exports = {
	getActionClass: getActionClass
};
