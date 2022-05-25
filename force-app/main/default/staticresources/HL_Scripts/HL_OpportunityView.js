var SysAdminProfileId = 'System Administrator';
var CAOProfileId = 'CAO';
var StandardProfileId = 'Standard User Template';
var LegalProfileId = 'Legal User';
var ComplianceProfileId = 'Compliance User';
var originalWidth;
$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
    AdditionalClientSubjectPromptCheck();
}); 

function DocumentReady(){
	console.log('javascript');
      $j("[title$=HL_OpportunityInternalTeamView]").load(function () {
            $j("[title$=HL_OpportunityInternalTeamView]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
      });
   
      $j("[title='Submit for Approval']").hide();
	  console.log('onOIt'+$j("#onOIT").val());
	  console.log('onOIt'+($j("#profileId").val()));
	  console.log('onOIt'+($j("#profileId").val()));
        if($j("#onOIT").val() === 'false'){
       //Hide NBC/FEIS Form Button When User is not On OIT (OIT also includes SysAdmin and CAO)
       $j("[name$=nbc_form").hide();
       $j("[name$=nbc_form_c]").hide();  
       $j("[name$=nbc_form_cr]").hide();  
		}
		else{
		$j("input[name = 'nbc_form']").click(function() {
				$j("input[name = 'nbc_form']").prop('disabled', true);
				});
				
		}
      
      if($j("[id^=00Ni000000D8hWWj]").length > 0){
          if($j("[id^=00Ni000000D8hWWj]").html().indexOf('Fairness') < 0)
            $j("[name$='feis_and_fairness_forms']").hide();
      }
      else //form is locked
      {
          if($j("tr td.labelCol:contains('Job Type')").siblings()[0].innerHTML.indexOf('Fairness') < 0)
                $j("[name$='feis_and_fairness_forms']").hide();
      }
    
    if($j("#profileId").val() && $j("#profileId").val().indexOf(StandardProfileId) >= 0 )
      {
           $j("[name$='dnd_on_off']").hide(); 
           //If Engaged, Need to Hide Additional Options for Editing External Team, Comments and Counterparties
           if($j("#stage").val() === 'Engaged'){
                $j(".actionColumn").hide();
                $j("[name$=new_external_team]").hide();
                $j("[name$=new_comment]").hide();
                $j("[name$=new_counterparty]").hide();
                $j("[name$=additional_client]").hide();
                $j("[name$=additional_subject]").hide();
           }
      }
    
    if($j("#stage").val() === 'Engaged'){
        $j("[name$=conflicts_check]").hide();
        $j("[name$=manage_ms_team]").hide();
        $j("[name$=restricted_list]").hide();
        $j("[name$=counterparties]").hide();
    }

      if($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0)
      {
           $j("[name$='System Administration']").parent().hide();
           $j("[name$='System Administration']").parent().next().hide();
      }
      
      if($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0 && $j("#profileId").val().indexOf(CAOProfileId) < 0){
              $j("[name$='LOB - Administration']").parent().hide();
              $j("[name$='LOB - Administration']").parent().next().hide();
        $j("[name$='convert_to_engagement']").hide();       
      }

    //below commented out by ayu on tracy's orders 6/7
     // if($j("#onOIT").val() === 'false' && ($j("#profileId").val().indexOf(LegalProfileId) < 0 && $j("#profileId").val().indexOf(ComplianceProfileId) < 0)){
        //$j("[name$=restricted_list").hide(); //hide restricted list if not on OIT
    //Hide NBC/FEIS Form Button When User is not On OIT (OIT also includes SysAdmin and CAO)
        //$j("[name$=nbc_form").hide();
        //$j("[name$=feis_and_fairness_forms").hide();
      //} 
      
      if(
        $j("#jobType").val() ==='Activism Advisory' ||
        $j("#jobType").val() ==='Corporate Alliances' ||
        $j("#jobType").val() ==='Debt Advisory' ||
        $j("#jobType").val() ==='ESOP Corporate Finance' ||
        $j("#jobType").val() ==='Financing' ||
        $j("#jobType").val() ==='Partners' ||
        $j("#jobType").val() ==='Real Estate Brokerage' ||
        $j("#jobType").val() ==='Special Situations' ||
        $j("#jobType").val() ==='Strategic Alternatives Study' ||
        $j("#jobType").val() ==='Take Over Defense'
      ){
          $j("[name$=nbc_form]").hide();
          $j("[name$=nbc_form_c]").hide();
          $j("[name$=nbc_form_cr]").hide();
      }
      if(
        $j("#jobType").val() ==='Illiquid Financial Assets' ||
        $j("#jobType").val() ==='Buyside & Financing Advisory' 
      ){
        $j("[name$=nbc_form_c]").hide();      
      }
      else{
        $j("[name$=nbc_form_cr]").hide();
      }

      $j( window ).load(function() {
           var internalTeamReferenceId = $j('[name$="HL Internal Team"]').attr('id');
           $j(".listHoverLinks").prepend('<a class="linklet" href="#' + internalTeamReferenceId + '"><span id="internalTeamList_link" style="cursor: pointer;" class="listTitle">HL Internal Team<span id="internalTeamCount" class="count">[' + $j("[title$=HL_OpportunityInternalTeamView]").contents().find('#internalTeamSize').val() +  ']</span></span></a><span class="pipe"> | </span>');

          CreateInternalTeamHover();
          originalWidth = $j("#tipPopupContent").css('width').replace('px','');
          
      });
    
      //Hide the Request Engagement Number Button when Approval already received to prevent multiple submissions
      if($j("span[class='extraStatus']").length > 0){
        $j("span[class='extraStatus']").each(function() {
          if(($j(this).html().trim() === 'Pending' && $j(this).closest('tr').find(".actionLink").html().indexOf('DND') < 0) || ($j(this).html().trim() === 'Approved' && $j(this).closest('tr').find(".actionLink").html().indexOf('DND') < 0))
            $j("[name$=request_engagement_number]").hide();
        });
      }
    
    if(document.getElementsByName('inlineEditCancel')[0])
    {
      document.getElementsByName('inlineEditCancel')[0].onclick = function(){
          sfdcPage.revert($j("[id^='topButtonRow']").attr("id").replace("topButtonRow","")); 
          DocumentReady();
      }
   }
}

function AdditionalClientSubjectPromptCheck(){
var indicatedAdditionalClient = $j("#indicatedAdditionalClient").val() && $j("#indicatedAdditionalClient").val().indexOf('Yes') >= 0;
var indicatedAdditionalSubject = $j("#indicatedAdditionalSubject").val() && $j("#indicatedAdditionalSubject").val().indexOf('Yes') >= 0;
var completedAdditionalClient = $j("#completedAdditionalClient").val() && $j("#completedAdditionalClient").val().indexOf('true') >= 0;
var completedAdditionalSubject = $j("#completedAdditionalSubject").val() && $j("#completedAdditionalSubject").val().indexOf('true') >= 0;

if((indicatedAdditionalClient && !completedAdditionalClient) || (indicatedAdditionalSubject && !completedAdditionalSubject)){
 var iframe_url = $j("#additionalClientSubjectPromptUrl").val() + "?id=" + $j("#opportunityId").val();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
    .dialog({
        autoOpen: false,
        title: 'Additional Clients/Subjects Required',
        resizable: true,
        width: 1100,
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
        open:  function(event, ui) { $j("[title$=Close]").hide(); },
        close: function() {
          $j.blockUI({ css: { 
              border: 'none', 
              padding: '15px', 
              backgroundColor: '#000', 
              '-webkit-border-radius': '10px', 
              '-moz-border-radius': '10px', 
              opacity: .5, 
              color: '#fff' 
          }, message: 'Just a Moment, Checking Requirements...' });
          location.reload();
        }
    }).dialog('open');
}
else{

    var internalTeamPrompt = $j("#internalTeamPrompt").val() && $j("#internalTeamPrompt").val().indexOf('true') >= 0;
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
        location.href = $j("#internalTeamUrl").val() + '?id=' + $j("#opportunityId").val();
    }
}
}

function CreateInternalTeamHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="tipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#tipPopupContent').html('<iframe id="iframeContentId" src="' + $j("#internalTeamViewUrl").val() + '?showheader=false&id=' + $j("#opportunityId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />');
$j("#iframeContentId").load(function() {
     $j(this).contents().find('.pbTitle').css('width','120px').show();
     $j(this).contents().find('[id$=pbHLInternalTeam]').css('border-top-color','#39c');
});
$j("#tipPopupContent").css('height',$j("[title$=HL_OpportunityInternalTeamView]").height() + 'px');
$j('#internalTeamList_link').live('mouseover', function () {
          var padding = $j("#sidebarCell").css('width').replace('px','');
          if(padding > 0)
            padding = parseInt(padding) + 10;
          $j("#tipPopupContent").css('padding-left',padding + 'px');
          $j("#tipPopupContent").css('width',(originalWidth - padding) + 'px');
          if (hideTimer)
              clearTimeout(hideTimer);
          container.css('display', 'block');
});
$j('#internalTeamList_link').live('mouseout', function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);

});

// Allow mouse over of details without hiding details
$j('#tipPopupContent').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#tipPopupContent').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});
}