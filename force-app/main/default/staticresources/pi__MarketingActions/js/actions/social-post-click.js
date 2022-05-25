var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var SocialPostClick = function(){
  BaseAction.apply(this, arguments);
}

inherits(SocialPostClick, BaseAction);

SocialPostClick.prototype.getIconClass = function() {
  return 'icon--social-click';
}

SocialPostClick.prototype.getTargetText = function() {
  if (this.marketingAction.socialPostClick && this.marketingAction.socialPostClick.name) {
    return this.marketingAction.socialPostClick.name;
  } else {
    return 'Untitled';
  }
}

SocialPostClick.prototype.getActionName = function() {
  return 'Social Post Click';
}

module.exports = SocialPostClick;
