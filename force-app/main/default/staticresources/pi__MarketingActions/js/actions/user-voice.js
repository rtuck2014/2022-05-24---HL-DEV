var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var UserVoice = function(){
  BaseAction.apply(this, arguments);
}

inherits(UserVoice, BaseAction);

UserVoice.prototype.getIconClass = function() {
  return 'icon--user-voice';
}

UserVoice.prototype.getTargetText = function() {
  if (this.marketingAction.userVoice && this.marketingAction.userVoice.name) {
    return this.marketingAction.userVoice.name;
  } else {
    return "Untitled";
  }
}

module.exports = UserVoice;
