var inherits = require('inherits');
var BaseAction = require('./base-action.js');

var Event = function(){
  BaseAction.apply(this, arguments);
}

inherits(Event, BaseAction);

Event.prototype.getIconClass = function() {
  return 'icon--event';
}

Event.prototype.getTargetText = function() {
  if (this.marketingAction.event && this.marketingAction.event.name) {
    return this.marketingAction.event.name;
  } else {
    return "Untitled";
  }
}

module.exports = Event;
