var idIncrement = 0;

function ErrorBar(jQuery) {
	this.$element = jQuery('#generic_error').clone().attr('id', 'generic_error_' + idIncrement++);
	jQuery('#generic_error').after(this.$element);
	this.locked = false;
}

ErrorBar.prototype.show = function(msg, noHide) {
	if (this.locked) {
		return;
	} else {
		//hiding can sometimes be wonky if we're simply updating an error message that's already on the screen.
		if (noHide !== true) {
			this.$element.hide();
		}
		this.$element.find('.text').text(msg).end().show('fast');
	}
}

ErrorBar.prototype.showWithHtml = function(msg, noHide) {
	if (this.locked) {
		return;
	} else {
		//hiding can sometimes be wonky if we're simply updating an error message that's already on the screen.
		if (noHide !== true) {
			this.$element.hide();
		}
		this.$element.find('.text').html(msg).end().show('fast');
	}
}

ErrorBar.prototype.hide = function() {
	if (this.locked) {
		return;
	} else {
		this.$element.hide('fast');
	}
}

ErrorBar.prototype.setLock = function(locked) {
	this.locked = locked;
}

ErrorBar.prototype.onClick = function(fn) {
	this.$element.on('click', fn);
}

function MessageBar(jQuery) {
	this.$element = jQuery('#generic_message').clone().attr('id', 'generic_message_' + idIncrement++);
	jQuery('#generic_message').after(this.$element);
	this.$element.on('click', '.close', this.hide.bind(this));
}

MessageBar.prototype.show = function(msg){
	this.$element.hide()
		.find('.text').text(msg).end()
		.show('fast')
		.addClass('expandable');
}

MessageBar.prototype.onClick = function(fn){
	this.$element.on('click', fn);
}

MessageBar.prototype.hide = function(){
	this.$element.hide('fast');
	return false;
}

module.exports = exports = {
	ErrorBar: ErrorBar,
	MessageBar: MessageBar
}
