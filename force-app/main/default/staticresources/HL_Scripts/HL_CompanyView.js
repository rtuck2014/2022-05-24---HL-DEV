$j = jQuery.noConflict();
var SysAdminProfileId = 'System Administrator';
var DataHygieneProfileId = 'Data Hygiene';
var timer;
var delay = 1000;
var activityHistoryCount = 0;
var originalWidth, originalOppWidth, originalEngWidth, originalEngShownWidth;
$j(document).ready(function () {
DocumentReady();
});

function DocumentReady(){
resizeFrames();

setInterval(function() {
        resizeFrames();
}, 500);
    
if($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0)
{
   $j("[name$='System Administration']").parent().hide();
   $j("[name$='System Administration']").parent().next().hide();
}

if(($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0) && $j("#userSyncRights").val() === 'false')
{
   $j("[name$=contact_address_sync]").hide();
}

//hide data.com clean button
if($j("#profileId").val() && ($j("#profileId").val().indexOf(SysAdminProfileId) < 0 && $j("#profileId").val().indexOf(DataHygieneProfileId) < 0) && $j("#dataDotCom").val() ==='false')
  {
    $j("[name$='datadotcomclean']").hide();
    $j("[id$='gwt_jigsawsearch']").hide();
    $j("[name$='prospecting_insights']").hide();
    $j("[name$='company_hierarchy']").hide();
  }

$j("[title$=HL_CompanyActivityLog]").load(function () {
  $j("[title$=HL_CompanyActivityLog]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
  $j("[id$=pbActivityLog]",this.contentWindow.document.body).css('border-color','#8a9ebe').css('border-left','none').css('border-right','none').css('border-bottom','none');
});

$j("[title$=HL_InvestorsList]").load(function () {
    $j("[title$=HL_InvestorsList]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
});

$j("[title$=HL_InvestmentsList]").load(function () {
    $j("[title$=HL_InvestmentsList]").css('height',this.contentWindow.document.body.scrollHeight + 'px');;
});

//$("[title$=HL_CoverageTeamAggregateView]").hide();

$j("[title$=HL_CoverageTeamAggregateView]").load(function () {
    $j("[title$=HL_CoverageTeamAggregateView]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
    $j("[id$=pbCoverageTeamAggregate]",this.contentWindow.document.body).css('border-color','#8a9ebe').css('border-left','none').css('border-right','none').css('border-bottom','none');
    fullCoverageTeamCount = this.contentWindow.document.getElementById('totalCoverageTeamCount').innerHTML; 
});

$j("[title$=HL_CompanyRelatedOppsView]").load(function () {
    $j("[title$=HL_CompanyRelatedOppsView]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
    $j("[id$=pbOpps]",this.contentWindow.document.body).css('border-color','#8a9ebe').css('border-left','none').css('border-right','none').css('border-bottom','none');
});

$j("[title$=HL_CompanyRelatedEngagementsView]").load(function () {
    $j("[title$=HL_CompanyRelatedEngagementsView]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
    $j("[id$=pbEngs]",this.contentWindow.document.body).css('border-color','#8a9ebe').css('border-left','none').css('border-right','none').css('border-bottom','none');
});

$j("[title$=HL_CompanyRelatedEngagementsShown]").load(function () {
    $j("[title$=HL_CompanyRelatedEngagementsShown]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
    $j("[id$=pbEngs]",this.contentWindow.document.body).css('border-color','#8a9ebe').css('border-left','none').css('border-right','none').css('border-bottom','none');
});
    
$j( window ).load(function() {
     var activityReferenceId = $j('[name$=Activities]').attr('id');
     var opportunityReferenceId = $j('[name$="Opportunities"]').attr('id');
     var engagementReferenceId = $j('[name$="Engagements"]').attr('id');
      var engagementsShownReferenceId = $j('[name$="Engagements Shown"]').attr('id');
     $j(".listHoverLinks").prepend('<a class="linklet" href="#' + activityReferenceId + '"><span id="activityList_link" style="cursor: pointer;" class="listTitle">Activities<span id="activityCount" class="count">[' + $j("#totalActivityRecords").val().trim() +  ']</span></span></a><span class="pipe"> | </span>');
     $j(".listHoverLinks").find(".listTitle").each(function(){
          if($j(this).html().indexOf("Coverage Team") >= 0){
             if($j("[title$=HL_CompanyRelatedOppsView]").contents().find('#opportunitiesSize').length > 0)
              $j(this).parent().next().append('<a class="linklet" href="#' + opportunityReferenceId + '"><span id="opportunityList_link" style="cursor: pointer;" class="listTitle">Opportunities<span id="opportunityCount" class="count">[' + $j("[title$=HL_CompanyRelatedOppsView]").contents().find('#opportunitiesSize').val() +  ']</span></span></a><span class="pipe"> | </span>');
             if($j("[title$=HL_CompanyRelatedEngagementsView]").contents().find('#engagementsSize').length > 0)
              $j(this).parent().next().append('<a class="linklet" href="#' + engagementReferenceId + '"><span id="engagementList_link" style="cursor: pointer;" class="listTitle">Engagements<span id="engagementCount" class="count">[' + $j("[title$=HL_CompanyRelatedEngagementsView]").contents().find('#engagementsSize').val() +  ']</span></span></a><span class="pipe"> | </span>');
             if($j("[title$=HL_CompanyRelatedEngagementsShown]").contents().find('#engagementsShownSize').length > 0)
              $j(this).parent().next().append('<a class="linklet" href="#' + engagementsShownReferenceId + '"><span id="engagementsShownList_link" style="cursor: pointer;" class="listTitle">Engagements Shown<span id="engagementsShownCount" class="count">[' + $j("[title$=HL_CompanyRelatedEngagementsShown]").contents().find('#engagementsShownSize').val() +  ']</span></span></a><span class="pipe"> | </span>');
          }
     });
     CreateActivityHover();
     CreateOpportunityHover();
     CreateEngagementHover();
     CreateEngagementsShownHover();
     originalWidth = $j("#tipPopupContent").css('width').replace('px','');
     originalOppWidth = $j("#oppTipPopupContent").css('width').replace('px','');
     originalEngWidth = $j("#engTipPopupContent").css('width').replace('px','');
     originalEngShownWidth = $j("#engShownTipPopupContent").css('width').replace('px','');
});
}

function CreateActivityHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="tipPopupContent" class="overlay" style="display:none; "></div>');  
$j('.listHoverLinks').append(container);
$j('#tipPopupContent').html('<iframe id="iframeContentId" src="' + $j("#activityLogUrl").val() + '?showheader=false&id=' + $j("#accountId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" style="box-shadow: 2px 2px 2px 2px #888888; border-radius: 3px;" />');
$j("#tipPopupContent").css('height',$j("[title$=HL_CompanyActivityLog]").height() + 'px');
$j("#iframeContentId").load(function() {
     $j(this).contents().find('.pbTitle').css('width','40px').show();
     $j(this).contents().find('[id$=pbActivityLog]').css('border-top-color','#236fbd');
});
$j('#activityList_link').live('mouseover', function () {
      var padding = $j("#sidebarCell").css('width').replace('px','');
       if(padding > 0)
         padding = parseInt(padding) + 10;
       $j("#tipPopupContent").css('padding-left',padding + 'px');
       $j("#tipPopupContent").css('width',(originalWidth - padding) + 'px');
       if (hideTimer)
              clearTimeout(hideTimer);
        container.css('display', 'block');
});
$j('#activityList_link').live('mouseout', function () {
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

function CreateOpportunityHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="oppTipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#oppTipPopupContent').html('<iframe id="iframeOppContentId" src="' + $j("#opportunityViewUrl").val() + '?showheader=false&id=' + $j("#accountId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" style="border-radius: 3px;" />');
$j("#oppTipPopupContent").css('height',$j("[title$=HL_CompanyRelatedOppsView]").height() + 'px');
$j('#opportunityList_link').live('mouseover', function () {
          var padding = $j("#sidebarCell").css('width').replace('px','');
          if(padding > 0)
            padding = parseInt(padding) + 10;
          $j("#oppTipPopupContent").css('padding-left',padding + 'px');
          $j("#oppTipPopupContent").css('width',(originalOppWidth - padding) + 'px');
          if (hideTimer)
              clearTimeout(hideTimer);
          container.css('display', 'block');
});
$j('#opportunityList_link').live('mouseout', function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);

});

// Allow mouse over of details without hiding details
$j('#oppTipPopupContent').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#oppTipPopupContent').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});
} 

function CreateEngagementHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="engTipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#engTipPopupContent').html('<iframe id="iframeEngContentId" src="' + $j("#engagementViewUrl").val() + '?showheader=false&id=' + $j("#accountId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" style="border-radius: 3px;" />');
$j("#engTipPopupContent").css('height',$j("[title$=HL_CompanyRelatedEngagementsView]").height() + 'px');
$j('#engagementList_link').live('mouseover', function () {
          var padding = $j("#sidebarCell").css('width').replace('px','');
          if(padding > 0)
            padding = parseInt(padding) + 10;
          $j("#engTipPopupContent").css('padding-left',padding + 'px');
          $j("#engTipPopupContent").css('width',(originalEngWidth - padding) + 'px');
          if (hideTimer)
              clearTimeout(hideTimer);
          container.css('display', 'block');
});
$j('#engagementList_link').live('mouseout', function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);

});

// Allow mouse over of details without hiding details
$j('#engTipPopupContent').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#engTipPopupContent').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});
} 

function CreateEngagementsShownHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="engShownTipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#engShownTipPopupContent').html('<iframe id="iframeEngShownContentId" src="' + $j("#engagementsShownViewUrl").val() + '?showheader=false&id=' + $j("#accountId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" style="border-radius: 3px;" />');
$j("#engShownTipPopupContent").css('height',$j("[title$=HL_CompanyRelatedEngagementsShown]").height() + 'px');
$j('#engagementsShownList_link').live('mouseover', function () {
          var padding = $j("#sidebarCell").css('width').replace('px','');
          if(padding > 0)
            padding = parseInt(padding) + 10;
          $j("#engShownTipPopupContent").css('padding-left',padding + 'px');
          $j("#engShownTipPopupContent").css('width',(originalEngShownWidth - padding) + 'px');
          if (hideTimer)
              clearTimeout(hideTimer);
          container.css('display', 'block');
});
$j('#engagementsShownList_link').live('mouseout', function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);

});

