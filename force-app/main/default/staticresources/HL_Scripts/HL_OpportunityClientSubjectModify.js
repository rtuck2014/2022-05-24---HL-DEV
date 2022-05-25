$j = jQuery.noConflict();
$j(document).ready(function () {
   DocumentReady();
});
function DocumentReady(){
     $j(".ui-dialog-content").dialog("destroy");
	 $j("[id$=newPEFirm]").click(function() { 
        $j(".ui-dialog-content").dialog("destroy");
        var iframe_url = $j("[id$=lookupAccountUrl]").html() + '?action=4&entity=' + $j("[id$=opportunityId]").html() + '&secondary=' + $j("[id$=recordId]").html();
        $j('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
        .dialog({
            autoOpen: false,
            title: 'Add PE Firm',
            resizable: true,
            width: 700,
            height: 680,
            autoResize: false,
            modal: true,
            draggable: true,
            show: {
                effect: "fade",
                duration: 500
            },
            hide: {
                effect: "fade",
                duration: 500
            },
            close: function() {$j("[id$=peFirmsRefresh]").trigger('click');}
        }).dialog('open');
        return false;
    });
    
    $j("[id$=editPEFirm]").click(function() { 
        $j(".ui-dialog-content").dialog("destroy");
        var iframe_url = $j("[id$=opportunityClientSubjectEditUrl]").html() + "?id=" + $j(this).siblings()[0].innerText;
        $j('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
        .dialog({
            autoOpen: false,
            title: 'Edit PE Firm',
            resizable: true,
            width: 500,
            height: 300,
            autoResize: false,
            modal: true,
            draggable: true,
            show: {
                effect: "fade",
                duration: 500
            },
            hide: {
                effect: "fade",
                duration: 500
            },
            close: function() {$j("[id$=peFirmsRefresh]").trigger('click');}
        }).dialog('open');
        return false;
    });
    
    $j("[id$=btnCancel]").click(function() {
    	ClosePopup();
    });
}
function ClosePopup(){
    window.parent.$j("[title$=Close]").trigger('click');
}