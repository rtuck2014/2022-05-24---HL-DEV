var SysAdminProfileId = 'System Administrator';
var CAOProfileId = 'CAO';
var StandardProfileId = 'Standard User Template';
var AccountingProfileId ='Accounting User';
var FSProfileId ='FS User';
var ComplianceProfileId='Compliance User';
var ComplianceTAProfileId='Compliance User Training Admin';
var originalWidth, originalRPWidth;
$j = jQuery.noConflict();
        
$j(document).ready(function () {
    DocumentReady();
});

function DocumentReady(){
resizeFrames();

setInterval(function() {
        resizeFrames();
}, 500);
    
	
  $j("[title$=HL_EngagementInternalTeamView]").load(function () {
          $j("[title$=HL_EngagementInternalTeamView]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
  });
$j("[title$=HL_RevenueProjectionRelatedListView]").load(function () {
  $j("[title$=HL_RevenueProjectionRelatedListView]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
  $j("[id$=pbRevenueProjection]",this.contentWindow.document.body).css('border-left','none').css('border-right','none').css('border-bottom','none');
});
  if($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0)
  {
     $j("[name$='System Administration']").parent().hide();
     $j("[name$='System Administration']").parent().next().hide();
  }

  if($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0 && $j("#profileId").val().indexOf(CAOProfileId) < 0 && $j("#profileId").val().indexOf(AccountingProfileId) < 0){
     $j("[name$='LOB - Administration']").parent().hide();
     $j("[name$='LOB - Administration']").parent().next().hide();
     $j("[name$=new_revenue_accrual]").hide();
  }

  if($j("#hasCommentsAccess").val() && $j("#hasCommentsAccess").val().trim() === 'false' && ($j("#profileId").val() && ($j("#profileId").val().indexOf(ComplianceProfileId) < 0) && ($j("#profileId").val() || $j("#profileId").val().indexOf(ComplianceTAProfileId) < 0)))
  {
    $j("[name$='new_comment']").hide();
    // Adding new section as Engagement Allocation
    $j("[name$='new_engagementallocation']").hide();
  }
	$j( window ).load(function() {
	       //Remove Counterparties
	   $j(".listHoverLinks").find(".listTitle").each(function(){
	      if($j(this).html().indexOf("Counterparties") >= 0){
	          var counterpartyContainer = $j(this).parent().attr('id');
	          $j("#" + counterpartyContainer.replace('_link','')).hide();
	          $j(this).parent().next().hide();
	          $j(this).parent().hide();
	       }
	   });

	   var internalTeamReferenceId = $j('[name$="HL Internal Team"]').attr('id');
	   var revenueProjectionReferenceId = $j('[name$="Revenue Projection"]').attr('id');
	   $j(".listHoverLinks").prepend('<a class="linklet" href="#' + internalTeamReferenceId + '"><span id="internalTeamList_link" style="cursor: pointer;" class="listTitle">HL Internal Team<span id="internalTeamCount" class="count">[' + $j("[title$=HL_EngagementInternalTeamView]").contents().find('#internalTeamSize').val() +  ']</span></span></a><span class="pipe"> | </span>');
	   $j(".listHoverLinks").find(".listTitle").each(function(){
		   if($j(this).html().indexOf("Revenue Accruals") >= 0){
             if($j("[title$=HL_RevenueProjectionRelatedListView]").contents().find('#revenueProjectionSize').length > 0)
              $j(this).parent().next().append('<a class="linklet" href="#' + revenueProjectionReferenceId + '"><span id="revenueProjectionList_link" style="cursor: pointer;" class="listTitle">Revenue Projection<span id="revenueProjectionCount" class="count">[' + $j("[title$=HL_RevenueProjectionRelatedListView]").contents().find('#revenueProjectionSize').val() +  ']</span></span></a><span class="pipe"> | </span>');
		   }
     });
	 
	  CreateInternalTeamHover();
	  CreateRevenueProjectionHover();
	  originalWidth = $j("#tipPopupContent").css('width').replace('px','');
	  originalRPWidth = $j("#rpTipPopupContent").css('width').replace('px','');
	});
	  
	if(
		($j("#LOB").val() === 'CF' &&  !(
			$j("#jobType").val() === 'Buyside' ||
			$j("#jobType").val() === 'Sellside' ||
			$j("#jobType").val() === 'Debt Capital Markets' ||
			$j("#jobType").val() === 'Equity Capital Markets' ||
			$j("#jobType").val() === 'Illiquid Financial Assets' ||
			$j("#jobType").val() === 'Tech+IP - Patent Sales' ||
			$j("#jobType").val() === 'Tech+IP - Tech+IP Sales' ||
			$j("#jobType").val() === 'Tech+IP - Buyside' ||
			$j("#jobType").val() === 'Syndicated Finance' ||
			$j("#jobType").val() === 'General Financial Advisory' ||
            $j("#jobType").val() === 'Strategy' ||
            $j("#jobType").val() === 'Post Merger Integration' ||
            $j("#jobType").val() === 'General Financial Advisory' ||
			$j("#jobType").val() === 'Valuation Advisory' ||
			$j("#jobType").val() === 'Merger')) || ($j("#profileId").val() && $j("#profileId").val().indexOf(FSProfileId) >= 0)
		){
			$j("[name$=counterparties]").hide();										
		}

    if($j("#onEIT").val() === 'false'){
        // $j("[name$=restricted_list").hide(); //hide restricted list if not on EIT  - ayu took this off on tracy's orders 6/7
        $j("[name$=cf_engagement_summary").hide(); //hide summary if not on EIT
        $j("[name$=counterparties]").hide();	// hide Counterparties if not on EIT
    }	
}

function CreateInternalTeamHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="tipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#tipPopupContent').html('<iframe id="iframeContentId" src="' + $j("#internalTeamViewUrl").val() + '?showheader=false&id=' + $j("#engagementId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />');
$j("#iframeContentId").load(function() {
     $j(this).contents().find('.pbTitle').css('width','120px').show();
     $j(this).contents().find('[id$=pbHLInternalTeam]').css('border-top-color','#e56363');
});
$j("#tipPopupContent").css('height',$j("[title$=HL_EngagementInternalTeamView]").height() + 'px');
$j('#internalTeamList_link').live('mouseover', function () {
          var padding = $j("#sidebarCell").css('width').replace('px','');
          if(padding > 0)
            padding = parseInt(padding) + 10;
          $j("#tipPopupContent").css('padding-left',padding + 'px');
          $j("#tipPopupContent").css('width',(originalRPWidth - padding) + 'px');
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

function CreateRevenueProjectionHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="rpTipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#rpTipPopupContent').html('<iframe id="iframeContentId" src="' + $j("#revenueprojectionViewURL").val() + '?showheader=false&id=' + $j("#engagementId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />');
$j("#iframeContentId").load(function() {
     $j(this).contents().find('.pbTitle').css('width','120px').show();
     $j(this).contents().find('[id$=pbRevenueProjection]').css('border-top-color','#e56363');
});
$j("#rpTipPopupContent").css('height',$j("[title$=HL_RevenueProjectionRelatedListView]").height() + 'px');
$j('#revenueProjectionList_link').live('mouseover', function () {
          var padding = $j("#sidebarCell").css('width').replace('px','');
          if(padding > 0)
            padding = parseInt(padding) + 10;
          $j("#rpTipPopupContent").css('padding-left',padding + 'px');
          $j("#rpTipPopupContent").css('width',(originalWidth - padding) + 'px');
          if (hideTimer)
              clearTimeout(hideTimer);
          container.css('display', 'block');
});
$j('#revenueProjectionList_link').live('mouseout', function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);

});

// Allow mouse over of details without hiding details
$j('#rpTipPopupContent').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#rpTipPopupContent').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});

// Allow mouse over of details without hiding details
$j('#rpTipPopupContent').mouseover(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
});

// Hide after mouseout
$j('#rpTipPopupContent').mouseout(function () {
    if (hideTimer)
        clearTimeout(hideTimer);
    hideTimer = setTimeout(function () {
        container.css('display', 'none');
    }, hideDelay);
});
}

function resizeFrames() {
  if($j("[title$=HL_RevenueProjectionRelatedListView]").length > 0 && $j("[title$=HL_RevenueProjectionRelatedListView]")[0].contentWindow && $j("[title$=HL_RevenueProjectionRelatedListView]")[0].contentWindow.document.body){
      $j("[title$=HL_RevenueProjectionRelatedListView]").css('height',($j($j("[title$=HL_RevenueProjectionRelatedListView]")[0].contentWindow.document.body).height() + 10) + 'px');
  }
} 