// Allow mouse over of details without hiding details
$j('#engShownTipPopupContent').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#engShownTipPopupContent').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});
} 

function resizeFrames() {
  if($j("[title$=HL_CoverageTeamAggregateView]").length > 0 && $j("[title$=HL_CoverageTeamAggregateView]")[0].contentWindow && $j("[title$=HL_CoverageTeamAggregateView]")[0].contentWindow.document.body){
      $j("[title$=HL_CoverageTeamAggregateView]").css('height',($j($j("[title$=HL_CoverageTeamAggregateView]")[0].contentWindow.document.body).height() + 10) + 'px');
      
  }

  if($j("[title$=HL_CompanyActivityLog]").length > 0 && $j("[title$=HL_CompanyActivityLog]")[0].contentWindow && $j("[title$=HL_CompanyActivityLog]")[0].contentWindow.document.body){
      $j("[title$=HL_CompanyActivityLog]").css('height',($j($j("[title$=HL_CompanyActivityLog]")[0].contentWindow.document.body).height() + 10) + 'px');
  }
   
  if($j("[title$=HL_InvestorsList]").length > 0 && $j("[title$=HL_InvestorsList]")[0].contentWindow && $j("[title$=HL_InvestorsList]")[0].contentWindow.document.body){
      $j("[title$=HL_InvestorsList]").css('height',($j($j("[title$=HL_InvestorsList]")[0].contentWindow.document.body).height() + 10) + 'px');
  }

  if($j("[title$=HL_InvestmentsList]").length > 0 && $j("[title$=HL_InvestmentsList]")[0].contentWindow && $j("[title$=HL_InvestmentsList]")[0].contentWindow.document.body){
      $j("[title$=HL_InvestmentsList]").css('height',($j($j("[title$=HL_InvestmentsList]")[0].contentWindow.document.body).height() + 10) + 'px');
  }
  
  if($j("[title$=HL_CompanyRelatedOppsView]").length > 0 && $j("[title$=HL_CompanyRelatedOppsView]")[0].contentWindow && $j("[title$=HL_CompanyRelatedOppsView]")[0].contentWindow.document.body){
     if($j($j("[title$=HL_CompanyRelatedOppsView]")[0].contentWindow.document.body).find("em").length === 0 || $j($j("[title$=HL_CompanyRelatedOppsView]")[0].contentWindow.document.body).find("em").html().indexOf("Content cannot be displayed") < 0)
        $j("[title$=HL_CompanyRelatedOppsView]").css('height',($j($j("[title$=HL_CompanyRelatedOppsView]")[0].contentWindow.document.body).height() + 10) + 'px');
  }
    
  if($j("[title$=HL_CompanyRelatedEngagementsView]").length > 0 && $j("[title$=HL_CompanyRelatedEngagementsView]")[0].contentWindow && $j("[title$=HL_CompanyRelatedEngagementsView]")[0].contentWindow.document.body){
     if($j($j("[title$=HL_CompanyRelatedEngagementsView]")[0].contentWindow.document.body).find("em").length === 0 || $j($j("[title$=HL_CompanyRelatedEngagementsView]")[0].contentWindow.document.body).find("em").html().indexOf("Content cannot be displayed") < 0)
        $j("[title$=HL_CompanyRelatedEngagementsView]").css('height',($j($j("[title$=HL_CompanyRelatedEngagementsView]")[0].contentWindow.document.body).height() + 10) + 'px');
  }

  if($j("[title$=HL_CompanyRelatedEngagementsShown]").length > 0 && $j("[title$=HL_CompanyRelatedEngagementsShown]")[0].contentWindow && $j("[title$=HL_CompanyRelatedEngagementsShown]")[0].contentWindow.document.body){
     if($j($j("[title$=HL_CompanyRelatedEngagementsShown]")[0].contentWindow.document.body).find("em").length === 0 || $j($j("[title$=HL_CompanyRelatedEngagementsShown]")[0].contentWindow.document.body).find("em").html().indexOf("Content cannot be displayed") < 0)
        $j("[title$=HL_CompanyRelatedEngagementsShown]").css('height',($j($j("[title$=HL_CompanyRelatedEngagementsShown]")[0].contentWindow.document.body).height() + 10) + 'px');
  }
  
  if($j("#tipPopupContent").length > 0 && $j("#iframeContentId")[0].contentWindow && $j("#iframeContentId")[0].contentWindow.document.body){
    $j("#tipPopupContent").css('height',($j($j("#iframeContentId")[0].contentWindow.document.body).height() + 40) + 'px');
  }
  
  if($j("#oppTipPopupContent").length > 0 && $j("#iframeOppContentId")[0].contentWindow && $j("#iframeOppContentId")[0].contentWindow.document.body){
    $j("#oppTipPopupContent").css('height',($j($j("#iframeOppContentId")[0].contentWindow.document.body).height() + 40) + 'px');
  }
    
  if($j("#engTipPopupContent").length > 0 && $j("#iframeEngContentId")[0].contentWindow && $j("#iframeEngContentId")[0].contentWindow.document.body){
  $j("#engTipPopupContent").css('height',($j($j("#iframeEngContentId")[0].contentWindow.document.body).height() + 40) + 'px');
  }
    
  if($j("#engShownTipPopupContent").length > 0 && $j("#iframeEngShownContentId")[0].contentWindow && $j("#iframeEngShownContentId")[0].contentWindow.document.body){
  $j("#engShownTipPopupContent").css('height',($j($j("#iframeEngShownContentId")[0].contentWindow.document.body).height() + 40) + 'px');
  }
}