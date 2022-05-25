var template = require('jade!../../../templates/selectable_filter.jade');

var SelectableFilter = function(filter, parentElement){
    this.filter = filter;
    this.element = $(template(this));
    parentElement.append(this.element);

    handleClick.call(this);
    handleCheckboxClicked.call(this);

    if (this.filter.defaultFilter) {
      this.element.find('.default-filter').show();
    }
}

SelectableFilter.prototype.isChecked = function(){
    return this.element.find('input[type="checkbox"]').is(':checked');
}

SelectableFilter.prototype.hideCheckbox = function(){
    this.element.find('.checkbox').hide().find('input[type="checkbox"]').prop('checked', false);
}

SelectableFilter.prototype.onClick = function(handler){
    this.selectedHandler = handler;
}

SelectableFilter.prototype.onCheckboxClick = function(handler){
    this.checkboxClickedHandler = handler;
}

SelectableFilter.prototype.toggleCheckbox = function(){
    this.element.find('.checkbox').toggle('fast').find('input[type="checkbox"]').prop('checked', false);
}

SelectableFilter.prototype.remove = function(callback){
    var that = this;
    this.element.hide('fast', function(){
        that.element.remove();
        callback();
    });
}

function handleClick(){
    var that = this;
    this.element.on('click', function(){
        if(that.selectedHandler){
            var checkBoxWasClicked = $(event.target).is('input');
            if(!checkBoxWasClicked){
                that.selectedHandler(that.filter);
            }
        }
    });
}

function handleCheckboxClicked(){
    var that = this;
    this.element.find('input[type="checkbox"]').on('click', function(event){
        if(that.checkboxClickedHandler){
            that.checkboxClickedHandler();
        }
    })
}

module.exports = SelectableFilter;
