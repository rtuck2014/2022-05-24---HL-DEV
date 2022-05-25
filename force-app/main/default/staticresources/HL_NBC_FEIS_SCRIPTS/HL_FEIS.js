var SysAdminProfileId = 'System Administrator';
var CAOProfileId = 'CAO';
$j = jQuery.noConflict();
var alert01 = true;
var alert02 = true;
var alert03 = true;
$j(document).ready(function () {
  DocumentReady();
  	setTimeout(function() {
        $j(window).one("scroll",function() { document.body.scrollTop = document.documentElement.scrollTop = 0; });
    }, 15);
    SetupAlerts();
});  
function DocumentReady(){
var hideDelay = 300;
var tipID;
var tipType;
var hideTimer = null;
  // One instance that's reused to show info for the current tip
var container = $j('<div id="tipPopupContainer">'
          + '<table width="" border="0" cellspacing="0" cellpadding="0" align="center" class="tipPopupPopup">'
          + '<tr>'
          + '   <td class="corner topLeft"></td>'
          + '   <td class="top"></td>'
          + '   <td class="corner topRight"></td>'
          + '</tr>'
          + '<tr>'
          + '   <td class="left">&nbsp;</td>'
          + '   <td><div id="tipPopupContent"></div></td>'
          + '   <td class="right">&nbsp;</td>'
          + '</tr>'
          + '<tr>'
          + '   <td class="corner bottomLeft">&nbsp;</td>'
          + '   <td class="bottom">&nbsp;</td>'
          + '   <td class="corner bottomRight"></td>'
          + '</tr>'
          + '</table>'
          + '</div>');
$j('body').append(container);
ToggleReliantFields();
$j("[id$=isPubliclyDisclosed], [id$=fairnessInAddition], [id$=shareholderVote], [id$=affiliatedParties], [id$=TransactionType], [id$=LegalStructure], [id$=Other], [id$=isPubliclyDisclosed_01], [id$=Conflicts3a], [id$=Conflicts35a], [id$=Conflicts4a], [id$=Conflicts5a]").change(function() {ToggleReliantFields();});
 //We need to retrigger the popup when these fields change
$j(".lrc, .lrc02").change(function() {alert03 = true;});
$j('.tipPopupTrigger').live('mouseover', function () {
              if (hideTimer)
                  clearTimeout(hideTimer);
              var pos = $j(this).offset();
              var width = $j(this).width();
              container.css({

                  left: (pos.left > 400) ? (pos.left - 690) + 'px' : (pos.left + width) + 'px',
                  top: pos.top - 5 + 'px'
              });
              $j('#tipPopupContent').html('&nbsp;');
              $j('#tipPopupContent').html($j(this).siblings().html());
              container.css('display', 'block');
});
$j('.tipPopupTrigger').live('mouseout', function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);

});

// Allow mouse over of details without hiding details
$j('#tipPopupContainer').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#tipPopupContainer').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});
$j(".ui-dialog-content").dialog("destroy");
//Remove Enter Functionality
$j('input, select').keypress(function(e){
    if ( e.which == 13 ) // Enter key = keycode 13
        return false;
});
$j("input.numeric-short, input.numeric-medium").keydown(function (event) {maskKeys(event);});
if($j("#tabsList").is(":visible"))
{
  if($j("#toggleTabs").is(":checked"))
    {
        if(!($j("#tabsList").is(":visible")))
      $j("#tabsList").toggle();
        $j("#tabs").tabs();
    }
    else
    {
        if($j("#tabsList").is(":visible"))
            $j("#tabsList").toggle();
        //$j("#tabs").tabs("destroy");
    }
}
$j("#toggleTabs").click(function() {
    $j("#tabsList").toggle();
    if($j("#toggleTabs").is(":checked"))
    {
        if(!($j("#tabsList").is(":visible")))
      $j("#tabsList").toggle();
        $j("#tabs").tabs();
    }
    else
    {
        if($j("#tabsList").is(":visible"))
            $j("#tabsList").toggle();
    $j("#tabs").tabs("destroy");
    }
    ToggleReliantFields();
});
$j("[id$=newClientSubject]").click(function() { 
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("#opportunityClientSubjectModifyUrl").val() + "?action=1&opp=" + $j("#opportunityId").val();
    $j('<div></div>')
           .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
           .dialog({
                autoOpen: false,
                title: 'Add Target/Subject',
                resizable: true,
                width: 1100,
                height: 700,
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
                close: function() {$j("[id$=clientsSubjectsRefresh]").trigger('click');}
        }).dialog('open');
        return false;
});
$j("[id$=editClientSubject]").click(function() { 
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("#opportunityClientSubjectModifyUrl").val() + "?action=1&opp=" + $j("#opportunityId").val() + '&id=' + $j(this).siblings()[0].innerText;
    $j('<div></div>')
           .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
           .dialog({
                autoOpen: false,
                title: 'Edit Target/Subject',
                resizable: true,
                width: 1100,
                height: 700,
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
                close: function() {$j("[id$=clientsSubjectsRefresh]").trigger('click');}
        }).dialog('open');
        return false;
});
$j("[id$=newCounterparty]").click(function() { 
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("#opportunityClientSubjectModifyUrl").val() + "?action=2&opp=" + $j("#opportunityId").val();
    $j('<div></div>')
           .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
           .dialog({
                autoOpen: false,
                title: 'Add Counterparty',
                resizable: true,
                width: 1100,
                height: 700,
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
                close: function() {$j("[id$=counterpartiesRefresh]").trigger('click');}
        }).dialog('open');
        return false;
});
$j("[id$=editCounterparty]").click(function() { 
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("#opportunityClientSubjectModifyUrl").val() + "?action=1&opp=" +  $j("#opportunityId").val() + '&id=' + $j(this).siblings()[0].innerText;
    $j('<div></div>')
           .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
           .dialog({
                autoOpen: false,
                title: 'Edit Counterparty',
                resizable: true,
                width: 1100,
                height: 700,
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
                close: function() {$j("[id$=counterpartiesRefresh]").trigger('click');}
        }).dialog('open');
        return false;
});

