var template = require('jade!../../../templates/filter_selection.jade');
var selectableFilters;
var element;
var filterSelectedHandler;
var filterCheckboxShowLinkSelector = '.filter-header .select-filter';
var filterCheckboxToggleLinksSelector = filterCheckboxShowLinkSelector + ', .filter-header a.cancel';
var SelectableFilter = require('./selectable_filter.js');
var toolbar = require('./filter_toolbar.js');

function setup(filterData, parentElement){
	element = $(template()).hide();
	setupSelectableFilters(filterData, element.find('ul.select'));
	parentElement.append(element);
	setupClickHandlers();
	setupToolbar();
}

function setupSelectableFilters(filterData, element){
	selectableFilters = [];
	filterData.forEach(function(filter){
		var selectableFilter = new SelectableFilter(filter, element);
		selectableFilter.onClick(filterSelected);
		selectableFilter.onCheckboxClick(checkboxClicked);
		selectableFilters.push(selectableFilter);
	});
}

function filterSelected(filter){
	if(inMultiSelectionMode()){
		return;
	}

	renderFilter(filter);
	toggleFilterDropDown();
}

function checkboxClicked(){
	var filterIds = [];

	selectableFilters.forEach(function(selectableFilter){
		if(selectableFilter.isChecked()){
			filterIds.push(selectableFilter.filter.id);
		}
	});

	toolbar.updatedSelectedFilters(filterIds);
}

function setupToolbar(){
	toolbar.setup(element.find('.filter-toolbar'));
	toolbar.onFiltersDeleted(removeFilters);
}

function removeFilters(filterIds){
	var filtersRemoved = 0;
	var newSelectableFilters = selectableFilters.slice(0);

	filterIds.forEach(function(filterId){
		var i = 0;
		selectableFilters.forEach(function(selectableFilter){
			if(selectableFilter.filter.id == filterId){
				selectableFilter.remove(filterRemoved);
				newSelectableFilters.splice(i, 1);
			}
			i++;
		});

		selectableFilters = newSelectableFilters;
	});
}

function filterRemoved(){
	if(selectableFilters.length == 0){
		window.location.reload();
	} else {
		updateCurrentFilter(selectableFilters[0].filter);
	}
}

function setFilterSelectedHandler(callback){
	filterSelectedHandler = callback;
}

function render(){
	var filter = getPreviouslyUsedFilter();
	if(filter){
		renderFilter(filter);
	} else {
		renderNoFiltersMessage();
	}
	element.show();
}

function renderFilter(filter){
	updateCurrentFilter(filter);
	if(filterSelectedHandler){
		filterSelectedHandler(filter);
	}
}

function renderNoFiltersMessage(){
	element.find('.filter-header').hide();
	element.find('.no-filters').show();
}

function setupClickHandlers(){
	element.on('click', '.current-filter', function(event){
		event.preventDefault();
		toggleFilterDropDown();
	});

	handleFilterCheckboxToggleLinks();
}

function handleFilterCheckboxToggleLinks(){
	element.on('click', filterCheckboxToggleLinksSelector, function(event){
		event.preventDefault();
		element.find(filterCheckboxToggleLinksSelector).toggle();

		selectableFilters.forEach(function(selectableFilter){
			selectableFilter.toggleCheckbox();
		});

		element.find('ul.select').toggleClass('in-multi-selection-mode');
		toolbar.updatedSelectedFilters([]);
	});
}

function inMultiSelectionMode(){
	return element.find('ul.select').is('.in-multi-selection-mode');
}

function getPreviouslyUsedFilter(){
	var previouslyUsedFilter;

	if(window.localStorage && localStorage.hasOwnProperty('lastFilterId')) {
		var filterId = localStorage.lastFilterId;
		var filter;
		for(var i = 0; i < selectableFilters.length; i++){
			filter = selectableFilters[i].filter;
			if(filter.id == filterId){
				previouslyUsedFilter = filter;
				break;
			}
		}
	}

	if(previouslyUsedFilter){
		return previouslyUsedFilter;
	} else if(selectableFilters[0]) {
		return selectableFilters[0].filter;
	}
}

function saveMostRecentFilterToLocalStorage(filterId){
	if(window.localStorage){
		localStorage.lastFilterId = filterId;
	}
}

function updateCurrentFilter(filter){
	var currentFilterText = element.find('.current-filter .text');
	currentFilterText.text(filter.title);
	saveMostRecentFilterToLocalStorage(filter.id);
}

function toggleFilterDropDown(){
	toggleDropdownArrow();
	var dropDown = element.find('.select');

	if(dropDown.is(':visible')){
		element.find(filterCheckboxToggleLinksSelector).fadeOut();
		$('#marketing_actions').show().css({ height: 'auto' }).animate({'margin-top': '0'});
		$('#new-filter-message-section').show();
	} else {
		resetSelectionMode();
		$('#marketing_actions').animate({'margin-top': '150%'}, function(){
			$(this).hide();
		});
		$('#new-filter-message-section').hide();
	}

	dropDown.slideToggle('fast');
	element.find('.current-filter').find('.filter-selection-title, .text').toggle();

	toolbar.toggle();
}

function resetSelectionMode(){
	element.find(filterCheckboxShowLinkSelector).fadeIn();
	element.find('ul').removeClass('in-multi-selection-mode');
	selectableFilters.forEach(function(selectableFilter){
		selectableFilter.hideCheckbox();
	});

	toolbar.updatedSelectedFilters([]);
}

function toggleDropdownArrow(){
	var arrow =  element.find('.dd-arrow');

	if(arrow.is('.flip-up')){
		arrow.removeClass('flip-up').addClass('flip-down');
	} else {
		arrow.removeClass('flip-down').addClass('flip-up');
	}
}

module.exports = {
	setup: setup,
	setFilterSelectedHandler: setFilterSelectedHandler,
	render: render,
	getPreviouslyUsedFilter: getPreviouslyUsedFilter
}
