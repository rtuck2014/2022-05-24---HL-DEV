var SysAdminProfileId = '00ei00000016T4BAAU';
var CAOProfileId = '00ei0000001XKVVAA4';
function ClosePopup(){
       	$j("[title$=Close]").trigger('click');
}
$j = jQuery.noConflict();
$j(document).ready(function () {
	DocumentReady();
	setTimeout(function() {
        $j(window).one("scroll",function() { document.body.scrollTop = document.documentElement.scrollTop = 0; });
    }, 15);
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
$j("[id$=Pitch00], [id$=InternationalAngle], [id$=AsiaAngle], [id$=RelatedParty], [id$=RestrictedList], [id$=ConflictsCheckDate], [id$=Fairness], [id$=Products], [id$=Geography], [id$=SeniorManagement], [id$=CoverageOfficers], [id$=MajoritySale], [id$=MetwithCompany], [id$=MetwithBOD], [id$=MetwithKey], [id$=CoverRelatedFinSpon], [id$=NoFinancials], [id$=FinAudit01], [id$=UserProfileId], [id$=Exist], [id$=UseofProceeds], [id$=TAS00], [id$=SC00], [id$=TECH00], [id$=Conflicts00], [id$=Conflicts2a], [id$=Conflicts3a], [id$=Conflicts35a], [id$=Conflicts4a], [id$=Conflicts5a], [id$=legal00]").change(function() {ToggleReliantFields();});
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

$j("[title$=Content]").load(function () {
          $j(this).css('height',this.contentWindow.document.body.scrollHeight + 'px');
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

$j("[id$=newFinancials]").click(function() { 
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=opportunityFinancialsModify]").html() + "?oa=" + $j("[id$=opportunityApprovalId]").html() + "&subject=" + $j("[id$=subjectId]").html() + "&currencyISO=" + $j("[id$=currencyISO]").html();
    $j("<div></div>")
    	   .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
           .dialog({
                autoOpen: false,
                title: 'Add Financials',
                resizable: true,
                width: 500,
                height: 650,
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
                close: function() {$j("[id$=RefreshFinancials]").trigger('click');}
        }).dialog('open');
        return false;
});
$j("[id$=editFinancials]").click(function() { 
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=opportunityFinancialsModify]").html() + "?id=" + $j(this).siblings()[0].innerText;
    $j('<div></div>')
           .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
           .dialog({
                autoOpen: false,
                title: 'Edit Financials',
                resizable: true,
                width: 500,
                height: 650,
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
                close: function() {$j("[id$=RefreshFinancials]").trigger('click');}
        }).dialog('open');
        return false;
});

//Show Required Indicators
$j('.required').wrap('<div class="requiredInput">').before('<div class="requiredBlock"></div>');

}

function ToggleReliantFields(){
		if($j("[id$=Pitch00]").val() === 'Yes'){
		$j("[id$=Pitch01]").show();
		$j("[id$=Pitch02]").show();
	}
	else{
		$j("[id$=Pitch01]").hide();
		$j("[id$=Pitch02]").hide();
		$j("[id$=Pitch02]").val('');			
	}	
	
	if($j("[id$=MajoritySale]").val() === 'Yes'){
		$j("[id$=MajoritySale01]").show();
		$j("[id$=MajoritySale02]").show();
	}
	else{
		$j("[id$=MajoritySale01]").hide();
		$j("[id$=MajoritySale02]").hide();
	}
	
	if($j("[id$=MetwithCompany]").val() === 'Yes'){
		$j("[id$=MetwithCompany01]").show();
		$j("[id$=MetwithCompany02]").show();
		}
	else{
		$j("[id$=MetwithCompany01]").hide();
		$j("[id$=MetwithCompany02]").hide();
		$j("[id$=MetwithCompany02]").val('');
	}	
	
	if($j("[id$=MetwithBOD]").val() === 'Yes'){
		$j("[id$=MetwithBOD01]").show();
		$j("[id$=MetwithBOD02]").show();
		}
	else{
		$j("[id$=MetwithBOD01]").hide();
		$j("[id$=MetwithBOD02]").hide();		
		$j("[id$=MetwithBOD02]").val('');
	}
	
	if($j("[id$=MetwithKey]").val() === 'Yes'){
		$j("[id$=MetwithKey01]").show();
		$j("[id$=MetwithKey02]").show();
		}
	else{
		$j("[id$=MetwithKey01]").hide();
		$j("[id$=MetwithKey02]").hide();		
		$j("[id$=MetwithKey02]").val('');
	}
	
	if($j("[id$=CoverRelatedFinSpon]").val() === 'Yes'){
		$j("[id$=CoverRelatedFinSpon01]").show();
		$j("[id$=CoverRelatedFinSpon02]").show();
		}
	else{
		$j("[id$=CoverRelatedFinSpon01]").hide();
		$j("[id$=CoverRelatedFinSpon02]").hide();
		$j("[id$=CoverRelatedFinSpon02]").val('');		
	}		
	
	if($j("[id$=TAS00]").val() === 'Yes'){
		$j("[id$=TAS01]").show();
		$j("[id$=TAS02]").show();
		$j("[id$=TAS02_lkwgt]").show();
	}
	else{
		$j("[id$=TAS01]").hide();
		$j("[id$=TAS02]").hide();
		$j("[id$=TAS02]").val('');	
		$j("[id$=TAS02_lkwgt]").hide();
	}
	
	if($j("[id$=SC00]").val() === 'Yes'){
		$j("[id$=SC01]").show();
		$j("[id$=SC02]").show();
		$j("[id$=SC02_lkwgt]").show();
	}
	else{
		$j("[id$=SC01]").hide();
		$j("[id$=SC02]").hide();
		$j("[id$=SC02]").val('');	
		$j("[id$=SC02_lkwgt]").hide();
	}

	if($j("[id$=TECH00]").val() === 'Yes'){
		$j("[id$=TECH01]").show();
		$j("[id$=TECH02]").show();
		$j("[id$=TECH02_lkwgt]").show();
	}
	else{
		$j("[id$=TECH01]").hide();
		$j("[id$=TECH02]").hide();
		$j("[id$=TECH02]").val('');	
		$j("[id$=TECH02_lkwgt]").hide();
	}	
	
	if($j("[id$=InternationalAngle]").val() === 'Yes'){
		$j("[id$=InternationalAngle01]").show();
		$j("[id$=InternationalAngle02]").show();
	}
	else{
		$j("[id$=InternationalAngle01]").hide();
		$j("[id$=InternationalAngle02]").hide();
		$j("[id$=InternationalAngle02]").val('');			
	}
	
	if($j("[id$=AsiaAngle]").val() === 'Yes'){
		$j("[id$=AsiaAngle01]").show();
		$j("[id$=AsiaAngle02]").show();
	}
	else{
		$j("[id$=AsiaAngle01]").hide();
		$j("[id$=AsiaAngle02]").hide();
		$j("[id$=AsiaAngle02]").val('');			
	}
	
	if($j("[id$=RestrictedList]").val() === 'Yes'){
		$j("[id$=RestrictedListYES]").removeAttr("disabled");	
	}
	else{		
		$j("[id$=RestrictedListYES]").attr("disabled", "disabled");
		$j("[id$=RestrictedListYES]").val('');
	}
	

//Conflicts Check Section
	if($j("[id$=Conflicts2a]").val() === 'Yes'){
		$j("[id$=Conflicts2b00]").show();
		$j("[id$=Conflicts2b01]").show();
		}
	else{
		$j("[id$=Conflicts2b00]").hide();
		$j("[id$=Conflicts2b01]").hide();
		$j("[id$=Conflicts2b01]").val('');
	}
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
	
	if($j("[id$=Conflicts2a]").val() === 'Yes' || $j("[id$=Conflicts3a]").val() === 'Yes' || $j("[id$=Conflicts35a]").val() === 'Yes' || $j("[id$=Conflicts4a]").val() === 'Yes' || $j("[id$=Conflicts5a]").val() === 'Yes'){
		$j("[id$=legal00]").show();
	}
	else{
		$j("[id$=legal00]").hide();
	}

	if($j("[id$=Fairness").val() === 'Yes'){
		$j("[id$=PublicDisclose]").removeAttr("disabled");
		$j("[id$=ShareholderVote]").removeAttr("disabled");
		$j("[id$=ProposalFeeRange]").removeAttr("disabled");
		$j("[id$=FeeInclusion]").removeAttr("disabled");
		$j("[id$=StaffNotes]").removeAttr("disabled");
		$j("[id$=Opine1]").removeAttr("disabled");
		$j("[id$=Opine2]").removeAttr("disabled");
		$j("[id$=Opine3]").removeAttr("disabled");
		$j("[id$=Opine4]").removeAttr("disabled");
		$j("[id$=Opine5]").removeAttr("disabled");
		$j("[id$=OpineNOT]").removeAttr("disabled");		
		$j("[id$=Opine6]").removeAttr("disabled");
		$j("[id$=OtherForms]").removeAttr("disabled");
		$j("[id$=RelatedParty]").removeAttr("disabled");		
	}
	else{
		$j("[id$=PublicDisclose]").attr("disabled", "disabled");
		$j("[id$=ShareholderVote]").attr("disabled", "disabled");
		$j("[id$=ProposalFeeRange]").attr("disabled", "disabled");
		$j("[id$=FeeInclusion]").attr("disabled", "disabled");
		$j("[id$=StaffNotes]").attr("disabled", "disabled");
		$j("[id$=Opine1]").attr("disabled", "disabled");	
		$j("[id$=Opine2]").attr("disabled", "disabled");
		$j("[id$=Opine3]").attr("disabled", "disabled");
		$j("[id$=Opine4]").attr("disabled", "disabled");
		$j("[id$=Opine5]").attr("disabled", "disabled");
		$j("[id$=OpineNOT]").attr("disabled", "disabled");
		$j("[id$=Opine6]").attr("disabled", "disabled");
		$j("[id$=OtherForms]").attr("disabled", "disabled");
		$j("[id$=RelatedParty]").attr("disabled", "disabled");	
		
		$j("[id$=PublicDisclose]").val("");
		$j("[id$=ShareholderVote]").val("");
		$j("[id$=ProposalFeeRange]").val("");
		$j("[id$=FeeInclusion]").val("");
		$j("[id$=StaffNotes]").val("");				
		$j("[id$=Opine1]").removeAttr("checked");	
		$j("[id$=Opine2]").removeAttr("checked");
		$j("[id$=Opine3]").removeAttr("checked");
		$j("[id$=Opine4]").removeAttr("checked");
		$j("[id$=Opine5]").removeAttr("checked");
		$j("[id$=OpineNOT]").removeAttr("checked");	
		$j("[id$=Opine6]").removeAttr("checked");
		$j("[id$=OtherForms]").val("");
		$j("[id$=RelatedParty]").val("");			
	}
	
	if($j("[id$=RelatedParty]").val() === 'Yes'){
		$j("[id$=RelatedParty01]").show();
		$j("[id$=RelatedParty02]").show();
	}
	else{
		$j("[id$=RelatedParty01]").hide();
		$j("[id$=RelatedParty02]").hide();
		$j("[id$=RelatedParty02]").val('');			
	}
	
	if($j("[id$=Products]").is(":checked")){
		$j("[id$=Products01]").removeAttr('disabled');
	}
		else{
		$j("[id$=Products01]").attr("disabled", "disabled");
		$j("[id$=Products01]").val('');		
	}
	
	if($j("[id$=Geography]").is(":checked")){
		$j("[id$=Geography01]").removeAttr('disabled');
	}
		else{
		$j("[id$=Geography01]").attr("disabled", "disabled");
		$j("[id$=Geography01]").val('');		
	}
	
	if($j("[id$=SeniorManagement]").is(":checked")){
		$j("[id$=SeniorManagement01]").removeAttr('disabled');
	}
		else{
		$j("[id$=SeniorManagement01]").attr("disabled", "disabled");
		$j("[id$=SeniorManagement01]").val('');			
	}
	
	if($j("[id$=CoverageOfficers]").is(":checked")){
		$j("[id$=CoverageOfficers01]").removeAttr('disabled');
	}
		else{
		$j("[id$=CoverageOfficers01]").attr("disabled", "disabled");
		$j("[id$=CoverageOfficers01]").val('');				
	}
  if($j("[id$=NoFinancials]").is(":checked")){
    $j("[id$=NoFinancials01]").show();
    $j("[id$=NoFinancials02]").show();
	$j("[id$=FinAudit00]").hide();
	$j("[id$=FinAudit01]").hide();
	$j("[id$=FinAuditExplain00]").hide();
	$j("[id$=FinAuditExplain01]").hide();		
	$j("[id$=FinAuditExplain00]").val('');	
	$j("[id$=FinAuditExplain01]").val('');	  
  }
  else{
    $j("[id$=NoFinancials01]").hide();
    $j("[id$=NoFinancials02]").hide();
    $j("[id$=NoFinancials02]").val('');
	$j("[id$=FinAudit00]").show();
	$j("[id$=FinAudit01]").show();		
	$j("[id$=FinAuditExplain00]").show();
	$j("[id$=FinAuditExplain01]").show();	  
  }
  
  if($j("[id$=FinAudit01]").val()==='No' && !($j("[id$=NoFinancials]").is(":checked"))){
    $j("[id$=FinAuditExplain00]").show();
    $j("[id$=FinAuditExplain01]").show();
  }
  else{
    $j("[id$=FinAuditExplain00]").hide();
    $j("[id$=FinAuditExplain01]").hide();
    $j("[id$=FinAuditExplain01]").val('');
  }
  
 
  //Disable form when ready for review
  if($j("#isLocked").val() === 'true'){
       $j("input[type='text'],select,textarea").prop("disabled", true);
	   $j("[id$=phSearchInput]").prop("disabled",false);
	   $j("input[type='checkbox']").bind("click", false);
       $j("[id$=toggleTabs]").unbind("click", false);
	   if($j("[id$=userProfileId]").html().trim() == SysAdminProfileId || $j("[id$=userProfileId]").html().trim() == CAOProfileId){
		$j("[id$=reviewGrade]").prop("disabled",false);
		$j("[id$=reviewNotes]").prop("disabled",false);
		$j("[id$=dateSubmit]").prop("disabled",false);
		$j("[id$=reasonWonLost]").prop("disabled",false);
		$j("[id$=feeDiff]").prop("disabled",false);
		$j("[id$=estMinFee]").prop("disabled",false);
		$j("[id$=estHighFee]").prop("disabled",false);
	   }
  }

  //Hide Review Tab unless SysAdmin or CAO
  if($j("[id$=userProfileId]").html().trim() != SysAdminProfileId && $j("[id$=userProfileId]").html().trim() != CAOProfileId){
    $j("[href='#tabs-7']").closest('li').hide();
    $j("#tabs-7").hide();
  }

//Hide Form Type and Submit to Legal
  if($j("[id$=userProfileId]").html().trim() != SysAdminProfileId){
		$j("[id$=formType]").attr("disabled", "disabled");
		//$j("[id$=submittedToLegal]").attr("disabled", "disabled");
  }
  
//Existing / Repeat Client
  	if($j("[id$=Exist]").val() === 'Yes'){
		$j("[id$=Exist01]").show();
		$j("[id$=Exist02]").show();
	}
	else{
		$j("[id$=Exist01]").hide();
		$j("[id$=Exist02]").hide();
		$j("[id$=Exist02]").val('');			
	}
 /*
  	if($j("[id$=UseofProceeds]").index('Other') >=0){
		$j("[id$=UseofProceeds01]").show();
		$j("[id$=UseofProceeds02]").show();
	}
	else{
		$j("[id$=UseofProceeds01]").hide();
		$j("[id$=UseofProceeds01]").hide();
		$j("[id$=UseofProceeds02]").val('');			
	}  */
}
function SubmitForReview(){
    $j("[id$=submit00]").trigger('click');
}
function SubmitToAdmin(){
    $j("[id$=submit01]").trigger('click');
}