$j("[title$=Content]").load(function () {
          $j(this).css('height',this.contentWindow.document.body.scrollHeight + 'px');
  });

//Show Required Indicators
$j('.required').wrap('<div class="requiredInput">').before('<div class="requiredBlock"></div>');
}

function SetupAlerts(){
   $j("[id$=descriptionOfTransaction]").focus(function() {if(alert01) {alert01 = false; alert('If the opinion will cover shareholders, indicate whether the opinion will cover all or a subset or group of shareholders. If the opinion covers a group or subset of shareholders, describe the group or subset and the consideration to be received by it and other shareholders in the transaction.');}}); 
     $j("[id$=Other02]").focus(function() {if(alert02) {alert02 = false; alert(' Any other wording of the opinion language must be reviewed by the Legal Dept prior to entering into the engagement letter.');}});
     
    //Questions 1-8
    //'Please note that outside counsel must be retained, preferably at the engagement letter stage. Outside counsel will assist the Firm among other matters, in identifying transaction issues and reviewing all drafts for this assignment, the engagement letter, board package and opinion before they are delivered to the client. Outside counsel must be chosen from the fairness opinion outside counsel list (see the Intranet).'
    //Question 1
    // Generally, the Firm does not permit the disclosure of, or any reference to, our opinions to security holders except to the extent such disclosure or reference is required by the federal securities or certain other applicable laws.
    //Question 3-8
    //In addition, the Legal Dept must be consulted before proposing or accepting, or providing a form of engagement letter with respect to, an engagement. Merely sending this form to the FEC or the Legal Dept is not sufficient to satisfy this consultation requirement.
     $j("[id$=btnSave], [id$=btnReturn]").click(function() {
         if(alert03){  
            var alert03Msg = '';
            var addedLastMsg = false;
          alert03 = false;
            $j(".lrc, .lrc02").each(function() {
                if($j(this).val() === 'Yes' || $j(this).val() === 'Maybe')
                    alert03Msg = 'Please note that outside counsel must be retained, preferably at the engagement letter stage. Outside counsel will assist the Firm among other matters, in identifying transaction issues and reviewing all drafts of the engagement letter, board package and opinion before they are delivered to the client. Outside counsel must be chosen from the fairness opinion outside counsel list (which can be reviewed on the Intranet).';
            });
            if($j("[id$=isPubliclyDisclosed]").val() === 'Yes' || $j("[id$=isPubliclyDisclosed]").val() === 'Maybe')
                alert03Msg += '\n\nGenerally, the Firm does not permit the disclosure of, or any reference to, our opinions to security holders except to the extent such disclosure or reference is required by the federal securities or certain other applicable laws.';
          $j(".lrc02").each(function() {
               if(($j(this).val() === 'Yes' || $j(this).val() === 'Maybe') && !addedLastMsg){
                   alert03Msg += '\n\nIn addition, the Legal Department must be consulted before proposing or accepting, or providing a form of engagement letter with respect to, an engagement. Merely sending this form to the Fairness Engagement Committee or the Legal Department is not sufficient to satisfy this consultation requirement.';
                   addedLastMsg = true;
               }
            });
            
            if(alert03Msg != '')
                alert(alert03Msg);
         }
     });
        
}

