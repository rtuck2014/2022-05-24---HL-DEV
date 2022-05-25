function errorBarOverSendLimitMessage (totalSendLimit, resetMessage){
  return 'You have reached your daily email send limit of '+totalSendLimit+'. Limit will reset '+resetMessage;
};

function errorBarTooManyRecipients (netPardotEmailSends, emailText, recipientText){
  return 'You have selected '+(-1 * netPardotEmailSends)+' more '+emailText+' than you are allowed to send today. Please delete '+(-1 * netPardotEmailSends)+' '+recipientText+' to send your campaign.';
};

function alertAllRecipientsInvalidByUnmailable (recipientType){
  return 'All of the ' + recipientType + 's you\'ve selected have opted out of emails.';
};

function alertAllRecipientsInvalidByNoEmailAddress (recipientType){
  if (recipientType == 'Recipient') {
    recipientType = 'recipient'; // per UX
  }
  return 'You must select at least one ' + recipientType + ' with a valid email address.';
};

function alertInvalidObjectType(recipientType){
  return 'This action is not supported on this page. This action is only supported on Lead, Contact, and Person Account pages.';
};

function alertRedirectionMessage (recipientType){
  return '\n\nYou will now be directed back to the ' + recipientType + 's tab';
};

function noTemplateSelectedPrimaryMessage(){
  return "No Template Selected";
};

function messageWhenPmlTagsFoundInHmlContent() {
  return "We can’t send this email because it contains outdated merge fields. Update all merge fields to Handlebars Merge Language and try again.";
}

function noTemplateSelectedSecondaryMessage(){
  return "Click to close and view templates";
};

function allRecipientsRemoved(){
  return 'You have deleted the available recipients, you will not be able to send an email.';
};

function userHasInsufficientAccess(){
  return 'You have insufficient access to view this content.';
};

function errorBarRecipientsAreNotListed(recipientsWithoutEmail){
  var recipientString = 'recipient';
  var areOrIs = 'is';

  if(recipientsWithoutEmail > 1) {
    recipientString += 's';
    areOrIs = 'are';
  }
  return ' ' + recipientsWithoutEmail + ' ' + recipientString + ' ' + areOrIs + ' not listed, find out why »';
};

function errorBarRecipientsAreUnmailable(unmailableRecipients){
  var recipientString = 'recipient';
  var areOrIs = 'is';
  var haveOrHas = 'has';

  if(unmailableRecipients > 1) {
    recipientString += 's';
    areOrIs = 'are';
    haveOrHas = 'have';
  }
  return ' ' + unmailableRecipients + ' ' + recipientString + ' ' + areOrIs + ' unmailable and ' + haveOrHas + ' been removed from the list. Show removed ' + recipientString + ' »';
};

function errorBarRecipientsHaveDuplicateEmails(duplicateEmailRecipients){
  var recipientString = 'recipient';
  var haveOrHas = 'has';
  var containOrContains = 'contains';

  if(duplicateEmailRecipients > 1) {
    recipientString += 's';
    haveOrHas = 'have';
    containOrContains = 'contain';
  }
  return ' ' + duplicateEmailRecipients + ' ' + recipientString + ' ' +  containOrContains + ' the same email address as another record and ' + haveOrHas + ' been removed from the list. Show removed ' + recipientString + ' »';
};

function cannotSendWithoutSubject (){
  return "Cannot send email without a subject.";
};

function errorPardotGettingVariableTags (){
	return "There was an error retrieving the Pardot variable tags.";
};

function messageWhenErrorLoadingLexTemplate(templateName) {
	return "We couldn’t load the template" + (templateName ?  " " + templateName : "") + ". Select a different template and try again.";
};

function salesforceTagsUsedOnPardotTemplate(){
  return "It looks like you are using Salesforce merge fields in your email, " +
    "however the email is being sent using Pardot's marketing template format. " +
    "Please use Pardot variable tags instead. " +
    "For more information about Pardot variable tags check out " +
    "<a href='http://www.pardot.com/faqs/emails/variable-tags/' target='_blank'>http://www.pardot.com/faqs/emails/variable-tags/</a>" +
    ".";
}

function errorBarUnsupportedTagsFound(numOfTags){
    var tagsOrTag = 'tag';
    var areOrIs = 'is';
    var theyOrIt = 'It';

    if(numOfTags > 1) {
        areOrIs = 'are';
        theyOrIt = 'They';
        tagsOrTag+='s';
    }
    return `You have ${numOfTags} ${tagsOrTag} that ${areOrIs} not supported for this email. ${theyOrIt} will appear blank to your recipients.`;
};

module.exports = {
  errorBarOverSendLimitMessage: errorBarOverSendLimitMessage,
  errorBarTooManyRecipients: errorBarTooManyRecipients,
  alertAllRecipientsInvalidByUnmailable: alertAllRecipientsInvalidByUnmailable,
  alertAllRecipientsInvalidByNoEmailAddress: alertAllRecipientsInvalidByNoEmailAddress,
  alertInvalidObjectType: alertInvalidObjectType,
  alertRedirectionMessage: alertRedirectionMessage,
  noTemplateSelectedPrimaryMessage: noTemplateSelectedPrimaryMessage,
  noTemplateSelectedSecondaryMessage: noTemplateSelectedSecondaryMessage,
  allRecipientsRemoved: allRecipientsRemoved,
  errorBarRecipientsAreNotListed: errorBarRecipientsAreNotListed,
  errorBarRecipientsAreUnmailable: errorBarRecipientsAreUnmailable,
  cannotSendWithoutSubject: cannotSendWithoutSubject,
  errorPardotGettingVariableTags: errorPardotGettingVariableTags,
  salesforceTagsUsedOnPardotTemplate: salesforceTagsUsedOnPardotTemplate,
  errorBarRecipientsHaveDuplicateEmails: errorBarRecipientsHaveDuplicateEmails,
  userHasInsufficientAccess: userHasInsufficientAccess,
  errorBarUnsupportedTagsFound: errorBarUnsupportedTagsFound,
  messageWhenErrorLoadingLexTemplate: messageWhenErrorLoadingLexTemplate,
  messageWhenPmlTagsFoundInHmlContent: messageWhenPmlTagsFoundInHmlContent
}
