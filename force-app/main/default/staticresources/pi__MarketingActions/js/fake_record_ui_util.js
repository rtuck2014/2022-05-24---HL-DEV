function handleTabClicks(element){
	element.on('click', '.tabs .tab:not(.disabled)', function(){
		var tab = $(this);
		tab.addClass('active').siblings().removeClass('active');
		element.find('.pane').hide().filter('.' + tab[0].id).show();
	});
}

module.exports = {
	handleTabClicks: handleTabClicks
}
