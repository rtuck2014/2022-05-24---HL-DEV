var config = require('../../../js/config-built.js');
var filterRepo = require('../../../js/repos/filters-' + config.env + '.js');
var filterCache = require('../../../js/caches/filters.js');
var element;
var selectedFilters = [];
var filterDeletedHandler;
var loader = require('../../../js/basic-loader.js');
import { navigateToPage } from '../../../js/force-navigator';

function setup(el){
	element = el;
	element.on('click', '.edit.button', handleEditButtonClick);
	element.on('click', '.delete.button', handleDeleteButtonClick);
	element.on('click', '.add.button', handleAddButtonClick);
}

function toggle(){
	if(element.is('.open')){
		element.animate({ height: 0 }, function(){
			element.hide();
		});
		element.removeClass('open');
	} else {
		element.addClass('open').show().animate({ height: 64 });
	}
}

function updatedSelectedFilters(filterIds){
	selectedFilters = filterIds;

	if(filterIds.length == 1){
		enableButton('edit');
		enableButton('delete');
	} else if(filterIds.length > 1){
		disableButton('edit');
		enableButton('delete');
	} else {
		disableButton('edit');
		disableButton('delete');
	}
}

function getSelectedFilters(){
	return selectedFilters;
}

function handleAddButtonClick(event){
	navigateToPage('filters', window.NamespacePrefix)
}

function handleEditButtonClick(event){
	if(buttonDisabled('edit')){
		event.preventDefault();
	} else{
		navigateToPage('filters', window.NamespacePrefix, {'Id' : selectedFilters[0]});
	}
}

function handleDeleteButtonClick(event){
	event.preventDefault();
	if(buttonDisabled('delete')){
		return;
	}

	disableButtons();
	loader.start();
	filterRepo.deleteFilters(selectedFilters, function(){
		filterCache.invalidate();
		filterCache.get();
		loader.stop();
		filtersDeleted();
	});
}

function buttonDisabled(buttonClass){
	return element.find('.' + buttonClass + '.button').is('.disabled');
}

function disableButtons(){
	disableButton('edit');
	disableButton('delete');
}

function enableButton(buttonClass){
	var button = element.find('.' + buttonClass + '.button').removeClass('disabled');
}

function disableButton(buttonClass){
	element.find('.' + buttonClass + '.button').addClass('disabled');
}

function onFiltersDeleted(handler){
	filterDeletedHandler = handler;
}

function filtersDeleted(){
	if(filterDeletedHandler){
		filterDeletedHandler(selectedFilters);
	}
	updatedSelectedFilters([]);
}

module.exports = {
	setup: setup,
	toggle: toggle,
	updatedSelectedFilters: updatedSelectedFilters,
	getSelectedFilters: getSelectedFilters,
	onFiltersDeleted: onFiltersDeleted
}
