var j$ = jQuery.noConflict();
j$(document).ready(function() {	
 	DocumentReady();
});
function DocumentReady() {
 //Remove Enter Functionality
 $j('input, select').keypress(function(e){
    if ( e.which == 13 ) // Enter key = keycode 13
			return false;
 });
 j$(":checkbox").change(function(){j$(this).closest('td').toggleClass('highlight');});
}