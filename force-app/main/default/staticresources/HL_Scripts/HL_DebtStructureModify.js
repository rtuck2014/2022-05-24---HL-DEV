$(document).ready(function () {
   DocumentReady();
});
function DocumentReady(){
    $(".ui-dialog-content").dialog("destroy");
    $("[id$=newLender]").click(function() {
        $(".ui-dialog-content").dialog("destroy");
        var iframe_url = $("[id$=lookupAccountUrl").html() + '?action=5&entity=' + $("[id$=engagementId").html()  + '&secondary=' + $("[id$=recordId]").html();
        $('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
        .dialog({
            autoOpen: false,
            title: 'Add Key Creditor',
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
            close: function() {$("[id$=lendersRefresh]").trigger('click');}
        }).dialog('open');
        return false;
    });
    $("[id$=editLender]").click(function() {
        $(".ui-dialog-content").dialog("destroy");
        var iframe_url = $("[id$=engagementClientSubjectEditUrl]").html() + "?id=" + $(this).siblings()[1].innerText;
        $('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
        .dialog({
            autoOpen: false,
            title: 'Edit Key Creditor',
            resizable: true,
            width: 580,
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
            close: function() {$("[id$=lendersRefresh]").trigger('click');}
        }).dialog('open');
        return false;
    });
    $("[id$=deleteLender]").click(function(){
        if(confirmDelete()){
            client.del('Engagement_Client_Subject__c', $(this).siblings()[1].innerText, deleteLenderCB);
        }
    });
}

function deleteLenderCB(results){
    $("[id$=lendersRefresh]").trigger('click');
}
