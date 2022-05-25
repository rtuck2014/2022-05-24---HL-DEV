

function InitLightbox()
{ 

	var overlay;
	var lightbox;
	
	$(document).ready(function(){
	
		overlay = $('.b-overlay');
		lightbox = $('.b-lightbox');
		
		
	});
	

}

function Lightbox() 
{
	lightbox.fadeIn('fast');
	overlay
		.height( $(document).height() )
		.css('opacity','0.6')
		.fadeIn('fast');
	return false;

}


function Closelightbox() 
{
	lightbox.fadeOut('fast');			
	overlay.fadeOut('fast');

}