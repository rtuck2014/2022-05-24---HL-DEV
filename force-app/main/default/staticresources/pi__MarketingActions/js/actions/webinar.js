var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var Webinar = function(){
  BaseAction.apply(this, arguments);
}

inherits(Webinar, BaseAction);

Webinar.prototype.getIconClass = function() {
  return 'icon--webinar';
}

Webinar.prototype.getTargetText = function() {
  if (this.marketingAction.webinar && this.marketingAction.webinar.name) {
    return this.marketingAction.webinar.name;
  } else {
    return 'Untitled';
  }
}

module.exports = Webinar;
