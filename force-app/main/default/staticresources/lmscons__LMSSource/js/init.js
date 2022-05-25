$(document).ready(function(){
	
	$('.m-tbl').find('table.m-hide').parent().parent().addClass('m-hide');
	$('.m-tbl').find('table.m-hide').parent().parent().attr('style', 'display: table-row;');
	/*$('.m-tbl').find('table.m-hide tr').addClass('m-faded');*/
	$('.m-tbl').find('table.m-hide').removeClass('m-hide');


	Toggler();
	HideShowToggler();
	Check();
	ShowSession();
	SearchToggler();
	DevPlanToggler();


	/* last/first child */
	$('.m-tbl th:first-child,.m-tbl td:first-child').addClass('m-first');
	$('.m-tbl th:last-child, .m-tbl td:last-child, .m-first-level tr:last-child, .b-dev-plan .b-blue-box:last, .b-additional-tbls:last').addClass('m-last');
	$('.m-first-level .m-second-level').parent().closest('td.m-first-level').addClass('m-no-bord');

	/* chrome/safari fix */
	$('.b-results .m-tbl tr td:nth-child(2)').addClass('m-auto-width');

	/* ie table fix */
	if (/msie/.test(navigator.userAgent.toLowerCase())) 
	{						
	   $(".m-tbl td:empty, .m-tbl thead th div:empty").html("&nbsp;");

	}


});

/* Show/Hide Completed courses */
function Check(){
    
    $(".b-tab-body .m-tbl td:visible:contains('Passed')").prev('td').parent('tr').addClass('m-open-child');
    $(".b-tab-body .m-tbl td:visible:contains('Completed')").prev('td').parent('tr').addClass('m-open-child');
    //$('.b-tab-body .m-open-child').hide();
    
    $('input#a').click(function(a){
        if (a.target.checked)
        {
            $('input#a').attr('checked', true);
            $('.m-open-child').show();
            $('.m-open-child td.m-minus').removeClass('m-minus');
        }
        else
        {
            $('input#a').attr('checked', false);
            $('.m-open-child').hide();
            $('.m-open-child').next('tr.m-hide').hide();
        };
    })
}

/* Login Toggler */
function SearchToggler()
{
	$('.b-search .b-advanced .b-flyout').hide();
	
	$('.b-search .b-advanced .m-toggle-link,.b-search .b-advanced a.b-btn').click(function(){
		$('.b-search .b-advanced .m-toggle-link').toggleClass('m-open');
		$('.b-search .b-advanced .b-flyout').toggle();	
	});	
}

/* Show/Hide Sessions */
function ShowSession(){
    
    $(".b-search-catalog .b-results .m-tbl td:visible:contains('View Sessions')").prev('td').parent('tr').addClass('m-open-child');
    $('.b-search-catalog .b-results .m-open-child').hide();
    
    $('input#sessions').click(function(a){
        if (a.target.checked)
        {
            $('input#sessions').attr('checked', true);
            $('.m-open-child').show();
            $('.m-open-child td.m-minus').removeClass('m-minus');
        }
        else
        {
            $('input#sessions').attr('checked', false);
            $('.m-open-child').hide();
            $('.m-open-child').next('tr.m-hide').hide();
        };
    })
} 


/* Toggler */
function Toggler()
{
	$('.b-tab-bodies .b-tab-body').hide();	
	$('.b-tab-bodies .b-tab-body:first-child').show();
	$('.b-tabs .b-tab:first-child').addClass('m-active');
	
	var tabs = $('.b-tabs .b-tab');
	var tabBodies = $('.b-tab-bodies .b-tab-body');
	var activeTabIndex = 0;

	tabs.click(function(){
		if( tabs.index(this) != activeTabIndex )
		{
			tabs.removeClass('m-active');
			
			$(this).addClass('m-active');	
			tabBodies.hide();
			
			if ($.browser.msie) {						
				tabBodies.eq( tabs.index(this) ).show();
			}
			else {
				tabBodies.eq( tabs.index(this) ).fadeIn();
			}
						
			activeTabIndex = tabs.index(this);
		};
	});
}


/* Hide/Show toggler */
function HideShowToggler()
{
	jQuery('.m-hide').hide();
	jQuery('.m-close').click( function() {
		jQuery(this).parent('tr').next('tr.m-hide').toggle();
		jQuery(this).toggleClass('m-open');
	});
	
	jQuery('.m-plus').click( function() {
		jQuery(this).parent('tr').next('tr.m-hide').toggle();
		jQuery(this).toggleClass('m-minus');
	});
	
}

/* Hide/Show toggler */
function DevPlanToggler()
{
	jQuery('.b-dev-plan .m-nested, .b-dev-plan .b-additional-tbls').hide();

	jQuery('.b-dev-plan .m-descr-tbl .b-toggler-title:last, .b-dev-plan .b-blue-box:last .b-title').toggleClass('m-open');
	jQuery('.b-dev-plan .m-nested:last, .b-dev-plan .b-additional-tbls:last').toggle();
	
	jQuery('.b-dev-plan .m-descr-tbl .b-toggler-title').click( function() {
		jQuery(this).closest('.m-descr-tbl').next('.m-nested').toggle();
		jQuery(this).toggleClass('m-open');
	});
	
	jQuery('.b-dev-plan .b-blue-box .b-toggler').click( function() {
		jQuery(this).closest('.b-blue-box').next('.b-additional-tbls').toggle();
		jQuery(this).find('.b-title').toggleClass('m-open');
	});	
	
}