function ToggleReliantFields(){
  if($j("[id$=TransactionType]").val() === 'Other'){
    $j("[id$=TransactionType01]").show();
    $j("[id$=TransactionType02]").show();
  }
  else{
    $j("[id$=TransactionType01]").hide();
    $j("[id$=TransactionType02]").hide();
    $j("[id$=TransactionType02]").val("");
  }
  
  if($j("[id$=LegalStructure]").val() === 'Other'){
    $j("[id$=LegalStructure01]").show();
    $j("[id$=LegalStructure02]").show();
  }
  else{
    $j("[id$=LegalStructure01]").hide();
    $j("[id$=LegalStructure02]").hide();
    $j("[id$=LegalStructure02]").val("");
  }
  
  
  if($j("[id$=isPubliclyDisclosed]").val() === 'Yes'){
    $j("[id$=isPubliclyDisclosed_01]").removeAttr('disabled');
    $j("[id$=isPubliclyDisclosed_02]").removeAttr('disabled');
  }
  else{
    $j("[id$=isPubliclyDisclosed_01]").attr("disabled", "disabled");
    $j("[id$=isPubliclyDisclosed_02]").attr("disabled", "disabled");
  }
  
  if($j("[id$=isPubliclyDisclosed_01]").val() === 'Other'){
		$j("[id$=otherFairnessDisclosureDocTXT]").show();
		$j("[id$=otherFairnessDisclosureDoc]").show();
		}
	else{
		$j("[id$=otherFairnessDisclosureDocTXT]").hide();
		$j("[id$=otherFairnessDisclosureDoc]").hide();
		$j("[id$=otherFairnessDisclosureDoc]").val('');
	}

  if($j("[id$=fairnessInAddition]").val() === 'Yes'){
    $j("[id$=fairnessInAddition_01]").removeAttr('disabled');
    $j("[id$=fairnessInAddition_02]").removeAttr('disabled');
  }
  else{
    $j("[id$=fairnessInAddition_01]").attr("disabled", "disabled");
    $j("[id$=fairnessInAddition_02]").attr("disabled", "disabled");
  }

  if($j("[id$=shareholderVote]").val() === 'Yes'){
    $j(".shareholderVote_01").removeAttr('disabled');
  }
  else{
    $j(".shareholderVote_01").attr("disabled", "disabled");
  }

  if($j("[id$=affiliatedParties]").val() === 'Yes'){
    $j("[id$=affiliatedParties_01]").removeAttr('disabled');
  }
  else{
    $j("[id$=affiliatedParties_01]").attr("disabled", "disabled");
  }
  
  if($j("[id$=Other]").is(":checked")){
    $j("[id$=Other01]").show();
    $j("[id$=Other02]").show();
  }
  else{
    $j("[id$=Other01]").hide();
    $j("[id$=Other02]").hide();
    $j("[id$=Other02]").val("");
  }
  //Relationship Questions
  if($j("[id$=Conflicts3a]").val() === 'Yes'){
		$j("[id$=Conflicts3b00]").show();
		$j("[id$=Conflicts3b01]").show();
		}
	else{
		$j("[id$=Conflicts3b00]").hide();
		$j("[id$=Conflicts3b01]").hide();
		$j("[id$=Conflicts3b01]").val('');
	}
	if($j("[id$=Conflicts35a]").val() === 'Yes'){
		$j("[id$=Conflicts35b00]").show();
		$j("[id$=Conflicts35b01]").show();
		}
	else{
		$j("[id$=Conflicts35b00]").hide();
		$j("[id$=Conflicts35b01]").hide();
		$j("[id$=Conflicts35b01]").val('');
	}
	if($j("[id$=Conflicts4a]").val() === 'Yes'){
		$j("[id$=Conflicts4b00]").show();
		$j("[id$=Conflicts4b01]").show();
		}
	else{
		$j("[id$=Conflicts4b00]").hide();
		$j("[id$=Conflicts4b01]").hide();
		$j("[id$=Conflicts4b01]").val('');
	}
	if($j("[id$=Conflicts5a]").val() === 'Yes'){
		$j("[id$=Conflicts5b00]").show();
		$j("[id$=Conflicts5b01]").show();
		}
	else{
		$j("[id$=Conflicts5b00]").hide();
		$j("[id$=Conflicts5b01]").hide();
		$j("[id$=Conflicts5b01]").val('');
	}
	
  //Disable form when ready for review
  if($j("#isLocked").val() === 'true'){
       $j("input[type='text'],select,textarea").prop("disabled", true);
	   $j("[id$=phSearchInput]").prop("disabled",false);
	   $j("input[type='checkbox']").bind("click", false);
       $j("[id$=toggleTabs]").unbind("click", false);
	   if($j("[id$=profileId]").val() == SysAdminProfileId || $j("[id$=profileId]").val() == CAOProfileId){
		   $j("[id$=reviewNotes]").prop("disabled",false);
	   }
  }
  //Hide Review Tab unless SysAdmin or CAO
  if($j("#profileId").val() != SysAdminProfileId && $j("#profileId").val() != CAOProfileId){
      $j("[href='#tabs-6']").closest('li').hide();
     $j("#tabs-6").hide();
  }
}

function SubmitForm(){
          $j("[id$=SubmitForm]").trigger('click');   
}