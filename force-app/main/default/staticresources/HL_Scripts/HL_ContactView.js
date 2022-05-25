var SysAdminProfileId = 'System Administrator';
var DataHygieneProfileId = 'Data Hygiene';
var timer;
var delay = 1000;
var originalWidth;
$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
});

function DocumentReady(){
    if($j("#profileId").val() && $j("#profileId").val().indexOf(SysAdminProfileId) < 0)
    {
       $j("[name$='System Administration']").parent().hide();
       $j("[name$='System Administration']").parent().next().hide();
    }

	//hide data.com clean button
	if($j("#profileId").val() && ($j("#profileId").val().indexOf(SysAdminProfileId) < 0 && $j("#profileId").val().indexOf(DataHygieneProfileId) < 0))
	{
		$j("[name$='datadotcomclean']").hide();
	}
	
    $j( window ).load(function() {
          var activityReferenceId = $j('[name$=Activities]').attr('id');
          //Hide Contact Email History
          $j(".listHoverLinks").find(".listTitle").each(function(){
              if($j(this).html().indexOf("Contact Email History") >= 0){
                    $j(this).parent().next().hide();
                    $j(this).parent().hide();
                 }
          });
          $j(".listHoverLinks").prepend('<a class="linklet" href="#' + activityReferenceId + '"><span id="activityList_link" style="cursor: pointer;" class="listTitle">Activities<span id="activityCount" class="count">[' + $j("#totalActivityRecords").val().trim() +  ']</span></span></a><span class="pipe"> | </span>');
          CreateActivityHover();
          originalWidth = $j("#tipPopupContent").css('width').replace('px','');
    });
    
    $j("[title$=HL_ContactActivityLog]").load(function () {
      $j("[title$=HL_ContactActivityLog]").css('height',this.contentWindow.document.body.scrollHeight + 'px');
      $j("[id$=pbActivityLog]",this.contentWindow.document.body).css('border-color','#8370c2').css('border-left','none').css('border-right','none').css('border-bottom','none');
  });
}
function windowLoaded(){}
function CreateActivityHover(){
var hideDelay = 300;
var hideTimer = null;
var container = $j('<div id="tipPopupContent" class="overlay" style="display:none;"></div>');  
$j('.listHoverLinks').append(container);
$j('#tipPopupContent').html('<iframe id="iframeContentId" src="' + $j("#activityLogUrl").val() + '?showheader=false&id=' + $j("#contactId").val() + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" style="border-radius: 3px;" />');
$j("#tipPopupContent").css('height',$j("[title$=HL_ContactActivityLog]").height() + 'px');
$j("#iframeContentId").load(function() {
     $j(this).contents().find('.pbTitle').css('width','40px').show();
     $j(this).contents().find('[id$=pbActivityLog]').css('border-top-color','#56458c');
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