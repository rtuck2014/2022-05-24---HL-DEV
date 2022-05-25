         $j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
});
function DocumentReady() {
    $j.unblockUI;
    $j(".ui-dialog-content").dialog("destroy");
    //Remove Enter Functionality
    $j('input, select').keypress(function(e){
        if ( e.which == 13 ) // Enter key = keycode 13
                return false;
    });
    $j("[id$=btnSave]").click(function(){
            $j.blockUI();
            setTimeout($j.unblockUI, 1500);
        });
    ToggleFollowupDetails();
    $j("[id$=isFollowup]").change(function() {
        ToggleFollowupDetails();
    });
    $j("[id$=lblScheduleFollowup]").click(function() { popupFollowupDetails(); });
    $j(".date").datepicker({changeMonth: true, changeYear: true});
    $j(".followupDate").datepicker({changeMonth: true, changeYear: true, minDate: 0});

    $j("[id$=startTime]").change(function(){
        $j("[id$=endTime]").val($j(this).val());
    });

    $j("[id$=followupStartTime]").change(function(){
        $j("[id$=followupEndTime]").val($j(this).val());
    });
    $j(".primaryCheckbox").change(function() {
            $j(".primaryCheckbox").removeAttr('checked');
            $j(".removeEmployeeCheckbox").show();
            $j(this).attr('checked', true);
            $j(this).parent().parent().find(".removeEmployeeCheckbox").removeAttr('checked');
            $j(this).parent().parent().find(".removeEmployeeCheckbox").hide();
    });
    $j(".primaryContactCheckbox").change(function() {
            $j(".primaryContactCheckbox").removeAttr('checked');
            $j(".removeContactCheckbox").show();
            $j(this).attr('checked', true);
            $j(this).parent().parent().find(".removeContactCheckbox").removeAttr('checked');
			var NoExternalAccess = $j("#NoExternalAccess").val();
			if(NoExternalAccess === "false") {
				//NoExternalContactClass
            $j(this).parent().parent().find(".removeContactCheckbox").hide();
			}
    });
	$j(".NoExternalContactClass").change(function() {
           // if($(this).is(":checked")){
				if($j(this).prop("checked") == true){
            $j(".removeContactCheckbox").show();
				}
				else{
					HideRemovePrimary();
				}
          //  $j(this).parent().parent().find(".removeContactCheckbox").removeAttr('checked');
		   //}
			
    });
    HideRemovePrimary();
	if($j(".NoExternalContactClass").prop("checked") == true){
            $j(".removeContactCheckbox").show();
				}
    //Show Required Indicators
    $j('.required').wrap('<div class="requiredInput" style="display:inline-block">').before('<div class="requiredBlock"></div>');

    //Check for access to internal activity type
    ToggleInternalAccess();
}

function OnAttendeeAdded(){
    DocumentReady();
    $j("[id$=inputContactId]").focus();
	$j(".NoExternalContactClass").attr('checked', false);
}

function OnInternalAttendeeAdded(){
    DocumentReady();
    $j("[id$=inputInternalContactId]").focus();
}

function OnEmployeeAdded(){
    DocumentReady();
    $j("[id$=inputEmployeeId]").focus();
}

function OnCompanyAdded(){
    DocumentReady();
    $j("[id$=inputTxtId]").focus();
}

function OnOpportunityAdded(){
    DocumentReady();
    $j("[id$=inputOpportunityId]").focus();
}

function OnCampaignAdded(){
    DocumentReady();
    $j("[id$=inputcampaignId]").focus();
}

function ToggleInternalAccess(){
    var hasInternalAccess = $j("#hasInternalAccess").val();
    if(hasInternalAccess === "false" && $j("[id$=eventType]"))
	{
        $j("[id$=eventType] option[value='Internal']").attr('disabled','disabled');		
	}
	
	var HasMentorActivityAccess = $j("#HasMentorActivityAccess").val();
    if(HasMentorActivityAccess === "false" && $j("[id$=eventType]"))
	{        
		$j("[id$=eventType] option[value='Internal Mentor Meeting']").attr('disabled','disabled');
	}
}

function ToggleInternalAccessWithFocus(){
    ToggleInternalAccess();

    //Set focus back to the subject field
    $j("[id$=eventSubject]").focus();

    ToggleFollowupExternal();
}

function ToggleFollowupExternal(){
    //Disable Followup External
    if($j("[id$=eventType]") && $j("[id$=eventType]").val() === 'Internal'){
        $j("[id$=followupType] option[value='External']").attr('disabled','disabled');
        if($j("[id$=followupType]").val() === 'External')
            $j("[id$=followupType]").val('Internal');
    }
    else
         $j("[id$=followupType] option[value='External']").removeAttr('disabled','disabled');
}

function ToggleFollowupDetails(){
  if($j("[id$=isFollowup]").is(":checked"))
     $j(".followup").show();
  else
     $j(".followup").hide();

  ToggleFollowupExternal();
}
function PopupNewCompany(){
    if($j("[id$=eventType]").val() != '' && $j("[id$=eventSubject]").val() != '' && $j("[id$=eventDate]").val() != ''){
$j(".ui-dialog-content").dialog("destroy");
        var iframe_url = $j("[id$=newCompanyUrl]").html() + '?action=11&txt=inputTxtId';
        $j('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
        .dialog({
            autoOpen: false,
            title: 'Add New Company',
            resizable: true,
            width: 680,
            height: 600,
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
            close: function() {}
        }).dialog('open');
        return false;
    }
    return true;
}
function PopupNewContact(){
    if($j("[id$=eventType]").val() != '' && $j("[id$=eventSubject]").val() != '' && $j("[id$=eventDate]").val() != ''){
$j(".ui-dialog-content").dialog("destroy");
        var iframe_url = $j("[id$=newContactUrl]").html() + '?action=1';
        $j('<div></div>')
        .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
        .dialog({
            autoOpen: false,
            title: 'Add New Contact',
            resizable: true,
            width: 680,
            height: 600,
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
            close: function() {}
        }).dialog('open');
        return false;
    }

    return true;
}
function HideRemovePrimary(){
	    $j(".primaryCheckbox").each(function() {
        if($j(this).is(":checked")){
          $j(this).parent().parent().find(".removeEmployeeCheckbox").hide();
        }
    });
    $j(".primaryContactCheckbox").each(function() {
        if($j(this).is(":checked")){
          $j(this).parent().parent().find(".removeContactCheckbox").hide();
        }
    });
}
