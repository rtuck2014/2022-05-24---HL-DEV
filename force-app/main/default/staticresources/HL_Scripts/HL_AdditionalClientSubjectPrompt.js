$j = jQuery.noConflict();
$j(document).ready(function () {
   DocumentReady();
});
function DocumentReady(){
     //Remove Enter Functionality
     $j('input, select').keypress(function(e){
        if ( e.which == 13 ) // Enter key = keycode 13
            return false;
     });
     $j("[id$=newClient]").click(function() { 
        $j(".ui-dialog-content").dialog("destroy"); 
        var iframe_url = $j("[id$=lookupAccountUrl]").html() + '?action=7&entity=' + $j("[id$=entityId]").html();
        $j('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
        .dialog({
            autoOpen: false,
            title: 'Add Additional Client(s)',
            resizable: true,
            width: 700,
            height: 580,
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
            close: function() {$j("[id$=additionalClientsRefresh]").trigger('click');}
        }).dialog('open');
        return false;
    });
    
    $j("[id$=newSubject]").click(function() { 
        $j(".ui-dialog-content").dialog("destroy"); 
        var iframe_url = $j("[id$=lookupAccountUrl]").html() + '?action=8&entity=' + $j("[id$=entityId]").html();
        $j('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
        .dialog({
            autoOpen: false,
            title: 'Add Additional Subject(s)',
            resizable: true,
            width: 700,
            height: 580,
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
            close: function() {$j("[id$=additionalSubjectsRefresh]").trigger('click');}
        }).dialog('open');
        return false;
    });
}

function CheckForNoResponsePrompt(promptType){
    var jobCode = $j("[id$=jobType]").html().trim();
    var clientPromptJobCodes = ["Creditor Advisors", "Equity Advisors", "Illiquid Financial Assets", "Lit - Exp Cons-Pre-Complt", "Lit - Exp Cons-Mediation", "Lit - Exp Cons-Arbitrat'n", "Lit - Exp Cons-Litigation", "Lit - Exp Wit-Pre-Complnt", "Lit - Exp Wit-Mediation", "Lit - Exp Wit-Arbitration", "Lit - Exp Wit-Litigation", "Lit - Exp Cons-Bankruptcy", "Lit - Exp Wit-Bankruptcy", "Lit - Appointed Arbitrator/Mediator"];
    var subjectPromptJobCodes = ["DM&amp;A Buyside", "Buyside", "Activist Advisory"];
    var noClientPrompt = "If we are being retained by a committee of creditors, the members of the committee generally should be listed as clients.  Have you confirmed that there is only one client?";
    var noSubjectPrompt = "If there are multiple targets, remember to add each target as a subject.  Have you confirmed that there is only one target?";
   
    if(promptType=== 'client')
        return clientPromptJobCodes.indexOf(jobCode) > -1 ? confirm(noClientPrompt) : true;
    else
        return subjectPromptJobCodes.indexOf(jobCode) > -1 ? confirm(noSubjectPrompt) : true;
}
    
function Validate(){
    if($j("[id$=hasAdverseClients]").val() == '' && $j("[id$=noAdditionalClientsIndicated]").length > 0)
    {
        alert('Please answer the adverse client question');
        return false;
    }
    return true;
}

function ClosePopup(){
    var internalTeamPrompt = $j("[id$=internalTeamPrompt]").html().indexOf('true') >= 0;
   
    if(internalTeamPrompt){
        $j.blockUI({ css: { 
            border: 'none', 
            padding: '15px', 
            backgroundColor: '#000', 
            '-webkit-border-radius': '10px', 
            '-moz-border-radius': '10px', 
            opacity: .5, 
            color: '#fff' 
        }, message: 'Just a Moment, Please Add Internal Team Members...' });  
        window.parent.location.href = $j("[id$=internalTeamUrl]").html() + '?id=' + $j("[id$=entityId]").html() + '&type=Opportunity__c';
    }
    else{
     window.parent.$j("[title$=Close]").filter("button").trigger('click');
    }
}