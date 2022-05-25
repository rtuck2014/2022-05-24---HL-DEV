var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var ChatTranscript = function(){
  BaseAction.apply(this, arguments);
}

inherits(ChatTranscript, BaseAction);

ChatTranscript.prototype.getIconClass = function() {
  return 'icon--chat-transcript';
}

ChatTranscript.prototype.getTargetText = function() {
  if (this.marketingAction.chatTranscript && this.marketingAction.chatTranscript.name) {
    return this.marketingAction.chatTranscript.name;
  } else {
    return "Untitled";
  }
}

module.exports = ChatTranscript;
